# SampleAI.coffee

class SampleAI
  setupBattlePosition: (character,members,area) ->
    console.log 'setupBattlePosition'
    i = members.indexOf character
    console.log area[i]
    return

nz.system.addAI 'SampleAI', new SampleAI()
