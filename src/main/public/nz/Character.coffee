###*
* @file Character.coffee
* キャラクター情報
###

###* nineteen namespace.
* @namespace nz
###

# node.js と ブラウザでの this.nz を同じインスタンスにする
_g = window ? global
nz = _g.nz = _g.nz ? {}
_g = undefined

DIRECTIONS = nz.system.character.directions
ACTION_COST = nz.system.character.action_cost

class nz.Character

  ###* 初期化
  * @classdesc キャラクタークラス
  * @constructor nz.Character
  ###
  constructor: (param = {}) ->
    nz.utils.marge @, {
      name: 'テストキャラクター'
      spriteSheet: 'character_001'
      team: 'teamA'
      ai:
        name: 'Default'
        # src: 'nz/ai/Default.js'
      maxhp: 10
      maxsp: 10
      maxap: 6
      hp: 10
      sp: 10
      mapx: -1
      mapy: -1
      direction: 0
      move:
        speed: 300
      armor:
        defense: 1
      weapon:
        damage: 4
        height: 48
        width: 12
        range:
          start: 0
          end: 120
          anticlockwise: false
        speed: 600
      shot:
        damage: 2
        range:
          start: 0
          end: -120
          anticlockwise: true
        distance: 32 * 8
        speed: 100
    }
    nz.utils.marge @, param
    @commands = [] # 戦闘コマンドリスト
    return

  _command: (i) ->
    i = @commands.length - 1 unless i?
    unless @commands[i]?
      @commands[i] = {}
      @clearCommand i
    @commands[i]

  ###* AI用キャラクター情報
  * @param {number} i 戦闘ターン数
  * @return {nz.Character} AI用のキャラクターインスタンス
  * @memberof nz.Character#
  * @method createAiInfo
  ###
  createAiInfo: (i) ->
    info = {
      name:      @name
      maxhp:     @maxhp
      maxsp:     @maxsp
      maxap:     @maxap
      hp:        @hp
      sp:        @sp
      mapx:      @mapx
      mapy:      @mapy
      direction: @direction
      team:      @team
    }
    info.move   = nz.utils.marge {}, @move
    info.weapon = nz.utils.marge {}, @weapon
    info.shot   = nz.utils.marge {}, @shot
    info.ai     = nz.utils.marge {}, @ai
    return new nz.Character(info)

  ###* コマンド削除
  * @param {number} i 戦闘ターン数
  * @memberof nz.Character#
  * @method clearCommand
  ###
  clearCommand: (i) ->
    command = @_command i
    command.attack = false
    command.actions = []
    command.cost = 0
    return

  ###* 移動コマンド削除
  * @param {number} i 戦闘ターン数
  * @memberof nz.Character#
  * @method clearMoveCommand
  ###
  clearMoveCommand: (i) ->
    command = @_command i
    actions = []
    for action in command.actions
      if action.move? or action.rotate?
        command.cost -= action.cost
      else
        actions.push action
    command.actions = actions
    return

  ###* 攻撃コマンドを削除
  * @param {number} i 戦闘ターン数
  * @memberof nz.Character#
  * @method clearAttackCommand
  ###
  clearAttackCommand: (i) ->
    command = @_command i
    unless command.attack
      return @
    command.cost -= ACTION_COST.attack
    command.attack = false
    return @

  ###* 射撃コマンドを削除
  * @param {number} i 戦闘ターン数
  * @memberof nz.Character#
  * @method clearShotCommand
  ###
  clearShotCommand: (i) ->
    command = @_command i
    actions = []
    for action in command.actions
      if action.shot?
        command.cost -= action.cost
      else
        actions.push action
    command.actions = actions
    return

  ###* アクションコストを取得
  * @param {number} i 戦闘ターン数
  * @memberof nz.Character#
  * @method getActionCost
  ###
  getActionCost: (i) -> @_command(i).cost

  ###* 残りのアクションポイントを取得
  * @param {number} i 戦闘ターン数
  * @memberof nz.Character#
  * @method getRemnantAp
  ###
  getRemnantAp: (i) -> @maxap - @getActionCost(i)

  getLastDirection: (i) ->
    command = @_command i
    direction = @direction
    for a in command.actions when a.rotate?
      direction = a.rotate.direction
    return direction

  getLastPosition: (i) ->
    command = @_command i
    pos =
      mapx: @mapx
      mapy: @mapy
    for a in command.actions when a.move?
      pos = a.move
    return pos

  ###* 移動コマンドを追加
  * @param {number} i 戦闘ターン数
  * @param {Array} route 移動ルート
  * @memberof nz.Character#
  * @method addMoveCommand
  ###
  addMoveCommand: (i,route) ->
    command   = @_command i
    direction = @getLastDirection(i)
    prev = command.cost
    cost = 0
    for r in route when prev + cost <= @maxap
      if direction != r.direction
        @addRotateCommand i, direction, DIRECTIONS[direction].rotateIndex[r.direction]
        direction = r.direction
      else
        r.speed = @move.speed
        if r.back
          r.speed *= 2
        command.actions.push
          move: r
          cost: r.cost - cost
      cost = r.cost
    command.cost = prev + cost
    return @

  ###* 方向転換コマンドを追加
  * @param {number} i 戦闘ターン数
  * @param {number} direction1 元の向き
  * @param {number} rotateIndex 方向転換する量(マイナスは反時計回り)
  * @memberof nz.Character#
  * @method addRotateCommand
  ###
  addRotateCommand:  (i,direction1,rotateIndex) ->
    command = @_command i
    for i in [0 .. rotateIndex] when i != 0
      command.actions.push
        rotate:
          direction: (direction1 + i + 6) % 6
          speed: @move.speed
        cost: ACTION_COST.rotate
      command.cost += ACTION_COST.rotate
    return @

  ###* 攻撃コマンドを設定
  * @param {number}  i    戦闘ターン数
  * @memberof nz.Character#
  * @method setAttackCommand
  ###
  setAttackCommand: (i) ->
    if @isShotCommand i
      return @
    command = @_command i
    if command.attack
      return @
    if @maxap >= ACTION_COST.attack
      command.cost += ACTION_COST.attack
      command.attack = true
    return @

  ###* 射撃コマンドを追加
  * @param {number} i        戦闘ターン数
  * @param {number} rotation 射撃角度
  * @memberof nz.Character#
  * @method addShotCommand
  ###
  addShotCommand: (i,rotation) ->
    if @isAttackCommand i
      return @
    command = @_command i
    command.actions.push
      shot:
        rotation: rotation
        distance: @shot.distance
        speed: @shot.speed
      cost: ACTION_COST.shot
    command.cost += ACTION_COST.shot
    return @

  ###* 射撃コマンドが設定されているかどうか
  * @param {number} i 戦闘ターン数
  * @return {boolean} 射撃コマンドを設定していたら true
  * @memberof nz.Character#
  * @method isShotCommand
  ###
  isShotCommand: (i) -> @_command(i).actions.some (action) -> action.shot?

  ###* 攻撃コマンドが設定されているかどうか
  * @param {number} i 戦闘ターン数
  * @return {boolean} 攻撃コマンドを設定していたら true
  * @memberof nz.Character#
  * @method isAttackCommand
  ###
  isAttackCommand: (i) -> @_command(i).attack

  ###* 移動コマンドが設定されているかどうか
  * @param {number} i 戦闘ターン数
  * @return {boolean} 移動コマンドを設定していたら true
  * @memberof nz.Character#
  * @method isMoveCommand
  ###
  isMoveCommand: (i) -> @_command(i).actions.some (action) -> action.move?

  ###* 死亡判定
  * @return {boolean} 死んでいる場合 true
  * @memberof nz.Character#
  * @method isDead
  ###
  isDead: -> @hp <= 0

  ###* 生存判定
  * @return {boolean} 生きている場合 true
  * @memberof nz.Character#
  * @method isAlive
  ###
  isAlive: -> @hp > 0
