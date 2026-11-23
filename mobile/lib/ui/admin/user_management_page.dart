import 'package:flutter/material.dart';
import '../../data/models/user.dart';
import '../../data/repositories/user_repository.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});
  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final _repo = UserRepository();
  List<UserModel> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _items = await _repo.getAll();
    } catch (_) {}
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola User')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final u = _items[i];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: u.isBlocked ? Colors.red.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
                      child: Text(u.username.isNotEmpty ? u.username[0].toUpperCase() : '?'),
                    ),
                    title: Text(u.username, style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: u.isBlocked ? TextDecoration.lineThrough : null,
                    )),
                    subtitle: Text('${u.email} • ${u.role.name}'),
                    trailing: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) async {
                        if (value == 'detail') {
                          _showDetailDialog(u);
                        } else if (value == 'delete') {
                          _deleteUser(u);
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'detail', child: Text('Detail')),
                        const PopupMenuItem(value: 'delete', child: Text('Hapus', style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showDetailDialog(UserModel u) async {
    bool isObscure = true;
    
    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Detail User', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('ID Account', u.id ?? '-'),
                const SizedBox(height: 12),
                _buildDetailRow('Username', u.username),
                const SizedBox(height: 12),
                _buildDetailRow('Email', u.email),
                const SizedBox(height: 12),
                // Show/Hide Sandi
                Row(
                  children: [
                    const Text('Sandi: ', style: TextStyle(color: Colors.grey)),
                    const Expanded(child: Text('password123', style: TextStyle(fontWeight: FontWeight.w500))),
                    IconButton(
                      icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility, size: 20),
                      onPressed: () => setS(() => isObscure = !isObscure),
                    ),
                  ],
                ),
                const Divider(height: 24),
                // Switch Blokir
                SwitchListTile(
                  title: const Text('Blokir User'),
                  value: u.isBlocked,
                  onChanged: (val) async {
                    final updated = UserModel(
                      id: u.id, username: u.username, email: u.email, 
                      role: u.role, isVerified: u.isVerified, isBlocked: val
                    );
                    await _repo.update(updated);
                    if (mounted) {
                      Navigator.pop(ctx);
                      _load();
                    }
                  },
                ),
                // Switch Role Admin
                SwitchListTile(
                  title: const Text('Jadikan Admin'),
                  value: u.role == UserRole.admin,
                  onChanged: (val) async {
                    final updated = UserModel(
                      id: u.id, username: u.username, email: u.email, 
                      role: val ? UserRole.admin : UserRole.user, isVerified: u.isVerified, isBlocked: u.isBlocked
                    );
                    await _repo.update(updated);
                    if (mounted) {
                      Navigator.pop(ctx);
                      _load();
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup')),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
      ],
    );
  }

  Future<void> _deleteUser(UserModel u) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Yakin ingin menghapus user ${u.username}? Tindakan ini tidak bisa dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true && u.id != null) {
      await _repo.delete(u.id!);
      _load();
    }
  }
}