require 'omdb/network'
require 'omdb/movie'
module Omdb
  class Api
    
    def self.config
      @@config ||= {}
    end

    def self.key(api_key)
      config[:api_key] = api_key
    end
    
    
    def search(search_term)
      res = network.call(s: search_term)
      if res[:data]["Response"] == "False"
        { movies: {}, status: 404 }
      else
        { movies: parse_movies(res[:data]), status: res[:code] }
      end
    end

    # fetchs a movie with a given title
    # set tomatoes to true if you want to get the rotten tomatoes ranking
    # set plot to full if you want to have the full, long plot
    def fetch(title, year = "", tomatoes = false, plot = "short")
      res = network.call({ t: title, y: year, tomatoes: tomatoes, plot: plot, apikey: @@config[:api_key] })

      if res[:data]["Response"] == "False"
        { status: 404 }
      else
        { status: res[:code], movie: parse_movie(res[:data]) }
      end
    end

    # fetches a movie by IMDB id
    # set tomatoes to true if you want to get the rotten tomatoes ranking
    # set plot to full if you want to have the full, long plot
    def find(id, tomatoes = false, plot = "short")
      res = network.call({ i: id, tomatoes: tomatoes, plot: plot, apikey: @@config[:api_key] })

      if res[:data]["Response"] == "False"
        { status: 404 }
      else
        { status: res[:code], movie: parse_movie(res[:data]) }
      end
    end

    private
    def parse_movies(json_string)
      data = json_string["Search"]
      movies = Array.new
      data.each do |movie|
        movies.push(parse_movie(movie))
      end
      movies
    end

    def parse_movie(data)
      Movie.new(data)
    end

    def network
      @network ||= Omdb::Network.new
    end
  end
end
