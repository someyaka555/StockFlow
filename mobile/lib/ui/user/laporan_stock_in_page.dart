import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import '../../core/helpers.dart';
import '../../core/ui_helpers.dart';
import '../../data/models/stock_in.dart';
import '../../data/repositories/stock_repository.dart';

class LaporanStockInPage extends StatefulWidget {
  const LaporanStockInPage({super.key});
  @override
  State<LaporanStockInPage> createState() => _LaporanStockInPageState();
}

class _LaporanStockInPageState extends State<LaporanStockInPage> with SingleTickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  final _repo = StockRepository();
  
  late TabController _tabController;
  
  String _selectedPeriod = 'Mingguan';
  List<StockInModel> _allData = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      _allData = await _repo.getStockInByDate('');
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _downloadImage() async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      await Gal.putImageBytes(pngBytes, name: 'laporan_masuk_${DateTime.now().millisecondsSinceEpoch}');
      if (mounted) AppSnackBar.success(context, 'Gambar berhasil disimpan ke Galeri');
    } catch (e) {
      if (mounted) AppSnackBar.error(context, 'Gagal menyimpan gambar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Stok'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Download Gambar',
            onPressed: _downloadImage,
          )
        ],
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
                  Tab(text: 'Personal'),
                  Tab(text: 'Bisnis'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                const Center(child: Text('Laporan Personal (Belum tersedia)')),
                _buildBisnisTab(),
              ],
            ),
    );
  }

  Widget _buildBisnisTab() {
    return Column(
      children: [
        _buildFilterBar(),
        const SizedBox(height: 8),
        Expanded(child: _buildTableBarangMasuk()),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Filter Rekap:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          DropdownButton<String>(
            value: _selectedPeriod,
            items: ['Mingguan', 'Bulanan', 'Tahunan'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (val) {
              setState(() {
                _selectedPeriod = val!;
                _loadData();
              });
            },
          ),
        ],
      ),
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

    final filteredData = _allData.where((e) {
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
        key: _globalKey,
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
}