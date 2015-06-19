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
        mapx = 1
        mapy = 1
        
        m = 4 * 32
        t = tm.geom.Vector2().setObject nz.utils.mapxy2screenxy param.target
        s = tm.geom.Vector2().setObject nz.utils.mapxy2screenxy param.chracter
        d = s.distance t
        r = s.sub(t).toAngle() - m / d
        g = tm.geom.Vector2().setRadian(r,d).add(t)

        param.setMoveCommand(mapx:mapx,mapy:mapy)
        return true
    @addRule
      cond: (param) ->
        # 距離が８以下で射撃範囲にターゲットがいる場合
        return param.distance <= 8 and param.checkShotRange()
      setup: (param) ->
        # 移動射撃
        param.setShotCommand()
        param.setBackCommand(5)
        return true
    @addRule
      cond: (param) ->
        # どれでもない時
        return true
      setup: (param) ->
        # 近づく
        param.setMoveCommand()
        return true

nz.system.addAI 'SampleAI', new nz.ai.SampleAI()
