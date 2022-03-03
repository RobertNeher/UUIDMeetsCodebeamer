import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';

import '../../configuration.dart';

class CB_UUID_Controller {
  DbCollection? _uuid_mapping;

  CB_UUID_Controller(DbCollection mapping) {
    _uuid_mapping = mapping;
  }

  static const Map<String, String> responseHeaders = {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET',
  };

  Handler get handler {
    final router = Router();

    // main route
    router.get('/', (Request request) {
      return Response.ok(
          'UUID REST Service for codebeamer server at "$CBSourceServer"');
    });

    //lookup for UUID
    router.get(
        '/uuid/<uuid|[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[4][0-9a-fA-F]{3}-[89ABab][0-9a-fA-F]{3}-[0-9a-fA-F]{12}>',
        (Request request, String uuid) async {
      Map<String, dynamic>? result;
      result = await _uuid_mapping!.findOne({'uuid': uuid});

      if (result == null) {
        return Response.notFound('UUID "$uuid" not found');
      } else {
        return Response.ok(jsonEncode(result), headers: responseHeaders);
      }
    });

    // lookup for ObjectID (by MongoDB)
    router.get('/id/<id|[0-9A-Fa-f]+>', (Request request, String id) async {
      Map<String, dynamic>? result;
      ObjectId oid = ObjectId.fromHexString(id);
      result = await _uuid_mapping!.findOne(where.id(oid));

      if (result == null) {
        return Response.notFound('OID "$id" not found');
      } else {
        return Response.ok(jsonEncode(result), headers: responseHeaders);
      }
    });

    //lookup for itemID on codebeamer server
    router.get('/itemID/<itemID|[0-9]+\$>',
        (Request request, String itemID) async {
      Map<String, dynamic>? result;
      result = await _uuid_mapping!.findOne({'itemID': int.parse(itemID)});

      if (result == null) {
        return Response.notFound('Item with ID "$itemID" not found');
      } else {
        return Response.ok(jsonEncode(result), headers: responseHeaders);
      }
    });

    //all other stuff
    router.all('/<ignored|.*>', (Request request) {
      return Response.notFound(
          'Unknown request token: use "uuid", "itemID", or "id" instead');
    });

    return router;
  }
}
