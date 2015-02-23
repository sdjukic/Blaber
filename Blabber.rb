
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

    MAX_NO_PAGES = 10
    QUERY_TEXT = "http://api.nytimes.com/svc/search/v2/articlesearch.json?"
    DATE = "&begin_date=20150219&end_date=20150220"
    LATEST_QUERY = Time.new(0)
    YESTERDAY = 86400      # number of the seconds in the day
    @@cached_results = ""
  end

  
  get '/' do
  	slim :home
  end

	
  get '/data' do
    if Time.now - LATEST_QUERY > YESTERDAY
      LATEST_QUERY = Time.now
		  @@cached_results = make_api_call
    end

		@@cached_results.to_json
	end

	
  get '/blab-data' do
    BLA = {'Bla' => 20, 'BlaBla' => 6, '404' => 10, 'Chatter' => 5, 'endless' =>11 }
    BLA.to_json
  end


  not_found do
    slim :four_o_four
  end


  def make_api_call()
      
      word_frequencies = Hash.new(0)
      counter = 0
      # for normalizing words size in the cloud
      min_frequency = 1           # can I get away with this assumption
      max_frequency = 0
      
      
      (0..MAX_NO_PAGES).each do |p|
        query = QUERY_TEXT + DATE + "&page=#{p}"+ "&api-key=" + API_KEY
        res = HTTParty.get(query)
        parsed = JSON.parse(res.body)
        

        if parsed['status'] == 'OK'
          parsed['response']['docs'].each do |d|
            puts d
      	    d["snippet"].split(' ').each do |word|
              word_frequencies[word.chomp(",")] += 1 unless STOP_WORDS.has_key?(word.downcase) or word.match(/\d+/)
              counter += 1
            end

            # if word in headline it has higher weight
            if d["headline"]["print_headline"]
              d["headline"]["print_headline"].split().each do |word|
                word_frequencies[word.chomp(",")] += 2 unless STOP_WORDS.has_key?(word.downcase) or word.match(/\d+/)
                max_frequency = word_frequencies[word.chomp(",")] if word_frequencies[word.chomp(",")] > max_frequency
                counter += 1                                  
              end
            end

          end 
        end  
      end
      #word_frequencies["total_number_of_words"] = counter
      puts "Max frequency: #{max_frequency}"
      word_frequencies
  end

end