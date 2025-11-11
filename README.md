# Moodle con Docker

Este proyecto contiene la configuración completa para ejecutar Moodle en contenedores Docker con todos los servicios necesarios.

## Servicios incluidos

- **Moodle**: Plataforma LMS (Learning Management System)
- **MariaDB**: Base de datos
- **Redis**: Sistema de caché para mejorar el rendimiento
- **phpMyAdmin**: Interfaz web para administrar la base de datos
- **Mailhog**: Servidor SMTP de prueba para desarrollo

## Requisitos previos

- Docker (versión 20.10 o superior)
- Docker Compose (versión 2.0 o superior)
- Al menos 4GB de RAM disponible para los contenedores
- Puertos disponibles: 9080, 9443, 9081, 3307, 6380, 2025, 9025

## Instalación y configuración

### 1. Clonar o descargar el proyecto

```bash
cd /home/phoenix/sesna/desarrollo/noSESNA/moodle
```

### 2. Configurar las variables de entorno

Edita el archivo `.env` según tus necesidades:

```bash
nano .env
```

**Variables importantes a modificar:**

- `MOODLE_ADMIN_USER`: Usuario administrador (por defecto: admin)
- `MOODLE_ADMIN_PASSWORD`: Contraseña del administrador (¡CÁMBIALA!)
- `MOODLE_ADMIN_EMAIL`: Email del administrador
- `MOODLE_SITE_NAME`: Nombre de tu sitio Moodle
- `MOODLE_DATABASE_PASSWORD`: Contraseña de la base de datos (¡CÁMBIALA!)
- `MYSQL_ROOT_PASSWORD`: Contraseña root de MySQL (¡CÁMBIALA!)
- `REDIS_PASSWORD`: Contraseña de Redis (¡CÁMBIALA!)

### 3. Iniciar los contenedores

```bash
docker-compose up -d
```

Este comando descargará las imágenes necesarias y creará los contenedores. La primera vez puede tardar varios minutos.

### 4. Verificar el estado de los contenedores

```bash
docker-compose ps
```

Todos los servicios deberían mostrar el estado "Up".

### 5. Ver los logs (opcional)

Para ver los logs de todos los servicios:

```bash
docker-compose logs -f
```

Para ver los logs de un servicio específico:

```bash
docker-compose logs -f moodle
```

## Acceso a los servicios

Una vez que los contenedores estén corriendo:

- **Moodle**: http://localhost:9080
- **Moodle (HTTPS)**: https://localhost:9443
- **phpMyAdmin**: http://localhost:9081
- **Mailhog (interfaz web)**: http://localhost:9025

### Credenciales por defecto

**Moodle:**
- Usuario: `admin` (o el valor de `MOODLE_ADMIN_USER`)
- Contraseña: `Admin123!SecurePass` (o el valor de `MOODLE_ADMIN_PASSWORD`)

**phpMyAdmin:**
- Servidor: `mariadb`
- Usuario: `root`
- Contraseña: El valor de `MYSQL_ROOT_PASSWORD` en `.env`

## Configuración de Redis en Moodle (opcional pero recomendado)

Para habilitar Redis como caché en Moodle:

1. Accede a Moodle como administrador
2. Ve a: Administración del sitio > Extensiones > Cachés > Configuración
3. O edita manualmente el archivo de configuración:

```bash
docker-compose exec moodle bash
nano /bitnami/moodle/config.php
```

4. Agrega antes de la última línea (`require_once(__DIR__ . '/lib/setup.php');`):

```php
// Redis cache configuration
$CFG->session_handler_class = '\core\session\redis';
$CFG->session_redis_host = 'redis';
$CFG->session_redis_port = 6380;
$CFG->session_redis_auth = 'redis_secure_password_2024'; // Tu REDIS_PASSWORD
$CFG->session_redis_database = 0;
$CFG->session_redis_prefix = 'moodle_sess_';
```

## Comandos útiles

### Detener los contenedores

```bash
docker-compose stop
```

### Iniciar los contenedores detenidos

```bash
docker-compose start
```

### Reiniciar los contenedores

```bash
docker-compose restart
```

### Detener y eliminar los contenedores (los datos persisten)

```bash
docker-compose down
```

### Eliminar todo (¡CUIDADO! Esto borra todos los datos)

```bash
docker-compose down -v
```

### Acceder al contenedor de Moodle

```bash
docker-compose exec moodle bash
```

### Acceder a la base de datos con CLI

```bash
docker-compose exec mariadb mysql -u root -p
```

### Ver el uso de recursos

```bash
docker stats
```

## Backup y restauración

### Hacer backup de la base de datos

```bash
docker-compose exec mariadb mysqldump -u root -p moodle > backup_moodle_$(date +%Y%m%d_%H%M%S).sql
```

### Restaurar base de datos desde backup

```bash
docker-compose exec -T mariadb mysql -u root -p moodle < backup_moodle_YYYYMMDD_HHMMSS.sql
```

### Backup de archivos de Moodle

```bash
docker-compose exec moodle tar czf /tmp/moodle_files_backup.tar.gz /bitnami/moodledata
docker cp moodle_app:/tmp/moodle_files_backup.tar.gz ./
```

## Actualización de Moodle

```bash
# Detener los contenedores
docker-compose down

# Actualizar las imágenes
docker-compose pull

# Iniciar con las nuevas imágenes
docker-compose up -d
```

## Solución de problemas

### El contenedor de Moodle se reinicia constantemente

Verifica los logs:
```bash
docker-compose logs moodle
```

Posibles causas:
- La base de datos no está lista. Espera unos minutos más.
- Problemas de memoria. Aumenta la RAM disponible para Docker.

### No puedo acceder a Moodle

1. Verifica que todos los contenedores estén corriendo:
   ```bash
   docker-compose ps
   ```

2. Verifica que los puertos no estén ocupados:
   ```bash
   sudo netstat -tulpn | grep -E '9080|9443'
   ```

3. Intenta reiniciar los contenedores:
   ```bash
   docker-compose restart
   ```

### Error de base de datos

1. Verifica que MariaDB esté corriendo:
   ```bash
   docker-compose ps mariadb
   ```

2. Revisa los logs de MariaDB:
   ```bash
   docker-compose logs mariadb
   ```

3. Verifica la conexión:
   ```bash
   docker-compose exec moodle ping mariadb
   ```

### Permisos de archivos

Si tienes problemas con permisos:

```bash
docker-compose exec moodle chown -R daemon:daemon /bitnami/moodle /bitnami/moodledata
```

## Configuración de producción

Para usar en producción, considera:

1. **Seguridad:**
   - Cambia TODAS las contraseñas en `.env`
   - Usa HTTPS con certificados válidos
   - Configura un firewall
   - Cierra los puertos innecesarios (phpMyAdmin, Mailhog)

2. **Rendimiento:**
   - Ajusta `PHP_MEMORY_LIMIT` según tus necesidades
   - Configura Redis correctamente
   - Optimiza la configuración de MariaDB en `docker/mariadb/custom.cnf`

3. **Backup:**
   - Configura backups automáticos diarios
   - Almacena backups en ubicación externa

4. **Monitoreo:**
   - Implementa monitoreo de logs
   - Configura alertas de recursos

## Variables de entorno disponibles

Consulta el archivo `.env` para ver todas las variables configurables.

## Soporte y documentación

- [Documentación oficial de Moodle](https://docs.moodle.org/)
- [Documentación de Docker](https://docs.docker.com/)
- [Bitnami Moodle Docker Image](https://hub.docker.com/r/bitnami/moodle)

## Licencia

Este proyecto usa Moodle, que está licenciado bajo GPL v3.
