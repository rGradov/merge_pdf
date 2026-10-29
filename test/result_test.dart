import 'package:flutter_test/flutter_test.dart';
import 'package:merge_pdf/utils/utils.dart';

void main() {
  test('Success holds its value', () {
    final result = Result.success(42);
    expect(result, isA<Success<int>>());
    expect(result.isSuccess, isTrue);
    expect((result as Success<int>).value, 42);
  });

  test('Failure carries the error key', () {
    final result = Result.failure<String>(Exception('no_file'));
    expect(result, isA<Failure<String>>());
    expect((result as Failure<String>).error.toString(), contains('no_file'));
  });
}
