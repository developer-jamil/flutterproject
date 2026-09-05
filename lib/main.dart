import 'package:flutter/material.dart';

import 'api_result.dart';

void main() {
  runApp(const MyApp());
}

// =========================
// App
// =========================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ApiResultDemo(),
    );
  }
}

// =========================
// Screen
// =========================
class ApiResultDemo extends StatefulWidget {
  const ApiResultDemo({super.key});

  @override
  State<ApiResultDemo> createState() => _ApiResultDemoState();
}

class _ApiResultDemoState extends State<ApiResultDemo> {
  ApiResult<String> result = const Loading();

  void showLoading() {
    setState(() {
      result = const Loading();
    });
  }

  void showSuccess() {
    setState(() {
      result = const Success('Jamil data loaded successfully!');
    });
  }

  void showFailure() {
    setState(() {
      result = const Failure('Something went wrong!');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ApiResult Demo'),
      ),

      body: Center(
        child: buildResultUI(result),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: showLoading,
                child: const Text('Loading'),
              ),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: ElevatedButton(
                onPressed: showSuccess,
                child: const Text('Success'),
              ),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: ElevatedButton(
                onPressed: showFailure,
                child: const Text('Failure'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


  // =========================
  // Switch + UI
  // =========================
  Widget buildResultUI(ApiResult<String> result) {
    return switch (result) {
      Loading() => const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading...'),
        ],
      ),

      Success(:final data) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, size: 70, color: Colors.green),
          const SizedBox(height: 16),
          Text(data, textAlign: TextAlign.center),
        ],
      ),

      Failure(:final message) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error, size: 70, color: Colors.red),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    };
  }
