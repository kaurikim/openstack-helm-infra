#!/bin/sh

{{/*
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/}}

set -ex
COMMAND="${@:-start}"

function start () {
  exec /bin/alertmanager \
    -config.file=/etc/alertmanager/config.yml \
    -storage.path={{ .Values.conf.command_flags.storage.path }} \
    -mesh.listen-address={{ .Values.conf.command_flags.mesh.listen_address }} \
    $(generate_peers)
}

function generate_peers () {
  final_pod_suffix=$(( {{ .Values.pod.replicas.alertmanager }}-1 ))
  for pod_suffix in `seq 0 "$final_pod_suffix"`
  do
    echo -mesh.peer={{ .Release.Name }}-$pod_suffix.$DISCOVERY_SVC:$MESH_PORT
  done
}

function stop () {
  kill -TERM 1
}

$COMMAND
