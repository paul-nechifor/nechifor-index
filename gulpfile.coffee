CvInfo = require 'cv-info'
async = require 'async'
fs = require 'fs'
gulp = require 'gulp'
jade = require 'gulp-jade'
gitRequire = require 'git-require'
{exec} = require 'child_process'

process.env.GIT_REQUIRE_DIR or= __dirname + '/projects'

info = new CvInfo.Info
screenshots = {}

loadInfo = (cb) ->
  repos = 'nechifor-info': 'git@github.com:paul-nechifor/nechifor-info'
  config = dir: null, repos: repos
  gitRequire.install __dirname, config, (err, repos) ->
    return cb err if err
    infoFile = repos['nechifor-info'].dir + '/info.yaml'
    info.loadFromFile infoFile, cb

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
        "#{process.env.GIT_REQUIRE_DIR}/#{id}/#{place}.#{format}"
    paths.push "static/other-screenshots/#{id}.#{format}"
    for path in paths
      if fs.existsSync path
        return [path, format]

  ['static/other-screenshots/default-screenshot.png', 'png']

gulp.task 'projects', (cb) ->
  loadInfo (err) ->
    return cb err if err
    repos = {}
    for p in info.projects.list
      git = p.links.map.github
      continue unless git
      name = git.url.split '/'
      name = name[name.length - 1]
      repos[name] = git.url
    config = dir: null, repos: repos
    gitRequire.install __dirname, config, cb

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
