#!/bin/bash

set -e

# =============== CONFIG ====================
IMAGE_URL="https://sourceforge.net/projects/nixpoin/files/windows2019DO.gz/download"
DISK="/dev/vda"
TMP_DIR="/mnt/tmpwindows"
IMG_GZ="$TMP_DIR/windows2019DO.img.gz"
IMG="$TMP_DIR/windows2019DO.img"
# ===========================================

echo "[*] Membuat direktori sementara..."
mkdir -p "$TMP_DIR"

echo "[*] Mengunduh image dari $IMAGE_URL..."
wget --content-disposition -O "$IMG_GZ" "$IMAGE_URL"

echo "[*] Mengecek format gzip..."
if ! gzip -t "$IMG_GZ"; then
  echo "[!] File bukan gzip valid. Gagal."
  exit 1
fi

echo "[*] Mengekstrak image..."
gunzip -f "$IMG_GZ"

echo "[*] Menulis image ke disk $DISK..."
dd if="$IMG" of="$DISK" bs=4M status=progress conv=fsync

echo "[*] Sinkronisasi selesai. Membersihkan..."
sync
rm -rf "$TMP_DIR"

echo "[✓] Image Windows berhasil di-install ke $DISK."

echo "[✓] Silakan reboot VPS Anda untuk mem-boot ke Windows."
