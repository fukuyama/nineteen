###*
* @file SpriteCharacter.coffee
* キャラクタースプライト
###

tm.define 'nz.SpriteCharacter',
  superClass: tm.display.AnimationSprite

  ###* 初期化
  * @classdesc キャラクタースプライトクラス
  * @constructor nz.SpriteCharacter
  * @param {nz.Character} character
  ###
  init: (@character) ->
    @superInit(@character.spriteSheet)
    @setInteractive true
    @setMapPosition @character.mapx, @character.mapy
    return

  setMapPosition: (mapx,mapy) ->
    {
      width
      height
    } = nz.system.map.chip
    @x = mapx * width + width * 0.5
    @y = mapy * height + height * 0.5
    @y += height * 0.5 if mapx % 2 == 0
    return
