FROM centos:6.6
 
USER root
 
RUN yum -y update;yum clean all
RUN yum -y install tar unzip vi vim telnet
RUN yum -y install httpd apr apr-util apr-devel apr-util-devel krb5-workstation mod_auth_kerb
RUN yum -y install elinks locate python-setuptools; yum clean all
 
 
RUN echo "Unzipping the EWS"
COPY software/jboss-ews-httpd-2.1.0-RHEL6-x86_64.zip /tmp/
RUN cd /opt; unzip /tmp/jboss-ews-httpd-2.1.0-RHEL6-x86_64.zip
 
RUN sed -i -e "0,/Allow from 127.0.0.1/{s/Allow from 127.0.0.1/Allow from all/}" /opt/jboss-ews-2.1/httpd/conf.d/mod_cluster.conf
RUN sed -i -e "s/Allow from 127.0.0.1/Allow from all/" /opt/jboss-ews-2.1/httpd/conf.d/mod_cluster.conf
RUN awk '/<VirtualHost/ { print; print "\n\tAllowDisplay On\n\tLogLevel debug\n"; next }1' /opt/jboss-ews-2.1/httpd/conf.d/mod_cluster.conf
RUN sed -i -e "s/#HTTPD/HTTPD/" /etc/sysconfig/httpd
 
WORKDIR /opt/jboss-ews-2.1/httpd
RUN ./.postinstall
 
RUN rm -f /tmp/jboss*.zip
 
EXPOSE 80 6666
 
#CMD ["/opt/jboss-ews-2.1/httpd/sbin/httpd","-D","FOREGROUND"]
CMD ["/opt/jboss-ews-2.1/httpd/sbin/apachectl","-k","start","-D","FOREGROUND"]
