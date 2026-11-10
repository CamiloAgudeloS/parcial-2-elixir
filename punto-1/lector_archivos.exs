
defmodule LectorArchivos do
  @moduledoc """
  Lee y procesa los archivos de ciudades y movimientos sismicos.
  """

  @doc """
  Lee el archivo de ciudades y devuelve los registros validos
  junto con la cantidad de registros rechazados.
  """
  def leer_ciudades(ruta_ciudades) do
    case File.read(ruta_ciudades) do
      {:ok, contenido} ->
        {ciudades, rechazados} =
          procesar_lineas(contenido, fn linea ->
            Ciudad.desde_linea(linea)
          end)

        {:ok, ciudades, rechazados}

      {:error, motivo} ->
        {:error, motivo}
    end
  end

  @doc """
  Lee el archivo de movimientos y devuelve los registros validos
  junto con la cantidad de registros rechazados.
  """
  def leer_movimientos(ruta_movimientos) do
    case File.read(ruta_movimientos) do
      {:ok, contenido} ->
        {movimientos, rechazados} =
          procesar_lineas(contenido, fn linea ->
            Movimiento.desde_linea(linea)
          end)

        {:ok, movimientos, rechazados}

      {:error, motivo} ->
        {:error, motivo}
    end
  end

  defp procesar_lineas(contenido, convertir_linea) do
    {registros, rechazados} =
      contenido
      |> String.split("\n")
      |> Enum.reduce({[], 0}, fn linea, {registros, rechazados} ->
        if String.trim(linea) == "" do
          {registros, rechazados}
        else
          case convertir_linea.(linea) do
            {:ok, registro} ->
              {[registro | registros], rechazados}

            {:error, _motivo} ->
              {registros, rechazados + 1}
          end
        end
      end)

    {Enum.reverse(registros), rechazados}
  end
end
