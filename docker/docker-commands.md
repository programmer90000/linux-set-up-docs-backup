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