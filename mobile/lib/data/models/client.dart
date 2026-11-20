class ClientModel {
  final String? id;
  final String nama;
  final String kontak;
  final String alamat;

  ClientModel({
    this.id,
    required this.nama,
    this.kontak = '',
    this.alamat = '',
  });

  Map<String, dynamic> toJson() => {
        'nama': nama,
        'kontak': kontak,
        'alamat': alamat,
      };

  factory ClientModel.fromJson(Map<String, dynamic> m) => ClientModel(
        id: (m['_id'] ?? m['id'])?.toString(),
        nama: m['nama'] ?? '',
        kontak: m['kontak'] ?? '',
        alamat: m['alamat'] ?? '',
      );
}