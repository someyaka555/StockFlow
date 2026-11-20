class SupplierModel {
  final String? id;
  final String nama;
  final String alamat;
  final String kontak;

  SupplierModel({
    this.id,
    required this.nama,
    this.alamat = '',
    this.kontak = '',
  });

  Map<String, dynamic> toJson() => {
        'nama': nama,
        'alamat': alamat,
        'kontak': kontak,
      };

  factory SupplierModel.fromJson(Map<String, dynamic> m) => SupplierModel(
        id: (m['_id'] ?? m['id'])?.toString(),
        nama: m['nama'] ?? '',
        alamat: m['alamat'] ?? '',
        kontak: m['kontak'] ?? '',
      );
}