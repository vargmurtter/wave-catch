#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BIN_DIR="$ROOT_DIR/assets/bin"
VERSION="${YTDLP_VERSION:-2025.12.08}"

mkdir -p "$BIN_DIR/linux" "$BIN_DIR/macos" "$BIN_DIR/windows"

download() {
  local url="$1"
  local output="$2"
  echo "Downloading $url"
  curl -fsSL "$url" -o "$output"
  if [[ "$output" != *.exe ]]; then
    chmod +x "$output"
  fi
}

download \
  "https://github.com/yt-dlp/yt-dlp/releases/download/${VERSION}/yt-dlp" \
  "$BIN_DIR/linux/yt-dlp"

download \
  "https://github.com/yt-dlp/yt-dlp/releases/download/${VERSION}/yt-dlp_macos" \
  "$BIN_DIR/macos/yt-dlp"

download \
  "https://github.com/yt-dlp/yt-dlp/releases/download/${VERSION}/yt-dlp.exe" \
  "$BIN_DIR/windows/yt-dlp.exe"

echo "yt-dlp binaries saved to $BIN_DIR"
