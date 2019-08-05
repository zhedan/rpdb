#!/bin/bash

LISTEN_TYPE=''


while getopts u option; do
    case $option in
        u)
            LISTEN_TYPE='unix'            
            shift
            ;;
        *)
            echo "nonsupported options: $OPTARG"
            exit 1
    esac
done

lerror(){
    local msg="$*"

    msg="$ERR_MARK$msg"
    if [ -t 2 ]; then
      echo -e 1>&2 "\e[31m$msg\e[0m"
    else
      echo -e 1>&2 "$msg"
    fi
}


lwarn(){
    local msg="$*"
    msg="$WARNING_MARK$msg"

    if [ -t 2 ]; then
      echo -e 1>&2 "\e[33m$msg\e[0m"
    else
      echo -e 1>&2 "$msg"
    fi
}


lsuccess(){
    local msg="$*"
    msg="$SUCESS_MARK$msg"

    if [ -t 2 ]; then
      echo -e 1>&2 "\e[32m$msg\e[0m"
    else
      echo -e 1>&2 "$msg"
    fi
}

function do_unix_listen() {
    local path=$1
    if [ x"$path" == x ]; then
        lerror "must provide unix socket path"
        exit 1
    fi

    if [ -e $path ]; then
      if [ -S $path ]; then
        lwarn "listen unix path already exist, rm it: $path" 
        rm -f $path
      else
        lerror "listen path already exist, but not a unix socket path: $path"
        lerror "you should check whether path is correct or remove it manually"
        exit 1
      fi
    fi

    lsuccess "Listening on unix socket path: $path"
    lsuccess "You can insert following code to your python code:"
    lsuccess "  import rpdb"
    lsuccess "  rpdb.set_trace(path='$path'"
    lsuccess "When client connected, you can do debug like using pdb"

    umask 0000

    socat UNIX-LISTEN:$path READLINE
}


function do_tcp_listen() {
    local port=$1
    if [ x"$port" == x ]; then
      echo 1>&2 "must provide listen port"
      exit 1
    fi

    lsuccess "Listening on tcp port: $port"
    lsuccess "You can insert following code to your python code:"
    lsuccess "  import rpdb"
    lsuccess "  rpdb.set_trace('\$any_ip_in_your_host', $port)"
    lsuccess "When client connected, you can do debug like using pdb"

    socat  TCP4-LISTEN:"$port" READLINE
}


function help() {
  cat <<EOF 
Usage: $0 [-u] LISTEN_DEST
  -u: when set, LISTEN_DEST should be a unix socket path
      when no set, LISTEN_DEST should be a tcp port
EOF
}


function main(){
    local listen_dest="${1:-444}"

    if [ $# -eq 0 ]; then
      help
      exit 0
    fi


    case $LISTEN_TYPE in
       unix)
          do_unix_listen $listen_dest
          ;;
        *)
          do_tcp_listen $listen_dest
          ;;
     esac
  }

main "$@"

