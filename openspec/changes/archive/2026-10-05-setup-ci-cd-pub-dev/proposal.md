## Why

El paquete `custom_data_table` requiere acondicionar su infraestructura de calidad, documentación, licencia de código abierto y automatización de CI/CD para cumplir con los estándares requeridos y ser publicado y mantenido como un paquete de alto impacto en [pub.dev](https://pub.dev).

Esta propuesta establece la estandarización para alcanzar el puntaje máximo en pub.dev (Pana Score 160/160), adoptar formalmente la licencia MIT e implementar un pipeline de Integración Continua (CI) ultrarrápido con doble capa de caché para Flutter 3.38.7, incorporando validaciones de simulación `--dry-run`.

## What Changes

- **Acondicionamiento para pub.dev**:
  - Adopción formal de la licencia **MIT** con copyright oficial.
  - Actualización de metadatos en `pubspec.yaml` (descripción completa, enlaces oficiales, topics).
  - Rediseño de `README.md` con ejemplos funcionales, características y referencia a `example/`.
  - Actualización de `CHANGELOG.md` documentando las versiones acumuladas y la versión candidata `3.0.6`.
  - Creación de pruebas unitarias y de widgets en `test/` para validar el renderizado y funciones base.
  - Configuración de `.pubignore` para excluir tooling y artefactos de desarrollo del paquete final.
- **Pipeline de CI Ultrarrápido (`.github/workflows/ci.yml`)**:
  - Flutter 3.38.7 con caché activo de Flutter SDK (`subosito/flutter-action@v2`).
  - Caché de dependencias pub (`~/.pub-cache`).
  - Validación de formato (`dart format --output=none --set-exit-if-changed .`).
  - Análisis estático riguroso (`flutter analyze --fatal-infos`).
  - Ejecución de pruebas automatizadas (`flutter test`).
  - Simulación estricta de publicación (`flutter pub publish --dry-run`) como seguro contra fallos de empaquetado.
  - Verificación del proyecto `example/`.
- **Candado de Publicación**:
  - Toda validación opera en modo simulación `--dry-run`, manteniendo el control total de lanzamientos.

## Capabilities

### New Capabilities
- `package-readiness`: Estandarización de metadatos (`pubspec.yaml`), licencia MIT, documentación pública (`README.md`, `CHANGELOG.md`), `.pubignore` y suite de pruebas en `test/` requeridas para obtener 160/160 puntos en pub.dev.
- `continuous-integration`: Pipeline automatizado de GitHub Actions con doble capa de caché (Flutter SDK y Pub Cache) para validación de formato, análisis estático, tests y simulación `--dry-run`.

### Modified Capabilities
<!-- No modified capabilities; initial change -->

## Impact

- **Código fuente**: Inclusión de tests en `test/`, limpieza de archivos no deseados en `.gitignore` (`.DS_Store`, build artifacts).
- **Metadatos del paquete**: `pubspec.yaml`, `LICENSE`, `README.md`, `CHANGELOG.md`, `.pubignore`.
- **DevOps**: Creación del directorio `.github/workflows/` con el workflow de CI.
