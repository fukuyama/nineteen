###*
* @file Rule.coffee
* ルールベースのAIクラス
###

# node.js と ブラウザでの this.nz を同じインスタンスにする
_g = window ? global
nz = _g.nz = _g.nz ? {}
_g = undefined

nz.ai = nz.ai ? {}

class nz.ai.Rule

  ###* 初期化
  * @classdesc ルールベースのAIクラス
  * @constructor nz.ai.Rule
  ###
  constructor: (caller) ->
    @_caller = caller
    @rules   = []

  add: (rule) ->
    @rules.push rule

  ###* 戦闘行動設定
  * @param　{nz.ai.Param} param 設定用パラメータ
  ###
  setupAction: (param) ->
    for r in @rules
      if r.cond.call(@_caller,param)
        if r.setup?.call(@_caller,param)
          break
    return
