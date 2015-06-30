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

  describe 'getHexPosition', ->
    checkPosition = (n,src,test) ->
      src.mapx.should.equals test.mapx,"(#{n})mapx"
      src.mapy.should.equals test.mapy,"(#{n})mapy"
    it 'default', ->
      reset()
      character.mapx = 6
      character.mapy = 6
      param = new nz.ai.Param(
        character:  character
        characters: characters
        graph:      graph
        turn:       1
      )
      res = param.getHexPosition()
      res.length.should.equals 6
      checkPosition(0,res[0],{mapx: 6,mapy: 0})
      checkPosition(1,res[1],{mapx: 6,mapy:12})
      checkPosition(2,res[2],{mapx: 0,mapy: 3})
      checkPosition(3,res[3],{mapx: 0,mapy: 9})
      checkPosition(4,res[4],{mapx:12,mapy: 3})
      checkPosition(5,res[5],{mapx:12,mapy: 9})
    it 'pos 6,6 len 5', ->
      reset()
      character.mapx = 6
      character.mapy = 6
      param = new nz.ai.Param(
        character:  character
        characters: characters
        graph:      graph
        turn:       1
      )
      res = param.getHexPosition(5)
      res.length.should.equals 6
      checkPosition(0,res[0],{mapx: 6,mapy: 1})
      checkPosition(1,res[1],{mapx: 6,mapy:11})
      checkPosition(2,res[2],{mapx: 1,mapy: 4})
      checkPosition(3,res[3],{mapx: 1,mapy: 9})
      checkPosition(4,res[4],{mapx:11,mapy: 4})
      checkPosition(5,res[5],{mapx:11,mapy: 9})
    it 'pos 7,7 len 5', ->
      reset()
      character.mapx = 7
      character.mapy = 7
      param = new nz.ai.Param(
        character:  character
        characters: characters
        graph:      graph
        turn:       1
      )
      res = param.getHexPosition(5)
      res.length.should.equals 6
      checkPosition(0,res[0],{mapx: 7,mapy: 2})
      checkPosition(1,res[1],{mapx: 7,mapy:12})
      checkPosition(2,res[2],{mapx: 2,mapy: 4})
      checkPosition(3,res[3],{mapx: 2,mapy: 9})
      checkPosition(4,res[4],{mapx:12,mapy: 4})
      checkPosition(5,res[5],{mapx:12,mapy: 9})
    it 'pos 1,1 len 5', ->
      reset()
      character.mapx = 1
      character.mapy = 1
      param = new nz.ai.Param(
        character:  character
        characters: characters
        graph:      graph
        turn:       1
      )
      res = param.getHexPosition(5)
      res.length.should.equals 2
      checkPosition(0,res[0],{mapx: 1,mapy: 6})
      checkPosition(1,res[1],{mapx: 6,mapy: 3})
