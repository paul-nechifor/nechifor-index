gulp = require 'gulp'
jade = require 'gulp-jade'

gulp.task 'templates', ->
  locals =
    varName: 'value'
  gulp.src './templates/index.jade'
  .pipe jade locals: locals
  .pipe gulp.dest './html'

gulp.task 'default', ['templates']
