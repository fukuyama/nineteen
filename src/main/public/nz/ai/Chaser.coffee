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

  ###* 初期化
  * @classdesc サンプルAIクラス
  * @constructor nz.ai.Chaser
  ###
  constructor: ->
    @defaultAI = new nz.ai.Default()
    @ruleAI    = new nz.ai.Rule(@)

    @rule
      cond: (param) ->
        # どれでもない時
        return true
      setup: (param) ->
        #console.log "turn #{param.turn} rule 3"
        # 近づく
        param.setMoveCommand(length:3)
        return true

nz.system.addAI 'Chaser', new nz.ai.Chaser()
