# Nido Mozzarella — Portfolio Interactivo de Data Science

Bienvenid@ a mi portfolio-app.
Un proyecto creado en **Flutter Web** que combina **gamificación** y **Data Science** para mostrar mis conocimientos de forma creativa y divertida.

Cada nivel es una metáfora de cómo aplico el ciclo completo de análisis de datos: desde atender un “restaurante de quesos” hasta crear un dashboard con métricas finales.

---

## Demo
https://marilu1707.github.io/marilu_portfolio/

> Nota: el deploy se migra a Vercel. Esta URL puede actualizarse tras la publicación.

---

## Deploy Web (Vercel)

- Ya NO usamos Netlify ni GitHub Pages en este repo. Se sirve como sitio estático desde `build/web`.
- `vercel.json` en la raíz define rewrites para SPA:

```json
{ "rewrites": [ { "source": "/(.*)", "destination": "/index.html" } ] }
```

### Build local (recomendado)

Opción rápida para generar `build/web` y publicar sin build en el host.

```bash
flutter clean
flutter pub get
flutter build web --release --base-href "/"
# Recomendado: quitar el service worker para evitar caché vieja en el primer deploy
rm -f build/web/flutter_service_worker.js  # (Windows: del build\web\flutter_service_worker.js)
```

Atajo con script:

- macOS/Linux: `scripts/build_web.sh`
- Windows (PowerShell): `powershell -ExecutionPolicy Bypass -File scripts/build_web.ps1`

Notas:
- Framework Preset en Vercel: “Other”.
- Build Command: vacío (sirve archivos estáticos).
- Output Directory: `build/web`.
- Si ves pantalla en blanco: hard refresh (Ctrl/Cmd + Shift + R). Asegurate de no publicar `flutter_service_worker.js` o eliminá cache desde DevTools.
- Windows: Flutter necesita “Developer Mode” habilitado para crear symlinks usados por plugins. Abrí Configuración con `start ms-settings:developers` y activalo.

### CI/CD con GitHub + Actions (opcional)

Este repo incluye workflows que pueden compilar Web y subir artefactos o commitear `build/web`. Si usás Vercel con contenido estático, podés desactivar los builds en Vercel y sólo servir `build/web`.

---

### Script para preparar build/web y subir a GitHub (estático)

Si preferís que Vercel sirva archivos estáticos sin construir, podés versionar `build/web` y hacer push con:

```powershell
powershell -ExecutionPolicy Bypass -File .\prepare_build_web_and_push.ps1 -RepoUrl "https://github.com/USER/REPO.git" -Branch main
```

Este script:
- Compila Flutter Web (renderer `canvaskit` por defecto; `-Renderer html` opcional)
- Asegura excepciones en `.gitignore` para incluir `build/web`
- Crea `vercel.json` si falta (fallback SPA)
- Commit y push a la rama indicada

## Niveles del juego

### Nivel 1 — Restaurante
Atendé a los ratoncitos estilo kawaii que llegan al restaurante pidiendo quesos.
Esto representa la **recolección de datos** (interacciones de clientes).

---

### Nivel 2 — EDA (Exploratory Data Analysis)
Visualización de los quesos más pedidos con gráficos de barras y comentarios del ratón chef.
Simula cómo realizo **análisis exploratorio de datos** para entender patrones de consumo.

---

### Nivel 3 — Inventario
Control de stock de quesos con semáforos de estado (suficiente, bajo, reponer).
Cada pedido impacta en el inventario. Esto representa la **gestión de datos y recursos**.

---

### Nivel 4 — A/B Test
Calculadora interactiva de tests A/B, comparando grupo control vs tratamiento.
Incluye explicación de qué se mide, cómo se calcula el **p-valor** y qué significa la significancia estadística.

---

### Nivel 5 — Dashboard
Resumen final con:
- Quesos más pedidos
- Resultados de A/B test
- Métricas globales (puntaje, tiempo jugado, niveles completados)

El ratón “analista” presenta todo en un estilo kawaii.
Este nivel refleja cómo presento resultados en un **dashboard ejecutivo**.

---

## Screenshots

_(Agregá acá imágenes de cada nivel — podés usar mockups o capturas reales de la app corriendo en Chrome)_

---

## Tecnologías

- [Flutter](https://flutter.dev/) + Dart
- `fl_chart` para gráficos
- `provider` para manejo de estado
- Estética personalizada kawaii

---

## Cómo correrlo en tu máquina

```bash
git clone https://github.com/Marilu1707/flutter_portfolio.git
cd flutter_portfolio
flutter pub get
flutter run -d chrome
```

Para compilar la versión web:

```bash
flutter build web
```

---

## Sobre mí

Soy estudiante de **Negocios Digitales en UADE**, con formación en **análisis de datos, marketing y desarrollo web**.
Tengo capacitaciones en **IT** y me apasiona unir **estrategia, tecnología y creatividad** para generar soluciones simples e innovadoras.

---

## Contacto

* Email: [mlujanmassironi@gmail.com](mailto:mlujanmassironi@gmail.com)
* LinkedIn: [Maria Luján Massironi](https://www.linkedin.com/in/maria-lujan-massironi/)
* GitHub: [Marilu1707](https://github.com/Marilu1707)
* [Descargar CV](assets/data/CV_MASSIRONI_MARIA_LUJAN.pdf)

---

### Créditos

Diseño y desarrollo: **Marilu**
Estilo kawaii inspirado en Tsuki y la idea de un restaurante de quesos interactivo.
