
# ------------

mainDir = './src/main/'
testDir = './src/test/'
distDir = './target/'

mainScripts = [
  'nz/System'
  'nz/SceneBase'
  'nz/SceneTitleMenu'
  'nz/SceneBattle'
  'MenuScene'
  'main'
]
testTargets = [
  'nz/Utils'
  'nz/Graph'
  'nz/GridNode'
  'nz/Character'
  'nz/BattleCounter'
  'nz/ai/Param'
]
dataNames= [
  'chipdata'
  'map_000'
  'map_001'
  'character_001'
  'character_test'
]
aiScripts= [
  'nz/ai/Sample'
  'nz/ai/Shooter'
  'nz/ai/Chaser'
  'nz/ai/Runner'
]

# ------------
config =
  main:
    files: (mainDir + 'coffeescript/' + name + '.coffee' for name in mainScripts)
    outputFile: 'main'
    distDir: distDir + 'public/javascripts/'

  ai:
    files: (mainDir + 'public/' + s + '.coffee' for s in aiScripts)
    srcOption:
      base: mainDir + 'public/javascripts/'
    distDir: distDir + 'public/javascripts/ai/'

  express:
    files: mainDir + 'express/**'
    distDir: distDir

  lib: [
    {files: 'lib/phina.js/build/phina.js', distDir: distDir + 'public/javascripts/'}
  ]

  data:
    dataNames: dataNames
    srcDir: mainDir + 'data/'
    distDir: distDir + 'public/data/'

  coffeelint:
    files: mainDir + '**/*.coffee'

  test:
    console:
      files: testDir + 'coffeescript/**/*.coffee'
      watch:
        files: (mainDir + 'coffeescript/' + name + '.coffee' for name in testTargets)

  server:
    rootDir: distDir

  cleanDir: distDir

module.exports = config
