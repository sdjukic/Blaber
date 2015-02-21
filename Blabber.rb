
require 'sinatra/base'

class Blabber < Sinatra::Base
	get '/' do
		'Yo, bro!'
	end
end