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
  init: (@index,@character) ->
    @superInit(@character.spriteSheet)

    @body = tm.display.Shape(
      width: @width
      height: @height
    ).addChildTo @

    @weapon = tm.display.RectangleShape(
      width: @character.weapon.width
      height: @character.weapon.height
      strokeStyle: 'black'
      fillStyle: 'gray'
    ).addChildTo @body
      .setOrigin(0.5,1.0)
      .setVisible(false)

    @gotoAndStop(nz.system.character.directions[@character.direction].name)

    @setInteractive true
    @setMapPosition @character.mapx, @character.mapy
    @on 'pointingover', @_dispatchCharacterEvent
    @on 'pointingout', @_dispatchCharacterEvent
    @on 'pointingend', @_dispatchCharacterEvent
    return

  _dispatchCharacterEvent: (_e) ->
    e = tm.event.Event('character.' + _e.type)
    e.app = _e.app
    e.characterIndex = @index
    e.app.currentScene.dispatchEvent e
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

  updateDirection: ->
    @body.rotation = nz.system.character.directions[@character.direction].rotation

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
    @gotoAndPlay(nz.system.character.directions[direction].name)

  attackAnimationStart: ->
    @updateDirection()
    @weapon.visible = true
    @weapon.rotation = @character.weapon.rotation.start
    @weapon.tweener
        .clear()
        .rotate(@character.weapon.rotation.end,@character.weapon.speed)
        .call @_attackAnimationEnd,@,[]

  _attackAnimationEnd: ->
    @weapon.visible = false
    @weapon.rotation = 0
