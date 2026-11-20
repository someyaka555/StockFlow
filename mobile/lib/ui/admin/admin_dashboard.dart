import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../user/user_dashboard.dart';
import 'user_management_page.dart';
import 'product_management_page.dart';
import 'supplier_management_page.dart';
import 'settings_page.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

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
            Text('Mode Admin',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Mode User',
            icon: const Icon(Icons.swap_horiz),
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
          children: [
            Card(
              color: AppTheme.primary,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.admin_panel_settings,
                          color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Halo, ${auth.user?.nama ?? '-'}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          const Text('Administrator',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Panel Admin',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _menu(context, 'Kelola User', Icons.people,
                      const UserManagementPage()),
                  _menu(context, 'Kelola Produk', Icons.inventory_2,
                      const ProductManagementPage()),
                  _menu(context, 'Kelola Supplier', Icons.local_shipping,
                      const SupplierManagementPage()),
                  _menu(context, 'Pengaturan API', Icons.settings,
                      const SettingsPage()),
                  _menu(context, 'Mode User', Icons.person,
                      const UserDashboard(), isSwitch: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menu(BuildContext c, String title, IconData icon, Widget page,
      {bool isSwitch = false}) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        if (isSwitch) {
          c.read<AuthProvider>().toggleMode();
        } else {
          Navigator.push(c, MaterialPageRoute(builder: (_) => page));
        }
      },
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: AppTheme.primary),
            const SizedBox(height: 10),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}