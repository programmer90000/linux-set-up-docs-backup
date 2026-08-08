# Components

## Images

A Docker image is a read-only template with instructions for creating a Docker container. It's a snapshot of a filesystem and application configuration at a specific point in time. Once an image is created, it can't be changed

An image contains:
- The OS to run
- The application code
- The application dependencies
- The application configuration
- Environment variables
- Any commands needed to run

### Display all downloaded images

To display all of the downloaded images, run:
```
docker image ls
```

### Docker Hub

Docker Hub is Docker's official cloud-based registry service for sharing and managing container images. It contains many images, allowing me to pull an image directly from there instead of setting it up myself

#### Pull an image from Docker Hub

To pull an image from Docker Hub, run:
```
docker pull NAME-OF-IMAGE
```

## Containers

A Docker container is a running instance of a Docker images

## Run a container

### Make a container from an image and run it

Run:
```
docker run NAME-OF-IMAGE
```

### Make a container from an image, run it and then delete the container

Run:
```
docker run --rm NAME-OF-IMAGE
```

### If the image doesn't exist

If the image I try to run doesn't exist, Docker will try to find and download that image and then run that image

### Display all containers

To display all of the containers, run:
```
docker ps -a
```

### Display only running containers

To display all of the running containers, run:
```
docker ps
```

### Display logs for a container

Run:
```
docker logs CONTAINER-ID
```

### Run commands inside a container

Run:
```
docker exec -it CONTAINER-ID PROGRAM-TO-EXECUTE
```

The program to execute is the shell to execute. For example: `/bin/sh`

> Note: -it stands for interactive

### Stop a container

Run:
```
docker stop CONTAINER-ID
```

## Volumes

A Docker volume is a data storage that exists independently of containers. Volumes allow data to presist even when containers are removed. I can save data to a volume and use it across multiple containers

### Create a volume

Run:
```
docker volume create VOLUME-NAME
```

### Use a volume

When running the Docker container, add the volume with the `-v VOLUME-NAME:DIRECTORY-TO-LOAD-IT-TO`

For example:
```
docker run -v VOLUME-NAME:DIRECTORY-TO-LOAD-IT-TO NAME-OF-IMAGE
``` 

## DOCKERFILE

To run a Dockerfile, run:
```
docker run -p 5000:2000 NAME-OF-IMAGE
```

`-p` stands for port. The first port is the host port. The second port is the container port

This will run the docker container on port 2000 and allow me to access it on my local computer using port 5000

## COMPOSE

Mae a `docker-compose.yaml` file. This file allows me to make 

### VERSION

The version key states which version of Docker to use
```
version: "`VERSION-OF-DOCKER-TO-USE-IN-BETWEEN-QUOTES"
```

### SERVICES

```
services:
    SERVICE-NAME:
        image: IMAGE-NAME
        ports:
            - "PORT-TO-USE-IN-BETWEEN-QUOTES"
        depends-on:
            - SERVICE-2-NAME
        environment:
            ENVIRONMENT-VARIABLE-1: ENVIRONMENT-VARIABLE-VALUE-1
            ENVIRONMENT-VARIABLE-2: ENVIRONMENT-VARIABLE-VALUE-2
            ENVIRONMENT-VARIABLE-2: ENVIRONMENT-VARIABLE-VALUE-2
    SERVICE-2-NAME:
        image: IMAGE-2-NAME
        ports:
            - "PORT-TO-USE-IN-BETWEEN-QUOTES"
        environment:
            ENVIRONMENT-VARIABLE-1: ENVIRONMENT-VARIABLE-VALUE-1
            ENVIRONMENT-VARIABLE-2: ENVIRONMENT-VARIABLE-VALUE-2
            ENVIRONMENT-VARIABLE-2: ENVIRONMENT-VARIABLE-VALUE-2
        volumes:
            - ./path/on/host/:/path/to/map/to/on/container
```

### NETWORKS

```
networks:
    NETWORK-NAME:
        ipam:
            driver: DRIVER-TO-USE-USUALLY-DEFAULT
            config:
                - subnet: "`SUBNET IP IN BETWEEN QUOTES`"
```

### RUN THE COMPOSE FILE

Run:
```
sudo docker-compose up
```

### STOP THE THINGS RUN BY THE COMPOSED FILE

Run:
```
sudo docker-compose stop
```

### STOP AND DELETE EVERYTHING MADE BY THE COMPOSED FILE

Run:
```
sudo docker-compose down
```