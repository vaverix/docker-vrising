FROM ubuntu:22.04 
LABEL maintainer="vaverix"
VOLUME ["/mnt/vrising/server", "/mnt/vrising/persistentdata", "/mnt/vrising/mods"]

ARG DEBIAN_FRONTEND="noninteractive"

RUN apt-get update && \
    apt-get upgrade -y

RUN apt-get install -y apt-utils wget software-properties-common tzdata

RUN useradd -m steam && cd /home/steam && \
    echo steam steam/question select "I AGREE" | debconf-set-selections && \
    echo steam steam/license note '' | debconf-set-selections
RUN apt purge steam steamcmd
    
RUN add-apt-repository multiverse && \
    dpkg --add-architecture i386

RUN apt-get update && \
    apt-get upgrade -y
RUN apt-get install -y gdebi-core libgl1-mesa-glx:i386

RUN apt install -y steam steamcmd
RUN ln -s /usr/games/steamcmd /usr/bin/steamcmd

RUN apt install -y wine \
                   winbind \
                   winetricks

RUN apt-get install -y xserver-xorg xvfb

RUN apt-get remove -y --purge wget software-properties-common && \
    apt-get clean autoclean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

COPY start.sh /start.sh
RUN chmod +x /start.sh
CMD ["/start.sh"]
