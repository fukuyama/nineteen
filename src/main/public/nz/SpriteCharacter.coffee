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
  init: (@num,@character) ->
    @superInit(@character.spriteSheet)
    @setInteractive true
    @setMapPosition @character.mapx, @character.mapy
    return

  setMapPosition: (mapx,mapy) ->
    {
      width
      height
    } = nz.system.map.chip
    @x = mapx * width  + width  * 0.5
    @y = mapy * height + height * 0.5
    @y += height * 0.5 if mapx % 2 == 0
    return

  mapMove: (route) ->
    {
      width
      height
    } = nz.system.map.chip
    @tweener.clear()
    for node in route
      {
        x
        y
        direction
      } = node
      @character.mapx = x
      @character.mapy = y
      if @character.direction != direction
        @tweener.call @directionAnimation,@,[direction]
        @character.direction = direction
      x = x * width  + width  * 0.5
      y = y * height + height * 0.5
      y += height * 0.5 if node.x % 2 == 0
      @tweener.move(x,y,180)

  directionAnimation: (direction) ->
    @gotoAndPlay(nz.system.character.directions[direction])
