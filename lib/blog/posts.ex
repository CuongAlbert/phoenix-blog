defmodule Blog.Posts do
  @moduledoc """
  The Posts context.
  """

  import Ecto.Query, warn: false
  alias Blog.Repo

  alias Blog.Posts.Post
  alias Blog.Comments.Comment

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts(params) do
    search = "%#{params["title"]}%"
    Post
    |> where([p], ilike(p.title, ^search))
    |> where([p], p.visibility == true)
    |> where([p], p.published_on <= ^DateTime.utc_now())
    |> order_by([p], desc: p.published_on)
    |> Repo.all()
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id) do
    comments_query = from c in Comment,
      order_by: [desc: c.inserted_at, desc: c.id],
      preload: :user

    post_query = from p in Post, preload: [:user, :tags, comments: ^comments_query]
    IO.inspect(post_query)
    Repo.get!(post_query, id)
  end

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(attrs \\ %{}, tags \\ []) do
    %Post{}
    |> Post.changeset(attrs, tags)
    |> Repo.insert()
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Post{} = post, attrs, tags \\ []) do
    post
    |> Post.changeset(attrs, tags)
    |> Repo.update()
  end

  @doc """
  Deletes a post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{data: %Post{}}

  """
  def change_post(%Post{} = post, attrs \\ %{}, tags \\ []) do
    Post.changeset(post, attrs, tags)
  end
end
