import 'dart:async';
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

class Conn<T> implements Stream<T>, StreamSink<T> {
  Stream<T> stream;
  StreamSink<T> sink;
  Conn(this.stream, this.sink);
  @override
  void add(T event) {
    this.sink.add(event);
  }

  @override
  void addError(Object error, [StackTrace stackTrace]) {
    this.sink.addError(error, stackTrace);
  }

  @override
  Future addStream(Stream<T> stream) {
    return this.sink.addStream(stream);
  }

  @override
  Future<bool> any(bool Function(T element) test) {
    return this.stream.any(test);
  }

  @override
  Stream<T> asBroadcastStream({void Function(StreamSubscription<T> subscription) onListen, void Function(StreamSubscription<T> subscription) onCancel}) {
    this.stream.asBroadcastStream(onListen: onListen, onCancel: onCancel);
    return this;
  }

  @override
  Stream<E> asyncExpand<E>(Stream<E> Function(T event) convert) {
    return this.stream.asyncExpand(convert);
  }

  @override
  Stream<E> asyncMap<E>(FutureOr<E> Function(T event) convert) {
    return this.stream.asyncMap(convert);
  }

  @override
  Stream<R> cast<R>() {
    throw "not implement";
  }

  @override
  Future close() {
    return this.sink.close();
  }

  @override
  Future<bool> contains(Object needle) {
    return this.stream.contains(needle);
  }

  @override
  Stream<T> distinct([bool Function(T previous, T next) equals]) {
    this.stream.distinct(equals);
    return this;
  }

  @override
  Future get done => this.sink.done;

  @override
  Future<E> drain<E>([E futureValue]) {
    return this.stream.drain(futureValue);
  }

  @override
  Future<T> elementAt(int index) {
    return this.stream.elementAt(index);
  }

  @override
  Future<bool> every(bool Function(T element) test) {
    return this.stream.every(test);
  }

  @override
  Stream<S> expand<S>(Iterable<S> Function(T element) convert) {
    return this.stream.expand(convert);
  }

  @override
  Future<T> get first => this.stream.first;

  @override
  Future<T> firstWhere(bool Function(T element) test, {T Function() orElse}) {
    return this.stream.firstWhere(test);
  }

  @override
  Future<S> fold<S>(S initialValue, S Function(S previous, T element) combine) {
    return this.stream.fold(initialValue, combine);
  }

  @override
  Future forEach(void Function(T element) action) {
    return this.stream.forEach(action);
  }

  @override
  Stream<T> handleError(Function onError, {bool test(error)}) {
    this.stream.handleError(onError, test: test);
    return this;
  }

  @override
  bool get isBroadcast => this.stream.isBroadcast;

  @override
  Future<bool> get isEmpty => this.stream.isEmpty;

  @override
  Future<String> join([String separator = ""]) {
    return this.stream.join(separator);
  }

  @override
  Future<T> get last => this.stream.last;

  @override
  Future<T> lastWhere(bool Function(T element) test, {T Function() orElse}) {
    return this.stream.lastWhere(test, orElse: orElse);
  }

  @override
  Future<int> get length => this.stream.length;

  @override
  StreamSubscription<T> listen(void Function(T event) onData, {Function onError, void Function() onDone, bool cancelOnError}) {
    return this.stream.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  Stream<S> map<S>(S Function(T event) convert) {
    return this.stream.map(convert);
  }

  @override
  Future pipe(StreamConsumer<T> streamConsumer) {
    return this.stream.pipe(streamConsumer);
  }

  @override
  Future<T> reduce(T Function(T previous, T element) combine) {
    return this.stream.reduce(combine);
  }

  @override
  Future<T> get single => this.stream.single;

  @override
  Future<T> singleWhere(bool Function(T element) test, {T Function() orElse}) {
    return this.stream.singleWhere(test, orElse: orElse);
  }

  @override
  Stream<T> skip(int count) {
    this.stream.skip(count);
    return this;
  }

  @override
  Stream<T> skipWhile(bool Function(T element) test) {
    this.stream.skipWhile(test);
    return this;
  }

  @override
  Stream<T> take(int count) {
    this.stream.take(count);
    return this;
  }

  @override
  Stream<T> takeWhile(bool Function(T element) test) {
    this.stream.takeWhile(test);
    return this;
  }

  @override
  Stream<T> timeout(Duration timeLimit, {void Function(EventSink<T> sink) onTimeout}) {
    this.stream.timeout(timeLimit, onTimeout: onTimeout);
    return this;
  }

  @override
  Future<List<T>> toList() {
    return this.stream.toList();
  }

  @override
  Future<Set<T>> toSet() {
    return this.stream.toSet();
  }

  @override
  Stream<S> transform<S>(StreamTransformer<T, S> streamTransformer) {
    return this.stream.transform(streamTransformer);
  }

  @override
  Stream<T> where(bool Function(T event) test) {
    this.stream.where(test);
    return this;
  }

  @override
  String toString() {
    return objectInfo(this.stream);
  }
}
