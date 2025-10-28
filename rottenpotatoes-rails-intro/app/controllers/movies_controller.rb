class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @movies = Movie.all
    @all_ratings = Movie.all_ratings
    # @ratings_to_show = params[:ratings] || session[:ratings] || Hash[@all_ratings.map { |r| [r, "1"] }]
    # @sort_by = params[:sort_by] || session[:sort_by]

    #if (params[:ratings].nil? && session[:ratings]) || (params[:sort_by].nil? && session[:sort_by])
      #redirect_to movies_path(ratings: session[:ratings], sort_by: session[:sort_by])
      #return
    #end

    if params[:ratings].present?
    # if params.key?(:ratings)
      # @ratings_to_show = params[:ratings]&.keys || []
      # @ratings_to_show = @all_ratings if @ratings_to_show.empty?
      @ratings_to_show = params[:ratings].keys
      session[:ratings] = params[:ratings]
    elsif params[:ratings] == nil && session[:ratings]
      # @ratings_to_show = @all_ratings
      @ratings_to_show = session[:ratings].keys
    elsif session[:ratings]
      @ratings_to_show = session[:ratings].keys
    else
      @ratings_to_show = @all_ratings
    end

    #puts "Ratings to show: #{@ratings_to_show.inspect}"

    if params[:sort_by]
      @sort_by = params[:sort_by]
      session[:sort_by] = @sort_by
    elsif session[:sort_by]
      @sort_by = session[:sort_by]
    else
      @sort_by = nil
    end

    @ratings_to_show_hash = Hash[@ratings_to_show.map { |rating| [rating, '1'] }]

    @movies = Movie.with_ratings(@ratings_to_show)
    if @sort_by.present? && ["title", "release_date"].include?(@sort_by)
      @movies = @movies.order(@sort_by)
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
