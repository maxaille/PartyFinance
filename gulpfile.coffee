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
angularTranslate = require 'gulp-angular-translate-extract'
rename = require 'gulp-rename'
livereload = require 'gulp-livereload'

log = util.log


gulp.task "sass", ->
    log "Generate CSS files " + (new Date()).toString()
    gulp.src ['public/sass/*.sass', 'public/sass/modules/**/*.sass']
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

    gulp.src 'public/build/**/*.html'
    .pipe angularTranslate
        defaultLang: 'en'
        lang: ['en', 'fr']
        dest: 'public/resources/translations'
    .pipe gulp.dest 'public/wtf' # IDK how the fuck this shit works...

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

gulp.task "resources", ->
    log "Copy resources in build " + (new Date()).toString()
    gulp.src 'public/resources/**/*'
    .pipe gulp.dest 'public/build/resources'
    .pipe livereload()


gulp.task "watch", ->
    livereload.listen()
    gulp.watch 'public/sass/**/*.sass', ["sass"]
    gulp.watch 'public/jade/**/*.jade', ["jade"]
    gulp.watch 'public/resources/**/*', ["resources"]
    gulp.watch [
        'public/coffee/app.coffee'
        'public/coffee/routes.coffee'
        'public/coffee/controllers/**/*.coffee'
        'public/coffee/services/**/*.coffee'
        'public/coffee/directives/**/*.coffee'
        'public/coffee/filters/**/*.coffee'], ["coffee"]

gulp.task 'default', ['sass', 'jade', 'coffee', 'resources']
