$:.unshift File.expand_path('../lib', __FILE__)

require 'sinatra/base'
require 'slim'
require 'yaml'
require 'httparty'
require 'json'
require 'date'
require "sinatra/helpers"


class Blabber < Sinatra::Base

  helpers Sinatra::Helpers


  configure do
    data = YAML.load_file('.secret_config.yaml')
    API_KEY = data['NYT_ARTICLE_KEY']
    
    STOP_WORDS = {}
    
    file = File.open('stopwords', 'r')
    file.each_line do |line|
      STOP_WORDS[line.chomp] = 1
    end
    
    MAX_NO_PAGES = 10
    QUERY_TEXT = "http://api.nytimes.com/svc/search/v2/articlesearch.json?"
    @@latest_query = DateTime.new(0)
    @@cached_results = ""
  end

  
  get '/' do
  	slim :root
  end

	
  get '/daily-data' do
    today = DateTime.now
    if today.strftime("%Y%m%d") != @@latest_query.strftime("%Y%m%d")  # this is new day put @@latest_query in history array
      
    #if today.strftime("%H") != @@latest_query.strftime("%H")     # in this case it is the same day just update at the hour  
      @@latest_query = DateTime.now
		  @@cached_results = daily_api_call((@@latest_query - 1).strftime("%Y%m%d"),
      @@latest_query.strftime("%Y%m%d"))
                                      
    end

		@@cached_results.to_json
	end

	
  get '/blab-data' do
    BLA = {'Bla' => 20, 'BlaBla' => 6, '404' => 10, 'Chatter' => 5, 'endless' =>11 }
    BLA.to_json
  end


  post '/form' do
    if params[:time] == 'daily'
      # Here render home page with appropriate time
      # And how to pass this parameter to script in that page?
      # today = Date.today
      slim :home
    end

  end


  not_found do
    slim :four_o_four
  end

end