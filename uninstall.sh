```bash id="m0jlwm"
#!/bin/sh

echo "=================================="
echo " RouteRich BCW Manager Uninstall"
echo "=================================="
echo ""

rm -f /usr/bin/bcw
rm -f /root/blockcheckw-manager.sh
rm -f /root/.bcw.conf

echo "Manager removed."

echo ""
echo "Remove reports too? [y/N]"
read a

case "$a" in
y|Y)
rm -f /root/*_working.txt
rm -f /root/*_quick.txt
rm -f /root/*_report.json
rm -f /root/*_scan.json
rm -f /root/*_check.json
rm -f /root/*_report_vanilla.txt
echo "Reports removed."
;;
*)
echo "Reports kept."
;;
esac

echo ""
echo "Done."
```
