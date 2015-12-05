config     = require '../buildconfig.coffee'
gulp       = require 'gulp'
coffee     = require 'gulp-coffee'
concat     = require 'gulp-concat'
uglify     = require 'gulp-uglify'
sourcemaps = require 'gulp-sourcemaps'

gulp.task 'build_main_script', ['coffeelint'], ->
  {
    files
    outputFile
    distDir
  } = config.main
  gulp.src files
    .pipe sourcemaps.init()
    .pipe coffee()
    .pipe concat(outputFile + '.js')
    .pipe sourcemaps.write('.', {addComment: true})
    .pipe gulp.dest(distDir)

gulp.task 'build_main_script:uglify', ['coffeelint'], ->
  {
    files
    outputFile
    distDir
  } = config.main
  gulp.src files
    .pipe sourcemaps.init()
    .pipe coffee()
    .pipe concat(outputFile + '.min.js')
    .pipe uglify()
    .pipe sourcemaps.write('.', {addComment: true})
    .pipe gulp.dest(distDir)

gulp.task 'build_main_script:watch', ->
  {
    files
  } = config.main
  gulp.watch files, ['build_main_script','build_main_script:uglify']
