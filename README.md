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

- Ya NO usamos Netlify ni GitHub Pages en este repo.
- Asegurate de tener `vercel.json` en la raíz con el fallback de SPA (incluido en este repo):

```json
{ "rewrites": [ { "source": "/(.*)", "destination": "/index.html" } ] }
```

### Opción A — CLI (rápida y recomendada)

1) Build local

```bash
flutter clean
flutter pub get
flutter build web --release --web-renderer canvaskit --base-href "/"
```

2) Instalar Vercel CLI (una vez)

```bash
npm i -g vercel
```

3) Deploy directo de la carpeta compilada

```bash
# macOS/Linux
bash scripts/deploy_vercel.sh

# Windows (PowerShell)
powershell -ExecutionPolicy Bypass -File scripts/deploy_vercel.ps1

# Alternativa manual
vercel build/web      # preview
vercel --prod build/web
```

Notas:
- Si preguntan “Output directory”, ya pasás `build/web`.
- Con `vercel.json` (rewrites a `/index.html`) no habrá 404 al refrescar rutas internas (SPA).
- `--web-renderer canvaskit` ofrece mejor fidelidad visual; `--web-renderer html` puede ser útil en dispositivos de bajos recursos o si priorizás tamaño de descarga.

#### Scripts de deploy (un comando)

- macOS/Linux: `scripts/deploy_vercel.sh [renderer]`
  - Ejemplos: `scripts/deploy_vercel.sh` (canvaskit) o `scripts/deploy_vercel.sh html`
- Windows (PowerShell): `scripts/deploy_vercel.ps1 [-Preview] [-Renderer canvaskit|html]`
  - Ejemplos: `powershell -ExecutionPolicy Bypass -File scripts/deploy_vercel.ps1`
             `powershell -ExecutionPolicy Bypass -File scripts/deploy_vercel.ps1 -Renderer html`
  - Si PowerShell bloquea la ejecución: `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass`

### Opción B — Conectar GitHub a Vercel (CI/CD)

1) Ir a https://vercel.com/new e importar el repo.
2) Framework Preset: “Other”.
3) Output Directory: `build/web`.
4) Build Command (si querés construir en Vercel):

```
flutter build web --release --web-renderer canvaskit --base-href "/"
```

Importante: Vercel no incluye Flutter por defecto. Para construir ahí, suele requerir un script que instale el SDK en tiempo de build. Si no querés complicarte, preferí la Opción A (CLI).

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
