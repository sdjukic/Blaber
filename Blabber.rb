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
    
    # from Sinatra up and running 
    Blabber.set :latest_query, Time.new(0)
    Blabber.set :today_hash, {}
    Blabber.set :daily_array, []
    Blabber.set :weekly_array, []
    Blabber.set :weekly_hash, {}
    Blabber.set :number_of_daily_queries, 0
  end


  get '/' do
  	slim :root
  end

	get '/update-data' do
    update.to_json
  end


  get '/daily-data' do
	  Blabber.today_hash.to_json
	end

	get '/hourly-data' do
    puts params['hour']
    Blabber.daily_array[params['hour'].to_i].to_json 
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