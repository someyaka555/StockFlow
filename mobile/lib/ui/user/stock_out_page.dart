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
              const Center(child: Text('Belum ada barang keluar'))
            else
              ..._items.map((it) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.call_made, color: AppTheme.danger),
                      title: Text(it.productNama),
                      subtitle: Text('Client: ${it.clientNama}\n${it.deskripsi} • ${it.kg} kg • ${it.pcs} pcs'),
                      isThreeLine: true,
                      trailing: Text('-Rp ${it.total}', style: const TextStyle(color: AppTheme.danger, fontWeight: FontWeight.bold)),
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Produk/Client belum ada')));
      return;
    }

    ProductModel? selProduct;
    ClientModel? selClient;
    final desc = TextEditingController();
    final kg = TextEditingController();
    final pcs = TextEditingController();
    final harga = TextEditingController();
    final total = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Tambah Barang Keluar'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<ProductModel>(
                  value: selProduct,
                  decoration: const InputDecoration(labelText: 'Produk'),
                  items: products.map((p) => DropdownMenuItem(value: p, child: Text(p.nama))).toList(),
                  onChanged: (v) => setS(() { 
                    selProduct = v; 
                    desc.text = v?.deskripsi ?? ''; 
                    kg.text = v?.kg.toString() ?? '';
                    harga.text = v?.harga.toString() ?? '';
                  }),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<ClientModel>(
                  value: selClient,
                  decoration: const InputDecoration(labelText: 'Ke Client'),
                  items: clients.map((c) => DropdownMenuItem(value: c, child: Text(c.nama))).toList(),
                  onChanged: (v) => selClient = v,
                ),
                const SizedBox(height: 12),
                TextField(controller: desc, decoration: const InputDecoration(labelText: 'Deskripsi')),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: kg, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Kg'))),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: pcs, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Pcs'))),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(controller: harga, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Harga')),
                const SizedBox(height: 12),
                TextField(controller: total, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Total Harga')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                final tot = double.tryParse(total.text);
                if (selProduct == null || selClient == null || tot == null) return;
                
                final model = StockOutModel(
                  clientId: selClient!.id!,
                  clientNama: selClient!.nama,
                  productId: selProduct!.id!,
                  productNama: selProduct!.nama,
                  deskripsi: desc.text,
                  kg: double.tryParse(kg.text) ?? 0,
                  pcs: int.tryParse(pcs.text) ?? 0,
                  harga: double.tryParse(harga.text) ?? 0,
                  total: tot,
                  tanggal: DateFormat('yyyy-MM-dd').format(_date),
                );
                await _repo.addStockOut(model);
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