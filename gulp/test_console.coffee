config = require '../buildconfig.coffee'
gulp   = require 'gulp'
mocha  = require 'gulp-mocha'

gulp.task 'test_console', ->
  {
    files
  } = config.test.console
  return gulp.src files, read: false
    .pipe mocha
      reporter: 'nyan'

gulp.task 'test_console:watch', ->
  {
    files
    watch
  } = config.test.console
  gulp.watch files, ['test_console']
  gulp.watch watch.files, ['test_console'] if watch?
