import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'dart:typed_data';
import 'package:darksocks/src/util.dart';
import 'package:logging/logging.dart';

final _log = Logger("SocksProxy");

typedef Future<Socket> Dialer(String uri, Socket conn);

class SocksTransformer {
  Socket conn;
  Dialer dialer;
  String httpUpstream;
  //
  List<int> _pre;
  int _step = 0;
  Socket _next;
  SocksTransformer(this.conn, this.dialer, this.httpUpstream);
  void proc() async {
    try {
      await for (var data in this.conn) {
        await this._handlerData(data);
      }
    } finally {
      if (this._next != null) {
        await this._next.close();
      }
    }
  }

  void _handlerData(Uint8List data) async {
    // print("----->$data");
    if (this._next != null) {
      this._next.add(data);
      return;
    }
    if (this._pre != null && this._pre.isNotEmpty) {
      data.insertAll(0, this._pre);
      this._pre = null;
    }
    if (data.length < 2) {
      this._pre = data;
      return;
    }
    if (this._step == 0x00) {
      if (data[0] != 0x05) {
        if (this.httpUpstream == null || this.httpUpstream.isEmpty) {
          this.conn.destroy();
          throw "only ver 0x05 is supported, but ${data[0]}";
        }
        _log.fine("SocksProxy proxy connection to http upstream(${httpUpstream}) from ${objectInfo(this.conn)}");
        var parts = this.httpUpstream.split(":");
        var host = parts[0];
        var port = int.parse(parts[1]);
        this._next = await Socket.connect(host, port);
        this._next.add(data);
        unawaited(this._next.pipe(this.conn));
        return;
      }
      this._step = 0x01;
    }
    if (this._step == 0x01) {
      if (data.length < data[1] + 2) {
        this._pre = data;
        return;
      }
      data = data.sublist(data[1] + 2);
      this.conn.add(Uint8List.fromList([0x05, 0x00]));
      this._step = 0x03;
    }
    if (this._step == 0x03) {
      if (data.length < 2 || data.length < data[1] + 2) {
        this._pre = data;
        return;
      }
      String uri;
      switch (data[3]) {
        case 0x01:
          uri = "${data[4]}.${data[5]}.${data[6]}.${data[7]}:${data[8] * 256 + data[9]}";
          data = data.sublist(10);
          break;
        case 0x03:
          var remote = String.fromCharCodes(data.sublist(5, data[4] + 5));
          uri = "${remote}:${data[data[4] + 5] * 256 + data[data[4] + 6]}";
          data = data.sublist(data[4] + 7);
          break;
        default:
          this.conn.destroy();
          throw "ATYP ${data[3]} is not supported";
          break;
      }
      this._next = await this.dialer(uri, this.conn);
      this.conn.add(Uint8List.fromList([0x05, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]));
      unawaited(this.conn.addStream(this._next));
      if (data.isNotEmpty) {
        this._next.add(data);
      }
    }
  }
}

//SocksProxy is an implementation of socks5 proxy
class SocksProxy {
  ServerSocket server;
  Dialer dialer;
  String httpUpstream = "";
  Set<SocksTransformer> conns = Set();
  SocksProxy(this.dialer);
  void run(String addr) async {
    var parts = addr.split(":");
    var host = parts[0];
    var port = int.parse(parts[1]);
    this.server = await ServerSocket.bind(host, port);
    _log.info("SocksProxy listen socks5 proxy on $addr");
    await for (var conn in this.server) {
      this._runConn(conn);
    }
  }

  void _runConn(Socket conn) async {
    var transformer = SocksTransformer(conn, this.dialer, this.httpUpstream);
    this.conns.add(transformer);
    try {
      _log.finer("SocksProxy proxy connection from ${conn.remoteAddress.address}:${conn.remotePort}");
      await transformer.proc();
      _log.finest("SocksProxy proxy connection from ${conn.remoteAddress.address}:${conn.remotePort} is done");
    } catch (e) {
      _log.finest("SocksProxy proxy connection from ${conn.remoteAddress.address}:${conn.remotePort} is done with $e", e);
    }
    this.conns.remove(transformer);
  }

  void close() async {
    _log.warning("SocksProxy is closing");
    await this.server.close();
  }
}
