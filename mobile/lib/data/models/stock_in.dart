class StockInModel {
  final String? id;
  final String productId;
  final String productNama;
  final String productSatuan;
  final String clientId;
  final String clientNama;
  final int qty;
  final String tanggal;
  final String? catatan;

  StockInModel({
    this.id,
    required this.productId,
    this.productNama = '',
    this.productSatuan = '',
    required this.clientId,
    this.clientNama = '',
    required this.qty,
    required this.tanggal,
    this.catatan,
  });

  Map<String, dynamic> toJson() => {
        'product': productId,
        'client': clientId,
        'qty': qty,
        'tanggal': tanggal,
        'catatan': catatan ?? '',
      };

  factory StockInModel.fromJson(Map<String, dynamic> m) {
    final p = m['product'];
    final c = m['client'];
    return StockInModel(
      id: m['_id']?.toString(),
      productId: p is Map ? p['_id'].toString() : p.toString(),
      productNama: p is Map ? (p['nama'] ?? '') : '',
      productSatuan: p is Map ? (p['satuan'] ?? '') : '',
      clientId: c is Map ? c['_id'].toString() : c.toString(),
      clientNama: c is Map ? (c['nama'] ?? '') : '',
      qty: m['qty'] ?? 0,
      tanggal: m['tanggal'] ?? '',
      catatan: m['catatan'] ?? '',
    );
  }
}