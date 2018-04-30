#!/bin/bash

# TRACS integration docker image setup
# Run it first time to create all the needed
# infrastructure,
#!/bin/bash
# 
# Setup the enviroment to use the EUDAQ docker
# container. It will download the TRACS code 
# and download it on
#  - $HOME/repos/tracs
# and create the proper 
#  - docker-compose yaml files 
# 
# jorge.duarte.campderros@cern.ch (CERN/IFCA)
#

# 1. Check it is running as regular user
if [ "${EUID}" -eq 0 ];
then
    echo "Do not run this as root"
    exit -2
fi

# 2. Check if the setup was run:
if [ -e ".setupdone" ];
then
    echo "DO NOT DOING ANYTHING, THE SETUP WAS ALREADY DONE:"
    echo "=================================================="
    cat .setupdone
    exit -3
fi

DOCKERDIR=${PWD}

# 3. Download the code: XXX This can be done in the image actually
# Get ready to download the code from sifca gitlab
echo 'Download the code from the CERN gitlab'
read -r -p 'Enter your CERN user: ' CERNUSER
CODEDIR=${HOME}/repos/tracs
mkdir -p ${CODEDIR} && cd ${CODEDIR}/.. ;
if [ "X$(command -v git)" == "X" ];
then
    echo "You will need to install git (https://git-scm.com/)"
    exit -1;
fi

echo "Cloning TRACS into : $(pwd)"
git clone https://${CERNUSER}@gitlab.cern.ch:8443/sifca/tracs.git tracs

if [ "$?" -eq 128 ];
then
    echo "Repository already available at '${CODEDIR}'"
    echo "Remove it if you want to re-clone it"
else
    # Change to the tracs_v1 branch
    echo "Switch to tracs-v1 branch"
    git checkout tracs_v1
fi

# 3. Fill the place-holders of the .templ-Dockerfile 
#    and .templ-docker-compose.yml and create the needed
#    directories
cd ${DOCKERDIR}
# -- copying relevant files
for dc in .templ-docker-compose.yml;
do
    finalf=$(echo ${dc}|sed "s/.templ-//g")
    cp $dc $finalf
    sed -i "s#@CODEDIR#${CODEDIR}#g" $finalf
done

# 4. Create a .setupdone file with some info about the
#    setup
cat << EOF > .setupdone
TRACS integration docker image and services
TRACS v2: re-furbished
-------------------------------------------
Last setup performed at $(date)
CODE DIRECTORY: ${CODEDIR}
EOF
cat .setupdone

