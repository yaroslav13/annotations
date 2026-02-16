import 'package:dart_annotations/dart_annotations.dart';

void main() {
  // 1. The lint should highlight the call to `doSomething()` and indicate that it may throw a `FormatException`.
  doSomething();

  try {
    // 2. The lint should not highlight the call to `doSomething()` inside the `try` block, since the exception is being caught.
    doSomething();
  } catch (e) {
    print('Caught an exception: $e');
  }

  try {
    // 3. The lint should not highlight the call to `doSomething()` inside the `try` block, since the exception is being caught.
    doSomething();
  } on FormatException catch (e) {
    print('Caught a FormatException: $e');
  }

  try {
    // 4. The lint should not highlight the call to `doSomething()` inside the `try` block, since the exception is being caught.
    doSomething();
  } on Exception catch (e) {
    print('Caught an exception: $e');
  }

  try {
    // 5. the lint should highlight the call to `doSomething()` inside the `try` block, since the exception is not being caught.
    doSomething();
  } on StateError {
    print('Caught a FormatException');
  }
}

@Throws({FormatException})
void doSomething() {
  throw FormatException();
}
