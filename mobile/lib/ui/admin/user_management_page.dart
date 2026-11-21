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
                        } else if (value == 'edit') {
                          _showEditDialog(u);
                        } else if (value == 'block') {
                          _toggleBlock(u);
                        } else if (value == 'delete') {
                          _deleteUser(u);
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'detail', child: Text('Lihat Detail')),
                        const PopupMenuItem(value: 'edit', child: Text('Edit Role')),
                        PopupMenuItem(value: 'block', child: Text(u.isBlocked ? 'Buka Blokir' : 'Blokir User')),
                        const PopupMenuItem(value: 'delete', child: Text('Hapus', style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showDetailDialog(UserModel u) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Detail User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nama: ${u.username}'),
            Text('Email: ${u.email}'),
            Text('Sandi: (Simulasi: password123)'), // Di mode tester, kita tampilkan sandi default
            Text('Role: ${u.role.name}'),
            Text('Status: ${u.isBlocked ? "Diblokir" : "Aktif"}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(UserModel u) async {
    UserRole selectedRole = u.role;
    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text('Edit Role: ${u.username}'),
          content: DropdownButtonFormField<UserRole>(
            value: selectedRole,
            decoration: const InputDecoration(labelText: 'Role'),
            items: const [
              DropdownMenuItem(value: UserRole.user, child: Text('User')),
              DropdownMenuItem(value: UserRole.admin, child: Text('Admin')),
            ],
            onChanged: (v) => setS(() => selectedRole = v ?? UserRole.user),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                final updated = UserModel(
                  id: u.id, username: u.username, email: u.email, 
                  role: selectedRole, isVerified: u.isVerified, isBlocked: u.isBlocked
                );
                await _repo.update(updated);
                if (mounted) Navigator.pop(ctx);
                _load();
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleBlock(UserModel u) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: Text('Yakin ingin ${u.isBlocked ? "membuka blokir" : "memblokir"} user ${u.username}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ya')),
        ],
      ),
    );

    if (confirm == true) {
      final updated = UserModel(
        id: u.id, username: u.username, email: u.email, 
        role: u.role, isVerified: u.isVerified, isBlocked: !u.isBlocked
      );
      await _repo.update(updated);
      _load();
    }
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