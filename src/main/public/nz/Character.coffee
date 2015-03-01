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
      mapx: 0
      mapy: 0
      direction: 1
      move:
        speed: 200
      weapon:
        height: 48
        width: 8
        rotation:
          start: 0
          end: 120
        speed: 220
      shot:
        rotation:
          start: 0
          end: -120
        distance: 32 * 8
        speed: 180
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

  ###* 移動ルートの追加
  * @param {number} i 戦闘ターン数
  * @param {Array} route 移動ルート
  ###
  addRoute: (i,route) ->
    command = @_command i
    for r in route
      r.speed = @move.speed
      command.actions.push(r)
    return @

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
