# ParamTest.coffee

require('chai').should()

require('../../../main/public/nz/System.coffee')
require('../../../main/public/nz/Utils.coffee')
require('../../../main/public/nz/Character.coffee')
require('../../../main/public/nz/ai/Param.coffee')

# 価値は何か，誰にとっての価値か，実際の機能は何か
describe 'nz.ai.ParamTest', () ->

  # --- TEST DATA
  mapdata =
    chipdata: [
      {
        weight: 0
      }
      {
        weight: 1
      }
    ]
    mapdata:
      width:  15 # マップの幅
      height: 15 # マップの高さ
      data: for y in [0 ... 15] then for x in [0 ... 15] then 1
  character = new nz.Character(mapx:5,mapy:5,direction:0,name:'user',team:'X')
  characters = []
  graph = new nz.Graph(mapdata)
  # ---

  reset = ->
    characters = [
      new nz.Character(mapx: 0,mapy: 0,direction:0,name:'char0',team:'A')
      new nz.Character(mapx:10,mapy: 0,direction:0,name:'char1',team:'A')
      new nz.Character(mapx:10,mapy:10,direction:0,name:'char2',team:'B')
      new nz.Character(mapx: 0,mapy:10,direction:0,name:'char3',team:'B')
    ]
  reset()

  describe 'searchTargets', ->
    it 'front', ->
      reset()
      characters[0].mapx = 5
      characters[0].mapy = 4
      param = new nz.ai.Param(
        character:  character
        characters: characters
        graph:      graph
        turn:       1
      )
      r = param.searchTargets(0,6)
      r.length.should.equals 1,'length'
      r[0].name.should.equals 'char0'
    it 'back', ->
      reset()
      characters[1].mapx  = 5
      characters[1].mapy  = 4
      character.direction = 3
      param = new nz.ai.Param(
        character:  character
        characters: characters
        graph:      graph
        turn:       1
      )
      r = param.searchTargets(3,6)
      r.length.should.equals 1,'length'
      r[0].name.should.equals 'char1'
