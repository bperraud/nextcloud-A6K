#!/bin/bash

set -e

datadir=/srv/data
wwwdir=/var/www/html

cd $wwwdir

if ! wget --timeout=5 --quiet -O/tmp/status.json --no-check-certificate https://nextcloud:8443/status.php; then
  echo "error: can't get nextcloud status.php"
  exit 1
fi

if [ "`jq .needsDbUpgrade < /tmp/status.json`" != "false" ]; then
  # should not happen
  echo "error: nextcloud needs DB upgrade"
  exit 1
fi

{{- range $app, $cfg := .Values.nextcloud.apps }}
# Configuration for app {{ $app }}
if [ ! -e "$wwwdir/apps/{{ $app }}" ] && [ ! -e "$wwwdir/custom_apps/{{ $app }}" ]; then
  echo "error: app {{ $app }} is mentionned in Helm values but not present in Docker image"
  exit 1
fi
{{- if list nil true | has $cfg.enabled}}
./occ app:enable {{ $app }}

{{- range $cfg.occ_config }}
./occ {{ tpl . $ }}
{{- end }}

{{- range $key, $val := $cfg.json_config }}
./occ config:app:set --value={{ if or (kindIs "slice" $val) (kindIs "map" $val) }}{{ tpl ($val | mustToJson | quote) $ }}{{ else }}{{ tpl ($val | quote) $ }}{{ end }} {{ $app }} {{ $key }}
{{- end }}

{{- else }}
./occ app:disable {{ $app }}
{{- end }}
{{- end }}

./occ db:add-missing-indices

