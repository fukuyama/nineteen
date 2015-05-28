config     = require '../buildconfig.coffee'
gulp       = require 'gulp'
coffeelint = require 'gulp-coffeelint'

gulp.task 'coffeelint', ->
  {
    files
  } = config.coffeelint
  return gulp.src files
    .pipe coffeelint()
    .pipe coffeelint.reporter('coffeelint-stylish')
    .pipe coffeelint.reporter('fail')
