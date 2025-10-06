import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/vehicles_controller.dart';
import '../data/vehicles_repository.dart';
import '../models/vehicle.dart';
import 'vehicle_form.dart';
// eğer tokens.dart kullanıyorsan ekleyebilirsin:
// import 'package:reviz_develop/theme/tokens.dart';

class VehiclesPage extends StatefulWidget {
  const VehiclesPage({super.key});

  @override
  State<VehiclesPage> createState() => _VehiclesPageState();
}

class _VehiclesPageState extends State<VehiclesPage> {
  late final VehiclesController ctrl;

  @override
  void initState() {
    super.initState();
    ctrl = VehiclesController(VehiclesRepository(Supabase.instance.client));
    ctrl.refresh();
  }

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Araçlarım'),
        centerTitle: true,
      ),
      body: AnimatedBuilder(
        animation: ctrl,
        builder: (context, _) {
          if (ctrl.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (ctrl.error != null) {
            return Center(child: Text('Hata: ${ctrl.error}'));
          }
          if (ctrl.items.isEmpty) {
            return _EmptyState(onAdd: _goAdd);
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (_, i) => _VehicleCard(
              v: ctrl.items[i],
              onDelete: () async {
                await ctrl.remove(ctrl.items[i].id);
              },
            ),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: ctrl.items.length,
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goAdd,
        icon: const Icon(Icons.add),
        label: const Text('Araç Ekle'),
      ),
    );
  }

  Future<void> _goAdd() async {
    // await'lerden sonra context kullanmamak için referansları önce al
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    // sayfaya git ve sonucu bekle
    final added = await navigator.push<Vehicle?>(
      MaterialPageRoute(builder: (_) => const VehicleFormPage()),
    );

    if (added == null) return;

    // listeyi tazele
    await ctrl.refresh();

    // kullanıcıya bilgi ver
    messenger.showSnackBar(
      SnackBar(content: Text('${added.plate} kaydedildi')),
    );
  }
}

class _VehicleCard extends StatefulWidget {
  final Vehicle v;
  final VoidCallback onDelete;
  const _VehicleCard({required this.v, required this.onDelete});

  @override
  State<_VehicleCard> createState() => _VehicleCardState();
}

class _VehicleCardState extends State<_VehicleCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final v = widget.v;
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            Row(
              children: [
                // İstersen burada kendi araç ikonunu kullan:
                // Image.asset('assets/Group-427321991@2x.png', width: 32, height: 32),
                const Icon(Icons.motorcycle_outlined, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(v.plate,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700)),
                      Text('${v.brand} ${v.model} • ${v.year}',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Sil',
                  onPressed: widget.onDelete,
                  icon: const Icon(Icons.delete_outline),
                ),
                IconButton(
                  tooltip: expanded ? 'Kapat' : 'Detay',
                  onPressed: () => setState(() => expanded = !expanded),
                  icon: Icon(expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down),
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 8, left: 4, right: 4),
                child: Row(
                  children: [
                    const Icon(Icons.event, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      v.purchaseDate == null
                          ? 'Satın alma tarihi yok'
                          : 'Satın alma: ${_fmtDate(v.purchaseDate!)}',
                    ),
                    const Spacer(),
                    const Icon(Icons.speed, size: 18),
                    const SizedBox(width: 6),
                    Text(v.km == null ? 'KM yok' : '${v.km} km'),
                  ],
                ),
              ),
              crossFadeState: expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Kendi illüstrasyonun:
            // Image.asset('assets/empty-garage.png', width: 180),
            const Icon(Icons.motorcycle, size: 96, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Kayıtlı aracınız yok',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text(
              'Plaka ve temel bilgileri girerek aracını ekleyebilirsin.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Araç Ekle'),
            ),
          ],
        ),
      ),
    );
  }
}

String _fmtDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
