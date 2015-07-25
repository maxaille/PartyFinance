module.exports = (grunt) ->
    grunt.loadNpmTasks('grunt-contrib-coffee')
    grunt.loadNpmTasks('grunt-contrib-jade')
    grunt.loadNpmTasks('grunt-contrib-sass')
    grunt.loadNpmTasks('grunt-contrib-watch')

    grunt.initConfig
        coffee:
            compile:
                cwd: 'public/coffee'
                src: ['**/*.coffee']
                dest: 'public/build/js'
                expand: true
                flatten: true
                ext: '.js'
        sass:
            compile:
                options:
                    style: 'compressed'
                files: [
                    cwd: 'public/sass'
                    src: ['**/*.sass']
                    dest: 'public/build/css'
                    expand: true
                    ext: '.min.css'
                ]
        jade:
            compile:
                options:
                    client: false
                    pretty: false
                files: [
                    cwd: 'public/jade'
                    src: '**/*.jade'
                    dest: 'public/build'
                    expand: true
                    ext: '.html'
                ]
        watch:
            coffee:
                files: ['public/coffee/**/*.coffee']
                tasks: ['coffee']
            jade:
                files: ['public/jade/**/*.jade']
                tasks: ['jade']
            sass:
                files: ['public/sass/**/*.sass']
                tasks: ['sass']

    grunt.registerTask 'default', ['jade', 'sass', 'coffee']
