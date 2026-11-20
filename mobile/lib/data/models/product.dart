class ProductModel {
  final String? id;
  final String nama;
  final String kode;
  final int stokTotal;
  final String satuan;

  ProductModel({
    this.id,
    required this.nama,
    required this.kode,
    required this.stokTotal,
    required this.satuan,
  });

  Map<String, dynamic> toJson() => {
        'nama': nama,
        'kode': kode,
        'stokTotal': stokTotal,
        'satuan': satuan,
      };

  factory ProductModel.fromJson(Map<String, dynamic> m) => ProductModel(
        id: (m['_id'] ?? m['id'])?.toString(),
        nama: m['nama'] ?? '',
        kode: m['kode'] ?? '',
        stokTotal: (m['stokTotal'] ?? 0) as int,
        satuan: m['satuan'] ?? 'pcs',
      );
}