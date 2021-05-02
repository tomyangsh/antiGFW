if [ ! -f ssl.crt ]
then
	echo "请将证书保存至当前目录ssl.crt文件中"
	exit
fi
if [ ! -f ssl.key ]
then
	echo "请将证书密钥保存至当前目录ssl.key文件中"
	exit
fi
apt update
apt install -y nginx unzip wget xz-utils
mkdir /http
cat << EOF > /etc/nginx/sites-available/default
server {
        listen 80 default_server;

        server_name _;

        location / {
                root /http;
                autoindex on;
        }
}
EOF
systemctl restart nginx
cp ssl.crt /etc/ssl.crt
cp ssl.key /etc/ssl.key
wget -q -nc https://github.com/trojan-gfw/trojan/releases/download/v1.16.0/trojan-1.16.0-linux-amd64.tar.xz
tar -xf trojan-1.16.0-linux-amd64.tar.xz
cp trojan/trojan /usr/bin/
chmod +x /usr/bin/trojan
echo "请输入域名"
read HOST
echo "请输入密码"
read PASSWORD
cat << EOF > /etc/trojan.json
{
    "run_type": "server",
    "local_addr": "0.0.0.0",
    "local_port": 443,
    "remote_addr": "127.0.0.1",
    "remote_port": 80,
    "password": [
        "$PASSWORD"
    ],
    "log_level": 1,
    "ssl": {
        "cert": "/etc/ssl.crt",
        "key": "/etc/ssl.key",
        "key_password": "",
        "cipher": "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384",
        "cipher_tls13": "TLS_AES_128_GCM_SHA256:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_256_GCM_SHA384",
        "prefer_server_cipher": true,
        "alpn": [
            "http/1.1"
        ],
        "alpn_port_override": {
            "h2": 81
        },
        "reuse_session": true,
        "session_ticket": false,
        "session_timeout": 600,
        "plain_http_response": "",
        "curves": "",
        "dhparam": ""
    }
}
EOF
cat << EOF > /etc/systemd/system/trojan.service
[Unit]
Description=trojan
Documentation=man:trojan(1) https://trojan-gfw.github.io/trojan/config https://trojan-gfw.github.io/trojan/
After=network.target network-online.target nss-lookup.target mysql.service mariadb.service mysqld.service

[Service]
Type=simple
StandardError=journal
User=nobody
AmbientCapabilities=CAP_NET_BIND_SERVICE
ExecStart=/usr/bin/trojan /etc/trojan.json
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
RestartSec=1s

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now trojan
wget -q -nc https://github.com/p4gefau1t/trojan-go/releases/download/v0.9.0/trojan-go-linux-amd64.zip
if [ ! -f trojan-go ]
then
	unzip trojan-go-linux-amd64.zip
fi
cp trojan-go /usr/bin
cat << EOF > /etc/trojan-go.json
{
    "run_type": "server",
    "local_addr": "0.0.0.0",
    "local_port": 8443,
    "remote_addr": "127.0.0.1",
    "remote_port": 80,
    "password": [
        "$PASSWORD"
    ],
    "ssl": {
        "cert": "/etc/ssl.crt",
        "key": "/etc/ssl.key",
        "sni": "",
        "fallback_addr": "127.0.0.1",
        "fallback_port": 80
    },
    "websocket": {
        "enabled": true,
        "path": "/alonglonglongwebsocketpath",
        "host": "$HOST",
        "obfuscation_password": "$PASSWORD",
        "double_tls": false
    }
}
EOF
cat << EOF > /etc/systemd/system/trojan-go.service
[Unit]
Description=Trojan-Go - An unidentifiable mechanism that helps you bypass GFW
Documentation=https://github.com/p4gefau1t/trojan-go
After=network.target nss-lookup.target
Wants=network-online.target

[Service]
Type=simple
User=root
ExecStart=/usr/bin/trojan-go -config /etc/trojan-go.json
Restart=on-failure
RestartSec=10
RestartPreventExitStatus=23

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now trojan-go
systemctl status trojan
systemctl status trojan-go
