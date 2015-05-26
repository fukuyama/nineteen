config     = require '../buildprop.coffee'
gulp       = require 'gulp'
coffee     = require 'gulp-coffee'
concat     = require 'gulp-concat'
uglify     = require 'gulp-uglify'
sourcemaps = require 'gulp-sourcemaps'

gulp.task 'build_main_script', ['coffeelint','test_console'], ->
  {
    coffeeFiles
    outputFile
    distDir
  } = config.main
  gulp.src coffeeFiles
    .pipe sourcemaps.init()
    .pipe coffee()
    .pipe concat(outputFile)
    .pipe uglify()
    .pipe sourcemaps.write('.', {addComment: true})
    .pipe gulp.dest(distDir)


gulp.task 'build_main_script:watch', ->
  {
    coffeeFiles
  } = config.main
  gulp.watch coffeeFiles, ['build_main_script']
