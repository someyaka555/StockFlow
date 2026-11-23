import '../api/api_client.dart';
import '../models/client.dart';

class ClientRepository {
  static final List<ClientModel> _mockClients = [
    ClientModel(id: 'c1', nama: 'Toko Berkah', kontak: '08123', alamat: 'Semarang', saldo: 500000),
    ClientModel(id: 'c2', nama: 'Warung Jaya', kontak: '08987', alamat: 'Jakarta', saldo: 0),
  ];

  Future<List<ClientModel>> getAll() async {
    if (AppConstants.authMode == 'local') return List.from(_mockClients);
    final res = await ApiClient().dio.get('/clients');
    return (res.data as List).map((e) => ClientModel.fromJson(e)).toList();
  }

  Future<void> create(ClientModel client) async {
    if (AppConstants.authMode == 'local') {
      _mockClients.add(ClientModel(
        id: 'c${_mockClients.length + 1}', nama: client.nama, kontak: client.kontak, alamat: client.alamat, saldo: client.saldo,
      ));
      return;
    }
    await ApiClient().dio.post('/clients', data: client.toJson());
  }

  Future<void> update(ClientModel client) async {
    if (AppConstants.authMode == 'local') {
      final i = _mockClients.indexWhere((e) => e.id == client.id);
      if (i >= 0) _mockClients[i] = client;
      return;
    }
    await ApiClient().dio.put('/clients/${client.id}', data: client.toJson());
  }

  Future<void> delete(String id) async {
    if (AppConstants.authMode == 'local') {
      _mockClients.removeWhere((e) => e.id == id);
      return;
    }
    await ApiClient().dio.delete('/clients/$id');
  }
}