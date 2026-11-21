import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';

class VerifyPage extends StatefulWidget {
  const VerifyPage({super.key});
  @override
  State<VerifyPage> createState() => _VerifyPageState();
}

class _VerifyPageState extends State<VerifyPage> {
  final _code = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verifikasi Email')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text('Kami telah mengirimkan kode verifikasi ke email Anda.'),
            const SizedBox(height: 16),
            TextField(
              controller: _code, 
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Masukkan kode (Tester: ${AppConstants.mockOtpCode})'
              )
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_code.text == AppConstants.mockOtpCode) {
                  context.read<AuthProvider>().verifySuccess();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kode salah')));
                }
              },
              child: const Text('Verifikasi'),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Kode baru telah dikirim (Tester: ${AppConstants.mockOtpCode})'))
                );
              },
              child: const Text('Kirim Ulang Kode (Resend)'),
            )
          ],
        ),
      ),
    );
  }
}