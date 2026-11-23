import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/ui_helpers.dart';
import '../../providers/auth_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _newPass = TextEditingController();
  final _confirmPass = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final cleanUsername = (user?.username ?? '-').replaceAll(' ', '');

    return Scaffold(
      appBar: AppBar(title: const Text('Profil Saya')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
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
                        onPressed: () => AppSnackBar.success(context, 'Fitur upload foto (Simulasi)'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            _buildReadOnlyField('ID Account', user?.id ?? '-'),
            const SizedBox(height: 16),
            _buildReadOnlyField('Email', user?.email ?? '-'),
            const SizedBox(height: 16),
            _buildReadOnlyField('Username', cleanUsername),
            
            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 20),
            
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Ganti Sandi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPass,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password', prefixIcon: Icon(Icons.lock_outline)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPass,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm Password', prefixIcon: Icon(Icons.lock_outline)),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : () async {
                  if (_newPass.text.isEmpty || _newPass.text != _confirmPass.text) {
                    AppSnackBar.error(context, 'Sandi baru tidak cocok atau kosong!');
                    return;
                  }
                  setState(() => _loading = true);
                  final err = await context.read<AuthProvider>().changePassword(_newPass.text);
                  if (mounted) {
                    setState(() => _loading = false);
                    if (err == null) {
                      AppSnackBar.success(context, 'Sandi berhasil diubah!');
                      _newPass.clear();
                      _confirmPass.clear();
                    } else {
                      AppSnackBar.error(context, err);
                    }
                  }
                },
                child: _loading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Simpan Sandi Baru'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}