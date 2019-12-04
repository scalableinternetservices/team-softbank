class CommentsController < ApplicationController
  def create
    @comment = Comment.create!(post_id: params[:post_id], user_id: params[:user_id], body: params[:body])
    Post.find(params[:post_id]).touch
    redirect_to(@comment.post)
  end

  def destroy
    @comment = Comment.find(params[:id])
    post_path = "/posts/#{@comment.post_id}"
    @comment.destroy!
    Post.find(params[:post_id]).touch
    redirect_to(post_path)
  end

  def toggle_like_comment
    @comment = Comment.find(params[:comment_id])
    @comments_page_num = (params[:comments_page_num] || 1).to_i
    if current_user.liked? @comment
      @comment.unliked_by! current_user
    else
      @comment.liked_by! current_user
    end
    redirect_to post_path(id: @comment.post_id, comments_page_num: @comments_page_num)
  end
end
