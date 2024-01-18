defmodule Mq.Server do
  require Logger

  @doc """
  Loops a listen on `port`, spinning off new Tasks to serve clients.
  """
  def accept(port) do
    {:ok, socket} =
      :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])

    Logger.info("Accepting connections on port #{port}")
    loop_acceptor(socket)
  end

  defp message_listener(socket) do
    receive do
      {:topic_message, topic, message} ->
        write_line(socket, {:ok, %{"topic" => topic, "body" => message}})
    end

    message_listener(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)

    {:ok, listener_process} =
      Task.Supervisor.start_child(Mq.TaskSupervisor, fn ->
        message_listener(client)
      end)

    {:ok, pid} =
      Task.Supervisor.start_child(Mq.TaskSupervisor, fn -> serve(client, listener_process) end)

    :ok = :gen_tcp.controlling_process(client, pid)
    loop_acceptor(socket)
  end

  defp serve(socket, listener_process) do
    result =
      with {:ok, data} <- read_line(socket),
           {:ok, command} <- Mq.Command.parse(data),
           do: Mq.Command.run(command, listener_process)

    write_line(socket, result)

    serve(socket, listener_process)
  end

  defp read_line(socket) do
    :gen_tcp.recv(socket, 0)
  end

  defp write_line(socket, {:ok, %{"topic" => topic, "body" => body}}) do
    msg =
      "#{Jason.encode!(%{"status" => "message", "message" => %{"topic" => topic, "body" => body}})}"

    :gen_tcp.send(socket, msg)
  end

  defp write_line(socket, {:ok, text}) do
    msg = "#{Jason.encode!(%{"status" => "ok", "message" => "#{text}"})}"
    :gen_tcp.send(socket, msg)
  end

  defp write_line(socket, {:error, :unknown_command}) do
    msg = "#{Jason.encode!(%{"status" => "error", "message" => "UNKNOWN COMMAND"})}"
    :gen_tcp.send(socket, msg)
  end

  defp write_line(socket, {:error, :bad_json_format}) do
    msg = "#{Jason.encode!(%{"status" => "error", "message" => "Bad JSON format"})}"
    :gen_tcp.send(socket, msg)
  end

  defp write_line(socket, {:error, :not_found}) do
    msg = "#{Jason.encode!(%{"status" => "error", "message" => "Not found"})}"
    :gen_tcp.send(socket, msg)
  end

  defp write_line(_socket, {:error, :closed}) do
    exit(:shutdown)
  end

  defp write_line(socket, {:error, msg}) do
    error_message = "#{Jason.encode!(%{"status" => "error", "message" => "#{msg}"})}"
    :gen_tcp.send(socket, error_message)
    exit(error_message)
  end
end
