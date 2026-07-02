#!/usr/bin/env python3
"""Download all Stitch screens for Private Pensieve project."""
import json, subprocess, os, sys

API_KEY = os.environ.get("STITCH_API_KEY", "")
if not API_KEY:
    print("Error: Set STITCH_API_KEY environment variable")
    sys.exit(1)
PROJECT = "3840871406850157846"
BASE = f"https://stitch.googleapis.com/v1/projects/{PROJECT}/screens"
ROOT = "/Users/s.sainithinkrishna/Desktop/Projects/AI_Dairy/private-pensieve-codex-handoff/design"
IMG_DIR = f"{ROOT}/stitch_screens"
CODE_DIR = f"{ROOT}/stitch_code"

os.makedirs(IMG_DIR, exist_ok=True)
os.makedirs(CODE_DIR, exist_ok=True)

SCREENS = [
    ("03_talk_idle", "03a032d5b7894ae5be6fc73e669b46d1"),
    ("04_vault", "30f307d364c54f65b7f9392c3c176455"),
    ("05_onboarding_welcome", "e4372bae9ec14e779fe18853732ebee7"),
    ("06_recall_ask", "1b1b766231a246a5b7e74a1202b57db4"),
    ("07_privacy_settings", "3528b8be8cea4cf6b41255d756f391c3"),
    ("08_onboarding_privacy", "0c57934ad436417881cbafdaec3a3d17"),
    ("09_onboarding_security", "05cf4608951040eca50451b5d80e4c5a"),
    ("10_talk_listening", "a7b10b248ee040ae9f2d8ecf4286007e"),
    ("11_onboarding_ai_model", "5cb070843b0c4030aae9e8be5aac203d"),
    ("12_review_transcript", "1004396a48b94c34b371f694ff25797a"),
    ("13_memory_detail", "b9571f9229a649659058aa60ef098cdf"),
    ("14_recall_answer", "5c5d2f16883c43559da06f661502dd0c"),
    ("15_vault_empty", "1f37932d4ac14128a7e4464bb1fa57da"),
]

img_ok = 0
html_ok = 0

for i, (name, sid) in enumerate(SCREENS, 1):
    print(f"[{i}/13] {name}...", flush=True)
    
    # Use curl to fetch JSON (avoids Python SSL issues)
    tmp = f"/tmp/stitch_{name}.json"
    r = subprocess.run(
        ["curl", "-s", f"{BASE}/{sid}", "-H", f"X-Goog-Api-Key: {API_KEY}", "-o", tmp],
        capture_output=True, text=True
    )
    
    try:
        with open(tmp) as f:
            raw = f.read()
        data = json.loads(raw, strict=False)
    except Exception as e:
        print(f"  ✗ JSON parse error: {e}")
        continue
    
    title = data.get("title", "?")
    print(f"  → {title}")
    
    # Download image
    img_url = data.get("screenshot", {}).get("downloadUrl", "")
    if img_url:
        img_path = f"{IMG_DIR}/{name}.png"
        subprocess.run(["curl", "-sL", img_url, "-o", img_path])
        sz = os.path.getsize(img_path)
        if sz > 100:
            print(f"  ✓ Image: {name}.png ({sz:,} bytes)")
            img_ok += 1
        else:
            print(f"  ⚠ Image too small ({sz} bytes), may be error")
    
    # Download HTML
    html_url = data.get("htmlCode", {}).get("downloadUrl", "")
    if html_url:
        html_path = f"{CODE_DIR}/{name}.html"
        subprocess.run(["curl", "-sL", html_url, "-o", html_path])
        sz = os.path.getsize(html_path)
        if sz > 100:
            print(f"  ✓ HTML: {name}.html ({sz:,} bytes)")
            html_ok += 1
        else:
            print(f"  ⚠ HTML too small ({sz} bytes)")
    
    # Clean up
    os.remove(tmp)

print(f"\n{'='*40}")
print(f"✅ Downloaded: {img_ok} images, {html_ok} HTML files")
print(f"📁 Images: {IMG_DIR}/")
print(f"📁 Code: {CODE_DIR}/")
