#!/bin/bash

# Local dev only: compared to default entrypoint, stay running as root and
# use a permissive umask instead of dropping to jetty,
# and make existing volume content group-writable to match.
chgrp -R 0 /data
chmod -R g+rwX /data
umask 0002

for MEM_FILE in memory.max memory/memory.limit_in_bytes memory/memory.memsw.limit_in_bytes memory/memory.kmem.limit_in_bytes; do
  echo "Checking for /sys/fs/cgroup/$MEM_FILE..."
  if [[ -e /sys/fs/cgroup/${MEM_FILE} ]]; then
    echo "Found."
    break
  fi
done

if [[ ! -e /sys/fs/cgroup/${MEM_FILE} ]]; then
  echo "Could not read container memory."
fi

if [[ -d /jetty-overrides ]]; then
  cd /jetty-overrides
  for file in $(find . -type f); do cp $file ${JETTY_BASE}/$file; done
  cd -
fi

MEM_BYTES=$(cat /sys/fs/cgroup/${MEM_FILE})
if [[ -e /sys/fs/cgroup/${MEM_FILE} && $MEM_BYTES -ne "max" && $MEM_BYTES -ne "9223372036854771712" ]]; then
  let "MX=$MEM_BYTES * 8 / 10 / 1024 / 1024"
  echo "Setting -Xmx${MX}m"
  JAVA_OPTIONS="${JAVA_OPTIONS} -Xmx${MX}m"
fi

DEFAULT_CONFIG="file-simple"
if [[ "$FCREPO_VERSION" < "4.7.0" ]]; then
  DEFAULT_CONFIG="minimal-default"
fi

MODESHAPE_CONFIG=${MODESHAPE_CONFIG:-classpath:/config/${DEFAULT_CONFIG}/repository.json}
export JAVA_OPTIONS="${JAVA_OPTIONS} -Dfcrepo.home=/data -Dfcrepo.modeshape.configuration=${MODESHAPE_CONFIG}"
exec /docker-entrypoint.sh "$@"
