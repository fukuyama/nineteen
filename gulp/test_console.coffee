config = require '../buildconfig.coffee'
gulp   = require 'gulp'
mocha  = require 'gulp-mocha'

gulp.task 'test_console', ->
  {
    files
  } = config.test
  return gulp.src files, read: false
    .pipe mocha
      reporter: 'nyan'

gulp.task 'test_console:watch', ->
  {
    files
  } = config.test
  gulp.watch files, ['test_console']
