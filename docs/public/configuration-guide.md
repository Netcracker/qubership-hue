This section provides the information about the Hue and Trino connectors for connecting to databases.

You can initiate the Helm charts using Deployer tools through a Jenkins job or manually.

* [Hue Hadoop Side Steps](#hue-hadoop-side-steps)
  * [Сonfiguration Hive](#сonfiguration-hive)
    * [Downloading Hive Configurations as a Prestart Script](#downloading-hive-configurations-as-a-prestart-script) 
    * [Manually Specifying Hive Configurations](#manually-specifying-hive-configurations)
    * [Hive with SSL](#hive-with-ssl)
  * [Connecting to Trino Supported Databases](#connecting-to-trino-supported-databases)
    * [Cassandra](#cassandra)
    * [MongoDB](#mongodb)
    * [Redis](#redis)
    * [Using Multiple Databases](#using-multiple-databases)
  * [Hue with PostgreSQL](#hue-with-postgresql)
  * [Hue with Greenplum](#hue-with-greenplum)
  * [Hue Connections Supported OOB](#hue-connections-supported-oob)
 
## Hue Hadoop Side Steps

On Hadoop cluster itself, you need to perform some steps manually or using the `update_hdp` stage:

1. Add your Kerberos principal user in `core-site.xml`.

````yaml
inv_configuration:
  - name: HDFS
    configuration:
    - type: core-site
      properties:
      - key: hadoop.proxyuser.<your_principal>.groups
        value: "*"
      - key: hadoop.proxyuser.<your_principal>.hosts
        value: "*"
````

2. Allow hive impersonalization.

````yaml
inv_configuration:
  - name: HIVE
    configuration:
    - type: hive-interactive-site
      properties:
      - key: hive.server2.enable.doAs
        value: "true"
````

In the UI, it is the **Run as end user instead of Hive user** checkbox in the `hive-interactive-site` configuration on HIVE.

3. Add the `hive` user in Ranger <cluster>_yarn policy in "all - queue".

### Сonfiguration Hive

Specify the default Hue configuration as given below.

```yaml
hue:
  interpreters: |
    
    [[[hive]]]

    name=Hive

    interface=hiveserver2

  ini: >
    
    [beeswax]

    hive_conf_dir=/etc/hadoop/conf

    hive_server_host=<hive server host>

    security_enabled=true

    mechanism=GSSAPI

```

You also need to add hive configurations from HDP, there are two possible ways of doing this.

#### Downloading Hive Configurations as a Prestart Script

It is possible to enable downloading configurations from Ambari through pre-start script. In this case, it is necessary to specify the Ambari connection parameters and set `hue.args` to `/bin/get_hive_conf.sh`. For example,

```yaml
env:  
  - name: AMBARI_USER
    value: <user name>
  - name: AMBARI_PASSWORD
    value: <password>
  - name: AMBARI_URL
    value: <url>
  - name: AMBARI_PORT
    value: "8443"
  - name: CLUSTER_NAME
    value: <cluster name>
...
hue:
  args:
    - "/bin/get_hive_conf.sh"
```

#### Manually Specifying Hive Configurations

Instead of downloading hive configurations, it is possible to specify them in the deploy parameters. In this case, you need to copy hive.xml from any Hadoop node where hive is located or download it from the Ambari UI.

You need to specify it in Values.

```yaml
hive:
  site: |
    <!--

    <property>
      <name>ambari.hive.db.schema.name</name>
      <value>hive_test0</value>
    </property>
    ...........

    -->
```

#### Hive with SSL

Firstly, you need to change the HUE configuration to the SSL version of beeswax as given below.

```yaml
hue:
  ini: |
    [beeswax]
    hive_conf_dir=/etc/hadoop/conf
    hive_server_host=<hive server host>
    security_enabled=true
    mechanism=GSSAPI
    [desktop]
    app_blacklist=filebrowser,search,hbase,security,jobbrowser,oozie
    [[database]]
    host=(<hue-db>|<postgres-service.pg-patroni>)
    engine=(<mysql>|<postgresql_psycopg2>)
    user=<hue-user>
    password=<password>
    name=<hue database>
    [[ssl]]
    enabled=true
    cacerts=/etc/hue/cacerts.pem ## Path to Certificate Authority certificates
    validate=true

```

Additionally, to specify SSL in the Hue configuration, you need to specify their value.

```yaml
ssl:
  enabled: True
  cacerts: |
    certificate content
```

Where `cacerts` is the base64 encoded file from Certificate Center with the .pem extension. 


### Connecting to Trino Supported Databases

Hue does not support some databases like Cassandra, Redis, Mongo, and so on, OOB, but it supports Trino, which in turn supports these databases.

Therefore, it is required to install the Trino pod as well. It is possible to add configurations for Trino using the `databasescommon.configs` installation parameter. It is also possible to add additional configurations for Trino with `databasescommon.additionalConfigs`. The configurations are added to /dbadditionalconfigs directory of the Trino pods.

#### Cassandra

For Cassandra, additional parameters are required, for example:

```yaml

databasescommon:
  enabled: True
  configs:
    tpch.properties: |
      connector.name=tpch
    cassandra.properties: |
      connector.name=cassandra
      cassandra.contact-points=cassandra.cassandra
      cassandra.native-protocol-port=9042
      cassandra.security=PASSWORD
      cassandra.username=<user name>
      cassandra.password=<password>
      cassandra.load-policy.dc-aware.local-dc=dc1
      cassandra.load-policy.use-dc-aware=true
jvmconfig: |
    -server
    -Xmx1G
    -XX:+UseG1GC
    -XX:G1HeapRegionSize=32M
    -XX:+ExplicitGCInvokesConcurrent
    -XX:+HeapDumpOnOutOfMemoryError
    -XX:+UseGCOverheadLimit
    -XX:+ExitOnOutOfMemoryError
    -XX:ReservedCodeCacheSize=256M
    -Djdk.attach.allowAttachSelf=true
    -Djdk.nio.maxCachedBufferSize=2000000
    -DHADOOP_USER_NAME=hdfs

trino:
  enabled: True
  image: ghcr.io/netcracker/qubership-trino:main
  imagePullPolicy: "IfNotPresent"
  replicas: 1
  resources:
    requests:
      cpu: "50m"
      memory: "300Mi"
  service:
    annotations: {}
  securityContext:
    runAsUser: 1000
    runAsGroup: 1000
  securityRules:
    capabilities:
      drop:
        - ALL
    seccompProfile:
      type: RuntimeDefault
    allowPrivilegeEscalation: false
    runAsNonRoot: true
````

For connection properties, refer to [https://trino.io/docs/471/connector/cassandra.html](https://trino.io/docs/471/connector/cassandra.html).

In the Hue configuration, you should specify the section for the connection to Cassandra through Trino, for example:

````yaml
hue:
  interpreters: |
    [[[trino_cassandra]]]
    name = cassandra
    interface= sqlalchemy
    options='{"url": "trino://trino:8080/cassandra"}'
````

#### MongoDB

For MongoDB, the additional parameters in `databasescommon.configs` are also required, for example:

```yaml
databasescommon:
  enabled: True
  configs:
...
    mongodb.properties: |
      connector.name=mongodb
      mongodb.connection-url=mongodb://root:root@mongos.mongo.svc/
...
```

For connection properties, refer to [https://trino.io/docs/471/connector/mongodb.html](https://trino.io/docs/471/connector/mongodb.html).

In the Hue configuration, you should specify the section for the connection to MongoDB through Trino:

```yaml
hue:
  interpreters: |
    [[[trino_mongo]]]
    name = mongodb
    interface= sqlalchemy
    options='{"url": "trino://trino:8080/mongodb"}'
```

#### Redis

For Redis, additional parameters in `databasescommon.configs` and `databasescommon.additionalConfigs` are also required, for example:

```yaml
databasescommon:
  enabled: True
  configs:
...
    redis-1.properties: |
      connector.name=redis
      redis.table-names: redis
      redis.nodes: <redis node ip>
      redis.default-schema: default
      redis.password: <password>
      redis.database-index: 1
      redis.table-description-dir: /dbadditionalconfigs/test.json
...
  additionalConfigs:
    test.json: |
      {
        "tableName": "redis",
        "schemaName": "redis",
        "key": {
          "dataFormat": "raw",
          "fields": [
            {
              "name": "redis_key",
              "type": "varchar",
              "hidden": "false"
            }
          ]
        },
        "value": {
          "dataFormat": "raw",
          "fields": [
            {
              "name": "redis_value",
              "type": "varchar",
              "hidden": "false"
            }
          ]
        }
      }
...
```

In the Hue configuration, you should specify the section for the connection to Redis through Trino:

```yaml
hue:
  interpreters: |
    [[[trino_redis]]]
    name = redis-1
    interface= sqlalchemy
    options='{"url": "trino://trino:8080/redis-1"}'
```

#### Using Multiple Databases

If you want to install both the additional database (for example, Cassandra) and Hive, use the following configuration in addition to the part that is described in [Connection to Hive](#hive).

````yaml
hue:
  interpreters: |
    [[[hive]]]
    # The name of the snippet.
    name=Hive
    # The backend connection to use to communicate with the server.
    interface=hiveserver2
    [[[trino]]]
    name = Trino
    interface= sqlalchemy
    options='{"url": "trino://trino:8080/cassandra"}'
````

### Hue with PostgreSQL

Hue supports connection to PostgreSQL out of the box.
Add the following to the Hue configuration.

```yaml
hue:
  interpreters: |
    [[[postgresql]]]
    name = PostgreSql
    interface=sqlalchemy
    options='{"url": "postgresql+psycopg2://<pg_user>:<pg_password>@<pg_host>:<pg_port>/<db>"}'
```

### Hue with Greenplum

Hue supports connection to Greenplum out of the box.
Add the following to the Hue configuration.

```yaml
hue:
  interpreters: |
    [[[greenplum]]]
    name = Greenplum
    interface=sqlalchemy
    options='{ "url": "postgresql+psycopg2://<gp_user>:<gp_password>@<greenplum-host>:<greenplum-port>/<db>"}'
```

### Hue Connections Supported OOB

Hue supports various connections.
For more information and configuration examples, refer to [http://cloudera.github.io/hue/latest/administrator/configuration/editor/#connectors](http://cloudera.github.io/hue/latest/administrator/configuration/editor/#connectors).
