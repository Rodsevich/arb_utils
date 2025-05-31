import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class HardcodedTextInWidgetLint extends DartLintRule {
  HardcodedTextInWidgetLint() : super(code: _code);

  static const _code = LintCode(
    name: 'hardcoded_text_in_widget',
    problemMessage: 'Avoid hardcoded text in widget build methods. Consider extracting to an ARB label.',
    correctionMessage: 'Try creating an ARB label named like YourWidgetName_text.',
    errorSeverity: ErrorSeverity.INFO, // Or WARNING
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addStringLiteral((node) {
      // Check if it's a simple string literal, not part of interpolation for now
      if (node.stringValue == null) return;
      if (node.stringValue!.isEmpty) return; // Ignore empty strings

      // Find the enclosing method declaration
      MethodDeclaration? method = node.thisOrAncestorOfType<MethodDeclaration>();
      if (method == null || method.name.lexeme != 'build') {
        return;
      }

      // Find the enclosing class declaration
      ClassDeclaration? classDecl = method.thisOrAncestorOfType<ClassDeclaration>();
      if (classDecl == null) {
        return;
      }

      // Check if the class is a Widget
      // This is a simplified check. A more robust check might involve resolving the type
      // and checking against `Widget`, `StatelessWidget`, `StatefulWidget`.
      // For now, we'll assume classes ending with 'Widget' or common Flutter widgets.
      // This part might need refinement.
      final className = classDecl.name.lexeme;
      bool isWidget = className.endsWith('Widget') ||
                       className.endsWith('Page') ||
                       className.endsWith('Screen') ||
                       className.endsWith('Dialog') ||
                       className.endsWith('View');
                       // Add more common suffixes if needed, or resolve type properly.

      if (!isWidget) {
        // A more robust check:
        // final classElement = classDecl.declaredElement;
        // if (classElement != null) {
        //   final type = classElement.thisType;
        //   // Check if type is subtype of Widget - requires more setup with resolver
        // }
        return;
      }

      // Suggest a label name
      final suggestedLabel = '${className}_text';
      // Update correction message with the specific name
      final specificCorrection = 'Try creating an ARB label named like ${suggestedLabel}.';


      reporter.reportErrorForNode(
        LintCode(
          name: _code.name,
          problemMessage: _code.problemMessage,
          correctionMessage: specificCorrection,
          errorSeverity: _code.errorSeverity,
          uniqueName: _code.uniqueName // Ensure uniqueName is passed if using a new LintCode instance
        ),
        node,
      );
    });
  }
}
