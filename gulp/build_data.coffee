config = require '../buildconfig.coffee'
gulp   = require 'gulp'
fs     = require 'fs'

gulp.task 'build_data', ['build_express'], (cb) ->
  {
    dataNames
    srcDir
    distDir
  } = config.data
  max   = dataNames.length
  count = 0
  onEnd = (err) ->
    if err?
      cb(err)
      return
    count++
    if count >= max
      cb()
  fs.mkdir distDir, (err) ->
    if err? and err.code isnt 'EEXIST'
      cb(err)
      return
    for name in dataNames
      obj = require '../' + srcDir + name + '.coffee'
      out = distDir + name + '.json'
      fs.writeFile out, JSON.stringify(obj), onEnd

gulp.task 'build_data:watch', ->
  {
    dataNames
    srcDir
  } = config.data
  watchFiles = (srcDir + name + '.coffee' for name in dataNames)
  gulp.watch watchFiles, ['build_data']
