config = require '../buildconfig.coffee'
gulp   = require 'gulp'

gulp.task 'build_lib', ->
  for data in config.lib
    {
      files
      distDir
    } = data
    gulp.src files
      .pipe gulp.dest(distDir)

gulp.task 'build_lib:watch', ->
  {
    files
  } = config.lib
  gulp.watch files, ['build_lib']
