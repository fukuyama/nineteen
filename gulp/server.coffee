config = require '../buildprop.coffee'
gulp   = require 'gulp'
server = require 'gulp-server-livereload'

gulp.task 'server', ['build_express'], ->
  {
    root
  } = config.server
  gulp.src root
    .pipe server
      livereload:       true
      directoryListing: false
      open:             false
