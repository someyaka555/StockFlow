import '../../core/constants.dart';
import '../api/api_client.dart';
import '../models/product.dart';

class ProductRepository {
  static final List<ProductModel> _mock = [
    ProductModel(id: 'p1', nama: 'Semen Tiga Roda', deskripsi: 'Semen 50kg', kg: 50.0, satuan: 'sak', harga: 65000, stokTotal: 100),
    ProductModel(id: 'p2', nama: 'Pasir Merapi', deskripsi: 'Pasir halus', kg: 25.0, satuan: 'karung', harga: 35000, stokTotal: 50),
  ];

  Future<List<ProductModel>> getAll() async {
    if (!AppConstants.useApi) return List.from(_mock);
    final res = await ApiClient().dio.get('/products');
    return (res.data as List).map((e) => ProductModel.fromJson(e)).toList();
  }

  Future<void> create(ProductModel p) async {
    if (!AppConstants.useApi) {
      _mock.add(ProductModel(
        id: 'p${_mock.length + 1}', nama: p.nama, deskripsi: p.deskripsi, kg: p.kg, satuan: p.satuan, harga: p.harga, stokTotal: p.stokTotal,
      ));
      return;
    }
    await ApiClient().dio.post('/products', data: p.toJson());
  }

  Future<void> update(ProductModel p) async {
    if (!AppConstants.useApi) {
      final i = _mock.indexWhere((e) => e.id == p.id);
      if (i >= 0) _mock[i] = p;
      return;
    }
    await ApiClient().dio.put('/products/${p.id}', data: p.toJson());
  }

  Future<void> delete(String id) async {
    if (!AppConstants.useApi) {
      _mock.removeWhere((e) => e.id == id);
      return;
    }
    await ApiClient().dio.delete('/products/$id');
  }
}