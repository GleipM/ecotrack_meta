import 'package:flutter/foundation.dart';

import '../datos/consumo_repository.dart';
import '../dominio/consumo.dart';
import '../dominio/meta.dart';

/// Único dueño del estado compartido de EcoTrack.
/// Recibe el contrato del repositorio: no sabe de dónde salen los datos.
class ConsumosViewModel extends ChangeNotifier {
  ConsumosViewModel(this._repositorio);

  final ConsumoRepository _repositorio;

  // Estado compartido.
  List<Consumo> consumos = const [];
  String? error;
  bool guardando = false;
  double meta = metaInicial;

  // Estado derivado: se calcula cada vez, nunca se guarda.
  double get total => consumos.fold(0.0, (suma, c) => suma + c.litros);
  double get avance => avanceDeMeta(total: total, meta: meta);
  bool get metaSuperada => total > meta;

  Future<void> cargar() async {
    consumos = await _repositorio.todos();
    notifyListeners();
  }

  /// Regresa true si el consumo se guardó.
  Future<bool> guardar(String laboratorio, String litrosTexto) async {
    final litros = double.tryParse(
      litrosTexto.replaceAll(RegExp(r'\s'), '').replaceAll(',', '.'),
    );

    final mensaje = validarLitros(litros);
    if (mensaje != null) {
      error = mensaje;
      notifyListeners();
      return false;
    }

    guardando = true;
    error = null;
    notifyListeners();

    try {
      await _repositorio.guardar(
        Consumo(laboratorio: laboratorio, litros: litros!),
      );
      consumos = await _repositorio.todos();
    } finally {
      guardando = false;
      notifyListeners();
    }
    return true;
  }

  void subirMeta() => _cambiarMeta(pasoMeta);

  void bajarMeta() => _cambiarMeta(-pasoMeta);

  void _cambiarMeta(double cambio) {
    meta = ajustarMeta(meta, cambio);
    notifyListeners();
  }
}
