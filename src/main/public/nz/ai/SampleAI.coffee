# SampleAI.coffee

# node.js と ブラウザでの this.nz を同じインスタンスにする
_g = window ? global
nz = _g.nz = _g.nz ? {}
_g = undefined

nz.ai = nz.ai ? {}

class nz.ai.SampleAI

  constructor: ->
    @rules = [
      {
        cond: (param) ->
          # 距離が１以下で後ろに移動ができる場合
          return param.distance <= 1 and param.checkBackPosition()
        setup: (param) ->
          # １歩下がりつつ攻撃
          param.target = param.backPosition
          param.setAttackCommand()
          return true
      }
      {
        cond: (param) ->
          # 距離が４以下の場合
          return param.distance <= 4
        setup: (param) ->
          # ターゲットに移動攻撃
          param.setAttackCommand()
          return true
      }
      {
        cond: (param) ->
          # 距離が６以下で射撃範囲にターゲットがいる場合
          return param.distance <= 6 and param.checkShotRange()
        setup: (param) ->
          # 移動射撃
          param.setShotCommand()
          return true
      }
      {
        cond: (param) ->
          # どれでもない時
          return true
        setup: (param) ->
          # 近づく
          param.setMoveCommand()
          return true
      }
    ]

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
    console.log 'setupAction ' + param.character.name
    for r in @rules
      if r.cond.call(@,param)
        if r.setup?.call(@,param)
          break
    return

nz.system.addAI 'SampleAI', new nz.ai.SampleAI()
