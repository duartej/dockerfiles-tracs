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
$ source setup.sh
```
The ```setup.sh``` script will create some ```docker-compose.yml``` file and
also creates the directories ```$HOME/repos/tracs``` if does not exist, while
downloading the code from the gitlab CERN repository (you need to introduce
your CERN user).
*If you previously download the repository, do not forget to switch to the proper
branch before running any container*
```bash
git checkout tracs_v1
```

2. Download the automated build from the dockerhub: 
```bash
$ docker pull duartej/tracs:1.0
```
or alternativelly you can build an image from the
[Dockerfile](Dockerfile)
```bash
# Using docker
$ docker build github.com/duartej/dockerfiles-tracs#tracs_v1
# Using docker-compose within the repo directory
$ docker-compose build tracs-phusion
```

## Mount points
The containers created with the tracs image mount the directory 
* ```/home/tracs/code```,

and expect to be linked with the host machine directory where the TRACS repository 
is. If your using the ```docker-compose.yml``` file (see _Installation_), this 
directory must be ```$HOME/repos/tracs``` in the host-machine.


## Usage
After the setup.sh, the ```docker-compose.yml``` can be used to run any container:
```bash
docker-compose --rm devcode
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


