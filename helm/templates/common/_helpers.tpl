{{/* vim: set filetype=mustache: */}}
{{/*
定义图表的名称。
*/}}
{{- define "professional.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
定义一个默认的完全限定应用程序名称。
*/}}
{{- define "professional.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
定义图表标签所使用的图表名称和版本。唯一标识。
*/}}
{{- define "professional.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
定义要使用的服务帐户的名称
*/}}
{{- define "professional.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "professional.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}


{{/*
定义项目公共名字空间
*/}}
{{- define "professional.namespace" -}}
    {{ .Values.namespace | default .Release.Namespace }}
{{- end -}}

{{/*
定义公共标签, 默认标签只显示名字和版本
*/}}
{{- define "professional.labels" -}}
app.kubernetes.io/name: {{ include "professional.name" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- end -}}

