const bodyParser = require('body-parser')

module.exports = function customMiddleware(app, express) {
  app.use(bodyParser.json({ limit: '10mb' }))
  app.use(bodyParser.urlencoded({ limit: '10mb', extended: true }))
} 