# Inspection & Info
| Command | Description |
|---------|-------------|
| docker version | client + daemon versions |
| docker info | system-wide info (containers, images, storage) |
| sudo docker ps | running containers |
| sudo docker ps -a | ALL containers (incl. stopped) |
| sudo docker images | local images |
| sudo docker image ls | same as above |
| sudo docker volume ls | list volumes |
| sudo docker network ls | list networks |
| sudo docker stats | live CPU/mem/net usage per container |
| sudo docker inspect <container\|image> | full JSON details |
| sudo docker logs <container> | stdout/stderr logs |
| sudo docker logs -f <container> | follow logs live |
| sudo docker logs --tail 100 <c> | last 100 lines |
| sudo docker port <container> | show port mappings |
| sudo docker top <container> | processes inside a container |

# Running containers
| Command | Description |
|---------|-------------|
| sudo docker run nginx | Basic run |
| sudo docker run -d --name web -p 8080:80 nginx | Detached (background) + name + port mapping |
| sudo docker run -it --rm ubuntu bash | Interactive shell (great for debugging images) |
| sudo docker run -d -e MYSQL_ROOT_PASSWORD=secret mysql | With an environment variable |
| sudo docker run -d -v mydata:/var/lib/mysql mysql | With a persistent volume |
| sudo docker run -d -v $(pwd)/html:/usr/share/nginx/html nginx | Bind-mount a host directory |
| sudo docker run -d --restart unless-stopped nginx | Auto-restart on crash/reboot |
| sudo docker run -d --network mynet --name api myapp | Attach to a network |
| sudo docker run -d --cpus="1.5" --memory="512m" nginx | Limit resources |


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
| sudo docker stop <container> | graceful stop |
| sudo docker start <container> | start a stopped container |
| sudo docker restart <container> | stop + start |
| sudo docker kill <container> | force kill |
| sudo docker rm <container> | delete a stopped container |
| sudo docker rm -f <container> | force delete (even running) |
| sudo docker rename old new | rename |
| sudo docker stop $(docker ps -q) | Stop ALL containers |
| sudo docker rm $(docker ps -aq) | Remove ALL containers |

# Interacting with running containers
| Command | Description |
|---------|-------------|
| sudo docker exec -it <container> bash | shell in |
| sudo docker exec -it <container> sh | if bash isn't installed |
| sudo docker exec <container> ls /app | run a one-off command |
| sudo docker exec -u root -it <c> bash | as a specific user |
| sudo docker cp file.txt <container>:/app/ | copy host → container |
| sudo docker cp <container>:/app/log.txt . | copy container → host |
| sudo docker attach <container> | attach to main process (Ctrl-P Ctrl-Q to detach) |

# Images

| Command | Description |
|---------|-------------|
| sudo docker pull nginx:1.27 | download specific tag |
| sudo docker pull nginx | latest |
| sudo docker push myrepo/myapp:1.0 | upload to registry |
| sudo docker build -t myapp:1.0 . | build from Dockerfile in cwd |
| sudo docker build -t myapp:1.0 -f other.Dockerfile . | build with alternate Dockerfile |
| sudo docker tag myapp:1.0 myrepo/myapp:1.0 | tag an image |
| sudo docker rmi <image> | delete image |
| sudo docker rmi -f <image> | force delete |
| sudo docker history <image> | layer breakdown |
| sudo docker save -o myapp.tar myapp:1.0 | export image to file |
| sudo docker load -i myapp.tar | import image from file |

# Volumes (Presistent data)
| Command | Description |
|---------|-------------|
| sudo docker volume create mydata | create a volume |
| sudo docker volume ls | list volumes |
| sudo docker volume inspect mydata | inspect a volume |
| sudo docker volume rm mydata | remove a volume |
| sudo docker volume prune | remove unused volumes |

# Networks
| Command | Description |
|---------|-------------|
| sudo docker network create mynet | create a network |
| sudo docker network ls | list networks |
| sudo docker network inspect mynet | inspect a network |
| sudo docker network connect mynet <container> | connect container to network |
| sudo docker network disconnect mynet <container> | disconnect container |
| sudo docker network rm mynet | remove a network |
| sudo docker network prune | remove unused networks |

# Docker Compose (Multi-Container Apps)
| Command | Description |
|---------|-------------|
| sudo docker compose up -d | start all services in background |
| sudo docker compose up --build | rebuild images first |
| sudo docker compose down | stop + remove containers/networks |
| sudo docker compose down -v | also remove volumes |
| sudo docker compose ps | status |
| sudo docker compose logs -f | follow logs |
| sudo docker compose logs -f web | one service |
| sudo docker compose exec web bash | shell into a service |
| sudo docker compose restart web | restart a service |
| sudo docker compose pull | update images |
| sudo docker compose config | validate/print config |

# Cleanup
| Command | Description |
|---------|-------------|
| sudo docker system df | disk usage summary |
| sudo docker system prune | remove stopped containers, dangling images, unused networks |
| sudo docker system prune -a | also remove ALL unused images (aggressive) |
| sudo docker system prune -a --volumes | ALSO remove volumes ⚠️ data loss |
| sudo docker container prune | stopped containers only |
| sudo docker image prune | dangling images |
| sudo docker image prune -a | all unused images |
| sudo docker volume prune | unused volumes |
| sudo docker builder prune | build cache |

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
sudo docker kill $(docker ps -q)

# Remove all stopped containers
sudo docker rm $(docker ps -aq)

# Remove all images
sudo docker rmi $(docker images -q)

# Get a container's IP
sudo docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' <c>

# Follow logs for all compose services
sudo docker compose logs -f --tail=50

# Shell into the most recently started container
sudo docker exec -it $(docker ps -lq) bash

# Tail logs and grep
sudo docker logs -f <c> 2>&1 | grep ERROR
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
