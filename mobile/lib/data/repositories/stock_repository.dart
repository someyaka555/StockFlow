import '../../core/constants.dart';
import '../api/api_client.dart';
import '../models/stock_in.dart';
import '../models/stock_out.dart';

class StockRepository {
  static final List<StockInModel> _mockIn = [];
  static final List<StockOutModel> _mockOut = [];

  Future<void> addStockIn(StockInModel s) async {
    if (!AppConstants.useApi) {
      _mockIn.insert(0, s);
      return;
    }
    await ApiClient().dio.post('/stock/in', data: s.toJson());
  }

  Future<List<StockInModel>> getStockInByDate(String date) async {
    if (!AppConstants.useApi) {
      return _mockIn.where((e) => e.tanggal == date).toList();
    }
    final res = await ApiClient().dio.get('/stock/in', queryParameters: {'tanggal': date});
    return (res.data as List).map((e) => StockInModel.fromJson(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getStockInSummaryByDate(String date) async {
    if (!AppConstants.useApi) {
      final filtered = _mockIn.where((e) => e.tanggal == date);
      final Map<String, int> grouped = {};
      for (final item in filtered) {
        grouped[item.clientNama] = (grouped[item.clientNama] ?? 0) + item.qty;
      }
      return grouped.entries.map((e) => {'client_nama': e.key, 'total': e.value}).toList();
    }
    final res = await ApiClient().dio.get('/stock/in/summary', queryParameters: {'tanggal': date});
    return (res.data as List).map((e) => {'client_nama': e['clientNama'], 'total': e['total']}).toList();
  }

  Future<void> addStockOut(StockOutModel s) async {
    if (!AppConstants.useApi) {
      _mockOut.insert(0, s);
      return;
    }
    await ApiClient().dio.post('/stock/out', data: s.toJson());
  }

  Future<List<StockOutModel>> getStockOutByDate(String date) async {
    if (!AppConstants.useApi) {
      return _mockOut.where((e) => e.tanggal == date).toList();
    }
    final res = await ApiClient().dio.get('/stock/out', queryParameters: {'tanggal': date});
    return (res.data as List).map((e) => StockOutModel.fromJson(e)).toList();
  }
}