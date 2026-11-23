import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'ui/auth/login_page.dart';
import 'ui/auth/verify_page.dart';
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
      home: const AuthGate(), // Pindahkan logic ke widget terpisah
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        // 1. Loading State
        if (auth.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        // 2. Belum Login
        if (!auth.isLoggedIn) {
          return const LoginPage();
        }
        
        // 3. Butuh Verifikasi
        if (auth.needsVerification) {
          return const VerifyPage();
        }
        
        // 4. Admin Mode
        if (auth.isAdmin && auth.adminMode) {
          return const AdminDashboard();
        }
        
        // 5. User Mode
        return const UserDashboard();
      },
    );
  }
}