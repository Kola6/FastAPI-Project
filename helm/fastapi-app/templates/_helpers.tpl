{{- define "fastapi-app.name" -}}
fastapi
{{- end }}

{{- define "fastapi-app.fullname" -}}
{{ include "fastapi-app.name" . }}-deployment
{{- end }}