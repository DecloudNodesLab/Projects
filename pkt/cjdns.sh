#!/bin/sh
# modified initial scrypt https://pkt.cash/special/cjdns/cjdns.sh!
if [ -z "$CJDNS_IPV4" ]
then
echo "Public IP is empty! Set CJDNS_IPV4 in SDL and update deployment!"
sleep infinity
fi
if [ -e /etc/cjdns.sh.env ] ; then
    . "/etc/cjdns.sh.env"
fi

: "${CJDNS_PATH:=/usr/local/bin}"
: "${CJDNS_PORT:=3478}"
: "${CJDNS_CONF_PATH:=/etc/cjdroute_${CJDNS_PORT}.conf}"
: "${CJDNS_SOCKET:=cjdroute_${CJDNS_PORT}.sock}"
: "${CJDNS_IPV6:=true}"
: "${CJDNS_PEERID:=PUB_NotYielding}"
: "${CJDNS_SETUSER:=nobody}"
: "${CJDNS_SECONDARY:=false}"
: "${CJDNS_IPV4:=false}"
: "${CJDNS_IPV6:=false}"
if [ -z "$CJDNS_TUN" ]; then
    if ! [ "$CJDNS_SECONDARY" = 'false' ]; then
        CJDNS_TUN='false'
    else
        CJDNS_TUN='true'
    fi
fi
if [ -z "$CJDNS_ADMIN_PORT" ]; then
    if ! [ "$CJDNS_SECONDARY" = 'false' ]; then
        CJDNS_ADMIN_PORT=$((CJDNS_PORT + 1))
    else
        CJDNS_ADMIN_PORT=11234
    fi
fi

cjdns_sh_env() {
    echo "#!/bin/sh"
    echo ": \"\${CJDNS_PATH:=$CJDNS_PATH}\""
    echo ": \"\${CJDNS_PORT:=$CJDNS_PORT}\""
    echo ": \"\${CJDNS_CONF_PATH:=$CJDNS_CONF_PATH}\""
    echo ": \"\${CJDNS_SOCKET:=$CJDNS_SOCKET}\""
    echo ": \"\${CJDNS_TUN:=$CJDNS_TUN}\""
    echo ": \"\${CJDNS_PEERID:=$CJDNS_PEERID}\""
    echo ": \"\${CJDNS_IPV6:=$CJDNS_IPV6}\""
    echo ": \"\${CJDNS_SETUSER:=$CJDNS_SETUSER}\""
    echo ": \"\${CJDNS_SECONDARY:=$CJDNS_SECONDARY}\""
    echo ": \"\${CJDNS_ADMIN_PORT:=$CJDNS_ADMIN_PORT}\""
    echo ": \"\${CJDNS_IPV4:=$CJDNS_IPV4}\""
    echo ": \"\${CJDNS_IPV6:=$CJDNS_IPV6}\""
}

die() {
    echo "ERROR: $1"
    exit 100
}
need() {
    if ! command -v "$1" >/dev/null ; then
        die "Need $1"
    fi
}
dlod() {
    if command -v wget >/dev/null ; then
        wget -qO - "$1"        
    elif command -v curl >/dev/null ; then
        curl "$1"
    else
        die "Need either wget or curl"
    fi
}

check() {
    echo "Checking required tools are present"
    need uname
    need tar
    need sha256sum
    need cut
    need chmod
    need grep
    need jq
    need ldd

    if command -v wget >/dev/null ; then
        true
    elif command -v curl >/dev/null ; then
        true
    else
        die "Need either wget or curl"
    fi
    if ! [ "$(id -u)" = '0' ] ; then
        die "This script must be run as root"
    fi
}

do_manifest() {
    download_path=$1
    dlod "$download_path/manifest.txt" | while read -r line; do
        hash="$(echo "$line" | cut -f 1 -d ' ')"
        file="$(echo "$line" | cut -f 3 -d ' ')"
        if ! [ "$file" = "" ] ; then
            if [ -e "$CJDNS_PATH/$file" ] ; then
                if ! [ "$(sha256sum "$CJDNS_PATH/$file" 2>/dev/null | cut -f 1 -d ' ')" = "$hash" ] ; then
                    echo "File $file has different hash (likely update) - re-downloading"
                    rm "$CJDNS_PATH/$file" 2>/dev/null
                fi
            fi
            if ! [ -e "$CJDNS_PATH/$file" ] ; then
                dlod "$download_path/$file" > "$CJDNS_PATH/$file"
            fi
            chmod a+x "$CJDNS_PATH/$file"
        fi
    done
}

update() {
    libc=$1
    echo "Downloading / updating cjdns"
    do_manifest "https://pkt.cash/special/cjdns"
    do_manifest "https://pkt.cash/special/cjdns/binaries/$(uname -s)-$(uname -m)-$libc"
}

mk_conf() {
    echo "Updating cjdns conf file: $CJDNS_CONF_PATH"
    if ! [ -s "$CJDNS_CONF_PATH" ] ; then
        "${CJDNS_PATH}/cjdroute" --genconf > "$CJDNS_CONF_PATH" || die "Unable to launch cjdns"
    fi
}

update_conf() {
    tun_iface='del(.router.interface)'
    if ! [ "$CJDNS_TUN" = "false" ] ; then
        tun_iface='(.router.interface) |= {"type":"TUNInterface"}'
    fi
    if [ "$CJDNS_IPV6" = "true" ] ; then
        ipv6="(.interfaces.UDPInterface[1]) |= { \"bind\":\"[::]:$CJDNS_PORT\" }"
    else
        ipv6="del(.interfaces.UDPInterface[1])"
    fi
    if echo "$CJDNS_SETUSER" | grep -q '^[0-9]\+$' ; then
        user="$CJDNS_SETUSER"
    else
        user="\"$CJDNS_SETUSER\""
    fi
    ext_ipv4=""
    ext_ipv6=""
    if ! [ "$CJDNS_IPV4" = "false" ] ; then
        ext_ipv4=", \"ipv4\": \"$CJDNS_IPV4\""
    fi
    if ! [ "$CJDNS_IPV6" = "false" ] ; then
        ext_ipv6=", \"ipv6\": \"$CJDNS_IPV6\""
    fi
    "${CJDNS_PATH}/cjdroute" --cleanconf < "$CJDNS_CONF_PATH" | jq "\
        (.interfaces.UDPInterface[0].bind) |= \"0.0.0.0:$CJDNS_PORT\" | \
        $ipv6 | \
        (.admin.bind) |= \"127.0.0.1:$CJDNS_ADMIN_PORT\" | \
        (.router.publicPeer) |= { \"id\": \"$CJDNS_PEERID\" $ext_ipv4 $ext_ipv6 } | \
        (.pipe) |= \"$CJDNS_SOCKET\" | \
        (.noBackground) |= 1 | \
        (.security) |= map( \
            if has(\"setuser\") then \
                { \"keepNetAdmin\": 1, \"setuser\": $user } \
            else \
                . \
            end \
        ) | \
        $tun_iface" > "$CJDNS_CONF_PATH.upd"
    if ! [ -s "$CJDNS_CONF_PATH.upd" ] ; then
        die "Updating file yielded no/empty result, not saving"
    else
        mv "$CJDNS_CONF_PATH.upd" "$CJDNS_CONF_PATH"
    fi
}

install_launcher_systemd() {
    echo "Installing systemd launcher /etc/systemd/system/cjdns-sh.service"
    need systemctl
        echo '
[Unit]
Description=cjdns.sh: Automated cjdns installer and runner
Wants=network.target
After=network-pre.target
Before=network.target network.service

[Service]
ProtectHome=true
ProtectSystem=true
SyslogIdentifier=cjdroute
ExecStart=/usr/local/bin/cjdns.sh exec
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
' > "/etc/systemd/system/cjdns-sh.service"
    systemctl enable cjdns-sh.service
    systemctl start cjdns-sh.service
    systemctl status cjdns-sh.service
}

install_launcher_openrc() {
    echo "Installing openrc launcher /etc/init.d/cjdns-sh"
    echo '
#!/sbin/openrc-run

description="Automated cjdns installer and runner"

command="/usr/local/bin/cjdns.sh"
command_args="exec"
command_user="root"  # Adjust the user as needed

depend() {
    need net
    before net
}

supervisor=supervise-daemon
output_log="/var/log/cjdns.log"
error_log="/var/log/cjdns.log"
pidfile="/var/run/cjdns.pid"
respawn_delay=5
respawn_max=0  # Unlimited respawns, similar to `Restart=always` in systemd

start_pre() {
    ebegin "Starting cjdns service"
}

stop_pre() {
    ebegin "Stopping cjdns service"
}

start() {
    ebegin "Running cjdns.sh"
    supervise-daemon --start cjdns --pidfile "$pidfile" --respawn --respawn-delay $respawn_delay --stdout "$output_log" --stderr "$error_log" -- "$command" "$command_args"
    eend $?
}

stop() {
    ebegin "Stopping cjdns"
    supervise-daemon --stop cjdns --pidfile "$pidfile"
    eend $?
}
' > /etc/init.d/cjdns-sh
    chmod a+x /etc/init.d/cjdns-sh
    rc-update add cjdns-sh default
    rc-service cjdns-sh start
    rc-service crond-sh status
}

install_launcher() {
    if [ -d /run/systemd/system ] ; then
        install_launcher_systemd
        restart_cmd='systemctl restart cjdns-sh.service'
        stop_cmd='systemctl disable cjdns-sh.service'
    elif command -v rc-service >/dev/null 2>/dev/null ; then
        install_launcher_openrc
        restart_cmd='rc-service cjdns-sh restart'
        stop_cmd='rc-update del cjdns-sh default'
    else
        die "Only supported on systems with openrc or systemd"
    fi
    if [ "$CJDNS_ADMIN_PORT" = '11234' ] ; then
        cjdnstool_cmd='cjdnstool'
    else
        cjdnstool_cmd="cjdnstool -p $CJDNS_ADMIN_PORT"
    fi
    # Persist our env vars
    cjdns_sh_env > "/etc/cjdns.sh.env"
    for i in 1 2 3 4 5 6 7 8 9 10 ; do
        echo $i
        if "${CJDNS_PATH}/cjdnstool" -p "$CJDNS_ADMIN_PORT" peers show 2>/dev/null >/dev/null ; then
            break;
        fi
        echo "Waiting for cjdns to start up [$i]..."
        sleep 1
    done
    echo "Cjdns should be running with admin port $CJDNS_ADMIN_PORT"
    echo "You can control it using '$cjdnstool_cmd'"
    echo "For example, to get the list of your peers, use $cjdnstool_cmd peers show'"
    echo "As follows:"
    echo
    echo "$ $cjdnstool_cmd peers show"
    "${CJDNS_PATH}/cjdnstool" -p "$CJDNS_ADMIN_PORT" peers show
    echo
    echo "Your cjdns public UDP port is $CJDNS_PORT, and Peer ID is $CJDNS_PEERID"
    echo "This port MUST be open to the outside world in order to yield, check your firewall / NAT"
    echo "This script will update every restart. You can use $restart_cmd to restart it."
    echo "To stop cjdns from restarting, you can use: $stop_cmd"
    echo "You may run this script any time, and in case of cjdns installation issues, your installation will be fixed."
}

main() {
    check

    if ldd /bin/sh | grep -q 'libc.so.6'; then
        libc="GNU"
#    elif ldd /bin/sh | grep -q 'musl'; then
#        libc="MUSL"
    else
        libc="STATIC"
    fi

    update "$libc"
    mk_conf
    update_conf

    for arg in "$@"; do
        if [ "$arg" = "exec" ]; then
            exec "${CJDNS_PATH}/cjdroute" < "$CJDNS_CONF_PATH"
            exit 100
        fi
    done

    # We check and install the launcher only if we're not being launched from it
    install_launcher
}
main "$@"
