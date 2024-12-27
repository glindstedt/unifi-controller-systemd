set dotenv-filename := "variables.env"

units_dir := join(source_directory(), "units")
templates_dir := join(source_directory(), "templates")

install_path := join(home_directory(), ".config", "containers", "systemd", "unifi-controller")

_default:
    @just --list --justfile {{justfile()}}

default_variables := join(templates_dir, "default-variables.env")
variables_file := join(source_directory(), "variables.env")
tmpl_mongo_initdb_root_pass_var := "TMPL_MONGO_INITDB_ROOT_PASSWORD"
tmpl_mongo_pass_var := "TMPL_MONGO_PASS"
tmpl_tz_var := "TMPL_TZ"

# initialize variables.env file
init-variables:
    #!/usr/bin/env sh
    if {{path_exists(variables_file)}}; then
        echo "{{ variables_file }} already exists! Will not overwrite it.";
    else
        echo "Generating variables...";
        cat {{ default_variables }} > {{ variables_file }}
        cat >> {{ variables_file }} <<EOF
    {{ tmpl_mongo_initdb_root_pass_var }}=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 32; echo)
    {{ tmpl_mongo_pass_var }}=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 32; echo)
    EOF
    fi

# templates
unifi_db_env_tmpl := join(templates_dir, "unifi-db.env")
unifi_db_env_file := "unifi-db.env"
unifi_app_env_tmpl := join(templates_dir, "unifi-network-application.env")
unifi_app_env_file := "unifi-network-application.env"

_copy-env-files:
    envsubst < {{ unifi_db_env_tmpl }} > {{ join(install_path, unifi_db_env_file) }}
    envsubst < {{ unifi_app_env_tmpl }} > {{ join(install_path, unifi_app_env_file) }}

_copy-unit-files:
    cp {{ units_dir }}/* {{ install_path }}

_reload:
    systemctl --user daemon-reload

# install systemd units to ~/.config/containers/systemd/unifi-controller/
install: _copy-env-files _copy-unit-files _reload

restart-db:
    systemctl --user restart unifi-db.service

restart-service:
    systemctl --user restart unifi-network-application.service

# show last 5 minutes of logs
logs:
    journalctl --user-unit=unifi-network-application --user-unit=unifi-db --since=$(date -d "-10 min" -I"minutes") | bat -l log --style plain
