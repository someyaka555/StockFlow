class ClientModel {
  final String? id;
  final String nama;
  final String kontak;
  final String alamat;
  final double saldo;

  ClientModel({
    this.id,
    required this.nama,
    this.kontak = '',
    this.alamat = '',
    this.saldo = 0.0,
  });

  Map<String, dynamic> toJson() => {
        'nama': nama,
        'kontak': kontak,
        'alamat': alamat,
        'saldo': saldo,
      };

  factory ClientModel.fromJson(Map<String, dynamic> m) => ClientModel(
        id: (m['_id'] ?? m['id'])?.toString(),
        nama: m['nama'] ?? '',
        kontak: m['kontak'] ?? '',
        alamat: m['alamat'] ?? '',
        saldo: (m['saldo'] ?? 0.0).toDouble(),
      );
}