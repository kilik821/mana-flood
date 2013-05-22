#### Routes
# We are setting up theese routes:
#
# GET, POST, PUT, DELETE methods are going to the same controller methods - we dont care.
# We are using method names to determine controller actions for clearness.

module.exports = (app) ->
  app.get /\/partials\/(.+)/, (req, res, next) ->
    res.render 'partials/' + req.params[0]

  app.get '/api/:controller', (req, res, next) ->
    routeMvc(req.params.controller, 'index', req, res, next)

  app.post '/api/:controller', (req, res, next) ->
    routeMvc(req.params.controller, 'create', req, res, next)

  app.get '/api/:controller/all', (req, res, next) ->
    routeMvc(req.params.controller, 'index', req, res, next)

  app.all '/api/:controller/all/:method', (req, res, next) ->
    routeMvc(req.params.controller, req.params.method, req, res, next)

  app.get '/api/:controller/:id', (req, res, next) ->
    routeMvc(req.params.controller, 'get', req, res, next)

  app.put '/api/:controller/:id', (req, res, next) ->
    routeMvc(req.params.controller, 'update', req, res, next)

  app.post '/api/:controller/:id', (req, res, next) ->
    routeMvc(req.params.controller, 'update', req, res, next)

  app.delete '/api/:controller/:id', (req, res, next) ->
    routeMvc(req.params.controller, 'delete', req, res, next)

  app.all '/api/:controller/:id/:method', (req, res, next) ->
    routeMvc(req.params.controller, req.params.method, req, res, next)

  app.all '/api/*', (req, res, next) ->
    res.send 404, 'Route not found'

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
    res.send 404, controllerName + ' not found'
  if typeof controller[methodName] is 'function'
    actionMethod = controller[methodName].bind controller
    actionMethod req, res, next
  else
    console.warn 'method not found: ' + methodName
    res.send 404, "Method '#{methodName}' on resource '#{controllerName}' not found"
