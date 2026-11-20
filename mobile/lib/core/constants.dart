class AppConstants {
  // URL API
  static String apiBaseUrl = 'http://10.0.2.2:3000/api';

  // 🔧 MODE TESTER: false = mock lokal (tanpa backend), true = API asli
  static bool useApi = false;

  // ==========================================
  // ⚠️ PENGATURAN KHUSUS TESTER (MODE MOCK)
  // ==========================================
  
  // Kode OTP yang berlaku saat mode tester
  static const String mockOtpCode = '0000';

  // Email yang didaftarkan di sini akan LANGSUNG masuk tanpa OTP
  static const List<String> mockVerifiedEmails = [
    'admin2@stockflow.com', // Bisa langsung login sebagai Admin
    'user2@stockflow.com',  // Bisa langsung login sebagai User
  ];
}