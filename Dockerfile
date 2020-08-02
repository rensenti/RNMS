#FROM debian:buster-slim
FROM debian:stable-20200607-slim

ENV RNMS_PREFIX /RNMS
ENV HTTPD_PREFIX $RNMS_PREFIX/apache
ENV PATH $RNMS_PREFIX/bin:$HTTPD_PREFIX/bin:$PATH
ENV HTTPD_DOWNLOAD_URL http://njahaha.net/RNMS/httpd.tar.bz2
ENV LANG en_US.UTF-8  

RUN mkdir -p "$HTTPD_PREFIX/src" \
	&& mkdir -p "$RNMS_PREFIX/web_aplikacija" \
	&& mkdir -p "$RNMS_PREFIX/netflow" \
	&& mkdir -p "$RNMS_PREFIX/database" \
	&& mkdir -p "$RNMS_PREFIX/bin" \
	&& mkdir -p "$RNMS_PREFIX/rrdb" \
	&& mkdir -p "$RNMS_PREFIX/log";
     
WORKDIR $HTTPD_PREFIX
COPY ./dockerSrc/httpd.tar.bz2 "$HTTPD_PREFIX"

# Sys preduvjeti + kompajliranje HTTPD-a
RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		iproute2 \
		cron \
		postgresql-11 \
		snmp \
		rrdtool \
		dnsutils \
		nfdump \
		wget \
		curl \
		net-tools \
		bzip2 \
		nmap \
		iputils-ping \
		libapr1-dev \
		libaprutil1-dev \
		libaprutil1-ldap \
		ca-certificates \
		dirmngr \
		dpkg-dev \
		gcc \
		gnupg \
		libbrotli-dev \
		libcurl4-openssl-dev \
		libjansson-dev \
		liblua5.2-dev \
		libnghttp2-dev \
		libpcre3-dev \
		libssl-dev \
		libxml2-dev \
		make \
		zlib1g-dev \
        ; \
	rm -rf /var/lib/apt/lists/*; \
	\
	tar -xf httpd.tar.bz2 -C src --strip-components=1; \
	rm httpd.tar.bz2; \
	cd src; \
	\
	gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
	# RNMS :D
	CFLAGS="-g -O2 -fdebug-prefix-map=/=. -fstack-protector-strong -Wformat -Werror=format-security -DBIG_SECURITY_HOLE"; \
	CPPFLAGS="$(dpkg-buildflags --get CPPFLAGS)"; \
	LDFLAGS="$(dpkg-buildflags --get LDFLAGS)"; \
	./configure \
		--build="$gnuArch" \
		--prefix="$HTTPD_PREFIX" \
		--enable-mods-shared=reallyall \
		--enable-mpms-shared=all \
		--enable-pie \
		CFLAGS="-pipe $CFLAGS" \
		CPPFLAGS="$CPPFLAGS" \
		LDFLAGS="-Wl,--as-needed $LDFLAGS" \
	; \
	make -j "$(nproc)"; \
	make install; \
	\
	cd ..; \
	rm -r src; \
	\
	sed -ri \
		-e 's!^(\s*CustomLog)\s+\S+!\1 /proc/self/fd/1!g' \
		-e 's!^(\s*ErrorLog)\s+\S+!\1 /proc/self/fd/2!g' \
		-e 's!^(\s*TransferLog)\s+\S+!\1 /proc/self/fd/1!g' \
		"$HTTPD_PREFIX/conf/httpd.conf" \
		"$HTTPD_PREFIX/conf/extra/httpd-ssl.conf" \
	; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false;

WORKDIR $RNMS_PREFIX

# schema baze podataka za PSQL
COPY ./dockerSrc/rnms_db /tmp/rnms_db
# src RNMS datoteke za HTTP
COPY ./dockerSrc/web_aplikacija $RNMS_PREFIX/web_aplikacija
COPY ./dockerSrc/bin $RNMS_PREFIX/bin
COPY ./dockerSrc/conf/crontab /etc/cron.d/
COPY ./dockerSrc/mibs /usr/share/snmp/mibs/
COPY ./dockerSrc/conf/pomagalice $RNMS_PREFIX/

# APACHE konfiguracija
COPY ./dockerSrc/conf/httpd.conf $HTTPD_PREFIX/conf/httpd.conf
# POSTGRESQL konfiguracija
COPY ./dockerSrc/conf/postgresql.conf /etc/postgresql/11/main/postgresql.conf

#COPY ./ssh/* /root/.ssh/

# start skripta
COPY ./dockerSrc/startRNMS.sh /usr/local/bin/

# PRIPREMA,
RUN set -eux; \
        chown postgres:postgres "$RNMS_PREFIX/database" \
	&& su - postgres -c "/usr/lib/postgresql/11/bin/initdb -D $RNMS_PREFIX/database" \
	&& su - postgres -c "/usr/lib/postgresql/11/bin/pg_ctl -D $RNMS_PREFIX/database -l $RNMS_PREFIX/database/rnms_db.log start &" \
	&& sleep 10 \
	&& su - postgres -c "psql -c \"create database rnms\"" \
	&& su - postgres -c "psql rnms < /tmp/rnms_db" \
	&& rm -f /tmp/rnms_db \
	&& service cron start \
	&& chmod 0644 /etc/cron.d/crontab \
	&& crontab /etc/cron.d/crontab \
	&& mkdir /var/tmp/Src \
	&& cp -Rp $RNMS_PREFIX/* /var/tmp/Src/

#  POZOR, TCP:80 i UDP:2055 omoguci
EXPOSE 80
EXPOSE 2055/udp

# SAD: startRNMS
CMD ["startRNMS.sh"]
