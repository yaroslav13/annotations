# 1.0.3

- Handle async functions and Future return types in the `handle_throwing_invocations` lint rule, ensuring that exceptions thrown from async functions are also properly handled.
- Bump dependencies and remove unnecessary ones.
- Make the Dart SDK constraints lower to allow for more compatibility with older versions of Dart.

# 1.0.2 

- Improve changelog docs

# 1.0.1

- Rename plugin to `dart_annotations` to avoid conflicts with other packages that might use the same name for their plugin.

## 1.0.0

- Add @Throws annotation and the corresponding lint rule `handle_throwing_invocations`
