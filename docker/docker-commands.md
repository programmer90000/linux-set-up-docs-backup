# Inspection & Info
| Command | Description |
|---------|-------------|
| docker version | client + daemon versions |
| docker info | system-wide info (containers, images, storage) |
| sudo docker ps | running containers |
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

# Running containers
| Command | Description |
|---------|-------------|
| docker run nginx | Basic run |
| docker run -d --name web -p 8080:80 nginx | Detached (background) + name + port mapping |
| docker run -it --rm ubuntu bash | Interactive shell (great for debugging images) |
| docker run -d -e MYSQL_ROOT_PASSWORD=secret mysql | With an environment variable |
| docker run -d -v mydata:/var/lib/mysql mysql | With a persistent volume |
| docker run -d -v $(pwd)/html:/usr/share/nginx/html nginx | Bind-mount a host directory |
| docker run -d --restart unless-stopped nginx | Auto-restart on crash/reboot |
| docker run -d --network mynet --name api myapp | Attach to a network |
| docker run -d --cpus="1.5" --memory="512m" nginx | Limit resources |


| Flag | Meaning |
|------|---------|
| -d | detached (background) |
| -it | interactive + TTY |
| --rm | delete container on exit |
| -p host:container | publish port |
| -v | mount volume or bind path |
| -e KEY=value | env variable |
| --name | give it a name |
| --network | attach to network |
| --restart | restart policy |


# Managing Containers
| Command | Description |
|---------|-------------|
| docker stop <container> | graceful stop |
| docker start <container> | start a stopped container |
| docker restart <container> | stop + start |
| docker kill <container> | force kill |
| docker rm <container> | delete a stopped container |
| docker rm -f <container> | force delete (even running) |
| docker rename old new | rename |
| docker stop $(docker ps -q) | Stop ALL containers |
| docker rm $(docker ps -aq) | Remove ALL containers |

# Interacting with running containers
| Command | Description |
|---------|-------------|
| docker exec -it <container> bash | shell in |
| docker exec -it <container> sh | if bash isn't installed |
| docker exec <container> ls /app | run a one-off command |
| docker exec -u root -it <c> bash | as a specific user |
| docker cp file.txt <container>:/app/ | copy host → container |
| docker cp <container>:/app/log.txt . | copy container → host |
| docker attach <container> | attach to main process (Ctrl-P Ctrl-Q to detach) |

# Images

| Command | Description |
|---------|-------------|
| docker pull nginx:1.27 | download specific tag |
| docker pull nginx | latest |
| docker push myrepo/myapp:1.0 | upload to registry |
| docker build -t myapp:1.0 . | build from Dockerfile in cwd |
| docker build -t myapp:1.0 -f other.Dockerfile . | build with alternate Dockerfile |
| docker tag myapp:1.0 myrepo/myapp:1.0 | tag an image |
| docker rmi <image> | delete image |
| docker rmi -f <image> | force delete |
| docker history <image> | layer breakdown |
| docker save -o myapp.tar myapp:1.0 | export image to file |
| docker load -i myapp.tar | import image from file |

# Volumes (Presistent data)
| Command | Description |
|---------|-------------|
| docker volume create mydata | create a volume |
| docker volume ls | list volumes |
| docker volume inspect mydata | inspect a volume |
| docker volume rm mydata | remove a volume |
| docker volume prune | remove unused volumes |

# Networks
| Command | Description |
|---------|-------------|
| docker network create mynet | create a network |
| docker network ls | list networks |
| docker network inspect mynet | inspect a network |
| docker network connect mynet <container> | connect container to network |
| docker network disconnect mynet <container> | disconnect container |
| docker network rm mynet | remove a network |
| docker network prune | remove unused networks |

# Docker Compose (Multi-Container Apps)
| Command | Description |
|---------|-------------|
| docker compose up -d | start all services in background |
| docker compose up --build | rebuild images first |
| docker compose down | stop + remove containers/networks |
| docker compose down -v | also remove volumes |
| docker compose ps | status |
| docker compose logs -f | follow logs |
| docker compose logs -f web | one service |
| docker compose exec web bash | shell into a service |
| docker compose restart web | restart a service |
| docker compose pull | update images |
| docker compose config | validate/print config |

# Cleanup
| Command | Description |
|---------|-------------|
| docker system df | disk usage summary |
| docker system prune | remove stopped containers, dangling images, unused networks |
| docker system prune -a | also remove ALL unused images (aggressive) |
| docker system prune -a --volumes | ALSO remove volumes ⚠️ data loss |
| docker container prune | stopped containers only |
| docker image prune | dangling images |
| docker image prune -a | all unused images |
| docker volume prune | unused volumes |
| docker builder prune | build cache |

# Daemon / Service Management (systemd)
| Command | Description |
|---------|-------------|
| sudo systemctl start docker | start the daemon |
| sudo systemctl stop docker | stop the daemon |
| sudo systemctl restart docker | restart the daemon |
| sudo systemctl status docker | check status |
| sudo systemctl enable docker | start on boot |
| sudo journalctl -u docker -f | daemon logs |

# Handy One-Liners
```
# Kill all running containers
docker kill $(docker ps -q)

# Remove all stopped containers
docker rm $(docker ps -aq)

# Remove all images
docker rmi $(docker images -q)

# Get a container's IP
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' <c>

# Follow logs for all compose services
docker compose logs -f --tail=50

# Shell into the most recently started container
docker exec -it $(docker ps -lq) bash

# Tail logs and grep
docker logs -f <c> 2>&1 | grep ERROR
```

# Quick Mental Model
| You want to… | Command |
|--------------|---------|
| See what's running | docker ps |
| Start something | docker run … |
| Get inside it | docker exec -it … bash |
| See its output | docker logs -f … |
| Stop it | docker stop … |
| Delete it | docker rm … |
| Reclaim disk | docker system prune |


# Tip
| Tip | Description |
|-----|-------------|
| Always name your containers | (--name) — random names are painful to manage |
| Use --rm for throwaway containers | so they clean up automatically |
| Prefer Compose | over long docker run commands once you have 2+ services |
| Use volumes, not bind mounts | for data you want Docker to manage |
| Tag images explicitly | (myapp:1.0, not latest) — latest is a lie in production |
| docker logs before docker exec | logs usually tell you what's wrong faster |
| Run docker system df | when disk fills up — build cache is often the culprit |
