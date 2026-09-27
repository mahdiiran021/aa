#!/bin/bash
set -e

# اگر رمز تنظیم نشده بود، از پیش‌فرض استفاده کن
PASSWORD="${VNC_PASSWORD:-changeme123}"

# ساخت فایل رمز VNC
mkdir -p /root/.vnc
echo "$PASSWORD" | vncpasswd -f > /root/.vnc/passwd
chmod 600 /root/.vnc/passwd

# ساخت فایل xstartup برای اجرای XFCE
cat > /root/.vnc/xstartup <<'EOF'
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
startxfce4 &
EOF
chmod +x /root/.vnc/xstartup

# اجرای VNC با رمز عبور (نه SecurityTypes None)
vncserver :1 \
    -localhost no \
    -geometry 1024x768 \
    -depth 24 \
    -rfbauth /root/.vnc/passwd

# ساخت گواهی SSL برای noVNC
openssl req -new -subj "/C=JP" -x509 -days 365 -nodes \
    -out /self.pem -keyout /self.pem

# اجرای websockify (پل بین noVNC و VNC)
websockify -D --web=/usr/share/novnc/ --cert=/self.pem 6080 localhost:5901

# جلوگیری از خروج کانتینر
tail -f /dev/null
