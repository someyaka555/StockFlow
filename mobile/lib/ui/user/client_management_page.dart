import 'package:flutter/material.dart';
import '../../data/models/client.dart';
import '../../data/repositories/client_repository.dart';

class ClientManagementPage extends StatefulWidget {
  const ClientManagementPage({super.key});
  @override
  State<ClientManagementPage> createState() => _ClientManagementPageState();
}

class _ClientManagementPageState extends State<ClientManagementPage> {
  final _repo = ClientRepository();
  List<ClientModel> _items = [];
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
      appBar: AppBar(title: const Text('Kelola Client (Pembeli)')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Client'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(child: Text('Belum ada data client'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final c = _items[i];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.storefront),
                        title: Text(c.nama),
                        subtitle: Text('${c.alamat} • ${c.kontak}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showEditDialog(c),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                if (c.id == null) return;
                                await _repo.delete(c.id!);
                                _load();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Future<void> _showAddDialog() async {
    final n = TextEditingController();
    final a = TextEditingController();
    final k = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tambah Client'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: n, decoration: const InputDecoration(labelText: 'Nama Client')),
              const SizedBox(height: 12),
              TextField(controller: a, decoration: const InputDecoration(labelText: 'Alamat')),
              const SizedBox(height: 12),
              TextField(controller: k, decoration: const InputDecoration(labelText: 'Kontak/No HP')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              if (n.text.isEmpty) return;
              await _repo.create(ClientModel(
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

  Future<void> _showEditDialog(ClientModel c) async {
    final n = TextEditingController(text: c.nama);
    final a = TextEditingController(text: c.alamat);
    final k = TextEditingController(text: c.kontak);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Client'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: n, decoration: const InputDecoration(labelText: 'Nama Client')),
              const SizedBox(height: 12),
              TextField(controller: a, decoration: const InputDecoration(labelText: 'Alamat')),
              const SizedBox(height: 12),
              TextField(controller: k, decoration: const InputDecoration(labelText: 'Kontak/No HP')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              if (n.text.isEmpty) return;
              await _repo.update(ClientModel(
                id: c.id,
                nama: n.text.trim(),
                alamat: a.text.trim(),
                kontak: k.text.trim(),
              ));
              if (mounted) Navigator.pop(context);
              _load();
            },
            child: const Text('Simpan Perubahan'),
          ),
        ],
      ),
    );
  }
}