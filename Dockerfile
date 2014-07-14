FROM ubuntu
 
RUN echo 'deb http://archive.ubuntu.com/ubuntu precise main universe' > /etc/apt/sources.list && \
    echo 'deb http://archive.ubuntu.com/ubuntu precise-updates main universe' >> /etc/apt/sources.list && \
    apt-get update

#Runit
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y runit 
CMD /usr/sbin/runsvdir-start


RUN apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:mean!' |xargs chpasswd

EXPOSE 22
CMD    ["/usr/sbin/sshd", "-D"]

#Utilities
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y less net-tools inetutils-ping curl git telnet nmap socat dnsutils netcat tree htop unzip sudo

#Node
RUN curl http://nodejs.org/dist/v0.10.26/node-v0.10.26-linux-x64.tar.gz | tar xz
RUN mv node* node && \
    ln -s /node/bin/node /usr/local/bin/node && \
    ln -s /node/bin/npm /usr/local/bin/npm


#MongoDB
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10 && \
    echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' > /etc/apt/sources.list.d/mongodb.list && \
    apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y mongodb-org
RUN mkdir -p /data/db

# Create a mean user
RUN mkdir -p /home/mean
RUN useradd mean -d /home/mean -s /bin/bash 
RUN cd /home/mean
RUN chown mean /home/mean

#Install mean cli
RUN npm install -g meanio
# Init the application,install dependencies and run grunt
RUN su mean -c "cd /home/mean && pwd && id && mean init meanapp && cd /home/mean/meanapp && npm install"
RUN su mean -c "pwd && id && cd /home/mean/meanapp && echo "in dir" && pwd && ls -l"
RUN npm install -g grunt-cli

#Configuration
ADD . /docker

#Runit Automatically setup all services in the sv directory
RUN for dir in /docker/sv/*; do echo $dir; chmod +x $dir/run $dir/log/run; ln -s $dir /etc/service/; done

ENV HOME /root
WORKDIR /root
EXPOSE 22 7946 3000
