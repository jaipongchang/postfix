#!/command/with-contenv bash
# shellcheck shell=bash
set -e

. $(dirname $0)/00-env

postalias /etc/postfix/aliases
postmap /etc/postfix/virtual_alias_maps
postmap /etc/postfix/virtual_mailbox_maps
postmap /etc/postfix/sender_access

chown root:postfix /etc/postfix/*.db
chmod 640 /etc/postfix/*.db