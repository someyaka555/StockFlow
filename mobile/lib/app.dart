import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'ui/auth/login_page.dart';
import 'ui/auth/verify_page.dart'; // <-- Import halaman verifikasi
import 'ui/admin/admin_dashboard.dart';
import 'ui/user/user_dashboard.dart';

class StockFlowApp extends StatelessWidget {
  const StockFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StockFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.loading) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          
          // 1. Jika belum login, ke halaman Login
          if (!auth.isLoggedIn) return const LoginPage();
          
          // 2. Jika butuh verifikasi, ke halaman Verify
          if (auth.needsVerification) return const VerifyPage();
          
          // 3. Jika Admin mode, ke Admin Dashboard
          if (auth.isAdmin && auth.adminMode) return const AdminDashboard();
          
          // 4. Jika User, ke User Dashboard
          return const UserDashboard();
        },
      ),
    );
  }
}