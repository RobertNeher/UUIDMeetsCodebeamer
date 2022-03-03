import 'dart:convert';

import 'configuration.dart';

extension StringExtension on String {
  String truncateTo(int maxLength) =>
      (this.length <= maxLength) ? this : '${this.substring(0, maxLength)}...';
}

Map<String, String> httpHeader() {

  return {
    'accept': 'application/json',
    'content-type': 'application/json',
    'authorization': getAuthToken(),
  };
}

String getAuthToken([String type = "Basic"]) {
  String token = base64.encode(utf8.encode("$UserName:$PassWord"));
  return "$type $token";
}
