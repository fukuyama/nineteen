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
    @ghost = null

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

  createGhost: (direction,mapx,mapy) ->
    @ghost.remove() if @ghost?
    @ghost = nz.SpriteCharacter(@index,@character)
      .setMapPosition(mapx, mapy)
      .gotoAndStop(nz.system.character.directions[direction].name)
    return @ghost

  startAction: (turn) ->
    @tweener.clear()
    @mapx      = @character.mapx
    @mapy      = @character.mapy
    @direction = @character.direction
    command = @character.commands[turn]
    if command?
      @attack    = command.attack
      for action in command.actions
        @_setShotAction(action) if action.shot?
        @_setMoveAction(action) if action.x? and action.y?
    @tweener.call @endAction,@,[turn]
    return

  endAction: (turn) ->
    @character.mapx      = @mapx
    @character.mapy      = @mapy
    @character.direction = @direction
    @attack              = false
    return

  _setShotAction: (action) ->
    @tweener.call @shotAnimation,@,[action.shot]
    return
  _setMoveAction: (action) ->
    {
      x
      y
      direction
      speed
    } = action
    {
      width
      height
    } = nz.system.map.chip
    @mapx = x
    @mapy = y
    if @direction != direction
      @tweener.call @directionAnimation,@,[direction]
      @direction = direction
    x = x * width  + width  * 0.5
    y = y * height + height * 0.5
    y += height * 0.5 if @mapx % 2 == 0
    @tweener.move(x,y,speed)
    return

  attackCommand: (param) ->
    @attackAnimationStart()

  setMapPosition: (mapx,mapy) ->
    {
      width
      height
    } = nz.system.map.chip
    @x = mapx * width  + width  * 0.5
    @y = mapy * height + height * 0.5
    @y += height * 0.5 if mapx % 2 == 0
    return @

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

  shotAnimation: (param) ->
    {
      rotation
      distance
      speed
    } = param
    b = @body.localToGlobal(tm.geom.Vector2(0,0))
    ballet = tm.display.CircleShape(
      x: b.x
      y: b.y
      width: 10
      height: 10
    ).addChildTo @getRoot()
    angle = Math.degToRad(rotation)
    vx = distance * Math.cos(angle) + b.x
    vy = distance * Math.sin(angle) + b.y
    ballet.tweener.move(vx,vy,speed).call(-> ballet.remove())
