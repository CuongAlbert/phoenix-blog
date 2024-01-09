defmodule Blog.Tags do
  import Ecto.Query, warn: false
  alias Blog.Repo
  alias Blog.Tags.Tag
  def list_tags do
    Repo.all(Tag)
  end

  def get_tag!(id), do: Repo.get!(Tag, id)
end
