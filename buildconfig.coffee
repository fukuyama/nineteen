
# ------------

mainDir = './src/main/'
testDir = './src/test/'
distDir = './target/'

mainScripts = [
  'nz/System'
  'nz/Utils'
  'nz/Graph'
  'nz/GridNode'
  'nz/Character'
  'nz/BattleCounter'
  'nz/SpriteBattleMap'
  'nz/SpriteCharacter'
  'nz/SpriteStatus'
  'nz/SpriteHelpText'
  'nz/EventHandlerBattle'
  'nz/SceneBase'
  'nz/SceneMenu'
  'nz/SceneTitleMenu'
  'nz/SceneBattle'
  'nz/SceneBattlePosition'
  'nz/SceneBattleRotatePointer'
  'nz/SceneBattleMoveCommand'
  'nz/SceneBattleShotCommand'
  'nz/SceneBattleDirectionCommand'
  'nz/SceneBattlePhase'
  'nz/SceneBattleResult'
  'nz/ScenePopMessage'
  'nz/ai/Param'
  'nz/ai/Default'
  'nz/ai/Rule'
  'config'
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
