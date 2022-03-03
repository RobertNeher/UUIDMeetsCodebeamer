import 'dart:convert';

import 'package:http/http.dart' as http;

import 'configuration.dart';
import 'helper.dart';

class Project {
  int? id;
  String? name;

  Project({this.id, this.name});

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
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

Future<List<int>> getProjects() async {
  List<int> result = <int>[];
  Uri uri = Uri.https(CBSourceServer, '$RESTAPIPrefix/projects');

  try {
    http.Response response = await http.get(uri, headers: httpHeader());

    if (response.statusCode == 200) {
      var jsonRaw = jsonDecode(response.body);
      var projects = jsonRaw.map((item) => Project.fromJson(item)).toList();

      projects.forEach((project) {
        result.add(project.id!);
      });
      return result;
    } else {
      print(
          'Error in fetching projects: Failed (${response.statusCode}):${response.body}');
      return <int>[];
    }
  } catch (e) {
    print('Error fetching projects: $e');
    return <int>[];
  }
}
