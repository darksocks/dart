import 'package:darksocks/src/ds.dart';
import 'package:test/test.dart';

void main() {
  group('ds', () {
    setUp(() {});

    tearDown(() async {});

    test('test read writer', () async {
      var stream = Stream<List<int>>.fromIterable([
        [1, 2, 3],
        [1, 2, 3, 4]
      ]);
      await for (var data in stream.transform(CmdWriter()).transform(CmdReader())) {
        print("receive $data");
      }
    });
  });
}
