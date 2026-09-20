Test this on a VM. If the command runs, add it to the main repo:

```
sudo apt update
sudo apt install docker.io docker-cli ca-certificates apparmor
```

To run Docker without sudo, run:
```
sudo usermod -aG docker $USER
```

Logout and back in

To check if it is installed correctly, run:
```
docker --version
sudo docker run hello-world
```