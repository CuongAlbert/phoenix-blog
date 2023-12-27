defmodule Blog.Repo.Migrations.AlterPostsTableRemoveVisible do
  use Ecto.Migration

  def change do
    alter table("posts") do
      remove :visible
    end
  end
end
