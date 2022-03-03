**UUID meets codebeamer**

This project is supposed to support third party tools which require UUID for any artefact managed by codebeamer.
UUIDMeetsCodebeamer will parse the entire data set of a codebeamer server and reads
- all projects
- all trackers
- all work items
- all wikis
- all attachments

The data is being stored in a MongoDB database.

The configuration.dart file contains most of the relevant settings:
CBSourceServer = 'codebeamer.b-h-c.de': URL of codebeamer server

RESTAPIPrefix = '/api/v3': REST API prefix of codebeamer server

UUIDServiceURL = 'www.uuidgenerator.net': URL to retrieve (unlimited number of) UUIDs

UUIDServicePath = '/api/version4': here you may choose whivh UUID version should be used

UserName = '': User/password for logging on codebeamer server, user should have read access to all resources and REST rights
PassWord = ''

DBMappingServer = 'mongodb://localhost:27017/CodebeamerUUIDMapping': Database keeping mapping data. WARNING: Collection name "Mapping" is hard coded!

CB_UUIDWebServiceServer = 'localhost': URL and port für web service to retrieve data from mapping database 
CB_UUIDWebServicePort = 4712

*Start data collection and add UUIDs*

Start root app with: _dart run .\bin\uuid_meets_codebeamer.dart_

*REST Service*

The REST Service should be started before data could be accessed from outside:

Start root app with: _dart run .\bin\rest_api\server.dart_

The URL tokens:

<URL:Port>/uuid/<UUID>: retrieve item data by UUID
<URL:Port>/id/<ObjectID>: retrieve item data by Object ID (by MongoDB)
<URL:Port>/itemID/<ItemID>: retreive item data by ItemID

The returned document has this format:
{
  "type": "[Project|Tracker|Work Item|Wiki|Attachment]" (String)
  "itemID": 4711 (int32)
  "uuid": the unique ID across entire codebeamer server (String)
}
----- **** -----
