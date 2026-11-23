import '../../core/constants.dart';
import '../api/api_client.dart';
import '../models/product.dart';
import '../models/client.dart';
import '../models/stock_in.dart';
import '../models/stock_out.dart';
import 'product_repository.dart';
import 'client_repository.dart';

class StockRepository {
  static final List<StockInModel> _mockIn = [];
  static final List<StockOutModel> _mockOut = [];

  // ============ BARANG MASUK (MULTI-ITEM) ============
  Future<void> addStockIn(StockInModel s) async {
    if (AppConstants.authMode == 'local') { 
      _mockIn.insert(0, s);
      // Looping semua produk dalam nota, tambah stok
      for (var item in s.items) {
        await _updateProductStock(item.productId, item.total); 
      }
      return; 
    }
    await ApiClient().dio.post('/stock/in', data: s.toJson());
  }

  Future<void> updateStockIn(StockInModel newS) async {
    if (AppConstants.authMode == 'local') {
      final i = _mockIn.indexWhere((e) => e.id == newS.id);
      if (i >= 0) {
        final oldS = _mockIn[i];
        _mockIn[i] = newS;

        // 1. Kembalikan stok lama (kurangi stok)
        for (var oldItem in oldS.items) {
          await _updateProductStock(oldItem.productId, -oldItem.total);
        }
        
        // 2. Terapkan stok baru (tambah stok)
        for (var newItem in newS.items) {
          await _updateProductStock(newItem.productId, newItem.total);
        }
      }
      return;
    }
    await ApiClient().dio.put('/stock/in/${newS.id}', data: newS.toJson());
  }

  Future<void> deleteStockIn(String id) async {
    if (AppConstants.authMode == 'local') { 
      final i = _mockIn.indexWhere((e) => e.id == id);
      if (i >= 0) {
        final oldS = _mockIn[i];
        _mockIn.removeAt(i);
        // Kembalikan semua stok produk yang ada di nota ini
        for (var oldItem in oldS.items) {
          await _updateProductStock(oldItem.productId, -oldItem.total); 
        }
      }
      return; 
    }
    await ApiClient().dio.delete('/stock/in/$id');
  }

  Future<List<StockInModel>> getStockInByDate(String date) async {
    if (AppConstants.authMode == 'local') return _mockIn.where((e) => e.tanggal == date).toList();
    final res = await ApiClient().dio.get('/stock/in', queryParameters: {'tanggal': date});
    return (res.data as List).map((e) => StockInModel.fromJson(e)).toList();
  }

  // ============ BARANG KELUAR (MULTI-ITEM) ============
  Future<void> addStockOut(StockOutModel s) async {
    if (AppConstants.authMode == 'local') { 
      _mockOut.insert(0, s); 
      for (var item in s.items) {
        await _updateProductStock(item.productId, -item.pcs);
      }
      await _updateClientSaldo(s.clientId, -s.grandTotal); 
      return; 
    }
    await ApiClient().dio.post('/stock/out', data: s.toJson());
  }

  Future<void> updateStockOut(StockOutModel newS) async {
    if (AppConstants.authMode == 'local') {
      final i = _mockOut.indexWhere((e) => e.id == newS.id);
      if (i >= 0) {
        final oldS = _mockOut[i];
        _mockOut[i] = newS;
        
        // 1. Kembalikan stok & saldo lama
        for (var oldItem in oldS.items) {
          await _updateProductStock(oldItem.productId, oldItem.pcs);
        }
        await _updateClientSaldo(oldS.clientId, oldS.grandTotal);

        // 2. Terapkan stok & saldo baru
        for (var newItem in newS.items) {
          await _updateProductStock(newItem.productId, -newItem.pcs);
        }
        await _updateClientSaldo(newS.clientId, -newS.grandTotal);
      }
      return;
    }
    await ApiClient().dio.put('/stock/out/${newS.id}', data: newS.toJson());
  }

  Future<void> deleteStockOut(String id) async {
    if (AppConstants.authMode == 'local') { 
      final i = _mockOut.indexWhere((e) => e.id == id);
      if (i >= 0) {
        final oldS = _mockOut[i];
        _mockOut.removeAt(i);
        // Kembalikan stok & saldo
        for (var oldItem in oldS.items) {
          await _updateProductStock(oldItem.productId, oldItem.pcs);
        }
        await _updateClientSaldo(oldS.clientId, oldS.grandTotal);
      }
      return; 
    }
    await ApiClient().dio.delete('/stock/out/$id');
  }

  Future<List<StockOutModel>> getStockOutByDate(String date) async {
    if (AppConstants.authMode == 'local') return _mockOut.where((e) => e.tanggal == date).toList();
    final res = await ApiClient().dio.get('/stock/out', queryParameters: {'tanggal': date});
    return (res.data as List).map((e) => StockOutModel.fromJson(e)).toList();
  }

  // ============ FUNGSI BANTUAN ============
  Future<void> _updateProductStock(String productId, int delta) async {
    final products = await ProductRepository().getAll();
    try {
      final p = products.firstWhere((e) => e.id == productId);
      final newStok = p.stokTotal + delta;
      await ProductRepository().update(ProductModel(
        id: p.id, nama: p.nama, deskripsi: p.deskripsi, kg: p.kg, harga: p.harga, 
        stokTotal: newStok < 0 ? 0 : newStok // Cegah stok minus
      ));
    } catch (e) {
      print('Gagal update stok: Produk tidak ditemukan.');
    }
  }

  Future<void> _updateClientSaldo(String clientId, double delta) async {
    final clients = await ClientRepository().getAll();
    try {
      final c = clients.firstWhere((e) => e.id == clientId);
      await ClientRepository().update(ClientModel(
        id: c.id, nama: c.nama, kontak: c.kontak, alamat: c.alamat, 
        saldo: c.saldo + delta
      ));
    } catch (e) {
      print('Gagal update saldo: Client tidak ditemukan.');
    }
  }
}