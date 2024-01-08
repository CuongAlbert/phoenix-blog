defmodule Blog.PostsTest do
  use Blog.DataCase

  alias Blog.Posts

  describe "posts" do
    alias Blog.Posts.Post

    import Blog.PostsFixtures

    @invalid_attrs %{title: nil, content: nil, published_on: nil, visibility: nil, user_id: nil}

    test "list_posts/0 returns all posts" do
      post = post_fixture()
      assert Posts.list_posts() == [post]
    end

    test "get_post!/1 returns the post with given id" do
      post = post_fixture()
      assert Posts.get_post!(post.id) == post
    end

    test "create_post/1 with valid data creates a post" do
      valid_attrs = %{title: "some title", subtitle: "some subtitle", content: "some content"}

      assert {:ok, %Post{} = post} = Posts.create_post(valid_attrs)
      assert post.title == "some title"
      assert post.subtitle == "some subtitle"
      assert post.content == "some content"
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Posts.create_post(@invalid_attrs)
    end

    test "update_post/2 with valid data updates the post" do
      post = post_fixture()
      update_attrs = %{title: "some updated title", subtitle: "some updated subtitle", content: "some updated content"}

      assert {:ok, %Post{} = post} = Posts.update_post(post, update_attrs)
      assert post.title == "some updated title"
      assert post.subtitle == "some updated subtitle"
      assert post.content == "some updated content"
    end

    test "update_post/2 with invalid data returns error changeset" do
      post = post_fixture()
      assert {:error, %Ecto.Changeset{}} = Posts.update_post(post, @invalid_attrs)
      assert post == Posts.get_post!(post.id)
    end

    test "renders form for editing chosen post", %{conn: conn} do
      user = user_fixture()
      post = post_fixture(user_id: user.id)
      # log in the user
      conn = conn |> log_in_user(user) |> get(~p"/posts/#{post}/edit")
      assert html_response(conn, 200) =~ "Edit Post"
    end

    test "a user cannot edit another user's post", %{conn: conn} do
      post_user = user_fixture()
      other_user = user_fixture()
      post = post_fixture(user_id: post_user.id)
      conn = conn |> log_in_user(other_user) |> get(~p"/posts/#{post}/edit")
      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "You can only edit or delete your own posts."
      assert redirected_to(conn) == ~p"/posts/#{post}"
    end

    test "delete_post/1 deletes the post" do
      user = user_fixture()
      post = post_fixture()
      assert {:ok, %Post{}} = Posts.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Posts.get_post!(post.id) end
    end

    test "change_post/1 returns a post changeset" do
      post = post_fixture()
      assert %Ecto.Changeset{} = Posts.change_post(post)
    end
  end
end
