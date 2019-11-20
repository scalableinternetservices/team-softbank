class PostsController < ApplicationController
  # before_action :check_logged_in, only: [:create]
  # geocode_ip_address
  # before_action :location, only: [:index, :new, :create]
  respond_to :html, :js

  def index
    # @posts = Post.all
    @location = session[:html5_geoloc]
    @location ||= [0, 0]
    @sort = params[:sort]
    if @sort == 'spice'
      @posts = Post.within(
        5, # TODO: param
        units: :miles,
        origin: @location
      ).order('likes DESC')
    else
      @posts = Post.within(
        5, # TODO: param
        units: :miles,
        origin: @location
      ).by_distance(origin: @location)
    end
  end

  def show
    # TODO: check user loc
    @post = Post.find(params[:id])
    @comments = @post.comments
  end

  def create
    @post = Post.new(post_params) # TODO: author?
    @post.likes = 0
    @post.user_id = current_user.id

    if post_params[:latitude] == 'error'
      # TODO: remove ip geocoding altogether
      # or find a way to use it as fallback
      # esp cause we might need to fallback for load testing
      @post.latitude, @post.longitude = @location
    else
      # TODO: check if present
      # and store in session and cookie
      # this we can hold off until we scale
    end

    @post.save!

    redirect_to @post
  end

  def destroy
    @post = Post.find(params[:id])
    @post.destroy
    redirect_to '/posts/'
  end

  def toggle_like_post
    @post = Post.find(params[:post_id])
    if current_user.liked? @post
      @post.unliked_by current_user
      # Update likes field for sorting by likes
      @post.likes -= 1
      @post.save!
    else
      @post.liked_by current_user
      @post.likes += 1
      @post.save!
    end
    redirect_to @post
  end

  def update_location
    # TODO: check if session is identical
    # TODO: add a cookie and a check jquery-side for scaling
    session[:html5_geoloc] = [params[:latitude], params[:longitude]]
    @location = session[:html5_geoloc]
    @posts = Post.within(
      5, # TODO: param
      units: :miles,
      origin: @location
    ).by_distance(origin: @location)
    respond_to do |format|
      format.js { render layout: false }
    end
  end

  private

  def post_params
    params.require(:post).permit(:title, :body, :latitude, :longitude, :image)
  end

  # def location
  #   @location = session[:geo_location].slice('lat', 'lng').values
  #   @location ||= [0, 0] # TODO: something better
  # end

  def check_logged_in
    redirect_to '/' unless user_signed_in?
  end
end
