###*
* @file Character.coffee
* キャラクター情報
###

DIRECTIONS = nz.system.character.directions
ACTION_COST = nz.system.character.action_cost

tm.define 'nz.Character',

  ###* 初期化
  * @classdesc キャラクタークラス
  * @constructor nz.Character
  ###
  init: (param = {}) ->
    @.$extend {
      name: 'テストキャラクター'
      spriteSheet: 'character_001'
      team: 'teamA'
      ai:
        name: 'SampleAI'
        src: 'nz/ai/SampleAI.js'
      hp: 10
      ap: 6
      mapx: -1
      mapy: -1
      direction: 0
      move:
        speed: 300
      weapon:
        height: 48
        width: 12
        rotation:
          start: 0
          end: 120
          anticlockwise: false
        speed: 600
      shot:
        rotation:
          start: 0
          end: -120
          anticlockwise: true
        distance: 32 * 8
        speed: 100
      commands: [] # 戦闘コマンドリスト
    }.$extend param
    return

  _command: (i) ->
    i = @commands.length - 1 unless i?
    unless @commands[i]?
      @commands[i] = {}
      @clearAction i
    @commands[i]

  ###* アクション削除
  * @param {number} i 戦闘ターン数
  ###
  clearAction: (i) ->
    command = @_command i
    command.attack = false
    command.actions = []
    command.cost = 0
    return
  clearMoveAction: (i) ->
    command = @_command i
    command.actions = []
    command.cost = 0
    if @isAttackAction(i)
      command.cost += ACTION_COST.attack
    return
  clearShotAction: (i) ->
    command = @_command i
    actions = []
    for action in command.actions
      if action.shot?
        command.cost += ACTION_COST.shot
      actions.push action
    command.actions = actions
    return

  ###* アクションコストの取得
  * @param {number} i 戦闘ターン数
  ###
  getActionCost: (i) -> @_command(i).cost

  ###* 残りのアクションポイント
  * @param {number} i 戦闘ターン数
  ###
  getRemnantAp: (i) -> @ap - @getActionCost(i)

  ###* 移動ルートの追加
  * @param {number} i 戦闘ターン数
  * @param {Array} route 移動ルート
  ###
  addMoveCommand: (i,route) ->
    command = @_command i
    direction = @direction
    for a in command.actions when a.rotate?
      direction = a.rotate.direction
    prev = command.cost
    cost = 0
    for r in route
      if direction != r.direction
        @addRotateCommand i, direction, DIRECTIONS[direction].rotateIndex[r.direction]
        direction = r.direction
      r.speed = @move.speed
      command.actions.push
        move: r
      cost = r.cost
    command.cost = prev + cost
    return @

  ###* 方向転換の追加
  * @param {number} i 戦闘ターン数
  * @param {number} direction1 元の向き
  * @param {number} rotateIndex 方向転換する量(マイナスは反時計回り)
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

  ###* 攻撃モードの設定
  * @param {number}  i    戦闘ターン数
  * @param {boolean} flag 攻撃する場合 true
  ###
  setAttackCommand: (i,flag = true) ->
    command = @_command i
    if command.attack != flag
      if flag
        command.cost += ACTION_COST.attack
      else
        command.cost -= ACTION_COST.attack
      command.attack = flag
    return @

  ###* 射撃角度の追加
  * @param {number} i        戦闘ターン数
  * @param {number} rotation 射撃角度
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

  ###* 射撃アクションを行っているかどうか
  * @param {number} i 戦闘ターン数
  * @return {boolean} 射撃アクションを設定していたら true
  ###
  isShotAction: (i) ->
    command = @_command i
    for action in command.actions when action.shot?
      return true
    return false

  ###* 攻撃アクションを行っているかどうか
  * @param {number} i 戦闘ターン数
  * @return {boolean} 攻撃アクションを設定していたら true
  ###
  isAttackAction: (i) ->
    command = @_command i
    return command.attack

  ###* 移動アクションを行っているかどうか
  * @param {number} i 戦闘ターン数
  * @return {boolean} 移動アクションを設定していたら true
  ###
  isMoveAction: (i) ->
    command = @_command i
    for action in command.actions when action.move?
      return true
    return false
