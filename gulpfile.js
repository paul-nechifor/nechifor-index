const CvInfo = require('cv-info');
const async = require('async');
const fs = require('fs');
const gulp = require('gulp');
const htmlmin = require('gulp-htmlmin');
const mkdirp = require('mkdirp');
const path = require('path');
const pug = require('gulp-pug');
const webserver = require('gulp-webserver');
const {execSync} = require('child_process');

const projectsDir = path.join(__dirname, 'projects');
const screenshotDir = path.join(__dirname, 'dist', 'screenshots');
const info = new CvInfo.Info();
const screenshots = {};

gulp.task('default', ['html', 'webserver', 'watch']);

gulp.task('build', ['html']);

gulp.task('projects', done => {
  loadInfo(err => {
    if (err) {
      return done(err);
    }

    copyScreenshots(err => {
      if (err) {
        return done(err);
      }

      for (const p of info.projects.list) {
        break; ///////////////////////////////////////////////////////////////////////////////////////////////////////
        const {github} = p.links.map;
        if (github) {
          getOrUpdate(github.url);
        }
      }
      done();
    });
  });
});

gulp.task('html', ['projects'], () => {
  return gulp.src('index.pug')
    .pipe(pug({locals: {info, screenshots}}))
    .pipe(htmlmin({ collapseWhitespace: true }))
    .pipe(gulp.dest('dist'));
});

gulp.task('webserver', () => {
  const port = parseInt(process.env.port || '8080', 10);
  return gulp.src('dist')
    .pipe(webserver({ livereload: true, open: true, port, host: '0.0.0.0' }));
});

gulp.task('watch', () => {
  return gulp.watch(['index.pug'], ['html']);
});

function getOrUpdate(url) {
  const parts = url.split('/');
  const name = parts[parts.length - 1];
  const dir = path.join(projectsDir, name);

  if (fs.existsSync(dir)) {
    execSync(`cd '${dir}'; git pull`);
  } else {
    execSync(`git clone '${url}' '${dir}'`);
  }
}

function loadInfo(cb) {
  mkdirp.sync(projectsDir, {mode: 0755});
  getOrUpdate('https://github.com/paul-nechifor/nechifor-info');
  const infoFile = path.join(projectsDir, 'nechifor-info', 'info.yaml');
  info.loadFromFile(infoFile, cb);
}

function copyScreenshots(cb) {
  mkdirp.sync(screenshotDir, {mode: 0755});
  async.map(info.projects.list, copyScreenshot, cb);
}

function copyScreenshot(project, cb) {
  const id = project.code;
  const find = findScreenshot(id);
  screenshots[id] = {};
  if (!find) {
    return cb();
  }
  const [srcPath, format] = Array.from(find);
  screenshots[id] = {default: `${id}.${format}`};
  const dstPath = path.join(screenshotDir,`${id}.${format}`);

  fs.createReadStream(srcPath)
  .pipe(fs.createWriteStream(dstPath))
  .on('close', cb);
};

function findScreenshot(id) {
  const formats = ['png', 'jpg'];
  const places = ['screenshot'];

  for (const format of Array.from(formats)) {
    const paths = places.map(
      place => `${projectsDir}/${id}/${place}.${format}`
    );
    paths.push(path.join(__dirname, 'default-screenshot.png'));
    for (const path of paths) {
      if (fs.existsSync(path)) {
        return [path, format];
      }
    }
  }
};
