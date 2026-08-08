# Dockerfile

A Dockerfile is a file with the name `Dockerfile`. It has no extension and has an uppercase `D`

## FROM

The `FROM` line takes another Docker image and installs it. Everything used in the Docker file of this image is run added to the Docker image I make.

Example:
```
FROM nodejs:8.5.1
```

## WORKDIR

The `WORKDIR` line specifies the directory to run all future commands in this Docker file, inside the Docker container

Example:
```
WORKDIR /home/user/Desktop/
```

All of the commands after this line will be run inside the `/home/user/Desktop` directory

## COPY

The `COPY` line copies files from the host computer into the Docker container.

Example:
```
COPY file.txt .
```

This will get `file.txt` from my host computer. It will copy it into the Docker container at location `.`

## RUN

Run a command in the terminal inside the Docker container to build the image

## EXPOSE

The `EXPOSE` line doesn't do anything. It is used as metadata to inform the user which port the Docker container will be running on. However, it doesn't actually run the container on that port or expose the container to that port

## ENV

The `ENV` line sets environment variables

Example:
```
ENV NODE=/usr/bin/nodejs
```

## CMD

Run a command in the terminal inside Docker to run the container

CMD ["node" "myapp.js"]