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
        name: 'SampleAI'
        src: 'nz/ai/SampleAI.js'
      maxhp: 100
      hp: 100
      sp: 100
      ap: 6
      mapx: -1
      mapy: -1
      direction: 0
      move:
        speed: 300
      armor:
        defense: 20
      weapon:
        damage: 50
        height: 48
        width: 12
        range:
          start: 0
          end: 120
          anticlockwise: false
        speed: 600
      shot:
        damage: 30
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
      @clearAction i
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
      hp:        @hp
      sp:        @sp
      ap:        @ap
      mapx:      @mapx
      mapy:      @mapy
      direction: @direction
      team:      @team
    }
    nz.utils.marge info.move, @move
    nz.utils.marge info.weapon, @weapon
    nz.utils.marge info.shot, @shot
    return new nz.Character(info)

  ###* アクション削除
  * @param {number} i 戦闘ターン数
  * @memberof nz.Character#
  * @method clearAction
  ###
  clearAction: (i) ->
    command = @_command i
    command.attack = false
    command.actions = []
    command.cost = 0
    return

  ###* 移動アクション削除
  * @param {number} i 戦闘ターン数
  * @memberof nz.Character#
  * @method clearMoveAction
  ###
  clearMoveAction: (i) ->
    command = @_command i
    command.actions = []
    command.cost = 0
    if @isAttackCommand(i)
      command.cost += ACTION_COST.attack
    return

  ###* 射撃アクションを削除
  * @param {number} i 戦闘ターン数
  * @memberof nz.Character#
  * @method clearShotAction
  ###
  clearShotAction: (i) ->
    command = @_command i
    actions = []
    for action in command.actions
      if action.shot?
        command.cost += ACTION_COST.shot
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
  getRemnantAp: (i) -> @ap - @getActionCost(i)

  ###* 移動コマンドを追加
  * @param {number} i 戦闘ターン数
  * @param {Array} route 移動ルート
  * @memberof nz.Character#
  * @method addMoveCommand
  ###
  addMoveCommand: (i,route) ->
    command = @_command i
    direction = @direction
    for a in command.actions when a.rotate?
      direction = a.rotate.direction
    prev = command.cost
    cost = 0
    for r in route when prev + cost <= @ap
      if direction != r.direction
        @addRotateCommand i, direction, DIRECTIONS[direction].rotateIndex[r.direction]
        direction = r.direction
      else
        r.speed = @move.speed
        if r.back
          r.speed *= 2
        command.actions.push
          move: r
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
      command.cost += ACTION_COST.rotate
    return @

  ###* 攻撃コマンドを設定
  * @param {number}  i    戦闘ターン数
  * @param {boolean} flag 攻撃する場合 true
  * @memberof nz.Character#
  * @method setAttackCommand
  ###
  setAttackCommand: (i,flag = true) ->
    if command.attack == flag
      return @
    command = @_command i
    if flag
      if @ap >= ACTION_COST.attack
        command.cost += ACTION_COST.attack
        command.attack = true
    else
      command.cost -= ACTION_COST.attack
      command.attack = false
    return @

  ###* 射撃コマンドを追加
  * @param {number} i        戦闘ターン数
  * @param {number} rotation 射撃角度
  * @memberof nz.Character#
  * @method addShotCommand
  ###
  addShotCommand: (i,rotation) ->
    command = @_command i
    command.actions.push
      shot:
        rotation: rotation
        distance: @shot.distance
        speed: @shot.speed
    command.cost += ACTION_COST.shot
    return @

  ###* 射撃コマンドが設定されているかどうか
  * @param {number} i 戦闘ターン数
  * @return {boolean} 射撃コマンドを設定していたら true
  * @memberof nz.Character#
  * @method isShotCommand
  ###
  isShotCommand: (i) ->
    command = @_command i
    for action in command.actions when action.shot?
      return true
    return false

  ###* 攻撃コマンドが設定されているかどうか
  * @param {number} i 戦闘ターン数
  * @return {boolean} 攻撃コマンドを設定していたら true
  * @memberof nz.Character#
  * @method isAttackCommand
  ###
  isAttackCommand: (i) ->
    command = @_command i
    return command.attack

  ###* 移動コマンドが設定されているかどうか
  * @param {number} i 戦闘ターン数
  * @return {boolean} 移動コマンドを設定していたら true
  * @memberof nz.Character#
  * @method isMoveCommand
  ###
  isMoveCommand: (i) ->
    command = @_command i
    for action in command.actions when action.move?
      return true
    return false
