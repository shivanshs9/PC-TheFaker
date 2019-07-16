#!/bin/sh

##########################
# Setup the Firewall rules
##########################
fw_setup() {
  # First we added a new chain called 'REDSOCKS2' to the 'nat' table.
  sudo iptables -t nat -N REDSOCKS2

  # Next we used "-j RETURN" rules for the networks we don’t want to use a proxy.
  while read item; do
      sudo iptables -t nat -A REDSOCKS2 -d $item -j RETURN
  done < /home/shivanshs9/Network/whitelist.txt

  # We then told iptables to redirect all port 80 connections to the http-relay redsocks port and all other connections to the http-connect redsocks port.
  sudo iptables -t nat -A REDSOCKS2 -p tcp --dport 80 -j REDIRECT --to-ports 12345
  sudo iptables -t nat -A REDSOCKS2 -p tcp -j REDIRECT --to-ports 12346

  # Finally we tell iptables to use the ‘REDSOCKS’ chain for all outgoing connection in the network interface ‘eth0′.
  sudo iptables -t nat -A PREROUTING -i docker0 -p tcp -j REDSOCKS2

  sudo iptables -t nat -I OUTPUT 1 -p tcp -j REDSOCKS2
}

##########################
# Clear the Firewall rules
##########################
fw_clear() {
  sudo iptables-save | grep -v REDSOCKS2 | iptables-restore
  #iptables -L -t nat --line-numbers
  #iptables -t nat -D PREROUTING 2
}

fw_reset() {
  sudo iptables -t nat -F REDSOCKS2
  sudo iptables -t nat -X REDSOCKS2
  sudo iptables -t nat -F PREROUTING
  sudo iptables -t nat -F OUTPUT
}

case "$1" in
    start)
        echo -n "Setting REDSOCKS firewall rules..."
        fw_clear
        fw_setup
        echo "done."
        ;;
    stop)
        echo -n "Cleaning REDSOCKS firewall rules..."
        fw_clear
        echo "done."
        ;;
    reset)
        echo -n "Resetting iptables..."
        fw_reset
        echo "done."
        ;;
    *)
        echo "Usage: $0 {start|stop}"
        exit 1
        ;;
esac
exit 0

