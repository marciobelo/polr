# retirado de https://github.com/andrewklau/docker-centos-lamp/blob/master/Dockerfile
FROM centos:centos7

# Install varioius utilities
RUN yum -y install curl wget unzip git vim nano \
iproute python-setuptools hostname inotify-tools yum-utils which \
epel-release

# Install Python and Supervisor
RUN yum -y install python-setuptools \
&& mkdir -p /var/log/supervisor \
&& easy_install supervisor

# Install Apache
RUN yum -y install httpd

# Install Remi Updated PHP 7
RUN wget http://rpms.remirepo.net/enterprise/remi-release-7.rpm \
&& rpm -Uvh remi-release-7.rpm \
&& yum-config-manager --enable remi-php72 \
&& yum -y install php php-devel php-gd php-pdo php-soap php-xmlrpc php-xml php-phpunit-PHPUnit

# Reconfigure Apache
RUN sed -i 's/AllowOverride None/AllowOverride All/g' /etc/httpd/conf/httpd.conf

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install MariaDB
COPY MariaDB.repo /etc/yum.repos.d/MariaDB.repo
RUN yum clean all;yum -y install mariadb-server mariadb-client
VOLUME /var/lib/mysql
EXPOSE 3306

# Install Redis
RUN yum -y install redis;
EXPOSE 3000

# Setup NodeJS
RUN curl --silent --location https://rpm.nodesource.com/setup_6.x | bash - \
&& yum -y install nodejs gcc-c++ make \
&& npm install -g npm \
&& npm install -g gulp grunt-cli \
&& yum clean all

# UTC Timezone & Networking
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime \
	&& echo "NETWORKING=yes" > /etc/sysconfig/network

# Copia os arquivos necessários ao deploy do projeto
COPY app /var/www
COPY config /var/www
COPY database /var/www
COPY docs /var/www
COPY resources /var/www
COPY storage /var/www
COPY public /var/www/html

COPY supervisord.conf /etc/supervisord.conf
EXPOSE 80
CMD ["/usr/bin/supervisord"]