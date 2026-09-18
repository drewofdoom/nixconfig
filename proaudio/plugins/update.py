#!/usr/bin/env python3
"""Update proaudio/plugins/<name>.nix to the latest GitHub release.

Handles both shapes used in this dir:
  - single `src = fetchzip {...}` (ZL-style)
  - `srcs = [ (fetchzip {...}) ... ]` (brummer-style, one asset per format)

Usage:
  proaudio/plugins/update.py <plugin-file>...   # e.g. proaudio/plugins/update.py proaudio/plugins/brummer-loopino.nix

  proaudio/plugins/update.py --all               # all tracked plugin files

For each file: reads `version`, asks GitHub for the latest release tag
(stable only; a leading `v` is stripped), and if newer, rewrites the
version + every release URL and refetches every hash with
`nix-prefetch-url --unpack` (byte-identical semantics to fetchzip).
"""
import json
import re
import subprocess
import sys
import urllib.request
from pathlib import Path

DIR = Path(__file__).resolve().parent


def github_latest(owner, repo, tag_prefix=None):
    if tag_prefix is None:
        url = f"https://api.github.com/repos/{owner}/{repo}/releases/latest"
        req = urllib.request.Request(url, headers={"Accept": "application/vnd.github+json"})
        with urllib.request.urlopen(req, timeout=30) as r:
            data = json.load(r)
        return data["tag_name"].lstrip("v")
    # Monorepo (e.g. dusk-audio-plugins): /latest is repo-wide, so scan
    # releases for the newest stable tag starting with `<prefix>-v`.
    url = f"https://api.github.com/repos/{owner}/{repo}/releases?per_page=100"
    req = urllib.request.Request(url, headers={"Accept": "application/vnd.github+json"})
    with urllib.request.urlopen(req, timeout=30) as r:
        releases = json.load(r)
    best = None
    for rel in releases:
        tag = rel.get("tag_name", "")
        if rel.get("draft") or rel.get("prerelease"):
            continue
        if not tag.startswith(tag_prefix + "-v"):
            continue
        published = rel.get("published_at", "")
        if best is None or published > best[0]:
            best = (published, tag)
    if best is None:
        raise RuntimeError(f"no stable {tag_prefix}-v* release found")
    return best[1][len(tag_prefix) + 2:]


def prefetch(url):
    base32 = subprocess.run(
        ["nix-prefetch-url", "--unpack", url],
        capture_output=True, text=True, check=True,
    ).stdout.strip().split()[-1]
    sri = subprocess.run(
        ["nix", "hash", "convert", "--hash-algo", "sha256", "--to", "sri", base32],
        capture_output=True, text=True, check=True,
    ).stdout.strip()
    return sri


def update_file(path):
    text = path.read_text()
    m = re.search(r'^\s*version = "([^"]+)";', text, re.M)
    if not m:
        print(f"{path.name}: no version found, skipping")
        return False
    old_version = m.group(1)

    urls = re.findall(r'url = "(https://github\.com/([^"/]+)/([^"/]+)/[^"]+)"', text)
    if not urls:
        print(f"{path.name}: no github URLs found, skipping")
        return False
    owner, repo = urls[0][1], urls[0][2]

    # Optional directive, e.g. `# update-tag-prefix: multi-comp` for monorepos
    # whose tags are `<prefix>-v<version>`.
    pm = re.search(r"^#\s*update-tag-prefix:\s*(\S+)", text, re.M)
    tag_prefix = pm.group(1) if pm else None

    try:
        new_version = github_latest(owner, repo, tag_prefix)
    except Exception as e:  # noqa: BLE001 - report and move on
        print(f"{path.name}: could not query {owner}/{repo}: {e}")
        return False
    if new_version == old_version:
        print(f"{path.name}: already at {old_version}")
        return False

    print(f"{path.name}: {old_version} -> {new_version}")
    # version line. URLs stay untouched: they are ${finalAttrs.version}
    # templates that track the version automatically (including unversioned
    # asset filenames like SUBSTANCE-Linux-x86_64.tar.gz).
    text = re.sub(r'^(\s*version = ")' + re.escape(old_version) + r'(";)',
                  rf"\g<1>{new_version}\g<2>", text, flags=re.M)

    # refetch every hash, pairing fetchzip blocks in file order.
    # Block closers differ by shape: `(fetchzip {...})` (multi-src srcs list)
    # vs `fetchzip {...};` (single src). A version change always refetches
    # everything -- content drift can't be read off templated URLs.
    blocks = re.findall(r"fetchzip \{(.*?)\}\s*[);]", text, re.S)
    urls = re.findall(r'url = "(https://[^"]+)"', text)
    if len(blocks) != len(urls):
        print(f"{path.name}: block/url mismatch, skipping")
        return False
    for block, url in zip(blocks, urls):
        download_url = url.replace("${finalAttrs.version}", new_version)
        try:
            sri = prefetch(download_url)
        except Exception as e:  # noqa: BLE001 - leave file untouched
            print(f"  prefetch failed for {download_url}: {e}")
            return False
        new_block, n = re.subn(r'hash = "[^"]*";', f'hash = "{sri}";', block, count=1)
        if n != 1:
            print(f"{path.name}: hash not found in block for {url}, skipping")
            return False
        text = text.replace(block, new_block, 1)
        print(f"  {download_url.split('/')[-1]}: {sri[:24]}...")

    path.write_text(text)
    return True


def main(argv):
    if argv == ["--all"]:
        files = sorted(DIR.glob("*.nix"))
        files = [f for f in files if f.name != "default.nix"]
    else:
        files = [Path(a) if Path(a).is_absolute() else Path.cwd() / a for a in argv]
    if not files:
        sys.exit("usage: update.py [--all | <plugin-file>...]")
    changed = False
    for f in files:
        changed |= update_file(f)
    sys.exit(0)


if __name__ == "__main__":
    main(sys.argv[1:])
