#Copypasta from generated dockerfile... ocaml/opam:ubuntu-20.04-ocaml-4.12 file:/Dockerfile.opam
# FROM ubuntu:focal
# LABEL distro_style="apt"
# RUN apt-get -y update
# RUN DEBIAN_FRONTEND=noninteractive apt-get -y upgrade
# RUN DEBIAN_FRONTEND=noninteractive apt-get -y install build-essential curl git libcap-dev sudo
# RUN git config --global user.email "docker@example.com"
# RUN git config --global user.name "Docker"
# RUN curl -fOL https://github.com/projectatomic/bubblewrap/releases/download/v0.4.1/bubblewrap-0.4.1.tar.xz
# RUN tar xf bubblewrap-0.4.1.tar.xz
# RUN cd bubblewrap-0.4.1 && ./configure --prefix=/usr/local && make && sudo make install
# RUN rm -rf bubblewrap-0.4.1.tar.xz bubblewrap-0.4.1
# RUN git clone git://github.com/ocaml/opam /tmp/opam && cd /tmp/opam && git checkout bcc21001c7e4850fc9aaeee00846775e343d40a6
# RUN sh -c "cd /tmp/opam && make cold && mkdir -p /usr/local/bin && cp /tmp/opam/opam /usr/local/bin/opam-2.0 && chmod a+x /usr/local/bin/opam-2.0 && rm -rf /tmp/opam"
# RUN git clone git://github.com/ocaml/opam /tmp/opam && cd /tmp/opam && git checkout 23a388ab4e5eef82e8ec351bdb0abc76bd9ab72a
# RUN sh -c "cd /tmp/opam && make CONFIGURE_ARGS=--with-0install-solver cold && mkdir -p /usr/local/bin && cp /tmp/opam/opam /usr/local/bin/opam-2.1 && chmod a+x /usr/local/bin/opam-2.1 && rm -rf /tmp/opam"


FROM ubuntu:focal
COPY --from=ocaml/opam:ubuntu-20.04-ocaml-4.12 [ "/usr/bin/bwrap", "/usr/bin/bwrap" ]
COPY --from=ocaml/opam:ubuntu-20.04-ocaml-4.12 [ "/usr/bin/opam-2.0", "/usr/bin/opam-2.0" ]
COPY --from=ocaml/opam:ubuntu-20.04-ocaml-4.12 [ "/usr/bin/opam-2.1", "/usr/bin/opam-2.1" ]
RUN ln /usr/bin/opam-2.0 /usr/bin/opam
RUN ln -fs /usr/share/zoneinfo/Europe/London /etc/localtime

RUN apt-get -y update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y upgrade
RUN echo 'Acquire::Retries "5";' > /etc/apt/apt.conf.d/mirror-retry
RUN apt-get -y update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y upgrade
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install build-essential curl git rsync sudo unzip nano libcap-dev libx11-dev
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN echo 'gitpod ALL=(ALL:ALL) NOPASSWD:ALL' > /etc/sudoers.d/gitpod
RUN chmod 440 /etc/sudoers.d/gitpod
RUN chown root:root /etc/sudoers.d/gitpod
RUN adduser --uid 33333 --disabled-password --gecos '' gitpod
RUN passwd -l gitpod
RUN chown -R gitpod:gitpod /home/gitpod
USER gitpod
ENV HOME="/home/gitpod"
WORKDIR $HOME
RUN mkdir .ssh
RUN chmod 700 .ssh
RUN echo 'wrap-build-commands: []' > ~/.opamrc-nosandbox
RUN echo 'wrap-install-commands: []' >> ~/.opamrc-nosandbox
RUN echo 'wrap-remove-commands: []' >> ~/.opamrc-nosandbox
RUN echo 'required-tools: []' >> ~/.opamrc-nosandbox
RUN echo '#!/bin/sh' > /home/gitpod/opam-sandbox-disable
RUN echo 'cp ~/.opamrc-nosandbox ~/.opamrc' >> /home/gitpod/opam-sandbox-disable
RUN echo 'echo --- opam sandboxing disabled' >> /home/gitpod/opam-sandbox-disable
RUN chmod a+x /home/gitpod/opam-sandbox-disable
RUN sudo mv /home/gitpod/opam-sandbox-disable /usr/bin/opam-sandbox-disable
RUN echo 'wrap-build-commands: ["%{hooks}%/sandbox.sh" "build"]' > ~/.opamrc-sandbox
RUN echo 'wrap-install-commands: ["%{hooks}%/sandbox.sh" "install"]' >> ~/.opamrc-sandbox
RUN echo 'wrap-remove-commands: ["%{hooks}%/sandbox.sh" "remove"]' >> ~/.opamrc-sandbox
RUN echo '#!/bin/sh' > /home/gitpod/opam-sandbox-enable
RUN echo 'cp ~/.opamrc-sandbox ~/.opamrc' >> /home/gitpod/opam-sandbox-enable
RUN echo 'echo --- opam sandboxing enabled' >> /home/gitpod/opam-sandbox-enable
RUN chmod a+x /home/gitpod/opam-sandbox-enable
RUN sudo mv /home/gitpod/opam-sandbox-enable /usr/bin/opam-sandbox-enable
RUN git config --global user.email "docker@example.com"
RUN git config --global user.name "Docker"
##FIXME REPO???
##COPY --chown=gitpod:gitpod [ ".", "/home/gitpod/opam-repository" ]
RUN opam-sandbox-disable
#RUN opam init -k local -a /home/gitpod/opam-repository --bare
RUN opam init --bare
#RUN rm -rf .opam/repo/default/.git
# COPY [ "Dockerfile", "/Dockerfile.opam" ]


# Dockerfile.ocaml

ENV OPAMYES="1" OPAMCONFIRMLEVEL="unsafe-yes" OPAMERRLOGLEN="0" OPAMPRECISETRACKING="1"
RUN opam switch create 4.12 --packages=ocaml-base-compiler.4.12.0
RUN opam pin add -k version ocaml-base-compiler 4.12.0
RUN opam install -y opam-depext
#FIXME move higher or or switch to standard git-pod base image.
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install pkg-config libssl-dev libev-dev 
#ENTRYPOINT [ "opam", "exec", "--" ]
#CMD bash