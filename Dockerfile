##docker build -t quaredevil/postgresql-repmgr-plpython3-pgcron:14-latest .
##docker push quaredevil/postgresql-repmgr-plpython3-pgcron:14-latest 
############################################
ARG VERSION=14

FROM bitnami/postgresql-repmgr:14


## Change user to perform privileged actions
USER 0

######################[apt]######################
##[apt] update / upgrade
RUN apt-get update && \
    apt-get upgrade -y

##[apt] update / upgrade | clear
RUN rm -r /var/lib/apt/lists /var/cache/apt/archives

##[apt] install
RUN install_packages build-essential cmake git gnupg libcurl4-openssl-dev libssl-dev libz-dev lsb-release wget libc6


######################[Repository]######################
##[Repository] (Postgresql)
RUN install_packages gnupg2
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc |  apt-key add -
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | tee  /etc/apt/sources.list.d/pgdg.list
RUN apt-get update

######################[Extension]######################

##[Extension][plpython3]
##[Extension][plpython3] | install
RUN install_packages python3 postgresql-contrib postgresql-plpython3-14

##[Extension][plpython3] | copy
RUN mv /usr/share/postgresql/14/extension/*plpython3* /opt/bitnami/postgresql/share/extension/
RUN mv /usr/lib/postgresql/14/lib/*plpython3* /opt/bitnami/postgresql/lib/

##[Extension][plpython3] | clear
RUN apt-get clean all && \
    rm -rf /var/cache/apk/* && \
    rm -rf /tmp/* && \
    rm -rf /var/tmp/*
    
######################

##[Extension][pg_cron]
RUN install_packages postgresql-14-cron

##[Extension][pg_cron] | copy
RUN mv /usr/share/postgresql/14/extension/*pg_cron* /opt/bitnami/postgresql/share/extension/
RUN mv /usr/lib/postgresql/14/lib/*pg_cron* /opt/bitnami/postgresql/lib/




##Extension [timescale] 
## RUN git clone https://github.com/timescale/timescaledb.git --branch 1.7.2 /tmp/timescaledb     && \
##     bash /tmp/timescaledb/bootstrap -DREGRESS_CHECKS=OFF     && \
##     make -C /build clean install
## 
## 
## RUN echo "deb https://packagecloud.io/timescale/timescaledb/debian/ $(lsb_release -c -s) main" | tee /etc/apt/sources.list.d/timescaledb.list     && \
##     wget --quiet -O - https://packagecloud.io/timescale/timescaledb/gpgkey | apt-key add -         && \
##     apt-get update     && \
##     install_packages -y timescaledb-tools
## 
## 
## #COPY /tmp/timescaledb/ /opt/bitnami/postgresql/conf/conf.d/ 
## 
## 

##Extension [zombodb] 
#RUN export CARGO_HOME=/tmp/cargo && export RUSTUP_HOME=/tmp/rustup && export PATH=$CARGO_HOME/bin:$PATH \
#    && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y \
#    && cargo install cargo-pgx \
#    && cargo pgx init --pg14=`which pg_config` \
#    && git clone -b https://github.com/zombodb/zombodb /tmp/zombodb \
#    && cd /tmp/zombodb \
#    && sudo bash -c 'CARGO_HOME=/tmp/cargo RUSTUP_HOME=/tmp/rustup PATH=$CARGO_HOME/bin:$PATH PGX_HOME=/var/lib/postgresql/.pgx cargo pgx install --release' \
#    && sudo rm -rf /var/lib/postgresql/.pgx || true


##Extension [pgroonga] https://github.com/pgroonga/pgroonga
#RUN install_packages postgresql-14-pgdg-pgroonga

##wal2json https://github.com/eulerto/wal2json
#RUN git clone https://github.com/eulerto/wal2json /tmp/wal2json \
#    && cd /tmp/wal2json \
#    && make && sudo make install

## pgsql-http https://github.com/pramsey/pgsql-http
#RUN wget -O /tmp/pgsql-http.tar.gz "https://github.com/pramsey/pgsql-http/archive/v${PGSQL_HTTP}.tar.gz" \
#    && mkdir -p /tmp/pgsql-http \
#    && tar --extract --file /tmp/pgsql-http.tar.gz --directory /tmp/pgsql-http --strip-components 1 \
#    && cd /tmp/pgsql-http \
#    && make && sudo make install \

##clear
RUN apt-get autoremove --purge -y --allow-remove-essential \
        curl \
        build-essential \
        libssl-dev \
        git \
        dpkg-dev \
        gcc \
        libc-dev \
        make \
        cmake \
        wget \
        libcurl4-openssl-dev \
    && apt-get clean -y \
    && rm -rf \
        "${HOME}/.cache" \
        /var/lib/apt/lists/* \
        /var/cache/apk/* \
        /tmp/* \
        /var/tmp/* \
    && apt-get clean all
    
## Revert to the original non-root user
USER 1001