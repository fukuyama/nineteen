###*
* @file Sample.coffee
* サンプルAI
###

# node.js と ブラウザでの this.nz を同じインスタンスにする
_g = window ? global
nz = _g.nz = _g.nz ? {}
_g = undefined

nz.ai = nz.ai ? {}

class nz.ai.Sample

  setupBattlePosition: (o) -> @defaultAI.setupBattlePosition o
  setupAction: (o) -> @ruleAI.setupAction o
  rule: (o) -> @ruleAI.add o

  ###* 初期化
  * @classdesc サンプルAIクラス
  * @constructor nz.ai.Sample
  ###
  constructor: ->
    @defaultAI = new nz.ai.Default()
    @ruleAI    = new nz.ai.Rule(@)

    @rule
      cond: (param) ->
        # 距離が１以下で後ろに移動ができる場合
        return param.distance <= 1 and param.checkBackPosition()
      setup: (param) ->
        # 下がりつつ攻撃
        param.setAttackCommand()
        param.setMoveBackCommand(10)
        return true
    @rule
      cond: (param) ->
        # 距離が４以下の場合
        return param.distance <= 4
      setup: (param) ->
        # ターゲットに移動攻撃
        param.setAttackCommand()
        param.setMoveCommand()
        return true
    @rule
      cond: (param) ->
        # 距離が６以下で射撃範囲にターゲットがいる場合
        return param.distance <= 6 and param.checkShotRange()
      setup: (param) ->
        # 移動射撃
        param.setShotCommand()
        param.setMoveBackCommand(5)
        return true
    @rule
      cond: (param) ->
        # どれでもない時
        return true
      setup: (param) ->
        # 近づく
        param.setMoveCommand()
        return true

nz.system.addAI 'SampleAI', new nz.ai.SampleAI()
