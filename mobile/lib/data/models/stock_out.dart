class StockOutItem {
  final String productId;
  final String productNama;
  final String deskripsi;
  final double kg;
  final int pcs;
  final double harga;
  final double ppn;
  final double restitusi;
  final double subtotal;

  StockOutItem({
    required this.productId, required this.productNama, this.deskripsi = '',
    required this.kg, required this.pcs, required this.harga, 
    this.ppn = 0.0, this.restitusi = 0.0, required this.subtotal,
  });

  Map<String, dynamic> toJson() => {
        'product': productId, 'deskripsi': deskripsi, 'kg': kg, 'pcs': pcs,
        'harga': harga, 'ppn': ppn, 'restitusi': restitusi, 'subtotal': subtotal,
      };

  factory StockOutItem.fromJson(Map<String, dynamic> m) {
    final p = m['product'];
    return StockOutItem(
      productId: p is Map ? p['_id'].toString() : p.toString(),
      productNama: p is Map ? (p['nama'] ?? '') : '',
      deskripsi: m['deskripsi'] ?? '',
      kg: (m['kg'] ?? 0.0).toDouble(),
      pcs: m['pcs'] ?? 0,
      harga: (m['harga'] ?? 0.0).toDouble(),
      ppn: (m['ppn'] ?? 0.0).toDouble(),
      restitusi: (m['restitusi'] ?? 0.0).toDouble(),
      subtotal: (m['subtotal'] ?? 0.0).toDouble(),
    );
  }
}

class StockOutModel {
  final String? id;
  final String clientId;
  final String clientNama;
  final String tanggal;
  final List<StockOutItem> items;
  final double grandTotal;

  StockOutModel({
    this.id, required this.clientId, required this.clientNama, required this.tanggal, required this.items, required this.grandTotal,
  });

  Map<String, dynamic> toJson() => {
        'client': clientId, 'tanggal': tanggal, 'grandTotal': grandTotal,
        'items': items.map((e) => e.toJson()).toList(),
      };

  factory StockOutModel.fromJson(Map<String, dynamic> m) {
    final c = m['client'];
    var rawItems = m['items'] as List? ?? [];
    return StockOutModel(
      id: m['_id']?.toString(),
      clientId: c is Map ? c['_id'].toString() : c.toString(),
      clientNama: c is Map ? (c['nama'] ?? '') : '',
      tanggal: m['tanggal'] ?? '',
      grandTotal: (m['grandTotal'] ?? 0.0).toDouble(),
      items: rawItems.map((e) => StockOutItem.fromJson(e)).toList(),
    );
  }
}