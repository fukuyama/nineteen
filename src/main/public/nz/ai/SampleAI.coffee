# SampleAI.coffee

class SampleAI
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

nz.system.addAI 'SampleAI', new SampleAI()
