# SampleAI.coffee

# node.js と ブラウザでの this.nz を同じインスタンスにする
_g = window ? global
nz = _g.nz = _g.nz ? {}
_g = undefined

nz.ai = nz.ai ? {}

class nz.ai.Base

  searchRoute: nz.utils.searchRoute

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
        # 距離が１以下の場合
        cond: (param) ->
          {
            distance
          } = param
          return distance <= 1
        # 移動攻撃して１歩下がる
        setup: (param) ->
          ###
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
          ###
          return true
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
            characters
            turn
            graph
            target
          } = param
          route = @searchRoute(graph,character,target,characters)
          character.setAttackCommand(turn)
          character.addMoveCommand(turn,route)
          return true
      }
      {
        # 距離が６以下で射撃範囲に敵がいる場合
        cond: (param) ->
          {
            distance
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
          return distance <= 6 and @checkDirectionRange(data)
        # 移動射撃
        setup: (param) ->
          {
            character
            turn
            rotation
          } = param
          character.addShotCommand(turn,rotation)
          return true
      }
      {
        # どれでもない時
        cond: (param) ->
          return true
        # 近づく
        setup: (param) ->
          {
            character
            characters
            turn
            graph
            target
          } = param
          route = @searchRoute(graph,character,target,characters)
          character.addMoveCommand(turn,route)
          return false
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
