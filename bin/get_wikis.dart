import 'dart:convert';

import 'package:http/http.dart' as http;

import 'configuration.dart';
import 'helper.dart';

class Wiki {
  int projectID;
  int id;

  Wiki(this.projectID, this.id);

  factory Wiki.fromJson(Map<String, dynamic> json) {
    return Wiki(
      json['projectID'],
      json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'projectID': projectID,
      'id': id,
    };
  }

  @override
  String toString() {
    return '$id';
  }
}

class WikiPage {
  int? page;
  int? pageSize;
  int? total;
  List<OutlineWikiPages>? outlineWikiPages;

  WikiPage({this.page, this.pageSize, this.total, this.outlineWikiPages});

  WikiPage.fromJson(Map<String, dynamic> json) {
    page = json['page'];
    pageSize = json['pageSize'];
    total = json['total'];
    if (json['outlineWikiPages'] != null) {
      outlineWikiPages = <OutlineWikiPages>[];
      json['outlineWikiPages'].forEach((v) {
        outlineWikiPages!.add( OutlineWikiPages.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['page'] = page;
    data['pageSize'] = pageSize;
    data['total'] = total;
    if (outlineWikiPages != null) {
      data['outlineWikiPages'] =
          outlineWikiPages!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class OutlineWikiPages {
  List<OutlineIndexes>? outlineIndexes;
  String? type;
  WikiPageReferenceModel? wikiPageReferenceModel;

  OutlineWikiPages(
      {this.outlineIndexes, this.type, this.wikiPageReferenceModel});

  OutlineWikiPages.fromJson(Map<String, dynamic> json) {
    if (json['outlineIndexes'] != null) {
      outlineIndexes = <OutlineIndexes>[];
      json['outlineIndexes'].forEach((v) {
        outlineIndexes!.add(OutlineIndexes.fromJson(v));
      });
    }
    type = json['type'];
    wikiPageReferenceModel = json['wikiPageReferenceModel'] != null
        ? new WikiPageReferenceModel.fromJson(json['wikiPageReferenceModel'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (outlineIndexes != null) {
      data['outlineIndexes'] =
          outlineIndexes!.map((v) => v.toJson()).toList();
    }
    data['type'] = type;
    if (wikiPageReferenceModel != null) {
      data['wikiPageReferenceModel'] = wikiPageReferenceModel!.toJson();
    }
    return data;
  }
}

class OutlineIndexes {
  int? level;
  int? index;

  OutlineIndexes({this.level, this.index});

  OutlineIndexes.fromJson(Map<String, dynamic> json) {
    level = json['level'];
    index = json['index'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['level'] = level;
    data['index'] = index;
    return data;
  }
}

class WikiPageReferenceModel {
  int? id;
  String? name;
  String? type;

  WikiPageReferenceModel({this.id, this.name, this.type});

  WikiPageReferenceModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['type'] = type;
    return data;
  }
}

Future<List<int>> getWikis(int project) async {
  List<int> result = <int>[];
  List<WikiPage> pages = <WikiPage>[];
  List<Wiki> wikis = <Wiki>[];
  WikiPage stats;
  int maxPages = 0;
  http.Response? response;
  const int maxPageSize = 500;

  try {
    Uri uri = Uri.https(
        CBSourceServer,
        '$RESTAPIPrefix/projects/$project/wikipages',
        {'page': '1', 'pageSize': maxPageSize.toString()});
    response = await http.get(uri, headers: httpHeader());

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonRaw = jsonDecode(response.body);
      stats = WikiPage.fromJson(jsonRaw);
      maxPages = stats.total! < maxPageSize? 1 : (stats.total! / maxPageSize).round();
    } else {
      return [];
    }

    for (int page = 0; page < maxPages; page++) {
      uri = Uri.https(
          CBSourceServer, '$RESTAPIPrefix/projects/$project/wikipages');
      response = await http.get(uri, headers: httpHeader());

      if (response.statusCode == 200) {
        WikiPage pageItem =
            WikiPage.fromJson(jsonDecode(response.body));
        pages.add(pageItem);
      } else {
        print("Error fetching wiki pages ${response.statusCode}");
        return [];
      }
    }
  } catch (e) {
    print(
        'Error in fetching wiki pages from project $project: ${response!.statusCode}: ${response.body}');
  }

  pages.forEach((page) {
    page.outlineWikiPages!.forEach((item) {
      result.add(item.wikiPageReferenceModel!.id!);
    });
  });
  return result;
}
