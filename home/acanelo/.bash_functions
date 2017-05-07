#!/bin/bash

clone_linux-setup(){
    if [ -d /tmp/linux-setup ] ; then
        echo "The directory '/tmp/linux-setup' already exists. Aborting."
        return 2
    fi
    pushd /tmp
    git clone git@github.com:alvarocanelo/linux-setup.git
    ret_code=$?
    popd
    if [ $ret_code -eq 0 ] ; then
        printf "\nLinux-setup repository successfully cloned in '/tmp/linux-setup/'\n\n"
        return 0
    else
        printf "\nThere was an error cloning repository 'github.com:alvarocanelo/linux-setup.git'\n\n"
        return 1
    fi
}

csview(){
    if [ "$#" -eq 0 ] || [ "$#" -gt 2 ]
    then
        echo "Usage: $0 <csv file> [<separator>]"              
        return 1
    fi

    SEP=,
    if [ "$#" -eq 2 ]
        then
        SEP=$2
    fi

    sed "s/$SEP$SEP/$SEP $SEP/g;s/$SEP$SEP/$SEP $SEP/g" "$1" | \
        column -s$SEP -t | \
        less -#2 -N -S
}

mounthost(){
    [ -z "$1" ] && echo "\
mounthost error: no given parameters [username@]hostname"
    param="$1"
    at_instring="${param//[^@]}"
    case ${#at_instring} in
        0)
           user='root'
           host="$param"
           user_host="$user"'@'"$host"
           ;;
        1)
            user="$(cut -d@ -f1 <<< $param)"
            host="$(cut -d@ -f2 <<< $param)"
            user_host="$param"
            ;;
        *)
            echo "mounthost error: too many '@'"
            return 1
    esac
    if ! ping &>/dev/null -c1 "$host" ; then
        echo "mounthost error: host [$host] unreachable."
        return 1
    fi
    mkdir -p /tmp/sshfs/
    local_dir="$(mktemp -p /tmp/sshfs/ -d $user_host.XXX)"
    sshfs "$user_host":/ "$local_dir" \
        || {\
            echo "\
mounthost error: error accessing [$host] through SSH. Aborting.]"
            rmdir "$local_dir"
            return 1 ; }
    echo "
[Mounting $user_host:/ on $local_dir and moving to that folder.]
[Press CTRL+d to exit and unmount cleanly.                                ]
"
    pushd "$local_dir"
    bash
    popd
    fusermount -u "$local_dir"
    rmdir "$local_dir"
}

scan_eth_hosts(){
    base_ip="$( ifconfig eth0 | \
                    grep 'inet addr' | \
                    awk '{print $2}' | \
                    cut -d: -f2      | \
                    cut -d. -f1-3       )"
    nmap -n -sn "$base_ip".2-254 -oG - | awk '/Up$/{print $2}' 
}

eth_connection(){
    ssh root@$(scan_eth_hosts | head -1)
}

toggle-openvpn(){
    if /etc/init.d/openvpn status 1>/dev/null ; then
        action='stop'
    else
        action='start'
    fi
    sudo /etc/init.d/openvpn "$action"
    return $?
}

transfer() {
    if [ $# -eq 0 ]; then
        echo "\
No arguments specified. Usage:\
echo transfer /tmp/test.md\
cat /tmp/test.md | transfer test.md"
        return 1
    fi
    tmpfile=$( mktemp -t transferXXX )
    if tty -s ; then
        basefile=$(basename "$1" | sed -e 's/[^a-zA-Z0-9._-]/-/g')
        curl --progress-bar --upload-file \
            "$1" "https://transfer.sh/$basefile" >> $tmpfile
    else
        curl --progress-bar --upload-file \
            "-" "https://transfer.sh/$1" >> $tmpfile
    fi
    cat $tmpfile
    rm -f $tmpfile
}

xmlview(){
    pre=""
    firstline=true
    sed -e 's_<_\
&_g' -e 's_>_&\
_g' -e 's_\
\
_\
_g' \
    | while read line; do 
        if $firstline ; then
            firstline=false
            continue
        fi
        if [   "${line:0:2}" == '</' ] ; then
            pre="${pre::-2}"
        fi
        echo "$pre""$line"
        if [ "${line:0:2}" != '</' ] \
           && [ "${line:0:1}" == '<' ] ; then
            pre="  ""$pre" # 4 whitespaces
        fi
        done \
    | less
}
