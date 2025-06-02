#-- Qubership custom Helm template functions for defining Kubernetes resources related to Hue and Trino deployments --
{{/*
Expand the name of the chart.
*/}}
{{- define "hue.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "hue.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "hue.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "hue.labels" -}}
helm.sh/chart: {{ include "hue.chart" . }}
{{ include "hue.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "hue.image" -}}
{{- printf "%s:%s" .Values.image.registry .Values.image.tag }}  
{{- end }}

{{ define "trinodb.image" -}}
{{ printf "%s" (.Values.trino.image) }}
{{- end }}

{{/*
Hue selector labels
*/}}
{{- define "hue.selectorLabels" -}}
app.kubernetes.io/name: {{ include "hue.name" . }}
app.kubernetes.io/instance: hue-{{ .Release.Namespace | nospace | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Hue deployment only labels for Qubership release
*/}}
{{- define "hue.deploymentOnlyLabels" -}}
app.kubernetes.io/instance: hue-{{ .Release.Namespace | nospace | trunc 63 | trimSuffix "-" }}
app.kubernetes.io/component: hue
app.kubernetes.io/version: {{ splitList ":" ( include "hue.image" . ) | last }}
app.kubernetes.io/technology: python
{{- end }}


{{/*
Hue deployment and service only labels for Qubership release
*/}}
{{- define "hue.deploymentAndServiceOnlyLabels" -}}
name:  {{ include "hue.name" . }}
app.kubernetes.io/name:  {{ include "hue.name" . }}
{{- end }}

{{/*
Trino selector labels
*/}}
{{- define "trino.selectorLabels" -}}
app.kubernetes.io/name: trino-hue
app.kubernetes.io/instance: hue-{{ .Release.Namespace | nospace | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Trino deployment only labels for Qubership release
*/}}
{{- define "trino.deploymentOnlyLabels" -}}
app.kubernetes.io/instance: hue-{{ .Release.Namespace | nospace | trunc 63 | trimSuffix "-" }}
app.kubernetes.io/component: trino
app.kubernetes.io/version: {{ splitList ":" ( include "hue.image" . ) | last }}
app.kubernetes.io/technology: java
{{- end }}


{{/*
Trino deployment and service only labels for Qubership release
*/}}
{{- define "trino.deploymentAndServiceOnlyLabels" -}}
name:  trino-hue
app.kubernetes.io/name: trino-hue
{{- end }}

{{/*
All object labels for Qubership release
*/}}
{{- define "allObjectsLabels" -}}
app.kubernetes.io/part-of: hue
{{- end }}

{{/*
Processed by grafana operator label for Qubership release
*/}}
{{- define "grafanaOperatorLabel" -}}
app.kubernetes.io/processed-by-operator: grafana-operator
{{- end }}

{{/*
Processed by prometheus operator label for Qubership release
*/}}
{{- define "prometheusOperatorLabel" -}}
app.kubernetes.io/processed-by-operator: prometheus-operator
{{- end }}

{{/*
Processed by cert-manager label for Qubership release
*/}}
{{- define "certManagerLabel" -}}
app.kubernetes.io/processed-by-operator: cert-manager
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "hue.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "hue.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Postgres Host
*/}}
{{- define "postgres.host" -}}
{{- .Values.hue.database.host -}}
{{- end -}}

{{/*
Postgres Port
*/}}
{{- define "postgres.port" -}}
{{- .Values.hue.database.port -}}
{{- end -}}

{{/*
Postgres Admin User
*/}}
{{- define "postgres.adminUser" -}}
{{- .Values.hue.database.adminUser -}}
{{- end -}}

{{/*
Postgres Admin Password
*/}}
{{- define "postgres.adminPassword" -}}
{{- .Values.hue.database.adminPassword -}}
{{- end -}}

{{/*
Hue PG User
*/}}
{{- define "postgres.hue.user" -}}
{{- .Values.hue.database.user -}}
{{- end -}}

{{/*
Hue PG User Password
*/}}
{{- define "postgres.hue.password" -}}
{{- .Values.hue.database.password -}}
{{- end -}}

