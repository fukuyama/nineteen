# SampleAI.coffee

# node.js と ブラウザでの this.nz を同じインスタンスにする
_g = window ? global
nz = _g.nz = _g.nz ? {}
_g = undefined

nz.ai = nz.ai ? {}

class nz.ai.Base
  ###* 経路探索
  * @param {nz.Graph}     graph  グラフ（マップ情報）
  * @param {nz.Character} source 開始位置のキャラクター
  * @param {nz.Character} target 終了位置のキャラクター
  * @param {Object}       [options] オプション
  * @param {boolean}      [options.closest] 到達できない場合に近くまで探索する場合 true
  ###
  searchRoute: (graph, source, target, options = {closest:true})->
    {direction,mapx,mapy} = source
    return graph.searchRoute(direction, mapx, mapy, target.mapx, target.mapy, options)

  distance: nz.utils.distance

  direction: nz.utils.direction

  checkDirectionRange: nz.utils.checkDirectionRange

  findNearTarget: (c,targets) ->
    result = {
      target: null
      distance: 99
    }
    for t in targets
      d = @distance(c,t)
      if d < result.distance
        result.distance = d
        result.target = t
    return result

class nz.ai.SampleAI extends nz.ai.Base

  constructor: ->
    @rules = [
      {
        # ターゲットと距離を計算
        cond: (param) ->
          {
            character
            characters
            graph
            friends
            targets
            turn
          } = param
          {
            target
            distance
          } = @findNearTarget character, targets
          param.target = target
          param.distance = distance
          return false
      }
      {
        # 距離が４以下の場合
        cond: (param) ->
          {
            distance
          } = param
          return distance <= 4
        # 移動攻撃
        setup: (param) ->
          {
            character
            turn
            graph
            target
          } = param
          route = @searchRoute(graph,character,target)
          character.setAttackCommand(turn)
          character.addMoveCommand(turn,route)
          return true
      }
      {
        # 距離が６以下の場合
        cond: (param) ->
          {
            distance
          } = param
          data = {
            source: character
            target: target
          }
          data[k] = v for k,v of character.shot.range
          return distance <= 6 and @checkDirectionRange(data)
        # 移動射撃
        setup: (param) ->
          {
            character
            turn
            graph
            target
          } = param
          route = @searchRoute(graph,character,target)
          character.setAttackCommand(turn)
          character.addMoveCommand(turn,route)
          return true
      }
      {
        # 距離が６以下の場合
        cond: (param) ->
          {
            distance
          } = param
          return distance <= 6
        # 移動射撃
        setup: (param) ->
          {
            character
            turn
            graph
            target
          } = param
          route = @searchRoute(graph,character,target)
          character.setAttackCommand(turn)
          character.addMoveCommand(turn,route)
          return true
      }
      {
        # 距離が７以上の場合
        cond: (param) ->
          {
            distance
          } = param
          return distance >= 7
        # 近づく
        setup: (param) ->
          {
            character
            turn
            graph
            target
          } = param
          route = @searchRoute(graph,character,target)
          character.addMoveCommand(turn,route)
          return false
      }
    ]

  setupBattlePosition: (param) ->
    console.log 'setupBattlePosition'
    {
      character
      members
      area
    } = param
    i = members.indexOf character
    return area[i]

  setupAction: (param) ->
    console.log 'setupAction'
    {
      character
      characters
    } = param
    friends = []
    targets = []
    for c in characters when c.name != character.name
      if character.team == c.team
        friends.push c
      else
        targets.push c
    param.friends = friends
    param.targets = targets
    for r in @rules
      if r.cond.call(@,param)
        if r.setup?.call(@,param)
          break
    return character

nz.system.addAI 'SampleAI', new nz.ai.SampleAI()
