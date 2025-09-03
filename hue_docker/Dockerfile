FROM gethue/hue:20250902-140101
USER root

ENV DEBIAN_FRONTEND=noninteractive

RUN mkdir /etc/hadoop \
    && chmod 777 /etc/hadoop \
    && mkdir --parents /home/hue \
    && chmod 777 -R /home/hue

COPY hue_docker/requrements.txt /bin/requrements.txt

RUN ./build/env/bin/pip install --no-cache-dir -r /bin/requrements.txt

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install --no-install-recommends -y openssl nodejs libssl1.1 krb5-user \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY hue_docker/createdb.py /bin/createdb.py
COPY hue_docker/get_hive_conf.sh /bin/get_hive_conf.sh

RUN chmod 777 /bin/get_hive_conf.sh

USER hue
