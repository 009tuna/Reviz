import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/addresses_repository.dart';
import '../models/address.dart';

class AddressSelectPage extends StatefulWidget {
  const AddressSelectPage({super.key});

  @override
  State<AddressSelectPage> createState() => _AddressSelectPageState();
}

class _AddressSelectPageState extends State<AddressSelectPage> {
  late final AddressesRepository repo;
  List<Address> items = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    repo = AddressesRepository(Supabase.instance.client);
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      items = await repo.fetchMyAddresses();
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adres Seç')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final a = items[i];
                return ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text(a.title),
                  subtitle: Text(a.line,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  onTap: () => Navigator.pop(context, a.id),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // TODO: yeni adres ekleme sayfasına gidebilirsin; şimdilik kapatıyoruz
          Navigator.pop(context, null);
        },
        label: const Text('Yeni Adres'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
