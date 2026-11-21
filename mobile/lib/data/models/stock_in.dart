class StockInModel {
  final String? id;
  final String productId;
  final String productNama;
  final String asalBarang;
  final double kg;
  final int total;
  final String tanggal;
  final String? catatan;

  StockInModel({
    this.id,
    required this.productId,
    this.productNama = '',
    required this.asalBarang,
    required this.kg,
    required this.total,
    required this.tanggal,
    this.catatan,
  });

  Map<String, dynamic> toJson() => {
        'product': productId,
        'asalBarang': asalBarang,
        'kg': kg,
        'total': total,
        'tanggal': tanggal,
        'catatan': catatan ?? '',
      };

  factory StockInModel.fromJson(Map<String, dynamic> m) {
    final p = m['product'];
    return StockInModel(
      id: m['_id']?.toString(),
      productId: p is Map ? p['_id'].toString() : p.toString(),
      productNama: p is Map ? (p['nama'] ?? '') : '',
      asalBarang: m['asalBarang'] ?? '',
      kg: (m['kg'] ?? 0.0).toDouble(),
      total: m['total'] ?? 0,
      tanggal: m['tanggal'] ?? '',
      catatan: m['catatan'] ?? '',
    );
  }
}