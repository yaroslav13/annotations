import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';
import 'package:dart_annotations/diagnostics/handle_throwing_invocations.dart';

/// The plugin instance that the analysis server looks for.
///
/// This MUST be a top-level variable named `plugin`.
final plugin = DartAnnotationsPlugin();

/// The annotations analyzer plugin.
///
/// This plugin provides static analysis rules for the `@Throws` annotation,
/// warning developers when they call functions that may throw exceptions
/// without proper exception handling.
final class DartAnnotationsPlugin extends Plugin {
  @override
  String get name => 'dart_annotations';

  @override
  void register(PluginRegistry registry) {
    // Register the handle_throwing_invocations diagnostic rule
    registry.registerLintRule(HandleThrowingInvocations());
  }
}
