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
        cond: (param) ->
          {
            distance
          } = param
          return distance <= 4
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
          return
      }
      {
        cond: (param) ->
          {
            distance
          } = param
          return distance >= 7
        setup: (param) ->
          {
            character
            turn
            graph
            target
          } = param
          route = @searchRoute(graph,character,target)
          character.addMoveCommand(turn,route)
          return
      }
    ]

  searchRoute : (graph,character,target)->
    {direction,mapx,mapy} = character
    graph.searchRoute(direction, mapx, mapy, target.mapx, target.mapy)

  distance: (c1,c2) ->
    hx = Math.abs(c1.mapx - c2.mapx)
    hy = Math.abs(c1.mapy - c2.mapy)
    hr = Math.ceil(hx / 2)
    return hx if hy < hr
    if hx % 2 == 1
      if c1.mapx % 2 == 1
        if c1.mapy <= c2.mapy
          hy += 1
      else
        if c1.mapy >= c2.mapy
          hy += 1
    return hx + hy - hr

  direction = (c1,c2) ->
    d = 0
    if c1.mapx == c2.mapx
      d = 0 if c1.mapy > c2.mapy
      d = 3 if c1.mapy < c2.mapy
    else if c1.mapx > c2.mapx # 左側
      if c1.mapy == c2.mapy
        d = if c1.mapx % 2 == 0 then 5 else 4
      else if c1.mapy > c2.mapy
        d = 5
      else if c1.mapy < c2.mapy
        d = 4
    else if c1.mapx < c2.mapx # 右側
      if c1.mapy == c2.mapy
        d = if c1.mapx % 2 == 0 then 1 else 2
      else if c1.mapy > c2.mapy
        d = 1
      else if c1.mapy < c2.mapy
        d = 2
    return d

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
