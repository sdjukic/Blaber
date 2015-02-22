
require 'sinatra/base'
require 'slim'
require 'yaml'
require 'httparty'
require 'json'

class Blabber < Sinatra::Base


    get '/' do
    	slim :home
    end

	get '/data' do
		@text = make_api_call
		@text.to_json
	end

	def make_api_call()
      query = "http://api.nytimes.com/svc/search/v2/articlesearch.json?begin_date=20150219&end_date=20150220&api-key="+API_KEY
      res = HTTParty.get(query)
      parsed = JSON.parse(res.body)

      filtered_text = []

      parsed['response']['docs'].each do |d|
      	d["snippet"].split(' ').each do |word|
          filtered_text.push(word.chomp(",")) unless STOP_WORDS.has_key?(word.downcase) or word.match(/\d+/)
        end
        d["headline"]["print_headline"].split().each do |word|
          filtered_text.push(word.chomp(",")) unless STOP_WORDS.has_key?(word.downcase) or word.match(/\d+/)
        end

      end 

      filtered_text
    end

  configure do
  	data = YAML.load_file('.secret_config.yaml')
  	API_KEY = data['NYT_ARTICLE_KEY']
  	STOP_WORDS = {}
    
    file = File.open('stopwords', 'r')
    file.each_line do |line|
    	STOP_WORDS[line.chomp] = 1
    end
  end

end