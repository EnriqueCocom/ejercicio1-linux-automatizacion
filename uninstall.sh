#!/bin/bash
RED='\033[1;31m'
GREEN='\033[1;32m'
NC='\033[0m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'

function delete_files {
    echo -e "\n${GREEN}Limpiando el directorio de archivos estaticos\n${NC}"
    rm -rf /var/www/html/*
}

function uninstall_git {
    echo -e "\n${GREEN}Desinstalando Git\n${NC}"
    apt remove -y --purge git
}

function uninstall_apache {
    echo -e "\n${GREEN}Desinstalando Apache2\n${NC}"
    apt remove -y --purge apache2
}

function uninstall_mariadb {
    echo -e "\n${GREEN}Desinstalando MariaDB\n${NC}"
    rm -rf /var/lib/mysql
    apt remove -y --purge mariadb-*
}

function uninstall_php {
    echo -e "\n${GREEN}Desinstalando PHP\n${NC}"
    apt remove -y --purge php libapache2-mod-php php-mysql php-mbstring php-zip php-gd php-json php-curl
}

if dpkg -l "git" > /dev/null 2>&1; then 
    uninstall_git
else
    echo "Git ya está desinstalado"
fi

if dpkg -l "apache2" > /dev/null 2>&1; then 
	delete_files
    uninstall_apache
else
    echo "Apache ya está desinstalado"
fi

if dpkg -l "mariadb*" > /dev/null 2>&1; then 
    uninstall_mariadb
else
    echo "MariaDB ya está desinstalado"
fi

if dpkg -l "php" "libapache2-mod-php" "php-mysql" "php-mbstring" "php-zip" "php-gd" "php-json" "php-curl" > /dev/null 2>&1; then
    uninstall_php
else
    echo "PHP ya está desinstalado"
fi
echo -e "\n${YELLOW}Desinstalacion completada!!!\n${NC}"