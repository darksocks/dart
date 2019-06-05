import 'dart:typed_data';

import 'package:darksocks/darksocks.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';
import 'dart:io';

void main() {
  group('SockProxy', () {
    SocksProxy proxy;
    ServerSocket echo;
    runEcho() async {
      echo = await ServerSocket.bind("127.0.0.1", 10023);
      await for (var conn in echo) {
        await for (var data in conn) {
          print("echo recieve ${String.fromCharCodes(data)}");
          conn.add(data);
        }
        await conn.close();
      }
    }

    setUp(() {
      Logger.root.level = Level.ALL; // defaults to Level.INFO
      Logger.root.onRecord.listen((record) {
        print('${record.level.name}: ${record.time}: ${record.message}');
      });
      proxy = SocksProxy((String uri, Stream<List<int>> conn) async {
        print("dial to $uri");
        var raw = await Socket.connect("127.0.0.1", 10023);
        return raw;
      });
      proxy.run("0.0.0.0:10022");
      runEcho();
    });

    tearDown(() async {
      await echo.close();
      await proxy.close();
    });

    test('test ip', () async {
      var conn = await Socket.connect("127.0.0.1", 10022);
      var step = 0x00;
      conn.add(Uint8List.fromList([0x05, 0x01, 0x00]));
      await for (var data in conn) {
        print("receiving $data");
        switch (step) {
          case 0x00:
            assert(data.length == 2);
            assert(data[1] == 0x00);
            step++;
            conn.add(Uint8List.fromList([0x05, 0x01, 0x00, 0x01, 127, 0, 0, 1, (10023 / 256).floor(), 10023 % 256]));
            break;
          case 0x01:
            assert(data.length == 10);
            assert(data[3] == 0x01);
            step++;
            conn.write("echo");
            break;
          case 0x02:
            assert(String.fromCharCodes(data) == "echo");
            step++;
            conn.write("exit");
            break;
          default:
            print("receive ${String.fromCharCodes(data)}");
            conn.destroy();
            break;
        }
      }
      print("test client is stopped");
    });

    test('test domain', () async {
      var conn = await Socket.connect("127.0.0.1", 10022);
      var step = 0x00;
      conn.add(Uint8List.fromList([0x05, 0x01, 0x00]));
      await for (var data in conn) {
        print("receiving $data");
        switch (step) {
          case 0x00:
            assert(data.length == 2);
            assert(data[1] == 0x00);
            step++;
            var host = "localhost";
            List<int> cmd = List();
            cmd.addAll([0x05, 0x01, 0x00, 0x03, host.length]);
            cmd.addAll(host.codeUnits);
            cmd.addAll([(10023 / 256).floor(), 10023 % 256]);
            conn.add(Uint8List.fromList(cmd));
            break;
          case 0x01:
            assert(data.length == 10);
            assert(data[3] == 0x01);
            step++;
            conn.write("echo");
            break;
          case 0x02:
            assert(String.fromCharCodes(data) == "echo");
            step++;
            conn.write("exit");
            break;
          default:
            print("receive ${String.fromCharCodes(data)}");
            conn.destroy();
            break;
        }
      }
      print("test client is stopped");
    });
  });
}
