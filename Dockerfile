# 
# TRAnsient Current Simulator Dockerfile
# https://github.com/duartej/dockerfiles-tracs
#
# Creates the environment to run TRACS
#
FROM ubuntu:14.04
LABEL author="jorge.duarte.campderros@cern.ch" \ 
    version="0.1-alpha" \ 
    description="Docker image for TRACS"

# Install all dependencies
RUN apt-get update && apt-get -y install \
  software-properties-common \
  build-essential \ 
  git \ 
  cmake \ 
  vim \ 
  g++ \
  gcc \
  gfortran \
  binutils \
  libxpm4 \ 
  libxft2 \ 
  libtiff5 \ 
  libvtk5-qt4-dev \ 
  wget \ 
  && rm -rf /var/lib/apt/lists/*

# ROOT 
RUN mkdir /rootfr \ 
  && wget https://root.cern.ch/download/root_v6.12.06.Linux-ubuntu14-x86_64-gcc4.8.tar.gz -O /rootfr/root.v6.12.06.tar.gz \ 
  && tar -xf /rootfr/root.v6.12.06.tar.gz -C /rootfr \ 
  && rm -rf /rootfr/root.v6.12.06.tar.gz

# Install fenics and remove extra info
RUN add-apt-repository ppa:fenics-packages/fenics-1.5.x \
  && apt-get update \ 
  && apt-get install -y fenics \ 
  && apt-get -y dist-upgrade \ 
  && apt-get install -y ipython-notebook \ 
  && apt-get install -y paraview \
  && add-apt-repository --remove ppa:fenics-packages/fenics-1.5.x \ 
  && apt-get install -y ppa-purge 
  # && ppa-purge ppa:fenics-packages/fenics-1.5.x

ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/eudaq/eudaq/lib"
ENV PYTHONPATH="${PYTHONPATH}:/eudaq/eudaq/lib:/eudaq/eudaq/python"
ENV PATH="${PATH}:/rootfr/root/bin:/eudaq/eudaq/bin"

# Create the tracs user, add it to the sudoers
RUN useradd -md /home/tracs -ms /bin/bash -G sudo tracs \
  && echo "tracs:docker" | chpasswd \
  && echo "tracs ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
  && mkdir /home/tracs/tracs-code && chown tracs:tracs /home/tracs/tracs-code

USER tracs

ENV ROOTSYS /rootfr/root
# BE aware of the ROOT libraries
ENV LD_LIBRARY_PATH /rootfr/root/lib
ENV PYTHONPATH /rootfr/root/lib

WORKDIR /home/tracs

