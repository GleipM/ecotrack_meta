# Gestión de estado — EcoTrack Meta

**Equipo:** Francisco Cereth y Maximiliano Torres
**Fecha:** 2026-10-27

## Tipos de estado en nuestro código

| Dato | Tipo (efímero, compartido, derivado, persistido) | Dónde vive |
|---|---|---|
| Pestaña activa | Efímero: solo le importa a la barra inferior y se cambia con `setState`. | Campo `_pestana` de `_PantallasEcoTrackState` en `lib/presentacion/vistas.dart`. |
| Texto del campo de litros | Efímero: vive en el formulario hasta que se toca Guardar y luego se limpia. | `TextEditingController _litros` de `_FormularioRegistroState` en `lib/presentacion/vistas.dart` (se libera en su `dispose()`). |
| consumos y meta | Compartido: Registro, Historial y Meta leen el mismo valor y avisan con `notifyListeners()`. | Campos `consumos` y `meta` de `ConsumosViewModel` en `lib/presentacion/consumos_view_model.dart`. |
| total y metaSuperada | Derivado: se calcula cada vez a partir de `consumos` y `meta`, nunca se guarda. | Getters `double get total` y `bool get metaSuperada` de `ConsumosViewModel`; lo prueba "total, avance y metaSuperada se derivan de consumos y meta" en `test/etapa3_viewmodel_test.dart`. |
| Lo que regresa todos() | Persistido: es la fuente de verdad, el ViewModel solo guarda una copia que reasigna. | `_consumos` de `MemoriaConsumoRepository` (`lib/datos/memoria_consumo_repository.dart`), entregado con `List.unmodifiable`; lo prueba "todos() no deja modificar la lista interna" en `test/etapa2_datos_test.dart`. |

## Criterios

| Criterio | A · ChangeNotifier puro | B · provider |
|---|---|---|
| Dato compartido | Sí: las tres pestañas reciben el mismo `_vm` creado en `_AppChangeNotifierState`; lo prueba "Dato compartido: Registro guarda, Historial y Meta lo ven" en `test/etapa4_change_notifier_test.dart`. | Sí: las tres pestañas leen el único `ConsumosViewModel` de `ChangeNotifierProvider` en `AppProvider`; misma prueba en `test/etapa5_provider_test.dart`. |
| Capas | Se respetan: `vistas.dart` solo importa `material.dart` y `dominio/consumo.dart`, y el error de `validarLitros` llega a la vista; lo prueba "Capas: el error del dominio aparece y no se guarda nada" (etapa 4) y los puntos 2–4 de `verificar_estado.sh`. | Igual que A y con los mismos archivos: `consumos_view_model.dart` y `vistas.dart` no cambiaron entre los commits de la etapa 4 y la 5 (`git diff` vacío); misma prueba "Capas" en la etapa 5. |
| Encaje con el diagrama | Vista tonta → adaptador `*CN` con `ListenableBuilder` → `ConsumosViewModel` → `ConsumoRepository`. Solo agrega los adaptadores en `lib/variantes/a_change_notifier.dart`. | Mismo diagrama; solo cambia la caja del cableado: adaptadores `*Provider` con `context.watch`/`context.read` en `lib/variantes/b_provider.dart`. |
| Constructores que reciben vm | 3: `RegistroCN`, `HistorialCN` y `MetaCN` (`required this.vm`). Con una subpantalla de detalle bajo Meta serían 4, y cada nivel intermedio sumaría uno. | 0: `RegistroProvider`, `HistorialProvider` y `MetaProvider` son `const` sin parámetros; lo prueba "Los adaptadores piden el ViewModel al árbol, no al constructor". |
| Quién libera el ViewModel | El dueño: `_AppChangeNotifierState.dispose()` llama a `_vm.dispose()`; ningún adaptador lo hace. | `ChangeNotifierProvider`: llama a `dispose()` solo cuando sale del árbol el ViewModel que creó en `create`; nosotros no escribimos ningún `dispose()`. |
| Costo de adoptarla ahora | Cero dependencias (`verificar_estado.sh` punto 5: "no usa paquetes extra"), pero hay que pasar `vm` a mano por cada constructor. | Una dependencia (`provider: ^6.1.5+1` en `pubspec.yaml`) y aprender la regla de `watch` para mostrar y `read` para actuar (punto 7 de `verificar_estado.sh`); el archivo B es más corto que el A. |
| Sustitución de la fuente de datos | Sí: `AppChangeNotifier(repositorio: espia)` con `RepositorioEspia` funciona sin tocar pantallas; prueba "Sustitución: con otra fuente de datos las pantallas no cambian" (etapa 4). | Sí: `AppProvider(repositorio: espia)`, misma prueba "Sustitución" en la etapa 5. En las dos, `MemoriaConsumoRepository` solo se importa en `main*.dart` (punto 8). |

## Elección

Elegimos: B · provider, porque con el mismo `ConsumosViewModel` ningún constructor recibe `vm` y el ciclo de vida lo maneja `ChangeNotifierProvider`; cuando crezca el número de pantallas, eso no hace crecer el cableado.

Se mantiene esta pieza del diagrama: `ConsumosViewModel` (junto con `dominio/` y el contrato `ConsumoRepository`): no cambió ni una línea entre la variante A y la B.

Esta pieza es la que podría sustituirse después: `MemoriaConsumoRepository`, por una fuente real (disco o nube) que implemente `ConsumoRepository`; solo habría que cambiar `lib/main.dart`, como demuestran las pruebas de "Sustitución" con `RepositorioEspia`.
