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

    @map =
      width: 15
      height: 15
      data: []

    @characters = [
      {
        name: 'テストキャラクター'
        spriteSheet: 'character_001'
      }
    ]

    @mapSprite = nz.SpriteBattleMap(@map).addChildTo(@)
    @mapSprite.x += 32 * 5

    @characterSprites = for character in @characters
      nz.SpriteCharacter(character)
        .addChildTo(@mapSprite)
        .on 'pointingend', (e) ->
          e.app.currentScene._openCharacterMenu(@character)

    @characterSprites[0].setMapPosition(10,10)

    return

  _openCharacterMenu: (character)->
    @app.pushScene tm.ui.MenuDialog(
      screenWidth: nz.system.screen.width
      screenHeight: nz.system.screen.height
      title: character.name
      showExit: true
      menu: ['移動','攻撃','射撃']
    ).on('menuselected', @_characterMenuSelected.bind(@))

  _characterMenuSelected: (e) ->
    if e.selectIndex == 0 # 移動
      @mapSprite.pointingover = (e) ->
        console.log "over #{e.mapx} #{e.mapy}"
      @one 'pointingend', (e) ->
        @mapSprite.pointingover = null
