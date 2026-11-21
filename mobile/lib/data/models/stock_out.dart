class StockOutModel {
  final String? id;
  final String clientId;
  final String clientNama;
  final String productId;
  final String productNama;
  final String deskripsi;
  final double kg;
  final int pcs;
  final double harga;
  final double total;
  final String tanggal;

  StockOutModel({
    this.id,
    required this.clientId,
    required this.clientNama,
    required this.productId,
    required this.productNama,
    this.deskripsi = '',
    required this.kg,
    required this.pcs,
    required this.harga,
    required this.total,
    required this.tanggal,
  });

  Map<String, dynamic> toJson() => {
        'client': clientId,
        'product': productId,
        'deskripsi': deskripsi,
        'kg': kg,
        'pcs': pcs,
        'harga': harga,
        'total': total,
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
      deskripsi: m['deskripsi'] ?? '',
      kg: (m['kg'] ?? 0.0).toDouble(),
      pcs: m['pcs'] ?? 0,
      harga: (m['harga'] ?? 0.0).toDouble(),
      total: (m['total'] ?? 0.0).toDouble(),
      tanggal: m['tanggal'] ?? '',
    );
  }
}