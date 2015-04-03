# SampleAITest.coffee

require('chai').should()

# node.js と ブラウザでの this.nz を同じインスタンスにする
_g = window ? global
nz = _g.nz = _g.nz ? {}
_g = undefined

nz.system = {
  addAI: ->
    return
  ai: {}
}

require('../../../../main/public/nz/ai/SampleAI.coffee')

# 価値は何か，誰にとっての価値か，実際の機能は何か
describe 'SampleAITest', () ->
  describe 'Distance', ->
    it 'Distance1 (55)', ->
      ai = new nz.ai.SampleAI()
      s = {x:5,y:5}
      ai.calcDistance(s,{x:5,y:3}).should.equals 2,'53'
      ai.calcDistance(s,{x:5,y:4}).should.equals 1,'54'
      ai.calcDistance(s,{x:5,y:5}).should.equals 0,'55'
      ai.calcDistance(s,{x:5,y:6}).should.equals 1,'56'
      ai.calcDistance(s,{x:5,y:7}).should.equals 2,'57'

      ai.calcDistance(s,{x:4,y:6}).should.equals 2,'46'
      ai.calcDistance(s,{x:4,y:5}).should.equals 1,'45'
      ai.calcDistance(s,{x:4,y:4}).should.equals 1,'44'
      ai.calcDistance(s,{x:4,y:3}).should.equals 2,'43'

      ai.calcDistance(s,{x:6,y:6}).should.equals 2,'66'
      ai.calcDistance(s,{x:6,y:5}).should.equals 1,'65'
      ai.calcDistance(s,{x:6,y:4}).should.equals 1,'64'
      ai.calcDistance(s,{x:6,y:3}).should.equals 2,'63'

    it 'Distance1 (65)', ->
      ai = new nz.ai.SampleAI()
      s = {x:6,y:5}
      ai.calcDistance(s,{x:6,y:3}).should.equals 2,'63'
      ai.calcDistance(s,{x:6,y:4}).should.equals 1,'64'
      ai.calcDistance(s,{x:6,y:5}).should.equals 0,'65'
      ai.calcDistance(s,{x:6,y:6}).should.equals 1,'66'
      ai.calcDistance(s,{x:6,y:7}).should.equals 2,'67'

      ai.calcDistance(s,{x:5,y:7}).should.equals 2,'57'
      ai.calcDistance(s,{x:5,y:6}).should.equals 1,'56'
      ai.calcDistance(s,{x:5,y:5}).should.equals 1,'55'
      ai.calcDistance(s,{x:5,y:4}).should.equals 2,'54'

      ai.calcDistance(s,{x:7,y:7}).should.equals 2,'77'
      ai.calcDistance(s,{x:7,y:6}).should.equals 1,'76'
      ai.calcDistance(s,{x:7,y:5}).should.equals 1,'75'
      ai.calcDistance(s,{x:7,y:4}).should.equals 2,'74'

    it 'Distance2', ->
      ai = new nz.ai.SampleAI()
      s = {x:5,y:5}
      ai.calcDistance(s,{x:5,y:2}).should.equals 3,'52'
      ai.calcDistance(s,{x:5,y:3}).should.equals 2,'53'
      ai.calcDistance(s,{x:5,y:7}).should.equals 2,'57'
      ai.calcDistance(s,{x:5,y:8}).should.equals 3,'58'

      ai.calcDistance(s,{x:4,y:7}).should.equals 3,'47'
      ai.calcDistance(s,{x:4,y:6}).should.equals 2,'46'
      ai.calcDistance(s,{x:4,y:3}).should.equals 2,'43'
      ai.calcDistance(s,{x:4,y:2}).should.equals 3,'42'

      ai.calcDistance(s,{x:6,y:7}).should.equals 3,'67'
      ai.calcDistance(s,{x:6,y:6}).should.equals 2,'66'
      ai.calcDistance(s,{x:6,y:3}).should.equals 2,'63'
      ai.calcDistance(s,{x:6,y:2}).should.equals 3,'62'

      ai.calcDistance(s,{x:3,y:7}).should.equals 3,'37'
      ai.calcDistance(s,{x:3,y:6}).should.equals 2,'36'
      ai.calcDistance(s,{x:3,y:5}).should.equals 2,'35'
      ai.calcDistance(s,{x:3,y:4}).should.equals 2,'34'
      ai.calcDistance(s,{x:3,y:3}).should.equals 3,'33'

      ai.calcDistance(s,{x:7,y:7}).should.equals 3,'77'
      ai.calcDistance(s,{x:7,y:6}).should.equals 2,'76'
      ai.calcDistance(s,{x:7,y:5}).should.equals 2,'75'
      ai.calcDistance(s,{x:7,y:4}).should.equals 2,'74'
      ai.calcDistance(s,{x:7,y:3}).should.equals 3,'73'

    it 'Distance3 (55)', ->
      ai = new nz.ai.SampleAI()
      s = {x:5,y:5}
      ai.calcDistance(s,{x:5,y:1}).should.equals 4,'51'
      ai.calcDistance(s,{x:5,y:2}).should.equals 3,'52'
      ai.calcDistance(s,{x:5,y:8}).should.equals 3,'58'
      ai.calcDistance(s,{x:5,y:9}).should.equals 4,'59'

      ai.calcDistance(s,{x:4,y:8}).should.equals 4,'48'
      ai.calcDistance(s,{x:4,y:7}).should.equals 3,'47'
      ai.calcDistance(s,{x:4,y:2}).should.equals 3,'42'
      ai.calcDistance(s,{x:4,y:1}).should.equals 4,'41'

      ai.calcDistance(s,{x:6,y:8}).should.equals 4,'68'
      ai.calcDistance(s,{x:6,y:7}).should.equals 3,'67'
      ai.calcDistance(s,{x:6,y:2}).should.equals 3,'62'
      ai.calcDistance(s,{x:6,y:1}).should.equals 4,'61'

      ai.calcDistance(s,{x:3,y:8}).should.equals 4,'38'
      ai.calcDistance(s,{x:3,y:7}).should.equals 3,'37'
      ai.calcDistance(s,{x:3,y:3}).should.equals 3,'33'
      ai.calcDistance(s,{x:3,y:2}).should.equals 4,'32'

      ai.calcDistance(s,{x:7,y:8}).should.equals 4,'78'
      ai.calcDistance(s,{x:7,y:7}).should.equals 3,'77'
      ai.calcDistance(s,{x:7,y:3}).should.equals 3,'73'
      ai.calcDistance(s,{x:7,y:2}).should.equals 4,'72'

      ai.calcDistance(s,{x:2,y:7}).should.equals 4,'27'
      ai.calcDistance(s,{x:2,y:6}).should.equals 3,'26'
      ai.calcDistance(s,{x:2,y:5}).should.equals 3,'25'
      ai.calcDistance(s,{x:2,y:4}).should.equals 3,'24'
      ai.calcDistance(s,{x:2,y:3}).should.equals 3,'23'
      ai.calcDistance(s,{x:2,y:2}).should.equals 4,'22'

      ai.calcDistance(s,{x:8,y:7}).should.equals 4,'87'
      ai.calcDistance(s,{x:8,y:6}).should.equals 3,'86'
      ai.calcDistance(s,{x:8,y:5}).should.equals 3,'85'
      ai.calcDistance(s,{x:8,y:4}).should.equals 3,'84'
      ai.calcDistance(s,{x:8,y:3}).should.equals 3,'83'
      ai.calcDistance(s,{x:8,y:2}).should.equals 4,'82'

    it 'Distance3 (65)', ->
      ai = new nz.ai.SampleAI()
      s = {x:6,y:5}
      ai.calcDistance(s,{x:6,y:1}).should.equals 4,'61'
      ai.calcDistance(s,{x:6,y:2}).should.equals 3,'62'
      ai.calcDistance(s,{x:6,y:8}).should.equals 3,'68'
      ai.calcDistance(s,{x:6,y:9}).should.equals 4,'69'

      ai.calcDistance(s,{x:5,y:9}).should.equals 4,'59'
      ai.calcDistance(s,{x:5,y:8}).should.equals 3,'58'
      ai.calcDistance(s,{x:5,y:3}).should.equals 3,'53'
      ai.calcDistance(s,{x:5,y:2}).should.equals 4,'52'

      ai.calcDistance(s,{x:7,y:9}).should.equals 4,'79'
      ai.calcDistance(s,{x:7,y:8}).should.equals 3,'78'
      ai.calcDistance(s,{x:7,y:3}).should.equals 3,'73'
      ai.calcDistance(s,{x:7,y:2}).should.equals 4,'72'

      ai.calcDistance(s,{x:4,y:8}).should.equals 4,'48'
      ai.calcDistance(s,{x:4,y:7}).should.equals 3,'47'
      ai.calcDistance(s,{x:4,y:3}).should.equals 3,'43'
      ai.calcDistance(s,{x:4,y:2}).should.equals 4,'42'

      ai.calcDistance(s,{x:8,y:8}).should.equals 4,'88'
      ai.calcDistance(s,{x:8,y:7}).should.equals 3,'87'
      ai.calcDistance(s,{x:8,y:3}).should.equals 3,'83'
      ai.calcDistance(s,{x:8,y:2}).should.equals 4,'82'

      ai.calcDistance(s,{x:3,y:8}).should.equals 4,'38'
      ai.calcDistance(s,{x:3,y:7}).should.equals 3,'37'
      ai.calcDistance(s,{x:3,y:6}).should.equals 3,'36'
      ai.calcDistance(s,{x:3,y:5}).should.equals 3,'35'
      ai.calcDistance(s,{x:3,y:4}).should.equals 3,'34'
      ai.calcDistance(s,{x:3,y:3}).should.equals 4,'33'

      ai.calcDistance(s,{x:9,y:8}).should.equals 4,'98'
      ai.calcDistance(s,{x:9,y:7}).should.equals 3,'97'
      ai.calcDistance(s,{x:9,y:6}).should.equals 3,'96'
      ai.calcDistance(s,{x:9,y:5}).should.equals 3,'95'
      ai.calcDistance(s,{x:9,y:4}).should.equals 3,'94'
      ai.calcDistance(s,{x:9,y:3}).should.equals 4,'93'
