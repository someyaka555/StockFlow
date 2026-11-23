import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/helpers.dart';
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
    try { _items = await _repo.getStockOutByDate(DateFormat('yyyy-MM-dd').format(_date)); } catch (_) {}
    setState(() => _loading = false);
  }

  void _showNotif(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: MediaQuery.of(context).size.height - 120),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Barang Keluar')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormDialog(),
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
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(it.productNama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text('Client: ${it.clientNama}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _buildBadge('${Helpers.formatNumber(it.kg)} kg', Colors.orange),
                                    const SizedBox(width: 8),
                                    _buildBadge('${it.pcs} pcs', Colors.blue),
                                    const Spacer(),
                                    Text('-Rp ${Helpers.formatNumber(it.total)}', style: const TextStyle(color: AppTheme.danger, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (val) {
                              if (val == 'edit') _showFormDialog(stockOut: it);
                              if (val == 'delete') _deleteStockOut(it);
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(value: 'edit', child: Text('Edit')),
                              const PopupMenuItem(value: 'delete', child: Text('Hapus', style: TextStyle(color: Colors.red))),
                            ],
                          )
                        ],
                      ),
                    ),
                  )),
          ],
        ),
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

  Future<void> _deleteStockOut(StockOutModel s) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Yakin ingin menghapus data keluar ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true && s.id != null) {
      await _repo.deleteStockOut(s.id!);
      _load();
      if (mounted) _showNotif('Data berhasil dihapus');
    }
  }

  Future<void> _showFormDialog({StockOutModel? stockOut}) async {
    final products = await ProductRepository().getAll();
    final clients = await ClientRepository().getAll();
    if (!mounted) return;
    if (products.isEmpty || clients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Produk/Client belum ada')));
      return;
    }

    ProductModel? selProduct;
    ClientModel? selClient;
    final desc = TextEditingController(text: stockOut?.deskripsi ?? '');
    final kg = TextEditingController(text: stockOut != null ? Helpers.formatNumber(stockOut.kg) : '');
    final pcs = TextEditingController(text: stockOut?.pcs.toString() ?? '');
    final harga = TextEditingController(text: stockOut != null ? Helpers.formatNumber(stockOut.harga) : '');
    final total = TextEditingController(text: stockOut != null ? Helpers.formatNumber(stockOut.total) : '');

    await showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: StatefulBuilder(
              builder: (ctx, setS) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(stockOut == null ? 'Tambah Barang Keluar' : 'Edit Barang Keluar', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Autocomplete<ProductModel>(
                    initialValue: TextEditingValue(text: stockOut?.productNama ?? ''),
                    displayStringForOption: (p) => p.nama,
                    optionsBuilder: (TextEditingValue text) {
                      if (text.text.isEmpty) return products;
                      return products.where((p) => p.nama.toLowerCase().contains(text.text.toLowerCase()));
                    },
                    onSelected: (p) => setS(() { 
                      selProduct = p; desc.text = p.deskripsi; kg.text = Helpers.formatNumber(p.kg); harga.text = Helpers.formatNumber(p.harga);
                    }),
                    fieldViewBuilder: (ctx, ctrl, fn, onSubmit) => TextField(controller: ctrl, focusNode: fn, decoration: const InputDecoration(labelText: 'Cari Produk')),
                  ),
                  const SizedBox(height: 12),
                  Autocomplete<ClientModel>(
                    initialValue: TextEditingValue(text: stockOut?.clientNama ?? ''),
                    displayStringForOption: (c) => c.nama,
                    optionsBuilder: (TextEditingValue text) {
                      if (text.text.isEmpty) return clients;
                      return clients.where((c) => c.nama.toLowerCase().contains(text.text.toLowerCase()));
                    },
                    onSelected: (c) => setS(() => selClient = c),
                    fieldViewBuilder: (ctx, ctrl, fn, onSubmit) => TextField(controller: ctrl, focusNode: fn, decoration: const InputDecoration(labelText: 'Cari Client')),
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: desc, decoration: const InputDecoration(labelText: 'Deskripsi')),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: kg, keyboardType: TextInputType.number, inputFormatters: [ThousandsFormatter()], decoration: const InputDecoration(labelText: 'Kg'))),
                      const SizedBox(width: 8),
                      Expanded(child: TextField(controller: pcs, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Pcs'))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: harga, keyboardType: TextInputType.number, inputFormatters: [ThousandsFormatter()], decoration: const InputDecoration(labelText: 'Harga')),
                  const SizedBox(height: 12),
                  TextField(controller: total, keyboardType: TextInputType.number, inputFormatters: [ThousandsFormatter()], decoration: const InputDecoration(labelText: 'Total Harga')),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          if (selProduct == null || selClient == null) return;
                          final model = StockOutModel(
                            id: stockOut?.id, clientId: selClient!.id!, clientNama: selClient!.nama, 
                            productId: selProduct!.id!, productNama: selProduct!.nama,
                            deskripsi: desc.text, kg: Helpers.parseNumber(kg.text), pcs: int.tryParse(pcs.text) ?? 0,
                            harga: Helpers.parseNumber(harga.text), total: Helpers.parseNumber(total.text), tanggal: DateFormat('yyyy-MM-dd').format(_date),
                          );
                          if (stockOut == null) { await _repo.addStockOut(model); } else { await _repo.updateStockOut(model); }
                          if (mounted) Navigator.pop(ctx);
                          _load();
                          if (mounted) _showNotif(stockOut == null ? 'Berhasil ditambah' : 'Berhasil diubah');
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
      ),
    );
  }
}