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

# Mengambil IP dan Gateway
IP4=$(curl -4 -s icanhazip.com)
GW=$(ip route | awk '/default/ { print $3 }')

# Membuat net.bat untuk settingan IP dan DNS otomatis
cat >/tmp/net.bat<<EOF
@ECHO OFF
cd.>%windir%\GetAdmin
if exist %windir%\GetAdmin (del /f /q "%windir%\GetAdmin") else (
echo CreateObject^("Shell.Application"^).ShellExecute "%~s0", "%*", "", "runas", 1 >> "%temp%\Admin.vbs"
"%temp%\Admin.vbs"
del /f /q "%temp%\Admin.vbs"
exit /b 2)
net user Administrator $PASSWORD

netsh -c interface ip set address name="Ethernet" source=static address=$IP4 mask=255.255.240.0 gateway=$GW
netsh -c interface ip add dnsservers name="Ethernet" address=1.1.1.1 index=1 validate=no
netsh -c interface ip add dnsservers name="Ethernet" address=8.8.4.4 index=2 validate=no

cd /d "%ProgramData%/Microsoft/Windows/Start Menu/Programs/Startup"
del /f /q net.bat
exit
EOF

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

# Mount dan copy file setup
mount.ntfs-3g /dev/vda2 /mnt
cd "/mnt/ProgramData/Microsoft/Windows/Start Menu/Programs/"
cd Start* || cd start*; \
wget https://nixpoin.com/ChromeSetup.exe
cp -f /tmp/net.bat net.bat

echo "[✓] Silakan reboot VPS Anda untuk mem-boot ke Windows."
