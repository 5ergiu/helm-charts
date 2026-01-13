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
Deployment component labels - generic version
Usage: include "laravel.deployment.labels" (dict "root" $ "component" "web")
*/}}
{{- define "laravel.deployment.labels" -}}
{{ include "laravel.labels" .root }}
app.kubernetes.io/component: {{ .component }}
{{- end }}

{{/*
Deployment selector labels - generic version
Usage: include "laravel.deployment.selectorLabels" (dict "root" $ "component" "web")
*/}}
{{- define "laravel.deployment.selectorLabels" -}}
{{ include "laravel.selectorLabels" .root }}
app.kubernetes.io/component: {{ .component }}
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
Get image for a deployment
Uses deployment-specific image if provided, otherwise falls back to appropriate default
For web deployment: defaults to images.web
For worker-* deployments: defaults to images.worker
*/}}
{{- define "laravel.deployment.image" -}}
{{- $component := .component -}}
{{- $config := .config -}}
{{- $root := .root -}}
{{- if $config.image -}}
  {{- printf "%s:%s" $config.image.repository $config.image.tag -}}
{{- else if hasPrefix "worker-" $component -}}
  {{- printf "%s:%s" $root.Values.images.worker.repository $root.Values.images.worker.tag -}}
{{- else if eq $component "web" -}}
  {{- printf "%s:%s" $root.Values.images.web.repository $root.Values.images.web.tag -}}
{{- else -}}
  {{- fail (printf "No image configuration found for deployment '%s'. Specify deployment.image or ensure component name starts with 'web' or 'worker-'" $component) -}}
{{- end -}}
{{- end -}}

{{/*
Get imagePullPolicy for a deployment
Uses deployment-specific pullPolicy if provided, otherwise falls back to default
*/}}
{{- define "laravel.deployment.imagePullPolicy" -}}
{{- $component := .component -}}
{{- $config := .config -}}
{{- $root := .root -}}
{{- if $config.image -}}
  {{- $config.image.pullPolicy | default "IfNotPresent" -}}
{{- else if hasPrefix "worker-" $component -}}
  {{- $root.Values.images.worker.pullPolicy | default "IfNotPresent" -}}
{{- else if eq $component "web" -}}
  {{- $root.Values.images.web.pullPolicy | default "IfNotPresent" -}}
{{- else -}}
  {{- "IfNotPresent" -}}
{{- end -}}
{{- end -}}

{{/*
Create migration job image
Defaults to images.worker if not specified
*/}}
{{- define "laravel.migration.image" -}}
{{- if .Values.migration.image -}}
  {{- printf "%s:%s" .Values.migration.image.repository .Values.migration.image.tag -}}
{{- else -}}
  {{- printf "%s:%s" .Values.images.worker.repository .Values.images.worker.tag -}}
{{- end -}}
{{- end -}}

{{/*
Create migration job imagePullPolicy
*/}}
{{- define "laravel.migration.imagePullPolicy" -}}
{{- if .Values.migration.image -}}
  {{- .Values.migration.image.pullPolicy | default "IfNotPresent" -}}
{{- else -}}
  {{- .Values.images.worker.pullPolicy | default "IfNotPresent" -}}
{{- end -}}
{{- end -}}

{{/*
Create scheduler image
Defaults to images.worker if not specified
*/}}
{{- define "laravel.scheduler.image" -}}
{{- if .Values.scheduler.image -}}
  {{- printf "%s:%s" .Values.scheduler.image.repository .Values.scheduler.image.tag -}}
{{- else -}}
  {{- printf "%s:%s" .Values.images.worker.repository .Values.images.worker.tag -}}
{{- end -}}
{{- end -}}

{{/*
Create scheduler imagePullPolicy
*/}}
{{- define "laravel.scheduler.imagePullPolicy" -}}
{{- if .Values.scheduler.image -}}
  {{- .Values.scheduler.image.pullPolicy | default "IfNotPresent" -}}
{{- else -}}
  {{- .Values.images.worker.pullPolicy | default "IfNotPresent" -}}
{{- end -}}
{{- end -}}

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
{{- end }}

{{/*
Common volumes
*/}}
{{- define "laravel.volumes" -}}
{{- if .Values.tmpfsVolumes.enabled }}
{{- range .Values.tmpfsVolumes.mounts }}
- name: {{ .name }}
  emptyDir: {}
{{- end }}
{{- end }}
{{- if .Values.persistence.enabled }}
- name: storage
  persistentVolumeClaim:
    claimName: {{ include "laravel.fullname" . }}-storage
{{- end }}
{{- end }}

{{/*
Get runtime configuration
Usage: $runtime := include "laravel.getRuntimeConfig" (dict "root" $ "config" .Values.web) | fromYaml
Returns runtime configuration dict with http/php settings and component flags
*/}}
{{- define "laravel.getRuntimeConfig" -}}
{{- $config := .config -}}
{{- $runtime := dict }}
{{- $_ := set $runtime "http" ($config.http | default dict) }}
{{- $_ := set $runtime "php" ($config.php | default dict) }}
{{- include "laravel.validateRuntime" $runtime }}
{{- end }}

{{/*
PHP configuration volume mounts
Returns volume mounts for PHP configuration files based on runtime
Usage: include "laravel.phpConfigVolumeMounts" (dict "root" $ "runtime" $runtime)
*/}}
{{- define "laravel.phpConfigVolumeMounts" -}}
{{- $root := .root -}}
{{- $runtime := .runtime -}}
{{- $components := $runtime.components | default dict }}
{{- if and $root.Values.php $root.Values.php.ini $root.Values.php.ini.enabled }}
- name: php-ini
  mountPath: {{ $root.Values.php.ini.mountPath | default "/usr/local/etc/php/conf.d/zz-custom.ini" }}
  subPath: zz-custom.ini
  readOnly: true
{{- end }}
{{- if and $components.phpFpm $root.Values.php.fpm $root.Values.php.fpm.enabled }}
- name: php-fpm
  mountPath: {{ $root.Values.php.fpm.mountPath | default "/usr/local/etc/php-fpm.d/zz-custom.conf" }}
  subPath: zz-custom.conf
  readOnly: true
{{- end }}
{{- if and $components.frankenphp $root.Values.php.frankenphp $root.Values.php.frankenphp.enabled }}
- name: frankenphp-config
  mountPath: {{ $root.Values.php.frankenphp.mountPath | default "/etc/caddy/Caddyfile" }}
  subPath: Caddyfile
  readOnly: true
{{- end }}
{{- if and $components.octane $root.Values.php.octane $root.Values.php.octane.enabled }}
- name: octane-config
  mountPath: {{ $root.Values.php.octane.mountPath | default "/var/www/html/.octane.php" }}
  subPath: .octane.php
  readOnly: true
{{- end }}
{{- end }}

{{/*
PHP configuration volumes
Returns volumes for PHP configuration files based on runtime
Usage: include "laravel.phpConfigVolumes" (dict "root" $ "runtime" $runtime)
*/}}
{{- define "laravel.phpConfigVolumes" -}}
{{- $root := .root -}}
{{- $runtime := .runtime -}}
{{- $components := $runtime.components | default dict }}
{{- if and $root.Values.php $root.Values.php.ini $root.Values.php.ini.enabled }}
- name: php-ini
  configMap:
    name: {{ include "laravel.fullname" $root }}-php-ini
{{- end }}
{{- if and $components.phpFpm $root.Values.php.fpm $root.Values.php.fpm.enabled }}
- name: php-fpm
  configMap:
    name: {{ include "laravel.fullname" $root }}-php-fpm
{{- end }}
{{- if and $components.frankenphp $root.Values.php.frankenphp $root.Values.php.frankenphp.enabled }}
- name: frankenphp-config
  configMap:
    name: {{ include "laravel.fullname" $root }}-frankenphp
{{- end }}
{{- if and $components.octane $root.Values.php.octane $root.Values.php.octane.enabled }}
- name: octane-config
  configMap:
    name: {{ include "laravel.fullname" $root }}-octane
{{- end }}
{{- end }}

{{/*
HTTP entrypoint sidecar container
Returns sidecar container definition for HTTP entrypoints (nginx/apache/caddy)
Usage: include "laravel.httpSidecar" (dict "root" $ "runtime" $runtime)
*/}}
{{- define "laravel.httpSidecar" -}}
{{- $root := .root -}}
{{- $runtime := .runtime -}}
{{- $http := $runtime.http | default dict }}
{{- $entrypoint := $http.entrypoint | default "" }}
{{- if eq $entrypoint "nginx" }}
{{- $nginxConfig := $http.nginx | default dict }}
- name: nginx
  image: "{{ $nginxConfig.image.repository | default "nginx" }}:{{ $nginxConfig.image.tag | default "1.25-alpine" }}"
  imagePullPolicy: {{ $nginxConfig.image.pullPolicy | default "IfNotPresent" }}
  command: ["nginx", "-g", "daemon off;"]
  ports:
    - name: http
      containerPort: {{ $nginxConfig.port | default 8080 }}
      protocol: TCP
  securityContext:
    allowPrivilegeEscalation: false
    capabilities:
      drop:
      - ALL
    readOnlyRootFilesystem: true
    runAsNonRoot: true
    runAsUser: 101
  resources:
    {{- if $nginxConfig.resources }}
    {{- toYaml $nginxConfig.resources | nindent 4 }}
    {{- else }}
    limits:
      cpu: 500m
      memory: 128Mi
    requests:
      cpu: 50m
      memory: 64Mi
    {{- end }}
  volumeMounts:
    - name: http-config
      mountPath: /etc/nginx/nginx.conf
      subPath: nginx.conf
      readOnly: true
    - name: http-logs
      mountPath: /var/log/nginx
    - name: http-cache
      mountPath: /var/cache/nginx
    - name: http-tmp
      mountPath: /tmp
{{- else if eq $entrypoint "apache" }}
{{- $apacheConfig := $http.apache | default dict }}
- name: apache
  image: "{{ $apacheConfig.image.repository | default "httpd" }}:{{ $apacheConfig.image.tag | default "2.4-alpine" }}"
  imagePullPolicy: {{ $apacheConfig.image.pullPolicy | default "IfNotPresent" }}
  command: ["httpd-foreground"]
  ports:
    - name: http
      containerPort: {{ $apacheConfig.port | default 8080 }}
      protocol: TCP
  securityContext:
    allowPrivilegeEscalation: false
    capabilities:
      drop:
      - ALL
    readOnlyRootFilesystem: true
  resources:
    {{- if $apacheConfig.resources }}
    {{- toYaml $apacheConfig.resources | nindent 4 }}
    {{- else }}
    limits:
      cpu: 500m
      memory: 128Mi
    requests:
      cpu: 50m
      memory: 64Mi
    {{- end }}
  volumeMounts:
    - name: http-config
      mountPath: /usr/local/apache2/conf/httpd.conf
      subPath: httpd.conf
      readOnly: true
    - name: http-tmp
      mountPath: /tmp
    - name: http-logs
      mountPath: /usr/local/apache2/logs
{{- else if eq $entrypoint "caddy" }}
{{- $caddyConfig := $http.caddy | default dict }}
- name: caddy
  image: "{{ $caddyConfig.image.repository | default "caddy" }}:{{ $caddyConfig.image.tag | default "2-alpine" }}"
  imagePullPolicy: {{ $caddyConfig.image.pullPolicy | default "IfNotPresent" }}
  command: ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
  ports:
    - name: http
      containerPort: {{ $caddyConfig.port | default 8080 }}
      protocol: TCP
  securityContext:
    allowPrivilegeEscalation: false
    capabilities:
      drop:
      - ALL
    readOnlyRootFilesystem: true
  resources:
    {{- if $caddyConfig.resources }}
    {{- toYaml $caddyConfig.resources | nindent 4 }}
    {{- else }}
    limits:
      cpu: 500m
      memory: 128Mi
    requests:
      cpu: 50m
      memory: 64Mi
    {{- end }}
  volumeMounts:
    - name: http-config
      mountPath: /etc/caddy/Caddyfile
      subPath: Caddyfile
      readOnly: true
    - name: http-tmp
      mountPath: /tmp
    - name: http-data
      mountPath: /data
    - name: http-config-data
      mountPath: /config
{{- end }}
{{- end }}

{{/*
HTTP entrypoint volumes
Returns volumes for HTTP entrypoint sidecars
Usage: include "laravel.httpVolumes" (dict "root" $ "runtime" $runtime)
*/}}
{{- define "laravel.httpVolumes" -}}
{{- $root := .root -}}
{{- $runtime := .runtime -}}
{{- $http := $runtime.http | default dict }}
{{- $entrypoint := $http.entrypoint | default "" }}
{{- if or (eq $entrypoint "nginx") (eq $entrypoint "apache") (eq $entrypoint "caddy") }}
- name: http-config
  configMap:
    name: {{ include "laravel.fullname" $root }}-{{ $entrypoint }}
- name: http-tmp
  emptyDir: {}
- name: http-logs
  emptyDir: {}
{{- if eq $entrypoint "nginx" }}
- name: http-cache
  emptyDir: {}
{{- else if eq $entrypoint "caddy" }}
- name: http-data
  emptyDir: {}
- name: http-config-data
  emptyDir: {}
{{- end }}
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
      {{- with $config.initContainers }}
      initContainers:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      containers:
        - name: {{ $component }}
          securityContext:
            {{- toYaml $config.securityContext | nindent 12 }}
          image: {{ include "laravel.deployment.image" (dict "root" $root "component" $component "config" $config) }}
          imagePullPolicy: {{ include "laravel.deployment.imagePullPolicy" (dict "root" $root "component" $component "config" $config) }}
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
          {{- with $config.envFrom }}
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with $config.env }}
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
          {{- if or $root.Values.tmpfsVolumes.enabled $root.Values.persistence.enabled $config.volumeMounts }}
          volumeMounts:
            {{- with $config.volumeMounts }}
            {{- toYaml . | nindent 12 }}
            {{- end }}
            {{- if or $root.Values.tmpfsVolumes.enabled $root.Values.persistence.enabled }}
            {{- include "laravel.volumeMounts" $root | nindent 12 }}
            {{- end }}
          {{- end }}
        {{- with $config.sidecars }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
        {{- if and (eq $component "web") $root.Values.reverseProxy $root.Values.reverseProxy.enabled }}
        {{- $proxyType := $root.Values.reverseProxy.type | default "nginx" }}
        {{- $proxyConfig := index $root.Values.reverseProxy $proxyType }}
        {{- if eq $proxyType "nginx" }}
        - name: nginx
          image: "{{ $proxyConfig.image.repository | default "nginx" }}:{{ $proxyConfig.image.tag | default "1.29.4-alpine" }}"
          imagePullPolicy: {{ $proxyConfig.image.pullPolicy | default "IfNotPresent" }}
          command: ["nginx", "-g", "daemon off;"]
          ports:
            - name: http
              containerPort: {{ $proxyConfig.port | default 8080 }}
              protocol: TCP
          securityContext:
            allowPrivilegeEscalation: false
            capabilities:
              drop:
              - ALL
            readOnlyRootFilesystem: true
          resources:
            {{- if $proxyConfig.resources }}
            {{- toYaml $proxyConfig.resources | nindent 12 }}
            {{- else }}
            limits:
              cpu: 500m
              memory: 128Mi
            requests:
              cpu: 50m
              memory: 64Mi
            {{- end }}
          volumeMounts:
            - name: reverseproxy-config
              mountPath: /etc/nginx/nginx.conf
              subPath: nginx.conf
              readOnly: true
            - name: reverseproxy-logs
              mountPath: /var/log/nginx
            - name: reverseproxy-cache
              mountPath: /var/cache/nginx
            - name: reverseproxy-tmp
              mountPath: /tmp
        {{- else if eq $proxyType "apache" }}
        - name: apache
          image: "{{ $proxyConfig.image.repository | default "httpd" }}:{{ $proxyConfig.image.tag | default "2.4-alpine" }}"
          imagePullPolicy: {{ $proxyConfig.image.pullPolicy | default "IfNotPresent" }}
          command: ["httpd-foreground"]
          ports:
            - name: http
              containerPort: {{ $proxyConfig.port | default 8080 }}
              protocol: TCP
          securityContext:
            allowPrivilegeEscalation: false
            capabilities:
              drop:
              - ALL
            readOnlyRootFilesystem: true
          resources:
            {{- if $proxyConfig.resources }}
            {{- toYaml $proxyConfig.resources | nindent 12 }}
            {{- else }}
            limits:
              cpu: 500m
              memory: 128Mi
            requests:
              cpu: 50m
              memory: 64Mi
            {{- end }}
          volumeMounts:
            - name: reverseproxy-config
              mountPath: /usr/local/apache2/conf/httpd.conf
              subPath: httpd.conf
              readOnly: true
            - name: reverseproxy-tmp
              mountPath: /tmp
            - name: reverseproxy-logs
              mountPath: /usr/local/apache2/logs
        {{- else if eq $proxyType "caddy" }}
        - name: caddy
          image: "{{ $proxyConfig.image.repository | default "caddy" }}:{{ $proxyConfig.image.tag | default "2-alpine" }}"
          imagePullPolicy: {{ $proxyConfig.image.pullPolicy | default "IfNotPresent" }}
          command: ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
          ports:
            - name: http
              containerPort: {{ $proxyConfig.port | default 8080 }}
              protocol: TCP
          securityContext:
            allowPrivilegeEscalation: false
            capabilities:
              drop:
              - ALL
            readOnlyRootFilesystem: true
          resources:
            {{- if $proxyConfig.resources }}
            {{- toYaml $proxyConfig.resources | nindent 12 }}
            {{- else }}
            limits:
              cpu: 500m
              memory: 128Mi
            requests:
              cpu: 50m
              memory: 64Mi
            {{- end }}
          volumeMounts:
            - name: reverseproxy-config
              mountPath: /etc/caddy/Caddyfile
              subPath: Caddyfile
              readOnly: true
            - name: reverseproxy-tmp
              mountPath: /tmp
            - name: reverseproxy-data
              mountPath: /data
            - name: reverseproxy-config-caddy
              mountPath: /config
        {{- end }}
        {{- end }}
      {{- if or $root.Values.tmpfsVolumes.enabled $root.Values.persistence.enabled $config.volumes (and (eq $component "web") $root.Values.reverseProxy $root.Values.reverseProxy.enabled) }}
      volumes:
        {{- with $config.volumes }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
        {{- if or $root.Values.tmpfsVolumes.enabled $root.Values.persistence.enabled }}
        {{- include "laravel.volumes" $root | nindent 8 }}
        {{- end }}
        {{- if and (eq $component "web") $root.Values.reverseProxy $root.Values.reverseProxy.enabled }}
        {{- $proxyType := $root.Values.reverseProxy.type | default "nginx" }}
        - name: reverseproxy-config
          configMap:
            name: {{ include "laravel.fullname" $root }}-{{ $component }}-{{ $proxyType }}
        - name: reverseproxy-tmp
          emptyDir: {}
        - name: reverseproxy-logs
          emptyDir: {}
        {{- if eq $proxyType "nginx" }}
        - name: reverseproxy-cache
          emptyDir: {}
        {{- else if eq $proxyType "caddy" }}
        - name: reverseproxy-data
          emptyDir: {}
        - name: reverseproxy-config-caddy
          emptyDir: {}
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

