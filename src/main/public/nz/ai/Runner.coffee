###*
* @file Runner.coffee
* ランナーAI
###

# node.js と ブラウザでの this.nz を同じインスタンスにする
_g = window ? global
nz = _g.nz = _g.nz ? {}
_g = undefined

nz.ai = nz.ai ? {}

class nz.ai.Runner

  setupBattlePosition: (o) -> @defaultAI.setupBattlePosition o

  ###* 初期化
  * マップ上を走り回るだけのAI
  * @classdesc ランナーAIクラス
  * @constructor nz.ai.Runner
  ###
  constructor: ->
    @defaultAI = new nz.ai.Default()

  ###* 戦闘行動設定
  * @param　{nz.ai.Param} param 設定用パラメータ
  ###
  setupAction: (param) ->
    {
      character
    } = param
    m = Math.rand(2, 6)
    param.setMoveFrontCommand(m)
    d = Math.rand(-2, 2)
    param.setRotateCommand(d)
    m = Math.rand(2, 6)
    param.setMoveFrontCommand(m)
    return

nz.system.addAI 'Runner', new nz.ai.Runner()
