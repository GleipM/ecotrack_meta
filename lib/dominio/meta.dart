// Dominio: reglas de la meta semanal, sin Flutter.

const metaInicial = 100.0;
const pasoMeta = 10.0;
const metaMinima = 10.0;

/// Suma [cambio] a la meta [actual] sin bajar nunca de [metaMinima].
double ajustarMeta(double actual, double cambio) {
  final nueva = actual + cambio;
  return nueva < metaMinima ? metaMinima : nueva;
}

/// Fracción de la meta ya usada, entre 0 y 1.
double avanceDeMeta({required double total, required double meta}) {
  if (meta <= 0) return total > 0 ? 1.0 : 0.0;
  return (total / meta).clamp(0.0, 1.0).toDouble();
}
