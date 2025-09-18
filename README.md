# 🧀 Nido Mozzarella — Portfolio Interactivo de Data Science

Bienvenid@ a mi portfolio-app 🎮✨  
Un proyecto creado en **Flutter Web** que combina **gamificación** y **Data Science** para mostrar mis conocimientos de forma creativa y divertida.

Cada nivel es una metáfora de cómo aplico el ciclo completo de análisis de datos: desde atender un “restaurante de quesos” hasta crear un dashboard con métricas finales.

---

## 🌟 Demo
👉 https://marilu1707.github.io/marilu_portfolio/

---

## 🚀 Deploy Web (Netlify)

- Opción CI (recomendada con repo conectado):
  - Build command: `flutter build web --release --web-renderer canvaskit --base-href /`
  - Publish directory: `build/web`
  - Incluido: `netlify.toml` + `netlify_build.sh` para instalar Flutter durante el build.
  - SPA redirect: `web/_redirects` con `/* /index.html 200` para evitar 404.

- Opción CLI (un comando desde tu PC):
  - Requisitos: `npm i -g netlify-cli`
  - Windows: `powershell -ExecutionPolicy Bypass -File scripts/deploy_netlify.ps1`
  - macOS/Linux: `bash scripts/deploy_netlify.sh`
  - (Primera vez): `netlify init` o `netlify link` para vincular el sitio.

---

## 🎮 Niveles del juego

### 🐭 Nivel 1 — Restaurante
Atendé a los ratoncitos estilo kawaii que llegan al restaurante pidiendo quesos.  
Esto representa la **recolección de datos** (interacciones de clientes).

---

### 📊 Nivel 2 — EDA (Exploratory Data Analysis)
Visualización de los quesos más pedidos con gráficos de barras y comentarios del ratón chef.  
Simula cómo realizo **análisis exploratorio de datos** para entender patrones de consumo.

---

### 📦 Nivel 3 — Inventario
Control de stock de quesos con semáforos de estado (🟢 suficiente, 🟡 bajo, 🔴 reponer).  
Cada pedido impacta en el inventario. Esto representa la **gestión de datos y recursos**.

---

### 🧪 Nivel 4 — A/B Test
Calculadora interactiva de tests A/B, comparando grupo control vs tratamiento.  
Incluye explicación de qué se mide, cómo se calcula el **p-valor** y qué significa la significancia estadística.

---

### 📈 Nivel 5 — Dashboard
Resumen final con:
- Quesos más pedidos 🧀  
- Resultados de A/B test  
- Métricas globales (puntaje, tiempo jugado, niveles completados)  

El ratón “analista” presenta todo en un estilo kawaii.  
Este nivel refleja cómo presento resultados en un **dashboard ejecutivo**.

---

## 🖼️ Screenshots

_(Agregá acá imágenes de cada nivel — podés usar las que generamos como mockups o capturas reales de la app corriendo en Chrome)_

---

## ⚙️ Tecnologías

- [Flutter](https://flutter.dev/) + Dart 🐦  
- `fl_chart` para gráficos 📊  
- `provider` para manejo de estado  
- Estética personalizada kawaii 🎨  

---

## 📥 Cómo correrlo en tu máquina

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

## 👩‍💻 Sobre mí

Soy estudiante de **Negocios Digitales en UADE**, con formación en **análisis de datos, marketing y desarrollo web**.
Tengo capacitaciones en **IT** y me apasiona unir **estrategia, tecnología y creatividad** para generar soluciones simples e innovadoras.

---

## 📬 Contacto

* ✉️ Email: [mlujanmassironi@gmail.com](mailto:mlujanmassironi@gmail.com)
* 💼 LinkedIn: [Maria Luján Massironi](https://www.linkedin.com/in/maria-lujan-massironi/)
* 🐙 GitHub: [Marilu1707](https://github.com/Marilu1707)
* 📄 [Descargar CV](assets/data/CV_MASSIRONI_MARIA_LUJAN.pdf)

---

### ✨ Créditos

Diseño y desarrollo: **Marilu**
Estilo kawaii inspirado en Tsuki y la idea de un restaurante de quesos interactivo.


