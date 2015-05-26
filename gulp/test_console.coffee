config = require '../buildprop.coffee'
gulp   = require 'gulp'
mocha  = require 'gulp-mocha'

gulp.task 'test_console', ->
  {
    testFiles
  } = config.test
  return gulp.src testFiles, read: false
    .pipe mocha
      reporter: 'nyan'

gulp.task 'test_console:watch', ->
  {
    testFiles
  } = config.test
  gulp.watch testFiles, ['test_console']
