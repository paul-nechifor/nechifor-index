gulp = require 'gulp'
jade = require 'gulp-jade'
CvInfo = require 'cv-info'
app = require './manifest'

# Not public yet.
INFO_FILE = '/home/p/pro/nechifor-info/info.yaml'

info = new CvInfo.Info

gulp.task 'load-info', (cb) ->
  info.loadFromFile INFO_FILE, cb

gulp.task 'templates', ['load-info'], ->
  locals =
    info: info
    app: app
  gulp.src './templates/index.jade'
  .pipe jade locals: locals
  .pipe gulp.dest './html'

gulp.task 'default', ['templates']
