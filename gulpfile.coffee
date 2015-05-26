config = require './buildprop.coffee'
gulp   = require 'gulp'

require('require-dir') './gulp'

gulp.task 'default', [
  'build'
  'watch'
  'server'
]

gulp.task 'build', [
  'coffeelint'
  'test_console'
  'build_express'
  'build_main_script'
  'build_ai_script'
  'build_data'
]

gulp.task 'watch', [
  'test_console:watch'
  'build_express:watch'
  'build_main_script:watch'
  'build_ai_script:watch'
  'build_data:watch'
]
