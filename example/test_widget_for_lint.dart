import 'package:flutter/material.dart';

class MyTestWidget extends StatelessWidget {
  const MyTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('This is a hardcoded string.'), // Expect lint here
        const Text('Another hardcoded string here.'), // Expect lint here
        Text('Hello ' + 'World'), // Expect lint for 'Hello World'
        const Text(''), // Should be ignored by the lint
        Text('Value: \${1 + 2}'), // String interpolation, might be ignored by current simple check, or linted. Let's see.
                                 // The current lint logic `node.stringValue == null` check should ignore this.
      ],
    );
  }
}

class NotAWidget {
  void build() {
    // ignore: unused_local_variable
    String test = 'This should not trigger the lint.';
  }
}

class AnotherTestScreen extends StatefulWidget {
  const AnotherTestScreen({super.key});

  @override
  State<AnotherTestScreen> createState() => _AnotherTestScreenState();
}

class _AnotherTestScreenState extends State<AnotherTestScreen> {
  @override
  Widget build(BuildContext context) {
    return const Text('Stateful widget hardcoded text.'); // Expect lint here
  }
}
