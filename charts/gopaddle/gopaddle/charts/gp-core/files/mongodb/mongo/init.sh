#/bin/bash
sh -x
ls /initscript
    if [[ ! -f  "{{ .Values.dataDir }}/init-done" ]]; then
      nohup /usr/local/bin/docker-entrypoint.sh mongod > /var/log/mongodb/mongodb.log 2>&1 &
      sleep 30
      if [ "$GP_EDITION" = "Enterprise" ]; then
        mongo --eval "var USERNAME = '$MONGO_INITDB_ROOT_USERNAME'; var PASSWORD = '$MONGO_INITDB_ROOT_PASSWORD';" /initscript/db.js
      else
        mongo --eval "var USERNAME = '$MONGO_INITDB_ROOT_USERNAME'; var PASSWORD = '$MONGO_INITDB_ROOT_PASSWORD';" /initscript/dblite.js
      fi
      touch "/data/db/init-done"
      sleep 10
    fi
    echo "Mongodb has been initialized!"
    # sleep 300


tail -f /var/log/mongodb/mongodb.log




