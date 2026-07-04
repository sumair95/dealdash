import 'package:flutter/material.dart';

class SocialAuthButtons extends StatelessWidget {
  const SocialAuthButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.g_mobiledata, size: 28),
          label: const Text('Continue with Google'),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          onPressed: () {},
          icon: const Icon(Icons.apple),
          label: const Text('Continue with Apple'),
        ),
      ],
    );
  }
}
