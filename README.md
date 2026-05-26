# 🧀 Portfolio Interactivo de Data Science

**Autora:** María Luján Massironi  
**Carreras:** Ingeniería en Inteligencia Artificial (UP) · Negocios Digitales (UADE)  
**Demo:** [marilu-portfolio.vercel.app](https://marilu-portfolio.vercel.app/)

---

## Descripción

Portfolio interactivo que combina **gamificación con Data Science**. Usando la temática kawaii de "Nido Mozzarella", la app permite jugar un simulador de pedidos y luego analizar los datos generados con herramientas reales: EDA, inventario, predicción ML y A/B testing.

Cada sección representa una parte del ciclo de análisis de datos: desde la recolección (juego) hasta la comunicación de insights (dashboard).

La IA fue una compañera de trabajo durante el desarrollo — para explorar ideas, entender errores, y pensar mejores implementaciones. Eso también es una habilidad que vale la pena desarrollar.

---

## Funcionalidades

| Sección | Descripción |
|---------|-------------|
| 🎮 **Nido Mozzarella** | Juego de 60s: atendé pedidos de quesos, sumá puntos y generá datos para análisis |
| 📊 **EDA Interactiva** | Gráficos de barras, donuts y rankings generados con fl_chart |
| 📦 **Inventario** | Control de stock con semáforos visuales (🟢 ok · 🟡 bajo · 🔴 crítico) |
| 🤖 **Predicción ML** | Regresión logística online con SGD — aprende en vivo de cada pedido |
| 🧪 **A/B Testing** | Z-test de dos proporciones con intervalos de confianza (90%, 95%, 99%) |
| 📋 **Dashboard Ejecutivo** | KPIs, cumplimiento de pedidos, insights automáticos |

---

## Tecnologías

| Tecnología | Uso |
|-----------|-----|
| Flutter + Dart | Framework principal |
| fl_chart | Visualizaciones interactivas |
| Provider | Gestión de estado |
| Google Fonts | Tipografía |
| Vercel | Hosting y deploy |

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
flutter build web --release --web-renderer html
```

---

## Pantallas

| Ruta | Descripción |
|------|-------------|
| `/welcome` | Pantalla de bienvenida |
| `/level1` | Juego Nido Mozzarella |
| `/level2` | EDA Interactiva |
| `/level3` | Inventario |
| `/level4` | Predicción ML |
| `/level5` | A/B Testing |
| `/dashboard` | Dashboard Ejecutivo |

---

## Deploy en Vercel

El proyecto se despliega automáticamente con GitHub Actions al hacer push a `main`.

Para deploy manual:

```bash
npm i -g vercel
flutter build web --release --web-renderer html
vercel deploy build/web --prod
```

---

## Contacto

- ✉️ [mlujanmassironi@gmail.com](mailto:mlujanmassironi@gmail.com)
- 💼 [LinkedIn](https://www.linkedin.com/in/maria-lujan-massironi/)
- 🐙 [GitHub](https://github.com/Marilu1707)

---

Portfolio Interactivo — hecho con amor, datos y mucho queso. 🧀🐭
