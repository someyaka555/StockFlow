class StockOutModel {
  final String? id;
  final String clientNama;
  final String clientKontak;
  final String productId;
  final String productNama;
  final int qty;
  final String tanggal;

  StockOutModel({
    this.id,
    required this.clientNama,
    required this.clientKontak,
    required this.productId,
    this.productNama = '',
    required this.qty,
    required this.tanggal,
  });

  Map<String, dynamic> toJson() => {
        'clientNama': clientNama,
        'clientKontak': clientKontak,
        'product': productId,
        'qty': qty,
        'tanggal': tanggal,
      };

  factory StockOutModel.fromJson(Map<String, dynamic> m) {
    final p = m['product'];
    return StockOutModel(
      id: m['_id']?.toString(),
      clientNama: m['clientNama'] ?? '',
      clientKontak: m['clientKontak'] ?? '',
      productId: p is Map ? p['_id'].toString() : p.toString(),
      productNama: p is Map ? (p['nama'] ?? '') : '',
      qty: m['qty'] ?? 0,
      tanggal: m['tanggal'] ?? '',
    );
  }
}