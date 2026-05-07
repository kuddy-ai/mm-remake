#!/bin/bash
# Project path sanity checker
# Run from project root

set -e

PASS=0
FAIL=0

echo "=== Project Path Check ==="
echo ""

# Helper function
check_path() {
    local desc="$1"
    local path="$2"
    local expected="$3"  # "exist" or "not_exist"

    if [ "$expected" = "not_exist" ]; then
        if [ -e "$path" ]; then
            echo "[FAIL] $desc: $path exists (should not)"
            FAIL=$((FAIL + 1))
        else
            echo "[PASS] $desc: $path not found"
            PASS=$((PASS + 1))
        fi
    else
        if [ -e "$path" ]; then
            echo "[PASS] $desc: $path exists"
            PASS=$((PASS + 1))
        else
            echo "[FAIL] $desc: $path missing"
            FAIL=$((FAIL + 1))
        fi
    fi
}

# 1. Check deprecated paths should NOT exist
check_path "Old assets/sounds directory" "assets/sounds" "not_exist"
check_path "Old docs/ui_style_guide.md" "docs/ui_style_guide.md" "not_exist"
check_path "Old wasteland_hunter_curated_pixel_designs directory" "wasteland_hunter_curated_pixel_designs" "not_exist"
check_path "Old kadokura_opening.mp3 anywhere" "" "not_exist"  # Special check below

# 2. Check kadokura_opening.mp3
if find . -name "kadokura_opening.mp3" -type f 2>/dev/null | grep -q .; then
    echo "[FAIL] kadokura_opening.mp3 found (should not exist)"
    FAIL=$((FAIL + 1))
else
    echo "[PASS] kadokura_opening.mp3 not found"
    PASS=$((PASS + 1))
fi

# 3. Check docs/concept-art has no .png files
png_count=$(find docs/concept-art -name "*.png" -type f 2>/dev/null | wc -l)
if [ "$png_count" -gt 0 ]; then
    echo "[FAIL] docs/concept-art contains $png_count .png files (should be .webp)"
    find docs/concept-art -name "*.png" -type f
    FAIL=$((FAIL + 1))
else
    echo "[PASS] docs/concept-art has no .png files"
    PASS=$((PASS + 1))
fi

# 4. Check external-assets should only have README.md in git
# (This checks if there are files that should be in .gitignore)
external_files=$(git ls-files external-assets/ 2>/dev/null | grep -v "README.md" | wc -l)
if [ "$external_files" -gt 0 ]; then
    echo "[FAIL] external-assets has $external_files tracked files (should only be README.md)"
    git ls-files external-assets/ | grep -v "README.md"
    FAIL=$((FAIL + 1))
else
    echo "[PASS] external-assets only has README.md tracked"
    PASS=$((PASS + 1))
fi

# 5. Check required paths should exist
check_path "Main scene file" "scenes/main.tscn" "exist"
check_path "Opening BGM file" "assets/audio/bgm/001_opening_theme.ogg" "exist"
check_path "UI style guide document" "docs/ui-design/ui-style-guide.md" "exist"

# 6. Check MUSIC_OPENING constant points to correct path
if grep -q "MUSIC_OPENING.*001_opening_theme.ogg" game/demo_main.gd 2>/dev/null; then
    echo "[PASS] MUSIC_OPENING points to 001_opening_theme.ogg"
    PASS=$((PASS + 1))
else
    echo "[FAIL] MUSIC_OPENING not pointing to correct file"
    FAIL=$((FAIL + 1))
fi

# Summary
echo ""
echo "=== Summary ==="
echo "PASS: $PASS"
echo "FAIL: $FAIL"

if [ "$FAIL" -gt 0 ]; then
    echo ""
    echo "Result: FAILED - Please fix the issues above"
    exit 1
else
    echo ""
    echo "Result: PASSED - All checks OK"
    exit 0
fi