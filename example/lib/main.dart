import 'package:flutter/material.dart';
import 'package:getdate_textfield/getdate_textfield.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GetDate TextField Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const DateFieldShowcase(),
    );
  }
}

class DateFieldShowcase extends StatefulWidget {
  const DateFieldShowcase({super.key});

  @override
  State<DateFieldShowcase> createState() => _DateFieldShowcaseState();
}

class _DateFieldShowcaseState extends State<DateFieldShowcase> {
  // Controller 1: Basic usage
  late final DateFieldController basicController;

  // Controller 2: Advanced styling
  late final DateFieldController styledController;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();

    basicController = DateFieldController(
      firstDate: today.subtract(const Duration(days: 365 * 10)), // 10 years ago
      lastDate: today.add(const Duration(days: 365 * 10)), // 10 years ahead
      initialValue: today,
    );

    styledController = DateFieldController(
      firstDate: DateTime(1900),
      lastDate: today,
    );
  }

  @override
  void dispose() {
    basicController.dispose();
    styledController.dispose();
    super.dispose();
  }

  void _showCurrentValue(DateFieldController controller, String name) {
    final value = controller.value;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value != null
              ? '$name current value: ${value.toLocal().toString().split(' ')[0]}'
              : '$name is empty or invalid.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DateField Showcase'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Usage',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('A standard date field with default styling.'),
            const SizedBox(height: 16),

            DateField(
              controller: basicController,
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () => basicController.setValue(null),
                  child: const Text('Reset'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () =>
                      _showCurrentValue(basicController, 'Basic Field'),
                  child: const Text('Print Value'),
                ),
              ],
            ),

            const Divider(height: 60),

            const Text(
              'Custom Styling',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
                'A customized field with clear icon, borders, and custom colors.'),
            const SizedBox(height: 16),

            DateField(
              controller: styledController,
              decorationConfig: const DateFieldDecorationConfig(
                hint: 'Date of Birth',
                clear: true,
                radius: 12,
                colors: DateFieldColors(
                  focusedBorderColor: Colors.deepPurple,
                  labelColor: Colors.deepPurple,
                  hintColor: Colors.grey,
                ),
              ),
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () => styledController.setValue(DateTime(2000)),
                  child: const Text('Force 01/01/2000'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () =>
                      _showCurrentValue(styledController, 'Styled Field'),
                  child: const Text('Print Value'),
                ),
              ],
            ),

            // Extra spacing at the bottom to allow the overlay to open downwards
            // if the user scrolls all the way down.
            const SizedBox(height: 300),
          ],
        ),
      ),
    );
  }
}
