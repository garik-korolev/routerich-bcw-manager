```bash id="q3fr1r"
#!/bin/sh

echo "=================================="
echo " RouteRich BCW Manager Installer"
echo "=================================="
echo ""

URL="https://raw.githubusercontent.com/dedikar/routerich-bcw-manager/main/blockcheckw-manager.sh"

echo "[1/4] Downloading..."
wget -O /root/blockcheckw-manager.sh "$URL" || exit 1

echo "[2/4] Setting permissions..."
chmod +x /root/blockcheckw-manager.sh

echo "[3/4] Creating command bcw..."
ln -sf /root/blockcheckw-manager.sh /usr/bin/bcw

echo "[4/4] Done."
echo ""
echo "Run command: bcw"
echo ""
bcw
```
