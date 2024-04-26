{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "fcrepo.name" }}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "fcrepo.fullname" }}
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
{{- define "fcrepo.chart" }}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "fcrepo.labels" }}
helm.sh/chart: {{ include "fcrepo.chart" . }}
{{ include "fcrepo.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "fcrepo.selectorLabels" }}
app.kubernetes.io/name: {{ include "fcrepo.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "fcrepo.serviceAccountName" }}
{{- if .Values.serviceAccount.create }}
{{- default (include "fcrepo.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "fcrepo.postgresql.fullname" }}
{{- $name := default "postgresql" .Values.postgresql.nameOverride }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Return PostgreSQL host
*/}}
{{- define "fcrepo.postgresql.host" }}
{{- if and (not .Values.postgresql.enabled) .Values.externalPostgresql.host }}
    {{- .Values.externalPostgresql.host }}
{{- else if and (not .Values.postgresql.enabled) .Values.global.postgresql.postgresqlHost }}
    {{- .Values.global.postgresql.postgresqlHost }}
{{- else }}
    {{- include "fcrepo.postgresql.fullname" . }}
{{- end }}
{{- end }}

{{/*
Return PostgreSQL username
*/}}
{{- define "fcrepo.postgresql.username" }}
{{- if and (not .Values.postgresql.enabled) .Values.externalPostgresql.username }}
    {{- .Values.externalPostgresql.username }}
{{- else if and (not .Values.postgresql.enabled) .Values.global.postgresql.auth.username }}
    {{- .Values.global.postgresql.auth.username }}
{{- else }}
    {{- .Values.postgresql.auth.username }}
{{- end }}
{{- end }}

{{/*
Return PostgreSQL password
*/}}
{{- define "fcrepo.postgresql.password" }}
{{- if and (not .Values.postgresql.enabled) .Values.externalPostgresql.password }}
    {{- .Values.externalPostgresql.password }}
{{- else if and (not .Values.postgresql.enabled) .Values.global.postgresql.auth.password }}
    {{- .Values.global.postgresql.auth.password }}
{{- else }}
    {{- .Values.postgresql.auth.password }}
{{- end }}
{{- end }}

{{/*
Return any addtional options to the JVM
*/}}
{{- define "fcrepo.additional_java_options" }}
{{- default " " .Values.additional_java_options }}
{{- end }}
