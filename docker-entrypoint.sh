#!/usr/bin/env bash
SEED=$(date +'%Y%m%d%H%M%S')
BASE_PATH="/usr/local/flexgw/"
VOLUME_PATH="${BASE_PATH}instance/"
DEFAULT_USER=${DEFAULT_USER:-admin}
DEFAULT_PASSWORD=${DEFAULT_PASSWORD:-admin}

IS_DEBUG=$(echo "$DEBUG" |grep -Ei "^(true|1)$")

log_if_error(){
    local rt=$1
    shift
    if [ "$rt" -gt 0 ];then 
        log_error "$*"
        exit $rt
    fi
}

log_error()
{
    echo -e "$(date +'%Y-%m-%d %H:%M:%S') \e[31;1m[ERROR]\e[0m $*";
}

log()
{
    echo -e "$(date +'%Y-%m-%d %H:%M:%S') [INFO] $*";
}

log_debug(){
    if [ ! -z "$IS_DEBUG" ];then
        echo -e "$(date +'%Y-%m-%d %H:%M:%S') \e[34;1m[DEBUG]\e[0m $*";
    fi
}


function migrate_db () {
    db_file="${VOLUME_PATH}website.db"
    db_backup="${db_file}.${SEED}"
    if [ -f "${db_file}" ]; then
        cp -f "${db_file}" "${db_backup}"
        log "backup db to ${db_backup}"
    else
        log "database not found,create it."
        # touch ${db_file}
        ${BASE_PATH}scripts/initdb.py
        # mv -f  "${BASE_PATH}website.db" "${db_file}"
    fi
    log "starting database migrating."
    ${BASE_PATH}scripts/db-manage.py db upgrade --directory "${BASE_PATH}scripts/migrations" # 1>/dev/null 2>&1 
    rt=$?
    if [ $rt -eq 0 ]; then
        rm -f "${db_backup}"
        log "database migration successed."
    else
        { 
            log_error "error: upgrade db failed."
            log "backup db is: ${db_backup}"
            exit 1
        } >&2
    fi
}

function prepare_config () {
    # build cert.
    if [ ! -f "${VOLUME_PATH}ca.crt" ]; then
        log "generate certificates."
        pushd /usr/local/flexgw/scripts/
        bash cert-build
        pushd keys
        cp -f ca.crt server.crt server.key "${VOLUME_PATH}"
    fi
    cd "${VOLUME_PATH}"
    cp -f ca.crt server.crt server.key /etc/openvpn/
    # packaging openvpn client config files.
    cd "${BASE_PATH}website/vpn/dial/static"
    zip -qj windows-openvpn-client.zip /etc/openvpn/ca.crt "${BASE_PATH}rc/openvpn-client.ovpn"
    tar -czf linux-openvpn-client.tar.gz -C /etc/openvpn ca.crt -C "${BASE_PATH}rc" openvpn-client.conf
    cp -f "${BASE_PATH}application.cfg" "${VOLUME_PATH}"
    application_config="${VOLUME_PATH}application.cfg"
    if [ "${DEBUG}" == "true" ]; then
        sed -i 's/False/True/g' "${application_config}"
    fi
    # setting flask website SECRET_KEY
    echo "SECRET_KEY = '$(head -c 32 /dev/urandom | base64 | head -c 32)'" >> "$application_config"
}

function restore_snat(){
    snat_rules="${VOLUME_PATH}snat-rules.iptables"
    if [ -f "${snat_rules}" ]; then
        iptables-restore --table=nat < "${snat_rules}"
        log "restore snat rules."
    fi
}

function create_net_device(){
    mkdir -p /dev/net
    mknod /dev/net/tun c 10 200
    ip tuntap add mode tap tap
}

function create_user(){
    cd "$BASE_PATH"
    grep "^${DEFAULT_USER}:" /etc/passwd >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        useradd -m -s /bin/bash "${DEFAULT_USER}"
        echo "${DEFAULT_USER}:${DEFAULT_PASSWORD}" | chpasswd
        log "create user ${DEFAULT_USER}."
        ./scripts/user-manage.py add "${DEFAULT_USER}" "${DEFAULT_PASSWORD}"
    fi
}


migrate_db
prepare_config
restore_snat
# create_net_device
create_user

exec $@
