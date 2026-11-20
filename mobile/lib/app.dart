import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'ui/auth/login_page.dart';
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
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (!auth.isLoggedIn) return const LoginPage();
          if (auth.isAdmin && auth.adminMode) return const AdminDashboard();
          return const UserDashboard();
        },
      ),
    );
  }
}