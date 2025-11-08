defmodule Ogi do
  @moduledoc """
  Renders OpenGraph Images (or really any image you'd like) to PNG using Typst.

  Optionally caches the rendered images based on their filename and assigns in a temporary folder.
  """

  require Logger

  alias Ogi.Cache

  @doc """
  Renders a Typst markup with given assigns and filename to a PNG binary.

  Optionally retrieves a cached version of the image and writes the image to a cache directory
  if the cache is enabled.
  """
  def render_to_png(filename, typst_markup, assigns \\ [], opts \\ []) do
    with {:error, :not_found} <- Cache.maybe_get_cached_image(filename, assigns),
         {:ok, [png | _rest]} <- Typst.render_to_png(typst_markup, assigns, opts),
         :ok <- Cache.maybe_put_image(filename, assigns, png) do
      {:ok, png}
    end
  end

  @doc """
  Renders an OpenGraph Image and sends it as response for a `Plug.Conn`.
  """
  def render_image(%Plug.Conn{} = conn, filename, typst_markup, assigns \\ [], opts \\ []) do
    case render_to_png(filename, typst_markup, assigns, opts) do
      {:ok, png} ->
        conn
        |> Plug.Conn.put_resp_content_type("image/png", nil)
        |> Plug.Conn.put_resp_header(
          "cache-control",
          "public, immutable, no-transform, s-maxage=31536000, max-age=31536000"
        )
        |> Plug.Conn.send_resp(200, png)

      error ->
        Logger.error("Ogi couldn't render the OpenGraph Image for #{filename}: #{inspect(error)}")
        Plug.Conn.send_resp(conn, 404, "Not found")
    end
  end
end
