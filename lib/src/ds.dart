import 'dart:async';
import 'dart:io';

import 'dart:typed_data';

class CmdReader implements StreamTransformer<List<int>, List<int>> {
  Stream<List<int>> _stream;
  StreamController<List<int>> _controller;
  StreamSubscription<List<int>> _subscription;
  bool cancelOnError;
  List<int> _pre;

  CmdReader({bool sync = false, this.cancelOnError}) {
    _controller = new StreamController(
        onListen: _onListen,
        onCancel: _onCancel,
        onPause: () {
          _subscription.pause();
        },
        onResume: () {
          _subscription.resume();
        },
        sync: sync);
  }
  void _onListen() {
    _subscription = _stream.listen(_onData, onError: _controller.addError, onDone: _controller.close, cancelOnError: cancelOnError);
  }

  void _onCancel() {
    _subscription.cancel();
    _subscription = null;
  }

  void _onData(List<int> data) {
    if (this._pre != null && this._pre.isNotEmpty) {
      data.insertAll(0, this._pre);
      this._pre = null;
    }
    if (data.length < 5) {
      this._pre = data;
      return;
    }
    var frameLength = data[0] * 256 * 256 * 256 + data[1] * 256 * 256 + data[2] * 256 + data[3];
    if (data.length < frameLength) {
      this._pre = data;
      return;
    }
    this._controller.add(data.sublist(4, frameLength));
    this._pre = data.sublist(frameLength);
  }

  @override
  Stream<List<int>> bind(Stream<List<int>> stream) {
    this._stream = stream;
    return this._controller.stream;
  }

  @override
  StreamTransformer<RS, RT> cast<RS, RT>() {
    throw "not impl";
  }
}

class CmdWriter implements StreamTransformer<List<int>, List<int>> {
  Stream<List<int>> _stream;
  StreamController<List<int>> _controller;
  StreamSubscription<List<int>> _subscription;
  bool cancelOnError;

  CmdWriter({bool sync = false, this.cancelOnError}) {
    _controller = new StreamController(
        onListen: _onListen,
        onCancel: _onCancel,
        onPause: () {
          _subscription.pause();
        },
        onResume: () {
          _subscription.resume();
        },
        sync: sync);
  }

  void _onListen() {
    _subscription = _stream.listen(_onData, onError: _controller.addError, onDone: _controller.close, cancelOnError: cancelOnError);
  }

  void _onCancel() {
    _subscription.cancel();
    _subscription = null;
  }

  void _onData(List<int> data) {
    data.insertAll(0, [0, 0, 0, 0]);
    var bytes = Uint8List.fromList(data);
    ByteData.view(bytes.buffer).setUint32(0, data.length);
    this._controller.add(bytes);
  }

  @override
  Stream<List<int>> bind(Stream<List<int>> stream) {
    this._stream = stream;
    return this._controller.stream;
  }

  @override
  StreamTransformer<RS, RT> cast<RS, RT>() {
    throw "not impl";
  }
}

class Client {}

xx() async {
  var xx = await WebSocket.connect("wss://");
}
