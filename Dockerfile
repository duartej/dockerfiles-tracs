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
   libvtk7.1-qt \ 
   libvtk7-qt-dev \ 
   libxpm4 \ 
   wget \
   git \ 
   python3-click \ 
   python3-pip \ 
   python3-matplotlib \
   gmsh \
   sudo \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# ROOT: 6.18/00 (get it from a different image)
COPY --from=duartej/rootpython3:6.18.0 /rootfr/root /rootfr/root

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
  && if [ -e /usr/bin/python ]; then unlink /usr/bin/python; ln -sf /usr/bin/python3 /usr/bin/python; fi

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
