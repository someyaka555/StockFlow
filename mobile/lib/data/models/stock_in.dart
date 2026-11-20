class StockInModel {
  final String? id;
  final String productId;
  final String productNama;
  final String productSatuan;
  final String supplierId;
  final String supplierNama;
  final int qty;
  final String tanggal;
  final String? catatan;

  StockInModel({
    this.id,
    required this.productId,
    this.productNama = '',
    this.productSatuan = '',
    required this.supplierId,
    this.supplierNama = '',
    required this.qty,
    required this.tanggal,
    this.catatan,
  });

  Map<String, dynamic> toJson() => {
        'product': productId,
        'supplier': supplierId,
        'qty': qty,
        'tanggal': tanggal,
        'catatan': catatan ?? '',
      };

  factory StockInModel.fromJson(Map<String, dynamic> m) {
    final p = m['product'];
    final s = m['supplier'];
    return StockInModel(
      id: m['_id']?.toString(),
      productId: p is Map ? p['_id'].toString() : p.toString(),
      productNama: p is Map ? (p['nama'] ?? '') : '',
      productSatuan: p is Map ? (p['satuan'] ?? '') : '',
      supplierId: s is Map ? s['_id'].toString() : s.toString(),
      supplierNama: s is Map ? (s['nama'] ?? '') : '',
      qty: m['qty'] ?? 0,
      tanggal: m['tanggal'] ?? '',
      catatan: m['catatan'] ?? '',
    );
  }
}