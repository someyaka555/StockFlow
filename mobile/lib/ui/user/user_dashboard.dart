import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import 'stock_in_page.dart';
import 'stock_out_page.dart';
import 'product_management_page.dart';
import 'client_management_page.dart';
import 'user_settings_page.dart';

class UserDashboard extends StatelessWidget {
  const UserDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Keluar Aplikasi'),
            content: const Text('Yakin ingin keluar?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Keluar')),
            ],
          ),
        );
        if (shouldPop == true && context.mounted) SystemNavigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text('Mode User', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) async {
                if (value == 'settings') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const UserSettingsPage()));
                } else if (value == 'logout') {
                  auth.logout();
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'settings', 
                  child: ListTile(leading: Icon(Icons.lock_outline), title: Text('Ganti Sandi'))
                ),
                const PopupMenuItem<String>(
                  value: 'logout', 
                  child: ListTile(leading: Icon(Icons.logout, color: Colors.red), title: Text('Logout', style: TextStyle(color: Colors.red)))
                ),
              ],
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
                            Text(auth.user?.username ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(auth.user?.email ?? '-', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Menu Utama', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _menu(context, 'Barang Masuk', Icons.call_received, AppTheme.success, const StockInPage()),
                    _menu(context, 'Barang Keluar', Icons.call_made, AppTheme.danger, const StockOutPage()),
                    _menu(context, 'Kelola Produk', Icons.inventory_2, AppTheme.primary, const ProductManagementPage()),
                    _menu(context, 'Kelola Client', Icons.storefront, Colors.orange, const ClientManagementPage()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menu(BuildContext c, String title, IconData icon, Color color, Widget page) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => page)),
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}