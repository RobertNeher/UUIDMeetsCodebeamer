import 'dart:convert';

import 'package:http/http.dart' as http;

import 'configuration.dart';
import 'helper.dart';

class WorkItem {
  int? id;
  String? name;

  WorkItem({this.id, this.name});

  factory WorkItem.fromJson(Map<String, dynamic> json) {
    return WorkItem(
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

class WorkItemPage {
  int page = 0;
  int pageSize = 0;
  int total = 0;
  List<WorkItem> workItems = <WorkItem>[];

  WorkItemPage(
      {this.page = 0,
      this.pageSize = 0,
      this.total = 0,
      this.workItems = const <WorkItem>[]});

  WorkItemPage.fromJson(Map<String, dynamic> json) {
    page = json['page'];
    pageSize = json['pageSize'];
    total = json['total'];

    if (json['itemRefs'] != null) {
      json['itemRefs'].forEach((workItem) {
        workItems.add(WorkItem.fromJson(workItem));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['page'] = page;
    data['pageSize'] = pageSize;
    data['total'] = total;
    data['itemRefs'] = workItems.map((workItem) => workItem.toJson()).toList();

    return data;
  }

  @override
  String toString() {
    return 'Page $page, Size: $pageSize, Total Items: $total';
  }
}

Future<List<int>> getWorkItems(int tracker) async {
  List<int> result = <int>[];
  List<WorkItemPage> pages = <WorkItemPage>[];
  WorkItemPage stats;
  int maxPages = 0;
  http.Response? response;
  const int maxPageSize = 500;

  try {
    Uri uri = Uri.https(
        CBSourceServer,
        '$RESTAPIPrefix/trackers/$tracker/items',
        {'page': '1', 'pageSize': maxPageSize.toString()});
    response = await http.get(uri, headers: httpHeader());

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonRaw = jsonDecode(response.body);
      stats = WorkItemPage.fromJson(jsonRaw);
      maxPages = stats.total < maxPageSize? 1 : (stats.total / maxPageSize).round();
    } else {
      return [];
    }

    for (int page = 1; page <= maxPages; page++) {
      uri = Uri.https(CBSourceServer, '$RESTAPIPrefix/trackers/$tracker/items',
      {'page': page.toString(), 'pageSize': maxPageSize.toString()});
      response = await http.get(uri, headers: httpHeader());

      if (response.statusCode == 200) {
        WorkItemPage pageItem =
            WorkItemPage.fromJson(jsonDecode(response.body));
        pages.add(pageItem);
      } else {
        print("Error fetching workitems ${response.statusCode}");
        return [];
      }
    }
  } catch (e) {
    print(
        'Error in fetching workitems from tracker $tracker: ${response!.statusCode}: ${response.body}');
  }

  for (WorkItemPage page in pages) {
    for (WorkItem item in page.workItems) {
      result.add(item.id!);
    }
  }
  return result;
}
