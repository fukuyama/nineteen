
express = require('express')
router = express.Router()

router.get '/:id', (req, res, next) ->
  res.send(req)

module.exports = router
