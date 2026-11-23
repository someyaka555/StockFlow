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

  // ============ BARANG MASUK ============
  Future<void> addStockIn(StockInModel s) async {
    if (AppConstants.authMode == 'local') { 
      _mockIn.insert(0, s);
      
      // Update stok (Tambah)
      final products = await ProductRepository().getAll();
      try {
        final p = products.firstWhere((e) => e.id == s.productId);
        await ProductRepository().update(ProductModel(
          id: p.id, nama: p.nama, deskripsi: p.deskripsi, kg: p.kg, harga: p.harga, stokTotal: p.stokTotal + s.total
        ));
      } catch (e) {
        print('Produk tidak ditemukan saat tambah StockIn (aman)');
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

        // Update stok (Hitung Delta)
        final products = await ProductRepository().getAll();
        try {
          final p = products.firstWhere((e) => e.id == newS.productId);
          final delta = newS.total - oldS.total;
          if (delta != 0) {
            await ProductRepository().update(ProductModel(
              id: p.id, nama: p.nama, deskripsi: p.deskripsi, kg: p.kg, harga: p.harga, stokTotal: p.stokTotal + delta
            ));
          }
        } catch (e) {
          print('Produk tidak ditemukan saat edit StockIn (aman)');
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

        // Kembalikan stok (Restore)
        final products = await ProductRepository().getAll();
        try {
          final p = products.firstWhere((e) => e.id == oldS.productId);
          await ProductRepository().update(ProductModel(
            id: p.id, nama: p.nama, deskripsi: p.deskripsi, kg: p.kg, harga: p.harga, stokTotal: p.stokTotal - oldS.total
          ));
        } catch (e) {
          print('Produk tidak ditemukan saat hapus StockIn (aman)');
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

  // ============ BARANG KELUAR ============
  Future<void> addStockOut(StockOutModel s) async {
    if (AppConstants.authMode == 'local') { 
      _mockOut.insert(0, s); 
      
      // Update stok produk (Kurangi) & Saldo client (Kurangi)
      final products = await ProductRepository().getAll();
      final clients = await ClientRepository().getAll();
      try {
        final p = products.firstWhere((e) => e.id == s.productId);
        await ProductRepository().update(ProductModel(
          id: p.id, nama: p.nama, deskripsi: p.deskripsi, kg: p.kg, harga: p.harga, stokTotal: p.stokTotal - s.pcs
        ));
      } catch (e) { print('Produk tidak ditemukan saat tambah StockOut (aman)'); }

      try {
        final c = clients.firstWhere((e) => e.id == s.clientId);
        await ClientRepository().update(ClientModel(
          id: c.id, nama: c.nama, kontak: c.kontak, alamat: c.alamat, saldo: c.saldo - s.total
        ));
      } catch (e) { print('Client tidak ditemukan saat tambah StockOut (aman)'); }
      
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

        // Update stok produk (Hitung Delta)
        final products = await ProductRepository().getAll();
        final clients = await ClientRepository().getAll();
        try {
          final p = products.firstWhere((e) => e.id == newS.productId);
          final delta = newS.pcs - oldS.pcs;
          if (delta != 0) {
            await ProductRepository().update(ProductModel(
              id: p.id, nama: p.nama, deskripsi: p.deskripsi, kg: p.kg, harga: p.harga, stokTotal: p.stokTotal - delta
            ));
          }
        } catch (e) { print('Produk tidak ditemukan saat edit StockOut (aman)'); }

        // Update saldo client (Hitung Delta)
        try {
          final c = clients.firstWhere((e) => e.id == newS.clientId);
          final deltaSaldo = newS.total - oldS.total;
          if (deltaSaldo != 0) {
            await ClientRepository().update(ClientModel(
              id: c.id, nama: c.nama, kontak: c.kontak, alamat: c.alamat, saldo: c.saldo - deltaSaldo
            ));
          }
        } catch (e) { print('Client tidak ditemukan saat edit StockOut (aman)'); }
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

        // Kembalikan stok produk & Saldo Client
        final products = await ProductRepository().getAll();
        final clients = await ClientRepository().getAll();
        try {
          final p = products.firstWhere((e) => e.id == oldS.productId);
          await ProductRepository().update(ProductModel(
            id: p.id, nama: p.nama, deskripsi: p.deskripsi, kg: p.kg, harga: p.harga, stokTotal: p.stokTotal + oldS.pcs
          ));
        } catch (e) { print('Produk tidak ditemukan saat hapus StockOut (aman)'); }

        try {
          final c = clients.firstWhere((e) => e.id == oldS.clientId);
          await ClientRepository().update(ClientModel(
            id: c.id, nama: c.nama, kontak: c.kontak, alamat: c.alamat, saldo: c.saldo + oldS.total
          ));
        } catch (e) { print('Client tidak ditemukan saat hapus StockOut (aman)'); }
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
}