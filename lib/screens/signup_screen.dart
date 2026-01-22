import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';

class SignupScreen extends ConsumerWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authRepo = ref.read(authRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('新規登録')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'アカウントを作成',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'GoogleまたはAppleアカウントを使って\n簡単に登録できます',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 48),

              // Google Sign Up Button
              ElevatedButton.icon(
                onPressed: () async {
                  await authRepo.signInWithGoogle();
                  if (context.mounted && Navigator.canPop(context)) {
                    Navigator.pop(context); // Go back or go home
                  }
                },
                icon: const Icon(Icons.g_mobiledata, size: 32),
                label: const Text('Googleで登録'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
