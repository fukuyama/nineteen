
# tmlib-coffee-sample gruntfile
module.exports = (grunt) ->
  pkg = grunt.file.readJSON 'package.json'

  banner = """
  /*
   * #{pkg.name} #{pkg.version}
   * #{pkg.homepage}
   * #{pkg.license} Licensed
   *
   * Copyright (C) 2015 #{pkg.author}
   */

  """

  data_names = [
    'chipdata'
    'map_000'
    'map_001'
    'character_001'
  ]

  # 共通系スクリプト(tmlib.js 非依存のつもり)
  common_sections = [
  ]

  # 公開用スクリプト
  public_sections = [
    'nz/System'
    'nz/Graph'
    'nz/GridNode'
    'nz/Character'
    'nz/SceneTitleMenu'
    'nz/SceneBattle'
    'nz/SpriteBattleMap'
    'nz/SpriteCharacter'
    'main'
  ]

  src_dir = 'src/'
  target_dir = 'target/'
  doc_dir = 'doc/'

  main_path = 'main/'
  test_path = 'test/'
  common_path = 'common/'
  public_path = 'public/'
  data_path = 'data/'

  target_gen_dir = target_dir + 'generate/'
  target_public_dir = target_dir + public_path

  src_main_dir = src_dir + main_path
  src_test_dir = src_dir + test_path
  
  coffeelintConfig =
    options:
      configFile: 'coffeelint.json'
    all:
      files:
        src: [
          'gruntfile.coffee'
          'src/**/*.coffee'
        ]

  coffeeConfig =
    options:
      bare: false
    public_test:
      expand: true
      cwd: src_test_dir + public_path
      src: ['**/*.coffee']
      dest: target_public_dir + test_path
      ext: '.js'

  watchConfig =
    express:
      files: [target_dir + '**']
      tasks: ['express:dev']
      options:
        nospawn: true
    public:
      files: [src_dir + '**/*.html',src_dir + '**/*.json']
      tasks: ['copy']
    public_test:
      files: [src_test_dir + public_path + '**.coffee']
      tasks: [
        'coffee:public_test'
      ]

  simplemochaConfig =
    options:
      reporter: 'nyan'
      ui: 'bdd'
    all:
      src: [src_test_dir + common_path + '**.coffee']

  for f in common_sections
    js = target_gen_dir + common_path + "#{f}.js"
    coffee = src_main_dir + common_path + "#{f}.coffee"
    testcase = src_test_dir + common_path + "#{f}Test.coffee"
    coffeeConfig[f] = {}
    coffeeConfig[f].files = {}
    coffeeConfig[f].files[js] = coffee
    watchConfig[f] = {
      files: [coffee,testcase]
      tasks: ['coffeelint',"coffee:#{f}","simplemocha:#{f}",'concat','uglify']
    }
    simplemochaConfig[f] = {
      src: [testcase]
    }

  for f in public_sections
    js = target_gen_dir + public_path + "#{f}.js"
    coffee = src_main_dir + public_path + "#{f}.coffee"
    coffeeConfig[f] = {}
    coffeeConfig[f].files = {}
    coffeeConfig[f].files[js] = coffee
    watchConfig[f] = {
      files: [coffee]
      tasks: ['coffeelint',"coffee:#{f}",'concat','uglify']
    }

  sources = [
    (target_gen_dir + common_path + sec + '.js' for sec in common_sections)
    (target_gen_dir + public_path + sec + '.js' for sec in public_sections)
  ]

  uglify_files = {}
  uglify_files[target_public_dir + 'main.min.js'] = [
    target_public_dir + 'main.js'
  ]

  grunt.initConfig
    coffeelint: coffeelintConfig
    simplemocha: simplemochaConfig
    coffee: coffeeConfig
    watch: watchConfig
    concat:
      options:
        banner: banner
      public_scripts:
        src: sources
        dest: target_public_dir + 'main.js'
    uglify:
      public_scripts:
        files: uglify_files
    jsdoc:
      dist:
        src: sources
        options:
          destination: doc_dir
          configure: 'jsdoc.json'
    copy:
      express:
        expand: true
        cwd: src_main_dir + 'express/'
        src: ['**']
        dest: target_dir
      public_test:
        expand: true
        cwd: src_test_dir + public_path
        src: ['**']
        dest: target_public_dir

    express:
      options:
        background: true
      dev:
        options:
          script: target_dir + 'app.js'

    clean:
      target: [target_dir, doc_dir]

    execute:
      call_sample:
        call: (grunt, op) ->
          grunt.log.writeln('Hello!')
      test:
        call: (grunt, op) ->
          chipdata = require('./src/data/chip.coffee')
          console.log chipdata
          mapdata = require('./src/data/map001.coffee')
          console.log mapdata
      createdata:
        call: (grunt, op) ->
          fs = require 'fs'
          for name in data_names
            obj = require './' + src_main_dir + data_path + name + '.coffee'
            out = target_public_dir + data_path + name + '.json'
            fs.writeFile out, JSON.stringify(obj), (err) -> throw err if err?

  for o of pkg.devDependencies
    grunt.loadNpmTasks o if /grunt-/.test o
  
  grunt.registerTask 'server', ['express:dev', 'watch']
  grunt.registerTask 'test', ['coffeelint','simplemocha:all']
  grunt.registerTask 'createdata', ['execute:createdata']
  grunt.registerTask 'default', [
    'coffeelint','coffee', 'simplemocha:all'
    'concat', 'uglify', 'copy', 'createdata'
  ]
