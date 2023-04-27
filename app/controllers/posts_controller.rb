class PostsController < ApplicationController
  def index
    @posts = Post.order(created_at: :desc)
  end

  def show
    @post = Post.find(params[:id])
    @post.update!(impressions: @post.impressions + 1)
  end

  def edit

  end
end
