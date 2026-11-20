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
  int _total = 0;
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
      _total = await _repo.count();
    } catch (_) {}
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola User')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAdd,
        icon: const Icon(Icons.person_add),
        label: const Text('Tambah'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.people),
                title: const Text('Total User'),
                trailing: Text('$_total',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20)),
              ),
            ),
          ),
          Expanded(
            child: _loading
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
                            child: Text(u.nama.isNotEmpty
                                ? u.nama[0].toUpperCase()
                                : '?'),
                          ),
                          title: Text(u.nama),
                          subtitle: Text('@${u.username} • ${u.role.name}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Hapus User'),
                                  content: Text('Hapus ${u.nama}?'),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Batal')),
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Hapus')),
                                  ],
                                ),
                              );
                              if (ok == true && u.id != null) {
                                await _repo.delete(u.id!);
                                _load();
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAdd() async {
    final u = TextEditingController();
    final p = TextEditingController();
    final n = TextEditingController();
    UserRole role = UserRole.user;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Tambah User'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: n,
                    decoration:
                        const InputDecoration(labelText: 'Nama Lengkap')),
                const SizedBox(height: 12),
                TextField(
                    controller: u,
                    decoration:
                        const InputDecoration(labelText: 'Username')),
                const SizedBox(height: 12),
                TextField(
                    controller: p,
                    obscureText: true,
                    decoration:
                        const InputDecoration(labelText: 'Password')),
                const SizedBox(height: 12),
                DropdownButtonFormField<UserRole>(
                  value: role,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: const [
                    DropdownMenuItem(
                        value: UserRole.user, child: Text('User')),
                    DropdownMenuItem(
                        value: UserRole.admin, child: Text('Admin')),
                  ],
                  onChanged: (v) => setS(() => role = v ?? UserRole.user),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                if (u.text.isEmpty || p.text.isEmpty || n.text.isEmpty) return;
                await _repo.create(
                  username: u.text.trim(),
                  password: p.text,
                  nama: n.text.trim(),
                  role: role,
                );
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
}