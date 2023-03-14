#!/usr/bin/mongo
conn = new Mongo();
// Authentication 
client = conn.getDB("admin")
client.auth(USERNAME,PASSWORD)
mongodb = client.getMongo()

//////////////////////////////////////////////////////////
// Project
usermanager_db = mongodb.getDB('userdb')
usermanager_db.createCollection("project")
usermanager_db.project.createIndex( {"id":1}, { unique: true } )
usermanager_db.project.insert({
   "accountID":"1",
   "id":"prj9e510b72e6738e4635e8541e2681143a5de1",
   "name":"default",
   "organization":"gopaddle",
   "createdTime":  new Date(),
   "updatedTime":  new Date(),
   "defaultProject":true
}
)


////////////////////////////////////////////////////////
// Release
gpcore_db = mongodb.getDB('gpcore')
gpcore_db.createCollection("Release")
gpcore_db.Release.createIndex( {"id":1}, { unique: true } )
gpcore_db.Release.insert({
   "accountID":"1",
   "id" : "rel42aa4e1de98ffe4325eb9e4e01fd7212e31",
   "project":[
      "prj9e510b72e6738e4635e8541e2681143a5de1"
   ],
   "name":"default",
   "releaseTag":"default",
   "createdTime":  new Date(),
   "updatedTime":  new Date(),
   "defaultRelease":true
}
)

/////////////////////////////////////////////////////////
// Distribution
gpcore_db = mongodb.getDB('gpcore')
gpcore_db.createCollection("Distribution")
gpcore_db.Distribution.createIndex( {"id":1}, { unique: true } )
gpcore_db.Distribution.insert({

	"accountID" : "1",
	"project" : [
		"prj9e510b72e6738e4635e8541e2681143a5de1"
	],
	"releaseID" : "rel42aa4e1de98ffe4325eb9e4e01fd7212e31",
	"id" : "disf0ae2269e981ce4cd3e9693e488317487b3",
	"name" : "default",
	"distributionTag" : "default",
        "createdtime":  new Date(),
        "updatedtime":  new Date(),
	"isDefaultDistribution" : true
}
)


///////////////////////////////////////////////////////////
// Profile
gpcore_db = mongodb.getDB('gpcore')
gpcore_db.createCollection("Profile")
gpcore_db.Profile.createIndex( {"id":1}, { unique: true } )
gpcore_db.Profile.insert({

	"accountID" : "1",
	"project" : [
		"prj9e510b72e6738e4635e8541e2681143a5de1"
	],
	"releaseID" : "rel42aa4e1de98ffe4325eb9e4e01fd7212e31",
	"distributionID" : "disf0ae2269e981ce4cd3e9693e488317487b3",
	"id" : "pro6fa8031feae5ee4577e804ae5b73cc46475",
        "createdtime":  new Date(),
        "updatedtime":  new Date(),
	"name" : "default",
	"defaultProfile" : true
}
)


///////////////////////////////////////////////////////////////////////////////////////////
// Initialize deployment manager
deploymentmanager_db = mongodb.getDB('deploymentmanager')
var testCollection = deploymentmanager_db.getCollectionNames()
if ( testCollection.length != 0 ) {
    print("Database configuration has been done already")
    quit()
}



///////////////////////////////////////////////////////////////////////////////////////////
// Initialize configmanager
configmanager_db = mongodb.getDB('configmanager')

// Allocation policy
configmanager_db.createCollection("allocationPolicy")
configmanager_db.allocationPolicy.createIndex( {"id":1}, { unique: true } )
configmanager_db.allocationPolicy.insert({
   "accountID":"1",
   "id":"apff99b7adapf6b3ap46c8ap8c66ap2820a10cd123",
   "project" : [
		"prj9e510b72e6738e4635e8541e2681143a5de1"
	],
   "createdTime":  new Date(),
   "updatedTime":  new Date(),
   "defaultPolicy":true,
   "name":"default",
   "displayName":"default",
   "description":"Z29wYWRkbGUncyBkZWZhdWx0IGFsbG9jYXRpb25Qb2xpY3k=",
   "resources":{
      "limits":{
         "memory":"500M",
         "cpu":"500m"
      },
      "requests":{
         "memory":"200M",
         "cpu":"200m"
      }
   },
   "tags":[
      {
         "key":"default",
         "value":"default"
      }
   ]
})

// Deployment policy
configmanager_db.createCollection("deploymentPolicy")
configmanager_db.deploymentPolicy.createIndex( {"id":1}, { unique: true } )
configmanager_db.deploymentPolicy.insert({
   "accountID" : "1",
   "project" : [
		"prj9e510b72e6738e4635e8541e2681143a5de1"
	],
   "id":"dp4bb676e9dp25eedp44d1dpa31cdp2fe8f9e39123",
   "createdTime":  new Date(),
   "updatedTime":  new Date(),
   "name":"default-stateless",
   "displayName":"default-stateless",
   "type":"deployment",
   "description":"Z29wYWRkbGUncyBkZWZhdWx0IHN0YXRlbGVzcyBkZXBsb3ltZW50UG9saWN5",
   "property":{
      "revisionHistory":10,
      "deployment":{
         "updateMethod":"rollingUpdate",
         "replicas":1,
         "rollingUpdate":{
            "maxUnavailable":{
               "type":0,
               "intVal":0
            },
            "maxSurge":{
               "type":0,
               "intVal":1
            }
         }
      }
   },
   "tags":[
      {
         "key":"default",
         "value":"default"
      }
   ]
})
configmanager_db.deploymentPolicy.insert({
   "accountID":"1",
   "id":"dp4bb676e9dp25eedp44d1dpa31cdp2fe8f9e31234",
   "project" : [
		"prj9e510b72e6738e4635e8541e2681143a5de1"
	],
   "createdTime":  new Date(),
   "updatedTime":  new Date(),
   "defaultPolicy":true,
   "name":"default-stateful",
   "displayName":"default-stateful",
   "type":"stateful-set",
   "description":"Z29wYWRkbGUncyBkZWZhdWx0IHN0YXRlZnVsIGRlcGxveW1lbnRQb2xpY3k=",
   "property":{
      "revisionHistory":2,
      "statefulset":{
         "replicas":1,
         "updateMethod":"rollingUpdate",
         "rollingUpdate":{
            "partition":0
         }
      }
   },
   "tags":[
      {
         "key":"default-stateful",
         "value":"default-stateful"
      }
   ]
})



// NW policy
configmanager_db.createCollection("nwpolicy")
configmanager_db.nwpolicy.createIndex( {"id":1}, { unique: true } )
configmanager_db.nwpolicy.insert({
   "accountID":"1",
   "project" : [
		"prj9e510b72e6738e4635e8541e2681143a5de1"
	],
   "id":"np_0a11f0ddpdd84p42d9p93a0p484ae72bc123",
   "createdtime":  new Date(),
   "updatedtime":  new Date(),
   "defaultPolicy":true,
   "name":"default",
   "displayName":"default",
   "ingress":[
      {
         "ports":[
            {
               "protocol":"TCP",
               "port":22
            }
         ],
         "networkPolicyPeer":[
            {
               "IPBlock":{
                  "CIDR":"0.0.0.0/0"
               }
            }
         ]
      }
   ],
   "egress":[
      {
         "ports":[
            {
               "protocol":"TCP",
               "port":22
            }
         ],
         "networkPolicyPeer":[
            {
               "IPBlock":{
                  "CIDR":"0.0.0.0/0"
               }
            }
         ]
      }
   ]
})

// scaling policy
configmanager_db.createCollection("scalingPolicy")
configmanager_db.scalingPolicy.createIndex( {"id":1}, { unique: true } )
configmanager_db.scalingPolicy.insert({
   "accountID":"1",
   "id":"sp043128dcsp5e65sp433espaa57sp1b7dfb22b123",
   "project" : [
		"prj9e510b72e6738e4635e8541e2681143a5de1"
	],
   "createdTime":  new Date(),
   "updatedTime":  new Date(),
   "defaultPolicy":true,
   "name":"default",
   "displayName":"default",
   "description":"Z29wYWRkbGUncyBkZWZhdWx0IHNjYWxpbmdQb2xpY3k=",
   "minReplicas":2,
   "maxReplicas":4,
   "metric":[
      {
         "type":"resource",
         "resource":{
            "name":"cpu",
            "targetAverageUtilization":70
         }
      },
      {
         "type":"resource",
         "resource":{
            "name":"memory",
            "targetAverageUtilization":70
         }
      }
   ]
})


// NW policy
configmanager_db.createCollection("storageClass")
configmanager_db.storageClass.createIndex( {"id":1}, { unique: true } )
configmanager_db.storageClass.insert({
   "accountID":"1",
   "id":"pvb8796e65pv3f62pv4a28pv9538pvc8d8e0397123",
   "project" : [
		"prj9e510b72e6738e4635e8541e2681143a5de1"
	],
   "createdTime":  new Date(),
   "updatedTime":  new Date(),
   "defaultPolicy":true,
   "name":"default-aws",
   "displayName":"default-aws",
   "type":"aws",
   "description":"Z29wYWRkbGUncyBkZWZhdWx0IGF3cyBwcm92aXNpb25Qb2xpY3k=",
   "parameter":{
      "awsEBS":{
         "type":"io1",
         "zones":[
            "ap-southeast-1a"
         ],
         "fsType":"ext4"
      }
   },
   "reclaimPolicy":"delete",
   "tags":[
      {
         "key":"default",
         "value":"default"
      }
   ]
})
configmanager_db.storageClass.insert({
   "accountID":"1",
   "id":"pvb8796e65pv3f62pv4a28pv9538pvc8d8e0391234",
   "project" : [
		"prj9e510b72e6738e4635e8541e2681143a5de1"
	],
   "createdTime":  new Date(),
   "updatedTime":  new Date(),
   "defaultPolicy":true,
   "name":"default-gce",
   "displayName":"default-gce",
   "type":"gce",
   "description":"Z29wYWRkbGUncyBkZWZhdWx0IGdjZSBwcm92aXNpb25Qb2xpY3k=",
   "parameter":{
      "gcePD":{
         "type":"pd-standard",
         "zones":[
            "us-central1-a"
         ],
         "replicationType":"none",
         "fsType":"ext4"
      }
   },
   "reclaimPolicy":"delete",
   "tags":[
      {
         "key":"default",
         "value":"default"
      }
   ]
})
configmanager_db.storageClass.insert({
   "accountID":"1",
   "project" : [
		"prj9e510b72e6738e4635e8541e2681143a5de1"
	],
   "id":"pvb8796e65pv3f62pv4a28pv9538pvc8d8e0312345",
   "createdTime":  new Date(),
   "updatedTime":  new Date(),
   "internalTrigger":true,
   "type":"azure",
   "name":"default-azure",
   "displayName":"default-azure",
   "description":"Z29wYWRkbGUncyBkZWZhdWx0IGF6dXJlIHByb3Zpc2lvblBvbGljeQ==",
   "parameter":{
      "azureDISK":{
         "storageAccountType":"Standard_LRS",
         "kind":"Managed"
      }
   },
   "reclaimPolicy":"delete",
   "defaultPolicy":true,
   "tags":[
      {
         "key":"default",
         "value":"default"
      }
   ]
})

// Volume claim policy
configmanager_db.createCollection("volumeClaimPolicy")
configmanager_db.volumeClaimPolicy.createIndex( {"id":1}, { unique: true } )
configmanager_db.volumeClaimPolicy.insert({
   "accountid":"1",
   "project" : [
		"prj9e510b72e6738e4635e8541e2681143a5de1"
	],
   "id":"efcd9e6dgd545g4ae1gb432gb32340592123",
   "createdtime":  new Date(),
   "updatedtime":  new Date(),
   "defaultPolicy":true,
   "name":"default",
   "displayName":"default",
   "accessMode":"ReadWriteOnce",
   "volumeMode":"Filesystem",
   "resources":{
      "limits":"50Gi",
      "requests":"10Gi"
   }
})


// User manager
userdb_db = mongodb.getDB('userdb')
// user table
userdb_db.createCollection("user")
userdb_db.user.createIndex( {"id":1}, { unique: true } )
var passwordexpirydate = new Date()
userdb_db.user.insert({
    "accountid": "1",
    "username": "admin",
    "emailid": "admin@gopaddle.io",
    "phonenumber": "+91 9886024530",
    "isactive":true,
    "isverified":true,
    "createdtime":  new Date(),
    "updatedtime":  new Date(),
    "authprovider":"gopaddle",
    "subscription" : {
	"userdeploymentcount" : "15",
	"userbuildcount" : "1"
    },
    "authdata":{  
        "password":"oxZn+bc7PUL/kdiBbPqD+yfyxKYOywQsPgIE7GonDpH+OG8rqD8HhyigiB9GHGk/G6c6BHHzUvvJ1IBWv30ziq93OPu6OpIPa4DDsoU+h/2Ct+F+AzHdEsXrkSR+pduSHUJd0DBo8z82s7tjzfdatpTYMWn6XdspwPMBGzzBSqk=",
        "lastlogin":  new Date(),
        "passwordexpirydate":   new Date(passwordexpirydate.getTime() + 1000 * 3600 * 24 * 30),
        "resetpasswordtoken":"",
    },
})

//creating index in deploymentmanager
deploy_db=mongodb.getDB('deploymentmanager')
//SGResourceLock table
deploy_db.createCollection('SGResourceLock')
deploy_db.SGResourceLock.createIndex({"appID":1,"deploymentID":1,"deploymentVersion":1,"serviceGroupID":1,"serviceGroupVersion":1},{unique:true});
