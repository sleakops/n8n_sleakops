# n8n Docker Setup con Queue Workers

Configuración de n8n usando Docker Compose con arquitectura de colas (queue mode) para procesamiento distribuido de workflows.

## 📋 Requisitos

- Docker Engine 20.10+
- Docker Compose 2.0+
- Puertos disponibles: 5678

## 🏗️ Arquitectura

Este setup incluye 4 servicios:

- **PostgreSQL**: Base de datos para almacenar workflows, credenciales y ejecuciones
- **Redis**: Sistema de colas para distribución de trabajos
- **n8n**: Servidor principal (interfaz web y API)
- **n8n-worker**: Worker para procesamiento de workflows en segundo plano

## 🚀 Inicio Rápido

### 1. Clonar o crear los archivos

Asegúrate de tener estos archivos en tu directorio:
- `compose.yaml`
- `.env`
- `Dockerfile`

### 2. Crear carpeta para archivos locales

```bash
mkdir -p local-files
```

### 3. Levantar los servicios

```bash
docker-compose up -d
```

### 4. Acceder a n8n

Abre tu navegador en: `http://localhost:5678`

### 5. Ver logs

```bash
# Todos los servicios
docker-compose logs -f

# Solo n8n
docker-compose logs -f n8n

# Solo workers
docker-compose logs -f n8n-worker
```

## 🛠️ Comandos Útiles

### Detener servicios
```bash
docker-compose down
```

### Detener y eliminar volúmenes (⚠️ borra todos los datos)
```bash
docker-compose down -v
```

### Reiniciar servicios
```bash
docker-compose restart
```

### Reconstruir imágenes
```bash
docker-compose build --no-cache
docker-compose up -d
```

### Escalar workers
```bash
docker-compose up -d --scale n8n-worker=3
```

## 📝 Modos de Ejecución (Entrypoints)

La imagen de n8n soporta diferentes modos de ejecución:

### `start` (por defecto)
Inicia el servidor principal de n8n con interfaz web y API.
```yaml
command: start
# O simplemente omitir el command
```

### `worker`
Inicia un worker para procesar trabajos en cola.
```yaml
command: worker
```

### `webhook`
Inicia solo el servidor de webhooks (útil para escalado horizontal).
```yaml
command: webhook
```

### Otros comandos disponibles
```bash
# Ejecutar comando dentro del contenedor
docker-compose exec n8n n8n --help

# Exportar workflows
docker-compose exec n8n n8n export:workflow --all --output=/files/

# Importar workflows
docker-compose exec n8n n8n import:workflow --input=/files/workflow.json

# Ejecutar workflow
docker-compose exec n8n n8n execute --id=<workflow-id>
```

## ⚙️ Configuración

### Variables de Entorno Principales

| Variable | Descripción | Valor por Defecto |
|----------|-------------|-------------------|
| `N8N_PORT` | Puerto del servidor | `5678` |
| `N8N_PROTOCOL` | Protocolo (http/https) | `http` |
| `N8N_HOST` | Host del servidor | `localhost` |
| `EXECUTIONS_MODE` | Modo de ejecución | `queue` |
| `N8N_WORKERS_ENABLED` | Habilitar workers | `true` |
| `DB_TYPE` | Tipo de base de datos | `postgresdb` |
| `QUEUE_BULL_REDIS_HOST` | Host de Redis | `redis` |

Otras variables de entorno están documentadas en la [documentación oficial de n8n](https://docs.n8n.io/hosting/configuration/environment-variables/).

### Modificar Configuración

1. Edita el archivo `.env`
2. Reinicia los servicios:
```bash
docker-compose down
docker-compose up -d
```

## 📂 Estructura de Archivos

```
.
├── compose.yaml           # Definición de servicios
├── Dockerfile            # Imagen base de n8n
├── .env                  # Variables de entorno
├── local-files/          # Archivos compartidos con n8n
└── README.md            # Este archivo
```

### Volúmenes Persistentes

- `n8n_data`: Datos de n8n (workflows, credenciales, configuración)
- `postgres_data`: Base de datos PostgreSQL
- `redis_data`: Datos de Redis
- `./local-files`: Archivos locales accesibles desde workflows

## 🔧 Personalización

### Agregar Paquetes npm

Modifica el `Dockerfile`:

```dockerfile
FROM docker.n8n.io/n8nio/n8n:1.115.3

USER root
RUN npm install -g <paquete>
USER node
```

Luego reconstruye:
```bash
docker-compose build --no-cache
docker-compose up -d
```

### Cambiar Zona Horaria

En `.env`:
```env
GENERIC_TIMEZONE=America/Argentina/Buenos_Aires
TZ=America/Argentina/Buenos_Aires
```

### Habilitar HTTPS

1. Configura un reverse proxy (nginx, traefik, caddy)
2. O usa certificados SSL directamente:

```env
N8N_PROTOCOL=https
N8N_SSL_KEY=/path/to/key.pem
N8N_SSL_CERT=/path/to/cert.pem
```

## 🐛 Troubleshooting

### Error: "Command n8n not found"
- **Causa**: Comando incorrecto en `compose.yaml`
- **Solución**: Usa `command: worker` o `command: start` (sin el prefijo `n8n`)

### Los workflows no se ejecutan
- Verifica que Redis esté corriendo: `docker-compose ps`
- Revisa logs del worker: `docker-compose logs n8n-worker`
- Confirma `EXECUTIONS_MODE=queue` en `.env`

### No puedo acceder a localhost:5678
- Verifica que el puerto no esté ocupado: `lsof -i :5678`
- Revisa logs: `docker-compose logs n8n`
- Confirma que el servicio está corriendo: `docker-compose ps`

### Base de datos no se conecta
- Espera a que PostgreSQL esté listo (tiene healthcheck)
- Verifica credenciales en `.env`
- Revisa logs: `docker-compose logs db`

## 📚 Recursos

- [Documentación oficial de n8n](https://docs.n8n.io/)
- [n8n Community](https://community.n8n.io/)
- [n8n GitHub](https://github.com/n8n-io/n8n)
- [Docker Hub - n8n](https://hub.docker.com/r/n8nio/n8n)

## 🔐 Seguridad

⚠️ **Importante para Producción:**

1. Cambia `N8N_ENCRYPTION_KEY` por una clave segura generada aleatoriamente
2. Usa contraseñas fuertes para PostgreSQL
3. Configura `N8N_SECURE_COOKIE=true` si usas HTTPS
4. Restringe CORS en producción (elimina los `*`)
5. Usa variables de entorno seguras (secrets de Docker)
6. Considera usar un reverse proxy con autenticación

### Generar Nueva Encryption Key

```bash
openssl rand -base64 32
```

## 📊 Monitoreo

### Health Checks

Los servicios tienen health checks configurados:

```bash
# Ver estado de salud
docker-compose ps
```

### Métricas

Para habilitar métricas de Prometheus, agrega en `.env`:

```env
N8N_METRICS=true
N8N_METRICS_PREFIX=n8n_
```

## 🔄 Actualización

```bash
# 1. Detener servicios
docker-compose down

# 2. Actualizar versión en Dockerfile
# FROM docker.n8n.io/n8nio/n8n:1.XXX.X

# 3. Reconstruir y levantar
docker-compose build --no-cache
docker-compose up -d

# 4. Verificar logs
docker-compose logs -f
```

## 📄 Licencia

**n8n**: Este proyecto usa n8n, que está bajo [Apache 2.0 License con Commons Clause](https://github.com/n8n-io/n8n/blob/master/LICENSE.md). 

⚠️ **Nota importante**: La Commons Clause restringe el uso comercial de n8n como servicio SaaS. Si planeas ofrecer n8n como servicio a tus clientes, revisa las [opciones de licenciamiento empresarial de n8n](https://n8n.io/pricing/).

---

**¿Problemas?** Revisa los logs con `docker-compose logs -f` o abre un issue en el repositorio.