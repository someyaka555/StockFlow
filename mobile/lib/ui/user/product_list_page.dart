import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});
  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
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
      appBar: AppBar(title: const Text('Daftar Produk')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
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
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primary.withOpacity(0.15),
                            child: const Icon(Icons.inventory,
                                color: AppTheme.primary),
                          ),
                          title: Text(p.nama),
                          subtitle: Text('${p.kode} • ${p.satuan}'),
                          trailing: Text('${p.stokTotal}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}