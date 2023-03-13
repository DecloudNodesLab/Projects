#!/bin/bash
cat > /root/v2ray/config.json <<EOF 
{
"inbounds": [
{
"port": 1080,
"protocol": "vmess",
"settings": {
"clients": [
{
"id": "$UID",
"alterId": 0
"security": "$SECURITY",
}
]
}
}
],
"outbounds": [
{
"protocol": "freedom",
"settings": {}
}
]
}
EOF
