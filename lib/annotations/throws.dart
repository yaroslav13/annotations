/// Annotation that declares a function, method, constructor, or getter
/// may throw one or more exceptions at runtime.
///
/// This annotation is intended to be enforced by the `annotations` analyzer
/// plugin, which provides the `handle_throwing_invocations` lint rule.
///
/// **Usage:**
/// ```dart
/// @Throws({FormatException})
/// void parseData(String input) {
///   // may throw FormatException
/// }
///
/// @Throws({MyDomainError, StateError})
/// Future<void> processData() async {
///   // may throw MyDomainError or StateError
/// }
/// ```
///
/// **Note:** This annotation does not change runtime semantics. It is purely
/// a static analysis hint to help developers handle potential exceptions.
///
/// When a function annotated with `@Throws` is called, the analyzer plugin
/// will warn if the call is not wrapped in an appropriate try-catch block
/// or otherwise handled.
final class Throws {
  /// Creates a [Throws] annotation with the given set of exception types.
  ///
  /// The [exceptions] parameter should contain the types of exceptions that
  /// the annotated declaration may throw.
  const Throws(this.exceptions);

  /// The set of exception types that may be thrown by the annotated declaration.
  final Set<Type> exceptions;
}
