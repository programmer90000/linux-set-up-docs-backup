# Inspection & Info
| Command | Description |
|---------|-------------|
| docker version | client + daemon versions |
| docker info | system-wide info (containers, images, storage) |
| docker ps | running containers |
| docker ps -a | ALL containers (incl. stopped) |
| docker images | local images |
| docker image ls | same as above |
| docker volume ls | list volumes |
| docker network ls | list networks |
| docker stats | live CPU/mem/net usage per container |
| docker inspect <container\|image> | full JSON details |
| docker logs <container> | stdout/stderr logs |
| docker logs -f <container> | follow logs live |
| docker logs --tail 100 <c> | last 100 lines |
| docker port <container> | show port mappings |
| docker top <container> | processes inside a container |

