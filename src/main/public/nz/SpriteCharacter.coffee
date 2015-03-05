###*
* @file SpriteCharacter.coffee
* キャラクタースプライト
###

MAP_CHIP_W = nz.system.map.chip.width
MAP_CHIP_H = nz.system.map.chip.height
DIRECTIONS = nz.system.character.directions

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
    w  = MAP_CHIP_W
    h  = MAP_CHIP_H
    @x = @mapx * w + w * @originX
    @y = @mapy * h + h * @originY
    @y += h * 0.5 if @mapx % 2 == 0
    return @

  setDirection: (@direction) ->
    d = DIRECTIONS[@direction]
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
        @_setShotAction(action.shot) if action.shot?
        @_setMoveAction(action.move) if action.move?
        @_setRotateAction(action.rotate) if action.rotate?
    @tweener.call @_endAction,@,[turn]
    return

  _endAction: (turn) ->
    @character.mapx      = @mapx
    @character.mapy      = @mapy
    @character.direction = @direction
    @attack              = false
    @action              = false
    return

  _setShotAction: (param) ->
    @tweener.call @shotAnimation,@,[param]
    return

  _setMoveAction: (param) ->
    {
      @mapx
      @mapy
      speed
    } = param
    w = MAP_CHIP_W
    h = MAP_CHIP_H
    x = @mapx * w + w * @originX
    y = @mapy * h + h * @originY
    y += h * 0.5 if @mapx % 2 == 0
    @tweener.move(x,y,speed)
    return

  _setRotateAction: (param) ->
    {
      direction
      speed
    } = param
    @tweener.wait speed
    @tweener.call @directionAnimation,@,[direction]

  directionAnimation: (direction) ->
    @setDirection direction

  attackAnimation: ->
    @tweener.pause()
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
    @tweener.play()

  shotAnimation: (param) ->
    {
      rotation
      distance
      speed
    } = param
    bv = @body.localToGlobal(tm.geom.Vector2(0,0))
    ballet = tm.display.CircleShape(
      x:      bv.x
      y:      bv.y
      width:  10
      height: 10
    ).addChildTo @getRoot()
    angle = Math.degToRad(rotation)
    vx = distance * Math.cos(angle) + bv.x
    vy = distance * Math.sin(angle) + bv.y
    speed = speed * distance / 32
    ballet.tweener.move(vx,vy,speed).call(-> ballet.remove())
