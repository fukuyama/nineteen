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
      width:  @width
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

  isGhost: () -> (@alpha == 0.5) # 半透明かどうかで判断
  hasGhost: () -> @ghost != null

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
    {@x,@y} = nz.utils.mapxy2screenxy(@)
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

  ###* 座標方向確認。
  * キャラクターの向いている方向を考慮し、指定された座標が、キャラクターからみてどの方向にあるか確認する。
  * @param {number} param.x          mapSprite の local X座標
  * @param {number} param.y          mapSprite の local Y座標
  * @param {number} param.start      確認する開始角度 -180 ～ 180
  * @param {number} param.end        確認する終了角度 -180 ～ 180
  * @param {Function} param.callback チェック結果をもらう関数
  ###
  checkDirection: (param) ->
    {
      r
      start
      end
      anticlockwise
      callback
    } = param
    r = nz.utils.relativeRotation(@body.rotation,@,param) unless r?
    r1 = if anticlockwise then end   else start
    r2 = if anticlockwise then start else end
    res = false
    if r1 < r2
      res = r1 <= r and r <= r2
    else
      res = r1 <= r or  r <= r2
    if callback?
      unless res
        ra = r1 if r1 > r
        ra = r2 if r  > r2
      callback(res,ra)
    return res

  _checkAttackDirection: (p) ->
    p.x -= @width  / 2
    p.y -= @height / 2
    return true if @checkDirection(p)
    p.x += @width
    return true if @checkDirection(p)
    p.y += @height
    return true if @checkDirection(p)
    p.x -= @width
    return true if @checkDirection(p)
    return false

  _updateAttack: (enemy) ->
    return unless @attack
    return if @character.team == enemy.character.team
    cw = @character.weapon
    distance = enemy.position.distance @position
    if distance < (cw.height + @body.width / 2)
      p = enemy.position.clone().$extend cw.range
      if @_checkAttackDirection(p)
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
    @move      = false
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
    @tweener.call @_endAction,@,[]
    return

  applyPosition: ->
    @character.mapx      = @mapx
    @character.mapy      = @mapy
    @character.direction = @direction
    return

  _endAction: ->
    @applyPosition()
    @move                = false
    @action              = false
    # まだ攻撃してない場合、攻撃をつづける
    if @attack
      @updateBattle()
      @update = @updateBattle
    @tweener.clear()
    return

  isMove: -> @move
  isStop: -> not @move

  _setShotAction: (param) ->
    @tweener.call @shotAnimation,@,[param]
    return

  _setMoveAction: (param) ->
    @move = true
    {
      @mapx
      @mapy
      speed
    } = param
    {
      x
      y
    } = nz.utils.mapxy2screenxy(@)
    @tweener.move(x,y,speed)
    return

  _setBackAction: (param) ->
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
    @weapon.rotation = cw.range.start
    @weapon.tweener
        .clear()
        .wait 50
        .rotate(cw.range.end,cw.speed)
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
    @character.hp -= @character.armor.defense - attacker.shot.damage
    return

  _hitWeapon: (attacker) ->
    console.log "hit weapon #{@character.name}"
    @character.hp -= @character.armor.defense - attacker.weapon.damage
    return
