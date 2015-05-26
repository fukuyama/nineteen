config     = require '../buildprop.coffee'
gulp       = require 'gulp'
coffee     = require 'gulp-coffee'
concat     = require 'gulp-concat'
uglify     = require 'gulp-uglify'
sourcemaps = require 'gulp-sourcemaps'

gulp.task 'build_ai_script', ['coffeelint','test_console'], ->
  {
    coffeeFiles
    distDir
    srcOption
  } = config.ai
  gulp.src coffeeFiles, srcOption
    .pipe sourcemaps.init()
    .pipe coffee()
    .pipe uglify()
    .pipe sourcemaps.write('.', {addComment: true})
    .pipe gulp.dest(distDir)

gulp.task 'build_ai_script:watch', ->
  {
    coffeeFiles
  } = config.ai
  gulp.watch coffeeFiles, ['build_ai_script']
