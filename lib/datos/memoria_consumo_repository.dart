import '../dominio/consumo.dart';
import 'consumo_repository.dart';

/// Implementación del contrato que guarda los consumos en una lista en memoria.
class MemoriaConsumoRepository implements ConsumoRepository {
  final List<Consumo> _consumos = [];

  @override
  Future<void> guardar(Consumo consumo) async {
    _consumos.add(consumo);
  }

  /// Copia no modificable: nadie cambia la fuente de verdad desde fuera.
  @override
  Future<List<Consumo>> todos() async => List.unmodifiable(_consumos);
}
