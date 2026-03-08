#!/command/with-contenv sh
# shellcheck shell=sh
set -e

echo "Fixing perms..."


echo "Fixing data directory perms..."

mkdir -p /data /data/dkim /data/postfix/queue /data/postfix/queue/public /data/postfix/queue/maildrop /data/postfix/vmail

chown postfix:postfix /data

chown -R postfix:postfix /data/dkim
chown -R postfix:postfix /data/postfix/queue

chown root:root /data/postfix/queue
chown root:root /data/postfix/queue/pid
chown root:root /data/postfix/queue/etc
chown root:root /data/postfix/queue/etc/nsswitch.conf
chown root:root /data/postfix/queue/etc/services
chown root:root /data/postfix/queue/etc/host.conf

chown postfix:postdrop /data/postfix/queue/public
chown postfix:postdrop /data/postfix/queue/maildrop

chmod -R 751 /data/postfix/queue
chmod 751 /data/postfix/vmail


echo "Fixing postfix directory perms..."

mkdir -p /etc/postfix

cp -rL /config/postfix/* /etc/postfix/

chown -R root:root /etc/postfix
chmod -R 750 /etc/postfix


echo "Fixing sasl directory perms..."

rm -rf /etc/sasldb2
cp /etc/sasl2/sasldb2 /etc/sasldb2

chmod 400 /etc/sasldb2
chown postfix:postfix /etc/sasldb2

rm -rf /etc/sasl2/sasldb2 

echo "Done fixing perms !"