defmodule ShopWeb.LightLive do
  Phoenix.LiveView.Socket
  # alias ShopWeb.LightLive
  use ShopWeb, :live_view

  def inc(pid) do
    send(pid, :inc)
  end

  def mount(_params, _session, socket) do
    # :timer.apply_interval(1000, IO, :puts, ["xxx"])
    # :timer.apply_interval(10, ShopWeb.LightLive, :inc, [self()])
    socket
    |> assign(:brightness, 0)
    |> ok()
  end

  def handle_event("inc", _, socket) do
    socket
    |> update(:brightness, &min(100, &1 + 10))
    |> noreply()
  end

  def handle_event("dec", _, socket) do
    socket
    |> update(:brightness, &max(0, &1 - 10))
    |> noreply()
  end

  def render(assigns) do
    ~H"""
    <div><%= self() |> :erlang.pid_to_list() %></div>
    <h1>Front Porch Light</h1>
    <div id="light">
      <div class="meter">
        <span style={"width: #{@brightness}%"}>
          <%= @brightness %>%
        </span>
      </div>
    </div>

    <button phx-click="dec">
      dec
    </button>

    <button phx-click="inc">
      inc
    </button>
    """
  end

  def handle_info(:inc, socket) do
    socket
    |> update(:brightness, &min(100, &1 + 10))
    |> noreply()
  end

  def handle_info(:dec, socket) do
    socket
    |> update(:brightness, &max(0, &1 - 10))
    |> noreply()
  end
end
