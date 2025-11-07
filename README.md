# Ogi

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
    post = Posts.get_post_by_id(blog_id)

    if post do
      assigns = [
        title: post.title,
      ]

      Ogi.render_image(conn, "#{blog_id}.png", typst_markup(), assigns)
    else
      send_resp(conn, 404, "Not found")
    end
  end

  defp typst_markup do
    # Your generated Typst markup goes here.
    #
    # You can dynamically inline variables with:
    # Blog Title: <%= title %>
  end
end
```

Then you add this

## ToDo's

- [ ] Clean up Cache when a certain size is reached
- [ ] Add fallback OG Image option if render fails
- [ ]