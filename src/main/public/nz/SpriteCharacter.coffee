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
      return
    @on 'battleSceneEnd', ->
      return
    @on 'battleTurnStart', (e) ->
      @startAction(e.turn)
      @_weaponHitFlag = []
      return
    @on 'battleTurnEnd', (e) ->
      @update = null
      @attack = false
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

  calcRotation: (p) ->
    return Math.radToDeg(Math.atan2 p.y - @y, p.x - @x) - @body.rotation

  ###* 座標方向確認。
  * キャラクターの向いている方向を考慮し、指定された座標が、キャラクターからみてどの方向にあるか確認する。
  * @param {number} param.x          mapSprite の local X座標
  * @param {number} param.y          mapSprite の local Y座標
  * @param {number} param.start      確認する開始角度 -180 ～ 180
  * @param {number} param.end        確認する終了角度 -180 ～ 180
  * @param {Function} param.callback 範囲に入っていた場合に呼び出す関数
  ###
  checkDirection: (param) ->
    {
      start
      end
      anticlockwise
    } = param
    # v = tm.geom.Vector2 x - @x, y - @y
    # r = Math.radToDeg(v.toAngle()) - @body.rotation
    r = @calcRotation(param)
    if r > 180
      r = 360 - r
    else if r < -180
      r = 360 + r
    #console.log "#{r} #{param.x} #{param.y} #{@x} #{@y}"
    if anticlockwise
      if start > end
        return start >= r and r >= end
      else
        return start >= r or r >= end
    else
      if start < end
        return start <= r and r <= end
      else
        return start <= r or r <= end
    return false

  _updateAttack: (enemy) ->
    return unless @attack
    cw = @character.weapon
    distance = enemy.position.distance @position
    if distance < (cw.height + @body.width / 2)
      if @checkDirection(
        x:             enemy.x
        y:             enemy.y
        start:         cw.rotation.start
        end:           cw.rotation.end
        anticlockwise: cw.rotation.anticlockwise
      )
        @attackAnimation()
        @attack = false
    return

  _enterframeWeapon: (e) ->
    return unless @weapon.visible
    scene = @getRoot()
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
    @action              = false
    # まだ攻撃してない場合、攻撃をつづける
    if @attack
      @update = @updateBattle
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
    # 攻撃アニメーション中は、アクションを続ける
    action = @action
    @action = true
    finish = ->
      @weapon.visible  = false
      @weapon.rotation = 0
      @tweener.play()
      @action = action # 元の状態に
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
