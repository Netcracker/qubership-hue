FROM gethue/hue:20260212-140101
USER root

ENV DEBIAN_FRONTEND=noninteractive

RUN mkdir -p /etc/hadoop /home/hue

COPY hue_docker/requrements.txt /bin/requrements.txt

RUN ./build/env/bin/pip install --no-cache-dir -r /bin/requrements.txt

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install --no-install-recommends -y \
       openssl \
       nodejs \
       libssl3 \
       krb5-user \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


COPY hue_docker/createdb.py /bin/createdb.py
COPY hue_docker/get_hive_conf.sh /bin/get_hive_conf.sh

RUN chgrp -R 0 /usr/share/hue /etc/hadoop /home/hue /tmp /bin/get_hive_conf.sh && \
    chmod -R g+rwX /usr/share/hue /etc/hadoop /home/hue /tmp && \
    chmod +x /bin/get_hive_conf.sh   

USER hue
