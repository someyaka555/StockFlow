import 'package:flutter/material.dart';
import '../../core/helpers.dart';
import '../../core/ui_helpers.dart';
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
    try { _items = await _repo.getAll(); } catch (_) {}
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
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final p = _items[i];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p.nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text(p.deskripsi, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _buildBadge('${Helpers.formatNumber(p.kg)} kg', Colors.orange),
                                      _buildBadge('Rp ${Helpers.formatNumber(p.harga)}', Colors.green),
                                      _buildBadge('Stok: ${p.stokTotal}', Colors.blue),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue, size: 28),
                                  onPressed: () => _showFormDialog(product: p),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red, size: 28),
                                  onPressed: () => _deleteProduct(p),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.5))),
      child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Future<void> _deleteProduct(ProductModel p) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Yakin ingin menghapus ${p.nama}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true && p.id != null) {
      await _repo.delete(p.id!);
      _load();
      if (mounted) AppSnackBar.success(context, 'Produk berhasil dihapus');
    }
  }

  Future<void> _showFormDialog({ProductModel? product}) async {
    final n = TextEditingController(text: product?.nama ?? '');
    final d = TextEditingController(text: product?.deskripsi ?? '');
    final kg = TextEditingController(text: product != null ? Helpers.formatNumber(product.kg) : '');
    final h = TextEditingController(text: product != null ? Helpers.formatNumber(product.harga) : '');
    final s = TextEditingController(text: product?.stokTotal.toString() ?? '');

    await showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(product == null ? 'Tambah Produk' : 'Edit Produk', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const SizedBox(height: 20),
                TextField(controller: n, decoration: const InputDecoration(labelText: 'Nama Produk')),
                const SizedBox(height: 12),
                TextField(controller: d, decoration: const InputDecoration(labelText: 'Deskripsi')),
                const SizedBox(height: 12),
                TextField(controller: kg, keyboardType: TextInputType.number, inputFormatters: [ThousandsFormatter()], decoration: const InputDecoration(labelText: 'Berat (Kg)')),
                const SizedBox(height: 12),
                TextField(controller: h, keyboardType: TextInputType.number, inputFormatters: [ThousandsFormatter()], decoration: const InputDecoration(labelText: 'Harga (Rp)')),
                const SizedBox(height: 12),
                TextField(controller: s, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Stok Saat Ini')),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        if (n.text.isEmpty) return;
                        final model = ProductModel(
                          id: product?.id, nama: n.text.trim(), deskripsi: d.text.trim(),
                          kg: Helpers.parseNumber(kg.text), harga: Helpers.parseNumber(h.text), stokTotal: int.tryParse(s.text) ?? 0,
                        );
                        if (product == null) { await _repo.create(model); } else { await _repo.update(model); }
                        if (mounted) Navigator.pop(context);
                        _load();
                        if (mounted) AppSnackBar.success(context, 'Produk berhasil disimpan');
                      },
                      child: const Text('Simpan'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}