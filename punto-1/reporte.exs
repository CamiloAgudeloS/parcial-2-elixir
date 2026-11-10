
defmodule Reporte do
  @moduledoc """
  Genera los reportes de movimientos sismicos por ciudad.
  """

  @doc """
  Genera el reporte de una ciudad y calcula sus estadisticas.
  """
  def generar_ciudad(ciudad, movimientos) do
    {cantidad, mayor, suma_profundidades, detalles_invertidos} =
      recorrer_movimientos(
        movimientos,
        ciudad.id_ciudad,
        0,
        nil,
        0.0,
        []
      )

    detalles =
      if cantidad == 0 do
        "Sin movimientos registrados"
      else
        detalles_invertidos
        |> Enum.reverse()
        |> Enum.join("\n")
      end

    mayor_texto =
      case mayor do
        nil ->
          "No aplica"

        movimiento ->
          "#{movimiento.codigo} - #{movimiento.magnitud}"
      end

    promedio_texto =
      if cantidad == 0 do
        "No aplica"
      else
        promedio = suma_profundidades / cantidad
        "#{:erlang.float_to_binary(promedio, decimals: 2)} km"
      end

    Enum.join(
      [
        "Ciudad: #{ciudad.nombre}",
        "Numero de habitantes: #{ciudad.numero_habitantes}",
        "Movimientos:",
        detalles,
        "Total de movimientos: #{cantidad}",
        "Movimiento de mayor magnitud: #{mayor_texto}",
        "Profundidad promedio: #{promedio_texto}"
      ],
      "\n"
    )
  end

  @doc """
  Genera el reporte general de todas las ciudades validas.
  """
  def generar_general(datos) do
    reportes_ciudades =
      datos.ciudades
      |> Enum.map(fn ciudad ->
        generar_ciudad(ciudad, datos.movimientos)
      end)
      |> Enum.join("\n\n")

    Enum.join(
      [
        "REPORTE DE MOVIMIENTOS SISMICOS",
        "",
        reportes_ciudades,
        "",
        "REGISTROS RECHAZADOS",
        "Ciudades: #{datos.rechazados_ciudades}",
        "Movimientos: #{datos.rechazados_movimientos}"
      ],
      "\n"
    ) <> "\n"
  end

  defp recorrer_movimientos(
         [],
         _id_ciudad,
         cantidad,
         mayor,
         suma_profundidades,
         detalles
       ) do
    {cantidad, mayor, suma_profundidades, detalles}
  end

  defp recorrer_movimientos(
         [movimiento | restantes],
         id_ciudad,
         cantidad,
         mayor,
         suma_profundidades,
         detalles
       ) do
    if movimiento.id_ciudad == id_ciudad do
      nuevo_mayor =
        cond do
          mayor == nil ->
            movimiento

          movimiento.magnitud > mayor.magnitud ->
            movimiento

          true ->
            mayor
        end

      detalle =
        "- Codigo: #{movimiento.codigo} | " <>
          "Inicio: #{movimiento.hora_inicio} | " <>
          "Fin: #{movimiento.hora_final} | " <>
          "Magnitud: #{movimiento.magnitud} | " <>
          "Profundidad: #{movimiento.profundidad} km"

      recorrer_movimientos(
        restantes,
        id_ciudad,
        cantidad + 1,
        nuevo_mayor,
        suma_profundidades + movimiento.profundidad,
        [detalle | detalles]
      )
    else
      recorrer_movimientos(
        restantes,
        id_ciudad,
        cantidad,
        mayor,
        suma_profundidades,
        detalles
      )
    end
  end
end
