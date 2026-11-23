class StockInItem {
  final String productId;
  final String productNama;
  final double kg;
  final int total;

  StockInItem({required this.productId, required this.productNama, required this.kg, required this.total});

  Map<String, dynamic> toJson() => {'product': productId, 'kg': kg, 'total': total};

  factory StockInItem.fromJson(Map<String, dynamic> m) {
    final p = m['product'];
    return StockInItem(
      productId: p is Map ? p['_id'].toString() : p.toString(),
      productNama: p is Map ? (p['nama'] ?? '') : '',
      kg: (m['kg'] ?? 0.0).toDouble(),
      total: m['total'] ?? 0,
    );
  }
}

class StockInModel {
  final String? id;
  final String asalBarang;
  final String tanggal;
  final String? catatan;
  final List<StockInItem> items;

  StockInModel({
    this.id, required this.asalBarang, required this.tanggal, this.catatan, required this.items,
  });

  Map<String, dynamic> toJson() => {
        'asalBarang': asalBarang,
        'tanggal': tanggal,
        'catatan': catatan ?? '',
        'items': items.map((e) => e.toJson()).toList(),
      };

  factory StockInModel.fromJson(Map<String, dynamic> m) {
    var rawItems = m['items'] as List? ?? [];
    return StockInModel(
      id: m['_id']?.toString(),
      asalBarang: m['asalBarang'] ?? '',
      tanggal: m['tanggal'] ?? '',
      catatan: m['catatan'] ?? '',
      items: rawItems.map((e) => StockInItem.fromJson(e)).toList(),
    );
  }
}