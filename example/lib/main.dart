import 'package:flutter/material.dart';
import 'package:getdate_textfield/getdate_textfield.dart';

final DateTime startDate = DateTime.now();
final DateTime maxGlobalDate = startDate.add(const Duration(days: 3650));
final DateTime minGlobalDate = startDate.subtract(const Duration(days: 3650));

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DateFieldController controller1 = DateFieldController(
    firstDate: minGlobalDate,
    lastDate: maxGlobalDate,
    initialValue: startDate,
  );

  final DateFieldController controller2 = DateFieldController(
    firstDate: minGlobalDate,
    lastDate: maxGlobalDate,
  );

  @override
  void initState() {
    super.initState();
  }

  void reset1() {
    controller1.setValue(null);
  }

  void force1() {
    controller1.setValue(startDate.add(const Duration(days: 2)));
  }

  void print1() {
    debugPrint(controller1.value.toString());
    debugPrint(controller1.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 70),
              DateField(
                controller: controller1,
                decorationConfig: const DateFieldDecorationConfig(
                  hint: 'Date 1',
                  width: 120,
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: reset1,
                child: const Text('Reset value 1'),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: force1,
                child: const Text('Force value 1'),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: print1,
                child: const Text('print current value 1'),
              ),
              const SizedBox(height: 20),
              DateField(
                controller: controller2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
