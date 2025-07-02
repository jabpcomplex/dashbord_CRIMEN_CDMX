# 🚨 Plataforma interactiva de Delitos en la Ciudad de México ocurridos en 2024 

[![License: GPL v2](https://img.shields.io/badge/License-GPL_v2-blue.svg)](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html)
[![Shiny](https://img.shields.io/badge/Shiny-RStudio-blue.svg)](https://shiny.rstudio.com/)
![GitHub stars](https://img.shields.io/github/stars/jabpcomplex/dashbord_CRIMEN_CDMX?style=social)

**Plataforma interactiva** para explorar los datos públicos de delitos de la Fiscalía General de Justicia (2024), desarrollada con **R Shiny, CSS y JavaScript**.

👉 **URL de la App**: [Enlace al deploy] 

## 🌟 ¿Cual es la importancia del software libre?
| Democratización del Conocimiento | Soberanía Tecnológica | Impacto Social |
|---------------------------------|-----------------------|----------------|
| Transforma datos crudos en información accesible para ciudadanos, periodistas y académicos | 100% desarrollado con herramientas de software libre (R, JavaScript) | Facilita la identificación de patrones para políticas públicas basadas en evidencia |

## 🛠️ Tecnologías Clave

- R Shiny      # Backend interactivo
- Leaflet.js   # Mapas dinámicos
- D3.js        # Visualizaciones avanzadas
- Flexdashboard # Diseño responsive
- Tidyverse    # Procesamiento de datos


📊 Funcionalidades Principales
✅ Filtros interactivos por:

- Tipo de delito
- Alcaldía
- Fechas

✅ Series de tiempo 
✅ Panel administrativo para gestores públicos

🚀 Cómo Contribuir
Para principiantes:
⭐ Dale estrella al proyecto (arriba derecha)

🍴 Haz fork (Guía visual de fork)

```bash
# Pasos básicos:
git clone https://github.com/tu_usuario/dashbord_CRIMEN_CDMX.git
cd dashbord_CRIMEN_CDMX
````

Para desarrolladores:

# 1. Instala dependencias
```bash
if (!require("pacman")) install.packages("pacman")
pacman::p_load(shiny, leaflet, ggplot2, dplyr, lubridate)
```

# 2. Corre la app localmente
```bash
shiny::runApp()
```
📈 Roadmap (¡Colabora!)
Versión inicial con mapas interactivos

- Integrar API del SESNSP (Issues #12)

- Módulo de predicción (SARIMA)

Autenticación para gestores públicos

📜 Licencia

Este proyecto está bajo licencia GNU General Public License v2.0
📌 Leer licencia completa

📬 Contacto
📧 julioacustico10@gmail.com
