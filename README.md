# 🧀 Portfolio Interactivo de Data Science

**Autora:** María Luján Massironi  
**Carreras:** Ingeniería en Inteligencia Artificial (UP) · Negocios Digitales (UADE)  
**Demo:** [portfolio-interactivo.vercel.app](https://portfolio-interactivo.vercel.app/)

---

## Descripción

Portfolio interactivo que combina **gamificación con Data Science**. Usando la temática kawaii de "Nido Mozzarella", la app permite jugar un simulador de pedidos y luego analizar los datos generados con herramientas reales: EDA, predicción ML en vivo y A/B testing.

Cada sección representa una parte del ciclo de análisis de datos: desde la recolección (juego) hasta la comunicación de insights (dashboard ejecutivo).

La IA fue compañera de trabajo durante el desarrollo — para explorar ideas, entender errores y pensar mejores implementaciones. Eso también es una habilidad que vale la pena desarrollar.

---

## Funcionalidades

| Sección | Descripción |
|---------|-------------|
| 🎮 **Nido Mozzarella** | Juego de 60s: atendé pedidos de quesos, sumá puntos y generá datos para análisis |
| 📊 **EDA Interactiva** | Gráficos de barras, donuts, rankings + estadísticas descriptivas (media, mediana, CV%) |
| 📦 **Inventario** | Control de stock con semáforos visuales (🟢 ok · 🟡 bajo · 🔴 crítico) |
| 🤖 **Predicción ML** | Regresión logística online (SGD + L2) — aprende en vivo y explica cada predicción con pesos reales |
| 🧪 **A/B Testing** | Z-test de dos proporciones con CI, Cohen's h, veredicto visual e interpretación contextual |
| 📋 **Dashboard** | KPIs, métricas ML, insights automáticos con evaluación de accuracy |

---

## Data Science en detalle

| Concepto | Implementación |
|----------|---------------|
| **Regresión Logística** | SGD online con regularización L2, 14 features, learning rate 0.05 |
| **Feature Engineering** | Log transforms, encoding cíclico (sin/cos hora), one-hot quesos, normalización |
| **Explainabilidad** | Contribuciones reales w[i]*x[i] por feature — no hardcoded |
| **Estadísticas Descriptivas** | Media, mediana, desviación estándar, coeficiente de variación |
| **A/B Testing** | Z-test dos proporciones, p-value, intervalos de confianza, Cohen's h |
| **Visualización** | fl_chart (barras, donuts), semáforos de stock, badges de métricas |

---

## Tecnologías

| Tecnología | Uso |
|-----------|-----|
| Flutter + Dart | Framework principal (CanvasKit renderer) |
| fl_chart | Visualizaciones interactivas |
| Provider | Gestión de estado |
| Google Fonts | Tipografía |
| Vercel | Hosting y deploy automático |

---

## Instalación local

```bash
# 1. Clonar el repositorio
git clone https://github.com/Marilu1707/portfolio_interactivo.git
cd portfolio_interactivo

# 2. Instalar dependencias
flutter pub get

# 3. Correr en el navegador
flutter run -d chrome
```

Para compilar la versión de producción:

```bash
flutter build web --release
```

---

## Pantallas

| Ruta | Descripción |
|------|-------------|
| `/welcome` | Pantalla de bienvenida |
| `/` | Home — CV, skills, educación, niveles |
| `/level1` | Juego Nido Mozzarella |
| `/level2` | EDA Interactiva |
| `/level3` | Inventario |
| `/level4` | Predicción ML |
| `/level5` | A/B Testing |
| `/dashboard` | Dashboard Ejecutivo |

---

## Deploy en Vercel

El proyecto se despliega automáticamente al hacer push a `main`.

Para deploy manual:

```bash
npm i -g vercel
flutter build web --release
vercel deploy build/web --prod
```

---

## Contacto

- ✉️ [mlujanmassironi@gmail.com](mailto:mlujanmassironi@gmail.com)
- 💼 [LinkedIn](https://www.linkedin.com/in/maria-lujan-massironi/)
- 🐙 [GitHub](https://github.com/Marilu1707)

---

Portfolio Interactivo — hecho con amor, datos y mucho queso. 🧀🐭
