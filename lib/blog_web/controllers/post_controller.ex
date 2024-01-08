defmodule BlogWeb.PostController do
  use BlogWeb, :controller

  alias Blog.Comments.Comment
  alias Blog.Posts
  alias Blog.Comments
  alias Blog.Posts.Post
  plug :require_user_owns_post when action in [:edit, :update, :delete]

  def index(conn, params) do
    posts = Posts.list_posts(params)
    render(conn, :index, posts: posts)
  end

  def new(conn, _params) do
    changeset = Posts.change_post(%Post{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"post" => post_params}) do
    IO.inspect("dzo create")
    case Posts.create_post(post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post created successfully.")
        |> redirect(to: ~p"/posts/#{post}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def create_comment(conn, %{"comment" => comment_params, "post_id" => post_id}) do
    case Comments.create_comment(post_id, comment_params) do
      {:ok, _comment} ->
        conn
        |> put_flash(:info, "Comment created successfully.")
        # redirect to the post show page where the comment form is rendered
        |> redirect(to: ~p"/posts/#{post_id}")

        {:error, %Ecto.Changeset{} = comment_changeset} ->
        post = Posts.get_post!(comment_params["post_id"])
        # re-render the post show page with a comment changeset that the page uses to display errors.
        render(conn, :show, post: post, comment_changeset: comment_changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    post = Posts.get_post!(id)
    comments = Comments.get_comments!(id)
    comment_changeset = Comments.change_comment(%Comment{})
    render(conn, :show, post: post, comments: comments, comment_changeset: comment_changeset)
  end

  def edit(conn, %{"id" => id}) do
    post = Posts.get_post!(id)
    if conn.assigns[:current_user].id == post.user_id do
      changeset = Posts.change_post(post)
      render(conn, :edit, post: post, changeset: changeset)
    else
      conn
      |> put_flash(:error, "You can only edit your own posts.")
      |> redirect(to: ~p"/posts/#{id}")
      |> halt()
    end
  end

  def change_comment(conn, %{"id" => id}) do
    comment = Comments.get_comment!(id)
    post = Posts.get_post!(comment.post_id)
    if conn.assigns[:current_user].id == comment.user_id do
      comments = Comments.get_comments!(comment.post_id) -- [comment]
      changeset = Comments.change_comment(comment)
      render(conn, :change_comment,comments: comments, comment: comment, post: post, comment_changeset: changeset)
    else
      conn
      |> put_flash(:error, "You can only edit your own comments.")
      |> redirect(to: ~p"/posts/#{post.id}")
      |> halt()
    end
  end

  def update(conn, %{"id" => id, "post" => post_params}) do
    post = Posts.get_post!(id)
    case Posts.update_post(post, post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post updated successfully.")
        |> redirect(to: ~p"/posts/#{post}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, post: post, changeset: changeset)
    end
  end

  def update_comment(conn, %{"id" => id, "comment" => comment_params}) do
    comment = Comments.get_comment!(id)
    post = Posts.get_post!(comment.post_id)
    case Comments.update_comment(comment, comment_params) do
      {:ok, _comment} ->
        conn
        |> put_flash(:info, "Comment updated successfully.")
        |> redirect(to: ~p"/posts/#{post}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :change_comment, post: post, comment: comment, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    post = Posts.get_post!(id)
    if conn.assigns[:current_user].id == post.user_id do
      {:ok, _post} = Posts.delete_post(post)

      conn
      |> put_flash(:info, "Post deleted successfully.")
      |> redirect(to: ~p"/posts")
    else
      conn
      |> put_flash(:error, "You can only delete your own posts.")
      |> redirect(to: ~p"/posts/#{id}")
      |> halt()
    end
  end

  def delete_comment(conn, %{"id" => id}) do
    comment = Comments.get_comment!(id)
    post = Posts.get_post!(comment.post_id)
    if conn.assigns[:current_user].id == post.user_id do
      {:ok, _comment} = Comments.delete_comment(comment)

      conn
      |> put_flash(:info, "Comment deleted successfully.")
      |> redirect(to: ~p"/posts/#{comment.post_id}")
    else
      conn
      |> put_flash(:error, "You can only delete your own comments.")
      |> redirect(to: ~p"/posts/#{id}")
      |> halt()
    end
  end

  defp require_user_owns_post(conn, _params) do
    post_id = String.to_integer(conn.path_params["id"])
    post = Posts.get_post!(post_id)

    if conn.assigns[:current_user].id == post.user_id do
      conn
    else
      conn
      |> put_flash(:error, "You can only edit or delete your own posts.")
      |> redirect(to: ~p"/posts/#{post_id}")
      |> halt()
    end
  end
end
