FROM mcr.microsoft.com/mssql/server:2022-latest

USER root
COPY init.sh /usr/local/bin/init-scuoladb.sh
COPY backup.sh /usr/local/bin/backup-scuoladb.sh
COPY ScuolaDb.sql SeedData.sql /opt/scuoladb/
RUN chmod +x /usr/local/bin/init-scuoladb.sh /usr/local/bin/backup-scuoladb.sh \
    && mkdir -p /opt/scuoladb

ENTRYPOINT ["/usr/local/bin/init-scuoladb.sh"]
