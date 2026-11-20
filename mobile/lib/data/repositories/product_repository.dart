import '../../core/constants.dart';
import '../api/api_client.dart';
import '../models/product.dart';

class ProductRepository {
  Future<List<ProductModel>> getAll() async {
    if (!AppConstants.useApi) return List.from(_mock);
    final res = await ApiClient().dio.get('/products');
    return (res.data as List).map((e) => ProductModel.fromJson(e)).toList();
  }

  Future<void> create(ProductModel p) async {
    if (!AppConstants.useApi) {
      _mock.add(ProductModel(
        id: 'p${_mock.length + 1}',
        nama: p.nama,
        kode: p.kode,
        stokTotal: p.stokTotal,
        satuan: p.satuan,
      ));
      return;
    }
    await ApiClient().dio.post('/products', data: p.toJson());
  }

  Future<void> updateStock(String id, int stokTotal) async {
    if (!AppConstants.useApi) {
      final i = _mock.indexWhere((e) => e.id == id);
      if (i >= 0) {
        final old = _mock[i];
        _mock[i] = ProductModel(
          id: old.id,
          nama: old.nama,
          kode: old.kode,
          stokTotal: stokTotal,
          satuan: old.satuan,
        );
      }
      return;
    }
    await ApiClient().dio.put('/products/$id/stock', data: {'stokTotal': stokTotal});
  }

  Future<void> delete(String id) async {
    if (!AppConstants.useApi) {
      _mock.removeWhere((e) => e.id == id);
      return;
    }
    await ApiClient().dio.delete('/products/$id');
  }

  static final List<ProductModel> _mock = [
    ProductModel(id: 'p1', nama: 'Produk A', kode: 'PRD-A', stokTotal: 100, satuan: 'pcs'),
    ProductModel(id: 'p2', nama: 'Produk B', kode: 'PRD-B', stokTotal: 50, satuan: 'box'),
  ];
}