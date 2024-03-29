module.exports = (grunt) ->
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-contrib-stylus')
  grunt.loadNpmTasks('grunt-contrib-jade')

  grunt.initConfig
    watch:
      coffee:
        files: 'src/app/*.coffee'
        tasks: ['coffee:compile']
      style:
        files: 'src/style/*.styl'
        tasks: ['stylus:compile']
      jade:
        files: 'src/partials/*.jade'
        tasks: ['jade:compile']

    coffee:
      compile:
        expand: true,
        flatten: true,
        cwd: "#{__dirname}/src/",
        src: ['app/*.coffee'],
        dest: 'public/app/js/',
        ext: '.js'
    stylus:
      compile:
        expand: true,
        flatten: true,
        cwd: "#{__dirname}/src/",
        src: ['style/app.styl'],
        dest: 'public/app/css/',
        ext: '.css'
    jade:
      compile:
        expand: true,
        flatten: true,
        cwd: "#{__dirname}/src/",
        src: ['partials/*.jade'],
        dest: 'public/app/partials/',
        ext:'.html'