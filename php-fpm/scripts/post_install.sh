#!/bin/bash
set -e

datadir=/srv/data
wwwdir=/var/www/html
config_path=/config/app-config.yaml

cd $wwwdir

# Check if Nextcloud is reachable
if ! wget --timeout=5 --quiet -O/tmp/status.json --no-check-certificate https://apache:8443/status.php; then
  echo "Cannot reach nextcloud status.php"
  exit 1
fi

if [ "$(jq .needsDbUpgrade < /tmp/status.json)" != "false" ]; then
  echo "Nextcloud needs DB upgrade"
  exit 1
fi

occ_path="./occ"

# Loop through apps
apps=$(yq -r 'keys[]' "$config_path")

for app in $apps; do
  enabled=$(yq -r ".\"$app\".enabled // yes" "$config_path")

  if [ ! -e "apps/$app" ] && [ ! -e "custom_apps/$app" ]; then
    echo "App '$app' is not found in the container"
    exit 1
  fi

  if [ "$enabled" != "no" ]; then
    echo "Enabling app: $app"
    $occ_path app:enable "$app"

    for cmd in $(yq -r ".\"$app\".occ_config[]?" "$config_path"); do
      echo "occ $cmd"
      $occ_path $cmd
    done

    yq -r ".\"$app\".json_config // {} | to_entries[] | [.key, .value] | @tsv" "$config_path" | \
    while IFS=$'\t' read -r key val; do
      echo "Configuring: $app / $key = $val"
      $occ_path config:app:set "$app" "$key" --value="$val"
    done
  else
    echo "Disabling app: $app"
    $occ_path app:disable "$app"
  fi
done

# Final maintenance
$occ_path db:add-missing-indices
