express = require('express')
app = express()

app.get '/:id', (req, res, next) ->
  res.send(req.params)

module.exports = app
