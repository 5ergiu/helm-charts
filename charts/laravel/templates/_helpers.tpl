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
Horizon component labels
*/}}
{{- define "laravel.horizon.labels" -}}
{{ include "laravel.labels" . }}
app.kubernetes.io/component: horizon
{{- end }}

{{/*
Horizon selector labels
*/}}
{{- define "laravel.horizon.selectorLabels" -}}
{{ include "laravel.selectorLabels" . }}
app.kubernetes.io/component: horizon
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
Generate deployment spec for Laravel components
Usage: include "laravel.deployment" (dict "root" $ "component" "web" "config" .Values.web)
*/}}
{{- define "laravel.deployment" -}}
{{- $root := .root -}}
{{- $component := .component -}}
{{- $config := .config -}}
{{- $componentName := printf "%s-%s" (include "laravel.fullname" $root) $component -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ $componentName }}
  labels:
    {{- include "laravel.labels" $root | nindent 4 }}
    app.kubernetes.io/component: {{ $component }}
spec:
  {{- if not $config.autoscaling.enabled }}
  replicas: {{ $config.replicaCount }}
  {{- end }}
  strategy:
    {{- toYaml $config.strategy | nindent 4 }}
  selector:
    matchLabels:
      {{- include "laravel.selectorLabels" $root | nindent 6 }}
      app.kubernetes.io/component: {{ $component }}
  template:
    metadata:
      annotations:
        checksum/config: {{ include "laravel.envConfigMap" $root | sha256sum }}
        checksum/secret: {{ include "laravel.envSecret" $root | sha256sum }}
        {{- with $config.podAnnotations }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
      labels:
        {{- include "laravel.selectorLabels" $root | nindent 8 }}
        app.kubernetes.io/component: {{ $component }}
        {{- with $config.podLabels }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
    spec:
      {{- with $root.Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      serviceAccountName: {{ include "laravel.serviceAccountName" $root }}
      securityContext:
        {{- toYaml $config.podSecurityContext | nindent 8 }}
      {{- with $root.Values.initContainers }}
      initContainers:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      containers:
        - name: {{ $component }}
          securityContext:
            {{- toYaml $config.securityContext | nindent 12 }}
          {{- if $config.image }}
          image: "{{ $config.image.repository }}:{{ $config.image.tag }}"
          imagePullPolicy: {{ $config.image.pullPolicy | default "IfNotPresent" }}
          {{- else }}
          image: {{ include "laravel.image" $root }}
          imagePullPolicy: {{ include "laravel.imagePullPolicy" $root }}
          {{- end }}
          {{- with $config.command }}
          command:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $config.args }}
          args:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $config.ports }}
          ports:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          envFrom:
            {{- include "laravel.envConfigMap" $root | nindent 12 }}
            {{- include "laravel.envSecret" $root | nindent 12 }}
          {{- with $root.Values.extraEnvFrom }}
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $root.Values.extraEnv }}
          env:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- if $config.livenessProbe }}
          {{- if $config.livenessProbe.enabled }}
          livenessProbe:
            {{- omit $config.livenessProbe "enabled" | toYaml | nindent 12 }}
          {{- end }}
          {{- end }}
          {{- if $config.readinessProbe }}
          {{- if $config.readinessProbe.enabled }}
          readinessProbe:
            {{- omit $config.readinessProbe "enabled" | toYaml | nindent 12 }}
          {{- end }}
          {{- end }}
          {{- if $config.startupProbe }}
          {{- if $config.startupProbe.enabled }}
          startupProbe:
            {{- omit $config.startupProbe "enabled" | toYaml | nindent 12 }}
          {{- end }}
          {{- end }}
          resources:
            {{- toYaml $config.resources | nindent 12 }}
          {{- if or $root.Values.tmpfsVolumes.enabled $root.Values.persistence.enabled $root.Values.extraVolumeMounts $config.extraVolumeMounts }}
          volumeMounts:
            {{- with $config.extraVolumeMounts }}
            {{- toYaml . | nindent 12 }}
            {{- end }}
            {{- if or $root.Values.tmpfsVolumes.enabled $root.Values.persistence.enabled $root.Values.extraVolumeMounts }}
            {{- include "laravel.volumeMounts" $root | nindent 12 }}
            {{- end }}
          {{- end }}
        {{- with $config.sidecars }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
        {{- if and (eq $component "web") $root.Values.web.reverseProxy.enabled }}
        - name: {{ $root.Values.web.reverseProxy.container.name }}
          image: "{{ $root.Values.web.reverseProxy.container.image.repository }}:{{ $root.Values.web.reverseProxy.container.image.tag }}"
          imagePullPolicy: {{ $root.Values.web.reverseProxy.container.image.pullPolicy }}
          {{- with $root.Values.web.reverseProxy.container.command }}
          command:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $root.Values.web.reverseProxy.container.ports }}
          ports:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          securityContext:
            {{- toYaml $root.Values.web.reverseProxy.container.securityContext | nindent 12 }}
          resources:
            {{- toYaml $root.Values.web.reverseProxy.container.resources | nindent 12 }}
          {{- with $root.Values.web.reverseProxy.container.volumeMounts }}
          volumeMounts:
            {{- toYaml . | nindent 12 }}
          {{- end }}
        {{- end }}
      {{- if or $root.Values.tmpfsVolumes.enabled $root.Values.persistence.enabled $root.Values.extraVolumes $config.extraVolumes (and (eq $component "web") $root.Values.web.reverseProxy.enabled) }}
      volumes:
        {{- with $config.extraVolumes }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
        {{- if or $root.Values.tmpfsVolumes.enabled $root.Values.persistence.enabled $root.Values.extraVolumes }}
        {{- include "laravel.volumes" $root | nindent 8 }}
        {{- end }}
        {{- if and (eq $component "web") $root.Values.web.reverseProxy.enabled }}
        {{- with $root.Values.web.reverseProxy.volumes }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
        {{- end }}
      {{- end }}
      {{- with $config.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $config.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $config.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
{{- end -}}

