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

test_direction = (ai,s,data) ->
  for d in data
    ai.direction(s,{mapx:d[0],mapy:d[1]}).should.equals d[2], "#{s.mapx}#{s.mapy},#{d[0]}#{d[1]}=#{d[2]}"


# 価値は何か，誰にとっての価値か，実際の機能は何か
describe 'SampleAITest', () ->
  describe 'Direction', ->
    it 'Direction1 (55)', ->
      ai = new nz.ai.SampleAI()
      s = {mapx:5,mapy:5}
      ai.direction(s,{mapx:5,mapy:4}).should.equals 0, '55,54'
      ai.direction(s,{mapx:6,mapy:4}).should.equals 1, '55.64'
      ai.direction(s,{mapx:6,mapy:5}).should.equals 2, '55,65'
      ai.direction(s,{mapx:5,mapy:6}).should.equals 3, '55.56'
      ai.direction(s,{mapx:4,mapy:5}).should.equals 4, '55.45'
      ai.direction(s,{mapx:4,mapy:4}).should.equals 5, '55,44'
    it 'Direction1 (65)', ->
      ai = new nz.ai.SampleAI()
      s = {mapx:6,mapy:5}
      ai.direction(s,{mapx:6,mapy:4}).should.equals 0, '65,64'
      ai.direction(s,{mapx:7,mapy:5}).should.equals 1, '65.75'
      ai.direction(s,{mapx:7,mapy:6}).should.equals 2, '65,76'
      ai.direction(s,{mapx:6,mapy:6}).should.equals 3, '65.66'
      ai.direction(s,{mapx:5,mapy:6}).should.equals 4, '65.56'
      ai.direction(s,{mapx:5,mapy:5}).should.equals 5, '65,55'
    it 'Direction2 (55)', ->
      ai = new nz.ai.SampleAI()
      s = {mapx:5,mapy:5}
      data = [
        [5,3,0]
        [6,3,1]
        [7,4,1]
        [7,5,2]
        [7,6,2]
        [6,6,2]
        [5,7,3]
        [4,6,4]
        [3,6,4]
        [3,5,4]
        [3,4,5]
        [4,3,5]
      ]
      test_direction(ai,s,data)
  describe 'Distance', ->
    it 'Distance1 (55)', ->
      ai = new nz.ai.SampleAI()
      s = {mapx:5,mapy:5}
      ai.distance(s,{mapx:5,mapy:3}).should.equals 2,'53'
      ai.distance(s,{mapx:5,mapy:4}).should.equals 1,'54'
      ai.distance(s,{mapx:5,mapy:5}).should.equals 0,'55'
      ai.distance(s,{mapx:5,mapy:6}).should.equals 1,'56'
      ai.distance(s,{mapx:5,mapy:7}).should.equals 2,'57'

      ai.distance(s,{mapx:4,mapy:6}).should.equals 2,'46'
      ai.distance(s,{mapx:4,mapy:5}).should.equals 1,'45'
      ai.distance(s,{mapx:4,mapy:4}).should.equals 1,'44'
      ai.distance(s,{mapx:4,mapy:3}).should.equals 2,'43'

      ai.distance(s,{mapx:6,mapy:6}).should.equals 2,'66'
      ai.distance(s,{mapx:6,mapy:5}).should.equals 1,'65'
      ai.distance(s,{mapx:6,mapy:4}).should.equals 1,'64'
      ai.distance(s,{mapx:6,mapy:3}).should.equals 2,'63'

    it 'Distance1 (65)', ->
      ai = new nz.ai.SampleAI()
      s = {mapx:6,mapy:5}
      ai.distance(s,{mapx:6,mapy:3}).should.equals 2,'63'
      ai.distance(s,{mapx:6,mapy:4}).should.equals 1,'64'
      ai.distance(s,{mapx:6,mapy:5}).should.equals 0,'65'
      ai.distance(s,{mapx:6,mapy:6}).should.equals 1,'66'
      ai.distance(s,{mapx:6,mapy:7}).should.equals 2,'67'

      ai.distance(s,{mapx:5,mapy:7}).should.equals 2,'57'
      ai.distance(s,{mapx:5,mapy:6}).should.equals 1,'56'
      ai.distance(s,{mapx:5,mapy:5}).should.equals 1,'55'
      ai.distance(s,{mapx:5,mapy:4}).should.equals 2,'54'

      ai.distance(s,{mapx:7,mapy:7}).should.equals 2,'77'
      ai.distance(s,{mapx:7,mapy:6}).should.equals 1,'76'
      ai.distance(s,{mapx:7,mapy:5}).should.equals 1,'75'
      ai.distance(s,{mapx:7,mapy:4}).should.equals 2,'74'

    it 'Distance2', ->
      ai = new nz.ai.SampleAI()
      s = {mapx:5,mapy:5}
      ai.distance(s,{mapx:5,mapy:2}).should.equals 3,'52'
      ai.distance(s,{mapx:5,mapy:3}).should.equals 2,'53'
      ai.distance(s,{mapx:5,mapy:7}).should.equals 2,'57'
      ai.distance(s,{mapx:5,mapy:8}).should.equals 3,'58'

      ai.distance(s,{mapx:4,mapy:7}).should.equals 3,'47'
      ai.distance(s,{mapx:4,mapy:6}).should.equals 2,'46'
      ai.distance(s,{mapx:4,mapy:3}).should.equals 2,'43'
      ai.distance(s,{mapx:4,mapy:2}).should.equals 3,'42'

      ai.distance(s,{mapx:6,mapy:7}).should.equals 3,'67'
      ai.distance(s,{mapx:6,mapy:6}).should.equals 2,'66'
      ai.distance(s,{mapx:6,mapy:3}).should.equals 2,'63'
      ai.distance(s,{mapx:6,mapy:2}).should.equals 3,'62'

      ai.distance(s,{mapx:3,mapy:7}).should.equals 3,'37'
      ai.distance(s,{mapx:3,mapy:6}).should.equals 2,'36'
      ai.distance(s,{mapx:3,mapy:5}).should.equals 2,'35'
      ai.distance(s,{mapx:3,mapy:4}).should.equals 2,'34'
      ai.distance(s,{mapx:3,mapy:3}).should.equals 3,'33'

      ai.distance(s,{mapx:7,mapy:7}).should.equals 3,'77'
      ai.distance(s,{mapx:7,mapy:6}).should.equals 2,'76'
      ai.distance(s,{mapx:7,mapy:5}).should.equals 2,'75'
      ai.distance(s,{mapx:7,mapy:4}).should.equals 2,'74'
      ai.distance(s,{mapx:7,mapy:3}).should.equals 3,'73'

    it 'Distance3 (55)', ->
      ai = new nz.ai.SampleAI()
      s = {mapx:5,mapy:5}
      ai.distance(s,{mapx:5,mapy:1}).should.equals 4,'51'
      ai.distance(s,{mapx:5,mapy:2}).should.equals 3,'52'
      ai.distance(s,{mapx:5,mapy:8}).should.equals 3,'58'
      ai.distance(s,{mapx:5,mapy:9}).should.equals 4,'59'

      ai.distance(s,{mapx:4,mapy:8}).should.equals 4,'48'
      ai.distance(s,{mapx:4,mapy:7}).should.equals 3,'47'
      ai.distance(s,{mapx:4,mapy:2}).should.equals 3,'42'
      ai.distance(s,{mapx:4,mapy:1}).should.equals 4,'41'

      ai.distance(s,{mapx:6,mapy:8}).should.equals 4,'68'
      ai.distance(s,{mapx:6,mapy:7}).should.equals 3,'67'
      ai.distance(s,{mapx:6,mapy:2}).should.equals 3,'62'
      ai.distance(s,{mapx:6,mapy:1}).should.equals 4,'61'

      ai.distance(s,{mapx:3,mapy:8}).should.equals 4,'38'
      ai.distance(s,{mapx:3,mapy:7}).should.equals 3,'37'
      ai.distance(s,{mapx:3,mapy:3}).should.equals 3,'33'
      ai.distance(s,{mapx:3,mapy:2}).should.equals 4,'32'

      ai.distance(s,{mapx:7,mapy:8}).should.equals 4,'78'
      ai.distance(s,{mapx:7,mapy:7}).should.equals 3,'77'
      ai.distance(s,{mapx:7,mapy:3}).should.equals 3,'73'
      ai.distance(s,{mapx:7,mapy:2}).should.equals 4,'72'

      ai.distance(s,{mapx:2,mapy:7}).should.equals 4,'27'
      ai.distance(s,{mapx:2,mapy:6}).should.equals 3,'26'
      ai.distance(s,{mapx:2,mapy:5}).should.equals 3,'25'
      ai.distance(s,{mapx:2,mapy:4}).should.equals 3,'24'
      ai.distance(s,{mapx:2,mapy:3}).should.equals 3,'23'
      ai.distance(s,{mapx:2,mapy:2}).should.equals 4,'22'

      ai.distance(s,{mapx:8,mapy:7}).should.equals 4,'87'
      ai.distance(s,{mapx:8,mapy:6}).should.equals 3,'86'
      ai.distance(s,{mapx:8,mapy:5}).should.equals 3,'85'
      ai.distance(s,{mapx:8,mapy:4}).should.equals 3,'84'
      ai.distance(s,{mapx:8,mapy:3}).should.equals 3,'83'
      ai.distance(s,{mapx:8,mapy:2}).should.equals 4,'82'

    it 'Distance3 (65)', ->
      ai = new nz.ai.SampleAI()
      s = {mapx:6,mapy:5}
      ai.distance(s,{mapx:6,mapy:1}).should.equals 4,'61'
      ai.distance(s,{mapx:6,mapy:2}).should.equals 3,'62'
      ai.distance(s,{mapx:6,mapy:8}).should.equals 3,'68'
      ai.distance(s,{mapx:6,mapy:9}).should.equals 4,'69'

      ai.distance(s,{mapx:5,mapy:9}).should.equals 4,'59'
      ai.distance(s,{mapx:5,mapy:8}).should.equals 3,'58'
      ai.distance(s,{mapx:5,mapy:3}).should.equals 3,'53'
      ai.distance(s,{mapx:5,mapy:2}).should.equals 4,'52'

      ai.distance(s,{mapx:7,mapy:9}).should.equals 4,'79'
      ai.distance(s,{mapx:7,mapy:8}).should.equals 3,'78'
      ai.distance(s,{mapx:7,mapy:3}).should.equals 3,'73'
      ai.distance(s,{mapx:7,mapy:2}).should.equals 4,'72'

      ai.distance(s,{mapx:4,mapy:8}).should.equals 4,'48'
      ai.distance(s,{mapx:4,mapy:7}).should.equals 3,'47'
      ai.distance(s,{mapx:4,mapy:3}).should.equals 3,'43'
      ai.distance(s,{mapx:4,mapy:2}).should.equals 4,'42'

      ai.distance(s,{mapx:8,mapy:8}).should.equals 4,'88'
      ai.distance(s,{mapx:8,mapy:7}).should.equals 3,'87'
      ai.distance(s,{mapx:8,mapy:3}).should.equals 3,'83'
      ai.distance(s,{mapx:8,mapy:2}).should.equals 4,'82'

      ai.distance(s,{mapx:3,mapy:8}).should.equals 4,'38'
      ai.distance(s,{mapx:3,mapy:7}).should.equals 3,'37'
      ai.distance(s,{mapx:3,mapy:6}).should.equals 3,'36'
      ai.distance(s,{mapx:3,mapy:5}).should.equals 3,'35'
      ai.distance(s,{mapx:3,mapy:4}).should.equals 3,'34'
      ai.distance(s,{mapx:3,mapy:3}).should.equals 4,'33'

      ai.distance(s,{mapx:9,mapy:8}).should.equals 4,'98'
      ai.distance(s,{mapx:9,mapy:7}).should.equals 3,'97'
      ai.distance(s,{mapx:9,mapy:6}).should.equals 3,'96'
      ai.distance(s,{mapx:9,mapy:5}).should.equals 3,'95'
      ai.distance(s,{mapx:9,mapy:4}).should.equals 3,'94'
      ai.distance(s,{mapx:9,mapy:3}).should.equals 4,'93'
