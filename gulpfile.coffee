
gulp   = require 'gulp'
coffee = require 'gulp-coffee'
concat = require 'gulp-concat'
uglify = require 'gulp-uglify'
copy   = require 'gulp-copy'
rename = require 'gulp-rename'
rimraf = require 'rimraf'

gulp.task 'compile', ->
  gulp.src 'src/main/public/nz/*.coffee'
    .pipe coffee()
    .pipe concat('main.min.js')
  	.pipe uglify()
    .pipe gulp.dest './target/public/'

gulp.task 'clean', (cb) ->
  rimraf './target', cb

gulp.task 'build', ['compile']
gulp.task 'default', ['build']
