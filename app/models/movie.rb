class Movie < ActiveRecord::Base
  # class method of movie
  def self.ratings
    Movie.distinct.pluck(:rating).sort
  end
end
