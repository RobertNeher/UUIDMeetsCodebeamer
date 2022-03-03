import 'get_uuids.dart';
import 'get_attachments.dart';

void main(List<String> args) async {
  List<int> attachments = await getAttachments(int.parse(args[0]));
  print(attachments.length);
  print(attachments);
}
