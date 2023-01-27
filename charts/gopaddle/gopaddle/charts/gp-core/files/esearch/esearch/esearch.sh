#!/bin/bash
set -x
chown elasticsearch:elasticsearch /usr/share/elasticsearch/data
echo "node.local: true" >> /etc/elasticsearch/elasticsearch.yml
/usr/bin/java -Xms256m -Xmx1g -Djava.awt.headless=true -XX:+UseParNewGC -XX:+UseConcMarkSweepGC -XX:CMSInitiatingOccupancyFraction=75 -XX:+UseCMSInitiatingOccupancyOnly -XX:+HeapDumpOnOutOfMemoryError -XX:+DisableExplicitGC -Dfile.encoding=UTF-8 -Delasticsearch -Des.foreground=yes -Des.path.home=/usr/share/elasticsearch -cp :/usr/share/elasticsearch/lib/elasticsearch-1.7.3.jar:/usr/share/elasticsearch/lib/*:/usr/share/elasticsearch/lib/sigar/* org.elasticsearch.bootstrap.Elasticsearch > esearch.log
tail -f esearch.log
