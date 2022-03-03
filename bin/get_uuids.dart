import 'dart:convert';

import 'package:http/http.dart' as http;

import 'configuration.dart';
import 'helper.dart';

const int maxUUIDs = 500;

Future<List<String>> getUUIDs(int UUIDCount) async {
  List<String> uuids = <String>[];
  http.Response? response;
  Uri uri;

  int slots = (UUIDCount ~/ maxUUIDs);

  for (int slot = slots; slot >= 0; slot--) {
    uri = Uri.https(UUIDServiceURL, '$UUIDServicePath/${slot == 0? UUIDCount % maxUUIDs : maxUUIDs}');

    try {
      response = await http.get(uri, headers: httpHeader());

      if (response.statusCode == 200) {
        List jsonRaw = jsonDecode(response.body);
        uuids.addAll(jsonRaw.map((uuid) => uuid as String).toList());
      } else {
        return [];
      }
    } catch (e) {
      print(
          'Error in fetching UUIDs from UUID service channel: ${response!.statusCode}: ${response.body}');
    }
  }
  return uuids;
}
