###*
* @file Shooter.coffee
* シューターAI
###

# node.js と ブラウザでの this.nz を同じインスタンスにする
_g = window ? global
nz = _g.nz = _g.nz ? {}
_g = undefined

nz.ai = nz.ai ? {}

class nz.ai.Shooter　extends　nz.ai.RuleBaseAI

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
    s = tm.geom.Vector2().setObject nz.utils.mapxy2screenxy chracter
    # ターゲットまでの距離
    d = s.distance t
    # ターゲットからの方向
    r = s.sub(t).toAngle()
    # 移動後の方向
    r -= m / d
    # 目的値
    g = tm.geom.Vector2().setRadian(r,d).add(t)
    return nz.utils.screenxy2mapxy g

  ###* 初期化
  * @classdesc サンプルAIクラス
  * @constructor nz.ai.SampleAI
  ###
  constructor: ->
    super()
    @addRule
      cond: (param) ->
        # 距離が４以下で射撃範囲にターゲットがいる場合
        return param.distance <= 4 and param.checkShotRange()
      setup: (param) ->
        # 射撃移動
        param.setShotCommand()
        # 移動先は、相手の位置から同じ距離を保ちつつ左に回り込む
        # TODO: 座標計算＆壁計算も
        p = @calcSlidePosition
          target: param.target
          character: param.character
          length: 4
        param.setMoveCommand(p)
        return true
    @addRule
      cond: (param) ->
        # 距離が８以下で射撃範囲にターゲットがいる場合
        return param.distance <= 8 and param.checkShotRange()
      setup: (param) ->
        # 移動射撃
        param.setShotCommand()
        param.setMoveBackCommand(5)
        return true
    @addRule
      cond: (param) ->
        # どれでもない時
        return true
      setup: (param) ->
        # 近づく
        param.setMoveCommand()
        return true

nz.system.addAI 'Shooter', new nz.ai.Shooter()
