import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class EmptyTasksWidget extends StatelessWidget {
  const EmptyTasksWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Lottie animation for empty state.
          Lottie.asset(
            'assets/imgs/empty_state.json',
            width: 250,
            height: 250,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          const Text(
            "No tasks for today!",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Tap the '+' button below to create a new task.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
