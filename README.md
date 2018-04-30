# TRACS dockerfile

Creates the environment to run [TRACS](). 
This image is based on an ubuntu-16.04 and contains
the necessary packages to run (or develop) TRACS

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
some ```docker-compose*.yml``` files. It also creates
the directories ```$HOME/eudaq_data/logs``` and 
```$HOME/eudaq_data/data```, where logs and raw data will
be sent in the host computer.

Note that a eudaq repository will be clone at 
```$HOME/repos/eudaq``` (unless it is already in that location).
This repository will be linked to the containers in ```development```
mode.

2. Download the automated build from the dockerhub: 
```bash
$ docker pull duartej/tracs-ubuntu
```
or alternativelly you can build an image from the
[Dockerfile](Dockerfile)
```bash
# Using docker
$ docker build github.com/duartej/tracs
# Using docker-compose within the repo directory
$ docker-compose build tracs-ubuntu
```

TRACS is built under a ubuntu-16.04 docker image and including
 * fenics-1.5.0

