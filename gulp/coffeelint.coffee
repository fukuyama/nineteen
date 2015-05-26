config     = require '../buildprop.coffee'
gulp       = require 'gulp'
coffeelint = require 'gulp-coffeelint'

gulp.task 'coffeelint', ->
  {
    lintFiles
  } = config.coffeelint
  return gulp.src lintFiles
    .pipe coffeelint()
    .pipe coffeelint.reporter('coffeelint-stylish')
    .pipe coffeelint.reporter('fail')
