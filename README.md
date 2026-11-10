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

