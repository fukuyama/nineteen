config = require '../buildconfig.coffee'
gulp   = require 'gulp'
rimraf = require 'rimraf'

gulp.task 'clean', (cb) -> rimraf config.cleanDir, cb
