import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shelf_router/shelf_router.dart';

import '../configuration.dart';
import './controllers/cb_uuid_controller.dart';

void main(List<String> args) async {
  Db mappingDB = await Db(DBMappingServer);
  await mappingDB.open();
  DbCollection mappingCollection = DbCollection(mappingDB, DBMappingCollection);

  final app = Router();

  final cb_uuid_controller = CB_UUID_Controller(mappingCollection);
  app.mount('/api/v1/', cb_uuid_controller.handler);

  final server =
      await shelf_io.serve(app, CB_UUIDWebServiceServer, CB_UUIDWebServicePort);

  print(
      '☀️ Server started listening on $CB_UUIDWebServiceServer:$CB_UUIDWebServicePort ☀️');
}
