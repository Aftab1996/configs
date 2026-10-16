#!/usr/bin/env bash
set -uo pipefail

LOG="/tmp/ocr-hypr.log"
echo "---- OCR RUN: $(date '+%F %T %Z') ----" >> "$LOG"

TMPDIR=$(mktemp -d) || { echo "mktemp failed" | tee -a "$LOG"; exit 1; }
echo "tmpdir: $TMPDIR" >> "$LOG"

# Try to take screenshot (region mode). Adjust -m and args if you use a different hyprshot usage.
echo "Running hyprshot..." >> "$LOG"
if ! hyprshot -m region -o "$TMPDIR" 2>>"$LOG"; then
    echo "hyprshot command returned non-zero. Checking for files anyway..." | tee -a "$LOG"
fi

# Wait for a PNG to appear (up to 3s, checking every 0.2s)
IMG=""
for i in {1..15}; do
    IMG=$(find "$TMPDIR" -maxdepth 1 -type f -iname '*.png' -print -quit || true)
    if [[ -n "$IMG" ]]; then break; fi
    sleep 0.2
done

if [[ -z "$IMG" ]]; then
    echo "NO PNG FOUND in $TMPDIR" | tee -a "$LOG"
    echo "ls -la $TMPDIR:" >> "$LOG"
    ls -la "$TMPDIR" >> "$LOG" 2>&1
    notify-send "OCR Error" "Screenshot failed: no image found."
    rm -rf "$TMPDIR"
    exit 1
fi

echo "Found image: $IMG" >> "$LOG"
echo "Image details:" >> "$LOG"
file "$IMG" >> "$LOG" 2>&1
identify "$IMG" >> "$LOG" 2>&1 || true  # identify may not be installed, ignore if missing

# Run tesseract
echo "Running tesseract..." >> "$LOG"
TEXTOUT=$(mktemp)
/usr/bin/time -f "tesseract_time:%e" -o "$LOG" -a tesseract "$IMG" "$TEXTOUT" 2>>"$LOG" || true
# Some tesseract installations write to stdout; attempt both.
if command -v tesseract >/dev/null 2>&1; then
    # preferred: stdout
    TEXT=$(tesseract "$IMG" stdout 2>>"$LOG" || true)
else
    TEXT=$(cat "${TEXTOUT}.txt" 2>/dev/null || true)
fi

if [[ -z "${TEXT//[$'\t\r\n ']}" ]]; then
    echo "Tesseract produced no text." | tee -a "$LOG"
    echo "tesseract exit/log:" >> "$LOG"
    tail -n 80 "$LOG" >> "$LOG" 2>&1
    notify-send "OCR Error" "No text detected by tesseract."
    rm -rf "$TMPDIR"
    exit 1
fi

echo "OCR text length: ${#TEXT}" >> "$LOG"

# Copy to clipboard (wl-copy preferred, fallback to xclip)
if command -v wl-copy >/dev/null 2>&1; then
    printf "%s" "$TEXT" | wl-copy
    CLIP_OK=$?
elif command -v xclip >/dev/null 2>&1; then
    printf "%s" "$TEXT" | xclip -selection clipboard
    CLIP_OK=$?
else
    CLIP_OK=1
fi

if [[ $CLIP_OK -eq 0 ]]; then
    notify-send "OCR Success" "Text copied to clipboard."
else
    # fallback: write to /tmp/ocr-result.txt
    echo "$TEXT" > /tmp/ocr-result.txt
    notify-send "OCR Success" "Text saved to /tmp/ocr-result.txt (clipboard unavailable)."
    echo "Saved result at /tmp/ocr-result.txt" >> "$LOG"
fi

# Save text to log
echo "---- OCR TEXT START ----" >> "$LOG"
echo "$TEXT" >> "$LOG"
echo "---- OCR TEXT END ----" >> "$LOG"

# cleanup
rm -rf "$TMPDIR"
echo "Done. Log: $LOG" >> "$LOG"
exit 0

