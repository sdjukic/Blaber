# Blaber
Playing with sinatra and D3

## Scripts used
I used word d3-cloud project by Jason Davies

https://github.com/jasondavies/d3-cloud

## What have I learned
In order to use JS libraries and frameworks like angular, D3, etc. some of your routes have to return JSON which will be used by JS framework in another route (that happens via AJAX) - take a look at views/home.slim for such an example.

## Sinatra quirks
Modules that are in separate files should be in lib/sinatra directory and be in module Sinatra. see helpers.rb

## To run the application 
`bundle exec rackup -p 3000`

This will run on port 3000 on the local machine.

## Heroku hosted address
The app url is: http://pacific-beach-1447.herokuapp.com
