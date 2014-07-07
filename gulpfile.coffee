gulp = require 'gulp'
jade = require 'gulp-jade'
CvInfo = require 'cv-info'
fs = require 'fs'

app = do ->
  index = process.argv.indexOf '--app'
  throw 'no-app' unless index >= 0
  json = process.argv[index + 1]
  JSON.parse json

# Not public yet.
INFO_FILE = '/home/p/pro/nechifor-info/info.yaml'
PROJECTS_ROOT = '/home/p/pro'

info = new CvInfo.Info
screenshots = {}

copyScreenshots = (cb) ->
  try
    fs.mkdirSync 'static/screenshots'
  catch
    # Ignore
  i = 0
  list = info.projects.list
  next = ->
    return cb() if i >= list.length
    copyScreenshot list[i].code, (err) ->
      return cb err if err
      i++
      next()
  next()

copyScreenshot = (id, cb) ->
  find = findScreenshot id
  screenshots[id] = {}
  return cb() unless find
  [srcPath, format] = find
  screenshots[id] =
    default: "#{id}.#{format}"
  dstPath = "static/screenshots/#{id}.#{format}"
  fs.createReadStream srcPath
  .pipe fs.createWriteStream dstPath
  .on 'close', cb

findScreenshot = (id) ->
  formats = ['png', 'jpg']
  places = ['screenshot', 'private/screenshot']

  for format in formats
    paths =
      for place in places
        "#{PROJECTS_ROOT}/#{id}/#{place}.#{format}"
    paths.push "static/other-screenshots/#{id}.#{format}"
    for path in paths
      if fs.existsSync path
        return [path, format]

  return ['static/other-screenshots/default-screenshot.png', 'png']

gulp.task 'load-info', (cb) ->
  info.loadFromFile INFO_FILE, (err) ->
    return cb err if err
    copyScreenshots cb

gulp.task 'templates', ['load-info'], ->
  locals =
    info: info
    app: app
    screenshots: screenshots
  gulp.src './templates/index.jade'
  .pipe jade locals: locals
  .pipe gulp.dest './html'

gulp.task 'default', ['templates']
