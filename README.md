# 🧀 Nido Mozzarella — Portfolio Interactivo de Data Science

Bienvenid@ a mi portfolio-app 🎮✨. Es un proyecto creado en **Flutter Web** que combina **gamificación** y **Data Science** para mostrar mis conocimientos de forma creativa y divertida.

Cada nivel es una metáfora de cómo aplico el ciclo completo de análisis de datos: desde atender un “restaurante de quesos” hasta crear un dashboard con métricas finales.

---

## 📋 Tabla de contenidos
- [Demo](#-demo)
- [Niveles del juego](#-niveles-del-juego)
- [Dashboard ejecutivo](#-dashboard-ejecutivo)
- [Screenshots](#-screenshots)
- [Tecnologías](#-tecnologías)
- [Requisitos previos](#-requisitos-previos)
- [Cómo correrlo en tu máquina](#-cómo-correrlo-en-tu-máquina)
- [Deploy en Vercel](#-deploy-en-vercel)
- [Sobre mí](#-sobre-mí)
- [Contacto](#-contacto)
- [Créditos](#-créditos)

---

## 🌟 Demo
👉 [marilu-portfolio.vercel.app](https://marilu-portfolio.vercel.app/)

---

## 🎮 Niveles del juego

### 🐭 Nivel 1 — Juego (Restaurante kawaii)
Atendé a los ratoncitos estilo kawaii que llegan al restaurante pidiendo quesos. Esta fase gamificada representa la **recolección de datos** (interacciones de clientes) y genera los eventos que alimentan al resto de los niveles.

---

### 📊 Nivel 2 — EDA (Exploratory Data Analysis)
Visualización de los quesos más pedidos con gráficos de barras y comentarios del ratón chef. Simula cómo realizo **análisis exploratorio de datos** para entender patrones de consumo.

---

### 📦 Nivel 3 — Inventario
Control de stock de quesos con semáforos de estado (🟢 suficiente, 🟡 bajo, 🔴 reponer). Cada pedido impacta en el inventario. Esto representa la **gestión de datos y recursos**.

---

### 🤖 Nivel 4 — Predicción ML (online)
Un recomendador en vivo entrena un modelo de **Machine Learning** con gradiente descendente estocástico. Ajustá las variables del contexto (racha, hora, stock, tiempo promedio) y obtené sugerencias de qué queso ofrecer con probabilidades explicadas.

---

### 🧪 Nivel 5 — A/B Test
Calculadora interactiva para comparar Control (A) vs Tratamiento (B). Carga resultados al estado global, calcula **Z-score**, **p-valor**, intervalos de confianza y permite enviar los hallazgos al panel final.

---

## 📈 Dashboard ejecutivo

Un panel separado consolida todo el recorrido:
- Quesos más pedidos y cumplimiento del inventario.
- Evolución de pedidos vs. atendidos y tasa de acierto global.
- Resultados resumidos del test A/B (conversiones, lift, significancia).

El ratón “analista” presenta las métricas en estilo kawaii, pensado para mostrar cómo comunico insights a stakeholders.

---

## 🖼️ Screenshots

_Agregá imágenes de cada nivel si querés compartir capturas reales o mockups. Guardalas en `assets/` y linkealas acá para que se visualicen en GitHub._

---

## ⚙️ Tecnologías

- [Flutter](https://flutter.dev/) + Dart 🐦
- `fl_chart` para gráficos 📊
- `provider` para manejo de estado
- Estética personalizada kawaii 🎨

---

## 🛠️ Requisitos previos

- [Flutter](https://docs.flutter.dev/get-started/install) 3.16 o superior.
- Chrome, Edge o Safari para probar la app en modo web.
- (Opcional) [Node.js](https://nodejs.org/) si vas a publicar con la CLI de Vercel.

Ejecutá `flutter doctor` para chequear que tu entorno esté listo.

---

## 📥 Cómo correrlo en tu máquina

```bash
git clone https://github.com/Marilu1707/marilu_portfolio.git
cd marilu_portfolio
flutter clean
flutter pub get
flutter run -d chrome
```

Para compilar la versión web lista para producción:

```bash
flutter clean
flutter pub get
flutter build web --release
```

El build final queda en `build/web`.

---

## 🚀 Deploy en Vercel

> ✅ Requisitos previos: tener Flutter instalado localmente y una cuenta en [Vercel](https://vercel.com/).

1. **Generar el build estático**:
   ```bash
   flutter clean
   flutter pub get
   flutter build web --release
   ```
   El build respeta el `<base href="/">` necesario para que el routing de Flutter Web funcione en cualquier host.

2. **Configurar el proyecto en Vercel** (ya incluido en este repo):
   - `vercel.json` publica `build/web/**` como archivos estáticos.
   - Incluye una regla de _rewrite_ `/(.*) -> /index.html` para que Flutter Web cargue aun si refrescás rutas internas.
   - `.gitignore` permite versionar `build/web` (ideal si deployás desde GitHub, sin reconstruir en Vercel).

3. **Deploy desde el Dashboard**:
   1. `New Project → Import Git Repository`.
   2. Elegí `marilu_portfolio`.
   3. `Framework preset`: **Other** / **Static Files**.
   4. `Build Command`: `flutter clean && flutter pub get && flutter build web --release` (o dejalo vacío si vas a subir el build generado localmente).
   5. `Output Directory`: `build/web`.
   6. `Install Command`: vacío o `echo "skip"`.
   7. Deploy.

4. **Deploy con CLI (ideal si Vercel no tiene Flutter preinstalado)**:
   ```bash
   npm install -g vercel
   rm -rf .vercel
   vercel link
   vercel pull --yes --environment=production

   flutter clean
   flutter pub get
   flutter build web --release

   vercel deploy build/web --prod --yes
   ```
   Este flujo genera el build en tu máquina y sube la carpeta lista a Vercel (evita pantallas en blanco por builds incompletos).

5. **Automatizar con GitHub Actions (opcional)**: creá `.github/workflows/deploy-vercel.yml` y cargá los secrets `VERCEL_TOKEN`, `VERCEL_ORG_ID`, `VERCEL_PROJECT_ID`. El workflow compila con Flutter estable y publica `build/web` en cada push a `main`.

📌 Si ves pantalla en blanco asegurate de:
- Tener `vercel.json` en la raíz del repo.
- Publicar la carpeta `build/web` correcta.
- Mantener `<base href="/">` en `web/index.html`.
- Limpiar configuraciones viejas: `rm -rf .vercel && vercel link && vercel pull`.

---

## 👩‍💻 Sobre mí

Soy estudiante de **Negocios Digitales en UADE**, con formación en **análisis de datos, marketing y desarrollo web**. Tengo capacitaciones en **IT** y me apasiona unir **estrategia, tecnología y creatividad** para generar soluciones simples e innovadoras.

## 📬 Contacto

- ✉️ Email: [mlujanmassironi@gmail.com](mailto:mlujanmassironi@gmail.com)
- 💼 LinkedIn: [Maria Luján Massironi](https://www.linkedin.com/in/maria-lujan-massironi/)
- 🐙 GitHub: [Marilu1707](https://github.com/Marilu1707)
- 📄 [Descargar CV](assets/data/CV_MASSIRONI_MARIA_LUJAN.pdf)

---

### ✨ Créditos

Diseño y desarrollo: **Maria Lujan Massironi**. Estilo kawaii inspirado en Tsuki y la idea de un restaurante de quesos interactivo.
