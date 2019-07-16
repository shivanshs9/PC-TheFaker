#!/bin/bash

if test $# -eq 2
then
    proxy_user=$1
    proxy_pass=$2
else
    case "$1" in
    user)
        echo "Setting proxy of <user>..."
        proxy_user="<username>"
        proxy_pass="<password>"
        ;;
    *)
        echo "No proxy authentication defined. Exiting..."
        exit 1
        ;;
    esac
fi

echo "Creating redsocks configuration file using proxy 10.1.1.45:80..."
sed -e "s|\${proxy_user}|${proxy_user}|" \
    -e "s|\${proxy_pass}|${proxy_pass}|" \
    /home/shivanshs9/Network/redsocks.tmpl > /tmp/redsocks.conf

echo "Generated configuration:"
#cat /tmp/redsocks.conf

echo "Activating iptables rules..."
sudo bash /home/shivanshs9/Network/redsocks-fw.sh start

pid=0

# SIGUSR1 handler
usr_handler() {
  echo "usr_handler"
}

# SIGTERM-handler
term_handler() {
    if [ $pid -ne 0 ]; then
        echo "Interrupt signal catched. Shutdown redsocks and disable iptables rules..."
        kill -SIGTERM "$pid"
        wait "$pid"
        sudo bash /home/shivanshs9/Network/redsocks-fw.sh reset
    fi
    exit 143; # 128 + 15 -- SIGTERM
}

# setup handlers
trap 'kill ${!}; usr_handler' SIGUSR1
trap 'kill ${!}; term_handler' SIGINT

echo "Starting redsocks2..."
sudo redsocks2 -c /tmp/redsocks.conf &
pid="$!"

# wait indefinetely
while true
do
    tail -f /dev/null & wait ${!}
done
