FROM debian:stable

# Installation des outils
RUN apt-get update && apt-get install -y \
    nasm \
    qemu-system-x86 \
    gdb \
    make \
    gcc \
    binutils \
    sudo \
    && apt-get clean

# Création de l'utilisateur non-root
ARG USERNAME=jean-michel
ARG USER_UID=1000
ARG USER_GID=1000

RUN groupadd --gid $USER_GID $USERNAME && \
    useradd  --uid $USER_UID --gid $USER_GID -m $USERNAME && \
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Préparation du workspace
RUN mkdir -p /workspace && \
    chown -R $USERNAME:$USERNAME /workspace

# Ajout du script post_start.sh ligne par ligne
RUN echo '#!/bin/bash'                                                 >  /usr/local/bin/post_start.sh && \
    echo 'sudo chown -R jean-michel:jean-michel /workspace'            >> /usr/local/bin/post_start.sh && \
    echo 'echo "alias ll='\''ls -al'\''" >> /home/jean-michel/.bashrc' >> /usr/local/bin/post_start.sh

RUN chmod +x /usr/local/bin/post_start.sh && \
    chown $USERNAME:$USERNAME /usr/local/bin/post_start.sh

USER $USERNAME
WORKDIR /workspace

SHELL ["/bin/bash", "-c"]