
require 'sinatra/base'
require 'slim'
require 'yaml'
require 'httparty'
require 'json'

class Blabber < Sinatra::Base

  configure do
    data = YAML.load_file('.secret_config.yaml')
    API_KEY = data['NYT_ARTICLE_KEY']
    STOP_WORDS = {}
    
    file = File.open('stopwords', 'r')
    file.each_line do |line|
      STOP_WORDS[line.chomp] = 1
    end

  end

  
  get '/' do
  	slim :home
  end

	
  get '/data' do
		@text = make_api_call
		@text.to_json
	end

	
  get '/blab-data' do
    BLA = {'Bla' => 20, 'BlaBla' => 6, '404' => 10, 'Chatter' => 5, 'endless' =>11 }
    BLA.to_json
  end


  not_found do
    slim :four_o_four
  end


  def make_api_call()
      query = "http://api.nytimes.com/svc/search/v2/articlesearch.json?begin_date=20150219&end_date=20150220&api-key="+API_KEY
      res = HTTParty.get(query)
      parsed = JSON.parse(res.body)

      word_frequencies = Hash.new(0)
      counter = 0

      parsed['response']['docs'].each do |d|
      	d["snippet"].split(' ').each do |word|
          word_frequencies[word.chomp(",")] += 1 unless STOP_WORDS.has_key?(word.downcase) or word.match(/\d+/)
          counter += 1
        end

        d["headline"]["print_headline"].split().each do |word|
          word_frequencies[word.chomp(",")] += 1 unless STOP_WORDS.has_key?(word.downcase) or word.match(/\d+/)
          counter += 1
        end

      end 
      
      #word_frequencies["total_number_of_words"] = counter
      word_frequencies
  end

end