# 🧀 Nido Mozzarella — Portfolio Interactivo de Data Science

Bienvenid@ a mi portfolio-app 🎮✨  
Un proyecto creado en **Flutter Web** que combina **gamificación** y **Data Science** para mostrar mis conocimientos de forma creativa y divertida.

Cada nivel es una metáfora de cómo aplico el ciclo completo de análisis de datos: desde atender un “restaurante de quesos” hasta crear un dashboard con métricas finales.

---

## 🌟 Demo
👉 [marilu-portfolio.vercel.app](https://marilu-portfolio.vercel.app/)

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

## 🚀 Deploy en Vercel

> ✅ Requisitos previos: tener [Flutter](https://docs.flutter.dev/get-started/install) instalado localmente y una cuenta en [Vercel](https://vercel.com/).

1. **Preparar el build estático local** (lo publicamos tal cual en Vercel):

   ```bash
   flutter clean
   flutter pub get
   flutter build web --release
   ```

   El build queda en `build/web` y respeta el `<base href="/">` necesario para que el routing funcione en cualquier host.

2. **Configurar el proyecto para Vercel** (ya incluido en este repo):
   - `vercel.json` publica todo `build/web/**` como archivos estáticos.
   - Agregamos una regla de _rewrite_ `/(.*) -> /index.html` para que Flutter Web cargue aun si refrescás rutas internas.
   - `.gitignore` permite versionar `build/web` (ideal si deployás desde GitHub, sin reconstruir en Vercel).

3. **Conectar el repositorio desde el Dashboard de Vercel**:
   1. `New Project → Import Git Repository`.
   2. Elegí `marilu_portfolio`.
   3. `Framework preset`: **Other** / **Static Files**.
   4. `Build Command`: `flutter clean && flutter pub get && flutter build web --release` (o dejalo vacío si vas a subir el build generado localmente).
   5. `Output Directory`: `build/web`.
   6. `Install Command`: vacío o `echo "skip"`.
   7. Deploy. Si Vercel no encuentra Flutter, pasá al punto siguiente.

4. **Deploy con CLI (recomendado para entornos sin Flutter preinstalado)**:

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

Soy estudiante de **Negocios Digitales en UADE**, con formación en **análisis de datos, marketing y desarrollo web**.
Tengo capacitaciones en **IT** y me apasiona unir **estrategia, tecnología y creatividad** para generar soluciones simples e innovadoras.

## 📬 Contacto

* ✉️ Email: [mlujanmassironi@gmail.com](mailto:mlujanmassironi@gmail.com)
* 💼 LinkedIn: [Maria Luján Massironi](https://www.linkedin.com/in/maria-lujan-massironi/)
* 🐙 GitHub: [Marilu1707](https://github.com/Marilu1707)
* 📄 [Descargar CV](assets/data/CV_MASSIRONI_MARIA_LUJAN.pdf)

---

### ✨ Créditos

Diseño y desarrollo: **Maria Lujan Massironi**  
Estilo kawaii inspirado en Tsuki y la idea de un restaurante de quesos interactivo.


