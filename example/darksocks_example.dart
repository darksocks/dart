import 'dart:io';

import 'package:darksocks/darksocks.dart';
import 'package:darksocks/src/util.dart';
import 'package:logging/logging.dart';

main(List<String> args) {
  runLocalProxy(args[0]);
}

runLocalProxy(String addr) async {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
  final log = Logger("LocalProxy");
  var proxy = SocksProxy((String uri, Conn<List<int>> conn) async {
    log.fine("dial to $uri");
    var parts = uri.split(":");
    var host = parts[0];
    var port = int.parse(parts[1]);
    var raw = await Socket.connect(host, port);
    log.fine("dial to $uri success");
    return Conn(raw, raw);
  });
  await proxy.run(addr);
}
