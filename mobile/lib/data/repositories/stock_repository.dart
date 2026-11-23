import '../../core/constants.dart';
import '../api/api_client.dart';
import '../models/stock_in.dart';
import '../models/stock_out.dart';

class StockRepository {
  static final List<StockInModel> _mockIn = [];
  static final List<StockOutModel> _mockOut = [];

  // ============ BARANG MASUK ============
  Future<void> addStockIn(StockInModel s) async {
    if (AppConstants.authMode == 'local') { _mockIn.insert(0, s); return; }
    await ApiClient().dio.post('/stock/in', data: s.toJson());
  }

  Future<void> updateStockIn(StockInModel s) async {
    if (AppConstants.authMode == 'local') {
      final i = _mockIn.indexWhere((e) => e.id == s.id);
      if (i >= 0) _mockIn[i] = s;
      return;
    }
    await ApiClient().dio.put('/stock/in/${s.id}', data: s.toJson());
  }

  Future<void> deleteStockIn(String id) async {
    if (AppConstants.authMode == 'local') { _mockIn.removeWhere((e) => e.id == id); return; }
    await ApiClient().dio.delete('/stock/in/$id');
  }

  Future<List<StockInModel>> getStockInByDate(String date) async {
    if (AppConstants.authMode == 'local') return _mockIn.where((e) => e.tanggal == date).toList();
    final res = await ApiClient().dio.get('/stock/in', queryParameters: {'tanggal': date});
    return (res.data as List).map((e) => StockInModel.fromJson(e)).toList();
  }

  // ============ BARANG KELUAR ============
  Future<void> addStockOut(StockOutModel s) async {
    if (AppConstants.authMode == 'local') { _mockOut.insert(0, s); return; }
    await ApiClient().dio.post('/stock/out', data: s.toJson());
  }

  Future<void> updateStockOut(StockOutModel s) async {
    if (AppConstants.authMode == 'local') {
      final i = _mockOut.indexWhere((e) => e.id == s.id);
      if (i >= 0) _mockOut[i] = s;
      return;
    }
    await ApiClient().dio.put('/stock/out/${s.id}', data: s.toJson());
  }

  Future<void> deleteStockOut(String id) async {
    if (AppConstants.authMode == 'local') { _mockOut.removeWhere((e) => e.id == id); return; }
    await ApiClient().dio.delete('/stock/out/$id');
  }

  Future<List<StockOutModel>> getStockOutByDate(String date) async {
    if (AppConstants.authMode == 'local') return _mockOut.where((e) => e.tanggal == date).toList();
    final res = await ApiClient().dio.get('/stock/out', queryParameters: {'tanggal': date});
    return (res.data as List).map((e) => StockOutModel.fromJson(e)).toList();
  }
}