import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../data/models/stock_in.dart';
import '../../data/repositories/stock_repository.dart';

class DetailSupplierPage extends StatelessWidget {
  final String supplierNama;
  final DateTime date;
  const DetailSupplierPage({
    super.key,
    required this.supplierNama,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final repo = StockRepository();
    return Scaffold(
      appBar: AppBar(title: Text(supplierNama)),
      body: FutureBuilder<List<StockInModel>>(
        future: repo.getStockInByDate(DateFormat('yyyy-MM-dd').format(date)),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = (snap.data ?? [])
              .where((e) => e.supplierNama == supplierNama)
              .toList();
          if (items.isEmpty) {
            return const Center(child: Text('Tidak ada transaksi'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final it = items[i];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.success.withOpacity(0.15),
                    child: const Icon(Icons.inventory_2,
                        color: AppTheme.success),
                  ),
                  title: Text(it.productNama),
                  subtitle: Text('${it.tanggal} • ${it.productSatuan}'),
                  trailing: Text('+${it.qty}',
                      style: const TextStyle(
                          color: AppTheme.success,
                          fontWeight: FontWeight.bold)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}