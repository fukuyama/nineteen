config = require '../buildconfig.coffee'
gulp   = require 'gulp'
coffee = require 'gulp-coffee'

gulp.task 'build_express:coffee', ->
  {
    files
    distDir
  } = config.express
  gulp.src files + '/*.coffee'
    .pipe coffee()
    .pipe gulp.dest(distDir)

gulp.task 'build_express:resource', ->
  {
    files
    distDir
  } = config.express
  gulp.src files + '/!(*.coffee)'
    .pipe gulp.dest(distDir)

gulp.task 'build_express', ['build_express:coffee','build_express:resource']

gulp.task 'build_express:watch', ->
  {
    files
  } = config.express
  gulp.watch files, ['build_express']
