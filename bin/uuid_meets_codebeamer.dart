import 'package:mongo_dart/mongo_dart.dart';

import 'get_projects.dart';
import 'get_trackers.dart';
import 'get_workitems.dart';
import 'get_attachments.dart';
import 'get_wikis.dart';
import 'store_items.dart';
import 'configuration.dart';

void main(List<String> arguments) async {
  List<int> projects = <int>[];
  List<int> trackers = <int>[];
  List<int> projectTrackers = <int>[];
  List<int> trackerItems = <int>[];
  List<int> workItems = <int>[];
  List<int> itemAttachments = <int>[];
  List<int> attachments = <int>[];
  List<int> wikis = <int>[];
  List<int> projectWikis = <int>[];

  final Db mappingDB = await Db.create(DBMappingServer);
  await mappingDB.open();
  await mappingDB.drop();
  final DbCollection mappingCollection =
      mappingDB.collection(DBMappingCollection);
  mappingCollection.createIndex(keys: {'type': 1});
  mappingCollection.createIndex(keys: {'itemID': 1});

  // get all projects
  projects = await getProjects();
  await storeItems(mappingCollection, 'Project', projects);

  // get all trackers of all projects
  for (int project in projects) {
    projectTrackers = await getTrackers(project);
    await storeItems(mappingCollection, 'Tracker', projectTrackers);
    trackers.addAll(projectTrackers);

    // get all wikis from project
    projectWikis = await getWikis(project);
    wikis.addAll(projectWikis);
    await storeItems(mappingCollection, 'Wiki', projectWikis);
  }

  //get all work items of all trackers of project
  int wiCount = 0;

  for (int tracker in trackers) {
    trackerItems = await getWorkItems(tracker);
    print(
        'Tracker $tracker owns ${trackerItems.length} ($wiCount) work items');

    if (trackerItems.isNotEmpty) {
      await storeItems(mappingCollection, 'Work Item', trackerItems);
      workItems.addAll(trackerItems);
      wiCount += trackerItems.length;

      // get all attachments from project's work items across all project's trackers
      for (int workItem in trackerItems) {
        itemAttachments = await getAttachments(workItem);
        attachments.addAll(itemAttachments);
      }
      await storeItems(mappingCollection, 'Attachment', attachments);
    }

  }
  print('${trackers.length} trackers stored.');
  print('${workItems.length} work items stored.');
  print('${attachments.length} attachments stored.');
  print('${wikis.length} wikis stored.');

  await mappingDB.close();
}
