# Parcial II – Programación III

**Universidad del Quindío** · Ingeniería de Sistemas y Computación  
**Autores:** Juan Camilo Agudelo·Jeronimo Delgado

## Descripción

Solución en **Elixir** del Parcial II: generación local de reportes sísmicos y consulta de reportes entre nodos. Se utilizan structs, validaciones, recursividad, lectura de archivos y comunicación entre procesos mediante `spawn`, `send` y `receive`.

## Organización

- `punto-1/`: módulos del reporte local y carpeta `resources/`.
- `punto-2/nodo-servidor/`: servicio que procesa consultas y sus propios archivos en `resources/`.
- `punto-2/nodo-cliente/`: cliente que solicita y muestra reportes.

## Punto 1 – Reporte local

**Desde la raíz del repositorio:**

```bash
cd punto-1
elixir main.exs
```

**Entradas:** `punto-1/resources/ciudades.txt` y `punto-1/resources/movimientos.txt`. Cada línea contiene campos separados por `@` y no hay encabezados.

**Salida:** el reporte se muestra en consola y se genera automáticamente en `punto-1/resources/reporte_sismos.txt`. Se reemplaza en cada ejecución exitosa; si falla la lectura de una entrada, se conserva el reporte anterior.

El reporte incluye todas las ciudades válidas, detalles de sus movimientos, cantidad, magnitud máxima, profundidad promedio y registros rechazados por archivo. Los datos incluidos son **simulados para probar la aplicación**.

## Punto 2 – Consulta entre nodos

Se requieren **dos terminales** y la misma cookie de Erlang. Los siguientes comandos son los previstos para los nombres de nodo `servidor` y `cliente` y deben comprobarse al integrar el código del Punto 2.

**Terminal 1 — servidor (desde la raíz del repositorio):**

```bash
cd punto-2/nodo-servidor
elixir --sname servidor --cookie sismos_p2 nodo_servidor.exs
```

**Terminal 2 — cliente (desde la raíz del repositorio):**

```bash
cd punto-2/nodo-cliente
elixir --sname cliente --cookie sismos_p2 nodo_cliente.exs
```

El cliente debe conectar mediante `Node.connect/1` con el **nombre completo real del nodo servidor** (`servidor@nombre_equipo`), registrar `:servicio_respuesta` y enviar las consultas a `:servicio_sismos`. Los nombres de nodo y la cookie deben coincidir con la implementación final.

**Casos de verificación:** `C01` (con movimientos), `C03` (sin movimientos) y `C99` (inexistente). Después se solicita el reporte general y se envía `:fin`. Para comprobar que el servidor sigue atendiendo, **ejecutar de nuevo el comando del cliente sin reiniciar el servidor**. El servidor utiliza sus archivos en `punto-2/nodo-servidor/resources/`.

## Reflexión sobre el uso de inteligencia artificial

1. **Herramientas utilizadas**

Durante el desarrollo del parcial utilizamos ChatGPT como apoyo para analizar el enunciado, organizar los módulos, implementar algunas partes del código y diseñar pruebas de funcionamiento.

En el Punto 1, uno de sus principales aportes fue ayudarnos a verificar cada módulo por separado antes de integrarlo al programa. Realizamos pruebas para comprobar la validación de ciudades y movimientos, la lectura de archivos, los cálculos del reporte y la comunicación entre procesos.

Posteriormente, comprobamos el funcionamiento completo del programa, incluyendo la conservación del reporte anterior ante errores de lectura, la actualización de los datos y el manejo de errores de escritura.

La IA proponía el código y los casos de prueba, mientras que nosotros los ejecutábamos en nuestro entorno, revisábamos los resultados y comprobábamos que cumplieran con lo solicitado en el enunciado.

2. **Partes del problema desarrolladas con apoyo de IA**

La IA tuvo una participación importante en la implementación de las partes que consideramos más complejas:

Recursividad del reporte: ayudó a estructurar una función que calcula la cantidad de movimientos, identifica la magnitud máxima y acumula las profundidades en un mismo recorrido.

Rutas y persistencia: ayudó a implementar la ubicación de los archivos con Path.join/2, la lectura con File.read/1 y el almacenamiento del reporte con File.write/2, incluyendo el manejo de errores.

3. **Idea complementaria**

Una de las sugerencias de la IA que no habíamos trabajado directamente en clase fue utilizar Time.from_iso8601 para validar las horas de los movimientos sísmicos.

Inicialmente conocíamos la necesidad de comprobar el formato HH:MM:SS, pero no una función específica para validar que los valores correspondieran a una hora real.

La IA propuso esta alternativa y profundizamos en su funcionamiento mediante la documentación oficial de Elixir. También se utilizó Time.to_iso8601 para comprobar que las horas conservaran el formato solicitado.

4. **Conclusiones**

Consideramos que uno de los temas que mejor comprendemos es el manejo de procesos concurrentes en Elixir, especialmente el uso de spawn, self, send y receive, la comunicación mediante mensajes y la importancia de no depender del orden en que terminan los procesos.

Por esta razón decidimos utilizar estas herramientas en lugar de Task, ya que corresponden a los ejemplos trabajados en clase y nos permiten comprender directamente cómo se crean los procesos y cómo intercambian información.

Por otra parte, todavía necesitamos reforzar algunos conceptos relacionados con la construcción de rutas mediante Path.join la lectura y escritura de archivos y el manejo de errores durante la persistencia. Aunque comprobamos su funcionamiento, son aspectos en los que dependimos más del apoyo de la IA.

