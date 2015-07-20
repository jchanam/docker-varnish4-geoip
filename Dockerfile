FROM debian

MAINTAINER Julio Chana <julio.chana@bq.com>

RUN apt-get update
RUN apt-get install -y git pkg-config dpkg-dev autoconf curl make autotools-dev automake libtool libpcre3-dev libncurses-dev python-docutils bsdmainutils debhelper dh-apparmor gettext gettext-base groff-base html2text intltool-debian libbsd-dev libbsd0 libcroco3 libedit-dev libedit2 libgettextpo0 libpipeline1 libunistring0 man-db po-debconf libgeoip-dev wget

RUN apt-get install apt-transport-https
RUN curl https://repo.varnish-cache.org/GPG-key.txt | apt-key add -
RUN echo "deb https://repo.varnish-cache.org/debian/ jessie varnish-4.0" >> /etc/apt/sources.list.d/varnish-cache.list
RUN apt-get update
RUN apt-get install -y varnish=4.0.3\* libvarnishapi1=4.0.3\* libvarnishapi-dev=4.0.3\*

WORKDIR /opt

RUN wget https://repo.varnish-cache.org/source/varnish-4.0.3.tar.gz

RUN tar zxf varnish-4.0.3.tar.gz

WORKDIR /opt/varnish-4.0.3

RUN ./autogen.sh
RUN ./configure
RUN make

WORKDIR /opt/

RUN git clone git://github.com/varnish/libvmod-geoip.git

WORKDIR /opt/libvmod-geoip
ENV VARNISHSRC /opt/varnish-4.0.3
ENV VMODDIR /usr/lib/varnish/vmods

RUN ./autogen.sh
RUN ./configure
RUN make
RUN make install

RUN apt-get install -y geoip-bin

WORKDIR /opt/

RUN git clone https://github.com/maxmind/geoipupdate

WORKDIR /opt/geoipupdate

RUN apt-get install -y zlib1g-dev libcurl4-gnutls-dev

RUN ./bootstrap
RUN ./configure
RUN make
RUN make install

RUN mkdir /usr/local/share/GeoIP
COPY geoip_conf/GeoIP.conf /usr/local/etc/GeoIP.conf
COPY geoip_conf/geoipupdate /etc/crontab.d/geoipupdate

ENV LISTEN_PORT 6081

EXPOSE 6081

CMD ["varnishd","-a","0.0.0.0:6081","-T","0.0.0.0:6082","-f","/etc/varnish/default.vcl","-s","file,/var/cache/varnish.cache,256m","-F"]
