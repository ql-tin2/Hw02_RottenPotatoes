class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = self.class.list_ratings
    #@all_ratings = ['G', 'PG', 'PG-13', 'R']
    
    ratings = Hash.new
    @all_ratings.each do |rating_value|
      ratings[rating_value] = 1
    end
    
    #if ratings is not define, set it to all_ratings
    if ( params[:ratings])
      rating_keys =  params[:ratings].keys
      session[:ratings] = params[:ratings]
      ratings = session[:ratings]
      
    else
      if session[:ratings]
        rating_keys = session[:ratings].keys
        ratings = session[:ratings]
      else
        rating_keys = @all_ratings  
      end
      
    end
    
    if (params.has_key?(:title_header))
      session[:title_header] = true
      session.delete :release_date_header
      
      @movies = Movie.find(:all, :conditions => { :rating => rating_keys} ,:order => :title)
    elsif (params.has_key?(:release_date_header))
      session[:release_date_header] = true
      session.delete :title_header
      @movies = Movie.find(:all, :conditions => { :rating => rating_keys}, :order => :release_date)
    else
      if (session[:title_header])
        redirect_to movies_path ({ :title_header => true , :ratings => ratings } )
        #@movies = Movie.find(:all, :conditions => { :rating => rating_keys} ,:order => :title)
      elsif  (session[:release_date_header])
        redirect_to movies_path ({ :release_date_header => true , :ratings => ratings })
        #@movies = Movie.find(:all, :conditions => { :rating => rating_keys} ,:order => :release_date)
      else
        @movies = Movie.find(:all, :conditions => { :rating => rating_keys})
      end
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end
  
  def self.list_ratings
    # http://guides.rubyonrails.org/active_record_querying.html#selecting-specific-fields
    #@unique_rating_set = Movie.select(:rating).uniq
    movies = Movie.all
    
    existing_rating_hash = Hash.new
    
    rating_value_collection = []
    movies.each do |movie|
      if (! existing_rating_hash.has_key?(movie.rating))
        existing_rating_hash[movie.rating] = true
        rating_value_collection = rating_value_collection + [movie.rating]
      end
    end
    
    return rating_value_collection
    
  end

end
