$: << File.expand_path('../../', __FILE__)

require 'Blabber'
require 'rack/test'

def app
	Blabber.new
end

RSpec.configure do |config|
	config.include Rack::Test::Methods
end