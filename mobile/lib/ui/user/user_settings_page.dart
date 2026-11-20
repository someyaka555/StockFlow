import 'package:flutter/material.dart';

class UserSettingsPage extends StatefulWidget {
  const UserSettingsPage({super.key});
  @override
  State<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  final _oldPass = TextEditingController();
  final _newPass = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan Sandi')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _oldPass, obscureText: true, decoration: const InputDecoration(labelText: 'Sandi Lama')),
            const SizedBox(height: 16),
            TextField(controller: _newPass, obscureText: true, decoration: const InputDecoration(labelText: 'Sandi Baru')),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sandi berhasil diubah (Simulasi)')));
                  Navigator.pop(context);
                },
                child: const Text('Simpan Perubahan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}