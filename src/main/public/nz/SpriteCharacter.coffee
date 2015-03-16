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
    @checkHierarchy = true
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
    @weapon.checkHierarchy = true

    @weapon.on 'enterframe', @_enterframeWeapon.bind @

    @setMapPosition @character.mapx, @character.mapy
    @setDirection @character.direction

    @setInteractive true
    @on 'pointingover', @_dispatchCharacterEvent
    @on 'pointingout', @_dispatchCharacterEvent
    @on 'pointingend', @_dispatchCharacterEvent

    @on 'battleSceneStart', ->
      @clearGhost()
      #@update = @updateBattle
      return
    @on 'battleSceneEnd', ->
      @update = null
      return
    @on 'battleTurnStart', (e) ->
      @startAction(e.turn)
      @_weaponHitFlag = []
      return

    @on 'hitWeapon', (e) ->
      @_hitWeapon(e.owner)
      return

    @on 'hitBallet', (e) ->
      @_hitBallet(e.owner,e.ballet)
      return

    return

  _dispatchCharacterEvent: (_e) ->
    e = tm.event.Event('character.' + _e.type)
    e.app   = _e.app
    e.mapx  = @mapx
    e.mapy  = @mapy
    e.ghost =
      (@mapx != @character.mapx or @mapy != @character.mapy) or
      (@ghost?.mapx == @mapx and @ghost?.mapy == @mapy)
    e.characterIndex = @index
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
    if @ghost?
      @ghost.remove()
      @ghost = null
    return

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

  updateBattle: ->
    scene = @getRoot()
    for enemy,i in scene.characterSprites when @index != i
      @_updateAttack(enemy)
    return

  _updateAttack: (enemy) ->
    return unless @attack
    cw = @character.weapon
    distance = enemy.position.distance @position
    if distance < (cw.height + @body.width / 2)
      v = tm.geom.Vector2 enemy.x - @x, enemy.y - @y
      r = Math.radToDeg(v.toAngle()) - @body.rotation
      if r > 180
        r = 360 - r
      else if r < -180
        r = 360 + r
      if cw.rotation.start <= r and r <= cw.rotation.end
        @attackAnimation()
        @attack = false
    return

  _enterframeWeapon: (e) ->
    return unless @weapon.visible
    scene = e.app.currentScene
    for enemy,i in scene.characterSprites when @index != i and not @_weaponHitFlag[i]
      if @_isHitWeapon(enemy)
        enemy.flare 'hitWeapon', {owner: @}
        @_weaponHitFlag[i] = true
    return

  _isHitWeapon: (enemy) ->
    for w in [16 ... @weapon.width] by 8
      rt = tm.geom.Vector2 0,0
      rt.setDegree(@weapon.rotation + @body.rotation, w)
      rt = @localToGlobal rt
      if enemy.isHitPoint(rt.x,rt.y)
        return true
    return false

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
        if @attack
          @tweener.call @updateBattle,@,[]
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
    finish = ->
      @weapon.visible  = false
      @weapon.rotation = 0
      @tweener.play()
    @tweener.pause()
    cw = @character.weapon
    @weapon.visible = true
    @weapon.rotation = cw.rotation.start
    @weapon.tweener
        .clear()
        .wait 50
        .rotate(cw.rotation.end,cw.speed)
        .call finish,@,[]

  shotAnimation: (param) ->
    {
      rotation
      distance
      speed
    } = param
    scene = @getRoot()
    bv = scene.mapSprite.globalToLocal @localToGlobal(@body.position)
    ballet = tm.display.CircleShape(
      x:      bv.x
      y:      bv.y
      width:  10
      height: 10
    ).addChildTo scene.mapSprite
    angle = Math.degToRad(rotation)
    vx = distance * Math.cos(angle) + bv.x
    vy = distance * Math.sin(angle) + bv.y
    speed = speed * distance / 32
    einfo = {
      ballet: ballet
      owner: @
    }
    finish = ->
      ballet.remove()
      scene.flare 'removeBallet', einfo
    ballet.tweener
      .move(vx,vy,speed)
      .call finish, @, []
    ballet.on 'collisionenter', (e) ->
      e.other.flare 'hitBallet', einfo
      ballet.tweener
        .clear()
        .call finish, @, []

    scene.flare 'addBallet', einfo

  _hitBallet: (shooter,ballet) ->
    console.log "hit ballet #{@character.name}"
    return

  _hitWeapon: (attacker) ->
    console.log "hit weapon #{@character.name}"
    return
