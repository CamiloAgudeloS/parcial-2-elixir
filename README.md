# Parcial II – Programación III

**Universidad del Quindío**  
**Programa:** Ingeniería de Sistemas y Computación

**Autores:**
- Juan Camilo Agudelo
- Jerónimo Delgado

## Descripción

Solución en **Elixir** del Parcial II, que comprende la generación local de reportes sísmicos y la consulta de reportes entre nodos.

Se utilizan structs, validaciones, recursividad, lectura y escritura de archivos, y comunicación entre procesos mediante `spawn`, `send` y `receive`.

## Organización del proyecto

- `punto-1/`: módulos para generar el reporte local y carpeta `resources/`.
- `punto-2/nodo-servidor/`: servicio que procesa las consultas reutilizando los módulos del Punto 1 y sus propios archivos de datos.
- `punto-2/nodo-cliente/`: cliente encargado de solicitar y mostrar los reportes.

## Punto 1 – Reporte local

**Desde la raíz del repositorio:**

```bash
cd punto-1
elixir main.exs
```

**Archivos de entrada:**
- `punto-1/resources/ciudades.txt`
- `punto-1/resources/movimientos.txt`

Los registros están separados por `@` y no contienen encabezados.

**Archivo de salida:**

`punto-1/resources/reporte_sismos.txt`

El reporte se muestra en consola y se genera automáticamente en el archivo indicado. Cada ejecución exitosa actualiza su contenido; si falla la lectura de alguno de los archivos, se conserva el reporte anterior.

Se incluyen todas las ciudades válidas, los detalles de sus movimientos, las estadísticas de magnitud y profundidad, y los registros rechazados por archivo.

Los datos utilizados son **simulados con fines académicos y de prueba**.

## Punto 2 – Consulta entre nodos

Para ejecutar el Punto 2 se necesitan **dos terminales**, utilizando la misma cookie de Erlang. Los siguientes comandos están preparados para ejecutar ambos nodos en el mismo computador.

**Terminal 1 – Servidor (desde la raíz del repositorio):**

```bash
cd punto-2/nodo-servidor
elixir --sname servidor --cookie sismos_p2 nodo_servidor.exs
```

**Terminal 2 – Cliente (desde la raíz del repositorio):**

```bash
cd punto-2/nodo-cliente
elixir --sname cliente --cookie sismos_p2 nodo_cliente.exs
```

El servidor registra el proceso `:servicio_sismos` y el cliente registra `:servicio_respuesta`. La conexión se establece mediante `Node.connect/1`, utilizando los nombres de los nodos y la misma cookie.

El cliente identifica automáticamente el nodo `servidor@nombre_equipo` cuando ambos programas se ejecutan en el mismo computador.

### Casos de verificación

- `C01`: ciudad con movimientos registrados.
- `C03`: ciudad sin movimientos registrados.
- `C99`: ciudad inexistente.
- `:reporte_general`: reporte de todas las ciudades.
- `:fin`: confirmación de finalización del cliente.

Para comprobar que el servidor continúa atendiendo solicitudes, se debe **ejecutar nuevamente el comando del cliente sin reiniciar el servidor**.

El servidor utiliza los archivos de `punto-2/nodo-servidor/resources/` y reutiliza los módulos del Punto 1.

Una vez terminadas las pruebas, el servidor puede detenerse manualmente desde su terminal.

## Reflexión sobre el uso de inteligencia artificial

### 1. Herramientas utilizadas

Durante el desarrollo del parcial utilizamos **ChatGPT** como apoyo para analizar el enunciado, organizar los módulos, implementar algunas partes del código y diseñar pruebas de funcionamiento.

En el Punto 1, uno de sus principales aportes fue ayudarnos a comprobar cada módulo por separado antes de integrarlo. Realizamos pruebas sobre las validaciones, la lectura de archivos, la recursividad del reporte y la coordinación de procesos.

Durante el punto 2, la IA cumplió la función de asesoramiento en el caso de que aparecieran errores desconocidos o malos funcionamientos durante el proceso. Así mismo, tambien ayudó a entender en mayor profundidad algunos de los conceptos así como tambien su aplicación dentro del proyecto y en su desarrollo.

Posteriormente, verificamos el funcionamiento completo, incluyendo la actualización de los datos, la conservación del reporte anterior ante errores de lectura y el manejo de errores de escritura.

La IA proponía soluciones y pruebas, mientras que nosotros las ejecutábamos, revisábamos los resultados y comprobábamos su cumplimiento frente al enunciado.

### 2. Partes desarrolladas con IA


La IA tuvo mayor participación en algunas partes que consideramos complejas:

- **Recursividad:** ayudó a estructurar el recorrido que calcula la cantidad de movimientos, identifica la magnitud máxima y acumula las profundidades.
- **Coordinación:** apoyó la organización de la recepción recursiva de los resultados de los trabajadores, sin depender de su orden de llegada.
- **Rutas y persistencia:** ayudó a implementar `Path.join/2`, `File.read/1` y `File.write/2`, junto con el manejo de errores.

- **nodo servidor:**  ayudó con el bucle recursivo de espera, atención de `{:reporte_ciudad, id}`, `:reporte_general` y `:fin`, y reutilización del Coordinador del Punto 1 para leer los archivos de forma concurrente.

Recurrimos a este apoyo porque estas partes requerían integrar varios conceptos y contemplar situaciones que inicialmente no teníamos completamente claras.

### 3. Idea complementaria 

Una sugerencia de la IA que no habíamos trabajado directamente en clase fue utilizar `Time.from_iso8601/1` para validar las horas de los movimientos sísmicos.

Aunque conocíamos el formato `HH:MM:SS`, no sabíamos cómo utilizar una función específica para comprobar que los valores correspondieran a una hora válida.

La IA propuso esta implementación y profundizamos en su funcionamiento consultando la documentación oficial de Elixir. También utilizamos `Time.to_iso8601/1` para verificar que las horas conservaran el formato solicitado.


Esta experiencia nos permitió conocer funciones adicionales y comprender la importancia de consultar la documentación oficial cuando utilizamos herramientas nuevas.

### 4. Conclusiones y aprendizajes

Consideramos que uno de los temas que mejor comprendemos es el manejo de **procesos concurrentes en Elixir**, especialmente `spawn`, `self`, `send` y `receive`, la comunicación mediante mensajes y la importancia de no depender del orden en que terminan los procesos.

Por esta razón decidimos utilizar estas herramientas en lugar de `Task`, ya que corresponden a los ejemplos trabajados en clase y nos permiten comprender directamente cómo se crean los procesos y cómo intercambian información.

Por otra parte, todavía necesitamos reforzar conceptos relacionados con la construcción de rutas mediante `Path.join/2`, la lectura y escritura de archivos y el manejo de errores durante la persistencia. Aunque verificamos su funcionamiento, son aspectos en los que dependimos más del apoyo de la IA.
