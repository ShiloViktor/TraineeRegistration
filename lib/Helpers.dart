import 'dart:convert';

class Helpers {
  static String transformMessageToString(String message) {
    if (message != '' && message != null) {
      List<int> bytes = utf8.encode(message);
      String value = utf8.decode(bytes);
      return value;
    } else {
      return '';
    }
  }
}
