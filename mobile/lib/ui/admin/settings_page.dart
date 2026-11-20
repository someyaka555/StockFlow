import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _url;
  bool _useApi = false;

  @override
  void initState() {
    super.initState();
    final s = context.read<SettingsProvider>();
    _url = TextEditingController(text: s.baseUrl);
    _useApi = s.useApi;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan API')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _url,
              decoration: const InputDecoration(
                labelText: 'Base URL API',
                hintText: 'http://10.0.2.2:3000/api',
              ),
            ),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Tips: emulator Android pakai 10.0.2.2, HP fisik pakai IP LAN server',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Gunakan API Server'),
              subtitle:
                  const Text('Matikan untuk mode tester (mock lokal)'),
              value: _useApi,
              onChanged: (v) => setState(() => _useApi = v),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await context
                      .read<SettingsProvider>()
                      .save(_url.text.trim(), _useApi);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pengaturan disimpan')),
                    );
                  }
                },
                child: const Text('Simpan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}