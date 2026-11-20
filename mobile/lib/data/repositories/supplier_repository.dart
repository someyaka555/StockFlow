import '../../core/constants.dart';
import '../api/api_client.dart';
import '../models/supplier.dart';

class SupplierRepository {
  Future<List<SupplierModel>> getAll() async {
    if (!AppConstants.useApi) return List.from(_mock);
    final res = await ApiClient().dio.get('/suppliers');
    return (res.data as List).map((e) => SupplierModel.fromJson(e)).toList();
  }

  Future<void> create(SupplierModel s) async {
    if (!AppConstants.useApi) {
      _mock.add(SupplierModel(
        id: 's${_mock.length + 1}',
        nama: s.nama,
        alamat: s.alamat,
        kontak: s.kontak,
      ));
      return;
    }
    await ApiClient().dio.post('/suppliers', data: s.toJson());
  }

  Future<void> delete(String id) async {
    if (!AppConstants.useApi) {
      _mock.removeWhere((e) => e.id == id);
      return;
    }
    await ApiClient().dio.delete('/suppliers/$id');
  }

  static final List<SupplierModel> _mock = [
    SupplierModel(id: 's1', nama: 'PT Sumber Jaya', alamat: 'Jakarta', kontak: '0812345'),
    SupplierModel(id: 's2', nama: 'CV Makmur Abadi', alamat: 'Bandung', kontak: '0823456'),
  ];
}