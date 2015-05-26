config = require '../buildprop.coffee'
gulp   = require 'gulp'
rimraf = require 'rimraf'

gulp.task 'clean', (cb) -> rimraf config.cleanDir, cb
