defmodule Blog.Repo.Migrations.AlterPostsTableAddVisibility do
  use Ecto.Migration

  def change do
    alter table("posts") do
      add :visibility, :boolean, default: true
    end
  end
end
