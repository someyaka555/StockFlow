import '../../core/constants.dart';
import '../api/api_client.dart';
import '../models/client.dart';

class ClientRepository {
  static final List<ClientModel> _mockClients = [
    ClientModel(id: 'c1', nama: 'Toko Berkah Jaya', kontak: '08123456789', alamat: 'Jakarta'),
    ClientModel(id: 'c2', nama: 'Warung Sederhana', kontak: '08987654321', alamat: 'Bandung'),
  ];

  Future<List<ClientModel>> getAll() async {
    if (!AppConstants.useApi) return List.from(_mockClients);
    final res = await ApiClient().dio.get('/clients');
    return (res.data as List).map((e) => ClientModel.fromJson(e)).toList();
  }

  Future<void> create(ClientModel client) async {
    if (!AppConstants.useApi) {
      _mockClients.add(ClientModel(
        id: 'c${_mockClients.length + 1}',
        nama: client.nama,
        kontak: client.kontak,
        alamat: client.alamat,
      ));
      return;
    }
    await ApiClient().dio.post('/clients', data: client.toJson());
  }

  Future<void> update(ClientModel client) async {
    if (!AppConstants.useApi) {
      final index = _mockClients.indexWhere((e) => e.id == client.id);
      if (index >= 0) {
        _mockClients[index] = client;
      }
      return;
    }
    await ApiClient().dio.put('/clients/${client.id}', data: client.toJson());
  }

  Future<void> delete(String id) async {
    if (!AppConstants.useApi) {
      _mockClients.removeWhere((e) => e.id == id);
      return;
    }
    await ApiClient().dio.delete('/clients/$id');
  }
}