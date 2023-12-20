#!/bin/bash

repo="ejercicio1-linux-automatizacion"
USERID=$(id -u)
REPO_URL=https://github.com/EnriqueCocom/$repo.git

#colores
LRED='\033[1;31m'
LGREEN='\033[1;32m'
NC='\033[0m'
LBLUE='\033[0;34m'
LYELLOW='\033[1;33m'


echo "|| ============ Inicio del Script =========== ||"

# Ejecutar el usuario ROOT
if [ "${USERID}" -ne 0 ]; then
    echo -e "\n${LRED}Correr con usuario ROOT${NC}"
    echo -e "Saliendo del Script..."
    exit
fi


echo -e "Actualizando paquetes del servidor..."
    apt-get update
echo -e "\n${LGREEN}El servidor fue actualizado...${NC}"

echo ""
echo "|| ========================================= ||"
echo ""

# Comprobar la instalacion de GIT
echo ""
echo "|| ========================================= ||"
echo ""

if dpkg -l | grep git; then
    echo -e "Git ya se encuentra instalado..."
else
echo -e "\n${LYELLOW}instalando GIT ...${NC}"
    apt install git -y
fi



# Comprobar la instalacion de MySQL
echo ""
echo "|| ========================================= ||"
echo ""

echo -e "Comprobando instalacion de MariDB..."
if dpkg -l | grep mariadb-server; then
    echo -e "MariaDB ya se encuentra instalado..."
else
    echo -e "\n${LYELLOW}Instalando MariaDB...${NC}"
    apt install -y mariadb-server
    systemctl start mariadb
    systemctl enable mariadb
fi
echo -e "\n${LGREEN}MariaDB fue instalado...${NC}"

echo ""
echo "|| ========================================= ||"
echo ""


# Comprobar la instalacion de Apache
echo ""
echo "|| ========================================= ||"
echo ""
echo -e "Comprobando la instalacion de Apache2..."

if dpkg -l | grep apache2; then
    echo -e "Apache2 ya se encuentra instalado en el Sistema..."
else
echo -e "\n${LYELLOW}Instalando Apache2...${NC}"
    apt install apache2 -y
    apt install -y php libapache2-mod-php php-mysql php-mbstring php-zip php-gd php-json php-curl 
    #Configurando Apache
    systemctl start apache2
    systemctl enable apache2
    php -v
    mv /var/www/html/index.html /var/www/html/index.html.bkp
fi
sed -i 's/index.html/index.php index.html/g' /etc/apache2/mods-enabled/dir.conf
systemctl reload apache2

echo ""
echo "|| ========================================= ||"
echo ""

#Configurando Base de Datos

echo ""
echo "|| ========================================= ||"
echo ""

echo -e "Comprobando base de datos"
if mysqlshow devopstravel > /dev/null 2>&1; then
    echo -e "La base de datos devopstravel ya existe"
else
    echo -e "\n${LYELLOW}Creando la base de datos devopstravel...${NC}"
        mysql -e "CREATE DATABASE devopstravel;"
        echo -e "\n${LGREEN}La base de datos fue creada exitosamente...${NC}"
fi

echo ""
echo "|| ========================================= ||"
echo ""

# Creación del usuario de base de datos
echo ""
echo "|| ========================================= ||"
echo ""

echo -e "\n${LYELLOW}Creando usuario a la base de datos...${NC}"
if mysql -e "SELECT user FROM mysql.user GROUP BY user;" | grep codeuser > /dev/null 2>&1; then
    echo -e "El usuario codeuser ya existe"
else
        mysql -e "
        CREATE USER 'codeuser'@'localhost' IDENTIFIED BY 'codepass';
        GRANT ALL PRIVILEGES ON *.* TO 'codeuser'@'localhost';
        FLUSH PRIVILEGES;"
    echo -e "\n${LGREEN}El usuario codeuser fue creado exitosamente...${NC}"
fi

echo ""
echo "|| ========================================= ||"
echo ""

# Clonar el repositorio
echo ""
echo "|| ========================================= ||"
echo ""

if [[ -d $repo ]]; then
    echo -e "El repositorio ${repo} ya existe"
    cd ${repo}
    git pull origin rama-dev
else
    echo -e "\n${LYELLOW}Clonando el repositorio ${repo}...${NC}"
    git clone ${REPO_URL}
    cd ${repo}
    git pull origin rama-dev
    echo $repo
    echo -e "\n${LGREEN}El repositorio fue clonado exitosamente...${NC}"
fi
echo ""
echo "|| ========================================= ||"
echo ""

# Copiar los archivos del repositorio a la carpeta del servidor web
echo ""
echo "|| ========================================= ||"
echo ""

cp -r ~/${repo}/app-295devops-travel/* /var/www/html

echo -e "\n${LGREEN}Archivos copiados al servidor web exitosamente ... ${NC}"

echo ""
echo "|| ========================================= ||"
echo ""

# Configuración de datos a la base de datos

echo ""
echo "|| ========================================= ||"
echo ""

echo -e "\n${LYELLOW} Cargando datos a la base de datos...${NC}"

mysql < ~/$repo/app-295devops-travel/database/devopstravel.sql

echo -e "\n${LGREEN}Los datos fueron cargados exitosamente...${NC}"

echo ""
echo "|| ========================================= ||"
echo ""

# Configuración de contraseña de la base de datos
echo ""
echo "|| ========================================= ||"
echo ""

echo -e "\n${LYELLOW}Ingresando la contraseña de la  base de datos a la pagina web...${NC}"
    sleep 2
    nano /var/www/html/config.php
    systemctl reload apache2
    echo -e "\n${LGREEN}La contraseña fue configurada exitosamente...${NC}"

echo ""
echo "|| ========================================= ||"
echo ""


#Deploy
echo ""
echo "|| ========================================= ||"
echo ""

echo -e "Pruebe la pagina ingrasando a: http://localhost o http://ip"

echo -e "\n${LGREEN}Fin del despliegue del proyecto... ${NC}"

echo ""
echo "|| ========================================= ||"
echo ""


# Configuración de Discord
# Configura el token de acceso de tu bot de Discord
DISCORD="https://discord.com/api/webhooks/1154865920741752872/au1jkQ7v9LgQJ131qFnFqP-WWehD40poZJXRGEYUDErXHLQJ_BBszUFtVj8g3pu9bm7h"

# Verifica si se proporcionó el argumento del directorio del repositorio
#if [ $# -ne 1 ]; then
#  echo "Uso: $0 <ruta_al_repositorio>"
#  exit 1
#fi

# Cambia al directorio del repositorio
#cd "$1"

# Obtiene el nombre del repositorio
REPO_NAME=$(basename $(git rev-parse --show-toplevel))
# Obtiene la URL remota del repositorio
REPO_URL=$(git remote get-url origin)
WEB_URL="localhost"
# Realiza una solicitud HTTP GET a la URL
HTTP_STATUS=$(curl -Is "$WEB_URL" | head -n 1)

# Verifica si la respuesta es 200 OK (puedes ajustar esto según tus necesidades)
if [[ "$HTTP_STATUS" == *"200 OK"* ]]; then
  # Obtén información del repositorios
    DEPLOYMENT_INFO2="Despliegue del repositorio $REPO_NAME: "
    DEPLOYMENT_INFO="La página web $WEB_URL está en línea."
    COMMIT="Commit: $(git rev-parse --short HEAD)"
    AUTHOR="Autor: $(git log -1 --pretty=format:'%an')"
    DESCRIPTION="Descripción: $(git log -1 --pretty=format:'%s')"
else
  DEPLOYMENT_INFO="La página web $WEB_URL no está en línea."
fi

# Obtén información del repositorio


# Construye el mensaje
MESSAGE="$DEPLOYMENT_INFO2\n$DEPLOYMENT_INFO\n$COMMIT\n$AUTHOR\n$REPO_URL\n$DESCRIPTION"

# Envía el mensaje a Discord utilizando la API de Discord
curl -X POST -H "Content-Type: application/json" \
     -d '{
       "content": "'"${MESSAGE}"'"
     }' "$DISCORD"

echo ""
echo "|| ========================================= ||"
echo ""

echo -e "Enviando notificacion a Discord"

echo ""
echo "|| ========================================= ||"
echo ""
