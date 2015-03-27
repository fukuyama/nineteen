# SampleAI.coffee

class SampleAI
  setupBattlePosition: (character,members,area) ->
    console.log 'setupBattlePosition'
    return

nz.system.addAI 'SampleAI', new SampleAI()
