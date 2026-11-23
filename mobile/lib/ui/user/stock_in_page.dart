import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/helpers.dart';
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
    try { _items = await _repo.getStockInByDate(DateFormat('yyyy-MM-dd').format(_date)); } catch (_) {}
    setState(() => _loading = false);
  }

  void _showNotif(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Barang Masuk')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormBottomSheet(),
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
                if (p != null) { setState(() { _date = p; }); _load(); }
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
                                Text(it.productNama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text('Asal: ${it.asalBarang}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _buildBadge('${Helpers.formatNumber(it.kg)} kg', Colors.orange),
                                    const SizedBox(width: 8),
                                    _buildBadge('+${it.total} item', Colors.green),
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
                                onPressed: () => _showFormBottomSheet(stockIn: it),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red, size: 28),
                                onPressed: () => _deleteStockIn(it),
                              ),
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

  Future<void> _deleteStockIn(StockInModel s) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Yakin ingin menghapus data masuk ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true && s.id != null) {
      await _repo.deleteStockIn(s.id!);
      _load();
      if (mounted) _showNotif('Data berhasil dihapus');
    }
  }

  Future<void> _showFormBottomSheet({StockInModel? stockIn}) async {
    final products = await ProductRepository().getAll();
    final historyIn = await _repo.getStockInByDate(''); 
    final allHistory = [..._items, ...historyIn]; 
    final uniqueAsal = allHistory.map((e) => e.asalBarang).where((e) => e.isNotEmpty).toSet().toList();
    
    if (!mounted) return;

    ProductModel? selProduct;
    String? selAsal = stockIn?.asalBarang;
    final kg = TextEditingController(text: stockIn != null ? Helpers.formatNumber(stockIn.kg) : '');
    final total = TextEditingController(text: stockIn?.total.toString() ?? '');
    final catatan = TextEditingController(text: stockIn?.catatan ?? '');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom), // Anti Keyboard
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: StatefulBuilder(
            builder: (ctx, setS) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(stockIn == null ? 'Tambah Barang Masuk' : 'Edit Barang Masuk', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const SizedBox(height: 20),
                
                LayoutBuilder(
                  builder: (context, constraints) => Autocomplete<ProductModel>(
                    initialValue: TextEditingValue(text: stockIn?.productNama ?? ''),
                    displayStringForOption: (p) => p.nama,
                    optionsBuilder: (TextEditingValue text) {
                      if (text.text.isEmpty) return products;
                      return products.where((p) => p.nama.toLowerCase().contains(text.text.toLowerCase()));
                    },
                    onSelected: (p) {
                      setS(() { selProduct = p; kg.text = Helpers.formatNumber(p.kg); });
                    },
                    fieldViewBuilder: (ctx, ctrl, fn, onSubmit) => TextField(
                      controller: ctrl, focusNode: fn,
                      decoration: const InputDecoration(labelText: 'Cari Nama Produk'),
                    ),
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4.0,
                          borderRadius: BorderRadius.circular(12),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxHeight: 200, maxWidth: constraints.maxWidth), 
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (BuildContext context, int index) {
                                final option = options.elementAt(index);
                                return InkWell(
                                  onTap: () => onSelected(option),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(option.nama),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 12),
                Autocomplete<String>(
                  initialValue: TextEditingValue(text: selAsal ?? ''),
                  optionsBuilder: (TextEditingValue text) {
                    if (text.text.isEmpty) return uniqueAsal;
                    return uniqueAsal.where((a) => a.toLowerCase().contains(text.text.toLowerCase()));
                  },
                  onSelected: (val) => selAsal = val,
                  fieldViewBuilder: (ctx, ctrl, fn, onSubmit) => TextField(
                    controller: ctrl, focusNode: fn,
                    decoration: const InputDecoration(labelText: 'Asal Barang (Kota/Toko)'),
                    onChanged: (val) => selAsal = val,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(controller: kg, keyboardType: TextInputType.number, inputFormatters: [ThousandsFormatter()], decoration: const InputDecoration(labelText: 'Berat (Kg)')),
                const SizedBox(height: 12),
                TextField(controller: total, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Total Item')),
                const SizedBox(height: 12),
                TextField(controller: catatan, decoration: const InputDecoration(labelText: 'Catatan (Opsional)')),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        final t = int.tryParse(total.text);
                        if (selProduct == null || selAsal == null || selAsal!.isEmpty || t == null) return;
                        final model = StockInModel(
                          id: stockIn?.id, productId: selProduct!.id!, productNama: selProduct!.nama, asalBarang: selAsal!,
                          kg: Helpers.parseNumber(kg.text), total: t,
                          tanggal: DateFormat('yyyy-MM-dd').format(_date), catatan: catatan.text,
                        );
                        if (stockIn == null) { await _repo.addStockIn(model); } else { await _repo.updateStockIn(model); }
                        if (mounted) Navigator.pop(ctx);
                        _load();
                        if (mounted) _showNotif(stockIn == null ? 'Berhasil ditambah' : 'Berhasil diubah');
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