class AppConstants {
  // Base URL API (bisa diubah dari halaman Pengaturan)
  // 10.0.2.2 = localhost dari emulator Android
  static String apiBaseUrl = 'http://10.0.2.2:3000/api';

  // true = pakai API server, false = pakai mock lokal (tester)
  static bool useApi = false;
}