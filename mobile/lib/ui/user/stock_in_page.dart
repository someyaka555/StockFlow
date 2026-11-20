import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../data/models/product.dart';
import '../../data/models/stock_in.dart';
import '../../data/models/supplier.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/stock_repository.dart';
import '../../data/repositories/supplier_repository.dart';

class StockInPage extends StatefulWidget {
  const StockInPage({super.key});
  @override
  State<StockInPage> createState() => _StockInPageState();
}

class _StockInPageState extends State<StockInPage> {
  final _repo = StockRepository();
  DateTime _date = DateTime.now();
  List<StockInModel> _items = [];
  List<Map<String, dynamic>> _summary = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final d = DateFormat('yyyy-MM-dd').format(_date);
    try {
      _items = await _repo.getStockInByDate(d);
      _summary = await _repo.getStockInSummaryByDate(d);
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
      appBar: AppBar(title: const Text('Barang Masuk')),
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
            if (_summary.isNotEmpty) ...[
              const Text('Rekap per Asal',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ..._summary.map((s) => Card(
                    child: ListTile(
                      dense: true,
                      title: Text(s['supplier_nama'] ?? '-'),
                      trailing: Text('${s['total']} unit',
                          style: const TextStyle(
                              color: AppTheme.success,
                              fontWeight: FontWeight.bold)),
                    ),
                  )),
              const SizedBox(height: 12),
            ],
            const Text('Detail Transaksi',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: Text('Belum ada barang masuk')),
              )
            else
              ..._items.map((it) => Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.success.withOpacity(0.15),
                        child: const Icon(Icons.call_received,
                            color: AppTheme.success),
                      ),
                      title: Text(it.productNama),
                      subtitle: Text('Asal: ${it.supplierNama}'),
                      trailing: Text('+${it.qty}',
                          style: const TextStyle(
                              color: AppTheme.success,
                              fontWeight: FontWeight.bold)),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddDialog() async {
    final products = await ProductRepository().getAll();
    final suppliers = await SupplierRepository().getAll();
    if (!mounted) return;
    if (products.isEmpty || suppliers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk/Supplier belum ada, minta admin menambah')),
      );
      return;
    }

    ProductModel? selProduct = products.first;
    SupplierModel? selSupplier = suppliers.first;
    final qty = TextEditingController();
    final catatan = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tambah Barang Masuk'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<ProductModel>(
                value: selProduct,
                decoration: const InputDecoration(labelText: 'Produk'),
                items: products
                    .map((p) => DropdownMenuItem(value: p, child: Text(p.nama)))
                    .toList(),
                onChanged: (v) => selProduct = v,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<SupplierModel>(
                value: selSupplier,
                decoration: const InputDecoration(labelText: 'Asal / Supplier'),
                items: suppliers
                    .map((s) => DropdownMenuItem(value: s, child: Text(s.nama)))
                    .toList(),
                onChanged: (v) => selSupplier = v,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: qty,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Qty'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: catatan,
                decoration: const InputDecoration(labelText: 'Catatan (opsional)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final q = int.tryParse(qty.text);
              if (q == null || q <= 0) return;
              final model = StockInModel(
  productId: selProduct!.id!,
  productNama: selProduct!.nama,
  productSatuan: selProduct!.satuan,
  supplierId: selSupplier!.id!,
  supplierNama: selSupplier!.nama,
  qty: q,
  tanggal: DateFormat('yyyy-MM-dd').format(_date),
  catatan: catatan.text,
);
              try {
                await _repo.addStockIn(model);
                if (mounted) Navigator.pop(context);
                _load();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(e.toString())));
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