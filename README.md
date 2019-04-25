# TRACS dockerfile

Creates the environment to run the TRACS toolkit. This image is based on an
ubuntu-14.04 docker image and includes the *fenics-1.5.0* version, it
contains the necessary packages to run (or develop) the TRACS toolkit
as well as the CLI and GUI executables.

* *Image corresponding to tracs_v1 branch* at [tracs](https://gitlab.cern.ch/sifca/tracs/tree/tracs_v1).
* *Tagged as 1.0* at [dockerhub](https://hub.docker.com/r/duartej/tracs)


## Installation
Assuming ```docker``` and ```docker-compose``` is installed on your system
(host-computer).

1. Clone the docker eudaq repository and configure it
```bash
$ git clone https://github.com/duartej/dockerfiles-tracs
$ cd dockerfiles-tracs
$ /bin/bash setup.sh
```
The ```setup.sh``` script will create some ```docker-compose_v1.yml``` file and
also creates the directories ```$HOME/repos/tracs``` if does not exist, while
downloading the code from the gitlab CERN repository (you need to introduce
your CERN user). The script will also switch the repository to the proper branch

2. Download the automated build from the dockerhub (**Recommended**): 
```bash
$ docker pull duartej/tracs:1.0
```
or alternativelly you can build an image from the
[Dockerfile](Dockerfile)
```bash
# Using docker
$ docker build github.com/duartej/dockerfiles-tracs#tracs_v1
# Using docker-compose within the repo directory
$ docker-compose build tracs-ubuntu
```

## Mount points
The containers created with the tracs image mount the directory 
* ```/home/tracs/tracs-code```,

and expect to be linked with the host machine directory where the TRACS repository 
is. If your using the ```docker-compose_v1.yml``` file (see _Installation_), this 
directory must be ```$HOME/repos/tracs``` in the host-machine.


## Usage
After the setup.sh, the ```docker-compose_v1.yml``` can be used to run any container:
```bash
docker-compose -f docker_compose_v1.yml run --rm devcode_v1
```
Or alternativelly, you can run it with ```docker```
```bash
$ docker run --rm -i \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e DISPLAY=unix${DISPLAY} \
    --mount type=bind,source=${CODEDIR},target=/home/tracs/code
    duartej/tracs:1.0
```
where ```CODEDIR``` points to the tracs repository directory of the host machine.
Don't forget to allow the docker group to use the X-server if you need to use
the X-windows:
```bash
xhost +local:docker
```


