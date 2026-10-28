// Dominio: Dart puro, no conoce Flutter.

/// Laboratorios donde se registran consumos. Es una constante, no estado.
const laboratoriosUtez = ['Lab Química', 'Lab Redes', 'Lab Física'];

/// Tope de litros que acepta un registro.
const topeLitros = 10000.0;

/// Un consumo de agua registrado en un laboratorio.
class Consumo {
  const Consumo({required this.laboratorio, required this.litros});

  final String laboratorio;
  final double litros;
}

/// Regla de negocio de los litros: regresa el mensaje de error o null.
String? validarLitros(double? litros) {
  if (litros == null || litros.isNaN) return 'Escribe los litros con número';
  if (litros <= 0) return 'Los litros deben ser mayores que cero';
  if (litros > topeLitros) return 'Los litros superan el tope de 10000';
  return null;
}
