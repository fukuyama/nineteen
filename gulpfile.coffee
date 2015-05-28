config = require './buildconfig.coffee'
gulp   = require 'gulp'

require('require-dir') './gulp'

gulp.task 'default', [
  'test'
  'build'
]

gulp.task 'dev', [
  'watch'
  'server'
]

gulp.task 'test', [
  'coffeelint'
  'test_console'
]

gulp.task 'build', [
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
