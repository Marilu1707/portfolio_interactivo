
# 🧀 Nido Mozzarella — Portfolio Interactivo de Data Science  

Bienvenid@ a mi **portfolio-app** 🎮✨.  
Un proyecto creado en **Flutter Web** que combina **gamificación + Data Science** para mostrar mis conocimientos de forma creativa y divertida.  

Cada sección representa una parte del ciclo de análisis de datos: desde atender pedidos en un “restaurante de quesos” hasta comunicar insights en un dashboard final.  

---

## 🌟 Demo online  
👉 [marilu-portfolio.vercel.app](https://marilu-portfolio.vercel.app/)  

---

## 🎮 Secciones del juego  

### 🐭 Nido Mozzarella (Juego)  
Atendé ratoncitos kawaii que llegan pidiendo quesos 🧀.  
Simboliza la **recolección de datos**: cada pedido genera eventos que se usan en el resto de las etapas.  

---

### 📊 EDA Interactiva  
Explorá con gráficos la participación de cada queso y patrones de consumo.  
Representa mi forma de aplicar **análisis exploratorio de datos (EDA)** para detectar tendencias y anomalías.  

---

### 📦 Inventario  
Gestión de stock con semáforos visuales (🟢 ok, 🟡 bajo, 🔴 crítico).  
Cada pedido impacta en la disponibilidad. Refleja la **gestión de datos y recursos**.  

---

### 🤖 Predicción ML (online)  
Un recomendador en tiempo real entrena un modelo de **Machine Learning**.  
Ajustá variables (racha, hora, stock, tiempo promedio) y obtené sugerencias de qué queso ofrecer, con explicación de la probabilidad calculada.  

---

### 🧪 A/B Testing  
Comparador interactivo entre Control (A) y Tratamiento (B).  
Calcula **Z-score, p-valor e intervalos de confianza** para evaluar significancia estadística y priorizar decisiones.  

---

## 📈 Dashboard ejecutivo  

Un panel que consolida todo:  
- Quesos más pedidos e inventario.  
- Evolución de pedidos vs. atendidos.  
- Tasa global de aciertos.  
- Resultados de A/B test.  

El ratón “analista” presenta métricas kawaii pensadas para **contar historias con datos a stakeholders**.  

---

## 🖼️ Screenshots  

📌 Podés agregar capturas reales en `assets/` y linkearlas acá para que se vean en GitHub.  

---

## ⚙️ Tecnologías usadas  

- [Flutter](https://flutter.dev/) + Dart 🐦  
- `fl_chart` → visualizaciones interactivas 📊  
- `provider` → manejo de estado  
- Estética kawaii propia 🎨  

---

## 🛠️ Requisitos  

- [Flutter](https://docs.flutter.dev/get-started/install) 3.16+  
- Navegador moderno (Chrome, Edge, Safari).  
- (Opcional) [Node.js](https://nodejs.org/) para publicar con la CLI de Vercel.  

Ejecutá `flutter doctor` para validar tu entorno.  

---

## 📥 Cómo correrlo en tu máquina  

```bash
git clone https://github.com/Marilu1707/marilu_portfolio.git
cd marilu_portfolio
flutter clean
flutter pub get
flutter run -d chrome
````

Para compilar la versión web lista para producción:

```bash
flutter clean
flutter pub get
flutter build web --release
```

El build queda en `build/web`.

---

## 🚀 Deploy en Vercel

1. **Generar build estático**

   ```bash
   flutter clean
   flutter pub get
   flutter build web --release
   ```

2. **Configurar proyecto**

   * `vercel.json` ya incluye rewrites necesarios (`/(.*) -> /index.html`).
   * `.gitignore` permite versionar `build/web` para deploy directo.

3. **Deploy desde GitHub**

   * Importá el repo en Vercel.
   * `Framework preset`: **Other / Static Files**.
   * `Output Directory`: `build/web`.

4. **Deploy con CLI**

   ```bash
   npm install -g vercel
   flutter build web --release
   vercel deploy build/web --prod
   ```

---

## 👩‍💻 Sobre mí

Soy estudiante de **Negocios Digitales en UADE**, con formación en **Data Science, marketing y desarrollo web**.
Me apasiona unir **estrategia + tecnología + creatividad** para generar soluciones simples e innovadoras.

---

## 📬 Contacto

* ✉️ [mlujanmassironi@gmail.com](mailto:mlujanmassironi@gmail.com)
* 💼 [LinkedIn](https://www.linkedin.com/in/maria-lujan-massironi/)
* 🐙 [GitHub](https://github.com/Marilu1707)
* 📄 [Descargar CV](assets/data/CV_MASSIRONI_MARIA_LUJAN.pdf)

---

### ✨ Créditos

Diseño y desarrollo: **María Luján Massironi**
Estilo kawaii inspirado en Tsuki 🌙 y la idea de un **restaurante de quesos interactivo**.

```
