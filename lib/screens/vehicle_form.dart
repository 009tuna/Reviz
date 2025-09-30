import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/vehicles_repository.dart';
import '../models/vehicle.dart';

class VehicleFormPage extends StatefulWidget {
  const VehicleFormPage({super.key});

  @override
  State<VehicleFormPage> createState() => _VehicleFormPageState();
}

class _VehicleFormPageState extends State<VehicleFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _plate = TextEditingController();
  final _km = TextEditingController();
  final _year = TextEditingController(text: '2020');

  String? _brand;
  String? _model;
  DateTime? _purchaseDate;

  final _brands = const ['Honda', 'Yamaha', 'Kuba', 'Volta', 'Arora'];
  final _modelsByBrand = const {
    'Honda': ['CBR-650', 'CB-125', 'PCX'],
    'Yamaha': ['R6', 'MT-07', 'NMax'],
    'Kuba': ['Blueberry', 'KM-125'],
    'Volta': ['VS1', 'VM4'],
    'Arora': ['AR-1000', 'AR-250'],
  };

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      firstDate: DateTime(1990),
      lastDate: DateTime(now.year + 1),
      initialDate: _purchaseDate ?? now,
      helpText: 'Satın Alma Tarihi',
    );
    if (d != null) setState(() => _purchaseDate = d);
  }

  @override
  void dispose() {
    _plate.dispose();
    _km.dispose();
    _year.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = VehiclesRepository(Supabase.instance.client);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Araç Ekle'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              value: _brand,
              items: _brands
                  .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                  .toList(),
              onChanged: (v) => setState(() {
                _brand = v;
                _model = null;
              }),
              decoration: const InputDecoration(
                labelText: 'Marka *',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null ? 'Marka seçin' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _model,
              items: (_brand == null
                      ? <String>[]
                      : _modelsByBrand[_brand] ?? <String>[])
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (v) => setState(() => _model = v),
              decoration: const InputDecoration(
                labelText: 'Model *',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null ? 'Model seçin' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _year,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Üretim Tarihi *',
                      hintText: '2020',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null ||
                          n < 1980 ||
                          n > DateTime.now().year + 1) {
                        return 'Geçerli yıl';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Satın Alım *',
                        border: OutlineInputBorder(),
                      ),
                      child: Row(
                        children: [
                          Text(_purchaseDate == null
                              ? 'gg.aa.yyyy'
                              : '${_purchaseDate!.day.toString().padLeft(2, '0')}.${_purchaseDate!.month.toString().padLeft(2, '0')}.${_purchaseDate!.year}'),
                          const Spacer(),
                          const Icon(Icons.calendar_today, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _plate,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Plaka *',
                      hintText: '34 ABC 123',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Plaka girin' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _km,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'KM Bilgisi',
                      hintText: '50000',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                final v = await repo.addVehicle(
                  plate: _plate.text,
                  brand: _brand!,
                  model: _model!,
                  year: int.parse(_year.text),
                  purchaseDate: _purchaseDate,
                  km: _km.text.isEmpty ? null : int.parse(_km.text),
                );
                if (!mounted) return;
                Navigator.of(context).pop<Vehicle>(v);
              },
              child: const Text('Aracı Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}
