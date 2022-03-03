import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:mongo_dart/mongo_dart.dart';

class CB_UUID_ServiceAPI {
  DbCollection? uuid_mappings;

  CB_UUID_ServiceAPI({this.uuid_mappings});

  Router get router {
    const Map<String, String> responseHeaders = {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET',
    };

    final router = Router();

    router.get('/uuid/<uuid>', (Request request, String uuid) async {
        // '/<uuid|^[0-9A-F]{8}-[0-9A-F]{4}-[4][0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}\$>',
        // (Request request, String uuid) async {
      RegExp uuidScanner = RegExp(r'^[0-9A-F]{8}-[0-9A-F]{4}-[4][0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}\$',
        caseSensitive: false,
        multiLine: false,
      );

      if (!uuidScanner.hasMatch(request.url.query)) {
        return Response.notFound('Wrong uuid?', headers: responseHeaders);
      }
      Map<String, dynamic>? result;
      print(uuid);
      result = await uuid_mappings!.findOne({'uuid': uuid});

      if (result!.isEmpty) {
        return Response.notFound('Wrong uuid?', headers: responseHeaders);
      } else {
        return Response.ok(jsonEncode(result), headers: responseHeaders);
      }
    });

    router.get('/<id|[0-9A-Fa-f]+>', (Request request, String id) async {
      Map<String, dynamic>? result;
      ObjectId oid = ObjectId.fromHexString(id);
      print(oid);
      result = await uuid_mappings!.findOne({'_id': oid});

      if (result!.isEmpty) {
        return Response.notFound('Wrong Object ID?', headers: responseHeaders);
      } else {
        return Response.ok(jsonEncode(result), headers: responseHeaders);
      }
    });

    router.get('/<itemID|[0-9]+>', (Request request, int itemID) async {
      Map<String, dynamic>? result;
      print(itemID);
      result = await uuid_mappings!.findOne({'itemID': itemID});

      if (result!.isEmpty) {
        return Response.notFound('Wrong Item ID?', headers: responseHeaders);
      } else {
        return Response.ok(jsonEncode(result), headers: responseHeaders);
      }
    });

    router.all('/<ignored|.*>', (Request request) {
      return Response.notFound('Page not found', headers: responseHeaders);
    });

    return router;
  }
}
