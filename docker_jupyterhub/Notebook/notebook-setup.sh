#A file to copy configs into a users home directory before notebook startup
#
#
if [ ! -d /home/jovyan/custom/lib ]
  then
    mkdir -p /home/jovyan/custom/lib
fi
if [ ! -d /home/jovyan/custom/bin ]
  then
    mkdir -p /home/jovyan/custom/bin
fi
