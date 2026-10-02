# Installing AdaptiveUI

AdaptiveUI is for the WoW Classic "Forever" client (interface 16001). It will not do anything useful on Retail.
Your settings live in the game's `WTF` folder and are never touched by installing, updating or uninstalling.

## Where the game's folders are

Windows, typically: `C:\Program Files (x86)\World of Warcraft\`

Inside it, each version of the game has its own folder. The one for the Forever beta is **`_classic_beta_`**. You may also
see `_classic_era_`, `_classic_`, `_retail_` and others. Addons go in the flavour you actually play:

```
World of Warcraft\_classic_beta_\Interface\AddOns\AdaptiveUI\AdaptiveUI.toc
```

If you have no `Interface\AddOns` folder yet, create it. Check the folder name for your client: if Blizzard renames
the Forever folder when it leaves beta (for example to `_classic_`), use that flavour's folder instead. The installer
lists what it finds.

## Option 1: the installer (Windows)

1. Download `AdaptiveUI-Setup.exe` from the [releases page](https://github.com/wahfcore/AdaptiveUI/releases). Optional but recommended: check it
   (see "Verify the download" below).
2. Run it. **Windows will probably say "Windows protected your PC"** (SmartScreen). That is because the file is not
   code-signed yet and few people have run it. Choose **More info**, then **Run anyway**.
3. The installer looks for the game (registry entries the game itself leaves, and the usual folders) and lists the
   Classic flavours it finds, Forever beta first. If it finds nothing, or you keep the game somewhere unusual, press
   **Browse** and pick the `World of Warcraft` folder.
4. Press **Install** (or **Update** if it is already there). It:
   - unpacks the addon next to its destination and checks every file against a SHA-256 list,
   - moves any existing `AdaptiveUI` folder aside as `AdaptiveUI.backup-<date>-<time>`,
   - puts the new one in place and checks again. If any check fails, it puts your old copy back.
5. It ends with: *Installed vX to `<path>`. In game: /reload or log in, then /aui*.

Other buttons: **Restore backup** swaps the newest backup in (and keeps the copy that was live as another backup, so
nothing is lost); **Uninstall** removes the addon folder and leaves your settings and backups alone.

**If the game is under `Program Files`:** Windows may not let a normal program write there. The installer checks first,
and if it cannot write it shows **Restart as administrator** (the normal Windows prompt) instead of failing halfway. It
never asks for administrator rights unless it needs them. Installing the game outside `Program Files` avoids all this.

### What the installer does not do
It uses no network, writes nothing to the registry (it only reads it, to find the game), installs no services or
scheduled tasks, and runs no scripts. The addon files are inside the exe; it copies them into your AddOns folder. That
is all. I wrote it to be boring on purpose. The source is in `tools/installer/` in the repository, and I build it with
the C# compiler that ships with Windows.

### Verify the download
The release page lists a SHA-256 for `AdaptiveUI-Setup.exe` and for the zip (also in `SHA256SUMS.txt`). In PowerShell:

```
Get-FileHash .\AdaptiveUI-Setup.exe -Algorithm SHA256
```

or in Command Prompt: `certutil -hashfile AdaptiveUI-Setup.exe SHA256`. If the value does not match the one on the
release page, do not run it, and tell me.

### About the SmartScreen warning
The exe is **unsigned**. I haven't bought a code-signing certificate yet, and Windows also wants reputation built up
over many downloads, so for now the warning will show once. It is not a virus warning; it is "we don't recognise this yet". If you
would rather not click through it, use the zip (option 2) or CurseForge/Wago (option 3): neither triggers a warning.

## Option 2: manual zip (Windows and macOS)

1. Download `AdaptiveUI-<version>.zip` from the release page.
2. Unzip it. It contains one folder, `AdaptiveUI`.
3. Copy that folder into `World of Warcraft\_classic_beta_\Interface\AddOns\`, so that
   `...\AddOns\AdaptiveUI\AdaptiveUI.toc` exists (not `...\AddOns\AdaptiveUI\AdaptiveUI\AdaptiveUI.toc`; the doubled
   folder is the most common mistake).
4. Updating: close the game, move the old `AdaptiveUI` folder somewhere outside `AddOns` (that is your backup), and copy
   the new one in.

### macOS
The steps are the same; the folder is usually `/Applications/World of Warcraft/_classic_beta_/Interface/AddOns/`
(Finder: Go, Go to Folder, paste it). If macOS won't let you write there, drag the folder in with the usual admin
prompt. The installer is Windows only. I have not been able to test on a Mac yet: if the path is different for you,
please tell me.

## Option 3: CurseForge / Wago
Once AdaptiveUI is listed there (see the release page for the links), install it from the CurseForge app or the Wago
app like any other addon. It updates itself, and there is no warning to click through.

## Check that it loaded

1. Log in. You should see a chat line from AdaptiveUI, and on a first run the **welcome** window.
2. Type **`/aui`**. The settings window opens.
3. Type **`/aui build`**. It prints your client build and one of *audited*, *provisional* or *refused*. "Audited" and
   "provisional" both run in full. If it says refused, it loaded but is not touching Blizzard's UI on purpose: send me
   the line.
4. Character select, AddOns button: AdaptiveUI should be in the list and ticked. If it says "Out of date", tick
   "Load out of date AddOns" (I target the current Forever interface number, so this should not be needed).
5. Nothing? See Troubleshooting.

## Update, uninstall and roll back

- **Update:** run the new installer (or copy the new folder over). Your settings stay.
- **Roll back:** the installer's **Restore backup** button, or by hand: close the game, delete
  `AddOns\AdaptiveUI`, rename `AddOns\AdaptiveUI.backup-<date>-<time>` to `AdaptiveUI`, log in.
- **Uninstall:** the installer's **Uninstall** button, or delete `Interface\AddOns\AdaptiveUI`. To remove the settings
  too, delete `AdaptiveUI.lua` from `WTF\Account\<ACCOUNT>\SavedVariables\` and from each
  character's `SavedVariables` folder, with the game closed.
- The `AdaptiveUI.backup-*` folders can be deleted whenever you like; the game ignores them.

## Troubleshooting

- **"AdaptiveUI" isn't in the addon list.** Almost always the doubled folder (see option 2 step 3) or the wrong flavour
  folder (`_retail_` or `_classic_era_` instead of `_classic_beta_`).
- **The installer says it can't find the game.** Press Browse and choose the folder that contains `_classic_beta_`.
- **Windows says the file is blocked / Defender scans it for a long time.** The exe is 4 MB and contains the whole addon;
  a first scan can take a moment. If Defender quarantines it, that is a false positive on an unsigned program: use the
  zip and let me know.
- **Everything is there but nothing looks different.** `/aui build` tells you whether the addon has stood down on your
  game build. `/aui quarantine clear`, then `/reload`, tries again.
- **Settings didn't save.** Reload or log out properly once; the game writes them to disk then. `/aui status` shows
  what happened on the last logins.
