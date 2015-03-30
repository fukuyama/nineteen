# SampleAI.coffee

class SampleAI
  setupBattlePosition: (param) ->
    {
      character
      members
      area
    } = param
    i = members.indexOf character
    return area[i]

  setupAction: (param) ->
    {
      character
      characters
      graph
    } = param
    return

nz.system.addAI 'SampleAI', new SampleAI()
