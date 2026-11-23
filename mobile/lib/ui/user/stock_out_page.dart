import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/helpers.dart';
import '../../core/ui_helpers.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Barang Keluar')),
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
              const Center(child: Text('Belum ada barang keluar'))
            else
              ..._items.map((it) => _buildNotaCard(it)),
          ],
        ),
      ),
    );
  }

  // REDESIGN UI KARTU (Tugas #18)
  Widget _buildNotaCard(StockOutModel it) {
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
                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.local_shipping_outlined, color: Colors.red),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Client: ${it.clientNama}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue, size: 24),
                  onPressed: () => _showFormBottomSheet(stockOut: it),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 24),
                  onPressed: () => _deleteStockOut(it),
                ),
              ],
            ),
            const Divider(height: 24),
            ...it.items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.productNama, style: const TextStyle(fontWeight: FontWeight.w500)),
                        Text('${item.pcs} pcs • ${Helpers.formatNumber(item.kg)} kg', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  Text('Rp ${Helpers.formatNumber(item.subtotal)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.danger)),
                ],
              ),
            )),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Grand Total:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('-Rp ${Helpers.formatNumber(it.grandTotal)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.danger, fontSize: 16)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> _deleteStockOut(StockOutModel s) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Yakin ingin menghapus nota ini? Stok dan Saldo Client akan dikembalikan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    // FIX BUG DELETE (Tugas #14)
    if (confirm == true && s.id != null) {
      await _repo.deleteStockOut(s.id!);
      await _load();
      if (mounted) AppSnackBar.success(context, 'Nota berhasil dihapus');
    }
  }

  Future<void> _showFormBottomSheet({StockOutModel? stockOut}) async {
    final products = await ProductRepository().getAll();
    final clients = await ClientRepository().getAll();
    if (!mounted) return;
    if (products.isEmpty || clients.isEmpty) {
      AppSnackBar.error(context, 'Produk/Client belum ada');
      return;
    }

    ClientModel? selClient = stockOut != null ? clients.firstWhere((c) => c.id == stockOut.clientId, orElse: () => clients.first) : null;
    List<StockOutItem> cartItems = stockOut != null ? List.from(stockOut.items) : [];
    
    // Controller untuk PPN & Restitusi di level Nota (Tugas #15)
    final ppnNota = TextEditingController(text: stockOut != null ? Helpers.formatNumber(stockOut.ppnNota) : '');
    final restitusiNota = TextEditingController(text: stockOut != null ? Helpers.formatNumber(stockOut.restitusiNota) : '');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: StatefulBuilder(
            builder: (ctx, setS) {
              double totalBarang = cartItems.fold(0, (sum, item) => sum + item.subtotal);
              double grandTotal = totalBarang + Helpers.parseNumber(ppnNota.text) - Helpers.parseNumber(restitusiNota.text);

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(stockOut == null ? 'Tambah Barang Keluar' : 'Edit Barang Keluar', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  
                  LayoutBuilder(
                    builder: (context, constraints) => Autocomplete<ClientModel>(
                      initialValue: TextEditingValue(text: selClient?.nama ?? ''),
                      displayStringForOption: (c) => c.nama,
                      optionsBuilder: (TextEditingValue text) {
                        if (text.text.isEmpty) return clients;
                        return clients.where((c) => c.nama.toLowerCase().contains(text.text.toLowerCase()));
                      },
                      onSelected: (c) => setS(() => selClient = c),
                      fieldViewBuilder: (ctx, ctrl, fn, onSubmit) => TextField(controller: ctrl, focusNode: fn, decoration: const InputDecoration(labelText: 'Cari Client')),
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
                  const SizedBox(height: 16),
                  
                  if (cartItems.isNotEmpty) ...[
                    const Text('Daftar Produk:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...cartItems.asMap().entries.map((entry) {
                      int idx = entry.key;
                      StockOutItem item = entry.value;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(item.productNama),
                          subtitle: Text('${item.pcs} pcs • Rp ${Helpers.formatNumber(item.subtotal)}'),
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
                        setS(() => cartItems.add(newItem));
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Produk ke Nota'),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // INPUT PPN & RESTITUSI DI LUAR (Tugas #15)
                  Row(
                    children: [
                      Expanded(child: TextField(controller: ppnNota, keyboardType: TextInputType.number, inputFormatters: [ThousandsFormatter()], decoration: const InputDecoration(labelText: 'PPN (Rp)'), onChanged: (v) => setS(() {}))),
                      const SizedBox(width: 8),
                      Expanded(child: TextField(controller: restitusiNota, keyboardType: TextInputType.number, inputFormatters: [ThousandsFormatter()], decoration: const InputDecoration(labelText: 'Restitusi (Rp)'), onChanged: (v) => setS(() {}))),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      'Grand Total: Rp ${Helpers.formatNumber(grandTotal)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          if (cartItems.isEmpty || selClient == null) {
                            AppSnackBar.error(ctx, 'Isi Client dan minimal 1 Produk');
                            return;
                          }

                          final model = StockOutModel(
                            id: stockOut?.id, clientId: selClient!.id!, clientNama: selClient!.nama, 
                            tanggal: DateFormat('yyyy-MM-dd').format(_date),
                            items: cartItems, grandTotal: grandTotal,
                            ppnNota: Helpers.parseNumber(ppnNota.text),
                            restitusiNota: Helpers.parseNumber(restitusiNota.text),
                          );
                          
                          if (stockOut == null) { await _repo.addStockOut(model); } else { await _repo.updateStockOut(model); }
                          if (mounted) Navigator.pop(ctx);
                          await _load();
                          if (mounted) AppSnackBar.success(context, stockOut == null ? 'Berhasil ditambah' : 'Berhasil diubah');
                        },
                        // UBAH TEXT TOMBOL (Tugas #11)
                        child: const Text('Simpan'),
                      ),
                    ],
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showAddProductDialog(BuildContext parentCtx, List<ProductModel> products, Function(StockOutItem) onAdd, {StockOutItem? initialItem}) async {
    ProductModel? selProduct = initialItem != null ? products.firstWhere((p) => p.id == initialItem.productId, orElse: () => products.first) : null;
    final desc = TextEditingController(text: initialItem?.deskripsi ?? '');
    final kg = TextEditingController(text: initialItem != null ? Helpers.formatNumber(initialItem.kg) : '');
    final pcs = TextEditingController(text: initialItem?.pcs.toString() ?? '');
    final harga = TextEditingController(text: initialItem != null ? Helpers.formatNumber(initialItem.harga) : '');

    await showDialog(
      context: parentCtx,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) {
          double subtotal = (int.tryParse(pcs.text) ?? 0) * Helpers.parseNumber(harga.text);
          
          return AlertDialog(
            title: Text(initialItem == null ? 'Tambah Produk' : 'Edit Produk'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<ProductModel>(
                    decoration: const InputDecoration(labelText: 'Pilih Produk'),
                    value: selProduct,
                    items: products.map((p) => DropdownMenuItem(value: p, child: Text(p.nama))).toList(),
                    onChanged: (p) {
                      setS(() { 
                        selProduct = p; 
                        if (p != null) {
                          desc.text = p.deskripsi; 
                          kg.text = Helpers.formatNumber(p.kg); 
                          harga.text = Helpers.formatNumber(p.harga);
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: desc, decoration: const InputDecoration(labelText: 'Deskripsi')),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: kg, keyboardType: TextInputType.number, inputFormatters: [ThousandsFormatter()], decoration: const InputDecoration(labelText: 'Kg'))),
                      const SizedBox(width: 8),
                      Expanded(child: TextField(controller: pcs, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Pcs'), onChanged: (v) => setS(() {}))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: harga, keyboardType: TextInputType.number, inputFormatters: [ThousandsFormatter()], decoration: const InputDecoration(labelText: 'Harga'), onChanged: (v) => setS(() {})),
                  
                  // PPN & Restitusi DIHAPUS dari sini (Tugas #15)
                  
                  const SizedBox(height: 16),
                  Text('Subtotal: Rp ${Helpers.formatNumber(subtotal)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
              ElevatedButton(
                onPressed: () {
                  final finalPcs = int.tryParse(pcs.text) ?? 0;
                  final finalHarga = Helpers.parseNumber(harga.text);
                  
                  if (selProduct == null || finalPcs <= 0) return;
                  
                  onAdd(StockOutItem(
                    productId: selProduct!.id!, productNama: selProduct!.nama, deskripsi: desc.text,
                    kg: Helpers.parseNumber(kg.text), pcs: finalPcs, harga: finalHarga,
                    subtotal: subtotal,
                  ));
                  Navigator.pop(ctx);
                },
                child: const Text('Tambahkan'),
              ),
            ],
          );
        },
      ),
    );
  }
}