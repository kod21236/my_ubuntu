FROM ubuntu:16.04
MAINTAINER kod21236 <kod21236@gmail.com>

USER root

ENV CHROME_DRIVER_VERSION 2.14
ENV ANACONDA_VERSION 5.1.0
ENV PYTHON_VERSION 2.7.10
ENV PYTHON_PIP_VERSION 7.0.3
ENV LANG C.UTF-8
ENV DISPLAY :99
ENV UID 1000
ENV GID 1000
ENV PATH /opt/conda/bin:$PATH

#================================================
# Add dedicated user
#================================================
RUN groupadd -r chrome -g $GID && useradd -u $UID -r -m -g chrome chrome

#================================================
# Customize sources for apt-get
#================================================
RUN SL=/etc/apt/sources.list && \
    cp ${SL} ${SL}.org && \
	sed -e 's/\(us.\)\?archive.ubuntu.com/ftp.daumkakao.com/g' -e 's/security.ubuntu.com/ftp.daumkakao.com/g' < ${SL}.org > ${SL}

  RUN apt-get update -qqy \
    && apt-get -qqy install build-essential wget unzip curl xvfb xz-utils zlib1g-dev libssl-dev git subversion
	
#===============
# Anaconda
#===============

  RUN wget --quiet https://repo.continuum.io/archive/Anaconda2-$ANACONDA_VERSION-Linux-x86_64.sh -O ~/anaconda.sh && \
    /bin/bash ~/anaconda.sh -b -p /opt/conda && \
	rm ~/anaconda.sh && \
	ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
	echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
	echo "conda activate base" >> ~/.bashrc

#===============
# Selenium 
#===============
#  RUN conda install --yes --quiet -c conda-forge --name base selenium && \
#      conda clean -tipsy
   
#===============
# chromedriver 
#===============
  ARG CHROME_DRIVER_VERSION=2.35 
  RUN wget --no-verbose -O /tmp/chromedriver_linux64.zip https://chromedriver.storage.googleapis.com/$CHROME_DRIVER_VERSION/chromedriver_linux64.zip \ 
   && rm -rf /opt/selenium/chromedriver \ 
   && unzip /tmp/chromedriver_linux64.zip -d /opt/selenium \ 
   && rm /tmp/chromedriver_linux64.zip \ 
   && mv /opt/selenium/chromedriver /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION \ 
   && chmod 755 /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION \ 
   && ln -fs /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION /usr/bin/chromedriver 

#===============
# misc 
#===============
  RUN apt-get update -qqy \
    && apt-get -qqy install openjdk-8-jre-headless vim

	
#============================
# Clean up
#============================
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.config/google-chrome

USER chrome
