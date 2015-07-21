###*
* @file Chaser.coffee
* チェイサーAI
###

# node.js と ブラウザでの this.nz を同じインスタンスにする
_g = window ? global
nz = _g.nz = _g.nz ? {}
_g = undefined

nz.ai = nz.ai ? {}

class nz.ai.Chaser

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
    r += m / d
    # 目的値
    g = tm.geom.Vector2().setRadian(r,d).add(t)
    a = nz.utils.screenxy2mapxy g
    return a

  ###* 初期化
  * @classdesc サンプルAIクラス
  * @constructor nz.ai.Chaser
  ###
  constructor: ->
    @defaultAI = new nz.ai.Default()
    @ruleAI    = new nz.ai.Rule(@)

    @rule
      cond: (param) ->
        # 敵味方分け
        param.setFriendsAndTargets()
        param.setNearTarget()
        return false
    @rule
      cond: (param) ->
        p = @calcSlidePosition
          target: param.target
          character: param.character
          length: 2
        if param.checkMovePosition(p) and param.distance <= 4
          return true
        return false
      setup: (param) ->
        p = @calcSlidePosition
          target: param.target
          character: param.character
          length: 2
        param.setAttackCommand()
        param.setMoveCommand(target:p)
        return true
    @rule
      cond: (param) ->
        # どれでもない時
        return true
      setup: (param) ->
        # 近づく
        param.setMoveCommand(length:2)
        return true

nz.system.addAI 'Chaser', new nz.ai.Chaser()
