#!/bin/bash
fqdn=$1

ip4=$(ip -o -4 addr list eth0  | awk '{print $4}' | cut -d/ -f1)
rev=$(echo $ip4 | awk -F . '{print $4"."$3"."$2"."$1".in-addr.arpa"}')

echo $fqdn
echo $ip4
echo $rev

echo "update hostname"
hostnamectl set-hostname "$fqdn"
echo $fqdn > /etc/HOSTNAME


echo "update minion_id"
echo $fqdn > /etc/salt/minion_id

echo "restart venv-salt-minion.service"
systemctl restart venv-salt-minion.service


echo "update dns"
#HMAC="hmac-sha512:hnrx:nfmJx01+UD0VJeKeAwopKlG8Onyuq/mVfQfeGD02RAkwHDggKt4ekPgySqxgGvZts4YHdPHLluXQBthZjyR1YA=="
HMAC="HMAC-MD5:homelab:xm3zf951D/2JUdreBT+92SvG6l5ZMICp7XlxpK8ma+8WkcxouI7cJpej/3KED92+d9vDUDvQezKFD2FCXmUDrQ=="

nsupdate -y $HMAC << EOF
server ns.homenet
update add $fqdn 172800 A $ip4
send
update add $rev 172800 PTR $fqdn.
send
EOF

echo "done!"