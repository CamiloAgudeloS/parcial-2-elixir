
defmodule Movimiento do
  @moduledoc """
  Representa un movimiento sismico y valida sus datos.
  """

  defstruct [
    :codigo,
    :id_ciudad,
    :hora_inicio,
    :hora_final,
    :magnitud,
    :profundidad
  ]

  @doc """
  Convierte una linea de texto en un struct Movimiento.
  """
  def desde_linea(linea) do
    campos =
      linea
      |> String.trim()
      |> String.split("@")

    case campos do
      [codigo, id_ciudad, hora_inicio, hora_final, magnitud, profundidad] ->
        codigo = String.trim(codigo)
        id_ciudad = String.trim(id_ciudad)
        hora_inicio = String.trim(hora_inicio)
        hora_final = String.trim(hora_final)
        magnitud = String.trim(magnitud)
        profundidad = String.trim(profundidad)

        cond do
          codigo == "" ->
            {:error, "El codigo del movimiento esta vacio"}

          id_ciudad == "" ->
            {:error, "El identificador de la ciudad esta vacio"}

          not hora_valida?(hora_inicio) ->
            {:error, "La hora de inicio no es valida"}

          not hora_valida?(hora_final) ->
            {:error, "La hora final no es valida"}

          magnitud == "" ->
            {:error, "La magnitud esta vacia"}

          profundidad == "" ->
            {:error, "La profundidad esta vacia"}

          true ->
            validar_numeros(
              codigo,
              id_ciudad,
              hora_inicio,
              hora_final,
              magnitud,
              profundidad
            )
        end

      _ ->
        {:error, "La linea de movimiento debe contener seis campos"}
    end
  end

  @doc """
  Filtra los movimientos asociados a ciudades validas.
  Devuelve los movimientos validos y la cantidad rechazada.
  """
  def filtrar_por_ciudades(movimientos, ciudades) do
    movimientos_validos =
      Enum.filter(movimientos, fn movimiento ->
        Enum.any?(ciudades, fn ciudad ->
          ciudad.id_ciudad == movimiento.id_ciudad
        end)
      end)

    rechazados = length(movimientos) - length(movimientos_validos)

    {movimientos_validos, rechazados}
  end

  defp hora_valida?(hora) do
    case Time.from_iso8601(hora) do
      {:ok, hora_convertida} ->
        Time.to_iso8601(hora_convertida) == hora

      {:error, _motivo} ->
        false
    end
  end

  defp validar_numeros(
         codigo,
         id_ciudad,
         hora_inicio,
         hora_final,
         magnitud,
         profundidad
       ) do
    case Float.parse(magnitud) do
      {magnitud_numero, ""} ->
        case Float.parse(profundidad) do
          {profundidad_numero, ""} when profundidad_numero >= 0 ->
            movimiento = %Movimiento{
              codigo: codigo,
              id_ciudad: id_ciudad,
              hora_inicio: hora_inicio,
              hora_final: hora_final,
              magnitud: magnitud_numero,
              profundidad: profundidad_numero
            }

            {:ok, movimiento}

          {_, ""} ->
            {:error, "La profundidad debe ser mayor o igual a cero"}

          _ ->
            {:error, "La profundidad debe ser un numero valido"}
        end

      _ ->
        {:error, "La magnitud debe ser un numero valido"}
    end
  end
end
