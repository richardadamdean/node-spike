conf = require('./config')
request = require("request")
events = require('events')
util = require('util')
_und = require("underscore")

YammerStream = () ->
  @url = "https://www.yammer.com/api/v1/messages.json?access_token=#{conf.yammer_access}"
  @stream()
  events.EventEmitter.call(@)
  @

util.inherits(YammerStream, events.EventEmitter) # inherit YammerStream from EventEmitter

YammerStream::stream = ->
  setInterval (=> 
    request @url, (error, response, body) =>
      
      jsonResponse =  JSON.parse(response.body)

      if error or !jsonResponse.messages
        console.error "Error fetching yammer stream. Did you set the yammer access token in the config?"
      else

        if(jsonResponse.messages.length > 0)
          @url = @url.substring(0, @url.indexOf('&newer_than')) if @url.indexOf('&newer_than') > 0
          @url = @url + '&newer_than=' + jsonResponse.messages[0].id 
        
        results = for result in jsonResponse.messages
          user = @user(result, jsonResponse)
          { 
            source: 'yammer'
            name: user.full_name
            image: user.mugshot_url
            text: result.body.parsed
            url: result.web_url
            vendorImage: 'http://online.deloitte.com.au/media/images/YammerLogoBubbleResized.png'
          }        

        @.emit('newStreamItems', results) unless results.empty
  ), 10000

YammerStream::user = (message, json) ->
  _und.find json.references, (item) -> 
    item.id is parseInt(message.sender_id)
  
module.exports = YammerStream