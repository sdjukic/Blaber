
module Sinatra

  MAX_WORD_SIZE = 80

  module Helpers

	  def daily_api_call(date_first, date_second)
      
        word_frequencies = Hash.new(0)
        counter = 0
        # for normalizing words size in the cloud
        min_frequency = 1           # can I get away with this assumption
        max_frequency = 0
      
      
        date = "&begin_date=#{date_first}&end_date=#{date_second}"
      
        (0..Blabber::MAX_NO_PAGES).each do |p|
          query = Blabber::QUERY_TEXT + date + "&page=#{p}"+ "&api-key=" + Blabber::API_KEY
        
          res = HTTParty.get(query)
          parsed = JSON.parse(res.body)
        

          if parsed['status'] == 'OK'
            parsed['response']['docs'].each do |d|
      	      d["snippet"].split(' ').each do |word|
                word_frequencies[word.chomp(",")] += 1 unless Blabber::STOP_WORDS.has_key?(word.downcase) or word.match(/\d+/)
                counter += 1
              end

              # if word in headline it has higher weight
              if d["headline"]["print_headline"]
                d["headline"]["print_headline"].split().each do |word|
                  word_frequencies[word.chomp(",")] += 2 unless Blabber::STOP_WORDS.has_key?(word.downcase) or word.match(/\d+/)
                  max_frequency = word_frequencies[word.chomp(",")] if word_frequencies[word.chomp(",")] > max_frequency
                  counter += 1                                  
                end
              end

            end 
          end  
        end
        word_frequencies.delete_if { |key, value| value < 2 }
        word_frequencies["word_scale"] = MAX_WORD_SIZE / max_frequency
        puts word_frequencies.length
        word_frequencies
    end
  end

end