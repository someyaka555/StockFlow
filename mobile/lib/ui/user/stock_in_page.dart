import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../data/models/product.dart';
import '../../data/models/stock_in.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/stock_repository.dart';

class StockInPage extends StatefulWidget {
  const StockInPage({super.key});
  @override
  State<StockInPage> createState() => _StockInPageState();
}

class _StockInPageState extends State<StockInPage> {
  final _repo = StockRepository();
  DateTime _date = DateTime.now();
  List<StockInModel> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _items = await _repo.getStockInByDate(DateFormat('yyyy-MM-dd').format(_date));
    } catch (_) {}
    setState(() => _loading = false);
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
              onPressed: () async {
                final p = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2020), lastDate: DateTime(2100));
                if (p != null) { _date = p; _load(); }
              },
              icon: const Icon(Icons.calendar_today, size: 18),
              label: Text(DateFormat('EEEE, dd MMM yyyy').format(_date)),
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_items.isEmpty)
              const Center(child: Text('Belum ada barang masuk'))
            else
              ..._items.map((it) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.call_received, color: AppTheme.success),
                      title: Text(it.productNama),
                      subtitle: Text('Asal: ${it.asalBarang} • ${it.kg} kg'),
                      trailing: Text('+${it.total}', style: const TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold)),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddDialog() async {
    final products = await ProductRepository().getAll();
    final historyIn = await _repo.getStockInByDate(''); // Ambil semua history (jika mock, ambil list)
    // Kumpulkan asal barang unik
    final uniqueAsal = historyIn.map((e) => e.asalBarang).toSet().toList();
    
    if (!mounted) return;

    ProductModel? selProduct;
    String? selAsal;
    final kg = TextEditingController();
    final total = TextEditingController();
    final catatan = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Tambah Barang Masuk'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Autocomplete Nama Produk
                Autocomplete<ProductModel>(
                  displayStringForOption: (p) => p.nama,
                  optionsBuilder: (TextEditingValue text) {
                    if (text.text.isEmpty) return products;
                    return products.where((p) => p.nama.toLowerCase().contains(text.text.toLowerCase()));
                  },
                  onSelected: (p) {
                    setS(() {
                      selProduct = p;
                      kg.text = p.kg.toString(); // Auto-fill kg
                    });
                  },
                  fieldViewBuilder: (ctx, ctrl, fn, onSubmit) => TextField(
                    controller: ctrl,
                    focusNode: fn,
                    decoration: const InputDecoration(labelText: 'Cari Nama Produk'),
                  ),
                ),
                const SizedBox(height: 12),
                // Autocomplete Asal Barang
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue text) {
                    if (text.text.isEmpty) return uniqueAsal;
                    return uniqueAsal.where((a) => a.toLowerCase().contains(text.text.toLowerCase()));
                  },
                  onSelected: (val) => selAsal = val,
                  fieldViewBuilder: (ctx, ctrl, fn, onSubmit) => TextField(
                    controller: ctrl,
                    focusNode: fn,
                    decoration: const InputDecoration(labelText: 'Asal Barang (Kota/Toko)'),
                    onChanged: (val) => selAsal = val,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(controller: kg, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Berat (Kg)')),
                const SizedBox(height: 12),
                TextField(controller: total, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Total Item')),
                const SizedBox(height: 12),
                TextField(controller: catatan, decoration: const InputDecoration(labelText: 'Catatan (Opsional)')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                final t = int.tryParse(total.text);
                if (selProduct == null || selAsal == null || t == null) return;
                
                final model = StockInModel(
                  productId: selProduct!.id!,
                  productNama: selProduct!.nama,
                  asalBarang: selAsal!,
                  kg: double.tryParse(kg.text) ?? 0,
                  total: t,
                  tanggal: DateFormat('yyyy-MM-dd').format(_date),
                  catatan: catatan.text,
                );
                await _repo.addStockIn(model);
                if (mounted) Navigator.pop(ctx);
                _load();
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}