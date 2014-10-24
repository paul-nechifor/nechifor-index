CvInfo = require 'cv-info'
fs = require 'fs'
async = require 'async'
{exec} = require 'child_process'

info = new CvInfo.Info
info.loadFromFile 'info/info.yaml', (err) ->
  return cb err if err
  get = []
  for p in info.projects.list
    g = p.links.map.github
    continue unless g
    name = g.url.split '/'
    name = name[name.length - 1]
    get.push name: name, url: g.url
  async.mapSeries get, getProject, (err) ->
    throw err if err

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
