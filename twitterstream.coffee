request = require("request")
events = require('events')
util = require('util')

# constructor
TwitterStream = () ->
  @url = "http://search.twitter.com/search.json?q=diuscomputing"
  @stream()
  events.EventEmitter.call(@)
  @

# inherit TwitterStream from EventEmitter - allows TwitterStream to send events
util.inherits(TwitterStream, events.EventEmitter) 

TwitterStream::stream = ->
  
  # poll twitter every 10 seconds
  setInterval (=>

    request @url, (error, response, body) =>
      jsonResponse = JSON.parse(response.body)
      
      @url = @url.substring(0, @url.indexOf('?')) + jsonResponse.refresh_url

      results = for result in jsonResponse.results
        {
          source: 'twitter'
          name: result.from_user_name
          image: result.profile_image_url
          text: result.text
          url: "https://twitter.com/#!/#{result.from_user}/status/#{result.id_str}"
          vendorImage: 'https://si0.twimg.com/a/1331785271/images/logos/twitter_newbird_blue.png'
        }

      # create a new event we the new set of items as the payload
      @.emit('newStreamItems', results) unless results.empty
  ), 10000

module.exports = TwitterStream
