class ProductModel {
  final String? id;
  final String nama;
  final String deskripsi;
  final double kg;
  final double harga;
  final int stokTotal;

  ProductModel({
    this.id,
    required this.nama,
    this.deskripsi = '',
    required this.kg,
    required this.harga,
    required this.stokTotal,
  });

  Map<String, dynamic> toJson() => {
        'nama': nama,
        'deskripsi': deskripsi,
        'kg': kg,
        'harga': harga,
        'stokTotal': stokTotal,
      };

  factory ProductModel.fromJson(Map<String, dynamic> m) => ProductModel(
        id: (m['_id'] ?? m['id'])?.toString(),
        nama: m['nama'] ?? '',
        deskripsi: m['deskripsi'] ?? '',
        kg: (m['kg'] ?? 0.0).toDouble(),
        harga: (m['harga'] ?? 0.0).toDouble(),
        stokTotal: m['stokTotal'] ?? 0,
      );
}