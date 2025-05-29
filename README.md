# Calculadora de Regresión Lineal Múltiple

Una herramienta interactiva para realizar análisis de regresión lineal múltiple con interfaz gráfica de usuario, que permite calcular modelos de regresión y sus intervalos de confianza de manera intuitiva.

## 📋 Descripción

Esta calculadora proporciona una solución completa para el análisis de regresión lineal múltiple, ideal para estudiantes, investigadores y profesionales que necesiten realizar análisis estadísticos de manera rápida y eficiente.

### Características principales:

- **Interfaz intuitiva**: Ventana inicial para configurar el tamaño de la tabla de datos
- **Análisis completo**: Cálculo de regresión lineal múltiple
- **Estadísticas avanzadas**: Generación de intervalos de confianza
- **Flexibilidad**: Soporte para diferentes tamaños de dataset
- **Resultados detallados**: Visualización clara de los resultados estadísticos

## 🚀 Funcionalidades

### ✨ Análisis de Regresión
- Regresión lineal múltiple con múltiples variables independientes
- Cálculo de coeficientes de regresión
- Evaluación de la significancia estadística
- Análisis de bondad de ajuste (R²)

### 📊 Intervalos de Confianza
- Cálculo de intervalos de confianza para los coeficientes
- Diferentes niveles de confianza (90%, 95%, 99%)
- Interpretación estadística de los resultados

### 🔧 Configuración Flexible
- Selección dinámica del tamaño de la tabla
- Entrada manual de datos
- Validación de datos de entrada

## 📦 Instalación

### Prerrequisitos
- **MATLAB R2024b** o superior
- **PostgreSQL 17.4-2** o compatible
- **Driver JDBC PostgreSQL 42.7.5** (postgresql-42.7.5.jar)
- Sistema operativo: Windows/Linux/macOS compatible con MATLAB

### Pasos de instalación

1. **Clona este repositorio:**
```bash
git clone https://github.com/Frank-Pesadilla/Calculadora-de-Integraci-n-Lineal-M-ltiple.git
```

2. **Navega al directorio del proyecto:**
```bash
cd Calculadora-de-Integraci-n-Lineal-M-ltiple
```

3. **Configuración de la base de datos:**
   - Instala PostgreSQL 17.4-2 si no lo tienes
   - Crea una base de datos para el proyecto
   - Configura usuario y contraseña de acceso

4. **Configuración del driver JDBC:**
   - Asegúrate de tener el archivo `postgresql-42.7.5.jar` en tu sistema
   - En MATLAB, agrega el driver al classpath:
   ```matlab
   javaaddpath('ruta/al/postgresql-42.7.5.jar')
   ```

5. **Ejecuta la aplicación:**
   - Abre MATLAB R2024b
   - Navega al directorio del proyecto
   - Ejecuta el archivo principal (ej: `main.m` o el archivo .m correspondiente)

## 🎯 Uso

### Configuración inicial de la base de datos

1. **Conexión a PostgreSQL desde MATLAB:**
```matlab
% Configurar la conexión
url = 'jdbc:postgresql://localhost:5432/nombre_de_tu_bd';
username = 'tu_usuario';
password = 'tu_contraseña';
driver = 'org.postgresql.Driver';

% Establecer conexión
conn = database('nombre_de_tu_bd', username, password, driver, url);
```

2. **Estructura de tablas sugerida:**
```sql
-- Tabla para almacenar datasets
CREATE TABLE datasets (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla para almacenar los datos de regresión
CREATE TABLE datos_regresion (
    id SERIAL PRIMARY KEY,
    dataset_id INTEGER REFERENCES datasets(id),
    variable_dependiente NUMERIC,
    variables_independientes NUMERIC[]
);
```

### Inicio rápido

1. **Configuración inicial**: Al iniciar la aplicación, selecciona el tamaño de tu tabla de datos
2. **Conexión a BD**: La aplicación se conectará automáticamente a PostgreSQL
3. **Entrada de datos**: Ingresa tus variables dependientes e independientes (se guardan en la BD)
4. **Cálculo**: Ejecuta el análisis de regresión usando las funciones de MATLAB
5. **Resultados**: Revisa los coeficientes, estadísticas y intervalos de confianza

### Ejemplo de uso en MATLAB

```matlab
% Ejemplo de análisis de regresión lineal múltiple
% Cargar datos desde PostgreSQL
query = 'SELECT * FROM datos_regresion WHERE dataset_id = 1';
data = fetch(conn, query);

% Preparar matrices
Y = data.variable_dependiente;
X = [ones(length(Y),1), cell2mat(data.variables_independientes)];

% Calcular regresión
[b, bint, r, rint, stats] = regress(Y, X);

% Mostrar resultados
fprintf('Coeficientes de regresión:\n');
disp(b);
fprintf('Intervalos de confianza:\n');
disp(bint);
```

## 📈 Salidas del Programa

La calculadora proporciona:

- **Coeficientes de regresión**: Valores estimados para cada variable
- **Intervalos de confianza**: Rangos de confianza para cada coeficiente
- **Estadísticas de ajuste**: R², R² ajustado, error estándar
- **Pruebas de significancia**: Valores p y estadísticos t
- **Diagnósticos**: Análisis de residuos (si aplica)

## 📋 Formato de Datos

### Entrada
- Datos numéricos únicamente
- Sin valores faltantes
- Variables organizadas en columnas
- Primera columna: variable dependiente (Y)
- Columnas siguientes: variables independientes (X₁, X₂, ..., Xₙ)

### Validaciones
- Verificación de tipos de datos numéricos
- Control de valores atípicos utilizando funciones de MATLAB
- Validación de dimensiones de la matriz
- **Validación de conexión a BD**: Verificación del estado de la conexión PostgreSQL

## ⚙️ Configuración del Entorno

### Toolboxes de MATLAB requeridos:
- **Statistics and Machine Learning Toolbox**: Para funciones de regresión
- **Database Toolbox**: Para conectividad con PostgreSQL
- **Optimization Toolbox** (opcional): Para optimización avanzada

### Configuración del Driver JDBC:
1. Descarga `postgresql-42.7.5.jar` desde [Maven Repository](https://mvnrepository.com/artifact/org.postgresql/postgresql/42.7.5)
2. Coloca el archivo en una carpeta accesible
3. Agrega al classpath de MATLAB:
```matlab
javaaddpath('C:\ruta\al\postgresql-42.7.5.jar')
% O usa una ruta relativa al proyecto
javaaddpath(fullfile(pwd, 'drivers', 'postgresql-42.7.5.jar'))
```

### Solución de problemas comunes:

**Error de conexión JDBC:**
```matlab
% Verificar que el driver esté cargado
javaclasspath
% Debe aparecer el postgresql-42.7.5.jar en la lista
```

**Error de PostgreSQL:**
```matlab
% Verificar servicio de PostgreSQL
% En Windows: services.msc → postgresql-x64-17
% En Linux: sudo systemctl status postgresql
```

## 🛠️ Tecnologías Utilizadas

- **Plataforma principal**: MATLAB R2024b
- **Base de datos**: PostgreSQL 17.4-2
- **Conectividad**: Driver JDBC PostgreSQL 42.7.5
- **Interfaz gráfica**: MATLAB GUI (App Designer o GUIDE)
- **Análisis estadístico**: 
  - Statistics and Machine Learning Toolbox
  - Database Toolbox para conectividad con PostgreSQL
- **Gestión de datos**: SQL queries a través de JDBC

### Arquitectura del sistema:
```
MATLAB R2024b (Frontend + Cálculos)
       ↕ JDBC Driver (postgresql-42.7.5.jar)
PostgreSQL 17.4-2 (Base de datos)
```

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Para contribuir:

1. Haz un fork del proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

### Áreas de mejora sugeridas:
- Exportación de resultados a Excel/CSV
- Gráficos de diagnóstico de residuos
- Soporte para regresión logística
- Validación cruzada
- Interface web

## 📝 Licencia

[Especificar la licencia del proyecto]

## 👨‍💻 Autor

**Frank Pesadilla**
- GitHub: [@Frank-Pesadilla](https://github.com/Frank-Pesadilla)

## 📞 Soporte

Si tienes preguntas o encuentras algún problema:
- Abre un [issue](https://github.com/Frank-Pesadilla/Calculadora-de-Integraci-n-Lineal-M-ltiple/issues)
- Envía un email: [franciscoestuardofranco2004@gmail.com]

## 🔄 Historial de Versiones

### v1.0.0
- Implementación inicial en MATLAB R2024b
- Cálculo de regresión lineal múltiple usando Statistics Toolbox
- Intervalos de confianza básicos
- Integración con PostgreSQL 17.4-2
- Interfaz gráfica MATLAB (GUI)
- Driver JDBC PostgreSQL 42.7.5 para conectividad de BD

### Próximas características planificadas:
- Exportación de resultados a Excel usando `xlswrite`
- Gráficos de diagnóstico con `plotdiag`
- Análisis de residuos avanzado
- Respaldo automático de datos en PostgreSQL

---

⭐ Si este proyecto te ha sido útil, ¡considera darle una estrella!

## 📚 Referencias

- [Teoría de regresión lineal múltiple](enlace-a-referencia)
- [Documentación de intervalos de confianza](enlace-a-referencia)
- [Mejores prácticas en análisis estadístico](enlace-a-referencia)