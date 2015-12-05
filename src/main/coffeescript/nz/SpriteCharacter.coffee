###*
* @file SpriteCharacter.coffee
* キャラクタースプライト
###

MAP_CHIP_W = nz.system.map.chip.width
MAP_CHIP_H = nz.system.map.chip.height
DIRECTIONS = nz.system.character.directions
ST_COST    = nz.system.character.stamina_cost

phina.define 'nz.SpriteCharacter',
  superClass: phina.display.AnimationSprite

  ###* 初期化
  * @classdesc キャラクタースプライトクラス
  * @constructor nz.SpriteCharacter
  * @param {nz.Character} character
  ###
  init: (@index,@character) ->
    @superInit(@character.spriteSheet)

    if @character.colorChanges?
      @ss = phina.asset.SpriteSheet(@ss) # 複製…ちょっと無理やり感
      w   = @ss.image.width
      h   = @ss.image.height
      bmp = @ss.image.getBitmap(0,0,w,h)
      for c in @character.colorChanges
        f = @_createColorFilter c.from, c.to
        bmp.filter f if f?
      @ss.image = phina.graphics.Canvas().resize(w,h).drawBitmap(bmp,0,0)

    @checkHierarchy = true
    @ghost = null
    @counter = new nz.BattleCounter()

    @body = phina.display.Shape(
      width:  @width
      height: @height
    ).addChildTo @

    @weapon = @createWeapon()
    @weapon.on 'enterframe', @_enterframeWeapon.bind @

    @setMapPosition @character.mapx, @character.mapy
    @setDirection @character.direction

    @on 'startBattleScene', ->
      @counter.clear()
      return
    @on 'endBattleScene', ->
      return
    @on 'startBattlePhase', ->
      @clearGhost()
      return
    @on 'endBattlePhase', ->
      return
    @on 'startBattleTurn', (e) ->
      @startAction(e.turn)
      @_weaponHitFlag = []
      return
    @on 'endBattleTurn', (e) ->
      @update = null
      @attack = false
      return
    @on 'addBallet', (e) ->
      e.ballet.collision.add(@) if @ != e.owner and @isAlive()
      return
    @on 'hitWeapon', (e) ->
      @_hitWeapon(e.owner)
      return
    @on 'hitBallet', (e) ->
      @_hitBallet(e.owner,e.ballet)
      return
    @on 'deadCharacter', (e) ->
      return
    return

  isGhost: () -> (@alpha == 0.5) # 半透明かどうかで判断
  hasGhost: () -> @ghost != null

  _createColorFilter: (a,b) ->
    if b.length is 3
      return {
        calc: (pixel, index, x, y, bitmap) ->
          if pixel[0] is a[0] and pixel[1] is a[1] and pixel[2] is a[2]
            bitmap.setPixelIndex(index, b[0], b[1], b[2])
      }
    if a.length is 4 and b.length is 4
      return {
        calc: (pixel, index, x, y, bitmap) ->
          if pixel[0] is a[0] and pixel[1] is a[1] and pixel[2] is a[2] and pixel[3] is a[3]
            bitmap.setPixel32Index(index, b[0], b[1], b[2], b[3])
      }
    return undefined

  createWeapon: ->
    w = phina.display.RectangleShape(
      width: @character.weapon.height
      height: @character.weapon.width
      strokeStyle: 'black'
      fillStyle: 'red'
    ).addChildTo @body
      .setOrigin(0.0,0.5)
      .setVisible(false)
    w.checkHierarchy = true
    return w

  createGhost: (param) ->
    {
      direction
      mapx
      mapy
    } = param
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
    for enemy,i in scene.characterSprites when @index != i and enemy.isAlive()
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
      ra = r
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
        @_attackAnimation()
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
      rt = phina.geom.Vector2 0,0
      rt.setDegree(@weapon.rotation + @body.rotation, w)
      rt = @localToGlobal rt
      if enemy.isHitPoint(rt.x,rt.y)
        return true
    return false

  startAction: (turn) ->
    @tweener.clear()
    @move      = false
    @attack    = false
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
    else
      @_endAction()
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
  isDead: -> @character.isDead()
  isAlive: -> @character.isAlive()

  _setShotAction: (param) ->
    @tweener.call @_shotAnimation,@,[param]
    @tweener.call @_fatigue,@,[ST_COST.shot]
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
      .call (->@counter.moveCount()),@,[]
      .call @_fatigue,@,[ST_COST.move]
    return

  _setRotateAction: (param) ->
    {
      direction
      speed
    } = param
    @tweener.wait speed
    @tweener.call @setDirection,@,[direction]
    @tweener.call @_fatigue,@,[ST_COST.rotate]

  _attackAnimation: ->
    # 攻撃アニメーション中は、アクションを続ける
    action = @action
    @action = true
    finish = ->
      @weapon.visible  = false
      @weapon.rotation = 0
      @tweener.play()
      @action = action # 元の状態に
      @_fatigue(ST_COST.attack)
    @tweener.pause()
    cw = @character.weapon
    @weapon.visible = true
    @weapon.rotation = cw.range.start
    @weapon.tweener
        .clear()
        .wait 50
        .rotate(cw.range.end,cw.speed)
        .call finish,@,[]

  _shotAnimation: (param) ->
    {
      rotation
      distance
      speed
    } = param
    scene = @getRoot()
    bv = scene.mapSprite.globalToLocal @localToGlobal(@body.position)
    ballet = phina.display.CircleShape(
      x:      bv.x
      y:      bv.y
      width:  10
      height: 10
    ).addChildTo scene.mapSprite
    angle = Math.degToRad(rotation)
    vx = distance * Math.cos(angle) + bv.x
    vy = distance * Math.sin(angle) + bv.y
    speed = speed * distance / 32
    info = {
      ballet: ballet
      owner: @
    }
    ｈ = scene.eventHandler
    finish = ->
      ballet.remove()
      ｈ.removeBallet(info)
    ballet.tweener
      .move(vx,vy,speed)
      .call finish, @, []
    ballet.on 'collisionenter', (e) ->
      e.other.flare 'hitBallet', info
      ballet.tweener
        .clear()
        .call finish, @, []

    ｈ.addBallet(info)
    return

  _deadAnimation: (param) ->
    # TODO:死亡時アニメーション
    return

  _hitBallet: (shooter,ballet) ->
    d = shooter.character.shot.damage - @character.armor.defense
    @_damage(d,shooter)
    shooter.counter.hitBallet(d)
    @counter.receiveBallet(d)
    # TODO: SE
    return

  _hitWeapon: (attacker) ->
    d = attacker.character.weapon.damage - @character.armor.defense
    @_damage(d,attacker)
    attacker.counter.hitWeapon(d)
    @counter.receiveWeapon(d)
    # TODO: SE
    return

  _damage: (n,s)->
    return if n <= 0
    c = @character
    return if c.isDead()
    c.hp -= n
    h = @getRoot().eventHandler
    if c.isDead()
      h.deadCharacter(c)
      s.counter.killing(c.name)
      @_dead()
    h.refreshStatus()
    return

  _dead: ->
    @attack = false
    @_endAction()
    @hide()
    @counter.deadCount()
    return

  _fatigue: (n) ->
    return if n <= 0
    @character.sp -= n
    @getRoot().eventHandler?.refreshStatus()
    return
