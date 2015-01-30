###*
* @file SceneBattle.coffee
* 戦闘シーン
###

tm.define 'nz.SceneBattle',
  superClass: tm.app.Scene

  ###* 初期化
  * @classdesc 戦闘シーンクラス
  * @constructor nz.SceneBattle
  ###
  init: () ->
    console.log 'SceneBattle'
    @superInit()

    @characters = []

    @mapSprite = nz.SpriteBattleMap().addChildTo(@)

    @characterSprites = for character in @characters
      nz.SpriteCharacter(character).addChildTo(@mapSprite)

    return
