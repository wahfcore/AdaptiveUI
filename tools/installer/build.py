"""Build AdaptiveUI-Setup.exe (and the manual-install zip) with the C# compiler that ships with Windows.

    python tools/installer/build.py              # -> dist/installer/AdaptiveUI-Setup.exe, AdaptiveUI-<ver>.zip, SHA256SUMS.txt
    python tools/installer/build.py --skip-exe   # only the zip and the hash list

No SDK, no NuGet, no network. Inputs: addon/AdaptiveUI (the payload), its crest art (window icon and header)
and the Barlow font (header type). The payload zip and a SHA-256 list of every file are embedded as
resources, so the installer can verify what it wrote. The zip is built with fixed timestamps, so the same
addon tree always gives the same zip.
"""
import hashlib
import io
import re
import subprocess
import sys
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent.parent
HERE = Path(__file__).resolve().parent
ADDON = ROOT / "addon" / "AdaptiveUI"
DIST = ROOT / "dist" / "installer"
OBJ = DIST / "obj"
CSC = Path(r"C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe")
ZIP_DATE = (2026, 9, 30, 0, 0, 0)
PARCHMENT = (232, 222, 196)
COMPANY = "Studiobard LLC"
PRODUCT = "AdaptiveUI"


def toc_version():
    text = (ADDON / "AdaptiveUI.toc").read_text(encoding="utf-8-sig")
    m = re.search(r"^##\s*Version:\s*(\S+)", text, re.M)
    if not m:
        sys.exit("no ## Version in the TOC")
    return m.group(1)


def numeric_version(v):
    nums = [int(x) for x in re.findall(r"\d+", v.split("-")[0])][:4]
    while len(nums) < 4:
        nums.append(0)
    return ".".join(str(n) for n in nums)


def payload_files():
    files = sorted(p for p in ADDON.rglob("*") if p.is_file())
    return [(p, p.relative_to(ADDON).as_posix()) for p in files]


def build_zip(files):
    buf = io.BytesIO()
    with zipfile.ZipFile(buf, "w", zipfile.ZIP_DEFLATED, compresslevel=9) as z:
        for path, rel in files:
            info = zipfile.ZipInfo("AdaptiveUI/" + rel, ZIP_DATE)
            info.compress_type = zipfile.ZIP_DEFLATED
            info.external_attr = 0o644 << 16
            z.writestr(info, path.read_bytes())
    return buf.getvalue()


def sha(data):
    return hashlib.sha256(data).hexdigest()


def crest_assets():
    """My crest (128 px white ink with alpha), tinted parchment: header PNG and multi-size icon."""
    from PIL import Image
    src = Image.open(ADDON / "Art" / "crest-art.tga").convert("RGBA")
    r, g, b, a = src.split()
    tint = Image.merge("RGBA", (Image.new("L", src.size, PARCHMENT[0]), Image.new("L", src.size, PARCHMENT[1]),
                                Image.new("L", src.size, PARCHMENT[2]), a))
    big = tint.resize((256, 256), Image.LANCZOS)
    # header PNG: on transparency, 160 px so it stays sharp at high DPI
    png = io.BytesIO()
    tint.resize((160, 160), Image.LANCZOS).save(png, "PNG")
    # the icon sits on an obsidian tile so it reads on a light taskbar
    tile = Image.new("RGBA", (256, 256), (14, 15, 19, 255))
    tile.alpha_composite(big.resize((224, 224), Image.LANCZOS), (16, 16))
    ico = io.BytesIO()
    tile.save(ico, "ICO", sizes=[(16, 16), (24, 24), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)])
    return png.getvalue(), ico.getvalue()


def assembly_info(version):
    num = numeric_version(version)
    return f'''using System.Reflection;
[assembly: AssemblyTitle("AdaptiveUI Setup")]
[assembly: AssemblyDescription("Installs the AdaptiveUI addon for World of Warcraft. Offline; copies files only.")]
[assembly: AssemblyCompany("{COMPANY}")]
[assembly: AssemblyProduct("{PRODUCT}")]
[assembly: AssemblyCopyright("Copyright (c) 2026 Studiobard LLC. All rights reserved.")]
[assembly: AssemblyVersion("{num}")]
[assembly: AssemblyFileVersion("{num}")]
[assembly: AssemblyInformationalVersion("{version}")]
'''


def main():
    skip_exe = "--skip-exe" in sys.argv
    version = toc_version()
    files = payload_files()
    zip_bytes = build_zip(files)
    DIST.mkdir(parents=True, exist_ok=True)
    OBJ.mkdir(parents=True, exist_ok=True)

    manifest = "".join(f"{sha(p.read_bytes())} *{rel}\n" for p, rel in files)
    zip_name = f"AdaptiveUI-{version}.zip"
    (DIST / zip_name).write_bytes(zip_bytes)
    (OBJ / "payload.zip").write_bytes(zip_bytes)
    (OBJ / "payload.sha256").write_text(manifest, encoding="utf-8", newline="\n")
    (OBJ / "version.txt").write_text("v" + version, encoding="utf-8")
    png, ico = crest_assets()
    (OBJ / "crest.png").write_bytes(png)
    (OBJ / "app.ico").write_bytes(ico)
    (OBJ / "font.ttf").write_bytes((ADDON / "Fonts" / "BarlowSemiCondensed-SemiBold.ttf").read_bytes())
    (OBJ / "AssemblyInfo.cs").write_text(assembly_info(version), encoding="utf-8")

    sums = [f"{sha(zip_bytes)} *{zip_name}"]
    if not skip_exe:
        if not CSC.exists():
            sys.exit(f"csc.exe not found at {CSC}")
        exe = DIST / "AdaptiveUI-Setup.exe"
        cmd = [str(CSC), "/nologo", "/target:winexe", "/optimize+", "/warnaserror+", f"/out:{exe}",
               f"/win32icon:{OBJ / 'app.ico'}", f"/win32manifest:{HERE / 'app.manifest'}",
               "/r:System.dll", "/r:System.Core.dll", "/r:System.Drawing.dll", "/r:System.Windows.Forms.dll",
               "/r:System.IO.Compression.dll",
               f"/resource:{OBJ / 'payload.zip'},payload.zip", f"/resource:{OBJ / 'payload.sha256'},payload.sha256",
               f"/resource:{OBJ / 'version.txt'},version.txt", f"/resource:{OBJ / 'crest.png'},crest.png",
               f"/resource:{OBJ / 'app.ico'},app.ico", f"/resource:{OBJ / 'font.ttf'},font.ttf",
               str(HERE / "Installer.cs"), str(OBJ / "AssemblyInfo.cs")]
        r = subprocess.run(cmd, capture_output=True, text=True)
        sys.stdout.write(r.stdout)
        sys.stderr.write(r.stderr)
        if r.returncode != 0:
            sys.exit("csc failed")
        sums.insert(0, f"{sha(exe.read_bytes())} *{exe.name}")
    (DIST / "SHA256SUMS.txt").write_text("\n".join(sums) + "\n", encoding="utf-8", newline="\n")
    print(f"AdaptiveUI v{version}: {len(files)} files, payload zip {len(zip_bytes) / 1e6:.1f} MB")
    for line in sums:
        print("  " + line)


if __name__ == "__main__":
    main()
