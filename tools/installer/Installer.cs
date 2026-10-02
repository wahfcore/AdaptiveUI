// AdaptiveUI-Setup: a small, plain Windows installer for the AdaptiveUI addon.
//
// What it does, all of it: finds your World of Warcraft folder, unpacks the addon that is
// embedded in this file into  <flavour>\Interface\AddOns\AdaptiveUI , checks every file
// against a SHA-256 list, and keeps a backup of whatever was there before.
// What it never does: use the network, write the registry, install services or scheduled
// tasks, run scripts, or unpack anything to a temp folder and execute it. Registry access is
// read-only, to find the game. Source: tools/installer/ in the AdaptiveUI repository.
//
// Language level is C# 5 (the compiler that ships with Windows).
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Diagnostics;
using System.Drawing;
using System.Drawing.Text;
using System.IO;
using System.IO.Compression;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using System.Windows.Forms;
using Microsoft.Win32;

namespace AdaptiveUISetup
{
    // One game flavour folder, e.g. C:\Program Files (x86)\World of Warcraft\_classic_beta_
    class Flavour
    {
        public string Path;
        public string Label;
        public override string ToString() { return Label; }
    }

    class InstallException : Exception
    {
        public InstallException(string message) : base(message) { }
    }

    static class Payload
    {
        static Stream Res(string name)
        {
            Stream s = Assembly.GetExecutingAssembly().GetManifestResourceStream(name);
            if (s == null) throw new InstallException("This installer is damaged: missing " + name + ".");
            return s;
        }

        public static string Text(string name)
        {
            using (StreamReader r = new StreamReader(Res(name), Encoding.UTF8)) return r.ReadToEnd().Trim();
        }

        public static byte[] Bytes(string name)
        {
            using (Stream s = Res(name))
            using (MemoryStream m = new MemoryStream()) { s.CopyTo(m); return m.ToArray(); }
        }

        public static string Version() { return Text("version.txt"); }

        // relative path (forward slashes) -> lowercase sha256
        public static Dictionary<string, string> Manifest()
        {
            Dictionary<string, string> map = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
            foreach (string line in Text("payload.sha256").Split('\n'))
            {
                string t = line.Trim();
                if (t.Length < 66) continue;
                map[t.Substring(66).Replace('\\', '/')] = t.Substring(0, 64).ToLowerInvariant();
            }
            return map;
        }

        public static ZipArchive Zip() { return new ZipArchive(new MemoryStream(Bytes("payload.zip")), ZipArchiveMode.Read); }
    }

    static class Setup
    {
        public const string AddonName = "AdaptiveUI";

        // ---------------------------------------------------------------- finding the game

        static void AddRoot(List<string> roots, string path)
        {
            if (string.IsNullOrEmpty(path)) return;
            path = path.Trim().Trim('"').TrimEnd('\\', '/');
            if (path.Length == 0) return;
            string leaf = System.IO.Path.GetFileName(path);
            if (Regex.IsMatch(leaf, "^_.+_$")) path = System.IO.Path.GetDirectoryName(path);
            if (string.IsNullOrEmpty(path) || !Directory.Exists(path)) return;
            foreach (string r in roots) if (string.Equals(r, path, StringComparison.OrdinalIgnoreCase)) return;
            roots.Add(path);
        }

        static string ReadValue(RegistryHive hive, RegistryView view, string key, string value)
        {
            try
            {
                using (RegistryKey b = RegistryKey.OpenBaseKey(hive, view))
                using (RegistryKey k = b.OpenSubKey(key, false))
                {
                    if (k == null) return null;
                    object v = k.GetValue(value);
                    return v == null ? null : v.ToString();
                }
            }
            catch (Exception) { return null; }
        }

        // Read-only: the registry keys Blizzard's installer and Battle.net leave behind, then the usual folders.
        public static List<string> FindWowRoots()
        {
            List<string> roots = new List<string>();
            string[] keys = {
                @"SOFTWARE\WOW6432Node\Blizzard Entertainment\World of Warcraft",
                @"SOFTWARE\Blizzard Entertainment\World of Warcraft" };
            string[] uninstall = {
                @"SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\World of Warcraft",
                @"SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\World of Warcraft" };
            foreach (RegistryView view in new RegistryView[] { RegistryView.Registry64, RegistryView.Registry32 })
            {
                foreach (string k in keys) AddRoot(roots, ReadValue(RegistryHive.LocalMachine, view, k, "InstallPath"));
                foreach (string k in uninstall)
                {
                    AddRoot(roots, ReadValue(RegistryHive.LocalMachine, view, k, "InstallLocation"));
                    AddRoot(roots, ReadValue(RegistryHive.CurrentUser, view, k, "InstallLocation"));
                }
            }
            foreach (DriveInfo d in DriveInfo.GetDrives())
            {
                if (d.DriveType != DriveType.Fixed) continue;
                string r = d.RootDirectory.FullName;
                AddRoot(roots, System.IO.Path.Combine(r, @"Program Files (x86)\World of Warcraft"));
                AddRoot(roots, System.IO.Path.Combine(r, @"Program Files\World of Warcraft"));
                AddRoot(roots, System.IO.Path.Combine(r, @"Games\World of Warcraft"));
                AddRoot(roots, System.IO.Path.Combine(r, @"World of Warcraft"));
                AddRoot(roots, System.IO.Path.Combine(r, @"Blizzard\World of Warcraft"));
            }
            return roots;
        }

        static string FriendlyName(string folder)
        {
            switch (folder.ToLowerInvariant())
            {
                case "_classic_beta_": return "Classic Forever beta";
                case "_classic_": return "Classic";
                case "_classic_era_": return "Classic Era";
                case "_classic_ptr_": return "Classic PTR";
                case "_classic_era_ptr_": return "Classic Era PTR";
                default: return folder;
            }
        }

        // Classic-family flavour folders under a game root. Retail folders are left out on purpose.
        public static List<Flavour> FindFlavours(string root)
        {
            List<Flavour> found = new List<Flavour>();
            if (!Directory.Exists(root)) return found;
            foreach (string dir in Directory.GetDirectories(root))
            {
                string name = System.IO.Path.GetFileName(dir);
                if (!Regex.IsMatch(name, "^_.+_$")) continue;
                string n = name.ToLowerInvariant();
                if (n == "_retail_" || n == "_ptr_" || n == "_xptr_" || n == "_beta_" || n == "_ptr2_") continue;
                found.Add(new Flavour { Path = dir, Label = FriendlyName(name) + "   (" + System.IO.Path.GetFileName(root) + ")" });
            }
            found.Sort(delegate (Flavour a, Flavour b)
            {
                // the Forever beta first
                bool fa = a.Path.EndsWith("_classic_beta_", StringComparison.OrdinalIgnoreCase);
                bool fb = b.Path.EndsWith("_classic_beta_", StringComparison.OrdinalIgnoreCase);
                if (fa != fb) return fa ? -1 : 1;
                return string.Compare(a.Path, b.Path, StringComparison.OrdinalIgnoreCase);
            });
            return found;
        }

        public static List<Flavour> FindAllFlavours()
        {
            List<Flavour> all = new List<Flavour>();
            foreach (string root in FindWowRoots())
                foreach (Flavour f in FindFlavours(root)) all.Add(f);
            return all;
        }

        // The user picked a folder by hand: a game root, a flavour folder, or something with an Interface folder.
        public static List<Flavour> FromPickedFolder(string picked)
        {
            List<Flavour> found = FindFlavours(picked);
            if (found.Count > 0) return found;
            if (Directory.Exists(System.IO.Path.Combine(picked, "Interface")) ||
                Regex.IsMatch(System.IO.Path.GetFileName(picked.TrimEnd('\\', '/')), "^_.+_$"))
                found.Add(new Flavour { Path = picked.TrimEnd('\\', '/'), Label = picked.TrimEnd('\\', '/') });
            return found;
        }

        // ---------------------------------------------------------------- paths and state

        public static string AddOns(string flavour) { return System.IO.Path.Combine(flavour, @"Interface\AddOns"); }
        public static string Dest(string flavour) { return System.IO.Path.Combine(AddOns(flavour), AddonName); }

        public static string InstalledVersion(string flavour)
        {
            string toc = System.IO.Path.Combine(Dest(flavour), AddonName + ".toc");
            if (!File.Exists(toc)) return null;
            foreach (string line in File.ReadAllLines(toc))
            {
                Match m = Regex.Match(line, @"^\s*##\s*Version:\s*(.+?)\s*$", RegexOptions.IgnoreCase);
                if (m.Success) return m.Groups[1].Value;
            }
            return "unknown version";
        }

        public static List<string> Backups(string flavour)
        {
            List<string> list = new List<string>();
            string addons = AddOns(flavour);
            if (!Directory.Exists(addons)) return list;
            foreach (string d in Directory.GetDirectories(addons, AddonName + ".backup-*")) list.Add(d);
            list.Sort(StringComparer.OrdinalIgnoreCase);
            list.Reverse(); // newest first: the names carry a sortable timestamp
            return list;
        }

        // Can we write here without elevation? Tries a harmless probe file in the nearest existing folder.
        public static bool CanWrite(string flavour)
        {
            string dir = AddOns(flavour);
            while (!string.IsNullOrEmpty(dir) && !Directory.Exists(dir)) dir = System.IO.Path.GetDirectoryName(dir);
            if (string.IsNullOrEmpty(dir)) return false;
            string probe = System.IO.Path.Combine(dir, ".adaptiveui-write-test-" + Guid.NewGuid().ToString("N"));
            try { File.WriteAllText(probe, "x"); File.Delete(probe); return true; }
            catch (UnauthorizedAccessException) { return false; }
            catch (IOException) { return false; }
            catch (System.Security.SecurityException) { return false; }
        }

        static string Stamp() { return DateTime.Now.ToString("yyyyMMdd-HHmmss"); }

        static string Unique(string basePath)
        {
            string p = basePath;
            int n = 2;
            while (Directory.Exists(p) || File.Exists(p)) p = basePath + "-" + (n++);
            return p;
        }

        static string Sha256(string file)
        {
            using (FileStream fs = File.OpenRead(file))
            using (SHA256 sha = SHA256.Create())
            {
                byte[] h = sha.ComputeHash(fs);
                StringBuilder sb = new StringBuilder();
                foreach (byte b in h) sb.Append(b.ToString("x2"));
                return sb.ToString();
            }
        }

        // ---------------------------------------------------------------- verify

        // Returns a list of problems: missing or changed files. Extra files (yours) are not a problem.
        public static List<string> Verify(string dir)
        {
            List<string> problems = new List<string>();
            foreach (KeyValuePair<string, string> kv in Payload.Manifest())
            {
                string file = System.IO.Path.Combine(dir, kv.Key.Replace('/', '\\'));
                if (!File.Exists(file)) { problems.Add("missing: " + kv.Key); continue; }
                if (Sha256(file) != kv.Value) problems.Add("changed: " + kv.Key);
            }
            return problems;
        }

        // ---------------------------------------------------------------- actions

        static void Extract(string staging)
        {
            string full = System.IO.Path.GetFullPath(staging);
            using (ZipArchive zip = Payload.Zip())
            {
                foreach (ZipArchiveEntry e in zip.Entries)
                {
                    if (e.FullName.EndsWith("/")) continue;
                    if (!e.FullName.StartsWith(AddonName + "/")) throw new InstallException("Unexpected file in payload: " + e.FullName);
                    string rel = e.FullName.Substring(AddonName.Length + 1).Replace('/', '\\');
                    string target = System.IO.Path.GetFullPath(System.IO.Path.Combine(full, rel));
                    if (!target.StartsWith(full + "\\", StringComparison.OrdinalIgnoreCase)) throw new InstallException("Unsafe path in payload: " + e.FullName);
                    Directory.CreateDirectory(System.IO.Path.GetDirectoryName(target));
                    using (Stream src = e.Open())
                    using (FileStream dst = File.Create(target)) src.CopyTo(dst);
                }
            }
        }

        // Unpack beside the target, verify, move the old folder aside, move the new one in, verify again.
        // Any failure puts the old folder back. Returns the backup path, or null if there was nothing to back up.
        public static string Install(string flavour, Action<string> log)
        {
            if (!Directory.Exists(flavour)) throw new InstallException("That game folder does not exist: " + flavour);
            string addons = AddOns(flavour);
            Directory.CreateDirectory(addons);
            string dest = Dest(flavour);
            string stamp = Stamp();
            string staging = Unique(dest + ".installing-" + stamp);
            string backup = null;
            try
            {
                log("Unpacking " + Payload.Version() + " ...");
                Extract(staging);
                List<string> bad = Verify(staging);
                if (bad.Count > 0) throw new InstallException("The unpacked files failed the SHA-256 check (" + bad[0] + "). Nothing was changed.");
                log("Every file matches its SHA-256.");
                if (Directory.Exists(dest))
                {
                    backup = Unique(dest + ".backup-" + stamp);
                    Directory.Move(dest, backup);
                    log("Backed up the existing copy to " + System.IO.Path.GetFileName(backup));
                }
                try { Directory.Move(staging, dest); }
                catch (Exception)
                {
                    if (backup != null && !Directory.Exists(dest)) Directory.Move(backup, dest);
                    throw;
                }
                List<string> after = Verify(dest);
                if (after.Count > 0)
                {
                    Directory.Delete(dest, true);
                    if (backup != null) Directory.Move(backup, dest);
                    throw new InstallException("The installed files failed the SHA-256 check (" + after[0] + "). The previous copy was put back.");
                }
                return backup;
            }
            finally
            {
                if (Directory.Exists(staging)) { try { Directory.Delete(staging, true); } catch (Exception) { } }
            }
        }

        // Swap the newest backup in. The copy that was live becomes a backup too, so nothing is lost.
        public static string Restore(string flavour, Action<string> log)
        {
            List<string> backups = Backups(flavour);
            if (backups.Count == 0) throw new InstallException("There is no backup to restore in " + AddOns(flavour));
            string dest = Dest(flavour);
            string chosen = backups[0];
            string displaced = null;
            if (Directory.Exists(dest))
            {
                displaced = Unique(dest + ".backup-" + Stamp());
                Directory.Move(dest, displaced);
                log("Set the current copy aside as " + System.IO.Path.GetFileName(displaced));
            }
            try { Directory.Move(chosen, dest); }
            catch (Exception)
            {
                if (displaced != null && !Directory.Exists(dest)) Directory.Move(displaced, dest);
                throw;
            }
            log("Restored " + System.IO.Path.GetFileName(chosen));
            return chosen;
        }

        public static void Uninstall(string flavour, Action<string> log)
        {
            string dest = Dest(flavour);
            if (!Directory.Exists(dest)) throw new InstallException("AdaptiveUI is not installed in " + AddOns(flavour));
            // Only ever delete a folder that really is this addon, directly inside an AddOns folder.
            if (!File.Exists(System.IO.Path.Combine(dest, AddonName + ".toc")) ||
                !string.Equals(System.IO.Path.GetFileName(System.IO.Path.GetDirectoryName(dest)), "AddOns", StringComparison.OrdinalIgnoreCase))
                throw new InstallException("Refusing to delete " + dest + ": it does not look like the AdaptiveUI addon folder.");
            Directory.Delete(dest, true);
            log("Removed " + dest);
            log("Your settings (WTF\\...\\SavedVariables\\AdaptiveUI.lua) and any backups were left alone.");
        }
    }

    static class Program
    {
        [DllImport("kernel32.dll")]
        static extern bool AttachConsole(int pid);

        [STAThread]
        static int Main(string[] args)
        {
            bool silent = false;
            string target = null, action = "install", logFile = null, shot = null, preselect = null, listRoot = null;
            for (int i = 0; i < args.Length; i++)
            {
                string a = args[i].ToLowerInvariant();
                string next = i + 1 < args.Length ? args[i + 1] : null;
                if (a == "--silent") silent = true;
                else if (a == "--target" && next != null) { target = next; i++; }
                else if (a == "--action" && next != null) { action = next.ToLowerInvariant(); i++; }
                else if (a == "--log" && next != null) { logFile = next; i++; }
                else if (a == "--shot" && next != null) { shot = next; i++; }
                else if (a == "--preselect" && next != null) { preselect = next; i++; }
                else if (a == "--list" && next != null) { listRoot = next; silent = true; action = "list"; i++; }
                else if (a == "--version") { silent = true; action = "version"; }
            }
            if (silent) return RunSilent(action, target, listRoot, logFile);

            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            MainForm form = new MainForm(preselect);
            if (shot != null) { form.SaveScreenshot(shot); return 0; }
            Application.Run(form);
            return 0;
        }

        // The command-line mode: used by the test, and by anyone who wants no window.
        //   AdaptiveUI-Setup.exe --silent --target "<...>\_classic_beta_" [--action install|uninstall|restore|verify]
        //   Exit codes: 0 ok, 1 failed, 2 needs administrator, 3 bad arguments.
        static int RunSilent(string action, string target, string listRoot, string logFile)
        {
            AttachConsole(-1);
            Action<string> log = delegate (string s)
            {
                try { Console.WriteLine(s); } catch (Exception) { }
                if (logFile != null) { try { File.AppendAllText(logFile, s + Environment.NewLine); } catch (Exception) { } }
            };
            try
            {
                if (action == "version") { log(Payload.Version()); return 0; }
                if (action == "list")
                {
                    foreach (Flavour f in Setup.FindFlavours(listRoot)) log(f.Path);
                    return 0;
                }
                if (string.IsNullOrEmpty(target)) { log("--target <flavour folder> is required with --silent"); return 3; }
                if (!Directory.Exists(target)) { log("target does not exist: " + target); return 1; }
                if (action == "verify")
                {
                    List<string> bad = Setup.Verify(Setup.Dest(target));
                    foreach (string b in bad) log(b);
                    log(bad.Count == 0 ? "OK " + Setup.InstalledVersion(target) : "FAILED");
                    return bad.Count == 0 ? 0 : 1;
                }
                if (action != "install" && action != "uninstall" && action != "restore") { log("unknown action: " + action); return 3; }
                if (!Setup.CanWrite(target)) { log("no write access to " + Setup.AddOns(target) + " (run as administrator)"); return 2; }
                if (action == "install")
                {
                    Setup.Install(target, log);
                    log("Installed " + Payload.Version() + " to " + Setup.Dest(target));
                }
                else if (action == "restore") Setup.Restore(target, log);
                else Setup.Uninstall(target, log);
                return 0;
            }
            catch (UnauthorizedAccessException) { log("access denied (run as administrator)"); return 2; }
            catch (Exception e) { log("error: " + e.Message); return 1; }
        }
    }

    class MainForm : Form
    {
        static readonly Color Obsidian = Color.FromArgb(14, 15, 19);
        static readonly Color Slate = Color.FromArgb(25, 26, 32);
        static readonly Color Parchment = Color.FromArgb(232, 222, 196);
        static readonly Color Muted = Color.FromArgb(150, 142, 124);
        static readonly Color Brass = Color.FromArgb(196, 160, 92);

        readonly PrivateFontCollection fonts = new PrivateFontCollection();
        FontFamily family;
        ComboBox combo;
        Label state, admin;
        TextBox output;
        Button install, restore, uninstall, browse, elevate, close;
        readonly List<Flavour> items = new List<Flavour>();
        GCHandle fontHandle;

        public MainForm(string preselect)
        {
            Text = "AdaptiveUI Setup";
            ClientSize = new Size(620, 470);
            FormBorderStyle = FormBorderStyle.FixedSingle;
            MaximizeBox = false;
            StartPosition = FormStartPosition.CenterScreen;
            BackColor = Obsidian;
            ForeColor = Parchment;
            LoadAssets();
            Build();
            foreach (Flavour f in Setup.FindAllFlavours()) AddFlavour(f);
            if (preselect != null) foreach (Flavour f in Setup.FromPickedFolder(preselect)) AddFlavour(f);
            if (combo.Items.Count > 0)
            {
                int pick = 0;
                if (preselect != null)
                    for (int i = 0; i < items.Count; i++)
                        if (string.Equals(items[i].Path, preselect.TrimEnd('\\', '/'), StringComparison.OrdinalIgnoreCase)) pick = i;
                combo.SelectedIndex = pick;
            }
            else
            {
                Say("Could not find World of Warcraft. Use Browse to pick the game folder (the one that contains _classic_beta_).");
                Refresh_();
            }
        }

        Font F(float size, FontStyle style)
        {
            if (family != null) { try { return new Font(family, size, FontStyle.Regular, GraphicsUnit.Point); } catch (Exception) { } }
            return new Font("Segoe UI", size, style, GraphicsUnit.Point);
        }

        void LoadAssets()
        {
            try
            {
                byte[] ttf = Payload.Bytes("font.ttf");
                fontHandle = GCHandle.Alloc(ttf, GCHandleType.Pinned);
                fonts.AddMemoryFont(fontHandle.AddrOfPinnedObject(), ttf.Length);
                if (fonts.Families.Length > 0) family = fonts.Families[0];
            }
            catch (Exception) { family = null; }
            try { Icon = new Icon(new MemoryStream(Payload.Bytes("app.ico"))); } catch (Exception) { }
        }

        Button Btn(string text, int x, int y, int w, bool primary)
        {
            Button b = new Button();
            b.Text = text;
            b.SetBounds(x, y, w, 34);
            b.FlatStyle = FlatStyle.Flat;
            b.FlatAppearance.BorderColor = primary ? Brass : Muted;
            b.FlatAppearance.BorderSize = 1;
            b.BackColor = primary ? Brass : Slate;
            b.ForeColor = primary ? Obsidian : Parchment;
            b.Font = F(11f, FontStyle.Bold);
            b.UseVisualStyleBackColor = false;
            b.Cursor = Cursors.Hand;
            Controls.Add(b);
            return b;
        }

        Label Lbl(string text, int x, int y, int w, int h, float size, Color colour)
        {
            Label l = new Label();
            l.Text = text;
            l.SetBounds(x, y, w, h);
            l.ForeColor = colour;
            l.BackColor = Color.Transparent;
            l.Font = F(size, FontStyle.Regular);
            Controls.Add(l);
            return l;
        }

        void Build()
        {
            // header
            Panel head = new Panel();
            head.SetBounds(0, 0, 620, 104);
            head.BackColor = Slate;
            Controls.Add(head);
            try
            {
                PictureBox crest = new PictureBox();
                crest.SetBounds(22, 12, 80, 80);
                crest.SizeMode = PictureBoxSizeMode.Zoom;
                crest.Image = Image.FromStream(new MemoryStream(Payload.Bytes("crest.png")));
                head.Controls.Add(crest);
            }
            catch (Exception) { }
            Label title = new Label();
            title.Text = "AdaptiveUI";
            title.SetBounds(120, 12, 460, 46);
            title.Font = F(28f, FontStyle.Bold);
            title.ForeColor = Parchment;
            head.Controls.Add(title);
            Label tag = new Label();
            tag.Text = "A WoW dad's answer to off-night couch gaming";
            tag.SetBounds(122, 58, 470, 24);
            tag.Font = F(12f, FontStyle.Regular);
            tag.ForeColor = Brass;
            head.Controls.Add(tag);
            Label ver = new Label();
            ver.Text = "Setup for " + Payload.Version() + "   -   by Wahf";
            ver.SetBounds(122, 80, 470, 20);
            ver.Font = F(9.5f, FontStyle.Regular);
            ver.ForeColor = Muted;
            head.Controls.Add(ver);

            Lbl("Game folder", 24, 120, 300, 22, 11f, Parchment);
            combo = new ComboBox();
            combo.SetBounds(24, 145, 462, 28);
            combo.DropDownStyle = ComboBoxStyle.DropDownList;
            combo.FlatStyle = FlatStyle.Flat;
            combo.BackColor = Slate;
            combo.ForeColor = Parchment;
            combo.Font = F(10f, FontStyle.Regular);
            combo.SelectedIndexChanged += delegate { Refresh_(); };
            Controls.Add(combo);
            browse = Btn("Browse...", 496, 142, 100, false);
            browse.Click += OnBrowse;

            state = Lbl("", 24, 180, 572, 44, 10f, Muted);
            admin = Lbl("This folder needs administrator rights to change. Restart the installer as administrator to continue.", 24, 228, 572, 40, 10f, Brass);
            admin.Visible = false;
            elevate = Btn("Restart as administrator", 24, 252, 230, true);
            elevate.Visible = false;
            elevate.Click += OnElevate;

            install = Btn("Install", 24, 292, 140, true);
            restore = Btn("Restore backup", 174, 292, 150, false);
            uninstall = Btn("Uninstall", 334, 292, 120, false);
            close = Btn("Close", 496, 292, 100, false);
            install.Click += delegate { Run("install"); };
            restore.Click += delegate { Run("restore"); };
            uninstall.Click += delegate { Run("uninstall"); };
            close.Click += delegate { Close(); };

            output = new TextBox();
            output.SetBounds(24, 340, 572, 84);
            output.Multiline = true;
            output.ReadOnly = true;
            output.BorderStyle = BorderStyle.FixedSingle;
            output.BackColor = Slate;
            output.ForeColor = Parchment;
            output.Font = F(10f, FontStyle.Regular);
            output.ScrollBars = ScrollBars.Vertical;
            Controls.Add(output);
            Say("Ready. Nothing is changed until you press a button.");

            Lbl("Free to use. (c) 2026 Studiobard LLC. All rights reserved. This installer is unsigned and works offline. It only copies files.", 24, 436, 572, 22, 8.5f, Muted);
        }

        void AddFlavour(Flavour f)
        {
            foreach (Flavour e in items) if (string.Equals(e.Path, f.Path, StringComparison.OrdinalIgnoreCase)) return;
            items.Add(f);
            combo.Items.Add(f);
        }

        Flavour Current() { return combo.SelectedItem as Flavour; }

        void Say(string text) { output.Text = text; }
        void Append(string text) { output.AppendText((output.TextLength > 0 ? "\r\n" : "") + text); }

        void Refresh_()
        {
            Flavour f = Current();
            bool have = f != null;
            bool writable = have && Setup.CanWrite(f.Path);
            string v = have ? Setup.InstalledVersion(f.Path) : null;
            int backups = have ? Setup.Backups(f.Path).Count : 0;
            state.Text = !have ? "No game folder selected."
                : f.Path + "\r\n" + (v == null ? "AdaptiveUI is not installed here." : "Installed here: " + v + ".")
                  + (backups > 0 ? "   " + backups + " backup" + (backups == 1 ? "" : "s") + " on disk." : "");
            admin.Visible = have && !writable;
            elevate.Visible = have && !writable;
            install.Enabled = have && writable;
            install.Text = v == null ? "Install" : "Update";
            restore.Enabled = have && writable && backups > 0;
            uninstall.Enabled = have && writable && v != null;
            foreach (Button b in new Button[] { install, restore, uninstall })
            {
                b.ForeColor = b.Enabled ? (b == install ? Obsidian : Parchment) : Muted;
                b.BackColor = b.Enabled ? (b == install ? Brass : Slate) : Slate;
            }
        }

        void OnBrowse(object sender, EventArgs e)
        {
            using (FolderBrowserDialog d = new FolderBrowserDialog())
            {
                d.Description = "Pick your World of Warcraft folder (the one that contains _classic_beta_), or the _classic_beta_ folder itself.";
                d.ShowNewFolderButton = false;
                if (d.ShowDialog(this) != DialogResult.OK) return;
                List<Flavour> found = Setup.FromPickedFolder(d.SelectedPath);
                if (found.Count == 0)
                {
                    Say("That folder has no _classic_beta_ (or other classic) folder inside it. Pick the folder that contains it.");
                    return;
                }
                foreach (Flavour f in found) AddFlavour(f);
                for (int i = 0; i < items.Count; i++)
                    if (string.Equals(items[i].Path, found[0].Path, StringComparison.OrdinalIgnoreCase)) combo.SelectedIndex = i;
            }
        }

        void OnElevate(object sender, EventArgs e)
        {
            Flavour f = Current();
            try
            {
                ProcessStartInfo psi = new ProcessStartInfo(Application.ExecutablePath);
                psi.UseShellExecute = true;
                psi.Verb = "runas"; // the normal Windows UAC prompt; asked for only because this folder needs it
                if (f != null) psi.Arguments = "--preselect \"" + f.Path + "\"";
                Process.Start(psi);
                Close();
            }
            catch (Win32Exception) { Say("The administrator prompt was cancelled. Nothing was changed."); }
        }

        void Run(string what)
        {
            Flavour f = Current();
            if (f == null) return;
            Cursor = Cursors.WaitCursor;
            Say("");
            Action<string> log = delegate (string s) { Append(s); Application.DoEvents(); };
            try
            {
                if (what == "install")
                {
                    Setup.Install(f.Path, log);
                    Append("");
                    Append("Installed " + Payload.Version() + " to " + Setup.Dest(f.Path) + ".");
                    Append("In game: /reload or log in, then /aui");
                }
                else if (what == "restore")
                {
                    if (MessageBox.Show(this, "Swap the newest backup in? The copy that is live now is kept as a backup too.",
                        "Restore backup", MessageBoxButtons.OKCancel, MessageBoxIcon.Question) != DialogResult.OK) { Say("Cancelled."); return; }
                    Setup.Restore(f.Path, log);
                    Append("Done. In game: /reload or log in.");
                }
                else
                {
                    if (MessageBox.Show(this, "Remove AdaptiveUI from this game folder? Your settings and backups are kept.",
                        "Uninstall", MessageBoxButtons.OKCancel, MessageBoxIcon.Question) != DialogResult.OK) { Say("Cancelled."); return; }
                    Setup.Uninstall(f.Path, log);
                }
            }
            catch (UnauthorizedAccessException) { Append("Windows refused access. Use Restart as administrator."); }
            catch (Exception ex) { Append("Problem: " + ex.Message); }
            finally { Cursor = Cursors.Default; Refresh_(); }
        }

        // Developer aid: render the window to a PNG without user input (used to check the look).
        public void SaveScreenshot(string path)
        {
            Show();
            Application.DoEvents();
            using (Bitmap bmp = new Bitmap(Width, Height))
            {
                DrawToBitmap(bmp, new Rectangle(0, 0, bmp.Width, bmp.Height));
                bmp.Save(path, System.Drawing.Imaging.ImageFormat.Png);
            }
            Close();
        }
    }
}
