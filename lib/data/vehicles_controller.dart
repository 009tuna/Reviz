import 'package:flutter/foundation.dart';
import '../models/vehicle.dart';
import 'vehicles_repository.dart';

class VehiclesController extends ChangeNotifier {
  final VehiclesRepository repo;
  VehiclesController(this.repo);

  bool loading = false;
  List<Vehicle> items = [];
  String? error;

  Future<void> refresh() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      items = await repo.fetchMyVehicles();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> add(Vehicle v) async {
    // bu metodu istemezsen doğrudan formdan repo.addVehicle çağırıyoruz
    await refresh();
  }

  Future<void> remove(String id) async {
    await repo.deleteVehicle(id);
    await refresh();
  }
}
