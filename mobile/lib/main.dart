import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/auth_provider.dart';
import 'providers/settings_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()..load()),
        // AuthProvider menunggu SettingsProvider selesai load
        ChangeNotifierProxyProvider<SettingsProvider, AuthProvider>(
          create: (_) => AuthProvider(),
          update: (_, settings, auth) {
            // Init hanya dipanggil sekali saat settings selesai load
            if (settings.isLoaded) {
              auth?.init();
            }
            return auth!;
          },
        ),
      ],
      child: const StockFlowApp(),
    ),
  );
}