
module Sinatra

  MAX_WORD_SIZE = 80

  module Helpers


    def update
      today = Time.now
        if today.strftime("%Y%m%d") != Blabber.latest_query.strftime("%Y%m%d")  # this is new day put @@latest_query in history array
          Blabber.weekly_array << Blabber.today_hash
          #update_weekly_array(@@weekly_array, weekly_hash) if @@weekly_array.size > 7
        
          Blabber.number_of_daily_queries = 1
          Blabber.latest_query = Time.now
          daily_api_call(today.strftime("%Y%M%d"), (today - 86400).strftime("%Y%M%d"))
          #@@today_hash = daily_api_call((@@latest_query - 1).strftime("%Y%m%d"),
          #@@latest_query.strftime("%Y%m%d"))
        else
          if today +  Blabber::UPDATE_INTERVAL < Blabber.latest_query     # in this case it is the same day just update hour from now
            puts "Update on the hour"
            Blabber.number_of_daily_queries += 1  
            Blabber.latest_query = DateTime.now
            #@@today_hash = daily_api_call((@@latest_query - 1).strftime("%Y%m%d"),
            #@@latest_query.strftime("%Y%m%d"))
          end                                
        end

    end


	  def daily_api_call(date_first, date_second)
      
        return_status =  {'status' => ""}     # function will return status

        word_frequencies = Hash.new(0)
       
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
                max_frequency = word_frequencies[word.chomp(",")] if word_frequencies[word.chomp(",")] > max_frequency
              end

              # if word in headline it has higher weight
              if d["headline"]["print_headline"]
                d["headline"]["print_headline"].split().each do |word|
                  word_frequencies[word.chomp(",")] += 2 unless Blabber::STOP_WORDS.has_key?(word.downcase) or word.match(/\d+/)
                  max_frequency = word_frequencies[word.chomp(",")] if word_frequencies[word.chomp(",")] > max_frequency                               
                end
              end

            end 
          end 

          if parsed['status'] == 'OK' and word_frequencies.size > 0 
            return_status['status'] = 'OK'
          else
            return_status['status'] = 'Update failed'
          end
        end

        word_frequencies.delete_if { |key, value| value < 2 }

        word_frequencies["word_scale"] = MAX_WORD_SIZE / max_frequency
        puts word_frequencies.length
        Blabber.today_hash = word_frequencies   # maybe eliminate this word_frequencies hash and manipualte Blabber.today_hash 

        return_status
    end
  end

  def update_weekly_array(weekly_array, weekly_hash)

  end
end