# docker-in-jenkins-in-docker

a.k.a. DinJinD

## Foreword

Trying to build Docker images from your Jenkins which is itself in a Docker container and still seeing `Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?` message? A solution is here!

If you want a Jenkins Docker image in which you can build Docker images, it is a bit tricky:
* To be able to run Docker commands in a Docker container, you need to use the [`wrapdocker` script from DinD project](https://github.com/jpetazzo/dind/blob/master/wrapdocker) and run your container with the [`--privileged` flag](https://docs.docker.com/engine/reference/run/#runtime-privilege-and-linux-capabilities).
* Because you cannot directly run multiple services in a container, you have to use a tool ([Supervisor](http://supervisord.org/) here) which will manage and run both Jenkins and Docker services. The container will then run Supervisor, which will start Jenkins and Docker.

## How-to

* Build image:
```
docker build -t docker-in-jenkins-in-docker .
```
* Run container:
```
docker run --privileged -it -p 8080:8080 docker-in-jenkins-in-docker
```
* Open Jenkins at `http://localhost:8080/`

## Pitfall with DNS

If you have a specific DNS configuration (like `nameserver` and `search` entries in `/etc/resolv.conf` configuration), you should forward this DNS configuration to the Docker daemon.
To do this, you have to create and configure `/etc/docker/daemon.json` file and specify `dns` and `dns-search` options.
For example, you can add these lines to your Dockerfile after the Docker installation:
```
RUN mkdir -p /etc/docker
RUN touch /etc/docker/daemon.json
RUN echo '{"dns":["8.8.8.8","a.b.c.d"],"dns-search":["search1.domain","search2.domain"]}' > /etc/docker/daemon.json
```

## See also

* https://github.com/jpetazzo/dind
* https://blog.docker.com/2013/09/docker-can-now-run-within-docker/
* https://blog.jayway.com/2015/03/14/docker-in-docker-with-jenkins-and-supervisord/
