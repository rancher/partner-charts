# ortelius-ms-compitem-crud
Repo for base service catalog data microservice

### API LIST
Four types of APIs are supported at the moment.

#### Add list of component item 

# Sample call 
curl localhost:5000/msapi/compitem?comp_id=255
[{"id": 361, "compid": 255, "buildid": "", "buildurl": "", "dockersha": "", "dockertag": "", "gitcommit": "", "gitrepo": "", "giturl": ""}, {"id": 8000, "compid": 255, "buildid": "test", "buildurl": "test", "dockersha": "test", "dockertag": "test", "gitcommit": "test", "gitrepo": "test", "giturl": "test"}, {"id": 8001, "compid": 255, "buildid": "test", "buildurl": "test", "dockersha": "test", "dockertag": "test", "gitcommit": "test", "gitrepo": "test", "giturl": "test"}]


#### Delete list of component item

# Sample call 

curl -X DELETE localhost:5000/msapi/compitem?comp_id=339

#### Get list of component item

# Sample call 

curl localhost:5000/msapi/compitem?comp_id=106

#### Update list of component item

# Sample call 

in progress

### Run the app

To run the app locally write \
`$ python main.py`