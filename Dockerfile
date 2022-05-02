############################################

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

##[apt] clean
RUN apt-get clean all && \
    rm -rf /var/cache/apk/* && \
    rm -rf /tmp/* && \
    rm -rf /var/tmp/*

######################[Repository]######################
##[Repository] (Postgresql-14)
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



##[Extension][pg_cron] | clear
RUN apt-get clean all && \
    rm -rf /var/cache/apk/* && \
    rm -rf /tmp/* && \
    rm -rf /var/tmp/*


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
## ##Extension [zombodb] 
## RUN git clone https://github.com/zombodb/zombodb.git /tmp/zombodb     && \
##     make -C /tmp/zombodb clean install


## Revert to the original non-root user
USER 1001