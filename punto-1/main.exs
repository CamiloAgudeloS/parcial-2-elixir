
# Cargar los modulos del Punto 1
Code.require_file("ciudad.exs", __DIR__)
Code.require_file("movimiento.exs", __DIR__)
Code.require_file("lector_archivos.exs", __DIR__)
Code.require_file("reporte.exs", __DIR__)
Code.require_file("coordinador.exs", __DIR__)

defmodule Main do
  @moduledoc """
  Ejecuta el reporte local de movimientos sismicos.
  """

  @doc """
  Coordina la generacion, visualizacion y almacenamiento
  del reporte sismico.
  """
  def main do
    ruta_ciudades = Path.join(__DIR__, "resources/ciudades.txt")
    ruta_movimientos = Path.join(__DIR__, "resources/movimientos.txt")
    ruta_reporte = Path.join(__DIR__, "resources/reporte_sismos.txt")

    case Coordinador.cargar_datos(ruta_ciudades, ruta_movimientos) do
      {:ok, datos} ->
        reporte = Reporte.generar_general(datos)

        IO.puts(reporte)

        case File.write(ruta_reporte, reporte) do
          :ok ->
            IO.puts("Reporte guardado correctamente en: #{ruta_reporte}")

          {:error, motivo} ->
            IO.puts("Error al guardar el reporte: #{inspect(motivo)}")
        end

      {:error, archivo, motivo} ->
        IO.puts("Error al leer el archivo de #{archivo}: #{inspect(motivo)}")
        IO.puts("El reporte anterior se conserva.")
    end
  end
end

Main.main()
