gulp = require 'gulp'
gulp = require "gulp"
util = require "gulp-util"
sass = require "gulp-sass"
jade = require "gulp-jade"
coffee = require "gulp-coffee"
concat = require "gulp-concat"
data = require "gulp-data"
changed = require "gulp-changed"
minifycss = require 'gulp-minify-css'
rename = require 'gulp-rename'
livereload = require 'gulp-livereload'

log = util.log


gulp.task "sass", ->
    log "Generate CSS files " + (new Date()).toString()
    gulp.src 'public/sass/*.sass'
    .pipe sass style: 'expanded'
    .pipe rename suffix: '.min'
    .pipe concat 'styles.min.css'
    .pipe minifycss()
    .pipe gulp.dest 'public/build/css/'
    .pipe livereload()

gulp.task "jade", ->
    log "Generate HTML files " + (new Date()).toString()
    gulp.src 'public/jade/**/*.jade'
    .pipe jade()
    .pipe gulp.dest 'public/build/'
    .pipe changed '.'
    .pipe livereload()

gulp.task "coffee", ->
    log "Generate JS files " + (new Date()).toString()
    gulp.src [
        'public/coffee/app.coffee'
        'public/coffee/routes.coffee'
        'public/coffee/controllers/**/*.coffee'
        'public/coffee/services/**/*.coffee'
        'public/coffee/directives/**/*.coffee'
        'public/coffee/filters/**/*.coffee']
    .pipe coffee()
    .pipe concat 'app.js'
    .pipe gulp.dest 'public/build/js/'
    .pipe livereload()

gulp.task "watch", ->
    livereload.listen()
    gulp.watch 'public/sass/**/*.sass', ["sass"]
    gulp.watch 'public/jade/**/*.jade', ["jade"]
    gulp.watch [
        'public/coffee/app.coffee'
        'public/coffee/routes.coffee'
        'public/coffee/controllers/**/*.coffee'
        'public/coffee/services/**/*.coffee'
        'public/coffee/directives/**/*.coffee'
        'public/coffee/filters/**/*.coffee'], ["coffee"]
