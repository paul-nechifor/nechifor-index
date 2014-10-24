CvInfo = require 'cv-info'
async = require 'async'
fs = require 'fs'
gulp = require 'gulp'
jade = require 'gulp-jade'
{exec} = require 'child_process'

info = new CvInfo.Info
screenshots = {}

loadInfo = (cb) ->
  info.loadFromFile 'info/info.yaml', cb

copyScreenshots = (cb) ->
  try fs.mkdirSync 'static/screenshots'
  async.map info.projects.list, copyScreenshot , cb

copyScreenshot = (project, cb) ->
  id = project.code
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
        "projects/#{id}/#{place}.#{format}"
    paths.push "static/other-screenshots/#{id}.#{format}"
    for path in paths
      if fs.existsSync path
        return [path, format]

  ['static/other-screenshots/default-screenshot.png', 'png']

getProject = (p, cb) ->
  console.log 'Getting', p.url
  exec """
    mkdir -p projects
    if [ -d projects/#{p.name} ]; then
      cd projects/#{p.name}
      git pull
    else
      git clone '#{p.url}' projects/#{p.name}
    fi
  """, cb

gulp.task 'projects', (cb) ->
  loadInfo (err) ->
    return cb err if err
    projects =
      for p in info.projects.list
        g = p.links.map.github
        continue unless g
        name = g.url.split '/'
        name = name[name.length - 1]
        name: name, url: g.url
    projects.sort (a, b) -> if a.name >= b.name then 1 else -1
    async.mapSeries projects, getProject, cb

gulp.task 'load-info', (cb) ->
  loadInfo (err) ->
    return cb err if err
    copyScreenshots cb

gulp.task 'default', ['load-info'], ->
  locals =
    info: info
    app: do ->
      index = process.argv.indexOf '--app'
      throw 'no-app' unless index >= 0
      JSON.parse process.argv[index + 1]
    screenshots: screenshots
  gulp.src './templates/index.jade'
  .pipe jade locals: locals
  .pipe gulp.dest './html'
