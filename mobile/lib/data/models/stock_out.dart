class StockOutModel {
  final String? id;
  final String clientId;
  final String clientNama;
  final String productId;
  final String productNama;
  final int qty;
  final String tanggal;

  StockOutModel({
    this.id,
    required this.clientId,
    required this.clientNama,
    required this.productId,
    this.productNama = '',
    required this.qty,
    required this.tanggal,
  });

  Map<String, dynamic> toJson() => {
        'client': clientId,
        'product': productId,
        'qty': qty,
        'tanggal': tanggal,
      };

  factory StockOutModel.fromJson(Map<String, dynamic> m) {
    final p = m['product'];
    final c = m['client'];
    return StockOutModel(
      id: m['_id']?.toString(),
      clientId: c is Map ? c['_id'].toString() : c.toString(),
      clientNama: c is Map ? (c['nama'] ?? '') : '',
      productId: p is Map ? p['_id'].toString() : p.toString(),
      productNama: p is Map ? (p['nama'] ?? '') : '',
      qty: m['qty'] ?? 0,
      tanggal: m['tanggal'] ?? '',
    );
  }
}