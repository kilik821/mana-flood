#### Routes
# We are setting up theese routes:
#
# GET, POST, PUT, DELETE methods are going to the same controller methods - we dont care.
# We are using method names to determine controller actions for clearness.

module.exports = (app) ->
  app.get '/partials/:name', (req, res, next) ->
    res.render 'partials/' + req.params.name
    do next

  app.get '/api/:controller', (req, res, next) ->
    routeMvc(req.params.controller, 'index', req, res, next)

  app.post '/api/:controller', (req, res, next) ->
    routeMvc(req.params.controller, 'create', req, res, next)

  app.get '/api/:controller/:id', (req, res, next) ->
    routeMvc(req.params.controller, 'get', req, res, next)

  app.put '/api/:controller/:id', (req, res, next) ->
    routeMvc(req.params.controller, 'update', req, res, next)

  app.delete '/api/:controller/:id', (req, res, next) ->
    routeMvc(req.params.controller, 'delete', req, res, next)

  app.post '/api/:controller/:id/:method', (req, res, next) ->
    routeMvc(req.params.controller, req.params.method, req, res, next)

  app.all '/api/*', (req, res, next) ->
    res.status 404
    res.send 'Route not found'

#  #   - _/_ -> controllers/index/index method
#  app.all '/api', (req, res, next) ->
#    routeMvc('index', 'index', req, res, next)
#
#  #   - _/**:controller**_  -> controllers/***:controller***/index method
#  app.all '/api/:controller', (req, res, next) ->
#    routeMvc(req.params.controller, 'index', req, res, next)
#
#  #   - _/**:controller**/**:method**_ -> controllers/***:controller***/***:method*** method
#  app.all '/api/:controller/:method', (req, res, next) ->
#    routeMvc(req.params.controller, req.params.method, req, res, next)
#
#  #   - _/**:controller**/**:method**/**:id**_ -> controllers/***:controller***/***:method*** method with ***:id*** param passed
#  app.all '/api/:controller/:method/:id', (req, res, next) ->
#    routeMvc(req.params.controller, req.params.method, req, res, next)

  # If all else failed, show index page
  app.all '/*', (req, res) ->
    res.render 'index'

# render the page based on controller name, method and id
routeMvc = (controllerName, methodName, req, res, next) ->
  controllerName = 'index' if not controllerName?
  controller = null
  try
    controller = require "./controllers/" + controllerName
  catch e
    console.warn "controller not found: " + controllerName, e
    next()
    return
  data = null
  if typeof controller[methodName] is 'function'
    actionMethod = controller[methodName].bind controller
    actionMethod req, res, next
  else
    console.warn 'method not found: ' + methodName
    next()
