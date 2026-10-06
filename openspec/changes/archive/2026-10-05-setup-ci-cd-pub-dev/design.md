## Context

El paquete `custom_data_table` es una biblioteca Flutter para tablas de datos con soporte de scroll bidireccional, filtros por fecha/mes, ordenamiento, selección de registros y temas visuales personalizables.

Para consolidar la biblioteca como un paquete de calidad en [pub.dev](https://pub.dev), se requiere establecer:
- Licencia de código abierto oficial.
- Metadatos completos y validados en `pubspec.yaml`.
- Documentación pública y ejemplos en `README.md` y `CHANGELOG.md`.
- Pruebas automatizadas en `test/`.
- Pipeline de Integración Continua (CI) de alta velocidad con caché para validar el estado del código en Pull Requests y Pushes.

## Goals / Non-Goals

**Goals:**
- Acondicionar todos los archivos y metadatos del paquete para cumplir con las directrices de calidad y obtener el puntaje máximo en el analizador Pana (160/160).
- Diseñar e implementar un workflow de GitHub Actions (`ci.yml`) con doble capa de caché (Flutter SDK 3.38.7 y pub cache).
- Incorporar el paso de simulación `flutter pub publish --dry-run` en el CI para asegurar release-readiness continuo.
- Implementar suite de pruebas iniciales con `testWidgets` y tests unitarios.
- Configurar `.pubignore` para excluir tooling y artefactos de desarrollo del empaquetado final.

**Non-Goals:**
- **Compilar APKs, AABs o Split-ABI**: El proyecto es un paquete de Dart/Flutter, no una aplicación ejecutable.
- **Configurar NDK, Gradle o firmas Keystore**: Innecesarios para el ciclo de vida del paquete.

## Decisions

### 1. Licencia MIT
- **Decisión**: Adoptar la licencia **MIT** con titularidad a nombre de `Elias Alfaro (2026)`.
- **Razón**: Máxima permisividad, estándar universal en código abierto y perfectamente aceptada por pub.dev para el máximo puntaje de licencia.

### 2. Versión del Entorno: Flutter 3.38.7 y Dart 3.10.7
- **Decisión**: Fijar `flutter-version: '3.38.7'` en `subosito/flutter-action@v2`.
- **Razón**: Coincide de manera exacta con el entorno local de desarrollo del autor, previniendo discrepancias de análisis estático o sintaxis.

### 3. Estrategia de Caché de Alto Rendimiento en CI
- **Flutter SDK Cache**: Utilizar `cache: true` en `subosito/flutter-action@v2` con key basada en OS, canal y versión.
- **Pub Cache**: Utilizar `actions/cache@v4` sobre el directorio `~/.pub-cache` con key basada en el hash de `pubspec.lock`.
- **Razón**: Reduce el tiempo de ejecución del CI de ~4 minutos a menos de 45 segundos por build.

### 4. Flujo de Validación Estricta en CI
El pipeline ejecutará secuencialmente:
1. `dart format --output=none --set-exit-if-changed .`
2. `flutter analyze --fatal-infos`
3. `flutter test`
4. `flutter pub publish --dry-run`
5. Análisis del directorio `example/` (`cd example && flutter pub get && flutter analyze --no-fatal-infos --no-fatal-warnings`).

### 5. Versionado Semántico y Preparación para Release
- El estado actual en git tiene el tag `3.0.5`.
- Para consolidar todos los cambios de metadatos, documentación, licencia y tests sin generar inconsistencias con versiones previas, se prepara el paquete bajo la versión `3.0.6`.

## Risks / Trade-offs

- **[Riesgo] Discrepancias de formato en código existente** → *Mitigación*: Ejecutar `dart format` sobre el código para garantizar que el paso `--set-exit-if-changed` pase en verde.
- **[Riesgo] Dependencias incompatibles en `example/`** → *Mitigación*: Asegurar que el `pubspec.yaml` de `example/` apunte correctamente al paquete local mediante `path: ../`.
- **[Riesgo] Archivos no deseados en el archivo publicado** → *Mitigación*: `.pubignore` filtra tooling de agentes, artefactos de build y archivos temporales.

## Implementation Steps

1. Actualizar `.gitignore` y configurar `.pubignore` para filtrar artefactos de desarrollo.
2. Crear y actualizar `LICENSE`, `pubspec.yaml`, `README.md`, `CHANGELOG.md` y `test/`.
3. Crear el workflow de CI en `.github/workflows/ci.yml`.
4. Ejecutar validaciones locales (`format`, `analyze`, `test`, `dry-run`).
5. Confirmar ejecución exitosa del CI en GitHub Actions.
