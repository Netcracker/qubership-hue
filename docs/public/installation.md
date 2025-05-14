The following topics are covered in this chapter:

* [Prerequisites](#prerequisites)
  * [Common](#common)
  * [Kubernetes](#common)
  * [OpenShift](#common)
* [Best Practices and Recommendations](#best-practices-and-recommendations)
  * [HWE](#hwe)
    * [Small](#small)
    * [Medium](#medium)
    * [Large](#large)
* [Parameters](#parameters)
  * [Qubership-hue Deployment Schema](#qubership-hue-deployment-schema)
  * [Hue Configuration](#hue-configuration)
    * [Hue Database](#hue-database)
    * [Hue Configuration File](#hue-configuration-file)
    * [Enable HTTPS/TLS](#enable-httpstls)
      * [Prepare TLS/SSL Certificate](#prepare-tlsssl-certificate)
      * [Enable TLS on Hue Ingress](#enable-tls-on-hue-ingress)
      * [Enable TLS on Hue Service](#enable-tls-on-hue-service)
      * [Enable TLS on Hue UI Inside Kubernetes](#enable-tls-on-hue-ingress)
      * [Re-encrypt Route In Openshift Without NGINX Ingress Controller](#re-encrypt-route-in-openshift-without-nginx-ingress-controller)
    * [Secure Connections from Hue](#secure-connections-from-hue)
       * [Adding a Certificate](#adding-a-certificate)
       * [Configure Connections to Use SSL/TLS](#configure-connections-to-use-ssltls)
         * [Disable Certificate Validation](#disable-certificate-validation)
    * [Kerberized Data Source](#kerberized-data-source)
    * [Hue with Ldap Integrated User Interface](#hue-with-ldap-integrated-user-interface)
    * [Hue Keycloak (OIDC) for SSO Login](#hue-keycloak-oidc-for-sso-login)
      * [Keycloak with TLS](#keycloak-with-tls) 
  * [Configuration Trino](#configuration-trino)
      * [Internal Trino](#internal-trino)
        * [Secure Connections for Internal Trino](#secure-connections-for-internal-trino)
      * [External Trino](#extrenal-trino)
        * [Secure Connections for External Trino](#secure-connections-for-external-trino)
* [Installation](#installation) 
  * [Manual Deployment](#manual-deployment)
* [On-Prem](#on-prem)
    * [Non-HA Scheme](#non-ha-scheme)
* [Upgrade](#upgrade)
* [Rollback](#rollback)


# Prerequisites

The prerequisites for the installation are as follows:

## Common

* Helm >= 3
* PostgreSQL service is required.

## Kubernetes

* Kubernetes >= 1.21
* A namespace in Kubernetes should be created.  

## OpenShift

* Openshift >= 4.10
* A namespace in OpenShift should be created. 

## HWE

The hardware requirements for the installation are specified below.

# Parameters

The parameters are specified in the below sub-sections.

## Qubership-hue Deployment Schema

Qubership-hue helm charts contain several Hue and Trino components for working with databases.

The chart for Hue deployment mostly follows community chart from https://github.com/gethue/hue/tree/master/tools/kubernetes/helm/hue with a few additions, like resources, custom labels and `priorityClassName`. The following table lists the configurable parameters of the Qubership-hue chart and their default values.

| Parameter                                 | Type            | Mandatory | Default value                                               | Description                                                                                                                                                                                                                                                                                                                                             |
|-------------------------------------------|-----------------|-----------|-------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `image.registry`                          | string          | false     | `"ghcr.io"`                           | The image repository.                                                                                                                                                                                                                                                                                                                                   |
| `image.pullPolicy`                        | string          | false     | `image.pullPolicy`                                          | The image pull policy.                                                                                                                                                                                                                                                                                                                                  |
| `image.tag`                               | string          | false     | `"main"`                                                  | This overrides the image tag, which is the hue version by default.                                                                                                                                                                                                                                                                                      |
| `hue.replicas`                            | string          | false     | `1`                                                         | The number of hue to run.                                                                                                                                                                                                                                                                                                                               |
| `hue.database.create`                     | string          | true      | `false`                                                     | The parameter for creating a database for HUE operation                                                                                                                                                                                                                                                                                                 |
| `hue.database.host`                       | string          | true      | `pg-patroni.postgres.svc`                                   | The host for connecting to the database                                                                                                                                                                                                                                                                                                                 |
| `hue.database.port`                       | integer         | true      | 5432                                                        | The port for connecting to the database                                                                                                                                                                                                                                                                                                                 |
| `hue.database.user`                       | string          | true      | ``                                                       | The username for working with the table                                                                                                                                                                                                                                                                                                                 |
| `hue.database.password`                   | string          | true      | ``                                                       | The password for working with the table                                                                                                                                                                                                                                                                                                                 |
| `hue.database.name`                       | string          | true      | ``                                                       | The name of the table to work with                                                                                                                                                                                                                                                                                                                      |
| `hue.database.adminUser`                  | string          | true      | ``                                                  | The username for connecting to the database                                                                                                                                                                                                                                                                                                             |
| `hue.database.adminPassword`              | string          | true      | ``                                                  | The password for connecting to the database                                                                                                                                                                                                                                                                                                             |
| `hue.podSecurityContext.runAsUser`        | string          | false     | `1001`                                                      | All processes' containers that run with the specified user.                                                                                                                                                                                                                                                                                             |
| `hue.securityContext.runAsUser`           | string          | false     | `1001`                                                      | All processes' containers that run with the specified user.                                                                                                                                                                                                                                                                                             |
| `hue.priorityClassName`                   | string          | false     | `~`                                                         | Priority class name for hue pods.                                                                                                                                                                                                                                                                                                                       |
| `hue.affinity`                            | map             | false     | `~`                                                         | Affinity for hue pods.                                                                                                                                                                                                                                                                                                                                  |
| `hue.hostAliases`                         | list            | false     | `[]`                                                        | Data for working with Hadoop                                                                                                                                                                                                                                                                                                                            |
| `hue.interpreters`                        | list ob objects | true      | -                                                           | Parameters for connecting to databases for hue and others                                                                                                                                                                                                                                                                                               |
| `hue.ini`                                 | list ob objects | true      | -                                                           | Section is about configuring the Hue server itself                                                                                                                                                                                                                                                                                                      |
| `ingress.tls.enabled`                     | string          | false     | `true`                                                      | Parameter to enable tls support                                                                                                                                                                                                                                                                                                                         |
| `ingress.tls.secretName`                  | string          | false     | `hue-tls-cm`                                                | Name of the secret that contains TLS certificate.                                                                                                                                                                                                                                                                                                       |
| `ingress.domain`                          | string          | true      | `hue...`                                                    | The address of access to the UI HUE                                                                                                                                                                                                                                                                                                                     |
| `hive.site`                               | list ob objects | true      | -                                                           | Configuration file for working with hive                                                                                                                                                                                                                                                                                                                |
| `kerberos.enabled`                        | string          | false     | `false`                                                     | Network authentication protocol                                                                                                                                                                                                                                                                                                                         |
| `kerberos.keytab`                         | list ob objects | false     | -                                                           | The Kerberos Keytab file contains mappings between Kerberos Principal names and DES-encrypted keys                                                                                                                                                                                                                                                      |
| `kerberos.config`                         | list ob objects | false     | -                                                           | The configuration file for the operation of Kerberos                                                                                                                                                                                                                                                                                                    |
| `ldap.enabled`                            | string          | false     | `false`                                                     | Network authentication protocol                                                                                                                                                                                                                                                                                                                         |
| `ldap.bind_password_script`               | list ob objects | false     | -                                                           | Password for LDAP operation                                                                                                                                                                                                                                                                                                                             |
| `databasescommon.enabled`                 | string          | true      | `true`                                                      | A parameter for working with databases in Trino                                                                                                                                                                                                                                                                                                         |
| `databasescommon.configs`                 | list ob objects | true      | -                                                           | Configuration options for database access                                                                                                                                                                                                                                                                                                               |
| `trino.enabled`                           | string          | false     | `true`                                                      | Parameter enabling Trino                                                                                                                                                                                                                                                                                                                                |
| `trino.image`                             | string          | false     | `"ghcr.io/netcracker/qubership-trino:main"`    | The image repository.                                                                                                                                                                                                                                                                                                                                   |
| `trino.imagePullPolicy`                   | string          | false     | `IfNotPresent`                                              | The image pull policy                                                                                                                                                                                                                                                                                                                                  |
| `trino.securityContext.runAsUser`         | string          | false     | `1000`                                                      | All processes' containers that run with the specified user                                                                                                                                                                                                                                                                                             |
| `trino.securityContext.runAsGroup`        | string          | false     | `1000`                                                      | All processes' containers that run with the specified user group                                                                                                                                                                                                                                                                                       |
| `trino.priorityClassName`                 | string          | false     | `~`                                                         | Priority class name for trino pods                                                                                                                                                                                                                                                                                                                     |
| `trino.affinity`                          | map             | false     | `~`                                                         | Affinity for trino pods                                                                                                                                                                                                                                                                                                                                |
| `certManagerInegration.enabled`           | string          | false     | `false`                                                     | The parameter to integrate cert-manager                                                                                                                                                                                                                                                                                                                |
| `certManagerInegration.secretName`        | string          | false     | `hue-tls`                                                   | The name of the certificate for a TLS operation                                                                                                                                                                                                                                                                                                        |
| `certManagerInegration.secretMounts`      | array           | false     | `- mountPath: /home/hue/trustcerts/ca.crt subPath: ca.crt`  | Cer manager generated certificates mount details - mountPath and subPath                                                                                                                                                                                                                                                                               |
| `certManagerInegration.clusterIssuerName` | string          | false     | `common-cluster-issuer`                                     | The name of the issuer to create a certificate for a TLS operation                                                                                                                                                                                                                                                                                      |
| `extraSecrets`                            | map             | false     | `{}`                                                        | Allows to create custom secrets to pass them to pods during the deployments. The format for secret data is "key/value" where key (can be templated) is the name of the secret that will be created, value - an object with the standard 'data' or 'stringData' key (or both). The value associated with those keys must be a string (can be templated). |
| `extraVolumes`                            | array           | false     | `[]`                                                        | One or more additional volume mounts to add to Hue, Trino and DB init job pods                                                                                                                                                                                                                                                                         |
| `extraVolumeMounts`                       | array           | false     | `[]`                                                        | One or more additional volume mounts to add to Hue, Trino and DB init job pods                                                                                                                                                                                                                                                                         |
| `env`                                     | array           | false     | `[]`                                                        | Additional env parameters for Hue Service and DB init job                                                                                                                                                                                                                                                                                             |


## Hue Configuration

The configuration information is provided in the below sub-sections.

### Hue Database

Hue demands database for backend activities and it can be any SQL database. Cloud DB Tool uses PostgreSQL database.
It is possible to specify parameters for the database creation. When the parameters are specified, the Kubernetes job runs before the Hue deployment and creates a database. An example of the parameters for the database creation is as follows:

```yaml

hue:
  database:
    create: true
    engine: "postgresql_psycopg2"
    host: pg-patroni.postgres-service.svc
    port: 5432
    user: <user>
    password: <password>
    name: <database>
    adminUser: <yourPGadminUser>
    adminPassword: <yourPGadminPassword>

```

Alternatively, you can manually create the database, user, and grants in PostgresSQL beforehand.

In any patroni pod, execute the following.

````
psql -c "create database  <database>;"
psql -c "CREATE USER <user> WITH PASSWORD '<password>';"
psql -c "GRANT ALL PRIVILEGES ON DATABASE <database> to <user>;"
````

**Note**: In further configuration examples, we used `<user>` = hue, `<database>` = hue, and `<password>`=pass

### Hue Configuration File

The default configuration of Hue is provided below:

```yaml
image:
   registry: "ghr.io/netcracker/qubership-hue"
   tag: "main"
   pullPolicy: "IfNotPresent"

api:
  enabled: false
  domain: api.hue.dashboard.host.k8s.com

hue:
  replicas: 1
  delayStart: 60
  resources:
    requests:
      cpu: "50m"
      memory: "300Mi"
  service:
    annotations: { }
  securityContext:
    runAsUser: 1001
  hostAliases:
    - ip: "ip"
      hostnames:
        - "hdm1"
    ...........
  
ingress:
  create: true
  type: "nginx"
  domain: "hue.dashboard.host.k8s.com"

```

The main configuration point of Hue - HUE configuration is included in all the data sources that you need and their settings. For more information, refer to the _Official Documentation_ at [https://github.com/cloudera/hue/blob/master/desktop/conf.dist/hue.ini](https://github.com/cloudera/hue/blob/master/desktop/conf.dist/hue.ini).

```yaml
hue:
  ini: |
    [desktop]
    app_blacklist=filebrowser,search,hbase,security,jobbrowser,oozie
    [[database]]
    host=(<hue-db>|<postgres-service.pg-patroni>)
    engine=(<mysql>|<postgresql_psycopg2>)
    user=<user>
    password=<password>
    name=<database>
```

### Enable HTTPS/TLS

The information on enabling HTTPS/TLS is provided below.

#### Prepare TLS/SSL Certificate

You can use the below two options to get the TLS/SSL certificates.

1. Using manual certificate for Hue.

1.1 Generate self-signed certificates for the Hue service.

1.2 Create a configuration file for generating the SSL certificate.

```bash
cat <<EOF > openssl.cnf
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
prompt = no

[req_distinguished_name]
CN = Trino.svc

[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth, serverAuth
subjectAltName = @alt_names
[alt_names]
DNS.1 = hue
DNS.2 = hue.hue
DNS.3 = hue.hue.svc
EOF
```

1.3 Create a CA certificate.

```bash
openssl req -days 730 -nodes -new -x509 -keyout ca.key -out ca.crt -subj "/CN=Hue.svc"
```

1.4 Create a private key.

```bash
openssl genrsa -out key.pem 2048
```

1.5 Create a certificate request.

```bash
openssl req -new -key key.pem -out req.pem -config openssl.cnf
```

1.6 Sign the certificate request using the CA file.

```bash
openssl x509 -req -in req.pem -CA ca.crt -CAkey ca.key -CAcreateserial -out cert.pem -days 365 -extensions v3_req -extfile openssl.cnf
```

1.7 Combine the private key and certificate into one file.

```bash
cat key.pem cert.pem > tls-combined.pem
```

1.8 Create a secret for `hue` in Kubernetes.

```yaml
kind: Secret
apiVersion: v1
metadata:
  name: hue-tls
  namespace: hue
data:
  tls-combined.pem: >-
    tls-combined.pem | base64
type: opaque
```

2. Using Cert-manager to get the certificate.

**Note**: Cert-manager must be installed in the cluster for this to work.

2.1 Use cluster-issuer to create a certificate.

The configuration is as follows.

```yaml
certManagerInegration:
  enabled: enabled
  secretName: hue-tls-cm
  clusterIssuerName: common-cluster-issuer
```

2.2 Use a custom issuer to create a certificate.

The configuration is as follows.

```yaml
certManagerInegration:
  enabled: enabled
  secretName: hue-tls-cm
```

#### Enable TLS on Hue Ingress

Some ingress providers allow setting default certificates and forcing HTTPS for all ingresses in a cluster. 
For example, refer to nginx ingress details at https://kubernetes.github.io/ingress-nginx/user-guide/tls/#default-ssl-certificate.
In this case, all ingresses in the k8s cluster are using the same default certificate. NGINX controller can be configured to force HTTPS for all ingresses even if `tls` settings are omitted for the ingress.  
In this case, no changes are required for the Hue ingress configuration.

However, it is possible to use TLS for Hue ingress separately using a custom certificate. For example:

```yaml
ingress:
  create: true
  type: "nginx"
  domain: <hue.k8s.com>
  tls:
    enabled: false
    secretName: hue-tls-cm
```

How to get a secret with certificates for `tls.secretName` is described in the [Get TLS/SSL Certificates](#get-tlsssl-certificate) section.

#### Enable TLS on Hue Service

You can enable TLS on Hue service as follows:

1. Prepare and mount certificates as described in the [Prepare TLS/SSL Certificate](#prepare-tlsssl-certificate) section.
2. Set the mounted certificates for `ssl_certificate` and `ssl_private_key` properties in `hue -> ini -> [desktop]` to enable TLS on Hue as a backend.

```yaml
hue:
  ini: >
    [desktop]

    ssl_certificate=/etc/hue/certs/tls.crt

    ssl_private_key=/etc/hue/certs/tls.key

    <...other properties...>
```

#### Enable TLS on Hue UI Inside Kubernetes

It is possible to enable TLS on Hue web user interface directly inside kubernetes. For this, Hue needs TLS key and certificate. 
TLS key and certificate can be requested from cert-manager using `certManagerInegration.enabled` parameter. By default, it will create secret `hue-tls-cm` with TLS certificate, TLS key and CA certificate. 
Alternatively, TLS key and certificate can be specified and mounted into the pod using `extraSecrets`, `extraVolumes`, `extraVolumeMounts` parameters.
Then, the mounted certificates should be set for `ssl_certificate` and `ssl_private_key` properties in `hue -> ini -> [desktop]` to enable TLS on Hue as a backend.
If using kubernetes with NGINX ingress controller, it is possible to pass the annotations for ingress controller to work with TLS backend. Configuration examples are given below.

```yaml
ingress:
  annotations:
    nginx.ingress.kubernetes.io/backend-protocol: HTTPS
    nginx.ingress.kubernetes.io/proxy-ssl-verify: 'on'
    nginx.ingress.kubernetes.io/proxy-ssl-name: 'hue.<hue_namespace>'                             <----- replace <hue_namespace> with actual value
    nginx.ingress.kubernetes.io/proxy-ssl-secret: '<hue_namespace>/<hue_service_tls_secret_name>' <----- replace <hue_namespace> and <hue_service_tls_secret_name> with actual values
  
certManagerInegration:
  enabled: true
  secretName: hue-tls-cm
  secretMounts:
    - mountPath: /etc/hue/certs/
  clusterIssuerName: common-cluster-issuer

hue:
  ini: >
    [desktop]

    ssl_certificate=/etc/hue/certs/tls.crt

    ssl_private_key=/etc/hue/certs/tls.key

    <...other properties...>

```

#### Re-encrypt Route in Openshift Without NGINX Ingress Controller

Ingress TLS re-encryption configuration in Openshift can be the same as for Kubernetes, if NGINX Ingress Controller is installed on Openshift. 
If no NGINX Ingress Controller is installed on Openshift, the following steps should be done to enable TLS re-encryption:

1. Disable Ingress in deployment parameters: `ingress.create: false`.

   Deploy with enabled web Ingress leads to incorrect Ingress and Route configuration.

2. Create Route manually. You can use the following template as an example:

   ```yaml
   kind: Route
   apiVersion: route.openshift.io/v1
   metadata:
     annotations:
       route.openshift.io/termination: reencrypt
     name: <specify-unique-route-name>
     namespace: <specify-namespace-where-hue-is-installed>
   spec:
     host: <specify-your-target-host-here>
     to:
       kind: Service
       name: hue
       weight: 100
     port:
       targetPort: http
     tls:
       termination: reencrypt
       destinationCACertificate: <place-CA-certificate-here-from-hue-TLS-secret>
       insecureEdgeTerminationPolicy: Redirect
   ```

**Note**: If you cannot access the webserver host after Route creation because of "too many redirects" error, then one of the possible root
causes, there is HTTP traffic between balancers and the cluster. To resolve this issue, it is necessary to add the Route name to
the exception list at the balancers.

**Note** It might be possible to create the route in openshift automatically using annotations like `route.openshift.io/destination-ca-certificate-secret` and `route.openshift.io/termination: "reencrypt"` but this approach was not tested.

### Secure Connections from Hue

In order to secure the connections from Hive Metastore using TLS/SSL, there are three options for adding certificates:

#### Adding a Certificate

The procedure for adding a certificate is specified below.

1. An appropriate CA certificate needs to be mounted to `/home/hue/trustcerts/ca.crt`.
Cert manager can be configured to generate certificates:

```yaml
certManagerInegration:
  enabled: true
  secretName: hue-tls-cm
  secretMounts:
    - mountPath: /home/hue/trustcerts/ca.crt
      subPath: ca.crt
  duration: 365
  subjectAlternativeName:
    additionalDnsNames: [ ]
    additionalIpAddresses: [ ]
  clusterIssuerName: common-cluster-issuer
```

2. Add certificates using `extraSecrets` deployment parameter. Mounting details are set using the `extraVolumes` and `extraVolumeMounts` parameters. The Certificates should be mounted to `/home/hue/trustcerts/ca.crt`.

```yaml
extraSecrets:
  tls-custom-cert:
    stringData: |
      cm-ca.crt: |
       -----BEGIN CERTIFICATE-----
       certificate content goes here
       -----END CERTIFICATE-----

extraVolumes:
  - name: tls-custom-cert
    secret:
      secretName: tls-custom-cert
extraVolumeMounts:
  - name: tls-custom-cert
    mountPath: /home/hue/trustcerts/ca-custom.crt
    subPath: cm-ca.crt
    readOnly: true
```

3. Add an existing secret to truststore. In this case, only `extraVolumes` and `extraVolumeMounts` parameters need to be configured to mount the secret.
   

```yaml
extraVolumes:
  - name: defaultcert
    secret:
      secretName: defaultsslcertificate

extraVolumeMounts:
  - name: defaultcert
    mountPath: /home/hue/trustcerts/ca-bundle.crt
    subPath: ca-bundle.crt
    readOnly: true
```

#### Configure Connections to Use SSL/TLS

To configure the connections to use SSL/TLS:

1. Add the following env variables:
```yaml
env:
  - name: REQUESTS_CA_BUNDLE
    value: /home/hue/trustcerts/ca.crt
  - name: SSL_CERT_FILE
    value: /home/hue/trustcerts/ca.crt
  - name: PGSSLROOTCERT
    value: /home/hue/trustcerts/ca.crt
  - name: POSTGRES_SSLMODE
    value: "verify-ca"
```
2. Update PG host and port to use the secured address.
3. Add `options='{"sslmode": "verify-ca"}'` to `ini` > `[desktop]` > `[[database]]`.
```yaml
ini: >
    [desktop]

    [[database]]

    host=pg-patroni.postgres-tls.svc

    engine=postgresql_psycopg2

    user=hue

    password=hue_pass

    name=hue

    options='{"sslmode": "verify-ca"}'
```
4. Update `interpreters` settings to secure the connections from Hue.
For PostgreSQL add `?sslmode=verify-ca` to URL.
```yaml
  interpreters: >
    [[[postgresql]]]

    name = PostgreSql

    interface=sqlalchemy

    options='{"url": "postgresql+psycopg2://hue:hue_pass@pg-patroni.postgres-tls.svc:5432/hue?sslmode=verify-ca"}'
    
```
For services connecting via Trino, add `"connect_args":"{\"protocol\": \"https\"}"` to `options`.
```yaml
  interpreters: >
    [[[trino_cassandra]]]
    
    name=cassandra
    
    interface=sqlalchemy
    
    options='{"url":"trino://trino.trino-namespace:8443/cassandra","connect_args":"{\"protocol\": \"https\"}"}'
    
    [[[trino_mongo]]]

    name = mongodb

    interface= sqlalchemy
    
    options='{"url": "trino://trino.trino-namespace:8443/mongodb","connect_args":"{\"protocol\": \"https\"}"}'

    [[[trino_redis]]]

    name = redis

    interface= sqlalchemy
    
    options='{"url": "trino://trino.trino-namespace:8443/redis","connect_args":"{\"protocol\": \"https\"}"}'
```

##### Disable Certificate Validation

To disable the certificate validation, configure the following:

```yaml
  env:
    - name: POSTGRES_SSLMODE
      value: "allow"
      
  ini: >
    [desktop]

    [[database]]

    host=pg-patroni.postgres-tls.svc

    engine=postgresql_psycopg2

    user=hue

    password=hue_pass

    name=hue

    options='{"sslmode": "allow"}'

  interpreters: >
    [[[postgresql]]]

    name = PostgreSql
  
    interface=sqlalchemy
  
    options='{"url": "postgresql+psycopg2://hue:hue_pass@pg-patroni.postgres-tls.svc:5432/hue?sslmode=allow"}'
    
    [[[trino_cassandra]]]
    
    name=cassandra
    
    interface=sqlalchemy
    
    options='{"url":"trino://trino.trino-namespace:8443/cassandra","connect_args":"{\"protocol\": \"https\", \"requests_kwargs\": {\"verify\": false}}"}'
    
    [[[trino_mongo]]]
  
    name = mongodb
  
    interface= sqlalchemy
    
    options='{"url": "trino://trino.trino-namespace:8443/mongodb","connect_args":"{\"protocol\": \"https\", \"requests_kwargs\": {\"verify\": false}}"}'
  
    [[[trino_redis]]]
  
    name = redis
  
    interface= sqlalchemy
    
    options='{"url": "trino://trino.trino-namespace:8443/redis","connect_args":"{\"protocol\": \"https\", \"requests_kwargs\": {\"verify\": false}}"}'

```

### Kerberized Data Source

If you have the kerberized data source, at least one of them, for example, HIVE.

To make Hue use the principal to connect to data sources, you need to specify the `[[kerberos]]` tag after `[desktop]` as given below.

```yaml
hue:
  ini: |
    [desktop]
    app_blacklist=filebrowser,search,hbase,security,jobbrowser,oozie
    [[database]]
    host=hue-db
    engine=mysql
    user=hue
    password=password
    name=hue
    [[kerberos]]
    # Path to Hue's Kerberos keytab file
    hue_keytab=/etc/hue/keytabs/service.keytab

    # Kerberos principal name for Hue
    # hue_principal=mapr/<hostname>@<realm>
    # Substitute your hostname and realm in the example below
    hue_principal=mapr/<hostname>@<realm>

    # Path to keep Kerberos credentials cached
    ccache_path=/tmp/krb5cc_1001
    # Frequency in seconds with which Hue will renew its keytab
    # keytab_reinit_frequency=86400

    # Path to kinit
    # Note that the actual path depends on which Linux OS you are using
    kinit_path=/usr/bin/kinit
```

Additionally, to specify Kerberos in the Hue configuration, you need to specify their values.

```yaml
kerberos:
  enabled: True
  keytab: |
    BQIAAABSAAEADFRFU1RBRC5MT0NBTAAPZHRsazMtc2l0bC11c2VyAAAAAWEY0lkBABIAIET7eb54fCCmNWLlYxeidjPdtvnDj2/yprsynHUxqbzBAAAAAQ==
  config: |
    [ libdefaults ]
      renew_lifetime = 7d
      forwardable = true
      default_realm = LDAP.REALM
      ticket_lifetime = 24h
      dns_lookup_realm = false
      dns_lookup_kdc = false
      default_ccache_name = /tmp/krb5cc_%{uid}
      #default_tgs_enctypes = aes des3-cbc-sha1 rc4 des-cbc-md5
      #default_tkt_enctypes = aes des3-cbc-sha1 rc4 des-cbc-md5

      [ logging ]
      default = FILE:/var/log/krb5kdc.log
      admin_server = FILE:/var/log/kadmind.log
      kdc = FILE:/var/log/krb5kdc.log

      [ realms ]
      LDAP.REALM = {
      admin_server = <AD URL>
      kdc = <AD URL>
      }
```

Where, `keytab` is the base64 encoded keytab that is generated on any Hadoop node or on local KRB5, and `config` is the krb5.conf file that can be downloaded from any Hadoop node or from the Ambari UI. 

**Note**: Do not forget to insert the main data source part, for example, for HIVE, it was described in [Connection to Hive](#hive).

**Note**: With configured kerberos, postgresql pscycopg client tries to enable the GSSAPI connection mode to PG by default (see https://jdbc.postgresql.org/documentation/publicapi/org/postgresql/jdbc/GSSEncMode.html). This can cause unwanted failed login attempts at KDC server. To avoid this, it is possible to disable the `gssencmode` pg connection option, for example:

```yaml
[[database]]
...
options='{"sslmode": "verify-ca", "gssencmode": "disable"}'
```

### Hue with Ldap Integrated User Interface

If you want to allow the Hue user interface to integrate with LDAP instead of using local users, you need to specify the parameters for hue.ini as given below.

```yaml
    [desktop]
    app_blacklist=filebrowser,search,hbase,security,jobbrowser,oozie
    [[auth]]
    backend=desktop.auth.backend.LdapBackend
    [[ldap]]
    ldap_url=ldaps://ldapurl
    search_bind_authentication=true
    create_users_on_login=true
    base_dn="base dn"
    bind_dn="bind dn"
    bind_password_script=sh /var/lib/hue/hue_passwords.sh
    [[[users]]]
    user_filter="objectclass=user"
    user_name_attr="sAMAccountName"
    [[[groups]]]
    group_filter="objectclass=group"
    group_name_attr="cn"
    group_member_attr="member"
```

Also, you need to specify the section for getting the ldap password.

```yaml
ldap:
  enabled: True
  bind_password_script: |
    ZWNobyAiUkFQdG9yMTIzNCEi
```

Where, `bind_password_script` should be encoded in the base64 bash script, which provides the password for the principal you specified above.

For example, this `ZWNobyAiUkFQdG9yMTIzNCEi` encoded script `echo "password"`.

### Hue Keycloak (OIDC) for SSO Login

Hue supports integration with Keycloak. It allows users from Keycloak to login into Hue Web user interface. 
Successfully authenticated users can be crated in Hue database.

*Keycloak Configuration*  
1. Create a client in Keycloak. The following should be configured for the client:
   * Client ID
   * Client Secret (`Credentials` tab)
   * Valid redirect URIs (`http://<hue_ingress>/oidc/callback/*`)
   * Client authentication should be On.
   * Authentication flow: Standard flow, Direct access grants.
   ![Client](./images/keycloak_client.png)
2. Open the client created at step 1 and navigate to the `Client scopes` tab.  
   ![Mapper](./images/keycloak_client_scopes.png)
   Go to `<client_name>-dedicated` assigned client scope and app a mapper with a user attribute that will be used as username in Hue.
   For example:
   * Add a mapper by configuration.
   * Select the `User Property` mapper type.
   * Set `email` to `Property`. Email will be used as a username in Hue.
   * `Add to ID token`, `Add to access token`, `Add to userinfo` should be `On`.
   ![Mapper](./images/keycloak_mapper.png)
3. To make users admins after login:
    * Open the client created at step 1 and go to `Client scopes` tab.
    * On `Client scopes` tab go to `<client_name>-dedicated`. 
    * Add a mapper by configuration.
    * Select the `Group Membership` mapper type.
    * Set `group_membership` to `Token Claim Name`.
    * `Add to ID token`, `Add to access token`, `Add to userinfo` should be `On`.
    * Add the user to admin group, for example, `hue_superusers`, and set the name of that group as `superuser_group=hue_superusers` in the Hue configuration (described below).
    ![Mapper](./images/keycloak_group_mapper.png)
   
*Hue Configuration*  
Below is an example of Hue configuration for Keycloak integration:
```yaml
ini: >
  [desktop]
  ...
  
  [[auth]]
  # Enables Keycloak OIDC SSO login
  backend=desktop.auth.backend.OIDCBackend
  
  # Hue session timeout not session in Keycloak 
  idle_session_timeout=30
  
  [[oidc]]
  
  # Keycloak client name
  oidc_rp_client_id=hue
 
  # Keycloak client secret
  oidc_rp_client_secret=bVVihRhd9WRJt4AgUECG3cNfaUctuZOx
  
  # Keycloak endpoints. Use https://<keycloak_address>/auth/realms/<realm>/.well-known/openid-configuration to get the endpoints.
  oidc_op_authorization_endpoint=https://<keycloak_address>/auth/realms/<realm>/protocol/openid-connect/auth
  oidc_op_token_endpoint=https://<keycloak_address>/auth/realms/<realm>/protocol/openid-connect/token
  oidc_op_user_endpoint=https://<keycloak_address>/auth/realms/<realm>/protocol/openid-connect/userinfo
  oidc_op_jwks_endpoint=https://<keycloak_address>/auth/realms/<realm>/protocol/openid-connect/certs
  logout_redirect_url=https://<keycloak_address>/auth/realms/<realm>/protocol/openid-connect/logout
  
  # Enables Keycloak TLS certificate validation
  oidc_verify_ssl=true
  
  login_redirect_url=http://<hue_ingress>/oidc/callback/
  login_redirect_url_failure=http://<hue_ingress>/hue/oidc_failed/
  
  # Enables successfully authenticated users creation in Hue
  create_users_on_login=true
  
  # User attribute name in Keycloak to use as a user name in Hue
  oidc_username_attribute=email

  # The group of users will be created and updated as superuser. To use this feature, setup in Keycloak:
  # 1. add the name of the group here
  # 2. in Keycloak, go to your_realm --> your_clients --> Mappers, add a mapper
  #      Mapper Type: Group Membership (this is predefined mapper type)
  #      Token Claim Name: group_membership (required exact string)
  ## superuser_group=hue_superusers
```

Note that groups are not created in Hue. Setting `superuser_group` property only allows marking users as admins. 

#### Keycloak with TLS

To work with TLS enabled Keycloak CA certificate should be mounted into Hue pod. Also, `REQUESTS_CA_BUNDLE` should be set.

```yaml
env:
  - name: REQUESTS_CA_BUNDLE
    value: /home/hue/trustcerts/idpcert.pem

extraSecrets:
  tls-custom-cert:
    stringData: |
      idpcert.pem: |
       -----BEGIN CERTIFICATE-----
       certficate content goes here
       -----END CERTIFICATE-----

extraVolumes:
  - name: tls-custom-cert
    secret:
      secretName: tls-custom-cert
      
extraVolumeMounts:
  - name: tls-custom-cert
    mountPath: /home/hue/trustcerts/idpcert.pem
    subPath: idpcert.pem
    readOnly: true
```

## Configuration Trino

The configuration information for Trino is specified below.

### Internal Trino

By default, Trino is not enabled for working with databases.

To enable Trino, you must specify minimum parameters in the parameters.

```yaml
trino:
  enabled: true
```

You need to add a database connection via Trino.
Examples of connections can be found in the [Connecting to Trino Supported Databases](/docs/public/configuration-guide.md#connecting-to-trino-supported-databases) section under Hue Service Configuration.

#### Secure Connections for Internal Trino

If internal Trino is used to connect to services, the following configuration should be applied:
1. In case of using external secrets, `externalVolumes` and  `extraVolumeMounts` should be configured for Trino:
```yaml
  extraVolumes:
    - name: tls-custom-cert
      secret:
        secretName: tls-custom-cert
  extraVolumeMounts:
    - name: tls-custom-cert
      mountPath: /home/trino/trustcerts/ca.crt
      subPath: cm-ca.crt
      readOnly: true
```

If cert-manager is used, certificates will be mounted automatically.

2. Configure the connections as follows:
```yaml
databasescommon:
  enabled: true
  configs:
    mongodb.properties: |
      connector.name=mongodb
      mongodb.connection-url=mongodb://root:root@mongos.mongo-tls.svc/
      mongodb.tls.enabled=true
      mongodb.tls.keystore-path=/usr/lib/jvm/temurin/jdk-22.0.2+9/lib/security/cacerts
      mongodb.tls.truststore-path=/usr/lib/jvm/temurin/jdk-22.0.2+9/lib/security/cacerts
      mongodb.tls.keystore-password=<keystore password>
      mongodb.tls.truststore-password=<truststore password>
    cassandra.properties: |
      connector.name=cassandra
      cassandra.contact-points=cassandra.cassandra-tls.svc
      cassandra.native-protocol-port=9042
      cassandra.username=admin
      cassandra.password=admin
      cassandra.load-policy.dc-aware.local-dc=dc1
      cassandra.load-policy.use-dc-aware=true
      cassandra.tls.enabled=true
      cassandra.tls.keystore-path=/usr/lib/jvm/temurin/jdk-22.0.2+9/lib/security/cacerts
      cassandra.tls.truststore-path=/usr/lib/jvm/temurin/jdk-22.0.2+9/lib/security/cacerts
      cassandra.tls.keystore-password=<keystore password>
      cassandra.tls.truststore-password=<truststore password>
    redis.properties: |
      connector.name=redis
      redis.table-names: redis
      redis.nodes: hue.redis
      redis.default-schema: redis
      redis.password: hue
      redis.database-index: 1
      redis.table-description-dir: /dbadditionalconfigs/test.json
```

### Extrenal Trino

If there is already a Trino on the cluster, then you can use it as a connector to databases.

To do this, in the hue configuration file, instead of specifying the internal Trino address, specify the external Trino address on the cluster.

configuration example:

   ```yaml
  hue:
    interpreters: |
      [[[trino_redis]]]
      name = redis
      interface= sqlalchemy
      options='{"url": "trino://trino.trino:8080/redis"}'
  ```

**Warning**: Database properties must be specified in an external Trino.

<!-- #GFCFilterMarkerStart# -->
Refer to example connectors for external Trino [here](https://github.com/Netcracker/qubership-trino/blob/main/docs/public/user-guide.md#trino-connectors).
<!-- #GFCFilterMarkerEnd# -->

1. Certificates mount and connections security should be configured for external Trino as well.  
   Refer to the external Trino documentation's `Secure Connections from Trino` section of `Installation` guide.

2. Secure connections to services should be configured in external Trino's deployment parameters:
```yaml
catalogs:
  cassandra: |
    connector.name=cassandra
    cassandra.contact-points=cassandra.cassandra-tls.svc
    cassandra.native-protocol-port=9042
    cassandra.username=admin
    cassandra.password=admin
    cassandra.load-policy.dc-aware.local-dc=dc1
    cassandra.load-policy.use-dc-aware=true
    cassandra.tls.enabled=true
    cassandra.tls.keystore-path=/usr/lib/jvm/temurin/jdk-22.0.2+9/lib/security/cacerts
    cassandra.tls.truststore-path=/usr/lib/jvm/temurin/jdk-22.0.2+9/lib/security/cacerts
    cassandra.tls.keystore-password=<kystore password>
    cassandra.tls.truststore-password=<truststore password>

  mongodb: |
    connector.name=mongodb
    mongodb.connection-url=mongodb://root:root@mongos.mongo-tls.svc/
    mongodb.tls.enabled=true
    mongodb.tls.keystore-path=/usr/lib/jvm/temurin/jdk-22.0.2+9/lib/security/cacerts
    mongodb.tls.truststore-path=/usr/lib/jvm/temurin/jdk-22.0.2+9/lib/security/cacerts
    mongodb.tls.keystore-password=<keystore password>
    mongodb.tls.truststore-password=<truststore password>

  redis: |
    connector.name=redis
    redis.table-names: redis
    redis.nodes: hue.redis
    redis.default-schema: redis
    redis.password: <password>
    redis.database-index: 1
    redis.table-description-dir: /dbadditionalconfigs/test.json
```

# Installation

The installation procedure is specified below.

## Manual Deployment

Refer to the releases page to find the release tag.

1. Navigate to the desired release tag and download the `<repo_root>/helm/hue` directory.
   
2. Edit the parameters in the **values.yaml** file. The configuration parameter details are described in the [hue Configuration](/docs/public/configuration-guide.md) section.

3. Install the chart to the K8s namespace created in the [Prerequisites](#prerequisites) section.

   ```
   helm install <helm release name> <path to chart directory> --values <path to values.yaml file> --namespace <namespace to install hive-metastore> --debug
   #Example
   helm install hive-metastore . --debug
   ```

# On-Prem

The on-premises deployment information is described below.

## Non-HA Scheme

To do this, specify these parameters in the configuration:

```yaml
replicas: 1 
```

# Upgrade

The upgrade process is similar to the clean and installation process.
It is required to check the new release notes for incompatibility points of parameters with the new version of Hue.

# Rollback

The rollback process is specified below.

1. Clear the namespace.
   `kubectl get ns hue`
2. Run a fresh installation with the previous version. Select the version below in the repository.
3. Restore data from the backup.
