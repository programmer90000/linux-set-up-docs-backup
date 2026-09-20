Test this on a VM. If the command runs, add it to the main repo. Note: Docker should be able to run on a VM:

```
sudo apt update
sudo apt install docker.io docker-cli ca-certificates apparmor
```

To check if it is installed correctly, run:
```
docker --version
sudo docker run hello-world
```

> Important: Docker requires sudo to run. I can stop this by adding users to the group docker. Do not add any users to the group docker as this is a security risk.