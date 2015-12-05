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

  ###* 初期化
  * マップ上を走り回るだけのAI
  * @classdesc ランナーAIクラス
  * @constructor nz.ai.Runner
  ###
  constructor: ->
    @defaultAI = new nz.ai.Default()

  setupBattlePosition: (o) -> @defaultAI.setupBattlePosition o

  ###* 戦闘行動設定
  * @param　{nz.ai.Param} param 設定用パラメータ
  ###
  setupAction: (param) ->
    {
      character
    } = param
    m = Math.rand(2, 6)
    ms = param.getHexPosition(m)
    if ms.length isnt 0
      ms.shuffle()
      param.setMoveCommand(target:ms[0])
    m = 6 - m
    if m > 0
      ms = param.getHexPosition(m)
      if ms.length isnt 0
        ms.shuffle()
        param.setMoveCommand(target:ms[0])
    return

nz.system.addAI 'Runner', new nz.ai.Runner()
