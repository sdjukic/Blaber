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
    UPDATE_INTERVAL = 3600           # this is update time in seconds aka one hour
    QUERY_TEXT = "http://api.nytimes.com/svc/search/v2/articlesearch.json?"
    @@latest_query = Time.new(0)
    @@today_hash = ""
    @@weekly_array = []
    @@weekly_hash = {}
    @@number_of_daily_queries = 0
  end

  
  get '/' do
  	slim :root
  end

	
  get '/daily-data' do
    today = Time.now
    if today.strftime("%Y%m%d") != @@latest_query.strftime("%Y%m%d")  # this is new day put @@latest_query in history array
      @@weekly_array << @@today_hash
      #update_weekly_array(@@weekly_array, weekly_hash) if @@weekly_array.size > 7
        
      @@number_of_daily_queries = 1
      @@latest_query = Time.now
      @@today_hash = daily_api_call((@@latest_query - 1).strftime("%Y%m%d"),
      @@latest_query.strftime("%Y%m%d"))
    else
      if today +  UPDATE_INTERVAL < @@latest_query     # in this case it is the same day just update hour from now
        puts "Update on the hour"
        @@number_of_daily_queries += 1  
        @@latest_query = DateTime.now
		    @@today_hash = daily_api_call((@@latest_query - 1).strftime("%Y%m%d"),
        @@latest_query.strftime("%Y%m%d"))
      end                                
    end

		@@today_hash.to_json
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