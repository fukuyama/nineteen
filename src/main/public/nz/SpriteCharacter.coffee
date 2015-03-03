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
      width: @character.weapon.height
      height: @character.weapon.width
      strokeStyle: 'black'
      fillStyle: 'red'
    ).addChildTo @body
      .setOrigin(0.0,0.5)
      .setVisible(false)

    @setMapPosition @character.mapx, @character.mapy
    @setDirection @character.direction

    @setInteractive true
    @on 'pointingover', @_dispatchCharacterEvent
    @on 'pointingout', @_dispatchCharacterEvent
    @on 'pointingend', @_dispatchCharacterEvent
    return

  _dispatchCharacterEvent: (_e) ->
    e = tm.event.Event('character.' + _e.type)
    e.app = _e.app
    e.characterIndex = @index
    e.mapx = @mapx
    e.mapy = @mapy
    e.ghost = false
    e.ghost = true if @mapx != @character.mapx or @mapy != @character.mapy
    e.ghost = true if @ghost?.mapx == e.mapx and @ghost?.mapy == e.mapy
    console.log e.ghost
    e.app.currentScene.dispatchEvent e
    return

  createGhost: (direction,mapx,mapy) ->
    @clearGhost()
    @ghost = nz.SpriteCharacter(@index,@character)
      .setAlpha 0.5
      .setMapPosition(mapx, mapy)
      .setDirection(direction)
    return @ghost

  clearGhost: ->
    @ghost.remove() if @ghost?
    @ghost = null
    return

  isGhost: -> @mapx != @character.mapx or @mapy != @character.mapy

  setMapPosition: (@mapx,@mapy) ->
    {
      width
      height
    } = nz.system.map.chip
    @x = mapx * width  + width  * 0.5
    @y = mapy * height + height * 0.5
    @y += height * 0.5 if mapx % 2 == 0
    return @

  setDirection: (@direction) ->
    d = nz.system.character.directions[@direction]
    @body.rotation = d.rotation
    @gotoAndPlay(d.name)
    return @

  updateAttack: (enemy) ->
    return unless @attack
    cw = @character.weapon
    distance = enemy.position.distance @position
    if distance < (cw.height + @body.width / 2)
      v = tm.geom.Vector2 enemy.x - @x, enemy.y - @y
      r = Math.radToDeg(v.toAngle()) - @body.rotation
      if cw.rotation.start <= r and r <= cw.rotation.end
        @attackAnimation()
        @attack = false
    return

  startAction: (turn) ->
    @tweener.clear()
    @action    = true
    @mapx      = @character.mapx
    @mapy      = @character.mapy
    @direction = @character.direction
    command = @character.commands[turn]
    if command?
      @attack = command.attack
      for action in command.actions
        @_setShotAction(action) if action.shot?
        @_setMoveAction(action) if action.x? and action.y?
    @tweener.call @_endAction,@,[turn]
    return

  _endAction: (turn) ->
    @character.mapx      = @mapx
    @character.mapy      = @mapy
    @character.direction = @direction
    @attack              = false
    @action              = false
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

  directionAnimation: (direction) ->
    @setDirection direction

  attackAnimation: ->
    cw = @character.weapon
    @weapon.visible = true
    @weapon.rotation = cw.rotation.start
    @weapon.tweener
        .clear()
        .rotate(cw.rotation.end,cw.speed)
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
    bv = @body.localToGlobal(tm.geom.Vector2(0,0))
    ballet = tm.display.CircleShape(
      x: bv.x
      y: bv.y
      width: 10
      height: 10
    ).addChildTo @getRoot()
    angle = Math.degToRad(rotation)
    vx = distance * Math.cos(angle) + bv.x
    vy = distance * Math.sin(angle) + bv.y
    ballet.tweener.move(vx,vy,speed).call(-> ballet.remove())
