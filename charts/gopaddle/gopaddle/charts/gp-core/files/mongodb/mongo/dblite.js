#!/usr/bin/mongo
conn = new Mongo();
// Authentication 
client = conn.getDB("admin")
client.auth(USERNAME,PASSWORD)
mongodb = client.getMongo()

///////////////////////////////////////////////////////////////////////////////////////////
// Initialize deployment manager
deploymentmanager_db = mongodb.getDB('deploymentmanager')
var testCollection = deploymentmanager_db.getCollectionNames()
if ( testCollection.length != 0 ) {
    print("Database configuration has been done already")
    quit()
}


//creating index in deploymentmanager
deploy_db=mongodb.getDB('deploymentmanager')
//SGResourceLock table
deploy_db.createCollection('SGResourceLock')
deploy_db.SGResourceLock.createIndex({"appID":1,"deploymentID":1,"deploymentVersion":1,"serviceGroupID":1,"serviceGroupVersion":1},{unique:true});