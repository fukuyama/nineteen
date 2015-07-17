
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
  'nz/SpriteBattleMap'
  'nz/SpriteCharacter'
  'nz/SpriteStatus'
  'nz/EventHandlerBattle'
  'nz/SceneBase'
  'nz/SceneMenu'
  'nz/SceneTitleMenu'
  'nz/SceneBattle'
  'nz/SceneBattlePosition'
  'nz/SceneBattleMoveCommand'
  'nz/SceneBattleShotCommand'
  'nz/SceneBattleDirectionCommand'
  'nz/SceneBattlePhase'
  'nz/SceneBattleResult'
  'nz/ai/Param'
  'nz/ai/Default'
  'nz/ai/Rule'
  'main'
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
    files: (mainDir + 'public/' + s + '.coffee' for s in mainScripts)
    outputFile: 'main.min.js'
    distDir: distDir + 'public/'

  ai:
    files: (mainDir + 'public/' + s + '.coffee' for s in aiScripts)
    srcOption:
      base: mainDir + 'public/'
    distDir: distDir + 'public/'

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
    files: testDir + '**/*.coffee'

  server:
    rootDir: distDir

  cleanDir: distDir

module.exports = config
