import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _newPass = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil Saya')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Foto Profil & Upload
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    child: const Icon(Icons.person, size: 60, color: Colors.grey),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.blue,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur upload foto (Simulasi)')));
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // ID Account
            Text('ID: ${user?.id ?? '-'}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            // Username & Email
            Text(user?.username ?? '-', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(user?.email ?? '-', style: const TextStyle(color: Colors.grey)),
            
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            
            // Ganti Sandi
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Ganti Sandi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _newPass,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Sandi Baru', prefixIcon: Icon(Icons.lock_outline)),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sandi berhasil diubah (Simulasi)')));
                  _newPass.clear();
                },
                child: const Text('Simpan Sandi Baru'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}