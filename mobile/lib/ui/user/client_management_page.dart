import 'package:flutter/material.dart';
import '../../core/helpers.dart';
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
    try { _items = await _repo.getAll(); } catch (_) {}
    setState(() => _loading = false);
  }

  void _showNotif(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

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
          : _items.isEmpty
              ? const Center(child: Text('Belum ada client'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final c = _items[i];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 60, height: 60,
                              decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), shape: BoxShape.circle),
                              child: const Icon(Icons.storefront, color: Colors.orange, size: 32),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(c.nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text('${c.alamat} • ${c.kontak}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                    child: Text('Saldo: Rp ${Helpers.formatNumber(c.saldo)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                                  ),
                                ],
                              ),
                            ),
                            // Tombol Aksi Langsung
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.account_balance_wallet, color: Colors.green, size: 28),
                                  onPressed: () => _showSaldoDialog(c),
                                  tooltip: 'Ubah Saldo',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue, size: 28),
                                  onPressed: () => _showFormDialog(client: c),
                                  tooltip: 'Edit Data',
                                ),
                              ],
                            )
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
        builder: (ctx, setS) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Saldo ${client.nama}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Text('Saldo saat ini: Rp ${Helpers.formatNumber(client.saldo)}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Tambah')),
                          selected: isAddition,
                          onSelected: (val) => setS(() => isAddition = true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Kurang')),
                          selected: !isAddition,
                          onSelected: (val) => setS(() => isAddition = false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amount, 
                    keyboardType: TextInputType.number,
                    inputFormatters: [ThousandsFormatter()],
                    decoration: const InputDecoration(labelText: 'Nominal (Rp)')
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final val = Helpers.parseNumber(amount.text);
                          if (val <= 0) return;
                          final newSaldo = isAddition ? (client.saldo + val) : (client.saldo - val);
                          final updated = ClientModel(id: client.id, nama: client.nama, kontak: client.kontak, alamat: client.alamat, saldo: newSaldo);
                          await _repo.update(updated);
                          if (mounted) Navigator.pop(ctx);
                          _load();
                          if (mounted) _showNotif('Saldo berhasil diperbarui');
                        },
                        child: const Text('Simpan'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(client == null ? 'Tambah Client' : 'Edit Client', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const SizedBox(height: 20),
                TextField(controller: n, decoration: const InputDecoration(labelText: 'Nama Client')),
                const SizedBox(height: 12),
                TextField(controller: a, decoration: const InputDecoration(labelText: 'Alamat')),
                const SizedBox(height: 12),
                TextField(controller: k, decoration: const InputDecoration(labelText: 'Kontak/No HP')),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        if (n.text.isEmpty) return;
                        final model = ClientModel(id: client?.id, nama: n.text.trim(), alamat: a.text.trim(), kontak: k.text.trim(), saldo: client?.saldo ?? 0.0);
                        if (client == null) { await _repo.create(model); } else { await _repo.update(model); }
                        if (mounted) Navigator.pop(context);
                        _load();
                        if (mounted) _showNotif('Client berhasil disimpan');
                      },
                      child: const Text('Simpan'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}