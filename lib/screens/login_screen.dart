import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_providers.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authRepo = ref.read(authRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('ログイン')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'DIY Partnerへようこそ',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 48),

              // Google Login Button
              ElevatedButton.icon(
                onPressed: () async {
                  await authRepo.signInWithGoogle();
                },
                icon: const Icon(Icons.g_mobiledata, size: 32),
                label: const Text('Googleでログイン'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 2,
                ),
              ),

              const SizedBox(height: 32),
              TextButton(
                onPressed: () {
                  context.push('/signup');
                },
                child: const Text('アカウントをお持ちでない方はこちら（新規登録）'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
