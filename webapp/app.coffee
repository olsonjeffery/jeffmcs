# libs
express = require 'express'
_ = require 'underscore'

# templates
renderMain = _.template require('./views/main')

# setup/config
app = module.exports = express.createServer()

app.configure () ->
  app.use(express.bodyDecoder())
  app.use(express.methodOverride())
  app.use(app.router)
  app.use(express.staticProvider(__dirname + '/public'))

app.configure 'development', ->
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true })); 
app.configure 'production', ->
  app.use(express.errorHandler()); 

# handlers
app.get '/', (req, res) ->
  res.send renderMain()

# server startup
if !module.parent
  app.listen(80);
  console.log("jeffnet webapp server listening on port %d", app.address().port)
