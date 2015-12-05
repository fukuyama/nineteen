###*
* @file Default.coffee
* デフォルトAI
###

# node.js と ブラウザでの this.nz を同じインスタンスにする
_g = window ? global
nz = _g.nz = _g.nz ? {}
_g = undefined

nz.ai = nz.ai ? {}

class nz.ai.Default

  ###* 初期化
  * @classdesc デフォルトAIクラス
  * @constructor nz.ai.Default
  ###
  constructor: ->

  ###* 戦闘開始位置設定
  * @memberof nz.ai.Default#
  * @method setupBattlePosition
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
    i = friends.indexOf character
    return area[i]

  ###* 戦闘行動設定
  * @memberof nz.ai.Default#
  * @method setupBattlePosition
  * @param　{nz.ai.Param} param 設定用パラメータ
  ###
  setupAction: (param) ->
    return

nz.system.addAI 'Default', new nz.ai.Default()
