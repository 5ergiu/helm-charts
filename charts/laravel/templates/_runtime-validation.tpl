{{/*
Validate runtime configuration (http.entrypoint, php.engine)
Returns dict with config and enabled components
Note: We don't validate combinations - users are responsible for their choices.
*/}}
{{- define "laravel.validateRuntime" -}}
{{- $http := .http | default dict }}
{{- $php := .php | default dict }}

{{- $entrypoint := $http.entrypoint | default "" }}
{{- $engine := $php.engine | default "" }}

{{- $result := dict "valid" true "errors" (list) }}

{{/* Set component enablement based on config */}}
{{- $components := dict }}
{{- $_ := set $components "httpSidecar" (or (eq $entrypoint "nginx") (eq $entrypoint "apache") (eq $entrypoint "caddy")) }}
{{- $_ := set $components "phpFpm" (eq $engine "fpm") }}
{{- $_ := set $components "phpIni" true }}
{{- $_ := set $components "frankenphp" (eq $engine "frankenphp") }}
{{- $_ := set $components "octane" (or (eq $engine "roadrunner") (eq $engine "swoole")) }}

{{- $_ := set $result "components" $components }}
{{- $_ := set $result "http" $http }}
{{- $_ := set $result "php" $php }}

{{- toYaml $result }}
{{- end }}
