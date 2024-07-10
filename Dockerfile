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
#RUN apt purge steam steamcmd
    
RUN add-apt-repository multiverse && \
    dpkg --add-architecture i386
    
RUN mkdir -pm755 /etc/apt/keyrings && \
    wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key && \
    wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources
    
RUN apt-get update
RUN apt-get install -y --install-recommends winehq-stable
RUN apt-get install -y gdebi-core libgl1-mesa-glx:i386 winbind xvfb
RUN apt install steam steamcmd
#RUN apt install -y xserver-xorg

RUN apt-get remove -y --purge wget software-properties-common && \
    apt-get clean autoclean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

RUN ln -s /usr/games/steamcmd /usr/bin/steamcmd
COPY start.sh /start.sh
RUN chmod +x /start.sh
CMD ["/start.sh"]
