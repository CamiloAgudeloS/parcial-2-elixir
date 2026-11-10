# Se reutilizan los modulos del Punto 1 (structs, validaciones y calculos)
punto_1 = Path.expand("../../punto-1", __DIR__)

Code.require_file("ciudad.exs", punto_1)
Code.require_file("movimiento.exs", punto_1)
Code.require_file("lector_archivos.exs", punto_1)
Code.require_file("reporte.exs", punto_1)
Code.require_file("coordinador.exs", punto_1)

defmodule NodoServidor do
  @moduledoc """
  Nodo servidor del Observatorio Sismologico.
  Atiende solicitudes de reportes enviadas por nodos cliente.
  """

  @nombre_servicio :servicio_sismos

  def iniciar do
    Process.register(self(), @nombre_servicio)
    IO.puts("Servidor listo en el nodo #{node()}")
    esperar_solicitudes()
  end

  # Recibe {destino_respuesta, solicitud}, con destino_respuesta = {nombre, nodo}.
  # Atiende una solicitud a la vez, por lo que responde en el orden de llegada.
  defp esperar_solicitudes do
    receive do
      {{nombre, nodo} = destino, solicitud} when is_atom(nombre) and is_atom(nodo) ->
        atender(destino, solicitud)

      _mensaje_desconocido ->
        :ok
    end

    esperar_solicitudes()
  end

  defp atender(destino, :fin) do
    IO.puts("Solicitud :fin recibida de #{inspect(destino)}")
    send(destino, :fin)
  end

  defp atender(destino, solicitud) do
    IO.puts("Solicitud recibida de #{inspect(destino)}: #{inspect(solicitud)}")
    send(destino, responder(solicitud))
  end

  defp responder({:reporte_ciudad, id_ciudad}) do
    con_datos(fn datos -> reporte_ciudad(datos, id_ciudad) end)
  end

  defp responder(:reporte_general) do
    con_datos(fn datos -> Reporte.generar_general(datos) end)
  end

  defp responder(solicitud), do: "Solicitud no reconocida: #{inspect(solicitud)}"

  defp reporte_ciudad(datos, id_ciudad) do
    case Enum.find(datos.ciudades, fn ciudad -> ciudad.id_ciudad == id_ciudad end) do
      nil -> "La ciudad no está registrada"
      ciudad -> Reporte.generar_ciudad(ciudad, datos.movimientos)
    end
  end

  # Lectura concurrente de ambos archivos (Coordinador del Punto 1).
  defp con_datos(generar_reporte) do
    case Coordinador.cargar_datos(ruta("ciudades.txt"), ruta("movimientos.txt")) do
      {:ok, datos} ->
        generar_reporte.(datos)

      {:error, archivo, motivo} ->
        "Error al leer el archivo de #{archivo}: #{inspect(motivo)}"
    end
  end

  defp ruta(nombre), do: Path.join([__DIR__, "resources", nombre])
end

NodoServidor.iniciar()
