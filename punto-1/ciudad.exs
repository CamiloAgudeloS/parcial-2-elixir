
defmodule Ciudad do
  @moduledoc """
  Representa una ciudad y valida sus datos.
  """

  defstruct [:id_ciudad, :nombre, :numero_habitantes]

  @doc """
  Convierte una linea de texto en un struct Ciudad.
  """
  def desde_linea(linea) do
    campos =
      linea
      |> String.trim()
      |> String.split("@")

    case campos do
      [id_ciudad, nombre, numero_habitantes] ->
        id_ciudad = String.trim(id_ciudad)
        nombre = String.trim(nombre)
        numero_habitantes = String.trim(numero_habitantes)

        cond do
          id_ciudad == "" ->
            {:error, "El identificador de la ciudad esta vacio"}

          nombre == "" ->
            {:error, "El nombre de la ciudad esta vacio"}

          numero_habitantes == "" ->
            {:error, "El numero de habitantes esta vacio"}

          true ->
            validar_habitantes(id_ciudad, nombre, numero_habitantes)
        end

      _ ->
        {:error, "La linea de ciudad debe contener tres campos"}
    end
  end

  defp validar_habitantes(id_ciudad, nombre, numero_habitantes) do
    try do
      habitantes = String.to_integer(numero_habitantes)

      if habitantes > 0 do
        ciudad = %Ciudad{
          id_ciudad: id_ciudad,
          nombre: nombre,
          numero_habitantes: habitantes
        }

        {:ok, ciudad}
      else
        {:error, "El numero de habitantes debe ser mayor que cero"}
      end
    rescue
      ArgumentError ->
        {:error, "El numero de habitantes debe ser un entero"}
    end
  end
end
