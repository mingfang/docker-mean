FROM ubuntu
 
RUN echo 'deb http://archive.ubuntu.com/ubuntu precise main universe' > /etc/apt/sources.list && \
    echo 'deb http://archive.ubuntu.com/ubuntu precise-updates universe' >> /etc/apt/sources.list && \
    apt-get update

#Prevent daemon start during install
RUN dpkg-divert --local --rename --add /sbin/initctl && ln -s /bin/true /sbin/initctl

#Supervisord
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y supervisor && mkdir -p /var/log/supervisor
CMD ["/usr/bin/supervisord", "-n"]

#SSHD
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server &&	mkdir /var/run/sshd && \
	echo 'root:root' |chpasswd

#Utilities
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y vim less net-tools inetutils-ping curl git telnet nmap socat dnsutils netcat tree htop unzip sudo bzip2

#Serf
RUN wget https://dl.bintray.com/mitchellh/serf/0.4.1_linux_amd64.zip && \
    unzip 0.4*.zip && \
    rm 0.4*.zip
RUN mv serf /usr/bin/

#Node
RUN wget http://nodejs.org/dist/v0.10.25/node-v0.10.25-linux-x64.tar.gz && \
    tar xvf node*gz && \
    rm node*gz
RUN mv node* node && \
    ln -s /node/bin/node /usr/local/bin/node && \
    ln -s /node/bin/npm /usr/local/bin/npm

#Express
RUN npm install express -g

#MongoDB
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10 && \
    echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' > /etc/apt/sources.list.d/mongodb.list && \
    apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y mongodb-10gen
RUN mkdir -p /data/db

#MEAN
RUN git clone https://github.com/linnovate/mean.git
RUN cd mean && \
    npm install

RUN npm install -g grunt-cli
RUN echo 'eval "$(grunt --completion=bash)"' >> ~/.bashrc
RUN npm install -g bower

RUN cd /mean && \
    bower --allow-root install && \
    npm install

#Configuration

ADD . /docker-serf
RUN ln -s /docker-serf/etc/supervisord-serf.conf /etc/supervisor/conf.d/supervisord-serf.conf
RUN ln -s /docker-serf/etc/supervisord-ssh.conf /etc/supervisor/conf.d/supervisord-ssh.conf
RUN ln -s /docker-serf/etc/supervisord-mongodb.conf /etc/supervisor/conf.d/supervisord-mongodb.conf

 
EXPOSE 22 7946 3000
