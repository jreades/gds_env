FROM darribas/gds_py:4.1

MAINTAINER Dani Arribas-Bel <D.Arribas-Bel@liverpool.ac.uk>

# https://github.com/ContinuumIO/docker-images/blob/master/miniconda3/Dockerfile
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

USER root

# Remove Conda from path to not interfere with R install
RUN echo ${PATH}
ENV PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
RUN echo ${PATH}

#--- Utilities ---#

RUN add-apt-repository -y ppa:ubuntugis/ubuntugis-experimental \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    dirmngr \
    gpg-agent \
    jq \
    libjq-dev \
    lbzip2 \
    libatk1.0-0 \
    libcairo2-dev \
    libfftw3-dev \
    libgdal-dev \
    libgeos-dev \
    libgsl0-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libhdf4-alt-dev \
    libhdf5-dev \
    liblwgeom-dev \
    libproj-dev \
    libprotobuf-dev \
    libnetcdf-dev \
    libsqlite3-dev \
    libssl1.0.0 \
    libssl-dev \
    libudunits2-dev \
    libv8-3.14-dev \
    libx11-6 \
    libxtst6 \
    netcdf-bin \
    protobuf-compiler \
    tk-dev \
    unixodbc-dev \
    wget \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

#--- R ---#
# https://github.com/rocker-org/rocker-versioned/blob/master/r-ver/Dockerfile
# Look at: http://sites.psu.edu/theubunturblog/installing-r-in-ubuntu/

RUN echo "deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/" >> /etc/apt/sources.list \
 && sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 \
 && apt-get update \
 && apt-get install -y \
    r-base \
    r-base-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*


RUN R -e "install.packages(c( \
            'arm', \
            'BiocManager', \
            'classInt', \
            'deldir', \
            'devtools', \
            'feather', \
            'geojsonio', \
            'ggmap', \
            'GISTools', \
            'gstat', \
            'hdf5r', \
            'hexbin', \
            'igraph', \
            'kableExtra', \
            'knitr', \
            'lidR', \
            'lme4', \
            'mapdata', \
            'maptools', \
            'mapview', \
            'ncdf4', \
            'nlme', \
            'plyr', \
            'proj4', \
            'RColorBrewer', \
            'RandomFields', \
            'RNetCDF', \
            'randomForest', \
            'raster', \
            'RCurl', \
            'reshape2', \
            'rgdal', \
            'rgeos', \
            'rlas', \
            'rmarkdown', \
            'RODBC', \
            'RSQLite', \
            'sf', \
            'shiny', \
            'sp', \
            'spacetime', \
            'spatstat', \
            'spdep', \
            'splancs', \
            'tidyverse', \
            'tmap', \
            'TraMineR', \
            'tufte', \
            'geoR', \
            'geosphere' \
            ), repos='https://cran.rstudio.com');" \
## from bioconductor
   && R -e "library(BiocManager); \
            BiocManager::install('rhdf5')"

# Re-attach conda to path
ENV PATH="/opt/conda/bin:${PATH}"

#--- R/Python ---#

USER root

RUN ln -s /opt/conda/bin/jupyter /usr/local/bin
RUN R -e "install.packages('IRkernel'); \
          library(IRkernel); \
          IRkernel::installspec(prefix='/opt/conda/');"
ENV LD_LIBRARY_PATH /usr/local/lib/R/lib/:${LD_LIBRARY_PATH}
RUN fix-permissions $HOME \
  && fix-permissions $CONDA_DIR

RUN pip install -U --no-deps rpy2 \
 && rm -rf /home/$NB_USER/.cache/pip \
 && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# Switch back to jovyan to avoid accidental container runs as root
USER $NB_UID
