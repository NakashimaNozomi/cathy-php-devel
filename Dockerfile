FROM docker.io/centos:6.7
MAINTAINER Nozomi Nakamura<nnakashima@coresoft-net.co.jp>

ENV HOSTNAME cathy-developer
ENV PW root123
ENV HOME /root
# docker run -it --name filemaker -p 80:80 -p 2222:20 centos:6.7 /bin/bash
# yum
#yum -y install ntp && \
#sed -i -e "s/server [0-9].centos.pool.ntp.org iburst/server ntp.nict.jp/g" /etc/ntp.conf &&\
#service ntpd restart && \

# TODO: zshに書き換えないと。。。
RUN echo 'ZONE="Asia/Tokyo"' > /etc/sysconfig/clock && \
    rm -f /etc/localtime && \
    ln -fs /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
    yum -y install yum-plugin-fastestmirror && \
    echo "include_only=.jp" >>  /etc/yum/pluginconf.d/fastestmirror.conf && \
    yum -y update && \
    yum clean all && \
    yum -y groupinstall "Development Tools" && \
    yum clean all && \
    # repos
    yum -y install http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm && \
    yum clean all && \
    sed -i -e "s/enabled *= *1/enabled=0/g" /etc/yum.repos.d/epel.repo && \
    yum -y install http://rpms.famillecollet.com/enterprise/remi-release-6.rpm && \
    yum clean all && \
    sed -i -e "s/enabled *= *1/enabled=0/g" /etc/yum.repos.d/remi.repo && \
    #yum -y install http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm && \
    yum -y install http://ftp.riken.jp/Linux/repoforge/redhat/el6/en/x86_64/rpmforge/RPMS/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm && \
    yum clean all && \
    sed -i -e "s/enabled *= *1/enabled=0/g" /etc/yum.repos.d/rpmforge.repo && \
    yum -y install libxml2-devel openssl-devel curl-devel libjpeg-devel libpng-devel libXpm-devel freetype-devel readline-devel libtidy-devel libxslt-devel gcc cmake && \
    yum -y install git vim openssh-server mysql mysql-devel mysql-server httpd httpd-tools httpd-devel tar bzip2 bzip2-devel libicu-devel wget && \
    yum -y install --enablerepo=epel libmcrypt libmcrypt-devel s3cmd tree re2c && \
    yum clean all && \
    curl -L https://raw.githubusercontent.com/CHH/phpenv/master/bin/phpenv-install.sh | bash && \
    git clone https://github.com/php-build/php-build $HOME/.phpenv/plugins/php-build && \
    echo 'export PATH="/root/.phpenv/bin:$PATH"' >> $HOME/.bash_profile && \
    echo 'eval "$(phpenv init -)"' >> $HOME/.bash_profile && \
    source $HOME/.bash_profile && \
    echo 'export PS1="[\u@\[\e[37m\e[47m\]\h\[\e[0m\]] \[\e[33m\]\$PWD\n\[\e[0m\]\`if [ \$? = 0 ]; then echo \[\e[35m\]\"(^o^)\"\[\e[0m\]; else echo \[\e[34m\]\"(._.)\"\[\e[0m\]; fi\` $\[\e[0m\] "' >> $HOME/.bash_profile && \
    source $HOME/.bash_profile && \
    #phpenvの設定はじめ
    wget https://raw.githubusercontent.com/NakashimaNozomi/myfiles/master/docker/php-build.patch && \
    patch -u $HOME/.phpenv/plugins/php-build/bin/php-build < php-build.patch && \
    rm php-build.patch && \
    echo --with-apxs2=/usr/sbin/apxs >> $HOME/.phpenv/plugins/php-build/share/php-build/default_configure_options && \
    phpenv install 5.6.31 && \
    phpenv global 5.6.31  && \
    phpenv rehash && \
    service mysqld start && \
    /usr/bin/mysqladmin -u root password 'root123' && \
    sed -i -e "s/\[mysqld\]/[mysqld]\ncharacter-set-server=utf8/g" /etc/my.cnf && \
    echo -e "\n[client]\ndefault-character-set=utf8" >> /etc/my.cnf && \
    sed -i -e "s/#PermitEmptyPasswords no/PermitEmptyPasswords yes/g" /etc/ssh/sshd_config && \
    sed -i -e "s/#PermitRootLogin yes/PermitRootLogin yes/g" /etc/ssh/sshd_config && \
    git clone https://github.com/garamon/phpenv-apache-version $HOME/.phpenv/plugins/phpenv-apache-version && \
    sed -i -e '317,347s/AllowOverride None/AllowOverride All/g' /etc/httpd/conf/httpd.conf && \
    sed -i -e 's/#ServerName www.example.com:80/ServerName localhost:80/g' /etc/httpd/conf/httpd.conf && \
    sed -i -e 's/AddType application\/x-pkcs7-crl    .crl/AddType application\/x-pkcs7-crl    .crl\nAddType application\/x-httpd-php .php/g' /etc/httpd/conf/httpd.conf && \
    sed -i -e 's/DirectoryIndex index.html index.html.var/DirectoryIndex index.html index.html.var index.php/g' /etc/httpd/conf/httpd.conf && \
    # ln -s $HOME/.phpenv/versions/5.2.17/libexec/libphp5.so /etc/httpd/modules/

LABEL name="Nakamura Devel Image" \
    vendor="NakamuraNozomi" \
    license="GPLv2" \
    build-date="20171101"

CMD ["/bin/bash"]