# TRACS dockerfile

Creates the environment to run the TRACS toolkit.
This image is based on an
(phusion-baseimage)[https://github.com/phusion/baseimage-docker]
and contains the necessary packages to run (or develop) the 
TRACS toolkit as well as the CLI and GUI executables.

This is the tracs-v2 version (re-furbished).

## Installation
Assuming ```docker``` and ```docker-compose``` is 
installed on your system (host-computer).

1. Clone the docker eudaq repository and configure it
```bash 
$ git clone https://github.com/duartej/dockerfiles-tracs
$ cd dockerfiles-tracs
$ source setup.sh
```
The ```setup.sh``` script will create 
some ```docker-compose.yml``` file and also creates
the directories ```$HOME/repos/tracs``` if does not 
exist, when downloading the code from the gitlab CERN repository
(you need to introduce your CERN user). 
Note that if you previously download the repository, do not 
forget to switch to the proper branch before running any container
```bash
git checkout tracs_v2_refurbished
```

2. Download the automated build from the dockerhub: 
```bash
$ docker pull duartej/tracs:2.0
```
or alternativelly you can build an image from the
[Dockerfile](Dockerfile)
```bash
# Using docker
$ docker build github.com/duartej/tracs:2.0
# Using docker-compose within the repo directory
$ docker-compose build tracs-phusion
```

## Mount points
The containers created with the tracs image mount the directory 
```/home/tracs/code```, and expect to be linked with the host 
machine directory where the TRACS repository is ```$HOME/repos/tracs```


## Usage
After the setup.sh, the ```docker-compose.yml``` can be used to 
run any container:
```bash
docker-compose --rm devcode
```
Or alternativelly, you can run it with ```docker```
```bash
$ docker run --rm -i \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e DISPLAY=unix${DISPLAY} \
    --mount type=bind,source=${HOME}/repos/tracs,target=/home/tracs/code
    duartej/tracs:v2.0
```


