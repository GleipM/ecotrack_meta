import '../dominio/consumo.dart';

/// Contrato de la fuente de verdad de los consumos.
/// Habla como el dominio: no sabe si detrás hay memoria, disco o red.
abstract class ConsumoRepository {
  Future<void> guardar(Consumo consumo);
  Future<List<Consumo>> todos();
}
