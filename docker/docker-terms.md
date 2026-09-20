| Term | Meaning |
| --- | --- |
| Image | A read-only template (like a snapshot) containing the app + dependencies. Built from a Dockerfile. |
| Container | A running (or stopped) instance of an image. You can run many containers from one image. |
| Dockerfile | A text file with instructions to build an image. |
| Registry | A storage/distribution server for images. Docker Hub is the default public one. |
| Volume | Persistent storage that survives container restarts/deletion. |
| Network | A virtual network connecting containers to each other and the outside world. |
| Daemon (dockerd) | The background service that manages images, containers, networks, and volumes. |
| CLI (docker) | The command-line client you use to talk to the daemon. |