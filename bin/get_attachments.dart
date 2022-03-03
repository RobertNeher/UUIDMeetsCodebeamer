import 'dart:convert';

import 'package:http/http.dart' as http;

import 'configuration.dart';
import 'helper.dart';

class Attachment {
  int? id;
  String? name;

  Attachment({this.id, this.name});

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
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

class AttachmentPage {
  int page = 0;
  int pageSize = 0;
  int total = 0;
  List<Attachment> attachments = <Attachment>[];

  AttachmentPage(
      {this.page = 0,
      this.pageSize = 0,
      this.total = 0,
      this.attachments = const <Attachment>[]});

  AttachmentPage.fromJson(Map<String, dynamic> json) {
    page = json['page'];
    pageSize = json['pageSize'];
    total = json['total'];

    if (json['attachments'] != null) {
      json['attachments'].forEach((workItem) {
        attachments.add(Attachment.fromJson(workItem));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['page'] = page;
    data['pageSize'] = pageSize;
    data['total'] = total;
    data['attachments'] = attachments.map((attachment) => attachment.toJson()).toList();

    return data;
  }

  @override
  String toString() {
    return 'Page $page, Size: $pageSize, Total Items: $total';
  }
}

Future<List<int>> getAttachments(int workItem) async {
  List<int> result = <int>[];
  List<AttachmentPage> pages = <AttachmentPage>[];
  List<Attachment> attachments = <Attachment>[];
  AttachmentPage stats;
  int maxPages = 0;
  http.Response? response;
  const int maxPageSize = 500;

  try {
    Uri uri = Uri.https(
        CBSourceServer,
        '$RESTAPIPrefix/items/$workItem/attachments',
        {'page': '1', 'pageSize': maxPageSize.toString()});
    response = await http.get(uri, headers: httpHeader());

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonRaw = jsonDecode(response.body);
      stats = AttachmentPage.fromJson(jsonRaw);
      maxPages = (stats.total / maxPageSize).round();
    } else {
      return [];
    }

    for (int page = 0; page <= maxPages; page++) {
      uri = Uri.https(CBSourceServer, '$RESTAPIPrefix/items/$workItem/attachments', {'page': (page+1).toString(), 'pageSize': maxPageSize.toString()});
      response = await http.get(uri, headers: httpHeader());

      if (response.statusCode == 200) {
        AttachmentPage pageItem =
            AttachmentPage.fromJson(jsonDecode(response.body));
        pages.add(pageItem);
      } else {
        print("Error fetching attachments ${response.statusCode}");
        return [];
      }
    }
  } catch (e) {
    print(
        'Error in fetching attachments from work item $workItem'); //: ${response!.statusCode}: ${response.body}');
  }

  for (AttachmentPage page in pages) {
    for (Attachment item in page.attachments) {
      result.add(item.id!);
    }
  }
  return result;
}
