# OGI

Generates and serves OpenGraph Images using Typst.

Inspired by [OG-Image](https://github.com/svycal/og-image/tree/main) but uses Typst instead of Chrome+Puppeteer, so you can add it directly to your Phoenix app.

## Installation

```elixir
def deps do
  [
    {:ogi, "~> 0.1.0"}
  ]
end
```

## Setup

You need these three things:

1. A Typst template.
    - LLMs are pretty good at generating those and you can test them quickly on [typst.app/play](https://typst.app/play/)
2. A Phoenix Controller and Route.
3. An `og:image` metatag in your `<head>` tag.

Below is an example controller for serving OG Images for a blog post.

```elixir
defmodule BlogWeb.ImageController do
  use BlogWeb, :controller

  alias Blog.Posts

  def show(conn, %{"id" => blog_id}) do
    post = Posts.get_post_by_id!(blog_id)
    assigns = [title: post.title]
    Ogi.render_image(conn, "#{blog_id}.png", typst_markup(), assigns)
  end

  defp typst_markup do
    # Your generated Typst markup goes here.
    #
    # You can dynamically inline variables with:
    # Blog Title: <%= title %>
    #
    # Note: There is *no* @ before the variable other than in HEEx templates!
  end
end
```

Then add this route to your router:

```elixir
scope "/", BlogWeb do
  get "/og-image/:id", ImageController, :show
end
```

For adding dynamic Metatags, I recommend the [Metatags](https://github.com/johantell/metatags) library:

```elixir
# In your Controller or LiveView serving the blog post, add this:
def handle_params(%{"id" => post_id}, _url, socket) do
  post = Posts.get_post_by_id!(post_id)

  socket =
    socket
    |> Metatags.put("og:title", post.title)
    |> Metatags.put("og:description", post.description)
    |> Metatags.put("og:image", url(~p"/og-image/#{post_id}"))

  {:ok, socket}
end
```

And that's it! You can test this by navigating to the route manually or by using a browser extension that previews OpenGraph information for a website.

## ToDo's

- [ ] Clean up Cache when a certain size is reached
- [ ] Add fallback OG Image option if render fails
- [ ]