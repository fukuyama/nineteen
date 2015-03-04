###*
* @file Character.coffee
* キャラクター情報
###

tm.define 'nz.Character',

  ###* 初期化
  * @classdesc キャラクタークラス
  * @constructor nz.Character
  ###
  init: (param = {}) ->
    @.$extend {
      name: 'テストキャラクター'
      spriteSheet: 'character_001'
      hp: 10
      ap: 6
      mapx: 0
      mapy: 0
      direction: 0
      move:
        speed: 300
      weapon:
        height: 48
        width: 8
        rotation:
          start: 0
          end: 120
        speed: 500
      shot:
        rotation:
          start: 0
          end: -120
        distance: 32 * 8
        speed: 150
      commands: [] # 戦闘コマンドリスト
    }.$extend param
    return

  _command: (i) ->
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

  ###* アクションコストの取得
  * @param {number} i 戦闘ターン数
  ###
  actionCost: (i) ->
    @_command(i).cost

  ###* 移動ルートの追加
  * @param {number} i 戦闘ターン数
  * @param {Array} route 移動ルート
  ###
  addRoute: (i,route) ->
    command = @_command i
    direction = @direction
    for a in command.actions when a.direction?
      direction = a.direction.direction
    for r in route
      if direction != r.direction
        @addDirection i, direction, r.direction
        direction = r.direction
      r.speed = @move.speed
      command.actions.push
        move: r
    return @

  addDirection: (i,direction1,direction2) ->
    command = @_command i
    cost = nz.system.character.directions[direction1].next[direction2]
    for i in [0 .. cost] when i != 0
      command.actions.push
        direction:
          direction: (direction1 + i + 6) % 6
          speed: @move.speed

  ###* 攻撃モードの設定
  * @param {number} i 戦闘ターン数
  * @param {boolean} flag 攻撃する場合 true
  ###
  setAttack: (i,flag = true) ->
    command = @_command i
    command.attack = flag
    return @

  ###* 射撃角度の追加
  * @param {number} i 戦闘ターン数
  * @param {number} rotation 射撃角度
  ###
  addShot: (i,rotation) ->
    command = @_command i
    command.actions.push
      shot:
        rotation: rotation
        distance: @shot.distance
        speed: @shot.speed
    return @