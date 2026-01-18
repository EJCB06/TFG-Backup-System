#!/bin/bash
set -e # Salir si hay errores críticos (pero gestionados)

# --- 1. CARGA DE VARIABLES ROBUSTA ---
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ENV_FILE="$SCRIPT_DIR/.env"

if [ -f "$ENV_FILE" ]; then
    echo "Cargando variables desde: $ENV_FILE"
    source "$ENV_FILE"
else
    echo "ERROR: No encuentro el archivo .env. Asegúrate de que existe."
    exit 1
fi

# --- 2. INSTALACIÓN DE PAQUETES ---
echo "--- ACTUALIZANDO SISTEMA ---"
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update
# sudo apt-get upgrade -y  <-- Lo comento para ahorrar tiempo si ya lo hiciste

echo "--- INSTALANDO APACHE Y MYSQL ---"
sudo apt-get install -y apache2 mysql-server wget curl unzip zip software-properties-common

# --- 3. LÓGICA INTELIGENTE DE MYSQL ---
echo "--- CONFIGURANDO MYSQL ---"
sudo systemctl start mysql
sudo systemctl enable mysql

# Permitir conexiones remotas (0.0.0.0)
sudo sed -i "s/bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf
sudo systemctl restart mysql

# DETECTAR SI YA TIENE CONTRASEÑA
# Intentamos conectar sin contraseña
if sudo mysql -e "status" >/dev/null 2>&1; then
    echo "MySQL no tiene contraseña configurada. Procediendo a asegurarlo..."
    
    # Ponemos la contraseña
    sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASS}';"
    sudo mysql -uroot -p"${MYSQL_ROOT_PASS}" -e "FLUSH PRIVILEGES;"
    
    echo "Contraseña de root establecida correctamente."

else
    echo "MySQL ya tiene contraseña (o no deja entrar sin ella)."
    echo "Probando conexión con la contraseña del .env..."
    
    # Probamos si la contraseña del .env funciona
    if sudo mysql -uroot -p"${MYSQL_ROOT_PASS}" -e "status" >/dev/null 2>&1; then
        echo "¡Éxito! La contraseña actual coincide con el .env. Continuamos."
    else
        echo "ERROR CRÍTICO: MySQL tiene contraseña, pero NO es la que está en el .env."
        echo "Solución: Cambia la contraseña en el .env o resetea MySQL."
        exit 1
    fi
fi

# A partir de aquí, usamos siempre la contraseña para los comandos
MYSQL_CMD="sudo mysql -uroot -p${MYSQL_ROOT_PASS}"

echo "--- 4. INSTALANDO PHP Y MÓDULOS ---"
sudo apt-get install -y php libapache2-mod-php php-mysql php-mbstring php-zip php-json php-gd php-xml php-curl
# Limpiar index por defecto y crear info.php
echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/info.php > /dev/null
sudo chown -R ubuntu:www-data /var/www/html
sudo chmod -R 775 /var/www/html

echo "--- 5. INSTALANDO PHPMYADMIN ---"
# Solo instalamos si no existe ya la carpeta
if [ ! -d "/var/www/html/phpmyadmin" ]; then
    cd /var/www/html
    wget -q https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz
    tar xf phpMyAdmin-latest-all-languages.tar.gz
    rm phpMyAdmin-latest-all-languages.tar.gz
    mv phpMyAdmin-*-all-languages phpmyadmin
    
    # Configurar
    cp /var/www/html/phpmyadmin/config.sample.inc.php /var/www/html/phpmyadmin/config.inc.php
    sed -i "s/\(\$cfg\['blowfish_secret'\] =\).*/\1 '${RANDOM_VALUE}';/" /var/www/html/phpmyadmin/config.inc.php
    echo "\$cfg['TempDir'] = '/tmp';" >> /var/www/html/phpmyadmin/config.inc.php
    
    # Crear tablas internas usando la contraseña
    $MYSQL_CMD < /var/www/html/phpmyadmin/sql/create_tables.sql
    
    # Crear usuario PMA
    $MYSQL_CMD <<SQL
CREATE USER IF NOT EXISTS '${PMA_USER}'@'%' IDENTIFIED BY '${PMA_PASS}';
GRANT ALL PRIVILEGES ON *.* TO '${PMA_USER}'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
SQL
    
    sudo chown -R www-data:www-data /var/www/html/phpmyadmin
else
    echo "phpMyAdmin ya parece estar instalado. Saltando descarga."
fi

sudo systemctl restart apache2

echo "--- INSTALACIÓN COMPLETADA CON ÉXITO ---"
IP_PUBLICA=$(curl -s ifconfig.me)
echo "Accede a: http://$IP_PUBLICA/phpmyadmin"