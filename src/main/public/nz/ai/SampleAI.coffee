# SampleAI.coffee

# node.js と ブラウザでの this.nz を同じインスタンスにする
_g = window ? global
nz = _g.nz = _g.nz ? {}
_g = undefined

nz.ai = nz.ai ? {}

class nz.ai.Base

  searchRoute: nz.utils.searchRoute

  distance: nz.Graph.distance

  direction: nz.Graph.direction

  checkDirectionRange: nz.utils.checkDirectionRange

  checkShotRange: (param) ->
    {
      character
      target
    } = param
    data = {
      source: character
      target: target
      range: character.shot.range
      callback: (res,r) ->
        param.rotation = r if res
    }
    return @checkDirectionRange(data)

  checkBackPosition: (param) ->
    {
      graph
      character
      characters
    } = param
    r = nz.Graph.backPosition character
    node = graph.grid[r.mapx][r.mapy]
    unless node?
      return false
    if node.isWall()
      return false
    for c in characters
      if c.mapx is r.mapx and c.mapy is r.mapy
        return false
    return true

  backPosition: (param) ->
    return nz.Graph.backPosition param.character

  setMoveCommand: (param) ->
    {
      character
      characters
      turn
      graph
      target
    } = param
    route = @searchRoute(graph,character,target,characters)
    character.addMoveCommand(turn,route)
    return

  setAttackCommand: (param) ->
    {
      character
      characters
      turn
      graph
      target
    } = param
    route = @searchRoute(graph,character,target,characters)
    character.setAttackCommand(turn)
    character.addMoveCommand(turn,route)
    return

  setShotCommand: (param) ->
    {
      character
      characters
      turn
      graph
      target
      rotation
    } = param
    route = @searchRoute(graph,character,target,characters)
    character.addShotCommand(turn,rotation)
    character.addMoveCommand(turn,route)
    return

  findNearTarget: (param) ->
    {
      character
      targets
    } = param
    result = {
      target: null
      distance: 99
    }
    for t in targets
      d = @distance(character,t)
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
          r = @findNearTarget param
          param.target   = r.target
          param.distance = r.distance
          return false
      }
      {
        # 距離が１以下で後ろに移動ができる場合
        cond: (param) ->
          return param.distance <= 1 and @checkBackPosition param
        # １歩下がりつつ攻撃
        setup: (param) ->
          param.target = @backPosition param
          @setAttackCommand param
          return true
      }
      {
        # 距離が４以下の場合
        cond: (param) ->
          return param.distance <= 4
        # ターゲットに移動攻撃
        setup: (param) ->
          @setAttackCommand param
          return true
      }
      {
        # 距離が６以下で射撃範囲にターゲットがいる場合
        cond: (param) ->
          return param.distance <= 6 and @checkShotRange param
        # 移動射撃
        setup: (param) ->
          @setShotCommand param
          return true
      }
      {
        # どれでもない時
        cond: (param) ->
          return true
        # 近づく
        setup: (param) ->
          @setMoveCommand param
          return true
      }
    ]

  setupBattlePosition: (param) ->
    {
      character
      members
      area
    } = param
    console.log 'setupBattlePosition ' + character.name
    i = members.indexOf character
    return area[i]

  setupAction: (param) ->
    {
      character
      characters
    } = param
    console.log 'setupAction ' + character.name
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
