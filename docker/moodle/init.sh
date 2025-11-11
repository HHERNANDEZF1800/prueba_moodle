#!/bin/bash
set -e

# Esperar a que la base de datos esté lista
echo "Esperando a que la base de datos esté lista..."
until mysql -h"$MOODLE_DB_HOST" -u"$MOODLE_DB_USER" -p"$MOODLE_DB_PASSWORD" --skip-ssl -e "SELECT 1" > /dev/null 2>&1; do
    echo "Esperando conexión a la base de datos..."
    sleep 3
done
echo "Base de datos lista!"

# Verificar si Moodle ya está instalado
if [ ! -f "/var/www/html/config.php" ]; then
    echo "Moodle no está configurado. Creando config.php..."

    cat > /var/www/html/config.php <<EOF
<?php
unset(\$CFG);
global \$CFG;
\$CFG = new stdClass();

\$CFG->dbtype    = '${MOODLE_DB_TYPE:-mariadb}';
\$CFG->dblibrary = 'native';
\$CFG->dbhost    = '${MOODLE_DB_HOST}';
\$CFG->dbname    = '${MOODLE_DB_NAME}';
\$CFG->dbuser    = '${MOODLE_DB_USER}';
\$CFG->dbpass    = '${MOODLE_DB_PASSWORD}';
\$CFG->prefix    = 'mdl_';
\$CFG->dboptions = array(
    'dbpersist' => false,
    'dbsocket'  => false,
    'dbport'    => '',
    'dbcollation' => 'utf8mb4_unicode_ci',
);

\$CFG->wwwroot   = '${MOODLE_URL}';
\$CFG->dataroot  = '/var/www/moodledata';
\$CFG->directorypermissions = 02777;
\$CFG->admin = 'admin';

require_once(__DIR__ . '/lib/setup.php');
// There is no php closing tag in this file,
// it is intentional because it prevents trailing whitespace problems!
EOF

    chown www-data:www-data /var/www/html/config.php
    chmod 644 /var/www/html/config.php

    echo "Instalando Moodle..."
    php /var/www/html/admin/cli/install_database.php \
        --agree-license \
        --lang=es \
        --adminuser="${MOODLE_ADMIN_USER:-admin}" \
        --adminpass="${MOODLE_ADMIN_PASSWORD}" \
        --adminemail="${MOODLE_ADMIN_EMAIL}" \
        --fullname="${MOODLE_SITE_NAME}" \
        --shortname="${MOODLE_SITE_NAME}"

    echo "Instalación de Moodle completada!"
else
    echo "Moodle ya está configurado."
fi

# Asegurar permisos correctos
chown -R www-data:www-data /var/www/html /var/www/moodledata

# Iniciar Apache
echo "Iniciando Apache..."
apache2-foreground
