import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../data/models/client.dart';
import '../../data/models/product.dart';
import '../../data/models/stock_out.dart';
import '../../data/repositories/client_repository.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/stock_repository.dart';

class StockOutPage extends StatefulWidget {
  const StockOutPage({super.key});
  @override
  State<StockOutPage> createState() => _StockOutPageState();
}

class _StockOutPageState extends State<StockOutPage> {
  final _repo = StockRepository();
  DateTime _date = DateTime.now();
  List<StockOutModel> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _items = await _repo.getStockOutByDate(DateFormat('yyyy-MM-dd').format(_date));
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _date = picked;
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Barang Keluar')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today, size: 18),
              label: Text(DateFormat('EEEE, dd MMM yyyy').format(_date)),
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: Text('Belum ada barang keluar')),
              )
            else
              ..._items.map((it) => Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.danger.withOpacity(0.15),
                        child: const Icon(Icons.call_made, color: AppTheme.danger),
                      ),
                      title: Text(it.productNama),
                      subtitle: Text('Ke Client: ${it.clientNama}'),
                      trailing: Text('-${it.qty}',
                          style: const TextStyle(color: AppTheme.danger, fontWeight: FontWeight.bold)),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddDialog() async {
    final products = await ProductRepository().getAll();
    final clients = await ClientRepository().getAll();
    if (!mounted) return;
    if (products.isEmpty || clients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk/Client belum ada')),
      );
      return;
    }

    ProductModel? selProduct = products.first;
    ClientModel? selClient = clients.first;
    final qty = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tambah Barang Keluar'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<ProductModel>(
                value: selProduct,
                decoration: const InputDecoration(labelText: 'Produk'),
                items: products.map((p) => DropdownMenuItem(value: p, child: Text('${p.nama} (stok ${p.stokTotal})'))).toList(),
                onChanged: (v) => selProduct = v,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ClientModel>(
                value: selClient,
                decoration: const InputDecoration(labelText: 'Ke Client'),
                items: clients.map((c) => DropdownMenuItem(value: c, child: Text(c.nama))).toList(),
                onChanged: (v) => selClient = v,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: qty,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Qty'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final q = int.tryParse(qty.text);
              if (q == null || q <= 0) return;
              if (q > selProduct!.stokTotal) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Stok tidak cukup (tersisa ${selProduct!.stokTotal})')),
                );
                return;
              }
              final model = StockOutModel(
                clientId: selClient!.id!,
                clientNama: selClient!.nama,
                productId: selProduct!.id!,
                productNama: selProduct!.nama,
                qty: q,
                tanggal: DateFormat('yyyy-MM-dd').format(_date),
              );
              try {
                await _repo.addStockOut(model);
                if (mounted) Navigator.pop(context);
                _load();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}