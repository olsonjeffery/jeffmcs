express = require('express')
_ = require 'underscore'

app = module.exports = express.createServer()

app.configure () ->
  app.set('views', __dirname + '/views')
  app.set('view engine', 'jade')
  app.use(express.bodyDecoder())
  app.use(express.methodOverride())
  app.use(app.router)
  app.use(express.staticProvider(__dirname + '/public'))

app.configure 'development', ->
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true })); 

app.configure 'production', ->
  app.use(express.errorHandler()); 

mainTemplate = '''
  <html>
    <head>
      <title>jeff's minecraft server</title>
      <style type="text/css">
        #main {
          width:500px;
          margin:0px auto;
        }
        main a {
          border:none 0px #fff;
        }
      </style>
    </head>
    <body>
      <div id="main">
        <a href="/worldpics/world.png"><img src="/worldpics/world_preview.png" /></a>
        <a href="/worldpics/world_night.png"><img src="/worldpics/world_night_preview.png" /></a>
      </div>
    </body>
  </html>
  '''
app.get '/', (req, res) ->
  res.send _.template(mainTemplate)()

if !module.parent
  app.listen(80);
  console.log("Express server listening on port %d", app.address().port)
