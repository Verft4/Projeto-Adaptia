import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Image(
            image: AssetImage('assets/images/logo_with_name.png'),
            width: 160,
            height: 160,
          ),
          const SizedBox(height: 28),
          Text(
            'Onde a educação e inclusão se encontram.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).colorScheme.onSurface
            ),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text(
                'Começar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)
              ),
            ),
          )
        ],
      ),
    );
  }
}