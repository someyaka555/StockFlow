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
        onPressed: () => _showFormDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Produk'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(child: Text('Belum ada produk'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final p = _items[i];
                    return Card(
                      child: ListTile(
                        title: Text(p.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${p.deskripsi}\n${p.kg} kg / ${p.satuan} • Rp ${p.harga}'),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showFormDialog(product: p),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Konfirmasi Hapus'),
                                    content: Text('Yakin ingin menghapus ${p.nama}?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
                                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
                                    ],
                                  ),
                                );
                                if (confirm == true && p.id != null) {
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

  Future<void> _showFormDialog({ProductModel? product}) async {
    final n = TextEditingController(text: product?.nama ?? '');
    final d = TextEditingController(text: product?.deskripsi ?? '');
    final kg = TextEditingController(text: product?.kg.toString() ?? '0');
    final sat = TextEditingController(text: product?.satuan ?? 'pcs');
    final h = TextEditingController(text: product?.harga.toString() ?? '0');
    final s = TextEditingController(text: product?.stokTotal.toString() ?? '0');

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(product == null ? 'Tambah Produk' : 'Edit Produk'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: n, decoration: const InputDecoration(labelText: 'Nama Produk')),
              const SizedBox(height: 12),
              TextField(controller: d, decoration: const InputDecoration(labelText: 'Deskripsi')),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: TextField(controller: kg, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Berat (Kg)'))),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: sat, decoration: const InputDecoration(labelText: 'Satuan (pcs/sak)'))),
                ],
              ),
              const SizedBox(height: 12),
              TextField(controller: h, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Harga')),
              const SizedBox(height: 12),
              TextField(controller: s, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Stok Awal')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              if (n.text.isEmpty) return;
              final model = ProductModel(
                id: product?.id,
                nama: n.text.trim(),
                deskripsi: d.text.trim(),
                kg: double.tryParse(kg.text) ?? 0,
                satuan: sat.text.trim(),
                harga: double.tryParse(h.text) ?? 0,
                stokTotal: int.tryParse(s.text) ?? 0,
              );
              
              if (product == null) {
                await _repo.create(model);
              } else {
                await _repo.update(model);
              }
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