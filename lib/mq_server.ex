defmodule Mq.Server do
  require Logger

  def accept(port) do
    {:ok, socket} =
      :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])

    Logger.info("Accepting connections on port #{port}")
    loop_acceptor(socket)
  end

  def loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, mq_client} = Mq.Client.start_link(fn msg -> handle_message(msg) end, [])
    serve(client, mq_client)
    loop_acceptor(socket)
  end

  defp handle_message({:topic_message, topic, message}) do
    IO.puts("#{topic}: #{message}")
  end

  def serve(socket, _mq_client) do
    socket |> read_line() |> send_request(socket)
  end

  def read_line(socket) do
    {:ok, data} = :gen_tcp.recv(socket, 0)
    data
  end

  def send_request(line, _socket) do
    IO.puts("Request: #{line}")
  end
end
