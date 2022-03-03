import 'dart:convert';

import 'package:http/http.dart' as http;

import 'configuration.dart';
import 'helper.dart';

class Tracker {
  int? id;
  String? name;

  Tracker({this.id, this.name});

  factory Tracker.fromJson(Map<String, dynamic> json) {
    return Tracker(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  String toString() {
    return '$id: $name';
  }
}

Future<List<int>> getTrackers(int project) async {
  List<int> result = <int>[];
  Uri uri = Uri.https(CBSourceServer, '$RESTAPIPrefix/projects/$project/trackers');

  try {
    http.Response response = await http.get(uri, headers: httpHeader());

    if (response.statusCode == 200) {
      var jsonRaw = jsonDecode(response.body);
      var trackers = jsonRaw.map((item) => Tracker.fromJson(item)).toList();

      trackers.forEach((tracker) {
        result.add(tracker.id!);
      });
      return result;
    } else {
      print(
          'Error in fetching trackers of project with id $project: Failed (${response.statusCode}):${response.body}');
      return <int>[];
    }
  } catch (e) {
    print('Error fetching trackers: $e');
    return <int>[];
  }
}
