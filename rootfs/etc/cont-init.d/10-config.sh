#!/command/with-contenv bash
# shellcheck shell=bash
set -e

. $(dirname $0)/00-env

echo "Setting timezone to ${TZ}..."
ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime
echo ${TZ} >/etc/timezone