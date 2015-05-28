config = require '../buildconfig.coffee'
gulp   = require 'gulp'

gulp.task 'build_express', ->
  {
    files
    distDir
  } = config.express
  return gulp.src files
    .pipe gulp.dest(distDir)

gulp.task 'build_express:watch', ->
  {
    files
  } = config.express
  gulp.watch files, ['build_express']
