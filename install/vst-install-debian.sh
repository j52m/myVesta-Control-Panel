#!/bin/bash

# myVesta Debian installer v 0.9

#----------------------------------------------------------#
#                  Variables&Functions                     #
#----------------------------------------------------------#
echo $PATH

export PATH='$PATH:/sbin'
#export PATH="${PATH}:/sbin"
export DEBIAN_FRONTEND="noninteractive"

echo $PATH
exit

RHOST='apt.myvestacp.com'
CHOST='c.myvestacp.com'
VERSION='debian'
VESTA='/usr/local/vesta'
memory=$(grep 'MemTotal' /proc/meminfo |tr ' ' '\n' |grep [0-9])
arch=$(uname -i)
os='debian'
release=$(cat /etc/debian_version | tr "." "\n" | head -n1)
codename="$(cat /etc/os-release |grep VERSION= |cut -f 2 -d \(|cut -f 1 -d \))"
vestacp="$VESTA/install/$VERSION/$release"

if [ "$release" -eq 11 ]; then
    software="nginx apache2 apache2-utils
        libapache2-mod-fcgid php-fpm php
        php-common php-cgi php-mysql php-curl php-fpm php-pgsql awstats
        vsftpd proftpd-basic bind9 exim4 exim4-daemon-heavy
        clamav-daemon spamassassin dovecot-imapd dovecot-pop3d roundcube-core
        roundcube-mysql roundcube-plugins mariadb-server mariadb-common
        mariadb-client postgresql postgresql-contrib phppgadmin phpmyadmin mc
        flex whois git idn zip sudo bc ftp lsof ntpdate rrdtool quota
        e2fslibs bsdutils e2fsprogs curl imagemagick fail2ban dnsutils
        bsdmainutils cron vesta vesta-nginx vesta-php expect libmail-dkim-perl
        unrar-free vim-common net-tools unzip iptables"
elif [ "$release" -eq 10 ]; then
    software="nginx apache2 apache2-utils
        libapache2-mod-fcgid php-fpm php
        php-common php-cgi php-mysql php-curl php-fpm php-pgsql awstats
        webalizer vsftpd proftpd-basic bind9 exim4 exim4-daemon-heavy
        clamav-daemon spamassassin dovecot-imapd dovecot-pop3d roundcube-core
        roundcube-mysql roundcube-plugins mariadb-server mariadb-common
        mariadb-client postgresql postgresql-contrib phppgadmin mc
        flex whois git idn zip sudo bc ftp lsof ntpdate rrdtool quota
        e2fslibs bsdutils e2fsprogs curl imagemagick fail2ban dnsutils
        bsdmainutils cron vesta vesta-nginx vesta-php expect libmail-dkim-perl
        unrar-free vim-common net-tools unzip"
elif [ "$release" -eq 9 ]; then
    echo "==================================================="
    echo "Important message:"
    echo "myVesta is much more faster with Debian 10 ."
    echo "Are you sure you want to continue with Debian 9 ?"
    read -p "==================================================="
    software="nginx apache2 apache2-utils apache2-suexec-custom
        libapache2-mod-ruid2 libapache2-mod-fcgid libapache2-mod-php php
        php-common php-cgi php-mysql php-curl php-fpm php-pgsql awstats
        webalizer vsftpd proftpd-basic bind9 exim4 exim4-daemon-heavy
        clamav-daemon spamassassin dovecot-imapd dovecot-pop3d roundcube-core
        roundcube-mysql roundcube-plugins mysql-server mysql-common
        mysql-client postgresql postgresql-contrib phppgadmin phpmyadmin mc
        flex whois rssh git idn zip sudo bc ftp lsof ntpdate rrdtool quota
        e2fslibs bsdutils e2fsprogs curl imagemagick fail2ban dnsutils
        bsdmainutils cron vesta vesta-nginx vesta-php expect libmail-dkim-perl
        unrar-free vim-common net-tools unzip"
elif [ "$release" -eq 8 ]; then
    echo "==================================================="
    echo "Important message:"
    echo "myVesta is much more faster with Debian 10 ."
    echo "Are you sure you want to continue with Debian 8 ?"
    read -p "==================================================="
    software="nginx apache2 apache2-utils apache2.2-common
        apache2-suexec-custom libapache2-mod-ruid2
        libapache2-mod-fcgid libapache2-mod-php5 php5 php5-common php5-cgi
        php5-mysql php5-curl php5-fpm php5-pgsql awstats webalizer vsftpd
        proftpd-basic bind9 exim4 exim4-daemon-heavy clamav-daemon
        spamassassin dovecot-imapd dovecot-pop3d roundcube-core
        roundcube-mysql roundcube-plugins mysql-server mysql-common
        mysql-client postgresql postgresql-contrib phppgadmin phpMyAdmin mc
        flex whois rssh git idn zip sudo bc ftp lsof ntpdate rrdtool quota
        e2fslibs bsdutils e2fsprogs curl imagemagick fail2ban dnsutils
        bsdmainutils cron vesta vesta-nginx vesta-php expect libmail-dkim-perl
        unrar-free vim-common net-tools unzip"
fi

# Defining help function
help() {
    echo "Usage: $0 [OPTIONS]
  -a, --apache            Install Apache        [yes|no]  default: yes
  -n, --nginx             Install Nginx         [yes|no]  default: yes
  -w, --phpfpm            Install PHP-FPM       [yes|no]  default: no
  -v, --vsftpd            Install Vsftpd        [yes|no]  default: no
  -j, --proftpd           Install ProFTPD       [yes|no]  default: yes
  -k, --named             Install Bind          [yes|no]  default: yes
  -m, --mysql             Install MariaDB       [yes|no]  default: yes
  -d, --mysql8            Install MySQL 8       [yes|no]  default: no
  -g, --postgresql        Install PostgreSQL    [yes|no]  default: no
  -x, --exim              Install Exim          [yes|no]  default: yes
  -z, --dovecot           Install Dovecot       [yes|no]  default: yes
  -c, --clamav            Install ClamAV        [yes|no]  default: yes
  -t, --spamassassin      Install SpamAssassin  [yes|no]  default: yes
  -i, --iptables          Install Iptables      [yes|no]  default: yes
  -b, --fail2ban          Install Fail2ban      [yes|no]  default: yes
  -o, --softaculous       Install Softaculous   [yes|no]  default: no
  -q, --quota             Filesystem Quota      [yes|no]  default: no
  -l, --lang              Default language                default: en
  -y, --interactive       Interactive install   [yes|no]  default: yes
  -s, --hostname          Set hostname
  -e, --email             Set admin email
  -p, --password          Set admin password
  -u, --secret_url        Set secret url for hosting panel
  -1, --port              Set Vesta port
  -f, --force             Force installation
  -h, --help              Print this help

  Example: bash $0 -e demo@myvestacp.com -p p4ssw0rd --apache no --phpfpm yes"
    exit 1
}


# Defining password-gen function
gen_pass() {
    MATRIX='0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
    LENGTH=14
    while [ ${n:=1} -le $LENGTH ]; do
        PASS="$PASS${MATRIX:$(($RANDOM%${#MATRIX})):1}"
        let n+=1
    done
    echo "$PASS"
}

# Defning return code check function
check_result() {
    if [ $1 -ne 0 ]; then
        echo "Error: $2"
        exit $1
    fi
}

# Defining function to set default value
set_default_value() {
    eval variable=\$$1
    if [ -z "$variable" ]; then
        eval $1=$2
    fi
    if [ "$variable" != 'yes' ] && [ "$variable" != 'no' ]; then
        eval $1=$2
    fi
}

# Define function to set default language value
set_default_lang() {
    if [ -z "$lang" ]; then
        eval lang=$1
    fi
    lang_list="
        ar cz el fa hu ja no pt se ua
        bs da en fi id ka pl ro tr vi
        cn de es fr it nl pt-BR ru tw
        bg ko sr th ur"
    if !(echo $lang_list |grep -w $lang 1>&2>/dev/null); then
        eval lang=$1
    fi
}

ensure_startup() {
    echo "- making sure startup is enabled for: $1"
    currentservice=$1
    unit_files="$(systemctl list-unit-files |grep $currentservice)"
    if [[ "$unit_files" =~ "disabled" ]]; then
        systemctl enable $currentservice
    fi
}

ensure_start() {
    echo "- making sure $1 is started"
    currentservice=$1
    systemctl status $currentservice.service > /dev/null 2>&1
    r=$?
    if [ $r -ne 0 ]; then
        systemctl start $currentservice
        check_result $? "$currentservice start failed"
    fi
}
   
  ##############################
  ##### New Functions 
  ##############################
  
    ERROR_MESSAGE() {
      local error=${1-"Uknown Error!"}
      local LINEN=${2-"${BASH_LINENO[0]}"}
        echo -e " \033[0;31mFatal Error [Line:${LINEN}]\e[0m: ${error}"
        exit 1
    }

    MAKE_TMP_FILE(){
      [[ -z "${1}" ]] && mktemp -p "${myVesta_TMP:-"/tmp"}" -t "XXXXXX" 2>&1 || mktemp -p "${myVesta_TMP:-"/tmp"}" -t "XXX_${1}" 2>&1
    }

    MAKE_CONFIG_FILE(){
      local items="${1}"
      local itemsvar="${2}"
      
        if [[ ! -z "${1}" ]]; then
          for Item in ${items[@]}; do
            [[ "${Item}" = "Break" ]] && echo "" >> ${myVesta_TMP}/myVesta.conf && continue 
            [[ "${2}" != "N" ]] && local Item="myVesta_${Item}"
              echo "${Item}=\"${!Item}\"" >> ${myVesta_TMP}/myVesta.conf
          done
        fi
    }

  ##############################
  ##### New Variables
  ##############################
    
    ### System Related Variables
    myVesta_OS="$(grep "^ID=" /etc/os-release | cut -d'=' -f2 | tr -d '"' | tr '[:upper:]' '[:lower:]')"
    myVesta_Arch="$(dpkg --print-architecture)"
    myVesta_systemRelease="$(grep "^VERSION_ID=" /etc/os-release | cut -d'=' -f2 | tr -d '"')"
    myVesta_CodeName="$(grep "^VERSION_CODENAME=" /etc/os-release | cut -d'=' -f2 | tr -d '"')"
    myVesta_Disk="$(df -H / | awk '$3 ~ /[0-9]+/ { print $4 }' | tr -d 'G')"
    myVesta_Memory="$(cat /proc/meminfo | awk '/MemTotal/ { printf $2 / (1024*1024)}')"
  
    ### myVesta Variables
    myVesta_Root="admin"
    
    myVesta_Version="0.9.8"
    myVesta_Release=""
    myVesta_Installed="$(date "+%d-%m-%Y %H:%M:%S")"

    ### myVesta Directory Structer Variables
    myVesta_TMP="$(mktemp -d -t XXX_myVesta-$(date +%m-%d-%Y_%H:%M:%S) 2>&1)" || { ERROR_MESSAGE "Failed to create TMP Directory. (${myVesta_TMP})"; }  
    myVesta_DIR="/usr/local/vesta"
    myVesta_BIN="${myVesta_DIR}/bin"
    myVesta_INSTALL_DIR="${myVesta_DIR}/install/${myVesta_OS}/${myVesta_systemRelease}"

    ### User Based Variables
    myVesta_User_Domain="j52m.com"
    
    ### Testing to be removed
    echo "${myVesta_TMP}"
    MAKE_CONFIG_FILE "Root Break Version Release Installed Break OS Arch systemRelease CodeName Break Disk Memory Break TMP DIR BIN INSTALL_DIR Break software"
   
#----------------------------------------------------------#
#                    Verifications                         #
#----------------------------------------------------------#

# Creating temporary file
tmpfile=$(mktemp -p /tmp)

# Translating argument to --gnu-long-options
for arg; do
    delim=""
    case "$arg" in
        --apache)               args="${args}-a " ;;
        --nginx)                args="${args}-n " ;;
        --phpfpm)               args="${args}-w " ;;
        --vsftpd)               args="${args}-v " ;;
        --proftpd)              args="${args}-j " ;;
        --named)                args="${args}-k " ;;
        --mysql)                args="${args}-m " ;;
        --mysql8)               args="${args}-d " ;;
        --postgresql)           args="${args}-g " ;;
        --mongodb)              args="${args}-d " ;;
        --exim)                 args="${args}-x " ;;
        --dovecot)              args="${args}-z " ;;
        --clamav)               args="${args}-c " ;;
        --spamassassin)         args="${args}-t " ;;
        --iptables)             args="${args}-i " ;;
        --fail2ban)             args="${args}-b " ;;
        --softaculous)          args="${args}-o " ;;
        --quota)                args="${args}-q " ;;
        --lang)                 args="${args}-l " ;;
        --interactive)          args="${args}-y " ;;
        --hostname)             args="${args}-s " ;;
        --email)                args="${args}-e " ;;
        --secret_url)           args="${args}-u " ;;
        --port)                 args="${args}-1 " ;;
        --password)             args="${args}-p " ;;
        --force)                args="${args}-f " ;;
        --help)                 args="${args}-h " ;;
        *)                      [[ "${arg:0:1}" == "-" ]] || delim="\""
                                args="${args}${delim}${arg}${delim} ";;
    esac
done
eval set -- "$args"

# Parsing arguments
while getopts "a:n:w:v:j:k:m:g:d:x:z:c:t:i:b:r:o:q:l:y:s:e:p:u:1:fh" Option; do
    case $Option in
        a) apache=$OPTARG ;;            # Apache
        n) nginx=$OPTARG ;;             # Nginx
        w) phpfpm=$OPTARG ;;            # PHP-FPM
        v) vsftpd=$OPTARG ;;            # Vsftpd
        j) proftpd=$OPTARG ;;           # Proftpd
        k) named=$OPTARG ;;             # Named
        m) mysql=$OPTARG ;;             # MariaDB
        d) mysql8=$OPTARG ;;            # MySQL8
        g) postgresql=$OPTARG ;;        # PostgreSQL
        d) mongodb=$OPTARG ;;           # MongoDB (unsupported)
        x) exim=$OPTARG ;;              # Exim
        z) dovecot=$OPTARG ;;           # Dovecot
        c) clamd=$OPTARG ;;             # ClamAV
        t) spamd=$OPTARG ;;             # SpamAssassin
        i) iptables=$OPTARG ;;          # Iptables
        b) fail2ban=$OPTARG ;;          # Fail2ban
        o) softaculous=$OPTARG ;;       # Softaculous plugin
        q) quota=$OPTARG ;;             # FS Quota
        l) lang=$OPTARG ;;              # Language
        y) interactive=$OPTARG ;;       # Interactive install
        s) servername=$OPTARG ;;        # Hostname
        e) email=$OPTARG ;;             # Admin email
        u) secret_url=$OPTARG ;;        # Secret URL for hosting panel
        1) port=$OPTARG ;;              # Vesta port
        p) vpass=$OPTARG ;;             # Admin password
        f) force='yes' ;;               # Force install
        h) help ;;                      # Help
        *) help ;;                      # Print help (default)
    esac
done

# Defining default software stack
set_default_value 'nginx' 'yes'
set_default_value 'apache' 'yes'
set_default_value 'phpfpm' 'no'
set_default_value 'vsftpd' 'no'
set_default_value 'proftpd' 'yes'
set_default_value 'named' 'yes'
set_default_value 'mysql' 'yes'
set_default_value 'mysql8' 'no'
set_default_value 'postgresql' 'no'
set_default_value 'mongodb' 'no'
set_default_value 'exim' 'yes'
set_default_value 'dovecot' 'yes'
if [ $memory -lt 1500000 ]; then
    set_default_value 'clamd' 'no'
    set_default_value 'spamd' 'no'
else
    set_default_value 'clamd' 'yes'
    set_default_value 'spamd' 'yes'
fi
set_default_value 'iptables' 'yes'
set_default_value 'fail2ban' 'yes'
set_default_value 'softaculous' 'no'
set_default_value 'quota' 'no'
set_default_value 'interactive' 'yes'
set_default_lang 'en'

# Checking software conflicts
# if [ "$phpfpm" = 'yes' ]; then
#     apache='no'
#     nginx='yes'
# fi
if [ "$proftpd" = 'yes' ]; then
    vsftpd='no'
fi
if [ "$exim" = 'no' ]; then
    clamd='no'
    spamd='no'
    dovecot='no'
fi
if [ "$iptables" = 'no' ]; then
    fail2ban='no'
fi
if [ "$mysql8" = 'yes' ]; then
    mysql='no'
fi

# Checking root permissions
if [ "x$(id -u)" != 'x0' ]; then
    check_error 1 "Script can be run executed only by root"
fi

# Checking admin user account
if [ ! -z "$(grep ^admin: /etc/passwd)" ] && [ -z "$force" ]; then
    echo 'Please remove admin user account before proceeding.'
    echo 'If you want to do it automatically run installer with -f option:'
    echo -e "Example: bash $0 --force\n"
    check_result 1 "User admin exists"
fi

echo "Updating apt, please wait..."
apt-get update > /dev/null 2>&1

# Checking wget
if [ ! -e '/usr/bin/wget' ]; then
    sudo apt-get -qq -y install wget > /dev/null 2>&1
    check_result $? "Can't install wget"
fi

# Check if gnupg2 is installed
if [ $(dpkg-query -W -f='${Status}' gnupg2 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
    sudo apt-get -qq -y install gnupg2 > /dev/null 2>&1
    check_result $? "Can't install gnupg2"
fi

# Check if apparmor is installed
# This check is borrowed from HestiaCP
if [ $(dpkg-query -W -f='${Status}' apparmor 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
    apparmor='no'
else
    apparmor='yes'
fi

# Checking repository availability
wget -q "apt.myvestacp.com/deb_signing.key" -O /dev/null
check_result $? "No access to Vesta repository"

# Check installed packages
tmpFilePkgs="$(MAKE_TMP_FILE "Packages")" || { ERROR_MESSAGE "Failed to create TMP File. (${tmpFilePkgs})"; }  
dpkg --get-selections > ${tmpFilePkgs}
for pkg in exim4 mysql-server apache2 nginx vesta; do
    if [ ! -z "$(grep $pkg ${tmpFilePkgs})" ]; then
        conflicts="$pkg $conflicts"
    fi
done

if [ ! -z "$conflicts" ] && [[ "$conflicts" = *"exim4"* ]]; then
    echo "=== Removing pre-installed exim4"
    sudo apt-get -qq -y remove --purge exim4 exim4-base exim4-config
    rm -rf /etc/exim4
    conflicts=$(echo "$conflicts" | sed -e "s/exim4//")
    conflicts=$(echo "$conflicts" | sed -e "s/ //")
fi

if [ ! -z "$conflicts" ] && [ -z "$force" ]; then
    echo '!!! !!! !!! !!! !!! !!! !!! !!! !!! !!! !!! !!! !!! !!! !!! !!! !!!'
    echo
    echo 'Following packages are already installed:'
    echo "$conflicts"
    echo
    echo 'It is highly recommended to remove them before proceeding.'
    echo 'If you want to force installation run this script with -f option:'
    echo "Example: bash $0 --force"
    echo
    echo '!!! !!! !!! !!! !!! !!! !!! !!! !!! !!! !!! !!! !!! !!! !!! !!! !!!'
    echo
    check_result 1 "Control Panel should be installed on clean server."
fi


#----------------------------------------------------------#
#                       Brief Info                         #
#----------------------------------------------------------#

# Printing nice ascii aslogo
clear
echo
echo "                __     __        _        "
echo "  _ __ ___  _   \ \   / /__  ___| |_ __ _ "
echo " | '_ \` _ \| | | \ \ / / _ \/ __| __/ _\` |"
echo " | | | | | | |_| |\ V /  __/\__ \ || (_| |"
echo " |_| |_| |_|\__, | \_/ \___||___/\__\__,_|"
echo "            |___/                         "
echo
echo '                                myVesta Control Panel'
echo -e "\n\n"

echo 'Following software will be installed on your system:'

# Web stack
if [ "$nginx" = 'yes' ]; then
    echo '   - nginx Web server'
fi
if [ "$apache" = 'yes' ] && [ "$nginx" = 'no' ] ; then
    echo '   - Apache web server'
fi
if [ "$apache" = 'yes' ] && [ "$nginx"  = 'yes' ] ; then
    echo '   - Apache web server (in very fast mpm_event mode)'
    echo '   - PHP-FPM service for PHP processing'
fi
if [ "$phpfpm"  = 'yes' ]; then
    echo '   - PHP-FPM service for PHP processing'
fi

# DNS stack
if [ "$named" = 'yes' ]; then
    echo '   - Bind9 DNS service'
fi

# Mail Stack
if [ "$exim" = 'yes' ]; then
    echo -n '   - Exim4 mail server'
    if [ "$clamd" = 'yes'  ] ||  [ "$spamd" = 'yes' ] ; then
        if [ "$clamd" = 'yes' ]; then
            echo -n ' + ClamAV antivirus'
        fi
        if [ "$spamd" = 'yes' ]; then
            echo -n ' + SpamAssassin antispam service'
        fi
    fi
    echo
    if [ "$dovecot" = 'yes' ]; then
        echo '   - Dovecot POP3/IMAP service'
    fi
fi

# DB stack
if [ "$mysql" = 'yes' ]; then
    echo '   - MariaDB Database server'
fi
if [ "$mysql8" = 'yes' ]; then
    echo '   - MySQL 8 Database server'
fi
if [ "$postgresql" = 'yes' ]; then
    echo '   - PostgreSQL Database server'
fi
# if [ "$mongodb" = 'yes' ]; then
#    echo '   - MongoDB Database Server'
# fi

# FTP stack
if [ "$vsftpd" = 'yes' ]; then
    echo '   - Vsftpd FTP service'
fi
if [ "$proftpd" = 'yes' ]; then
    echo '   - ProFTPD FTP service'
fi

# Softaculous
if [ "$softaculous" = 'yes' ]; then
    echo '   - Softaculous Plugin'
fi

# Firewall stack
if [ "$iptables" = 'yes' ]; then
    echo -n '   - iptables firewall'
fi
if [ "$iptables" = 'yes' ] && [ "$fail2ban" = 'yes' ]; then
    echo -n ' + Fail2Ban service'
fi
echo -e "\n\n"

# Asking for confirmation to proceed
if [ "$interactive" = 'yes' ]; then
    read -p 'Would you like to continue [y/n]: ' answer
    if [ "$answer" != 'y' ] && [ "$answer" != 'Y'  ]; then
        echo 'Goodbye'
        exit 1
    fi

    # Asking for contact email
    if [ -z "$email" ]; then
        read -p 'Please enter admin email address: ' email
    fi

    # Asking for secret URL
    if [ -z "$secret_url" ]; then
        echo 'Please enter secret URL address for hosting panel (or press enter for none).'
        echo 'Secret URL must be without special characters, just letters and numbers. Example: mysecret8205'
        read -p 'Enter secret URL address: ' secret_url
    fi

    # Asking for Vesta port
    if [ -z "$port" ]; then
        read -p 'Please enter Vesta port number (press enter for 8083): ' port
    fi

    # Asking to set FQDN hostname
    if [ -z "$servername" ]; then
        read -p "Please enter FQDN hostname [$(hostname)]: " servername
    fi
fi

# Generating admin password if it wasn't set
if [ -z "$vpass" ]; then
    vpass=$(gen_pass)
fi

# Set hostname if it wasn't set
if [ -z "$servername" ]; then
    servername=$(hostname -f)
fi

# Set FQDN if it wasn't set
mask1='(([[:alnum:]](-?[[:alnum:]])*)\.)'
mask2='*[[:alnum:]](-?[[:alnum:]])+\.[[:alnum:]]{2,}'
if ! [[ "$servername" =~ ^${mask1}${mask2}$ ]]; then
    if [ ! -z "$servername" ]; then
        servername="$servername.example.com"
    else
        servername="example.com"
    fi
    echo "127.0.0.1 $servername" >> /etc/hosts
fi

# Set email if it wasn't set
if [ -z "$email" ]; then
    email="admin@$servername"
fi

# Set port if it wasn't set
if [ -z "$port" ]; then
    port="8083"
fi

# Defining backup directory
vst_backups="/root/vst_install_backups/$(date +%s)"
echo "Installation backup directory: $vst_backups"

# Printing start message and sleeping for 5 seconds
echo -e "\n\n\n\nInstallation will take about 15 minutes ...\n"


#----------------------------------------------------------#
#                      Checking swap                       #
#----------------------------------------------------------#

if [ -z "$(swapon -s)" ] && [ $memory -lt 1000000 ]; then
    echo "== Checking swap on small instances"
    fallocate -l 1G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo "/swapfile   none    swap    sw    0   0" >> /etc/fstab
fi


#----------------------------------------------------------#
#                   Install repository                     #
#----------------------------------------------------------#

echo "=== Updating system (apt-get -y upgrade)"
sudo apt-get -qq -y upgrade
check_result $? 'apt-get upgrade failed'

echo "=== Installing nginx repo"
aptSourceList="/etc/apt/sources.list.d"
echo "deb http://nginx.org/packages/debian/ $codename nginx" > ${aptSourceList}/nginx.list
wget -q http://nginx.org/keys/nginx_signing.key -O ${myVesta_TMP}/nginx_signing.key
apt-key add ${myVesta_TMP}/nginx_signing.key

echo "=== Installing myVesta repo"
echo "deb http://$RHOST/$codename/ $codename vesta" > ${aptSourceList}/vesta.list
wget -q $CHOST/deb_signing.key -O ${myVesta_TMP}/deb_signing.key
apt-key add ${myVesta_TMP}/deb_signing.key

# Installing jessie backports
if [ "$release" -eq 8 ]; then
    if [ ! -e /etc/apt/apt.conf ]; then
        echo 'Acquire::Check-Valid-Until "false";' >> /etc/apt/apt.conf
    fi
    if [ ! -e /etc/apt/sources.list.d/backports.list ]; then
        echo "deb http://archive.debian.org/debian jessie-backports main" >\
            /etc/apt/sources.list.d/backports.list
    fi
fi


#----------------------------------------------------------#
#                         Backup                           #
#----------------------------------------------------------#

echo "=== Creating backup directory tree"
mkdir -p $vst_backups
cd $vst_backups
mkdir nginx apache2 php php5 php5-fpm vsftpd proftpd bind exim4 dovecot clamd
mkdir spamassassin mysql postgresql mongodb vesta

echo "=== Backing up old configs"
# Backing up Nginx configuration
service nginx stop > /dev/null 2>&1
cp -r /etc/nginx/* $vst_backups/nginx >/dev/null 2>&1

# Backing up Apache configuration
service apache2 stop > /dev/null 2>&1
cp -r /etc/apache2/* $vst_backups/apache2 > /dev/null 2>&1
rm -f /etc/apache2/conf.d/* > /dev/null 2>&1

# Backing up PHP configuration
cp /etc/php.ini $vst_backups/php > /dev/null 2>&1
cp -r /etc/php.d  $vst_backups/php > /dev/null 2>&1

# Backing up PHP configuration
service php5-fpm stop >/dev/null 2>&1
cp /etc/php5/* $vst_backups/php5 > /dev/null 2>&1
rm -f /etc/php5/fpm/pool.d/* >/dev/null 2>&1

# Backing up Bind configuration
service bind9 stop > /dev/null 2>&1
cp -r /etc/bind/* $vst_backups/bind > /dev/null 2>&1

# Backing up Vsftpd configuration
service vsftpd stop > /dev/null 2>&1
cp /etc/vsftpd.conf $vst_backups/vsftpd > /dev/null 2>&1

# Backing up ProFTPD configuration
service proftpd stop > /dev/null 2>&1
cp /etc/proftpd.conf $vst_backups/proftpd >/dev/null 2>&1

# Backing up Exim configuration
service exim4 stop > /dev/null 2>&1
cp -r /etc/exim4/* $vst_backups/exim4 > /dev/null 2>&1

# Backing up ClamAV configuration
service clamav-daemon stop > /dev/null 2>&1
cp -r /etc/clamav/* $vst_backups/clamav > /dev/null 2>&1

# Backing up SpamAssassin configuration
service spamassassin stop > /dev/null 2>&1
cp -r /etc/spamassassin/* $vst_backups/spamassassin > /dev/null 2>&1

# Backing up Dovecot configuration
service dovecot stop > /dev/null 2>&1
cp /etc/dovecot.conf $vst_backups/dovecot > /dev/null 2>&1
cp -r /etc/dovecot/* $vst_backups/dovecot > /dev/null 2>&1

# Backing up MySQL/MariaDB configuration and data
service mysql stop > /dev/null 2>&1
killall -9 mysqld > /dev/null 2>&1
mv /var/lib/mysql $vst_backups/mysql/mysql_datadir > /dev/null 2>&1
cp -r /etc/mysql/* $vst_backups/mysql > /dev/null 2>&1
mv -f /root/.my.cnf $vst_backups/mysql > /dev/null 2>&1

# Backup vesta
service vesta stop > /dev/null 2>&1
cp -r $VESTA/* $vst_backups/vesta > /dev/null 2>&1
apt-get -y remove vesta vesta-nginx vesta-php > /dev/null 2>&1
apt-get -y purge vesta vesta-nginx vesta-php > /dev/null 2>&1
rm -rf $VESTA > /dev/null 2>&1


#----------------------------------------------------------#
#                     Package Excludes                     #
#----------------------------------------------------------#

# Excluding packages
if [ "$nginx" = 'no'  ]; then
    software=$(echo "$software" | sed -e "s/^nginx//")
fi
if [ "$apache" = 'no' ]; then
    software=$(echo "$software" | sed -e "s/apache2 //")
    software=$(echo "$software" | sed -e "s/apache2-utils//")
    software=$(echo "$software" | sed -e "s/apache2-suexec-custom//")
    software=$(echo "$software" | sed -e "s/apache2.2-common//")
    software=$(echo "$software" | sed -e "s/libapache2-mod-ruid2//")
    software=$(echo "$software" | sed -e "s/libapache2-mod-fcgid//")
    software=$(echo "$software" | sed -e "s/libapache2-mod-php5//")
    software=$(echo "$software" | sed -e "s/libapache2-mod-php//")
fi
# if [ "$phpfpm" = 'no' ]; then
    # software=$(echo "$software" | sed -e "s/php5-fpm//")
    # software=$(echo "$software" | sed -e "s/php-fpm//")
# fi
if [ "$vsftpd" = 'no' ]; then
    software=$(echo "$software" | sed -e "s/vsftpd//")
fi
if [ "$proftpd" = 'no' ]; then
    software=$(echo "$software" | sed -e "s/proftpd-basic//")
    software=$(echo "$software" | sed -e "s/proftpd-mod-vroot//")
fi
if [ "$named" = 'no' ]; then
    software=$(echo "$software" | sed -e "s/bind9//")
fi
if [ "$exim" = 'no' ]; then
    software=$(echo "$software" | sed -e "s/exim4 //")
    software=$(echo "$software" | sed -e "s/exim4-daemon-heavy//")
    software=$(echo "$software" | sed -e "s/dovecot-imapd//")
    software=$(echo "$software" | sed -e "s/dovecot-pop3d//")
    software=$(echo "$software" | sed -e "s/clamav-daemon//")
    software=$(echo "$software" | sed -e "s/spamassassin//")
fi
if [ "$clamd" = 'no' ]; then
    software=$(echo "$software" | sed -e "s/clamav-daemon//")
fi
if [ "$spamd" = 'no' ]; then
    software=$(echo "$software" | sed -e "s/spamassassin//")
    software=$(echo "$software" | sed -e "s/libmail-dkim-perl//")
fi
if [ "$dovecot" = 'no' ]; then
    software=$(echo "$software" | sed -e "s/dovecot-imapd//")
    software=$(echo "$software" | sed -e "s/dovecot-pop3d//")
fi
if [ "$mysql" = 'no' ]; then
    software=$(echo "$software" | sed -e 's/mysql-server//')
    software=$(echo "$software" | sed -e 's/mysql-client//')
    software=$(echo "$software" | sed -e 's/mysql-common//')
    software=$(echo "$software" | sed -e 's/mariadb-server//')
    software=$(echo "$software" | sed -e 's/mariadb-client//')
    software=$(echo "$software" | sed -e 's/mariadb-common//')
    software=$(echo "$software" | sed -e 's/php5-mysql//')
    software=$(echo "$software" | sed -e 's/php-mysql//')
    software=$(echo "$software" | sed -e 's/phpMyAdmin//')
    software=$(echo "$software" | sed -e 's/phpmyadmin//')
    software=$(echo "$software" | sed -e 's/roundcube-mysql//')
fi
if [ "$mysql8" = 'yes' ]; then
    echo "=== Preparing MySQL 8 apt repo"
    software=$(echo "$software" | sed -e 's/exim4-daemon-heavy//')
    software=$(echo "$software" | sed -e 's/exim4//')
    #software="$software php-mysql roundcube-mysql"
    echo "### THIS FILE IS AUTOMATICALLY CONFIGURED ###" > /etc/apt/sources.list.d/mysql.list
    echo "# You may comment out entries below, but any other modifications may be lost." >> /etc/apt/sources.list.d/mysql.list
    echo "# Use command 'dpkg-reconfigure mysql-apt-config' as root for modifications." >> /etc/apt/sources.list.d/mysql.list
    echo "deb http://repo.mysql.com/apt/debian/ $codename mysql-apt-config" >> /etc/apt/sources.list.d/mysql.list
    echo "deb http://repo.mysql.com/apt/debian/ $codename mysql-8.0" >> /etc/apt/sources.list.d/mysql.list
    echo "deb http://repo.mysql.com/apt/debian/ $codename mysql-tools" >> /etc/apt/sources.list.d/mysql.list
    echo "#deb http://repo.mysql.com/apt/debian/ $codename mysql-tools-preview" >> /etc/apt/sources.list.d/mysql.list
    echo "deb-src http://repo.mysql.com/apt/debian/ $codename mysql-8.0" >> /etc/apt/sources.list.d/mysql.list

    # apt-key adv --keyserver pgp.mit.edu --recv-keys 3A79BD29
    key="467B942D3A79BD29"
    readonly key
    GNUPGHOME="$(mktemp -d)"
    export GNUPGHOME
    for keyserver in $(shuf -e ha.pool.sks-keyservers.net hkp://p80.pool.sks-keyservers.net:80 keyserver.ubuntu.com hkp://keyserver.ubuntu.com:80)
    do
        gpg --keyserver "${keyserver}" --recv-keys "${key}" 2>&1 && break
    done
    gpg --export "${key}" > /etc/apt/trusted.gpg.d/mysql.gpg
    gpgconf --kill all
    rm -rf "${GNUPGHOME}"
    unset GNUPGHOME
    
    mpass=$(gen_pass)
    debconf-set-selections <<< "mysql-community-server mysql-community-server/root-pass password $mpass"
    debconf-set-selections <<< "mysql-community-server mysql-community-server/re-root-pass password $mpass"
    debconf-set-selections <<< "mysql-community-server mysql-server/default-auth-override select Use Legacy Authentication Method (Retain MySQL 5.x Compatibility)"
fi
if [ "$postgresql" = 'no' ]; then
    software=$(echo "$software" | sed -e 's/postgresql-contrib//')
    software=$(echo "$software" | sed -e 's/postgresql//')
    software=$(echo "$software" | sed -e 's/php5-pgsql//')
    software=$(echo "$software" | sed -e 's/php-pgsql//')
    software=$(echo "$software" | sed -e 's/phppgadmin//')
fi
if [ "$softaculous" = 'no' ]; then
    software=$(echo "$software" | sed -e 's/vesta-softaculous//')
fi
if [ "$iptables" = 'no' ] || [ "$fail2ban" = 'no' ]; then
    software=$(echo "$software" | sed -e 's/fail2ban//')
fi


#----------------------------------------------------------#
#                     Install packages                     #
#----------------------------------------------------------#

MAKE_CONFIG_FILE "Break Break RHOST CHOST VERSION VESTA memory arch os release codename vestacp nginx apache phpfpm vsftpd proftpd named mysql mysql8 postgresql mongodb exim dovecot clamd spamd iptables fail2ban softaculous quota interactive lang apparmor break break break software mpass vpass" "N"
 
 
# Update system packages
echo "=== Running: apt-get update"
sudo apt-get -qq update

echo "=== Disable daemon autostart /usr/share/doc/sysv-rc/README.policy-rc.d.gz"
echo -e '#!/bin/sh \nexit 101' > /usr/sbin/policy-rc.d
chmod a+x /usr/sbin/policy-rc.d

if [ "$mysql8" = 'yes' ]; then
    echo "=== Installing MySQL 8"
    apt-get -y install mysql-server mysql-client mysql-common
    #update-rc.d mysql defaults
    currentservice='mysql'
    ensure_startup $currentservice
    ensure_start $currentservice
    echo -e "[client]\npassword='$mpass'\n" > /root/.my.cnf
    chmod 600 /root/.my.cnf
    mysqladmin -u root password $mpass
fi

echo "=== Installing all apt packages"
# echo "apt-get -y install $software"
#apt-get -y install $software
sudo apt-get -qq -y install $software
check_result $? "apt-get install failed"

if [ "$mysql8" = 'yes' ]; then
    if [ "$exim" = 'yes' ]; then
        echo "=== Installing exim4"
        apt-get -y install exim4 exim4-daemon-heavy
    fi
    echo "=== Installing phpmyadmin"
    #apt-get -y --no-install-recommends install phpmyadmin
    apt-get -y install phpmyadmin
fi

echo "=== Enabling daemon autostart"
rm -f /usr/sbin/policy-rc.d


#----------------------------------------------------------#
#                     Configure system                     #
#----------------------------------------------------------#

echo "== Enable SSH password auth"
sed -i "s/rdAuthentication no/rdAuthentication yes/g" /etc/ssh/sshd_config
systemctl restart ssh

echo "== Disable awstats cron"
rm -f /etc/cron.d/awstats

echo "== Set directory color"
echo 'LS_COLORS="$LS_COLORS:di=00;33"' >> /etc/profile

echo "== Register /sbin/nologin and /usr/sbin/nologin"
echo "/sbin/nologin" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells

echo "== NTP Synchronization"
echo '#!/bin/sh' > /etc/cron.daily/ntpdate
echo "$(which ntpdate) -s pool.ntp.org" >> /etc/cron.daily/ntpdate
chmod 775 /etc/cron.daily/ntpdate
ntpdate -s pool.ntp.org

if [ "$release" -eq 9 ]; then
  # Setup rssh
  if [ -z "$(grep /usr/bin/rssh /etc/shells)" ]; then
      echo /usr/bin/rssh >> /etc/shells
  fi
  sed -i 's/#allowscp/allowscp/' /etc/rssh.conf
  sed -i 's/#allowsftp/allowsftp/' /etc/rssh.conf
  sed -i 's/#allowrsync/allowrsync/' /etc/rssh.conf
  chmod 755 /usr/bin/rssh
fi

#----------------------------------------------------------#
#                     Configure VESTA                      #
#----------------------------------------------------------#

    ### Installing SUDO Configuration
    echo "== Installing SUDO Configuration"
    
    ### Create sudoers.d Directory
    [[ ! -d "/etc/sudoers.d" ]] && mkdir /etc/sudoers.d && chmod 750 /etc/sudoers.d
      
    ### Include sudoers.d Directory
    [[ -z "$(grep "includedir /etc/sudoers.d" /etc/sudoers)" ]] && echo -e "\n#includedir /etc/sudoers.d" >> /etc/sudoers
        
    ### Remove admin if Exist
    [[ -e "/etc/sudoers.d/${myVesta_Root}" ]] && rm -f /etc/sudoers.d/${myVesta_Root}
        
    ### Create Sudo for admin
    printf '%s\n' \
      "### Created by myVestaCP Installer" \
      "Defaults env_keep=\"VESTA\"" \
      "Defaults:${myVesta_Root} !syslog" \
      "Defaults:${myVesta_Root} !requiretty" \
      "Defaults:root !requiretty " \
      "" \
      "### Limit Sudo to myVestaCP Scripts" \
      "${myVesta_Root}   ALL=NOPASSWD:/usr/local/vesta/bin/*" > /etc/sudoers.d/${myVesta_Root}
              
    ### Set Permissons
    chmod 440 /etc/sudoers.d/${myVesta_Root}



    echo "== Configuring system env"
    ### DOUBLE CHECK
    #echo "export VESTA='$VESTA'" > /etc/profile.d/vesta.sh
    echo "export VESTA=\"${VESTA}\"" > /etc/profile.d/vesta.sh
    chmod 755 /etc/profile.d/vesta.sh
    source /etc/profile.d/vesta.sh
    
    
echo 'PATH=$PATH:'$VESTA'/bin' >> /root/.bash_profile
echo 'export PATH' >> /root/.bash_profile
source /root/.bash_profile

echo "== Copying logrotate for myVesta logs"
cp -f $vestacp/logrotate/vesta /etc/logrotate.d/

echo "== Building directory tree and creating some blank files for myVesta"
mkdir -p $VESTA/conf $VESTA/log $VESTA/ssl $VESTA/data/ips \
    $VESTA/data/queue $VESTA/data/users $VESTA/data/firewall \
    $VESTA/data/sessions
touch $VESTA/data/queue/backup.pipe $VESTA/data/queue/disk.pipe \
    $VESTA/data/queue/webstats.pipe $VESTA/data/queue/restart.pipe \
    $VESTA/data/queue/traffic.pipe $VESTA/log/system.log \
    $VESTA/log/nginx-error.log $VESTA/log/auth.log
chmod 750 $VESTA/conf $VESTA/data/users $VESTA/data/ips $VESTA/log
chmod -R 750 $VESTA/data/queue
chmod 660 $VESTA/log/*
rm -f /var/log/vesta
ln -s $VESTA/log /var/log/vesta
chmod 770 $VESTA/data/sessions

echo "== Generating vesta.conf"
rm -f $VESTA/conf/vesta.conf 2>/dev/null
touch $VESTA/conf/vesta.conf
chmod 660 $VESTA/conf/vesta.conf

# WEB stack
if [ "$apache" = 'yes' ] && [ "$nginx" = 'no' ] ; then
    echo "WEB_SYSTEM='apache2'" >> $VESTA/conf/vesta.conf
    echo "WEB_RGROUPS='www-data'" >> $VESTA/conf/vesta.conf
    echo "WEB_PORT='80'" >> $VESTA/conf/vesta.conf
    echo "WEB_SSL_PORT='443'" >> $VESTA/conf/vesta.conf
    echo "WEB_SSL='mod_ssl'"  >> $VESTA/conf/vesta.conf
    echo "STATS_SYSTEM='webalizer,awstats'" >> $VESTA/conf/vesta.conf
fi
if [ "$apache" = 'yes' ] && [ "$nginx"  = 'yes' ] ; then
    echo "WEB_SYSTEM='apache2'" >> $VESTA/conf/vesta.conf
    echo "WEB_RGROUPS='www-data'" >> $VESTA/conf/vesta.conf
    echo "WEB_PORT='8080'" >> $VESTA/conf/vesta.conf
    echo "WEB_SSL_PORT='8443'" >> $VESTA/conf/vesta.conf
    echo "WEB_SSL='mod_ssl'"  >> $VESTA/conf/vesta.conf
    echo "PROXY_SYSTEM='nginx'" >> $VESTA/conf/vesta.conf
    echo "PROXY_PORT='80'" >> $VESTA/conf/vesta.conf
    echo "PROXY_SSL_PORT='443'" >> $VESTA/conf/vesta.conf
    echo "STATS_SYSTEM='webalizer,awstats'" >> $VESTA/conf/vesta.conf
fi
if [ "$apache" = 'no' ] && [ "$nginx"  = 'yes' ]; then
    echo "WEB_SYSTEM='nginx'" >> $VESTA/conf/vesta.conf
    echo "WEB_PORT='80'" >> $VESTA/conf/vesta.conf
    echo "WEB_SSL_PORT='443'" >> $VESTA/conf/vesta.conf
    echo "WEB_SSL='openssl'"  >> $VESTA/conf/vesta.conf
    if [ "$release" -eq 9 ] || [ "$release" -eq 10 ] || [ "$release" -eq 11 ]; then
        if [ "$phpfpm" = 'yes' ]; then
            echo "WEB_BACKEND='php-fpm'" >> $VESTA/conf/vesta.conf
        fi
    else
        if [ "$phpfpm" = 'yes' ]; then
            echo "WEB_BACKEND='php5-fpm'" >> $VESTA/conf/vesta.conf
        fi
    fi
    echo "STATS_SYSTEM='webalizer,awstats'" >> $VESTA/conf/vesta.conf
fi

# FTP stack
if [ "$vsftpd" = 'yes' ]; then
    echo "FTP_SYSTEM='vsftpd'" >> $VESTA/conf/vesta.conf
fi
if [ "$proftpd" = 'yes' ]; then
    echo "FTP_SYSTEM='proftpd'" >> $VESTA/conf/vesta.conf
fi

# DNS stack
if [ "$named" = 'yes' ]; then
    echo "DNS_SYSTEM='bind9'" >> $VESTA/conf/vesta.conf
fi

# Mail stack
if [ "$exim" = 'yes' ]; then
    echo "MAIL_SYSTEM='exim4'" >> $VESTA/conf/vesta.conf
    if [ "$clamd" = 'yes'  ]; then
        echo "ANTIVIRUS_SYSTEM='clamav-daemon'" >> $VESTA/conf/vesta.conf
    fi
    if [ "$spamd" = 'yes' ]; then
        echo "ANTISPAM_SYSTEM='spamassassin'" >> $VESTA/conf/vesta.conf
    fi
    if [ "$dovecot" = 'yes' ]; then
        echo "IMAP_SYSTEM='dovecot'" >> $VESTA/conf/vesta.conf
    fi
fi

# CRON daemon
echo "CRON_SYSTEM='cron'" >> $VESTA/conf/vesta.conf

# Firewall stack
if [ "$iptables" = 'yes' ]; then
    echo "FIREWALL_SYSTEM='iptables'" >> $VESTA/conf/vesta.conf
fi
if [ "$iptables" = 'yes' ] && [ "$fail2ban" = 'yes' ]; then
    echo "FIREWALL_EXTENSION='fail2ban'" >> $VESTA/conf/vesta.conf
fi

# Disk quota
if [ "$quota" = 'yes' ]; then
    echo "DISK_QUOTA='yes'" >> $VESTA/conf/vesta.conf
fi

# Backups
echo "BACKUP_SYSTEM='local'" >> $VESTA/conf/vesta.conf

# Language
echo "LANGUAGE='$lang'" >> $VESTA/conf/vesta.conf

# Version
echo "VERSION='0.9.8'" >> $VESTA/conf/vesta.conf

echo "== Copying packages"
cp -rf $vestacp/packages $VESTA/data/

echo "== Copying templates"
cp -rf $vestacp/templates $VESTA/data/

if [ "$release" -eq 10 ]; then
    echo "== Symlink missing templates"
    ln -s /usr/local/vesta/data/templates/web/nginx/hosting.sh /usr/local/vesta/data/templates/web/nginx/default.sh
    ln -s /usr/local/vesta/data/templates/web/nginx/hosting.tpl /usr/local/vesta/data/templates/web/nginx/default.tpl
    ln -s /usr/local/vesta/data/templates/web/nginx/hosting.stpl /usr/local/vesta/data/templates/web/nginx/default.stpl

    ln -s /usr/local/vesta/data/templates/web/apache2/PHP-FPM-73.sh /usr/local/vesta/data/templates/web/apache2/hosting.sh
    ln -s /usr/local/vesta/data/templates/web/apache2/PHP-FPM-73.tpl /usr/local/vesta/data/templates/web/apache2/hosting.tpl
    ln -s /usr/local/vesta/data/templates/web/apache2/PHP-FPM-73.stpl /usr/local/vesta/data/templates/web/apache2/hosting.stpl
    ln -s /usr/local/vesta/data/templates/web/apache2/PHP-FPM-73.sh /usr/local/vesta/data/templates/web/apache2/default.sh
    ln -s /usr/local/vesta/data/templates/web/apache2/PHP-FPM-73.tpl /usr/local/vesta/data/templates/web/apache2/default.tpl
    ln -s /usr/local/vesta/data/templates/web/apache2/PHP-FPM-73.stpl /usr/local/vesta/data/templates/web/apache2/default.stpl
    
    ln  -s /usr/local/vesta/data/templates/web/nginx/php-fpm/default.stpl /usr/local/vesta/data/templates/web/nginx/php-fpm/PHP-FPM-73.stpl
    ln  -s /usr/local/vesta/data/templates/web/nginx/php-fpm/default.tpl /usr/local/vesta/data/templates/web/nginx/php-fpm/PHP-FPM-73.tpl
fi
if [ "$release" -eq 11 ]; then
    echo "== Symlink missing templates"
    ln -s /usr/local/vesta/data/templates/web/nginx/hosting.sh /usr/local/vesta/data/templates/web/nginx/default.sh
    ln -s /usr/local/vesta/data/templates/web/nginx/hosting.tpl /usr/local/vesta/data/templates/web/nginx/default.tpl
    ln -s /usr/local/vesta/data/templates/web/nginx/hosting.stpl /usr/local/vesta/data/templates/web/nginx/default.stpl

    ln -s /usr/local/vesta/data/templates/web/apache2/PHP-FPM-74.sh /usr/local/vesta/data/templates/web/apache2/hosting.sh
    ln -s /usr/local/vesta/data/templates/web/apache2/PHP-FPM-74.tpl /usr/local/vesta/data/templates/web/apache2/hosting.tpl
    ln -s /usr/local/vesta/data/templates/web/apache2/PHP-FPM-74.stpl /usr/local/vesta/data/templates/web/apache2/hosting.stpl
    ln -s /usr/local/vesta/data/templates/web/apache2/PHP-FPM-74.sh /usr/local/vesta/data/templates/web/apache2/default.sh
    ln -s /usr/local/vesta/data/templates/web/apache2/PHP-FPM-74.tpl /usr/local/vesta/data/templates/web/apache2/default.tpl
    ln -s /usr/local/vesta/data/templates/web/apache2/PHP-FPM-74.stpl /usr/local/vesta/data/templates/web/apache2/default.stpl
    
    ln  -s /usr/local/vesta/data/templates/web/nginx/php-fpm/default.stpl /usr/local/vesta/data/templates/web/nginx/php-fpm/PHP-FPM-74.stpl
    ln  -s /usr/local/vesta/data/templates/web/nginx/php-fpm/default.tpl /usr/local/vesta/data/templates/web/nginx/php-fpm/PHP-FPM-74.tpl
fi

echo "== Set nameservers address"
sed -i "s/YOURHOSTNAME1/ns1.${myVesta_User_Domain}/" /usr/local/vesta/data/packages/default.pkg
sed -i "s/YOURHOSTNAME2/ns2.${myVesta_User_Domain}/" /usr/local/vesta/data/packages/default.pkg
sed -i "s/ns1.domain.tld/ns1.${myVesta_User_Domain}/" /usr/local/vesta/data/packages/default.pkg
sed -i "s/ns2.domain.tld/ns2.${myVesta_User_Domain}/" /usr/local/vesta/data/packages/default.pkg
sed -i "s/ns1.example.com/ns1.${myVesta_User_Domain}/" /usr/local/vesta/data/packages/default.pkg
sed -i "s/ns2.example.com/ns2.${myVesta_User_Domain}/" /usr/local/vesta/data/packages/default.pkg

echo "== Copying index.html to default documentroot"
cp $VESTA/data/templates/web/skel/public_html/index.html /var/www/
sed -i 's/%domain%/It worked!/g' /var/www/index.html

echo "== Copying Firewall Ports"
#cp -rf $vestacp/firewall $VESTA/data/
cp -f ${myVesta_INSTALL_DIR}/firewall/ports.conf $VESTA/data/firewall/

 ##### Adding Firewall Rules
  echo "== Adding Firewall Rules"
    ${myVesta_BIN}/v-add-firewall-rule "ACCEPT" "0.0.0.0/0" "0" "ICMP" "PING" "1"
    ${myVesta_BIN}/v-add-firewall-rule "ACCEPT" "0.0.0.0/0" "8083" "TCP" "VESTA" "2"
    ${myVesta_BIN}/v-add-firewall-rule "ACCEPT" "0.0.0.0/0" "3306,5432" "TCP" "DB" "3"
      ${myVesta_BIN}/v-suspend-firewall-rule "3"
    ${myVesta_BIN}/v-add-firewall-rule "ACCEPT" "0.0.0.0/0" "143,993" "TCP" "IMAP" "4"
    ${myVesta_BIN}/v-add-firewall-rule "ACCEPT" "0.0.0.0/0" "110,995" "TCP" "POP3" "5"
    ${myVesta_BIN}/v-add-firewall-rule "ACCEPT" "0.0.0.0/0" "25,465,587,2525" "TCP" "SMTP" "6"
    ${myVesta_BIN}/v-add-firewall-rule "ACCEPT" "0.0.0.0/0" "53" "TCP" "DNS" "7"
    ${myVesta_BIN}/v-add-firewall-rule "ACCEPT" "0.0.0.0/0" "53" "UDP" "DNS" "8"
    ${myVesta_BIN}/v-add-firewall-rule "ACCEPT" "0.0.0.0/0" "21,12000-12100" "TCP" "FTP" "9"
    ${myVesta_BIN}/v-add-firewall-rule "ACCEPT" "0.0.0.0/0" "80,443" "TCP" "WEB" "10"
    ${myVesta_BIN}/v-add-firewall-rule "ACCEPT" "0.0.0.0/0" "22" "TCP" "SSH" "11"


echo "== Configuring server hostname: $servername"
${myVesta_BIN}/v-change-sys-hostname "${servername}" 2>/dev/null

  ##### Generating unsigned SSL certificate for myVesta
  echo "== Generating unsigned SSL certificate for myVesta."
  ${myVesta_BIN}/v-generate-ssl-cert "$(hostname)" "${email}" "US" "California" "San Francisco" "Vesta Control Panel" "IT" > ${myVesta_TMP}/vst.pem

    ### Parsing Certificate File
    crt_end=$(grep -n "END CERTIFICATE-" ${myVesta_TMP}/vst.pem |cut -f 1 -d:)
    key_start=$(grep -n "BEGIN RSA" ${myVesta_TMP}/vst.pem |cut -f 1 -d:)
    key_end=$(grep -n  "END RSA" ${myVesta_TMP}/vst.pem |cut -f 1 -d:)

        ### Copy Certificate File
        sed -n "1,${crt_end}p" ${myVesta_TMP}/vst.pem > ${myVesta_DIR}/ssl/certificate.crt
        sed -n "${key_start},${key_end}p" ${myVesta_TMP}/vst.pem > ${myVesta_DIR}/ssl/certificate.key
        chown root:mail ${myVesta_DIR}/ssl/*
        chmod 660 ${myVesta_DIR}/ssl/*

#----------------------------------------------------------#
#                     Configure Nginx                      #
#----------------------------------------------------------#

if [ "$nginx" = 'yes' ]; then
    echo "=== Configure nginx"
    rm -f /etc/nginx/conf.d/*.conf
    cp -f $vestacp/nginx/nginx.conf /etc/nginx/
    cp -f $vestacp/nginx/status.conf /etc/nginx/conf.d/
    cp -f $vestacp/nginx/phpmyadmin.inc /etc/nginx/conf.d/
    cp -f $vestacp/nginx/phppgadmin.inc /etc/nginx/conf.d/
    cp -f $vestacp/nginx/webmail.inc /etc/nginx/conf.d/
    cp -f $vestacp/logrotate/nginx /etc/logrotate.d/
    echo > /etc/nginx/conf.d/vesta.conf
    mkdir -p /var/log/nginx/domains
    #update-rc.d nginx defaults
    #service nginx start
    currentservice='nginx'
    ensure_startup $currentservice
    ensure_start $currentservice
fi


#----------------------------------------------------------#
#                    Configure Apache                      #
#----------------------------------------------------------#

if [ "$apache" = 'yes'  ]; then
    echo "=== Configure Apache"
    cp -f $vestacp/apache2/apache2.conf /etc/apache2/
    cp -f $vestacp/apache2/status.conf /etc/apache2/mods-enabled/
    cp -f  $vestacp/logrotate/apache2 /etc/logrotate.d/
    a2enmod rewrite
    # a2enmod suexec
    a2enmod ssl
    a2enmod actions
    # a2enmod ruid2
    a2enmod headers
    a2enmod expires
    a2enmod proxy_fcgi setenvif
    mkdir -p /etc/apache2/conf.d
    echo > /etc/apache2/conf.d/vesta.conf
    echo "# Powered by vesta" > /etc/apache2/sites-available/default
    echo "# Powered by vesta" > /etc/apache2/sites-available/default-ssl
    echo "# Powered by vesta" > /etc/apache2/ports.conf
    # echo -e "/home\npublic_html/cgi-bin" > /etc/apache2/suexec/www-data
    touch /var/log/apache2/access.log /var/log/apache2/error.log
    mkdir -p /var/log/apache2/domains
    chmod a+x /var/log/apache2
    chmod 640 /var/log/apache2/access.log /var/log/apache2/error.log
    chmod 751 /var/log/apache2/domains
    #update-rc.d apache2 defaults
    #service apache2 start
    currentservice='apache2'
    ensure_startup $currentservice
    ensure_start $currentservice
else
    #update-rc.d apache2 disable >/dev/null 2>&1
    #service apache2 stop >/dev/null 2>&1
    systemctl disable apache2
    systemctl stop apache2
fi


#----------------------------------------------------------#
#                     Configure PHP-FPM                    #
#----------------------------------------------------------#

if [ "$phpfpm" = 'yes' ]; then
    echo "=== Configure PHP-FPM"
    if [ "$release" -eq 11 ]; then
        cp -f $vestacp/php-fpm/www.conf /etc/php/7.4/fpm/pool.d/www.conf
        #update-rc.d php7.4-fpm defaults
        currentservice='php7.4-fpm'
        ensure_startup $currentservice
        ensure_start $currentservice
    elif [ "$release" -eq 10 ]; then
        cp -f $vestacp/php-fpm/www.conf /etc/php/7.3/fpm/pool.d/www.conf
        #update-rc.d php7.3-fpm defaults
        currentservice='php7.3-fpm'
        ensure_startup $currentservice
        ensure_start $currentservice
    elif [ "$release" -eq 9 ]; then
        cp -f $vestacp/php-fpm/www.conf /etc/php/7.0/fpm/pool.d/www.conf
        #update-rc.d php7.0-fpm defaults
        currentservice='php7.0-fpm'
        ensure_startup $currentservice
        ensure_start $currentservice
    else
        cp -f $vestacp/php5-fpm/www.conf /etc/php5/fpm/pool.d/www.conf
        #update-rc.d php5-fpm defaults
        currentservice='php5-fpm'
        ensure_startup $currentservice
        ensure_start $currentservice
    fi
fi


#----------------------------------------------------------#
#                     Configure PHP                        #
#----------------------------------------------------------#

echo "=== Configure PHP timezone"
ZONE=$(timedatectl 2>/dev/null|grep Timezone|awk '{print $2}')
if [ -z "$ZONE" ]; then
    ZONE='UTC'
fi
for pconf in $(find /etc/php* -name php.ini); do
    sed -i "s/;date.timezone =/date.timezone = $ZONE/g" $pconf
    # sed -i 's%_open_tag = Off%_open_tag = On%g' $pconf
done


#----------------------------------------------------------#
#                    Configure VSFTPD                      #
#----------------------------------------------------------#

if [ "$vsftpd" = 'yes' ]; then
    echo "=== Configure VSFTPD"
    cp -f $vestacp/vsftpd/vsftpd.conf /etc/
    #update-rc.d vsftpd defaults
    currentservice='vsftpd'
    ensure_startup $currentservice
    ensure_start $currentservice

    # To be deleted after release 0.9.8-18
    echo "/sbin/nologin" >> /etc/shells
fi


#----------------------------------------------------------#
#                    Configure ProFTPD                     #
#----------------------------------------------------------#

if [ "$proftpd" = 'yes' ]; then
    echo "=== Configure ProFTPD"
    echo "127.0.0.1 $servername" >> /etc/hosts
    cp -f $vestacp/proftpd/proftpd.conf /etc/proftpd/
    cp -f $vestacp/proftpd/tls.conf /etc/proftpd/
    #update-rc.d proftpd defaults
    currentservice='proftpd'
    ensure_startup $currentservice
    ensure_start $currentservice
fi


#----------------------------------------------------------#
#                  Configure MySQL/MariaDB                 #
#----------------------------------------------------------#

if [ "$mysql" = 'yes' ] || [ "$mysql8" = 'yes' ]; then

    if [ "$mysql" = 'yes' ]; then
        touch $VESTA/conf/mariadb_installed
    fi
    if [ "$mysql8" = 'yes' ]; then
        touch $VESTA/conf/mysql8_installed
    fi

    if [ "$mysql" = 'yes' ]; then
        echo "=== Configure MariaDB"
        mycnf="my-small.cnf"
        if [ $memory -gt 1200000 ]; then
            mycnf="my-medium.cnf"
        fi
        if [ $memory -gt 3900000 ]; then
            mycnf="my-large.cnf"
        fi

        # MySQL configuration
        cp -f $vestacp/mysql/$mycnf /etc/mysql/my.cnf
        mysql_install_db
        # update-rc.d mysql defaults
        currentservice='mysql'
        ensure_startup $currentservice
        ensure_start $currentservice

        # Securing MySQL installation
        mpass=$(gen_pass)
        mysqladmin -u root password $mpass
        echo -e "[client]\npassword='$mpass'\n" > /root/.my.cnf
        chmod 600 /root/.my.cnf
        mysql -e "DELETE FROM mysql.user WHERE User=''"
        mysql -e "DROP DATABASE test" >/dev/null 2>&1
        mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%'"
        mysql -e "DELETE FROM mysql.user WHERE user='' or password='';"
        mysql -e "FLUSH PRIVILEGES"
    fi

    # Configuring phpMyAdmin
    echo "=== Configure phpMyAdmin"
    if [ "$release" -eq 10 ]; then
        mkdir /etc/phpmyadmin
        mkdir -p /var/lib/phpmyadmin/tmp
    fi
    if [ "$apache" = 'yes' ]; then
        cp -f $vestacp/pma/apache.conf /etc/phpmyadmin/
        ln -s /etc/phpmyadmin/apache.conf /etc/apache2/conf.d/phpmyadmin.conf
    fi
    cp -f $vestacp/pma/config.inc.php /etc/phpmyadmin/
    chmod 777 /var/lib/phpmyadmin/tmp
    if [ "$release" -eq 10 ]; then
      # Code borrowed from HestiaCP
      mkdir /root/phpmyadmin
      mkdir /usr/share/phpmyadmin
      
      pma_v='4.9.7'
      echo "=== Installing phpMyAdmin version v$pma_v (Debian10 custom part)"

      cd /root/phpmyadmin

      # Download latest phpmyadmin release
      wget -nv -O phpMyAdmin-$pma_v-all-languages.tar.gz https://files.phpmyadmin.net/phpMyAdmin/$pma_v/phpMyAdmin-$pma_v-all-languages.tar.gz

      # Unpack files
      tar xzf phpMyAdmin-$pma_v-all-languages.tar.gz

      # Delete file to prevent error
      rm -fr /usr/share/phpmyadmin/doc/html

      # Overwrite old files
      cp -rf phpMyAdmin-$pma_v-all-languages/* /usr/share/phpmyadmin

      # Set config and log directory
      sed -i "s|define('CONFIG_DIR', '');|define('CONFIG_DIR', '/etc/phpmyadmin/');|" /usr/share/phpmyadmin/libraries/vendor_config.php
      sed -i "s|define('TEMP_DIR', './tmp/');|define('TEMP_DIR', '/var/lib/phpmyadmin/tmp/');|" /usr/share/phpmyadmin/libraries/vendor_config.php

      # Create temporary folder and change permission
      mkdir /usr/share/phpmyadmin/tmp
      chmod 777 /usr/share/phpmyadmin/tmp

      # Clear Up
      rm -fr phpMyAdmin-$pma_v-all-languages
      rm -f phpMyAdmin-$pma_v-all-languages.tar.gz
      
      wget -nv -O /root/phpmyadmin/pma.sh http://c.myvestacp.com/debian/10/pma/pma.sh 
      wget -nv -O /root/phpmyadmin/create_tables.sql http://c.myvestacp.com/debian/10/pma/create_tables.sql
      bash /root/phpmyadmin/pma.sh
      blowfish=$(gen_pass)
      echo "\$cfg['blowfish_secret'] = '$blowfish';" >> /etc/phpmyadmin/config.inc.php
  fi
  if [ "$release" -eq 11 ]; then
      echo "=== Configure phpMyAdmin (Debian11 custom part)"
      # Set config and log directory
      sed -i "s|define('CONFIG_DIR', '');|define('CONFIG_DIR', '/etc/phpmyadmin/');|" /usr/share/phpmyadmin/libraries/vendor_config.php
      sed -i "s|define('TEMP_DIR', './tmp/');|define('TEMP_DIR', '/var/lib/phpmyadmin/tmp/');|" /usr/share/phpmyadmin/libraries/vendor_config.php

      # Create temporary folder and change permission
      mkdir /usr/share/phpmyadmin/tmp
      chmod 777 /usr/share/phpmyadmin/tmp

      mkdir /root/phpmyadmin
      wget -nv -O /root/phpmyadmin/pma.sh http://c.myvestacp.com/debian/11/pma/pma.sh 
      wget -nv -O /root/phpmyadmin/create_tables.sql http://c.myvestacp.com/debian/11/pma/create_tables.sql
      bash /root/phpmyadmin/pma.sh
      blowfish=$(gen_pass)
      echo "\$cfg['blowfish_secret'] = '$blowfish';" >> /etc/phpmyadmin/config.inc.php
  fi
fi

#----------------------------------------------------------#
#                   Configure PostgreSQL                   #
#----------------------------------------------------------#

if [ "$postgresql" = 'yes' ]; then
    echo "=== Configure PostgreSQL"
    ppass=$(gen_pass)
    cp -f $vestacp/postgresql/pg_hba.conf /etc/postgresql/*/main/
    currentservice='postgresql'
    ensure_startup $currentservice
    ensure_start $currentservice
    sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD '$ppass'"

    # Configuring phpPgAdmin
    if [ "$apache" = 'yes' ]; then
        cp -f $vestacp/pga/phppgadmin.conf /etc/apache2/conf.d/
    fi
    cp -f $vestacp/pga/config.inc.php /etc/phppgadmin/
fi


#----------------------------------------------------------#
#                      Configure Bind                      #
#----------------------------------------------------------#

if [ "$named" = 'yes' ]; then
    echo "=== Configure Bind9"
    cp -f $vestacp/bind/named.conf /etc/bind/
    sed -i "s%listen-on%//listen%" /etc/bind/named.conf.options
    chown root:bind /etc/bind/named.conf
    chmod 640 /etc/bind/named.conf
    aa-complain /usr/sbin/named 2>/dev/null
    if [ "$apparmor" = 'yes' ]; then
      # echo "/home/** rwm," >> /etc/apparmor.d/local/usr.sbin.named 2>/dev/null
      sed -i "s#/etc/bind/\*\* rw,#/etc/bind/\*\* rw,\n  /home/\*\* rwm,#g" /etc/apparmor.d/usr.sbin.named
      sed -i "s#/etc/bind/\*\* r,#/etc/bind/\*\* rw,\n  /home/\*\* rwm,#g" /etc/apparmor.d/usr.sbin.named
      # service apparmor status >/dev/null 2>&1
      # if [ $? -ne 0 ]; then
          service apparmor restart
      # fi
    fi
    # update-rc.d bind9 defaults
    currentservice='bind9'
    ensure_startup $currentservice
    ensure_start $currentservice
fi

#----------------------------------------------------------#
#                      Configure Exim                      #
#----------------------------------------------------------#

if [ "$exim" = 'yes' ]; then
    echo "=== Configure Exim"
    gpasswd -a Debian-exim mail
    cp -f $vestacp/exim/exim4.conf.template /etc/exim4/
    cp -f $vestacp/exim/dnsbl.conf /etc/exim4/
    cp -f $vestacp/exim/spam-blocks.conf /etc/exim4/
    cp -f $vestacp/exim/deny_senders /etc/exim4/
    touch /etc/exim4/white-blocks.conf

    if [ "$spamd" = 'yes' ]; then
        sed -i "s/#SPAM/SPAM/g" /etc/exim4/exim4.conf.template
    fi
    if [ "$clamd" = 'yes' ]; then
        sed -i "s/#CLAMD/CLAMD/g" /etc/exim4/exim4.conf.template
    fi

    chmod 640 /etc/exim4/exim4.conf.template
    rm -rf /etc/exim4/domains
    mkdir -p /etc/exim4/domains

    rm -f /etc/alternatives/mta
    ln -s /usr/sbin/exim4 /etc/alternatives/mta
    update-rc.d -f sendmail remove > /dev/null 2>&1
    service sendmail stop > /dev/null 2>&1
    update-rc.d -f postfix remove > /dev/null 2>&1
    service postfix stop > /dev/null 2>&1

    #update-rc.d exim4 defaults
    currentservice='exim4'
    ensure_startup $currentservice
    ensure_start $currentservice
fi


#----------------------------------------------------------#
#                     Configure Dovecot                    #
#----------------------------------------------------------#

if [ "$dovecot" = 'yes' ]; then
    echo "=== Configure Dovecot"
    gpasswd -a dovecot mail
    cp -rf $vestacp/dovecot /etc/
    cp -f $vestacp/logrotate/dovecot /etc/logrotate.d/
    chown -R root:root /etc/dovecot*
    # update-rc.d dovecot defaults
    currentservice='dovecot'
    ensure_startup $currentservice
    ensure_start $currentservice
fi


#----------------------------------------------------------#
#                     Configure ClamAV                     #
#----------------------------------------------------------#

if [ "$clamd" = 'yes' ]; then
    echo "=== Configure ClamAV"
    gpasswd -a clamav mail
    gpasswd -a clamav Debian-exim
    cp -f $vestacp/clamav/clamd.conf /etc/clamav/
    mkdir -p /var/lib/clamav
    /usr/bin/freshclam

    # update-rc.d clamav-daemon defaults
    currentservice='clamav-daemon'
    ensure_startup $currentservice
    currentservice='clamav-freshclam'
    ensure_startup $currentservice
    
 if [ ! -d "/var/run/clamav" ]; then
        mkdir /var/run/clamav
    fi
    chown -R clamav:clamav /var/run/clamav
    if [ -e "/lib/systemd/system/clamav-daemon.service" ]; then
        exec_pre1='ExecStartPre=-/bin/mkdir -p /var/run/clamav'
        exec_pre2='ExecStartPre=-/bin/chown -R clamav:clamav /var/run/clamav'
        sed -i "s|\[Service\]|[Service]\n$exec_pre1\n$exec_pre2|g" /lib/systemd/system/clamav-daemon.service
        systemctl daemon-reload
    fi
    clamavfolder="/var/lib/clamav"
    if [ -d "$clamavfolder" ]; then
        echo "=== Blocking executable files inside zip/rar/tar archives in ClamAV"
        wget -nv -O $clamavfolder/foxhole_all.cdb http://c.myvestacp.com/tools/clamav/foxhole_all.cdb
        chown clamav:clamav $clamavfolder/foxhole_all.cdb
    fi
    
    currentservice='clamav-daemon'
    ensure_start $currentservice
    currentservice='clamav-freshclam'
    ensure_start $currentservice
fi


#----------------------------------------------------------#
#                  Configure SpamAssassin                  #
#----------------------------------------------------------#

if [ "$spamd" = 'yes' ]; then
    echo "=== Configure SpamAssassin"
    #update-rc.d spamassassin defaults
    sed -i "s/ENABLED=0/ENABLED=1/" /etc/default/spamassassin
    wget -nv -O /etc/spamassassin/barracuda.cf http://c.myvestacp.com/tools/spamassassin/barracuda.cf
    currentservice='spamassassin'
    ensure_startup $currentservice
    # ensure_start $currentservice
    systemctl restart spamassassin
fi


#----------------------------------------------------------#
#                   Configure RoundCube                    #
#----------------------------------------------------------#

if [ "$exim" = 'yes' ] && { [ "$mysql" = 'yes' ] || [ "$mysql8" = 'yes' ]; } then
    echo "=== Configure RoundCube"
    if [ "$apache" = 'yes' ]; then
        cp -f $vestacp/roundcube/apache.conf /etc/roundcube/
        ln -s /etc/roundcube/apache.conf /etc/apache2/conf.d/roundcube.conf
    fi
    cp -f $vestacp/roundcube/main.inc.php /etc/roundcube/
    cp -f  $vestacp/roundcube/db.inc.php /etc/roundcube/
    chmod 640 /etc/roundcube/debian-db-roundcube.php
    chmod 640 /etc/roundcube/config.inc.php
    chown root:www-data /etc/roundcube/debian-db-roundcube.php
    chown root:www-data /etc/roundcube/config.inc.php
    cp -f $vestacp/roundcube/vesta.php \
        /usr/share/roundcube/plugins/password/drivers/
    cp -f $vestacp/roundcube/config.inc.php /etc/roundcube/plugins/password/
    r="$(gen_pass)"
    mysql -e "CREATE DATABASE roundcube"
    if [ "$mysql8" = 'yes' ]; then
        mysql -e "CREATE USER 'roundcube'@'localhost' IDENTIFIED BY '$r';"
        mysql -e "GRANT ALL ON roundcube.* 
            TO roundcube@localhost"
    else
        mysql -e "GRANT ALL ON roundcube.* 
            TO roundcube@localhost IDENTIFIED BY '$r'"
    fi
    sed -i "s/%password%/$r/g" /etc/roundcube/db.inc.php
    sed -i "s/localhost/$servername/g" \
        /etc/roundcube/plugins/password/config.inc.php
    mysql roundcube < /usr/share/dbconfig-common/data/roundcube/install/mysql
    chmod a+r /etc/roundcube/main.inc.php
    if [ "$release" -eq 8 ] || [ "$release" -eq 9 ] || [ "$release" -eq 10 ] || [ "$release" -eq 11 ]; then
        mv -f /etc/roundcube/main.inc.php /etc/roundcube/config.inc.php
        mv -f /etc/roundcube/db.inc.php /etc/roundcube/debian-db-roundcube.php
        chmod 640 /etc/roundcube/debian-db-roundcube.php
        chmod 640 /etc/roundcube/config.inc.php
        chown root:www-data /etc/roundcube/debian-db-roundcube.php
        chown root:www-data /etc/roundcube/config.inc.php
    fi
    sed -i "s#^\$config\['smtp_user'\].*#\$config\['smtp_user'\] = '%u';#g" /etc/roundcube/defaults.inc.php
    sed -i "s#^\$config\['smtp_pass'\].*#\$config\['smtp_pass'\] = '%p';#g" /etc/roundcube/defaults.inc.php
    if [ "$release" -eq 8 ]; then
        # RoundCube tinyMCE fix
        tinymceFixArchiveURL=$vestacp/roundcube/roundcube-tinymce.tar.gz
        tinymceParentFolder=/usr/share/roundcube/program/js
        tinymceFolder=$tinymceParentFolder/tinymce
        tinymceBadJS=$tinymceFolder/tiny_mce.js
        tinymceFixArchive=$tinymceParentFolder/roundcube-tinymce.tar.gz
        if [[ -L "$tinymceFolder" && -d "$tinymceFolder" ]]; then
            if [ -f "$tinymceBadJS" ]; then
                wget $tinymceFixArchiveURL -O $tinymceFixArchive
                if [[ -f "$tinymceFixArchive" && -s "$tinymceFixArchive" ]]
                then
                    rm $tinymceFolder
                    tar -xzf $tinymceFixArchive -C $tinymceParentFolder
                    rm $tinymceFixArchive
                    chown -R root:root $tinymceFolder
                else
                    echo -n "File roundcube-tinymce.tar.gz is not downloaded,"
                    echo "RoundCube tinyMCE fix is not applied"
                    rm $tinymceFixArchive
                fi
            fi
        fi

    fi
fi


#----------------------------------------------------------#
#                    Configure Fail2Ban                    #
#----------------------------------------------------------#

if [ "$fail2ban" = 'yes' ]; then
    echo "=== Configure Fail2Ban"
    cp -rf $vestacp/fail2ban /etc/
    if [ "$dovecot" = 'no' ]; then
        fline=$(cat /etc/fail2ban/jail.local |grep -n dovecot-iptables -A 2)
        fline=$(echo "$fline" |grep enabled |tail -n1 |cut -f 1 -d -)
        sed -i "${fline}s/true/false/" /etc/fail2ban/jail.local
    fi
    if [ "$exim" = 'no' ]; then
        fline=$(cat /etc/fail2ban/jail.local |grep -n exim-iptables -A 2)
        fline=$(echo "$fline" |grep enabled |tail -n1 |cut -f 1 -d -)
        sed -i "${fline}s/true/false/" /etc/fail2ban/jail.local
    fi
    if [ "$vsftpd" = 'yes' ]; then
        #Create vsftpd Log File
        if [ ! -f "/var/log/vsftpd.log" ]; then
            touch /var/log/vsftpd.log
        fi
        fline=$(cat /etc/fail2ban/jail.local |grep -n vsftpd-iptables -A 2)
        fline=$(echo "$fline" |grep enabled |tail -n1 |cut -f 1 -d -)
        sed -i "${fline}s/false/true/" /etc/fail2ban/jail.local
    fi 
    #update-rc.d fail2ban defaults
    currentservice='fail2ban'
    ensure_startup $currentservice
    ensure_start $currentservice
fi


#----------------------------------------------------------#
#                   Configure Admin User                   #
#----------------------------------------------------------#

echo "=== Configure Admin User"
if [ "$release" -eq 11 ]; then
    echo "=== Switching to sha512"
    sed -i "s/yescrypt/sha512/g" /etc/pam.d/common-password
fi

echo "== Deleting old admin user"
if [ ! -z "$(grep ^admin: /etc/passwd)" ] && [ "$force" = 'yes' ]; then
    chattr -i /home/admin/conf > /dev/null 2>&1
    userdel -f admin >/dev/null 2>&1
    chattr -i /home/admin/conf >/dev/null 2>&1
    mv -f /home/admin  $vst_backups/home/ >/dev/null 2>&1
    rm -f /tmp/sess_* >/dev/null 2>&1
fi
if [ ! -z "$(grep ^admin: /etc/group)" ]; then
    groupdel admin > /dev/null 2>&1
fi

    echo "== Creating Administrator Account"
    ${myVesta_BIN}/v-add-user "${myVesta_Root}" "${vpass}" "${email}" "default" "System" "Administrator"
        check_result $? "Unable to create Administrator User"
        
        ${myVesta_BIN}/v-change-user-shell "${myVesta_Root}" "bash"
        ${myVesta_BIN}/v-change-user-language "${myVesta_Root}" "${lang}"

if [ "$exim" = 'yes' ] && { [ "$mysql" = 'yes' ] || [ "$mysql8" = 'yes' ]; } then
    echo "== RoundCube permissions fix"
    if [ ! -d "/var/log/roundcube" ]; then
        mkdir /var/log/roundcube
    fi
    chown admin:admin /var/log/roundcube
fi

# Vesta data sessions permissions
chown ${myVesta_Root}:${myVesta_Root} $VESTA/data/sessions

echo "== Configuring system ips (this can take a few minutes, relax)"
$VESTA/bin/v-update-sys-ip

echo "== Get main ip"
ip=$(ip addr|grep 'inet '|grep global|head -n1|awk '{print $2}'|cut -f1 -d/)
local_ip=$ip

# Firewall configuration
if [ "$iptables" = 'yes' ]; then
    echo "== Firewall configuration"
    $VESTA/bin/v-update-firewall
fi

echo "== Get public ip"
pub_ip=$(curl -4 -s https://scripts.myvestacp.com/ip.php)

if [ ! -z "$pub_ip" ] && [ "$pub_ip" != "$ip" ]; then
    echo "== NAT detected"
    $VESTA/bin/v-change-sys-ip-nat $ip $pub_ip
    ip=$pub_ip
fi

if [ "$apache" = 'yes' ] && [ "$nginx"  = 'yes' ] ; then
    echo "== Configuring libapache2-mod-remoteip"
    cd /etc/apache2/mods-available
    echo "<IfModule mod_remoteip.c>" > remoteip.conf
    echo "  RemoteIPHeader X-Real-IP" >> remoteip.conf
    if [ "$local_ip" != "127.0.0.1" ] && [ "$pub_ip" != "127.0.0.1" ]; then
        echo "  RemoteIPInternalProxy 127.0.0.1" >> remoteip.conf
    fi
    if [ ! -z "$local_ip" ] && [ "$local_ip" != "$pub_ip" ]; then
        echo "  RemoteIPInternalProxy $local_ip" >> remoteip.conf
    fi
    if [ ! -z "$pub_ip" ]; then
        echo "  RemoteIPInternalProxy $pub_ip" >> remoteip.conf
    fi
    echo "</IfModule>" >> remoteip.conf
    sed -i "s/LogFormat \"%h/LogFormat \"%a/g" /etc/apache2/apache2.conf
    a2enmod remoteip
    service apache2 restart
fi

if [ "$mysql" = 'yes' ] || [ "$mysql8" = 'yes' ]; then
    echo "== Configuring mysql host"
    $VESTA/bin/v-add-database-host "mysql" "localhost" "root" "${mpass}"
    # $VESTA/bin/v-add-database admin default default $(gen_pass) mysql
fi

if [ "$postgresql" = 'yes' ]; then
    echo "== Configuring pgsql host"
    $VESTA/bin/v-add-database-host pgsql localhost postgres $ppass
    $VESTA/bin/v-add-database admin db db $(gen_pass) pgsql
fi

  echo "== Adding Main Domain and NS Records"

  ### Add Main Domain
  ${myVesta_BIN}/v-add-domain "${myVesta_Root}" "${myVesta_User_Domain}"
    check_result $? "Unable to create Domain: ${myVesta_User_Domain}."
  
    if [ "$named" = 'yes' ]; then
      ### Add Domain ns1 and ns2 A Records
      ${myVesta_BIN}/v-add-dns-record "${myVesta_Root}" "${myVesta_User_Domain}" "ns1" "A" "$pub_ip"
        check_result $? "Unable to create ns1 A Record ns1.${myVesta_User_Domain} with Public IP: ${pub_ip}."
      ${myVesta_BIN}/v-add-dns-record "${myVesta_Root}" "${myVesta_User_Domain}" "ns2" "A" "$pub_ip"
        check_result $? "Unable to create ns2 A Record ns2.${myVesta_User_Domain} with Public IP: ${pub_ip}."
    fi
    
  ### Add Server Domain
  ${myVesta_BIN}/v-add-domain "${myVesta_Root}" "${servername}"
    check_result $? "Unable to create Domain: ${servername}."

if [ "$release" -eq 10 ]; then
  if [ -f "/etc/php/7.3/fpm/pool.d/$servername.conf" ]; then
    echo "== FPM pool.d $servername tweaks"
    sed -i "/^group =/c\group = www-data" /etc/php/7.3/fpm/pool.d/$servername.conf
    sed -i "/max_execution_time/c\php_admin_value[max_execution_time] = 900" /etc/php/7.3/fpm/pool.d/$servername.conf
    sed -i "/request_terminate_timeout/c\request_terminate_timeout = 900s" /etc/php/7.3/fpm/pool.d/$servername.conf
    sed -i "s|80M|800M|g" /etc/php/7.3/fpm/pool.d/$servername.conf
    sed -i "s|256M|512M|g" /etc/php/7.3/fpm/pool.d/$servername.conf
    service php7.3-fpm restart
    ln -s /var/lib/roundcube /var/lib/roundcube/webmail
    /usr/local/vesta/bin/v-change-web-domain-proxy-tpl 'admin' "$servername" 'hosting-webmail-phpmyadmin' 'jpg,jpeg,gif,png,ico,svg,css,zip,tgz,gz,rar,bz2,doc,xls,exe,pdf,ppt,txt,odt,ods,odp,odf,tar,wav,bmp,rtf,js,mp3,avi,mpeg,flv,woff,woff2' 'no'
  fi
fi
if [ "$release" -eq 11 ]; then
  if [ -f "/etc/php/7.4/fpm/pool.d/$servername.conf" ]; then
    echo "== FPM pool.d $servername tweaks"
    sed -i "/^group =/c\group = www-data" /etc/php/7.4/fpm/pool.d/$servername.conf
    sed -i "/max_execution_time/c\php_admin_value[max_execution_time] = 900" /etc/php/7.4/fpm/pool.d/$servername.conf
    sed -i "/request_terminate_timeout/c\request_terminate_timeout = 900s" /etc/php/7.4/fpm/pool.d/$servername.conf
    sed -i "s|80M|800M|g" /etc/php/7.4/fpm/pool.d/$servername.conf
    sed -i "s|256M|512M|g" /etc/php/7.4/fpm/pool.d/$servername.conf
    service php7.4-fpm restart
    ln -s /var/lib/roundcube /var/lib/roundcube/webmail
    /usr/local/vesta/bin/v-change-web-domain-proxy-tpl 'admin' "$servername" 'hosting-webmail-phpmyadmin' 'jpg,jpeg,gif,png,ico,svg,css,zip,tgz,gz,rar,bz2,doc,xls,exe,pdf,ppt,txt,odt,ods,odp,odf,tar,wav,bmp,rtf,js,mp3,avi,mpeg,flv,woff,woff2' 'yes'
  fi
fi


  ##### Adding CronJobs
  echo "== Adding CronJobs"
  ${myVesta_BIN}/v-add-cron-job "${myVesta_Root}" "15" "02" "*" "*" "*" "sudo ${myVesta_BIN}/v-update-sys-queue disk"
  ${myVesta_BIN}/v-add-cron-job "${myVesta_Root}" "10" "00" "*" "*" "*" "sudo ${myVesta_BIN}/v-update-sys-queue traffic"
  ${myVesta_BIN}/v-add-cron-job "${myVesta_Root}" "30" "03" "*" "*" "*" "sudo ${myVesta_BIN}/v-update-sys-queue webstats"
  ${myVesta_BIN}/v-add-cron-job "${myVesta_Root}" "*/5" "*" "*" "*" "*" "sudo ${myVesta_BIN}/v-update-sys-queue backup"
  ${myVesta_BIN}/v-add-cron-job "${myVesta_Root}" "10" "01" "*" "*" "6" "sudo ${myVesta_BIN}/v-backup-users"
  ${myVesta_BIN}/v-add-cron-job "${myVesta_Root}" "20" "00" "*" "*" "*" "sudo ${myVesta_BIN}/v-update-user-stats"
  ${myVesta_BIN}/v-add-cron-job "${myVesta_Root}" "*/5" "*" "*" "*" "*" "sudo ${myVesta_BIN}/v-update-sys-rrd"
  ${myVesta_BIN}/v-add-cron-vesta-autoupdate
  
    ##### Restart Cron Daemon
    sudo service cron restart

echo "== Building inititall rrd images"
$VESTA/bin/v-update-sys-rrd

if [ "$quota" = 'yes' ]; then
    echo "== Enabling file system quota"
    $VESTA/bin/v-add-sys-quota
fi

echo "== Enabling softaculous plugin"
if [ "$softaculous" = 'yes' ]; then
    $VESTA/bin/v-add-vesta-softaculous
fi

# Starting vesta service
#update-rc.d vesta defaults
currentservice='vesta'
ensure_startup $currentservice
ensure_start $currentservice
chown admin:admin $VESTA/data/sessions

  ##### Adding Control Panel Notifications
  echo "== Adding Notifications"
  
  ##### Remove Old Notifications
  [[ -f "${myVesta_DIR}/data/user/${myVesta_Root}/notifications.conf" ]] && rm -f ${myVesta_DIR}/data/users/${myVesta_Root}/notifications.conf
    
    ##### Add Notifications
    ${myVesta_BIN}/v-add-user-notification "${myVesta_Root}" "File Manager" "Browse, copy, edit, view, and retrieve all your web domain files using a fully featured <a href='http://vestacp.com/features/#filemanager'>File Manager</a>. Plugin is available for <a href='/edit/server/?lead=filemanager#module-filemanager'>purchase</a>." "filemanager"
    ${myVesta_BIN}/v-add-user-notification "${myVesta_Root}" "Chroot SFTP" "If you want to have SFTP accounts that will be used only to transfer files (and not to SSH), you can  <a href='/edit/server/?lead=sftp#module-sftp'>purchase</a> and enable <a href='http://vestacp.com/features/#sftpchroot'>SFTP Chroot</a>"
    ${myVesta_BIN}/v-add-user-notification "${myVesta_Root}" "Softaculous" "Softaculous is one of the best Auto Installers and it is finally <a href='/edit/server/?lead=sftp#module-softaculous'>available</a>"
    ${myVesta_BIN}/v-add-user-notification "${myVesta_Root}" "Release 0.9.8-26" "This release adds support for Lets Encrypt HTTP/2. For more information please read <a href='http://vestacp.com/history/#0.9.8-26'>release notes</a>"

#----------------------------------------------------------#
#                   Custom work                            #
#----------------------------------------------------------#

echo "=== Installing additional PHP libs"
if [ "$release" -eq 9 ]; then
  apt-get -y install php7.0-apcu php7.0-mbstring php7.0-bcmath php7.0-curl php7.0-gd php7.0-intl php7.0-mcrypt php7.0-mysql php7.0-mysqlnd php7.0-pdo php7.0-soap php7.0-json php7.0-xml php7.0-zip php7.0-memcache php7.0-memcached php7.0-zip php7.0-imagick php7.0-imap
fi
if [ "$release" -eq 10 ]; then
  apt-get -y install php7.3-apcu php7.3-mbstring php7.3-bcmath php7.3-curl php7.3-gd php7.3-intl php7.3-mysql php7.3-mysqlnd php7.3-pdo php7.3-soap php7.3-json php7.3-xml php7.3-zip php7.3-memcache php7.3-memcached php7.3-zip php7.3-imagick php7.3-imap
fi
if [ "$release" -eq 11 ]; then
  apt-get -y install php7.4-apcu php7.4-mbstring php7.4-bcmath php7.4-curl php7.4-gd php7.4-intl php7.4-mysql php7.4-mysqlnd php7.4-pdo php7.4-soap php7.4-json php7.4-xml php7.4-zip php7.4-memcache php7.4-memcached php7.4-zip php7.4-imagick php7.4-imap
fi

touch /var/log/php-mail.log
chmod a=rw /var/log/php-mail.log

if [ "$release" -eq 9 ]; then
  if [ "$apache" = 'yes' ]; then
    if [ $memory -lt 10000000 ]; then
      echo "=== Patching php7.0-vps"
      mkdir -p /root/vesta-temp-dl/vesta/patch
      cp $vestacp/php/php7.0-vps.patch /root/vesta-temp-dl/vesta/patch/php7.0-vps.patch
      patch -p1 --directory=/ < /root/vesta-temp-dl/vesta/patch/php7.0-vps.patch
    fi
    if [ $memory -gt 9999999 ]; then
      echo "=== Patching php7.0-dedi"
      mkdir -p /root/vesta-temp-dl/vesta/patch
      cp $vestacp/php/php7.0-dedi.patch /root/vesta-temp-dl/vesta/patch/php7.0-dedi.patch
      patch -p1 --directory=/ < /root/vesta-temp-dl/vesta/patch/php7.0-dedi.patch
    fi
  fi
  update-alternatives --set php /usr/bin/php7.0
fi

if [ "$release" -eq 10 ]; then
  if [ $memory -lt 10000000 ]; then
    echo "=== Patching php7.3-vps"
    patch /etc/php/7.3/fpm/php.ini < $vestacp/php/php7.3-vps.patch
  fi
  if [ $memory -gt 9999999 ]; then
    echo "=== Patching php7.3-dedi"
    patch /etc/php/7.3/fpm/php.ini < $vestacp/php/php7.3-dedi.patch
  fi
  update-alternatives --set php /usr/bin/php7.3
  service php7.3-fpm restart
fi

if [ "$release" -eq 11 ]; then
  if [ $memory -lt 10000000 ]; then
    echo "=== Patching php7.4-vps"
    patch /etc/php/7.4/fpm/php.ini < $vestacp/php/php7.4-vps.patch
  fi
  if [ $memory -gt 9999999 ]; then
    echo "=== Patching php7.4-dedi"
    patch /etc/php/7.4/fpm/php.ini < $vestacp/php/php7.4-dedi.patch
  fi
  update-alternatives --set php /usr/bin/php7.4
  service php7.4-fpm restart
fi

# echo "=== Patching rcube_vcard.php"
# wget -nv https://c.myvestacp.com/tools/patches/rcube_vcard.patch -O /root/rcube_vcard.patch
# patch /usr/share/roundcube/program/lib/Roundcube/rcube_vcard.php < /root/rcube_vcard.patch

# Comparing hostname and ip
make_ssl=0
host_ip=$(host $servername | head -n 1 | awk '{print $NF}')
if [ "$host_ip" != "$pub_ip" ]; then
    echo "***** PROBLEM: Hostname $servername is not pointing to your server (IP address $ip)"
    echo "Without pointing your hostname to your IP, LetsEncrypt SSL will not be generated for your server hostname."
    echo "Try to setup an A record in your DNS, pointing your hostname $servername to IP address $ip and then press ENTER."
    echo "(or register ns1.$servername and ns2.$servername as DNS Nameservers and put those Nameservers on $servername domain)"
    echo "If we detect that hostname is still not pointing to your IP, installer will not add LetsEncrypt SSL certificate to your hosting panel (unsigned SSL will be used instead)."
    read -p "To force to try anyway to add LetsEncrypt, press f and then ENTER." answer
    host_ip=$(host $servername | head -n 1 | awk '{print $NF}')
fi
if [ "$answer" = "f" ]; then
    make_ssl=1
fi
if [ "$host_ip" = "$ip" ]; then
    ip="$servername"
    make_ssl=1
fi

if [ $make_ssl -eq 1 ]; then
    # Check if www is also pointing to our IP
    www_host="www.$servername"
    www_host_ip=$(host $www_host | head -n 1 | awk '{print $NF}')
    if [ "$www_host_ip" != "$pub_ip" ]; then
        if [ "$named" = 'yes' ]; then
            echo "=== Deleting www to server hostname"
            $VESTA/bin/v-delete-web-domain-alias 'admin' "$servername" "$www_host" 'no'
            $VESTA/bin/v-delete-dns-on-web-alias 'admin' "$servername" "$www_host" 'no'
        fi
        www_host=""
   fi
fi

echo "==="
echo "Hostname $servername is pointing to $host_ip"

if [ $make_ssl -eq 1 ]; then
    echo "=== Generating HOSTNAME SSL"
    $VESTA/bin/v-add-letsencrypt-domain 'admin' "$servername" "$www_host" 'yes'
    $VESTA/bin/v-update-host-certificate 'admin' "$servername"
else
    echo "We will not generate SSL because of this"
fi
echo "==="
echo "UPDATE_HOSTNAME_SSL='yes'" >> $VESTA/conf/vesta.conf

# folder for upgrade notations
if [ ! -d "/usr/local/vesta/data/upgrades" ]; then
    mkdir -p /usr/local/vesta/data/upgrades
fi
touch /usr/local/vesta/data/upgrades/tune-fpm-config-files-v1
touch /usr/local/vesta/data/upgrades/tune-fpm-config-files-v2
touch /usr/local/vesta/data/upgrades/allow-backup-anytime
touch /usr/local/vesta/data/upgrades/fix-sudoers
touch /usr/local/vesta/data/upgrades/change-clamav-socket-v2
touch /usr/local/vesta/data/upgrades/change-clamav-socket-v3
touch /usr/local/vesta/data/upgrades/change-clamav-socket-v4
touch /usr/local/vesta/data/upgrades/keeping-mpm-event
touch /usr/local/vesta/data/upgrades/keeping-mpm-event-2
touch /usr/local/vesta/data/upgrades/keeping-mpm-event-3
touch /usr/local/vesta/data/upgrades/fix_ssl_directive_in_templates
touch /usr/local/vesta/data/upgrades/clamav_block_exe_in_archives
touch /usr/local/vesta/data/upgrades/clearing-letsencrypt-pipe
touch /usr/local/vesta/data/upgrades/limit_max_recipients
touch /usr/local/vesta/data/upgrades/roundcube_smtp_auth
touch /usr/local/vesta/data/upgrades/apache_status_public_access
touch /usr/local/vesta/data/upgrades/update-cloudflare-ips
touch /usr/local/vesta/data/upgrades/enable-tls-in-proftpd
touch /usr/local/vesta/data/upgrades/enable_cookie_httponly
touch /usr/local/vesta/data/upgrades/fix_exim_494_autoreply
touch /usr/local/vesta/data/upgrades/freshclam_start
touch /usr/local/vesta/data/upgrades/barracuda_rbl

# Secret URL
secretquery=''
if [ ! -z "$secret_url" ]; then
    echo "=== Set secret URL: $secret_url"
    echo "<?php \$login_url='$secret_url';" > $VESTA/web/inc/login_url.php
    secretquery="?$secret_url"
fi

if [ "$port" != "8083" ]; then
    echo "=== Set Vesta port: $port"
    $VESTA/bin/v-change-vesta-port $port
fi

echo "=== Set URL for phpmyadmin"
echo "DB_PMA_URL='https://$servername/phpmyadmin/'" >> $VESTA/conf/vesta.conf
if [ "$release" -eq 10 ] || [ "$release" -eq 11 ]; then
    echo "=== Set max_length_of_MySQL_username=80"
fi
echo "MAX_DBUSER_LEN=80" >> $VESTA/conf/vesta.conf
echo "ALLOW_BACKUP_ANYTIME='yes'" >> $VESTA/conf/vesta.conf
echo "NOTIFY_ADMIN_FULL_BACKUP='$email'" >> $VESTA/conf/vesta.conf
echo "================================================================"

# Removing old PHP sessions files
crontab -l | { cat; echo "10 2 * * 6 sudo find /home/*/tmp/ -type f -mtime +5 -exec rm {} \;"; } | crontab -

    MAKE_CONFIG_FILE "RHOST CHOST VERSION VESTA memory arch os release codename vestacp nginx apache phpfpm vsftpd proftpd named mysql mysql8 postgresql mongodb exim dovecot clamd spamd iptables fail2ban softaculous quota interactive lang apparmor break break break software mpass vpass" "N"
 
#----------------------------------------------------------#
#                  myVesta Access Info                     #
#----------------------------------------------------------#

# Sending notification to admin email
echo -e "Congratulations, you have just successfully installed \
myVesta Control Panel

Control Panel Login
    https://${ip}:${port}/${secretquery}
    - Username: ${myVesta_Root}
    - Password: ${vpass}

PHPMYADMIN Login
    https://linkhere
    - Username: ${myVesta_Root}
    - Password: ${mpass}

TMP FOLDER: ${myVesta_TMP}

We hope that you enjoy your installation of myVesta. Please \
feel free to contact us anytime if you have any questions.
Thank you.

--
Yours Sincerely,
myVestacp Team (http://myVestacp.com)
" > $tmpfile

send_mail="$VESTA/web/inc/mail-wrapper.php"
cat $tmpfile | $send_mail -s "myVesta Control Panel" $email

# Congrats
echo '=========================================='
echo
echo "                __     __        _        "
echo "  _ __ ___  _   \ \   / /__  ___| |_ __ _ "
echo " | '_ \` _ \| | | \ \ / / _ \/ __| __/ _\` |"
echo " | | | | | | |_| |\ V /  __/\__ \ || (_| |"
echo " |_| |_| |_|\__, | \_/ \___||___/\__\__,_|"
echo "            |___/                         "
echo
echo
cat $tmpfile
rm -f $tmpfile

# EOF
