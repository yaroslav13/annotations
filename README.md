# Annotations

A comprehensive Dart analyzer plugin that provides powerful annotations and static analysis rules for them. 

## Features

- `@Throws`: Declare the exceptions that a function can throw, enabling better documentation and static analysis of error handling.

## Installation

Add this package as a dependency:

```yaml
dependencies:
  annotations: ^1.0.0
```

## Usage

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
```

## Configuration

The plugin provides the `handle_throwing_invocations` lint rule. You can configure it in your `analysis_options.yaml`:

```yaml
analyzer:
  plugins:
    - annotations

linter:
  rules:
    handle_throwing_invocations: true
```

## Best Practices

1. **Be Specific**: Declare the exact exception types that can be thrown
2. **Document Exceptions**: Use the annotation as documentation for API consumers
3. **Consistent Usage**: Apply `@Throws` consistently across your codebase
4. **Error Hierarchies**: Consider using exception hierarchies for better categorization

```dart
// Good: Specific exception types
@Throws({ValidationError, NetworkError})
Future<User> fetchUser(String id) async { /* ... */ }

// Avoid: Too generic
@Throws({Exception})
Future<User> fetchUser(String id) async { /* ... */ }
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the BSD-3-Clause License - see the [LICENSE](LICENSE) file for details.

