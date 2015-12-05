config     = require '../buildconfig.coffee'
gulp       = require 'gulp'
server     = require 'gulp-develop-server'
livereload = require 'gulp-livereload'

gulp.task 'server:start', ->
  {rootDir} = config.server
  server.listen {path: rootDir + 'bin/www'}, livereload.listen

gulp.task 'server:watch', ['build_express','server:start'], ->
  restart = (file) ->
    server.changed (err) ->
      livereload.changed file.path unless err?

  {rootDir} = config.server
  gulp.watch [
    rootDir + '**/*.png'
    rootDir + '**/*.json'
    rootDir + '**/*.css'
    rootDir + '**/*.jade'
    rootDir + '**/*.html'
    rootDir + '**/*.js'
    rootDir + 'bin/www'
  ], server.restart
    .on 'change', restart
