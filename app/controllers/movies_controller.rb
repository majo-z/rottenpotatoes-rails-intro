class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    # @movies = Movie.all
    sort = params[:sort_by] || session[:sort_by]
    session[:sort_by] = sort
    
    # get all ratings (G, PG, PG-13, R)
    # @all_ratings = Movie.uniq.pluck(:rating).sort 
    # @all_ratings = Movie.distinct.pluck(:rating).sort # moved to movie.rb
    @all_ratings = Movie.ratings
    
    # @rating = @all_ratings
    # @rating = params[:ratings].keys if params.keys.include? 'ratings'
    
    if params.keys.include? 'ratings'
      @rating = params[:ratings].keys if params[:ratings].is_a? Hash
      @rating = params[:ratings] if params[:ratings].is_a? Array
    elsif session.keys.include? 'ratings'
      @rating = session[:ratings]
    else
      @rating = @all_ratings
    end
    session[:ratings] = @rating

    if params[:ratings] != session[:ratings] || params[:sort_by] != session[:sort_by]
      session[:sort_by] = sort
      session[:ratings] = @rating
      redirect_to sort_by: sort, ratings: @rating and return
    end

    # @movies = Movie.order(sort)
    @movies = Movie.where(rating: @rating).order(sort)

    @title_header = 'hilite' if sort == 'title'
    @release_date_header = 'hilite' if sort == 'release_date'
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

end
