{{/*
Expand the name of the chart.
*/}}
{{- define "nextjs.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "nextjs.fullname" -}}
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
{{- define "nextjs.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "nextjs.labels" -}}
helm.sh/chart: {{ include "nextjs.chart" . }}
{{ include "nextjs.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "nextjs.selectorLabels" -}}
app.kubernetes.io/name: {{ include "nextjs.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
App component labels
*/}}
{{- define "nextjs.app.labels" -}}
{{ include "nextjs.labels" . }}
app.kubernetes.io/component: app
{{- end }}

{{/*
App selector labels
*/}}
{{- define "nextjs.app.selectorLabels" -}}
{{ include "nextjs.selectorLabels" . }}
app.kubernetes.io/component: app
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "nextjs.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "nextjs.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the image pull policy
*/}}
{{- define "nextjs.imagePullPolicy" -}}
{{- .Values.image.pullPolicy | default "IfNotPresent" }}
{{- end }}

{{/*
Create the full image name
*/}}
{{- define "nextjs.image" -}}
{{- $tag := .Values.image.tag | default .Chart.AppVersion }}
{{- printf "%s:%s" .Values.image.repository $tag }}
{{- end }}

{{/*
Environment variables from ConfigMap
*/}}
{{- define "nextjs.envConfigMap" -}}
- configMapRef:
    name: {{ include "nextjs.fullname" . }}-env
{{- end }}

{{/*
Environment variables from Secret
*/}}
{{- define "nextjs.envSecret" -}}
- secretRef:
    name: {{ include "nextjs.fullname" . }}-secret
{{- end }}

{{/*
Common volume mounts
*/}}
{{- define "nextjs.volumeMounts" -}}
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
{{- define "nextjs.volumes" -}}
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
    claimName: {{ include "nextjs.fullname" . }}-storage
{{- end }}
{{- with .Values.extraVolumes }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
Init containers for setup tasks
*/}}
{{- define "nextjs.initContainers" -}}
{{- if .Values.initContainers.verifyBuild.enabled }}
- name: verify-build
  image: {{ include "nextjs.image" . }}
  imagePullPolicy: {{ include "nextjs.imagePullPolicy" . }}
  command: {{ toYaml .Values.initContainers.verifyBuild.command | nindent 4 }}
  securityContext:
    {{- toYaml .Values.app.securityContext | nindent 4 }}
{{- end }}
{{- with .Values.extraInitContainers }}
{{- toYaml . }}
{{- end }}
{{- end }}
