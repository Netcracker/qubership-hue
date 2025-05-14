## Table of Contents

* [Overview](#overview)
* [Architecture](docs/public/architecture.md)
* [Installation Guide](docs/public/installation.md)
* [Helm Chart Customizations](#helm-chart-customizations)

## Overview

Qubership-hue project provides images and helm charts to deploy hue and trino to Kuberneetes. Helm charts are based on [hue](https://github.com/gethue/hue/tree/master/tools/kubernetes/helm/hue) with some modifications.
Hue is a mature SQL Assistant for querying Databases & Data Warehouses.
Trino is used to connect to databases that are not covered by Hue support.

![Qubership-hue deployment schema Architecture](docs/internal/images/qubership-hue-non-ha-scheme.png)

---

## Helm Chart Customizations

This section documents the custom modifications made to the Qubership Hue Helm chart in this deployment, compared to the community [Hue charts](https://github.com/cloudera/hue/tree/master/tools/kubernetes/helm/hue)

### `values.yaml`

CUSTOM CHANGES: The following parameters have been added or modified to support our specific configuration requirements
```yaml

image:
   registry: "ghcr.io/netcracker/qubership-hue"
   tag: "main"
   pullPolicy: "IfNotPresent"
api:
  enabled: false
  domain: "api."
hue:
  priorityClassName: ~
  replicas: 1
  resources:
    limits:
      cpu: "300m"
      memory: "500Mi"
    requests:
      cpu: "200m"
      memory: "300Mi"
  service:
    annotations: { }
  database:
    initJobAnnotations:
      # This is what defines this resource as a hook. Without this line, the
      # job is considered part of the release.
      "helm.sh/hook": pre-install
      "helm.sh/hook-delete-policy": before-hook-creation,hook-succeeded,hook-failed
      "helm.sh/hook-weight": "-4"
    adminUser: "admin user name"
    adminPassword: "admin password"
  imagePullPolicy: Always
  podSecurityContext:
    runAsUser: 1001
  securityContext:
    capabilities:
      drop:
        - ALL
    seccompProfile:
      type: RuntimeDefault
    allowPrivilegeEscalation: false
    runAsNonRoot: true
    runAsUser: 1001
  hostAliases: []

  interpreters: |
    options='{"url": "postgresql+psycopg2://{{ include "postgres.hue.user" . }}:{{ include "postgres.hue.password" . }}@{{ include "postgres.host" . }}:{{ include "postgres.port" . }}/{{ .Values.hue.database.name }}"}'
#    [[[hive]]]
#    # The name of the snippet.
#    name=Hive
#    # The backend connection to use to communicate with the server.
#    interface=hiveserver2
#    [[[trino]]]
#    name = Trino
#    interface= sqlalchemy
#    options='{"url": "trino://trino:8080/cassandra"}'
#    [[[trino1]]]
#    name = Redis-1
#    interface= sqlalchemy
#    options='{"url": "trino://trino:8080/redis"}'
#    [beeswax]
#    hive_conf_dir=/etc/hadoop/conf
#    hive_server_host=<hiv server host url>
#    security_enabled=true
#    mechanism=GSSAPI
  ini: |

    enable_xff_for_hive_impala=false
  
    enable_prometheus=false
    # [[auth]]
    # backend=desktop.auth.backend.LdapBackend
    # [[ldap]]
    # ldap_url=ldaps://ldapurl
    # search_bind_authentication=true
    # create_users_on_login=true
    # base_dn="user base_dn"
    # bind_dn="bind_dn"
    # bind_password_script=sh /var/lib/hue/hue_passwords.sh
    # [[[users]]]
    # user_filter="objectclass=user"
    # user_name_attr="sAMAccountName"
    # [[[groups]]]
    # group_filter="objectclass=group"
    # group_name_attr="cn"
    # group_member_attr="member"
    [[database]]
    host={{ include "postgres.host" . }}
    engine=postgresql_psycopg2
    user={{ include "postgres.hue.user" . }}
    password={{ include "postgres.hue.password" . }}
    name={{ .Values.hue.database.name }}
    # [[kerberos]]
    # Path to Hue's Kerberos keytab file
    # hue_keytab=/etc/hue/keytabs/service.keytab

    # Kerberos principal name for Hue
    # hue_principal=mapr/<hostname>@<realm>
    # Substitute your hostname and realm in the example below
    # hue_principal=userr@LDAP.REALM.LOCAL

    # Path to keep Kerberos credentials cached
    
    # ccache_path=/tmp/krb5cc_1001
    # Frequency in seconds with which Hue will renew its keytab
    # keytab_reinit_frequency=86400

    # Path to kinit
    # Note that the actual path depends on which Linux OS you are using
    # kinit_path=/usr/bin/kinit

createDBJob:
  resources:
    limits:
      cpu: 500m
      memory: 512Mi
    requests:
      cpu: 300m
      memory: 300Mi
ingress:
  create: true
  domain: ""
  tls:
    enabled: false
    # secretName: hue-tls-cm
  annotations: {}
#    nginx.ingress.kubernetes.io/backend-protocol: HTTPS
#    nginx.ingress.kubernetes.io/proxy-ssl-verify: 'on'
#    nginx.ingress.kubernetes.io/proxy-ssl-name: 'hue.<hue_namespace>'
#    nginx.ingress.kubernetes.io/proxy-ssl-secret: '<hue_namespace>/<hue_service_secret_name>'

  # loadBalancerIp: "127.0.0.1"
ssl:
  enabled: false
  cacerts: |
    ""

kerberos:
  enabled: false
  keytab: |
    ""
  config: |
    ""

ldap:
  enabled: false
  bind_password_script: |
    ""

databasescommon:
  enabled: false
  configs:
    mongodb.properties: |
      connector.name=mongodb
      mongodb.connection-url=mongodb://root:root@mongos.mongo.svc/
    cassandra.properties: |
      connector.name=cassandra
      cassandra.contact-points=cassandra.cassandra
      cassandra.native-protocol-port=9042
      cassandra.security=PASSWORD
      cassandra.username=cassandra user
      cassandra.password=cassandra user password
      cassandra.load-policy.dc-aware.local-dc=dc1
      cassandra.load-policy.use-dc-aware=true
    redis.properties: |
      connector.name=redis
      redis.table-names: redis
      redis.nodes: redis.redis
      redis.default-schema: default
      redis.password: redis password
      redis.database-index: 1
      redis.table-description-dir: /dbadditionalconfigs/test.json
    tpch.properties: |
      connector.name=tpch

#additionalConfigs:
#  test.json: |
#    {
#      "tableName": "redis",
#      "schemaName": "redis",
#      "key": {
#        "dataFormat": "raw",
#        "fields": [
#          {
#            "name": "redis_key",
#            "type": "varchar",
#            "hidden": "false"
#          }
#        ]
#      },
#      "value": {
#        "dataFormat": "raw",
#        "fields": [
#          {
#            "name": "redis_value",
#            "type": "varchar",
#            "hidden": "false"
#          }
#        ]
#      }
#    }

trino:
  enabled: false
  image: ghcr.io/netcracker/qubership-trino:main
  imagePullPolicy: "IfNotPresent"
  replicas: 1
  priorityClassName: ~
  resources:
    limits:
      cpu: 150m
      memory: 800Mi
    requests:
      cpu: 100m
      memory: 600Mi
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
  hostAliases: []
  extraVolumes: []
#    - name: tls-pg-cert
#      secret:
#        secretName: tls-pg-cert
  extraVolumeMounts: []
#    - name: tls-pg-cert
#      mountPath: /home/trino/trustcerts/ca.crt
#      subPath: cm-ca.crt
#      readOnly: true

jvmconfig: |
  -XX:+ExplicitGCInvokesConcurrent
  -XX:+HeapDumpOnOutOfMemoryError
  -XX:+UseGCOverheadLimit
  -XX:+ExitOnOutOfMemoryError
  -XX:ReservedCodeCacheSize=256M
  -Djdk.attach.allowAttachSelf=true
  -Djdk.nio.maxCachedBufferSize=2000000
  -DHADOOP_USER_NAME=hadoop user name

jvm:
  maxHeapSize: 1G
  gcMethod:
    type: UseG1GC
    g1:
      heapRegionSize: 16M

certManagerInegration:
  enabled: false
  secretName: hue-tls-cm
  secretMounts:
    - mountPath: /home/hue/trustcerts/ca.crt
      subPath: ca.crt
  duration: 365
  subjectAlternativeName:
    additionalDnsNames: [ ]
    additionalIpAddresses: [ ]
  clusterIssuerName: ~

extraSecrets: {}
#  tls-custom-cert:
#    stringData: |
#      cm-ca.crt: |
#       -----BEGIN CERTIFICATE-----
#       certificate content goes here
#       -----END CERTIFICATE-----
#

extraVolumes: []
#  - name: tls-custom-cert
#    secret:
#      secretName: tls-custom-cert

extraVolumeMounts: []
#  - name: tls-custom-cert
#    mountPath: /home/hue/trustcerts/ca-custom.crt
#    subPath: cm-ca.crt
#    readOnly: true
 

```

---

### `deployment-hue-api.yaml`

```yaml
metadata:
  # Qubership custom change: custom labels for Qubership release support
  name: {{ .Chart.Name }}-hue-api
  labels:
    app: {{ .Chart.Name }}
    component: hue
    release: {{ .Release.Name }}
spec:
  
  selector:
    matchLabels:
      # Qubership custom change: custom labels for Qubership release support
      app: {{ .Chart.Name }}
      component: hue
      release: {{ .Release.Name }}
  template:
    metadata:
      labels:
        # Qubership custom change: custom labels for Qubership release support
        app: {{ .Chart.Name }}
        component: hue
        release: {{ .Release.Name }}
    spec:
      containers:
        imagePullPolicy: {{ .Values.hue.imagePullPolicy }}    
```
---

### `deployment-hue.yaml`

```yaml
metadata:
  # Qubership custom change: custom name and namespce for Qubership release support
  name: {{ .Chart.Name }}-hue
  namespace: {{ .Release.Namespace }}
  labels:
    # Qubership custom change: custom labels for Qubership release support
    {{- include "hue.deploymentOnlyLabels" . | nindent 4 }}
    {{- include "hue.deploymentAndServiceOnlyLabels" . | nindent 4 }}
    {{- include "allObjectsLabels" . | nindent 4 }}
spec:
  selector:
    matchLabels:
      # Qubership custom change: Qubership release support
      {{- include "hue.selectorLabels" . | nindent 6 }}

  template:
    metadata:
      labels:
      # Qubership custom change: custom labels for Qubership release support
        {{- include "allObjectsLabels" . | nindent 8 }}
        {{- include "hue.deploymentOnlyLabels" . | nindent 8 }}
        {{- include "hue.deploymentAndServiceOnlyLabels" . | nindent 8 }}
      annotations:
        # Qubership custom change: Using secret instead of configmap for security
        checksum/config: {{ include (print $.Template.BasePath "/hue/secrets-hue.yaml") . | sha256sum }}
        checksum/config-extra: {{ include (print $.Template.BasePath "/hue/secrets-hue.yaml") . | sha256sum }}
        checksum/config-hive: {{ include (print $.Template.BasePath "/hue/secret-hive.yaml") . | sha256sum }}
        checksum/hue-secret: {{ include (print $.Template.BasePath "/hue/secrets-hue.yaml") . | sha256sum }}
        # Qubership custom change: Using kerberos for authentication
        checksum/kerberos-config: {{ include (print $.Template.BasePath "/hue/kerberos-hue.yaml") . | sha256sum }}
      initContainers:
        # Qubership custom change: custom image for init container, and custom connection paramters
          image: {{ template "hue.image" . }}
          args: 
           - >
              set -x;
              while [ $(curl -s --connect-timeout 1 {{ include "postgres.host" . }}:{{ include "postgres.port" . }} || echo $?) -ne 52 ]; do
                sleep 1;
              done
# Qubership custom change: Qubership Custom pod-level settings for Qubership Hue: security, scheduling, host aliases, and restart policy from Helm values
          {{- if .Values.hue.securityContext }}
          securityContext:
            {{- toYaml .Values.hue.securityContext | nindent 12 }}
          {{- end }}
      {{- if .Values.hue.priorityClassName }}
      priorityClassName: {{ .Values.hue.priorityClassName }}
      {{- end }}
      {{- if .Values.hue.hostAliases }}
      hostAliases:
         {{- toYaml .Values.hue.hostAliases | nindent 8 }}
      {{- end }}
      restartPolicy: Always
      {{- if .Values.hue.nodeSelector }}
      nodeSelector:
        {{- toYaml .Values.hue.nodeSelector | nindent 8 }}
      {{- end }}
      {{- if .Values.hue.affinity }}
      affinity:
        {{- toYaml .Values.hue.affinity | nindent 8 }}
      {{- end }}
      {{- if .Values.hue.tolerations }}
      tolerations:
        {{- toYaml .Values.hue.tolerations | nindent 8 }}
      {{- end }}
      {{- if .Values.hue.podSecurityContext }}
      securityContext:
        {{- toYaml .Values.hue.podSecurityContext | nindent 8 }}
      {{- end }}
      containers:
      # Qubership custom change: Qubership Custom container config for Qubership Hue with dynamic image, security, args, and env based on Helm values
      - name: {{ .Chart.Name }}-hue
        image: {{ include "hue.image" . }}
        imagePullPolicy: {{ .Values.hue.imagePullPolicy }}
        {{- if .Values.hue.securityContext }}
        securityContext:
          {{- toYaml .Values.hue.securityContext | nindent 10 }}
        {{- end }}
        {{- if .Values.hue.args }}
        args: {{ tpl (toYaml .Values.hue.args) . | nindent 12 }}
          {{- end }}
        {{- if .Values.env }}
        env:
          {{- toYaml .Values.env | nindent 12}}
        {{- end }}
        volumeMounts:
        # Qubership custom change: Qubership Custom volume mounts for Qubership Hue from cert-manager secrets and extra user-defined mounts via Helm values
          {{- if .Values.certManagerInegration.enabled }}
          {{- range .Values.certManagerInegration.secretMounts }}
          - name: {{ $.Values.certManagerInegration.secretName }}-volume
            mountPath: {{ .mountPath }}
            {{- if .subPath }}
            subPath: {{ .subPath }}
            {{- end }}
          {{- end }}
          {{- end }}
          {{- if .Values.extraVolumeMounts }}
            {{- tpl (toYaml .Values.extraVolumeMounts) . | nindent 10 }}
          {{- end }}
          - name: config-volume
            mountPath: /usr/share/hue/desktop/conf/z-hue.ini
            subPath: z-hue.ini
          - name: config-volume-extra
            mountPath: /usr/share/hue/desktop/conf/zz-hue.ini
            subPath: zz-hue.ini
          - name: hive-config-volume
            mountPath: /etc/hive/conf/hive-site.xml
            subPath: hive-site.xml
          # Qubership custom change: Qubership Conditional volume mounts for Kerberos, SSL, and LDAP integrations based on enabled Helm values  
          {{- if .Values.kerberos.enabled }}
          - name: keytabs
            mountPath: "/etc/hue/keytabs/"
            readOnly: true
          - name: kerberos-config
            mountPath: /etc/krb5.conf
            subPath: krb5.conf
          {{- end }}
          {{- if .Values.ssl.enabled }}
          - name: cacerts
            mountPath: "/etc/hue/"
            readOnly: true
          {{- end }}
          {{- if .Values.ldap.enabled }}
          - name: scripts
            mountPath: "/var/lib/hue/hue_passwords.sh"
            subPath: hue_passwords.sh
          {{- end }}
        readinessProbe:
          httpGet:
          # Qubership custom change: Qubership support for secure connections
          {{- if contains "ssl_private_key" .Values.hue.ini  }}
            scheme: HTTPS
          {{ else }}
            scheme: HTTP
          {{- end }}
          initialDelaySeconds: 30
          timeoutSeconds: 15
          periodSeconds: 15
        resources:
          {{- toYaml .Values.hue.resources | nindent 12 }}
    volumes:
      # Qubership custom change: Qubership custom volumes for config files, cert-manager secrets, and conditional integrations (Kerberos, SSL, LDAP) using Helm values
        {{- if .Values.certManagerInegration.enabled }}
        - name: {{.Values.certManagerInegration.secretName }}-volume
          secret:
            secretName: {{.Values.certManagerInegration.secretName }}
        {{- end }}
        {{- if .Values.extraVolumes }}
          {{- tpl (toYaml .Values.extraVolumes) . | nindent 8 }}
        {{- end }}
        - name: config-volume
          secret:
            secretName: hue-config
            items:
              - key: z-hue.ini
                path: z-hue.ini
        - name: config-volume-extra
          secret:
            secretName: hue-config-extra
            items:
              - key: zz-hue.ini
                path: zz-hue.ini
        - name: hive-config-volume
          secret:
            secretName: hue-hive-config
            items:
              - key: hive-site.xml
                path: hive-site.xml
        {{- if .Values.kerberos.enabled }}
        - name: keytabs
          secret:
            secretName: keytabs
        - name: kerberos-config
          configMap:
            name: {{ .Chart.Name }}-kerberos
        {{- end }}
        {{- if .Values.ssl.enabled }}
        - name: cacerts
          secret:
            secretName: cacerts
        {{- end }}
        {{- if .Values.ldap.enabled }}
        - name: scripts
          secret:
            secretName: scripts
        {{- end }}
      serviceAccountName: ""

```
---

### `service-hue-api.yaml`
```yaml
metadata:
  # Qubership custom change: custom annotations for Qubership release support
  {{- if .Values.hue.service.annotations }}
  annotations:
    {{- toYaml .Values.hue.service.annotations | nindent 4 }}
  {{- end }}
  labels:
    # Qubership custom change: custom labels for Qubership release support
    app: {{ .Chart.Name }}
    component: hue
    release: {{ .Release.Name }}
spec:
            
  ports:
  - name: hue-api
    port: 8005
    #Qubership custom change: using ingress instead of Nodeport
    targetPort: 8005
  selector:
    pod: hue-api
    # Qubership custom change: Qubership release support
    app: {{ .Chart.Name }}
    component: hue
    release: {{ .Release.Name }}
```
---

### `service-hue.yaml`

```yaml
metadata:
  name: hue
  # Qubership custom change: custom namespace for Qubership release support
  namespace: {{ .Release.Namespace }}
  # Qubership custom change: custom annotations for Qubership release support
  {{- if .Values.hue.service.annotations }}
  annotations:
    {{- toYaml .Values.hue.service.annotations | nindent 4 }}
  {{- end }}
  labels:
    # Qubership custom change: custom lables for Qubership release support
    {{- include "hue.deploymentAndServiceOnlyLabels" . | nindent 4 }}
    {{- include "allObjectsLabels" . | nindent 4 }}
spec:
  ports:
  - name: hue
    port: 8888
    #Qubership custom change: using ingress instead of Nodeport
    targetPort: 8888
  selector:
    # Qubership custom change: custom lables for Qubership release support
    {{- include "hue.selectorLabels" . | nindent 4 }}
```
---
_helpers.tpl added to define Qubership custom Helm template functions for defining Kubernetes resources related to Qubership Hue and Trino deployments

configmap-hive.yaml is converted to secret-hive.yaml and configmap-hue-extra.yaml, configmap-hue.yaml files are converted to secret-hue.yaml for security reasons.

createdbjob.yaml and posgressconnparams are added as a pg pre install hooks to initlize the Qubership Hue DB and a secret contains  PostgreSQL credentials for initialization Job.

extrasecrets.yaml,tls-certificate-hue.yaml, tls-issuer-hue.yaml these files are added to provide complete TLS support and enable integration with cert-manager for secure HTTPS communication.

ingress-hue.yaml added to create Ingress for Qubership Hue and API, with TLS and custom annotations based on Helm values

kerberos-hue.yaml added to create ConfigMap for Kerberos configuration if Kerberos is enabled via Helm values

---
### Trino customizations

trino-databases-additional-configs.yaml, trino-databases-secret.yaml, trino-deployment.yaml, trino-jvm-configmap.yaml, trino-service.yaml are created to support Trino deployment and connections.
