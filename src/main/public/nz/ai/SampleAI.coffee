# SampleAI.coffee

# node.js と ブラウザでの this.nz を同じインスタンスにする
_g = window ? global
nz = _g.nz = _g.nz ? {}
_g = undefined

nz.ai = nz.ai ? {}

class nz.ai.SampleAI


  calcDistance: (node1,node2) ->
    dist = 0
    hx = Math.abs(node1.x - node2.x)
    hy = Math.abs(node1.y - node2.y)
    hr = Math.ceil(hx / 2)
    if hx % 2 == 1
      if node1.x % 2 == 1
        if hy <= hr
          if node1.y < node2.y
            hy -= hr
          else
            hy = 0
        else
          hy -= hr
        dist = hx + hy
      else
        dist = hx + hy
    else
      if hy <= hr
        hy = 0
      else
        hy -= hr
      dist = hx + hy
    dist

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
      graph
    } = param
    return

nz.system.addAI 'SampleAI', new nz.ai.SampleAI()
