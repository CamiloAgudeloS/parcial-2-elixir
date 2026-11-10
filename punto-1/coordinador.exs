
defmodule Coordinador do
  @moduledoc """
  Coordina la lectura concurrente de ciudades y movimientos.
  """

  @doc """
  Inicia dos trabajadores y reúne los resultados de lectura.
  """
  def cargar_datos(ruta_ciudades, ruta_movimientos) do
    principal_pid = self()

    spawn(fn ->
      resultado = LectorArchivos.leer_ciudades(ruta_ciudades)
      send(principal_pid, {:ciudades, resultado})
    end)

    spawn(fn ->
      resultado = LectorArchivos.leer_movimientos(ruta_movimientos)
      send(principal_pid, {:movimientos, resultado})
    end)

    esperar_resultados(nil, nil)
  end

  defp esperar_resultados(resultado_ciudades, resultado_movimientos) do
    if resultado_ciudades != nil and resultado_movimientos != nil do
      preparar_datos(resultado_ciudades, resultado_movimientos)
    else
      receive do
        {:ciudades, resultado} ->
          esperar_resultados(resultado, resultado_movimientos)

        {:movimientos, resultado} ->
          esperar_resultados(resultado_ciudades, resultado)
      end
    end
  end

  defp preparar_datos(resultado_ciudades, resultado_movimientos) do
    case {resultado_ciudades, resultado_movimientos} do
      {{:ok, ciudades, rechazados_ciudades},
       {:ok, movimientos, rechazados_movimientos}} ->

        {movimientos_validos, rechazados_referencia} =
          Movimiento.filtrar_por_ciudades(movimientos, ciudades)

        datos = %{
          ciudades: ciudades,
          movimientos: movimientos_validos,
          rechazados_ciudades: rechazados_ciudades,
          rechazados_movimientos:
            rechazados_movimientos + rechazados_referencia
        }

        {:ok, datos}

      {{:error, motivo}, _} ->
        {:error, :ciudades, motivo}

      {_, {:error, motivo}} ->
        {:error, :movimientos, motivo}
    end
  end
end
