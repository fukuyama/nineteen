config = require './buildconfig.coffee'
gulp   = require 'gulp'

require('require-dir') './gulp'

gulp.task 'default', [
  'test'
  'build'
]

gulp.task 'build', [
  'build_express'
  'build_main_script'
  'build_main_script:uglify'
  'build_ai_script'
  'build_data'
]

gulp.task 'test', [
  'coffeelint'
  'test_console'
]

gulp.task 'serve', [
  'server:start'
]

gulp.task 'debug', [
  'test_console:watch'
  'build_express:watch'
  'build_main_script:watch'
  'build_ai_script:watch'
  'build_data:watch'
  'server:watch'
]
