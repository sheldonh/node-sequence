module.exports = (grunt) ->

  distdirs = ['bin', 'lib']
  (distfiles = distdirs.map (d) -> "#{d}/**/*").push("*.js")
  (cleanfiles = distdirs.slice(0)).push("*.js")

  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    distfiles: distfiles
    cleanfiles: cleanfiles

    clean:
      build:
        src: 'build/'
        force: true
      dist:
        src: '<%= cleanfiles %>'
        force: true

    copy:
      dist:
        expand: true
        cwd: 'build/'
        src: '<%= distfiles %>'
        dest: '.'
      src:
        expand: true
        cwd: 'src/'
        src: ['<%= distfiles %>', '!**/*.coffee']
        dest: 'build/'
      test:
        expand: true
        cwd: 'test/'
        src: ['**/*', '!**/*.coffee']
        dest: 'build/test/'

    chmod:
      binfiles:
        options:
          mode: '0755'
        src: ['bin/**/*']

    coffee:
      src:
        expand: true
        cwd: 'src/'
        src: '**/*.coffee'
        dest: 'build'
        ext: '.js'
      test:
        expand: true
        cwd: 'test/'
        src: '**/*.coffee'
        dest: 'build/test'
        ext: '.js'

    simplemocha:
      options:
        reporter: 'tap'
      all:
        src: 'build/test/**/*-test.js'

    justWatch:
      src:
        options:
          event: ['added', 'changed']
        files: ['src/**/*.{coffee,js}']
        tasks: ['coffee:src', 'copy:src', 'justDist', 'justTest']
      test:
        options:
          event: ['added', 'changed']
        files: ['test/**/*.{coffee,js}']
        tasks: ['coffee:test', 'copy:test', 'justTest']
      testDeletes:
        options:
          event: 'deleted'
        files: ['test/**/*.{coffee,js}']
        tasks: ['clean:build', 'coffee:test', 'copy:test', 'justTest']
      srcDeletes:
        options:
          event: 'deleted'
        files: ['src/**/*.{coffee,js}']
        tasks: ['test']

  grunt.loadNpmTasks 'grunt-chmod'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-simple-mocha'

  grunt.registerTask 'justBuild', 'Build',                     ['coffee', 'copy:src', 'copy:test']
  grunt.registerTask 'justDist',  'Prepare distribution',      ['copy:dist', 'chmod:binfiles']
  grunt.registerTask 'justTest',  'Test',                      ['simplemocha']
  grunt.registerTask 'build',     'Clean & build',             ['clean', 'justBuild']
  grunt.registerTask 'dist',      'Clean, build & dist',       ['build', 'justDist']

  grunt.registerTask 'default',   'Clean, build & dist',       ['dist']

  grunt.registerTask 'test',      'Clean, build, dist & test', ['dist', 'justTest']

  grunt.renameTask   'watch',     'justWatch'
  grunt.registerTask 'watch',     'Clean, build, dist, test & watch', ['test', 'justWatch']
