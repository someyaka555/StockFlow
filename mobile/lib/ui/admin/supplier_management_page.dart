import 'package:flutter/material.dart';
import '../../data/models/supplier.dart';
import '../../data/repositories/supplier_repository.dart';

class SupplierManagementPage extends StatefulWidget {
  const SupplierManagementPage({super.key});
  @override
  State<SupplierManagementPage> createState() =>
      _SupplierManagementPageState();
}

class _SupplierManagementPageState extends State<SupplierManagementPage> {
  final _repo = SupplierRepository();
  List<SupplierModel> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _items = await _repo.getAll();
    } catch (_) {}
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Supplier')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAdd,
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final s = _items[i];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.local_shipping),
                    title: Text(s.nama),
                    subtitle: Text('${s.alamat} • ${s.kontak}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        if (s.id == null) return;
                        await _repo.delete(s.id!);
                        _load();
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _showAdd() async {
    final n = TextEditingController();
    final a = TextEditingController();
    final k = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tambah Supplier'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: n,
                  decoration: const InputDecoration(labelText: 'Nama')),
              const SizedBox(height: 12),
              TextField(
                  controller: a,
                  decoration:
                      const InputDecoration(labelText: 'Alamat')),
              const SizedBox(height: 12),
              TextField(
                  controller: k,
                  decoration:
                      const InputDecoration(labelText: 'Kontak')),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              if (n.text.isEmpty) return;
              await _repo.create(SupplierModel(
                nama: n.text.trim(),
                alamat: a.text.trim(),
                kontak: k.text.trim(),
              ));
              if (mounted) Navigator.pop(context);
              _load();
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}