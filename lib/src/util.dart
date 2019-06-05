import 'dart:io';

String objectInfo(Object obj) {
  switch (obj.runtimeType) {
    case Socket:
      var conn = obj as Socket;
      return "${conn.remoteAddress.address}:${conn.remotePort}";
    default:
      return "$obj";
  }
}

// class Reader {
//   static Future<T> readOnce<T>(Stream<T> s) async {
//     T res;
//     await for (res in s) {
//       break;
//     }
//     return res;
//   }
// }

void unawaited(Future w) async {
  try {
    await w;
  } catch (e) {
    //
  }
}
