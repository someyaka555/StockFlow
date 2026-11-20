import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import 'stock_in_page.dart';
import 'stock_out_page.dart';
import 'product_list_page.dart';

class UserDashboard extends StatelessWidget {
  const UserDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('StockFlow',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text('Mode User',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          if (auth.isAdmin)
            IconButton(
              tooltip: 'Mode Admin',
              icon: const Icon(Icons.admin_panel_settings_outlined),
              onPressed: () => auth.toggleMode(),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Yakin ingin keluar?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Batal')),
                    TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Keluar')),
                  ],
                ),
              );
              if (ok == true && context.mounted) auth.logout();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppTheme.primary.withOpacity(0.15),
                      child: const Icon(Icons.person, color: AppTheme.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(auth.user?.nama ?? '-',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('@${auth.user?.username ?? '-'}',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Menu',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  // Perbaikan: Mengirim Widget langsung, bukan fungsi ()
                  _menu(context, 'Barang Masuk', Icons.call_received,
                      AppTheme.success, const StockInPage()),
                  _menu(context, 'Barang Keluar', Icons.call_made,
                      AppTheme.danger, const StockOutPage()),
                  _menu(context, 'Produk', Icons.inventory, AppTheme.primary,
                      const ProductListPage()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi ini menerima parameter 'Widget page'
  Widget _menu(BuildContext c, String title, IconData icon, Color color, Widget page) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      // Perbaikan: Navigator.push langsung diletakkan di sini
      onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => page)),
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}