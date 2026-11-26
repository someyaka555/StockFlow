import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/helpers.dart';
import '../../core/ui_helpers.dart';
import '../../data/models/product.dart';
import '../../data/models/stock_in.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/stock_repository.dart';
// TAMBAHKAN IMPORT INI
import 'laporan_stock_in_page.dart'; 

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barang Masuk'),
        // TAMBAHKAN BAGIAN INI UNTUK TOMBOL LAPORAN
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Cek Laporan',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LaporanStockInPage()));
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormBottomSheet(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Nota'),
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
              ..._items.map((it) => _buildNotaCard(it)),
          ],
        ),
      ),
    );
  }

  Widget _buildNotaCard(StockInModel it) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.local_shipping, color: Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Asal: ${it.asalBarang}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue, size: 24),
                  onPressed: () => _showFormBottomSheet(stockIn: it),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 24),
                  onPressed: () => _deleteStockIn(it),
                ),
              ],
            ),
            const Divider(height: 24),
            ...it.items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(item.productNama, style: const TextStyle(fontWeight: FontWeight.w500))),
                  _buildBadge('${Helpers.formatNumber(item.kg)} kg', Colors.orange),
                  const SizedBox(width: 8),
                  _buildBadge('+${item.total} item', Colors.green),
                ],
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
        content: Text('Yakin ingin menghapus nota ini? Stok produk akan dikembalikan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true && s.id != null) {
      await _repo.deleteStockIn(s.id!);
      await _load();
      if (mounted) AppSnackBar.success(context, 'Nota berhasil dihapus');
    }
  }

  Future<void> _showFormBottomSheet({StockInModel? stockIn}) async {
    final products = await ProductRepository().getAll();
    final historyIn = await _repo.getStockInByDate(''); 
    final allHistory = [..._items, ...historyIn]; 
    final uniqueAsal = allHistory.map((e) => e.asalBarang).where((e) => e.isNotEmpty).toSet().toList();
    
    if (!mounted) return;

    List<StockInItem> cartItems = stockIn != null ? List.from(stockIn.items) : [];
    String? selAsal = stockIn?.asalBarang;
    final catatan = TextEditingController(text: stockIn?.catatan ?? '');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
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
                  builder: (context, constraints) => Autocomplete<String>(
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
                              itemBuilder: (context, index) {
                                final option = options.elementAt(index);
                                return InkWell(
                                  onTap: () => onSelected(option),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(option),
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
                const SizedBox(height: 16),
                
                if (cartItems.isNotEmpty) ...[
                  const Text('Daftar Produk:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...cartItems.asMap().entries.map((entry) {
                    int idx = entry.key;
                    StockInItem item = entry.value;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(item.productNama),
                        subtitle: Text('${Helpers.formatNumber(item.kg)} kg • ${item.total} item'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () async {
                                await _showAddProductDialog(context, products, (newItem) {
                                  setS(() => cartItems[idx] = newItem);
                                }, initialItem: item);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => setS(() => cartItems.removeAt(idx)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const Divider(),
                ],

                OutlinedButton.icon(
                  onPressed: () async {
                    await _showAddProductDialog(context, products, (newItem) {
                      setS(() {
                        int existingIdx = cartItems.indexWhere((e) => e.productId == newItem.productId);
                        if (existingIdx >= 0) {
                          final old = cartItems[existingIdx];
                          cartItems[existingIdx] = StockInItem(
                            productId: old.productId, productNama: old.productNama, kg: newItem.kg, total: old.total + newItem.total
                          );
                        } else {
                          cartItems.add(newItem);
                        }
                      });
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Produk ke Nota'),
                ),
                
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
                        if (cartItems.isEmpty || selAsal == null || selAsal!.isEmpty) {
                          AppSnackBar.error(ctx, 'Isi Asal Barang dan minimal 1 Produk');
                          return;
                        }
                        
                        final model = StockInModel(
                          id: stockIn?.id, asalBarang: selAsal!, tanggal: DateFormat('yyyy-MM-dd').format(_date), 
                          catatan: catatan.text, items: cartItems
                        );
                        
                        if (stockIn == null) { await _repo.addStockIn(model); } else { await _repo.updateStockIn(model); }
                        if (mounted) Navigator.pop(ctx);
                        await _load();
                        if (mounted) AppSnackBar.success(context, stockIn == null ? 'Berhasil ditambah' : 'Berhasil diubah');
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

  Future<void> _showAddProductDialog(BuildContext parentCtx, List<ProductModel> products, Function(StockInItem) onAdd, {StockInItem? initialItem}) async {
    ProductModel? selProduct = initialItem != null ? products.firstWhere((p) => p.id == initialItem.productId, orElse: () => products.first) : null;
    final kg = TextEditingController(text: initialItem != null ? Helpers.formatNumber(initialItem.kg) : '');
    final total = TextEditingController(text: initialItem?.total.toString() ?? '');

    await showDialog(
      context: parentCtx,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text(initialItem == null ? 'Tambah Produk' : 'Edit Produk'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LayoutBuilder(
                builder: (context, constraints) => Autocomplete<ProductModel>(
                  initialValue: TextEditingValue(text: selProduct?.nama ?? ''),
                  displayStringForOption: (p) => p.nama,
                  optionsBuilder: (TextEditingValue text) {
                    if (text.text.isEmpty) return products;
                    return products.where((p) => p.nama.toLowerCase().contains(text.text.toLowerCase()));
                  },
                  onSelected: (p) {
                    setS(() { 
                      selProduct = p; 
                      if (p != null) kg.text = Helpers.formatNumber(p.kg);
                    });
                  },
                  fieldViewBuilder: (ctx, ctrl, fn, onSubmit) => TextField(
                    controller: ctrl, focusNode: fn,
                    decoration: const InputDecoration(labelText: 'Cari / Ketik Nama Produk'),
                    onChanged: (text) {
                      if (selProduct != null && selProduct!.nama != text) {
                        setS(() => selProduct = null);
                      }
                    },
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
                            itemBuilder: (context, index) {
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
              TextField(controller: kg, keyboardType: TextInputType.number, inputFormatters: [ThousandsFormatter()], decoration: const InputDecoration(labelText: 'Berat (Kg)')),
              const SizedBox(height: 12),
              TextField(controller: total, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Total Item')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                final t = int.tryParse(total.text);
                if (t == null) return;

                String pId = selProduct?.id ?? '';
                String pNama = selProduct?.nama ?? '';

                if (selProduct == null) {
                  final fallbackName = 'Produk Manual ${DateTime.now().second}';
                  final newProduct = ProductModel(
                    nama: fallbackName, deskripsi: '', kg: Helpers.parseNumber(kg.text), harga: 0, stokTotal: 0
                  );
                  await ProductRepository().create(newProduct);
                  final updatedProducts = await ProductRepository().getAll();
                  pId = updatedProducts.last.id!;
                  pNama = updatedProducts.last.nama;
                }

                onAdd(StockInItem(productId: pId, productNama: pNama, kg: Helpers.parseNumber(kg.text), total: t));
                Navigator.pop(ctx);
              },
              child: const Text('Tambahkan'),
            ),
          ],
        ),
      ),
    );
  }
}