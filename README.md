# Annotations

A comprehensive Dart analyzer plugin that provides powerful annotations and static analysis rules for them.

## Annotations

- `@Throws`: Declare the exceptions that a function can throw, enabling better documentation and static analysis of error handling.

## Rules

- `handle_throwing_invocations`: Ensures that any function that calls a function annotated with `@Throws` either catches the declared exceptions or also declares them with `@Throws`.

## Installation

Add this package as a dependency:

```yaml
dependencies:
  dart_annotations: ^1.0.6
```

## Configuration

You can configure it in your `analysis_options.yaml`:

```yaml
plugins:
  dart_annotations:
    version: ^1.0.6
    diagnostics:
      handle_throwing_invocations: true
```

## Usage

### Basic Usage

```dart
@Throws({CustomException})
void riskyFunction() { /* ... */ }

// ✅ Specific exception type
try {
  riskyFunction();
} on CustomException catch (e) {
  // handle
}

// ✅ General Exception catch
try {
  riskyFunction();
} on Exception catch (e) {
  // handle
}

// ✅ Catch-all
try {
  riskyFunction();
} catch (e) {
  // handle
}

// ✅ Rethrowing with @Throws
@Throws({CustomException})
void callerFunction() {
  riskyFunction(); // OK because caller also declares @Throws
}

// ❌ Not declaring @Throws in caller
void anotherCallerFunction() {
    riskyFunction(); // Warning: callerFunction should declare @Throws
}

// ❌ Wrong exception type caught
try {
  riskyFunction();
} on StateError catch (e) {
  // This doesn't catch CustomException!
  // Warning: Unhandled exception from invocation annotated with @Throws
}
```

### Async Functions

```dart
@Throws({CustomException})
Future<void> riskyAsyncFunction() async { /* ... */ }

// ✅ Awaited call inside try-catch
try {
  await riskyAsyncFunction();
} catch (e) {
  // handle
}

// ✅ Using .catchError()
riskyAsyncFunction().catchError((e) {
  // handle
});

// ✅ Using .then() with onError
riskyAsyncFunction().then((_) {
  // success
}, onError: (e) {
  // handle
});

// ✅ Chained .then().catchError()
riskyAsyncFunction()
  .then((_) => print('success'))
  .catchError((e) => print('error'));

// ❌ Non-awaited call - try-catch won't catch async exceptions!
try {
  riskyAsyncFunction(); // Warning: async call not awaited
} catch (e) {
  // This won't catch the exception!
}

// ❌ Unhandled async call
riskyAsyncFunction(); // Warning: Unhandled exception
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

