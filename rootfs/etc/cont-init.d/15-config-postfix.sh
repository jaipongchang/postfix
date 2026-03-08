#!/command/with-contenv bash
# shellcheck shell=bash
set -e

. $(dirname $0)/00-env

postalias /etc/postfix/aliases
postmap /etc/postfix/sender_access
postmap /etc/postfix/sender_login_maps
postmap /etc/postfix/transport
postmap /etc/postfix/virtual_alias_maps
postmap /etc/postfix/virtual_mailbox_maps
postmap /etc/postfix/dnsbl_reply_map

chown root:postfix /etc/postfix/*.db
chmod 640 /etc/postfix/*.db