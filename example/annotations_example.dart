import 'package:dart_annotations/dart_annotations.dart';

Future<void> main() async {
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

  // 6. The lint should highlight the call to `doSomethingAsync()` and indicate that it may throw a `FormatException`.
  doSomethingAsync();

  // 7. The lint should not highlight the call to `doSomethingAsync()` inside the `catchError` block, since the exception is being caught.
  doSomethingAsync().catchError((e) {
    print('Caught an exception: $e');
  });

  try {
    // 8. The lint should highlight the call to `doSomethingAsync()` inside the `try` block is not awaited.
    doSomethingAsync();
  } catch (e) {
    print('Caught an exception: $e');
  }

  try {
    // 9. The lint should not highlight the call to `doSomethingAsync()` inside the `try` block, since the exception is being caught.
    await doSomethingAsync();
  } catch (e) {
    print('Caught an exception: $e');
  }

  // 10. The lint should not highlight the call to `doSomethingAsync()` inside the `then` block, since the exception is being caught.
  doSomethingAsync()
      .then((_) {
        print('doSomethingAsync completed successfully');
      })
      .catchError((e) {
        print('Caught an exception: $e');
      });

  // 11. The lint should not highlight the call to `doSomethingAsync()` inside the `whenComplete` block, since the exception is being caught.
  doSomethingAsync()
      .whenComplete(() {
        print('doSomethingAsync completed');
      })
      .catchError((e) {
        print('Caught an exception: $e');
      });
}

@Throws({FormatException})
void doSomething() {
  throw FormatException();
}

@Throws({FormatException})
Future<void> doSomethingAsync() async {
  throw FormatException();
}
