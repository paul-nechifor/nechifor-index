const async = require('async');
const fs = require('fs');
const gulp = require('gulp');
const htmlmin = require('gulp-htmlmin');
const mkdirp = require('mkdirp');
const path = require('path');
const pug = require('gulp-pug');
const webserver = require('gulp-webserver');
const yaml = require('js-yaml');
const {execSync} = require('child_process');

const projectsDir = path.join(__dirname, 'projects');
const screenshotDir = path.join(__dirname, 'dist', 'screenshots');
const screenshots = {};
let info = null;

gulp.task('default', ['html', 'webserver', 'watch']);

gulp.task('build', ['html']);

gulp.task('projects', done => {
  info = loadInfo();
  copyScreenshots(err => {
    if (err) {
      return done(err);
    }

    for (const p of info) {
      if (p.gitUrl) {
        getOrUpdate(p.gitUrl);
      }
    }
    done();
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

  console.log('Getting ‘%s’.', name);

  if (fs.existsSync(dir)) {
    execSync(`cd '${dir}'; git pull`);
  } else {
    execSync(`git clone '${url}' '${dir}'`);
  }
}

function loadInfo(cb) {
  mkdirp.sync(projectsDir, {mode: 0755});
  const infoFile = path.join(__dirname, 'info.yaml');
  const yamlData = fs.readFileSync(infoFile, 'utf8');
  return yaml.safeLoad(yamlData);
}

function copyScreenshots(cb) {
  mkdirp.sync(screenshotDir, {mode: 0755});
  async.map(info, copyScreenshot, cb);
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
