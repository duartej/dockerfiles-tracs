# 
# TRACS Dockerfile
# https://github.com/duartej/dockerfiles-tracs
#
# Creates the environment to run the TRACS 
# utility and toolkit 
# 
# Uses phusion base image (actually an ubuntu 16.04)
# with some improvements in order to be used ubuntu
# in docker (https://github.com/phusion/baseimage-docker)
#
# Build the image:
# docker build -t duartej/tracs_v2 .

FROM phusion/baseimage:0.11
LABEL author="jorge.duarte.campderros@cern.ch" \ 
    version="0.2-alpha" \ 
    description="Docker image for refurbished TRACS-v2"

ARG ROOT_VERSION=6.18.00

# -- Update and get needed packages
USER root
RUN apt-get update \
  && install_clean --no-install-recommends software-properties-common \ 
  && add-apt-repository ppa:fenics-packages/fenics \  
  && apt-get update \ 
  && install_clean fenics \ 
  && install_clean --no-install-recommends \ 
  build-essential \
  python3-dev \ 
  python3-numpy \
  vim \ 
  libxpm4 \ 
  libxft2 \ 
  libxft-dev \
  libxpm-dev \ 
  libxext-dev \
  libtiff5 \ 
  libtbb2 \  
  wget \
  git \ 
  python3-click \ 
  python3-pip \ 
  python3-matplotlib \
  gmsh \
  sudo

# ROOT: 6.18/00
RUN mkdir /rootfr \ 
  && wget https://root.cern.ch/download/root_v${ROOT_VERSION}.source.tar.gz -O /rootfr/root.${ROOT_VERSION}.tar.gz \ 
  && tar -xf /rootfr/root.${ROOT_VERSION}.tar.gz -C /rootfr \ 
  && rm -rf /rootfr/root.${ROOT_VERSION}.tar.gz \ 
  && mkdir /rootfr/root \ 
  && cd /rootfr/root-${ROOT_VERSION} \ 
  && cd build \
  && cmake .. \
    -Dbuiltin_fftw3=ON \ 
    -Dbuiltin_freetype=ON \
    -Dbuiltin_pcre=ON \
    -Dbuiltin_lzma=ON \
    -Dbuiltin_unuran=ON \
    -Dbuiltin_veccore=ON \
    -Dbuiltin_xrootd=ON \ 
    -Dbuiltin_gsl=ON \
    -Dpython3=ON \
    -DPYTHON_EXECUTABLE:FILEPATH="/usr/bin/python3" \
    -DPYTHON_INCLUDE_DIR:PATH="/usr/include/python3.6m" \
    -DPYTHON_INCLUDE_DIR2:PATH="/usr/include/x86_64-linux-gnu/python3.6m" \
    -DPYTHON_LIBRARY:FILEPATH="/usr/lib/x86_64-linux-gnu/libpython3.6m.so" \
    -DCMAKE_INSTALL_PREFIX=/rootfr/root \
  && cmake --build . -- -j4 \ 
  && cmake --build . --target install \ 
  && rm -rf /rootfr/root-${ROOT-VERSION}

# ROOT use
ENV ROOTSYS /rootfr/root
# BE aware of the ROOT libraries
ENV LD_LIBRARY_PATH /rootfr/root/lib
ENV PYTHONPATH /rootfr/root/lib

# User, add it to sudoers, and change python2 to python3 default
RUN useradd -m -s /bin/bash -G sudo tracs \
  && echo "tracs:docker" | chpasswd \
  && echo "tracs ALL=(ALL) NOPASSWD: ALL\n" >> /etc/sudoers \
  && cat /etc/sudoers \
##  && mkdir /etc/service/syslog-forwarder \ 
##  && touch /etc/service/syslog-forwarder/down \
  && rm /etc/my_init.d/10_syslog-ng.init \ 
  && ldconfig \ 
  && if [[ -e /usr/bin/python ]]; then unlink /usr/bin/python; ln -sf /usr/bin/python3 /usr/bin/python; fi

WORKDIR /home/tracs

# Create the directory to place the code, it should be
# linked here when run the container: 
# docker run -it --rm --mount type=bind,source=/home/tracks/code,\
#    target=HOST_CODE -v /tmp/.X11-unix:/tmp/.X11-unix \ 
#    -e DISPLAY=unix${DISPLAY} \
#    --mount type=bind,source=/home/duarte/repos/tracs,target=/home/tracs/code duartej/tracs_v2duartej/tracs_v2 
USER tracs
RUN touch /home/tracs/.sudo_as_admin_successful && \
  mkdir /home/tracs/tracs-code
VOLUME /home/tracs/tracs-code
# Some friendly accesories to the python interpreter
COPY pythonlogon_py /home/tracs/.pythonlogon.py

ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/home/tracs/tracs-code/build/src"
ENV PYTHONPATH="${PYTHONPATH}:/home/tracs/tracs-code/build/tracspy/python"
ENV PYTHONSTARTUP="/home/tracs/.pythonlogon.py"
ENV PATH="${PATH}:/rootfr/root/bin:/home/tracs/tracs-code/build/tracspy/bin"

RUN pip3 install --user meshio lxml h5py

USER root
ENTRYPOINT ["/sbin/my_init","--quiet","--","/sbin/setuser","tracs","/bin/bash","-l","-c"]
CMD ["/bin/bash","-i"]
