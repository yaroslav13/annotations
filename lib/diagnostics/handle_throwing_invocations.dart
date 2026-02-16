import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/src/analysis_rule/rule_context.dart';

/// The diagnostic code for handle_throwing_invocations rule.
const _code = LintCode(
  'handle_throwing_invocations',
  'Unhandled exception from invocation annotated with @Throws.',
  correctionMessage:
      'Wrap the invocation in a try-catch block or '
      'handle the exception appropriately.',
);

/// A diagnostic rule that warns when code invokes declarations annotated
/// with `@Throws` without handling the potential exception.
///
/// The rule triggers when:
/// 1. An invocation targets a function/method/constructor/getter annotated
///    with `@Throws(...)`.
/// 2. The invocation is not considered "handled" (e.g., not inside a try-catch
///    that catches the declared exception types).
final class HandleThrowingInvocations extends AnalysisRule {
  HandleThrowingInvocations()
    : super(
        name: 'handle_throwing_invocations',
        description:
            'Warn when invoking functions annotated with @Throws without handling exceptions.',
      );

  @override
  DiagnosticCode get diagnosticCode => _code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final visitor = _Visitor(this);

    registry.addMethodInvocation(this, visitor);
    registry.addFunctionExpressionInvocation(this, visitor);
    registry.addInstanceCreationExpression(this, visitor);
    registry.addPropertyAccess(this, visitor);
    registry.addPrefixedIdentifier(this, visitor);
  }
}

final class _Visitor extends SimpleAstVisitor<void> {
  final HandleThrowingInvocations rule;

  _Visitor(this.rule);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final element = node.methodName.element;
    _checkInvocation(node, element);
  }

  @override
  void visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    final element = node.element;

    _checkInvocation(node, element);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final element = node.constructorName.element;

    _checkInvocation(node, element);
  }

  @override
  void visitPropertyAccess(PropertyAccess node) {
    final element = node.propertyName.element;

    if (element is GetterElement) {
      _checkInvocation(node, element);
    }
  }

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    final element = node.identifier.element;
    if (element is GetterElement) {
      _checkInvocation(node, element);
    }
  }

  void _checkInvocation(AstNode node, Element? element) {
    if (element == null) return;

    // Check if the element has a @Throws annotation
    final throwsAnnotation = _getThrowsAnnotation(element);
    if (throwsAnnotation == null) return;

    // Get the exception types from the annotation
    final exceptionTypes = _getExceptionTypes(throwsAnnotation);

    // Check if the invocation is handled
    if (_isInvocationHandled(node, exceptionTypes)) return;

    // Check if the containing function also declares @Throws with the same types
    if (_isContainingFunctionAnnotatedWithThrows(node, exceptionTypes)) return;

    // Report the diagnostic
    rule.reportAtNode(node);
  }

  /// Gets the @Throws annotation from the element if present.
  ElementAnnotation? _getThrowsAnnotation(Element element) {
    for (final annotation in element.metadata.annotations) {
      final annotationElement = annotation.element;
      if (annotationElement == null) continue;

      // Get the class element of the annotation
      Element? classElement;
      if (annotationElement is ConstructorElement) {
        classElement = annotationElement.enclosingElement;
      } else if (annotationElement is GetterElement) {
        final returnType = annotationElement.returnType;
        if (returnType is InterfaceType) {
          classElement = returnType.element;
        }
      }

      if (classElement == null) continue;

      // Check if this is the Throws annotation
      if (classElement.name == 'Throws') {
        return annotation;
      }
    }
    return null;
  }

  /// Extracts the exception types from the @Throws annotation.
  /// Returns an empty list if types cannot be extracted.
  List<DartType> _getExceptionTypes(ElementAnnotation annotation) {
    final constantValue = annotation.computeConstantValue();
    if (constantValue == null) return [];

    final exceptionsField = constantValue.getField('exceptions');
    if (exceptionsField == null || exceptionsField.isNull) return [];

    final setElements = exceptionsField.toSetValue();
    if (setElements == null) return [];

    final types = <DartType>[];
    for (final element in setElements) {
      final typeValue = element.toTypeValue();
      if (typeValue != null) {
        types.add(typeValue);
      }
    }

    return types;
  }

  /// Checks if the invocation is inside a try-catch that can handle the exception.
  bool _isInvocationHandled(AstNode node, List<DartType> exceptionTypes) {
    AstNode? current = node;

    while (current != null) {
      if (current is TryStatement) {
        // Check if we're inside the try block (not in catch/finally)
        if (_isNodeInTryBlock(node, current)) {
          // Check if any catch clause can handle the exception
          if (_canCatchClausesHandle(current.catchClauses, exceptionTypes)) {
            return true;
          }
        }
      }
      current = current.parent;
    }

    return false;
  }

  /// Checks if the node is inside the try block of the TryStatement.
  bool _isNodeInTryBlock(AstNode node, TryStatement tryStatement) {
    final tryBlock = tryStatement.body;
    return node.offset >= tryBlock.offset && node.end <= tryBlock.end;
  }

  /// Checks if the catch clauses can handle the given exception types.
  bool _canCatchClausesHandle(
    List<CatchClause> catchClauses,
    List<DartType> exceptionTypes,
  ) {
    for (final catchClause in catchClauses) {
      final exceptionType = catchClause.exceptionType;

      // Generic catch (no type specified) catches everything
      if (exceptionType == null) {
        return true;
      }

      // Get the type from the catch clause
      final catchType = exceptionType.type;
      if (catchType == null) continue;

      // If no exception types are specified in @Throws, treat generic handlers as handling
      if (exceptionTypes.isEmpty) {
        // Generic Exception or Object handlers are considered as handling
        if (_isGenericExceptionType(catchType)) {
          return true;
        }
      }

      // Check if the catch clause can handle any of the declared exception types
      for (final thrownType in exceptionTypes) {
        if (_canTypeHandle(catchType, thrownType)) {
          return true;
        }
      }

      // If catch type is Object or Exception, it handles everything
      if (_isGenericExceptionType(catchType)) {
        return true;
      }
    }

    // If no exception types are declared but there are catch clauses, we can't know
    // for sure, so be conservative and treat as handled if there's any catch clause
    if (exceptionTypes.isEmpty && catchClauses.isNotEmpty) {
      return true;
    }

    return false;
  }

  /// Checks if a catch type can handle the thrown type.
  bool _canTypeHandle(DartType catchType, DartType thrownType) {
    // Check if types are the same or if catch type is a supertype
    if (catchType == thrownType) return true;

    // Check by name for simplicity (more robust would be subtype checking)
    final catchElement = catchType.element;
    final thrownElement = thrownType.element;

    if (catchElement == null || thrownElement == null) return false;

    // Same type
    if (catchElement.name == thrownElement.name) return true;

    // Check if catchType is a supertype of thrownType
    if (thrownType is InterfaceType) {
      // Check all supertypes
      for (final supertype in thrownType.allSupertypes) {
        if (supertype.element.name == catchElement.name) {
          return true;
        }
      }
    }

    return false;
  }

  /// Checks if the type is a generic exception handler type (Object, Exception, Error).
  bool _isGenericExceptionType(DartType type) {
    final element = type.element;
    if (element == null) return false;

    final name = element.name;
    return name == 'Object' || name == 'Exception' || name == 'Error';
  }

  /// Checks if the containing function is also annotated with @Throws
  /// with the same exception types (indicating the exception is forwarded).
  bool _isContainingFunctionAnnotatedWithThrows(
    AstNode node,
    List<DartType> exceptionTypes,
  ) {
    // Find the containing function/method
    AstNode? current = node;
    while (current != null) {
      if (current is FunctionDeclaration) {
        final element = current.declaredFragment?.element;
        if (element != null) {
          return _elementDeclaresThrowsForTypes(element, exceptionTypes);
        }
      } else if (current is MethodDeclaration) {
        final element = current.declaredFragment?.element;
        if (element != null) {
          return _elementDeclaresThrowsForTypes(element, exceptionTypes);
        }
      }
      current = current.parent;
    }
    return false;
  }

  /// Checks if the element has @Throws annotation that covers the given types.
  bool _elementDeclaresThrowsForTypes(
    Element element,
    List<DartType> exceptionTypes,
  ) {
    final throwsAnnotation = _getThrowsAnnotation(element);
    if (throwsAnnotation == null) return false;

    // If the containing function has @Throws, it's declaring that it may throw
    final declaredTypes = _getExceptionTypes(throwsAnnotation);

    // If no specific types in either, treat as covered
    if (exceptionTypes.isEmpty || declaredTypes.isEmpty) return true;

    // Check if all exception types are covered
    for (final exceptionType in exceptionTypes) {
      bool covered = false;
      for (final declaredType in declaredTypes) {
        if (_canTypeHandle(declaredType, exceptionType)) {
          covered = true;
          break;
        }
      }
      if (!covered) return false;
    }

    return true;
  }
}
