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


