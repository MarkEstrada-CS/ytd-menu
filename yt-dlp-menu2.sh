#!/bin/bash
# yt-dlp Extended Menu (Linux Version with Version Check + Nightly Build Notice)

DOCS="$HOME/Documents"
VDIR="$DOCS/yt-dlp-video"
ADIR="$DOCS/yt-dlp-audio"

mkdir -p "$VDIR" "$ADIR"

# --- Check yt-dlp version ---
echo "Checking yt-dlp version..."
if ! command -v yt-dlp &>/dev/null; then
    echo "❌ yt-dlp is not installed."
    echo "Install nightly build with:"
    echo "   pipx install yt-dlp --pip-args=\"--pre\""
    exit 1
fi

YTDLP_VER=$(yt-dlp --version 2>/dev/null)
echo "yt-dlp version: $YTDLP_VER"

# If version looks like "2021.x" or "2022.x", warn
if [[ "$YTDLP_VER" =~ ^20(21|22|23)\. ]]; then
    echo "⚠️  Warning: You are running an old/stable build."
    echo "    This may break due to YouTube changes."
    echo "💡 Recommended: switch to Nightly build:"
    echo "    pipx uninstall yt-dlp"
    echo "    pipx install yt-dlp --pip-args=\"--pre\""
    echo
    read -n 1 -s -r -p "Press any key to continue anyway..."
fi

# --- Main Menu Loop ---
while true; do
    clear
    echo "======================================="
    echo "       YouTube Downloader Menu"
    echo "======================================="
    echo "[1] Video Download"
    echo "[2] Audio Download"
    echo "[0] Exit"
    echo "======================================="
    read -p "Choose an option: " choice

    case $choice in
        1) # VIDEO MENU
            while true; do
                clear
                echo "======================================="
                echo "           Video Formats"
                echo "======================================="
                echo "[1] Best Quality (max video+audio)"
                echo "[2] 1080p"
                echo "[3] 720p"
                echo "[4] 480p"
                echo "[5] 360p"
#                echo "[7] Other Format (manual entry)"
                echo "[0] Back"
                echo "======================================="
                read -p "Choose video quality: " vchoice

                case $vchoice in
                    1) VFORMAT="bv*+ba/b"; VSUFFIX="" ;;
                    2) VFORMAT="bv[height=1080]+ba/b[height=1080]"; VSUFFIX=".1080p" ;;
                    3) VFORMAT="bv[height=720]+ba/b[height=720]"; VSUFFIX=".720p" ;;
                    4) VFORMAT="bv[height=480]+ba/b[height=480]"; VSUFFIX=".480p" ;;
                    5) VFORMAT="bv[height=360]+ba/b[height=360]"; VSUFFIX=".360p" ;;
                    7) 
                        echo
                        echo "Supported video formats:"
                        echo "  mp4  - MPEG-4 (universal, recommended)"
                        echo "  mkv  - Matroska (flexible, subs/audio)"
                        echo "  webm - Open format (efficient)"
                        echo "  flv  - Flash Video (legacy)"
                        echo "  avi  - Audio Video Interleave (old)"
                        echo "  mov  - QuickTime Movie (Apple/pro editing)"
                        echo "  ogg  - Ogg Theora (rare)"
                        echo "  [0] Back"
                        read -p "Custom format: " VFORMAT
                        if [[ "$VFORMAT" == "0" ]]; then
                            continue  # go back to video menu
                        fi
                        VSUFFIX=".custom"
                        ;;
                    0) break ;;
                    *) continue ;;
                esac

                clear
                read -p "Enter YouTube URL: " URL
                echo "[1] Single Video"
                echo "[2] Entire Playlist"
                read -p "Choose: " plchoice
                [[ $plchoice == 1 ]] && PLMODE="--no-playlist" || PLMODE="--yes-playlist"

                clear
                yt-dlp $PLMODE -f "$VFORMAT" --restrict-filenames -o "$VDIR/%(title)s$VSUFFIX.%(ext)s" "$URL"
                if [[ $? -ne 0 ]]; then
                    echo "❌ Error: Download failed. Check URL/format/network."
                    echo
                    echo "💡 If yt-dlp fails repeatedly, consider switching to the Nightly build:"
                    echo "   pipx uninstall yt-dlp"
                    echo "   pipx install yt-dlp --pip-args=\"--pre\""
                    read -n 1 -s -r -p "Press any key to continue..."
                    continue
                fi

                echo "✅ Video(s) saved to: $VDIR"
                read -n 1 -s -r -p "Press any key to continue..."
            done
            ;;
        2) # AUDIO MENU
            while true; do
                clear
                echo "======================================="
                echo "           Audio Formats"
                echo "======================================="
                echo "[1] MP3"
                echo "[2] M4A"
                echo "[3] OGG (Vorbis)"
                echo "[4] Opus"
                echo "[5] FLAC"
                echo "[6] Other Format (manual entry)"
                echo "[0] Back"
                echo "======================================="
                read -p "Choose audio format: " achoice

                case $achoice in
                    1) AFORMAT="mp3"; ASUFFIX=".mp3" ;;
                    2) AFORMAT="m4a"; ASUFFIX=".m4a" ;;
                    3) AFORMAT="vorbis"; ASUFFIX=".ogg" ;;
                    4) AFORMAT="opus"; ASUFFIX=".opus" ;;
                    5) AFORMAT="flac"; ASUFFIX=".flac" ;;
                    6)
                        echo "Supported audio formats:"
                        echo "  best   - keep original audio (no re-encode)"
                        echo "  aac    - Advanced Audio Coding (lossy)"
                        echo "  alac   - Apple Lossless (lossless)"
                        echo "  flac   - Free Lossless Audio Codec"
                        echo "  m4a    - MPEG-4 Audio container"
                        echo "  mp3    - MPEG Audio Layer III"
                        echo "  opus   - Opus codec (modern, efficient)"
                        echo "  vorbis - OGG Vorbis (open lossy)"
                        echo "  wav    - Uncompressed PCM WAV (huge)"
                        echo "  [0] Back"
                        read -p "Custom format: " AFORMAT
                        if [[ "$AFORMAT" == "0" ]]; then
                            continue  # go back to audio menu
                        fi
                        ASUFFIX=".custom"
                        ;;
                    0) break ;;
                    *) continue ;;
                esac

                clear
                read -p "Enter YouTube URL: " URL
                echo "[1] Single Video"
                echo "[2] Entire Playlist"
                read -p "Choose: " plchoice
                [[ $plchoice == 1 ]] && PLMODE="--no-playlist" || PLMODE="--yes-playlist"

                clear
                yt-dlp $PLMODE -x --audio-format "$AFORMAT" --audio-quality 0 --restrict-filenames -o "$ADIR/%(title)s$ASUFFIX" "$URL"
                if [[ $? -ne 0 ]]; then
                    echo "❌ Error: Download failed. Check URL/format/network."
                    echo
                    echo "💡 If yt-dlp fails repeatedly, consider switching to the Nightly build:"
                    echo "   pipx uninstall yt-dlp"
                    echo "   pipx install yt-dlp --pip-args=\"--pre\""
                    read -n 1 -s -r -p "Press any key to continue..."
                    continue
                fi

                echo "✅ Audio(s) saved to: $ADIR"
                read -n 1 -s -r -p "Press any key to continue..."
            done
            ;;
        0) exit 0 ;;
        *) continue ;;
    esac
done

