#!/command/with-contenv sh
# shellcheck shell=sh
set -e

echo "Fixing perms..."
mkdir -p /data /data/dkim /data/postfix/queue /data/postfix/vmail

chown postfix:postfix /data
chown -R postfix:postfix /data/dkim
chown -R postfix:postfix /data/postfix/queue

chown postfix:postdrop /data/postfix/queue/public
chown postfix:postdrop /data/postfix/queue/maildrop

chown root:root /data/postfix/queue/.
chown root:root /data/postfix/queue/pid
chown root:root /data/postfix/queue/etc
chown root:root /data/postfix/queue/etc/localtime
chown root:root /data/postfix/queue/etc/services
chown root:root /data/postfix/queue/etc/host.conf
chown root:root /data/postfix/queue/etc/nsswitch.conf

chmod 750 /data/postfix/vmail

mkdir -p -m o-rwx /var/run/rspamd
chown rspamd:rspamd /var/run/rspamd

# Fix perms
chown rspamd:rspamd /etc/rspamd /var/lib/rspamd