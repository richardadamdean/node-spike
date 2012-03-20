
# include our libraries
events = require('events')
express = require('express'); 
sockets = require('socket.io')

TwitterStream = require('./twitterstream')
YammerStream = require('./yammerstream')

# configure express mvc
app = express.createServer()
app.set 'view engine', 'jade' # set the express templating engine
app.set 'view options', {layout: false} # don't use a layout file for views
app.use(express.static(__dirname + '/public')) # serve static resources in /public

io = sockets.listen(app)

# router
app.get '/radiator', (req, res) ->
  res.render 'radiator', pageTitle: 'DiUS Radiator'

# set up the feeds
yammerStream = new YammerStream()
twitterStream = new TwitterStream()
  
# set up sockets.io to listen for connections
io.sockets.on 'connection', (socket) ->
  
  # on each new connection start listening for events from each stream
  for stream in [twitterStream, yammerStream]
    # listen for new items events from each stream
    stream.on 'newStreamItems', (streamItems) ->  
      # use websockets to push the new set of items out to the client  
      socket.emit 'stream', streamItems  

# server listens on 3000
app.listen 3000