# Configuración de Puertos - Moodle

Este documento resume los puertos configurados para evitar conflictos con WordPress.

## Comparación de Puertos

### WordPress (puertos ocupados)
- HTTP: 8080
- phpMyAdmin: 8081
- MySQL: 3306

### Moodle (nuevos puertos)
- **HTTP**: 9080
- **HTTPS**: 9443
- **MySQL/MariaDB**: 3307
- **phpMyAdmin**: 9081
- **Redis**: 6380
- **Mailhog SMTP**: 2025
- **Mailhog Web**: 9025

## Acceso rápido

Una vez que los contenedores estén corriendo:

```
Moodle:         http://localhost:9080
Moodle HTTPS:   https://localhost:9443
phpMyAdmin:     http://localhost:9081
Mailhog:        http://localhost:9025
```

## Comandos útiles

### Verificar que los puertos estén libres
```bash
sudo netstat -tulpn | grep -E '9080|9443|9081|3307|6380|2025|9025'
```

### Ver qué puertos están en uso
```bash
docker ps --format "table {{.Names}}\t{{.Ports}}"
```

### Iniciar Moodle
```bash
cd /home/phoenix/sesna/desarrollo/noSESNA/moodle
docker-compose up -d
```

### Ver estado de ambos proyectos
```bash
# WordPress
docker ps | grep wordpress

# Moodle
docker ps | grep moodle
```
