import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
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

class _StockInPageState extends State<StockInPage> with SingleTickerProviderStateMixin {
  final _repo = StockRepository();
  DateTime _date = DateTime.now();
  List<StockInModel> _items = [];
  List<StockInModel> _allReportData = [];
  bool _loading = true;
  late TabController _tabController;

  final GlobalKey _reportGlobalKey = GlobalKey();
  String _selectedPeriod = 'Mingguan';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _items = await _repo.getStockInByDate(DateFormat('yyyy-MM-dd').format(_date));
      _allReportData = await _repo.getStockInByDate('');
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _downloadImage() async {
    try {
      RenderRepaintBoundary boundary = _reportGlobalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      await Gal.putImageBytes(pngBytes);
      
      if (mounted) AppSnackBar.success(context, 'Gambar berhasil disimpan ke Galeri');
    } catch (e) {
      if (mounted) AppSnackBar.error(context, 'Gagal menyimpan gambar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barang Masuk'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 16, right: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(30),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.blue,
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(text: 'Transaksi'),
                  Tab(text: 'Laporan'),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _tabController,
        builder: (context, _) {
          if (_tabController.index == 0) {
            return FloatingActionButton.extended(
              onPressed: () => _showFormBottomSheet(),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Nota'),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTransaksiTab(),
          _buildLaporanTab(),
        ],
      ),
    );
  }

  // ================== TAB 1: TRANSAKSI ==================
  Widget _buildTransaksiTab() {
    return RefreshIndicator(
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

  // ================== TAB 2: LAPORAN ==================
  Widget _buildLaporanTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('Filter Rekap:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _selectedPeriod,
                    items: ['Mingguan', 'Bulanan', 'Tahunan'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedPeriod = val!;
                        _load();
                      });
                    },
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.download, color: Colors.blue),
                tooltip: 'Download Gambar',
                onPressed: _downloadImage,
              ),
            ],
          ),
        ),
        Expanded(child: _buildTableBarangMasuk()),
      ],
    );
  }

  Widget _buildTableBarangMasuk() {
    DateTime endDate = DateTime.now();
    DateTime startDate;
    if (_selectedPeriod == 'Mingguan') {
      startDate = endDate.subtract(const Duration(days: 7));
    } else if (_selectedPeriod == 'Bulanan') {
      startDate = DateTime(endDate.year, endDate.month, 1);
    } else {
      startDate = DateTime(endDate.year, 1, 1);
    }

    final filteredData = _allReportData.where((e) {
      final date = DateTime.tryParse(e.tanggal);
      return date != null && date.isAfter(startDate.subtract(const Duration(days: 1))) && date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();

    final Set<String> uniqueProducts = {};
    for (var nota in filteredData) {
      for (var item in nota.items) {
        uniqueProducts.add(item.productNama);
      }
    }
    final productList = uniqueProducts.toList();

    final Map<String, Map<String, int>> dailyData = {};
    for (var nota in filteredData) {
      dailyData.putIfAbsent(nota.tanggal, () => {});
      for (var item in nota.items) {
        dailyData[nota.tanggal]![item.productNama] = (dailyData[nota.tanggal]![item.productNama] ?? 0) + item.total;
      }
    }

    final Map<String, int> grandTotal = {};
    for (var p in productList) {
      grandTotal[p] = dailyData.values.fold(0, (sum, map) => sum + (map[p] ?? 0));
    }

    if (productList.isEmpty) {
      return const Center(child: Text('Tidak ada data pada periode ini.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: RepaintBoundary(
        key: _reportGlobalKey,
        child: Container(
          color: Colors.white,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.blue.withOpacity(0.1)),
              border: TableBorder.all(color: Colors.grey.shade300),
              columns: [
                const DataColumn(label: Text('Tanggal', style: TextStyle(fontWeight: FontWeight.bold))),
                ...productList.map((p) => DataColumn(label: Text(p, style: const TextStyle(fontWeight: FontWeight.bold)))),
                const DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: [
                ...dailyData.entries.map((entry) {
                  return DataRow(cells: [
                    DataCell(Text(entry.key)),
                    ...productList.map((p) => DataCell(Text(entry.value[p] != null ? '${entry.value[p]} (pcs)' : '-'))),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.info_outline, color: Colors.blue),
                        tooltip: 'Detail',
                        onPressed: () => _showDetailDialog(entry.key, filteredData.where((e) => e.tanggal == entry.key).toList()),
                      ),
                    ),
                  ]);
                }),
                DataRow(
                  color: MaterialStateProperty.all(Colors.grey.shade100),
                  cells: [
                    const DataCell(Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold))),
                    ...productList.map((p) => DataCell(Text('${grandTotal[p]}', style: const TextStyle(fontWeight: FontWeight.bold)))),
                    const DataCell(Text('-')),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDetailDialog(String tanggal, List<StockInModel> notas) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Detail Transaksi: $tanggal', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: notas.length,
                  itemBuilder: (context, i) {
                    final nota = notas[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Asal: ${nota.asalBarang}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                            const Divider(),
                            ...nota.items.map((item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(item.productNama),
                                  Text('${item.total} pcs • ${Helpers.formatNumber(item.kg)} kg'),
                                ],
                              ),
                            )),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              )
            ],
          ),
        ),
      ),
    );
  }

  // ================== FUNGSI CRUD ==================
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

  // DIALOG ADD/EDIT PRODUK
  Future<void> _showAddProductDialog(BuildContext parentCtx, List<ProductModel> products, Function(StockInItem) onAdd, {StockInItem? initialItem}) async {
    ProductModel? selProduct = initialItem != null ? products.firstWhere((p) => p.id == initialItem.productId, orElse: () => products.first) : null;
    
    final nameCtrl = TextEditingController(text: selProduct?.nama ?? '');
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
              // MENGGUNAKAN RAW AUTOCOMPLETE AGAR SEARCH & MANUAL INPUT BERJALAN BERSAMAAN
              LayoutBuilder(
                builder: (context, constraints) => RawAutocomplete<ProductModel>(
                  textEditingController: nameCtrl,
                  focusNode: FocusNode(),
                  displayStringForOption: (p) => p.nama,
                  optionsBuilder: (TextEditingValue text) {
                    if (text.text.isEmpty) return products;
                    return products.where((p) => p.nama.toLowerCase().contains(text.text.toLowerCase()));
                  },
                  onSelected: (p) {
                    setS(() { 
                      selProduct = p; 
                      nameCtrl.text = p.nama; // Update input teks
                      kg.text = Helpers.formatNumber(p.kg); // Isi otomatis kg
                    });
                  },
                  fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(labelText: 'Cari / Ketik Nama Produk'),
                      onChanged: (text) {
                        // Jika user mengetik manual dan teksnya beda dengan yang dipilih
                        if (selProduct != null && selProduct!.nama != text) {
                          setS(() => selProduct = null);
                        }
                      },
                    );
                  },
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
                
                // Ambil teks manual dari input
                final manualName = nameCtrl.text.trim();

                // Jika produk diketik manual, simpan ke database
                if (selProduct == null) {
                  if (manualName.isEmpty) {
                    AppSnackBar.error(ctx, 'Nama produk tidak boleh kosong');
                    return;
                  }
                  
                  final newProduct = ProductModel(
                    nama: manualName, // Gunakan nama asli yang diketik
                    deskripsi: '', 
                    kg: Helpers.parseNumber(kg.text), 
                    harga: 0, 
                    stokTotal: 0
                  );
                  
                  await ProductRepository().create(newProduct);
                  
                  // Ambil ID dari produk baru
                  final updatedProducts = await ProductRepository().getAll();
                  final createdProd = updatedProducts.firstWhere((p) => p.nama == manualName);
                  
                  pId = createdProd.id!;
                  pNama = createdProd.nama;
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