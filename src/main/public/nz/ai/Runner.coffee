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

  ###* 戦闘開始位置設定
  * @param  {Object}         param           設定用パラメータ
  * @param  {nz.Character}   param.character 設定対象のキャラクター
  * @param  {nz.Character[]} param.friends   設定対象を含む味方のキャラクター配列
  * @param  {Object[]}       param.area      開始位置情報の配列(mapdata.start.area)
  * @return {Object[]}       対象キャラクターの位置を、param.area の配列から１つ選択し返す
  ###
  setupBattlePosition: (param) ->
    {
      character
      friends
      area
    } = param
    console.log 'setupBattlePosition ' + character.name
    i = friends.indexOf character
    return area[i]

  ###* 戦闘行動設定
  * @param　{nz.ai.Param} param 設定用パラメータ
  ###
  setupAction: (param) ->
    {
      character
    } = param
    console.log 'setupAction ' + character.name
    m = Math.rand(2, 6)
    param.setMoveFrontCommand(m)
    d = Math.rand(-2, 2)
    param.setRotateCommand(d)
    m = Math.rand(2, 6)
    param.setMoveFrontCommand(m)
    return

nz.system.addAI 'Runner', new nz.ai.Runner()
