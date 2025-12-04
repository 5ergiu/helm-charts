{{/*
Expand the name of the chart.
*/}}
{{- define "laravel.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "laravel.fullname" -}}
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
{{- define "laravel.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "laravel.labels" -}}
helm.sh/chart: {{ include "laravel.chart" . }}
{{ include "laravel.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "laravel.selectorLabels" -}}
app.kubernetes.io/name: {{ include "laravel.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Web component labels
*/}}
{{- define "laravel.web.labels" -}}
{{ include "laravel.labels" . }}
app.kubernetes.io/component: web
{{- end }}

{{/*
Web selector labels
*/}}
{{- define "laravel.web.selectorLabels" -}}
{{ include "laravel.selectorLabels" . }}
app.kubernetes.io/component: web
{{- end }}

{{/*
Worker component labels
*/}}
{{- define "laravel.worker.labels" -}}
{{ include "laravel.labels" . }}
app.kubernetes.io/component: worker
{{- end }}

{{/*
Worker selector labels
*/}}
{{- define "laravel.worker.selectorLabels" -}}
{{ include "laravel.selectorLabels" . }}
app.kubernetes.io/component: worker
{{- end }}

{{/*
Scheduler component labels
*/}}
{{- define "laravel.scheduler.labels" -}}
{{ include "laravel.labels" . }}
app.kubernetes.io/component: scheduler
{{- end }}

{{/*
Scheduler selector labels
*/}}
{{- define "laravel.scheduler.selectorLabels" -}}
{{ include "laravel.selectorLabels" . }}
app.kubernetes.io/component: scheduler
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "laravel.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "laravel.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the image pull policy
*/}}
{{- define "laravel.imagePullPolicy" -}}
{{- .Values.image.pullPolicy | default "IfNotPresent" }}
{{- end }}

{{/*
Create the full image name
*/}}
{{- define "laravel.image" -}}
{{- $tag := .Values.image.tag | default .Chart.AppVersion }}
{{- printf "%s:%s" .Values.image.repository $tag }}
{{- end }}

{{/*
Environment variables from ConfigMap
*/}}
{{- define "laravel.envConfigMap" -}}
- configMapRef:
    name: {{ include "laravel.fullname" . }}-env
{{- end }}

{{/*
Environment variables from Secret
*/}}
{{- define "laravel.envSecret" -}}
- secretRef:
    name: {{ include "laravel.fullname" . }}-secret
{{- end }}

{{/*
Common volume mounts
*/}}
{{- define "laravel.volumeMounts" -}}
{{- if .Values.tmpfsVolumes.enabled }}
{{- range .Values.tmpfsVolumes.mounts }}
- name: {{ .name }}
  mountPath: {{ .mountPath }}
{{- end }}
{{- end }}
{{- if .Values.persistence.enabled }}
{{- range .Values.persistence.mounts }}
- name: {{ .name }}
  mountPath: {{ .mountPath }}
  {{- if .subPath }}
  subPath: {{ .subPath }}
  {{- end }}
{{- end }}
{{- end }}
{{- with .Values.extraVolumeMounts }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
Common volumes
*/}}
{{- define "laravel.volumes" -}}
{{- if .Values.tmpfsVolumes.enabled }}
{{- range .Values.tmpfsVolumes.mounts }}
- name: {{ .name }}
  emptyDir:
    medium: Memory
{{- end }}
{{- end }}
{{- if .Values.persistence.enabled }}
- name: storage
  persistentVolumeClaim:
    claimName: {{ include "laravel.fullname" . }}-storage
{{- end }}
{{- with .Values.extraVolumes }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
Init containers for cache warming
*/}}
{{- define "laravel.initContainers" -}}
{{- if .Values.initContainers.cacheConfig.enabled }}
- name: cache-config
  image: {{ include "laravel.image" . }}
  imagePullPolicy: {{ include "laravel.imagePullPolicy" . }}
  command: {{ toYaml .Values.initContainers.cacheConfig.command | nindent 4 }}
  envFrom:
    {{- include "laravel.envConfigMap" . | nindent 4 }}
    {{- include "laravel.envSecret" . | nindent 4 }}
  {{- with .Values.extraEnvFrom }}
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.extraEnv }}
  env:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  securityContext:
    {{- toYaml .Values.web.securityContext | nindent 4 }}
{{- end }}
{{- if .Values.initContainers.cacheRoute.enabled }}
- name: cache-route
  image: {{ include "laravel.image" . }}
  imagePullPolicy: {{ include "laravel.imagePullPolicy" . }}
  command: {{ toYaml .Values.initContainers.cacheRoute.command | nindent 4 }}
  envFrom:
    {{- include "laravel.envConfigMap" . | nindent 4 }}
    {{- include "laravel.envSecret" . | nindent 4 }}
  {{- with .Values.extraEnvFrom }}
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.extraEnv }}
  env:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  securityContext:
    {{- toYaml .Values.web.securityContext | nindent 4 }}
{{- end }}
{{- if .Values.initContainers.cacheView.enabled }}
- name: cache-view
  image: {{ include "laravel.image" . }}
  imagePullPolicy: {{ include "laravel.imagePullPolicy" . }}
  command: {{ toYaml .Values.initContainers.cacheView.command | nindent 4 }}
  envFrom:
    {{- include "laravel.envConfigMap" . | nindent 4 }}
    {{- include "laravel.envSecret" . | nindent 4 }}
  {{- with .Values.extraEnvFrom }}
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.extraEnv }}
  env:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  securityContext:
    {{- toYaml .Values.web.securityContext | nindent 4 }}
{{- end }}
{{- if .Values.initContainers.storageLink.enabled }}
- name: storage-link
  image: {{ include "laravel.image" . }}
  imagePullPolicy: {{ include "laravel.imagePullPolicy" . }}
  command: {{ toYaml .Values.initContainers.storageLink.command | nindent 4 }}
  envFrom:
    {{- include "laravel.envConfigMap" . | nindent 4 }}
    {{- include "laravel.envSecret" . | nindent 4 }}
  {{- with .Values.extraEnvFrom }}
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.extraEnv }}
  env:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  securityContext:
    {{- toYaml .Values.web.securityContext | nindent 4 }}
{{- end }}
{{- with .Values.extraInitContainers }}
{{- toYaml . }}
{{- end }}
{{- end }}
