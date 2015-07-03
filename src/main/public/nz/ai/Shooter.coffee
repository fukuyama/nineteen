###*
* @file Shooter.coffee
* シューターAI
###

# node.js と ブラウザでの this.nz を同じインスタンスにする
_g = window ? global
nz = _g.nz = _g.nz ? {}
_g = undefined

nz.ai = nz.ai ? {}

class nz.ai.Shooter

  setupBattlePosition: (o) -> @defaultAI.setupBattlePosition o
  setupAction: (o) -> @ruleAI.setupAction o
  rule: (o) -> @ruleAI.add o

  calcSlidePosition: (param) ->
    {
      target
      character
      length
    } = param
    m = length * 32
    # ターゲット
    t = tm.geom.Vector2().setObject nz.utils.mapxy2screenxy target
    # 自分の位置
    s = tm.geom.Vector2().setObject nz.utils.mapxy2screenxy character
    # ターゲットまでの距離
    d = s.distance t
    # ターゲットからの方向
    r = s.sub(t).toAngle()
    # 移動後の方向
    r -= m / d
    # 目的値
    g = tm.geom.Vector2().setRadian(r,d).add(t)
    a = nz.utils.screenxy2mapxy g
    #console.log "t=#{t} s=#{s} d=#{d} r=#{r} g=#{g} a.mapx=#{a.mapx} a.mapy=#{a.mapy}"
    return a

  ###* 初期化
  * @classdesc サンプルAIクラス
  * @constructor nz.ai.Shooter
  ###
  constructor: ->
    @defaultAI = new nz.ai.Default()
    @ruleAI    = new nz.ai.Rule(@)

    @rule
      cond: (param) ->
        # 距離が６以下で射撃範囲にターゲットがいる場合
        return param.distance <= 6 and param.checkShotRange()
      setup: (param) ->
        #console.log "turn #{param.turn} rule 1"
        # 射撃移動
        param.setShotCommand()
        # TODO: 座標計算＆壁計算も
        p = @calcSlidePosition
          target: param.target
          character: param.character
          length: 4
        if param.checkMovePosition p
          param.setMoveCommand(target:p)
        else
          param.setMoveBackCommand(2)
        return true
    @rule
      cond: (param) ->
        # 距離が８以下で射撃範囲にターゲットがいる場合
        return param.distance <= 8 and param.checkShotRange()
      setup: (param) ->
        #console.log "turn #{param.turn} rule 2"
        # 移動射撃
        param.setShotCommand()
        param.setMoveBackCommand(5)
        return true
    @rule
      cond: (param) ->
        # 距離が８以下
        return param.distance <= 8
      setup: (param) ->
        #console.log "turn #{param.turn} rule 3"
        p = @calcSlidePosition
          target: param.target
          character: param.character
          length: 3
        if param.checkMovePosition p
          param.setMoveCommand(target:p)
        else
          param.setMoveBackCommand(2)
        return true
    @rule
      cond: (param) ->
        # どれでもない時
        return true
      setup: (param) ->
        #console.log "turn #{param.turn} rule 3"
        # 近づく
        param.setMoveCommand(length:3)
        return true

nz.system.addAI 'Shooter', new nz.ai.Shooter()
