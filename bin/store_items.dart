import 'package:mongo_dart/mongo_dart.dart';

import 'configuration.dart';
import 'get_uuids.dart';

Future<void> storeItems(DbCollection collection, String type, List<int> data) async {

  if (data.length == 0) return;

  List<String> uuids = await getUUIDs(data.length);
  List<Map<String, dynamic>> bulkData = [];
  int count = 0;

  for (var element in data) {
    bulkData.add({
      "type": type,
      "itemID": element,
      "uuid": uuids[count++],
    });
  }
  if (bulkData.isNotEmpty) {
    await collection.insertMany(bulkData, bypassDocumentValidation: true, ordered: true);
  }
}
