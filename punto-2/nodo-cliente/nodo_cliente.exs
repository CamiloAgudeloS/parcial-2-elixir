defmodule NodoCliente do
  @moduledoc """
  Nodo cliente del Observatorio Sismologico.
  Envia consultas al nodo servidor y muestra las respuestas.
  """

  @servicio_servidor :servicio_sismos
  @servicio_respuesta :servicio_respuesta

  # Identificadores de prueba (ver datos en resources/ del servidor)
  @ciudad_con_movimientos "C01"
  @ciudad_sin_movimientos "C03"
  @ciudad_inexistente "C99"


  @doc """
  Registra el proceso de respuesta, se conecta al servidor,
  envia las solicitudes y muestra las respuestas hasta recibir :fin.
  Opcionalmente recibe el nombre completo del nodo servidor como argumento.
  """
  def main(argumentos) do
    nodo_servidor = nodo_servidor(argumentos)

    Process.register(self(), @servicio_respuesta)

    case conectar(nodo_servidor) do
      :ok ->
        IO.puts("Conectado al nodo #{nodo_servidor}")
        enviar_solicitudes(nodo_servidor)
        recibir_respuestas(1)

      {:error, motivo} ->
        IO.puts("Error: #{motivo}")
        System.halt(1)
    end
  end

  # Si no se indica el nodo, se asume "servidor" en el mismo equipo.
  defp nodo_servidor([nombre_completo | _]), do: String.to_atom(nombre_completo)

  defp nodo_servidor([]) do
    equipo =
      node()
      |> Atom.to_string()
      |> String.split("@")
      |> List.last()

    String.to_atom("servidor@" <> equipo)
  end

  defp conectar(nodo_servidor) do
    case Node.connect(nodo_servidor) do
      true ->
        :ok

      _ ->
        {:error,
         "no fue posible conectarse a #{nodo_servidor}. " <>
           "Verifique que el servidor este iniciado, el nombre del nodo y que la cookie coincida."}
    end
  end

  defp enviar_solicitudes(nodo_servidor) do
    destino_respuesta = {@servicio_respuesta, node()}

    solicitudes = [
      {:reporte_ciudad, @ciudad_con_movimientos},
      {:reporte_ciudad, @ciudad_sin_movimientos},
      {:reporte_ciudad, @ciudad_inexistente},
      :reporte_general,
      :fin
    ]

    Enum.each(solicitudes, fn solicitud ->
      send({@servicio_servidor, nodo_servidor}, {destino_respuesta, solicitud})
    end)
  end

  # Recepcion recursiva: continua hasta recibir :fin.

defp recibir_respuestas(numero) do
  receive do
    :fin ->
      IO.puts("Confirmacion :fin recibida. Cliente finalizado.")

    respuesta ->
      IO.puts("===== Respuesta #{numero} =====")
      mostrar(respuesta)
      IO.puts("")
      recibir_respuestas(numero + 1)
  end
end


  defp mostrar(respuesta) when is_binary(respuesta), do: IO.puts(respuesta)
  defp mostrar(respuesta), do: IO.inspect(respuesta)
end

NodoCliente.main(System.argv())
