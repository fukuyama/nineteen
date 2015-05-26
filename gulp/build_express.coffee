config = require '../buildprop.coffee'
gulp   = require 'gulp'

gulp.task 'build_express', ->
  {
    srcFiles
    distDir
  } = config.express
  return gulp.src srcFiles
    .pipe gulp.dest(distDir)

gulp.task 'build_express:watch', ->
  {
    srcFiles
  } = config.express
  gulp.watch srcFiles, ['build_express']
