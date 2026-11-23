import 'package:flutter/material.dart';
import '../../data/models/client.dart';
import '../../data/repositories/client_repository.dart';

class ClientManagementPage extends StatefulWidget {
  const ClientManagementPage({super.key});
  @override
  State<ClientManagementPage> createState() => _ClientManagementPageState();
}

class _ClientManagementPageState extends State<ClientManagementPage> {
  final _repo = ClientRepository();
  List<ClientModel> _items = [];
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

  String _fmt(double val) => val == val.roundToDouble() ? val.toInt().toString() : val.toString();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Client')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Client'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final c = _items[i];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.storefront),
                    title: Text(c.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${c.alamat} • ${c.kontak}\nSaldo: Rp ${_fmt(c.saldo)}'),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.account_balance_wallet, color: Colors.green),
                          onPressed: () => _showSaldoDialog(c),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showFormDialog(client: c),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _showSaldoDialog(ClientModel client) async {
    final amount = TextEditingController();
    bool isAddition = true;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text('Saldo ${client.nama}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Saldo saat ini: Rp ${_fmt(client.saldo)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Tambah'),
                      value: true,
                      groupValue: isAddition,
                      onChanged: (v) => setS(() => isAddition = v!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Kurang'),
                      value: false,
                      groupValue: isAddition,
                      onChanged: (v) => setS(() => isAddition = v!),
                    ),
                  ),
                ],
              ),
              TextField(
                controller: amount,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Nominal (Rp)'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                final val = double.tryParse(amount.text) ?? 0;
                if (val <= 0) return;
                
                final newSaldo = isAddition ? (client.saldo + val) : (client.saldo - val);
                final updated = ClientModel(
                  id: client.id, nama: client.nama, kontak: client.kontak, alamat: client.alamat, saldo: newSaldo
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

  Future<void> _showFormDialog({ClientModel? client}) async {
    final n = TextEditingController(text: client?.nama ?? '');
    final a = TextEditingController(text: client?.alamat ?? '');
    final k = TextEditingController(text: client?.kontak ?? '');

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(client == null ? 'Tambah Client' : 'Edit Client'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: n, decoration: const InputDecoration(labelText: 'Nama Client')),
              const SizedBox(height: 12),
              TextField(controller: a, decoration: const InputDecoration(labelText: 'Alamat')),
              const SizedBox(height: 12),
              TextField(controller: k, decoration: const InputDecoration(labelText: 'Kontak/No HP')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              if (n.text.isEmpty) return;
              final model = ClientModel(
                id: client?.id,
                nama: n.text.trim(),
                alamat: a.text.trim(),
                kontak: k.text.trim(),
                saldo: client?.saldo ?? 0.0,
              );
              
              if (client == null) {
                await _repo.create(model);
              } else {
                await _repo.update(model);
              }
              if (mounted) Navigator.pop(context);
              _load();
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}