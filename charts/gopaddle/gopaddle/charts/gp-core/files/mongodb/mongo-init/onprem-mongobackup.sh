#/bin/bash
sh -x
echo "Creating Dump Script"
export PATH=$PATH:./root/.local/bin/
mongodump -u admin -p cGFzc3dvcmQ
tar -cvzf onprem-mongo.tar.gz dump
rm -rf dump
export dateFormat=`date +%m-%d-%Y`
export PATH=$PATH:/root/.local/bin/
which aws
aws s3 cp onprem-mongo.tar.gz s3://onprem-mongodb-dump/`date +%m-%d-%Y`/onprem-mongo.tar.gz --sse aws:kms
rm onprem-mongo.tar.gz

