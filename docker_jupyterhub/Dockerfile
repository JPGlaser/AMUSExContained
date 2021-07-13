# Choose your desired base image
FROM jupyter/minimal-notebook:latest

USER root
COPY Notebook/start-singleuser.sh /usr/local/bin/start-singleuser.sh
COPY Notebook/notebook-setup.sh /usr/local/bin/notebook-setup.sh
COPY Notebook/00-initialize.py /home/jovyan/.ipython/profile_default/startup/00-initialize.py

# ----------------------------------------
# Install MKL Libraries
# ----------------------------------------
RUN apt update && /bin/sh -c "apt install -y intel-mkl-full libmkl-full-dev"

# ----------------------------------------
# Install Neccessary Core Debian Packages
# ----------------------------------------
RUN apt update && /bin/sh -c "apt install -y tightvncserver xinit xterm dbus-x11 xfce4 \
    xfce4-terminal cmake build-essential gfortran tcsh \
    dh-autoreconf pgplot5 libfftw3-dev libcfitsio-dev latex2html \
    pkg-config libglib2.0-dev curl imagemagick less dvipng \
    libgsl-dev gedit vim nano evince vim-gtk git \
    openssh-client libnetcdf-dev libgmp-dev libmpfr6 libgmp3-dev libhdf5-serial-dev \
    libhdf5-dev hdf5-tools libmpfr-dev libfftw3-3 libfftw3-dev libfftw3-doc \
    pdftk libgfortran4 libgfortran5 fort77 libpng-dev" && apt clean

# ----------------------------------------
# Install OpenMPI and Append the Path Variables
# ----------------------------------------
RUN echo "Installing Open MPI" && \
    export OMPI_DIR=/opt/ompi && \
    export OMPI_VERSION=4.1.1 && \
    export OMPI_URL="https://download.open-mpi.org/release/open-mpi/v4.1/openmpi-$OMPI_VERSION.tar.bz2" && \
    mkdir -p /tmp/ompi && \
    mkdir -p /opt && \
    cd /tmp/ompi && \
    wget -O openmpi-$OMPI_VERSION.tar.bz2 $OMPI_URL && \
    tar -xjf openmpi-$OMPI_VERSION.tar.bz2 && \
    ls /tmp/ompi && ls /tmp && \
    cd /tmp/ompi/openmpi-$OMPI_VERSION && \
    ./configure --prefix=$OMPI_DIR && \
    make -j8 install
ENV PATH=/opt/ompi/bin:$PATH
ENV LD_LIBRARY_PATH=/opt/ompi/lib:$LD_LIBRARY_PATH

# ----------------------------------------
# Install Neccessary Core Python Packages
# [This includes necessary uninstalls to ]
# [enable Intel MKL libraries for speed. ]
# ----------------------------------------
RUN conda update -y -n base conda
RUN conda install -y -n base "libblas=*=*mkl" && \
    pip uninstall -y numpy && \
    conda install -y -n base "libblas=*=*mkl" numpy -c defaults --force-reinstall
RUN pip uninstall -y ipympl matplotlib numba numexpr pandas patsy scipy seaborn
RUN conda install -y -c defaults -n base "libblas=*=*mkl" astropy bokeh bottleneck h5py imagecodecs \
    ipympl matplotlib numba numexpr pandas patsy scikit-sparse scipy \
    seaborn seaborn-base yt gmp mpfr nose && \
    conda clean -y --tarballs
RUN pip install wand marshmallow requests_oauthlib Cython \
    corner PyYAML ruamel.yaml pytest docutils quilt nose
RUN env MPICC=/opt/ompi/bin/mpicc pip install mpi4py

# ----------------------------------------
# Install AMUSE (2021.7.13)
# ----------------------------------------
WORKDIR /opt/
RUN git clone https://github.com/amusecode/amuse.git && \
    cd amuse && ./configure && make && pip install -e .

# ----------------------------------------
# Install SuiteSparse (5.8.1)
# ----------------------------------------
RUN conda install -y -c conda-forge -n base suitesparse ptmcmcsampler

# ----------------------------------------
# Setting Up PGPLOT Environments
# ----------------------------------------
ENV PGPLOT_DIR=/usr/lib/pgplot5
ENV PGPLOT_FONT=/usr/lib/pgplot5/grfont.dat
ENV PGPLOT_INCLUDES=/usr/include
ENV PGPLOT_BACKGROUND=white
ENV PGPLOT_FOREGROUND=black
ENV PGPLOT_DEV=/xs

# ----------------------------------------
# Setting up Jupyter Desktop Server
# ----------------------------------------
WORKDIR /opt/src
RUN git clone https://github.com/novnc/websockify.git && \
    cd websockify && \
    python setup.py install && \
    pip install git+https://github.com/yuvipanda/jupyter-desktop-server.git

# ----------------------------------------
# Finishing/Cleaning Up
# ----------------------------------------
RUN chown -R jovyan /home/jovyan && \
    chown -R jovyan:users /opt/conda && \
    chown -R jovyan:users /opt/amuse && \
    apt clean && \
    conda clean -a
WORKDIR /home/jovyan
USER $NB_USER
