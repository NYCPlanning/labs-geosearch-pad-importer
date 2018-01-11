# base image
FROM pelias/baseimage

# downloader apt dependencies
# note: this is done in one command in order to keep down the size of intermediate containers
RUN apt-get update && apt-get install -y bzip2 && apt-get install -y unzip && rm -rf /var/lib/apt/lists/* 
RUN sh -c 'echo "deb http://cran.rstudio.com/bin/linux/ubuntu trusty/" >> /etc/apt/sources.list' 
RUN gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9 
RUN gpg -a --export E084DAB9 | apt-key add - 
RUN apt-get update
RUN apt-get -y install r-base

# change working dir
ENV WORKDIR /code/pelias/nycpad
WORKDIR ${WORKDIR}

# add local code
ADD . ${WORKDIR}

# install npm dependencies
RUN npm install

# run tests
RUN npm test
