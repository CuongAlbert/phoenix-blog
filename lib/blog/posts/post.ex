defmodule Blog.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :title, :string
    field :content, :string
    field :published_on, :date
    field :visibility, :boolean
    has_many :comments, Blog.Comments.Comment

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :content, :published_on, :visibility])
    |> validate_required([:title, :content, :published_on, :visibility])
    |> unique_constraint(:title)
  end
end
