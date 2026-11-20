import 'package:flutter/material.dart';
import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';

class ProductManagementPage extends StatefulWidget {
  const ProductManagementPage({super.key});
  @override
  State<ProductManagementPage> createState() => _ProductManagementPageState();
}

class _ProductManagementPageState extends State<ProductManagementPage> {
  final _repo = ProductRepository();
  List<ProductModel> _items = [];
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
      appBar: AppBar(title: const Text('Kelola Produk')),
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
                final p = _items[i];
                return Card(
                  child: ListTile(
                    title: Text(p.nama),
                    subtitle:
                        Text('${p.kode} • ${p.satuan} • stok ${p.stokTotal}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showEditStock(p),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Hapus Produk'),
                                content: Text('Hapus ${p.nama}?'),
                                actions: [
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Batal')),
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Hapus')),
                                ],
                              ),
                            );
                            if (ok == true && p.id != null) {
                              await _repo.delete(p.id!);
                              _load();
                            }
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

  Future<void> _showAdd() async {
    final n = TextEditingController();
    final k = TextEditingController();
    final s = TextEditingController(text: '0');
    final sat = TextEditingController(text: 'pcs');

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tambah Produk'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: n,
                  decoration: const InputDecoration(labelText: 'Nama')),
              const SizedBox(height: 12),
              TextField(
                  controller: k,
                  decoration: const InputDecoration(labelText: 'Kode')),
              const SizedBox(height: 12),
              TextField(
                  controller: s,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Stok Awal')),
              const SizedBox(height: 12),
              TextField(
                  controller: sat,
                  decoration:
                      const InputDecoration(labelText: 'Satuan')),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              if (n.text.isEmpty || k.text.isEmpty) return;
              await _repo.create(ProductModel(
                nama: n.text.trim(),
                kode: k.text.trim(),
                stokTotal: int.tryParse(s.text) ?? 0,
                satuan: sat.text.trim().isEmpty ? 'pcs' : sat.text.trim(),
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

  Future<void> _showEditStock(ProductModel p) async {
    final c = TextEditingController(text: p.stokTotal.toString());
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Ubah Stok ${p.nama}'),
        content: TextField(
          controller: c,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Stok Total Baru'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final v = int.tryParse(c.text);
              if (v == null) return;
              await _repo.updateStock(p.id!, v);
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