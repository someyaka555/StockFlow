import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/helpers.dart';
import '../../core/ui_helpers.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Barang Masuk')),
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
              ..._items.map((it) => Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text('Asal: ${it.asalBarang}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue, size: 24),
                                    onPressed: () => _showFormBottomSheet(stockIn: it),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red, size: 24),
                                    onPressed: () => _deleteStockIn(it),
                                  ),
                                ],
                              )
                            ],
                          ),
                          const Divider(),
                          // List Item Produk dalam nota
                          ...it.items.map((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(item.productNama, style: const TextStyle(fontWeight: FontWeight.w500)),
                                Row(
                                  children: [
                                    _buildBadge('${Helpers.formatNumber(item.kg)} kg', Colors.orange),
                                    const SizedBox(width: 8),
                                    _buildBadge('+${item.total} item', Colors.green),
                                  ],
                                )
                              ],
                            ),
                          )),
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
        content: Text('Yakin ingin menghapus nota ini? Stok produk akan dikembalikan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true && s.id != null) {
      await _repo.deleteStockIn(s.id!);
      _load();
      if (mounted) AppSnackBar.success(context, 'Nota berhasil dihapus');
    }
  }

  Future<void> _showFormBottomSheet({StockInModel? stockIn}) async {
    final products = await ProductRepository().getAll();
    final historyIn = await _repo.getStockInByDate(''); 
    final allHistory = [..._items, ...historyIn]; 
    final uniqueAsal = allHistory.map((e) => e.asalBarang).where((e) => e.isNotEmpty).toSet().toList();
    
    if (!mounted) return;
    if (products.isEmpty) {
      AppSnackBar.error(context, 'Belum ada produk. Tambah produk terlebih dahulu.');
      return;
    }

    // Inisialisasi List Keranjang jika Edit, atau Kosong jika Baru
    List<StockInItem> cartItems = stockIn != null ? List.from(stockIn.items) : [];
    
    // Controller Global
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
                const SizedBox(height: 16),
                
                // Tampilkan List Keranjang
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
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => setS(() => cartItems.removeAt(idx)),
                        ),
                      ),
                    );
                  }),
                  const Divider(),
                ],

                // Tombol Tambah Produk ke Keranjang
                OutlinedButton.icon(
                  onPressed: () async {
                    await _showAddProductDialog(context, products, (newItem) {
                      setS(() {
                        // Cek jika produk sudah ada di keranjang, update totalnya
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
                        
                        if (stockIn == null) { 
                          await _repo.addStockIn(model); 
                        } else { 
                          await _repo.updateStockIn(model); 
                        }
                        
                        if (mounted) Navigator.pop(ctx);
                        _load();
                        if (mounted) AppSnackBar.success(context, stockIn == null ? 'Berhasil ditambah' : 'Berhasil diubah');
                      },
                      child: const Text('Simpan Nota'),
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

  // Dialog untuk memilih 1 produk dan memasukkan jumlahnya
  Future<void> _showAddProductDialog(BuildContext parentCtx, List<ProductModel> products, Function(StockInItem) onAdd) async {
    ProductModel? selProduct;
    final kg = TextEditingController();
    final total = TextEditingController();

    await showDialog(
      context: parentCtx,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Tambah Produk'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<ProductModel>(
                decoration: const InputDecoration(labelText: 'Pilih Produk'),
                value: selProduct,
                items: products.map((p) => DropdownMenuItem(value: p, child: Text(p.nama))).toList(),
                onChanged: (p) {
                  setS(() { 
                    selProduct = p; 
                    if (p != null) kg.text = Helpers.formatNumber(p.kg);
                  });
                },
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
              onPressed: () {
                final t = int.tryParse(total.text);
                if (selProduct == null || t == null) return;
                onAdd(StockInItem(
                  productId: selProduct!.id!, productNama: selProduct!.nama, 
                  kg: Helpers.parseNumber(kg.text), total: t
                ));
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