# CharacterTest.coffee

require('chai').should()

require('../../main/public/nz/System.coffee')
require('../../main/public/nz/Utils.coffee')
require('../../main/public/nz/Character.coffee')

# 価値は何か，誰にとっての価値か，実際の機能は何か
describe 'nz.CharacterTest', () ->
  describe 'common', () ->
    it 'name', ->
      c1 = new nz.Character()
      c1.name.should.equals 'テストキャラクター'
      c1.name = 'testname'
      c1.name.should.equals 'testname'
      c2 = new nz.Character()
      c2.name.should.equals 'テストキャラクター'
      c1.name = 'testname1'
      c1.name.should.equals 'testname1'
    it 'move.speed', ->
      c1 = new nz.Character()
      c1.move.speed.should.equals 300
      c1.move.speed = 200
      c1.move.speed.should.equals 200
      c2 = new nz.Character()
      c2.move.speed.should.equals 300
      c1.move.speed = 200
      c1.move.speed.should.equals 200

  describe 'command', () ->
    c = null
    it 'addMoveCommand 1', ->
      route = [
        {mapx:0,mapy:1,cost:1,back:false,direction:3}
        {mapx:0,mapy:1,cost:2,back:false,direction:2}
        {mapx:1,mapy:2,cost:3,back:false,direction:2}
      ]
      c = new nz.Character(mapx:0,mapy:0,direction:3)
      c.addMoveCommand(0,route)
      c.getActionCost(0).should.equals 3
      actions = c.commands[0].actions
      actions.length.should.equals 3
      actions[0].cost.should.equals 1
      actions[1].cost.should.equals 1
      actions[2].cost.should.equals 1
    it 'clearMoveCommand 1', ->
      c.clearMoveCommand(0)
      c.getActionCost(0).should.equals 0
      actions = c.commands[0].actions
      actions.length.should.equals 0
    it 'addMoveCommand 2', ->
      route = [
        {mapx:0,mapy:1,cost:1,back:false,direction:3}
        {mapx:0,mapy:1,cost:2,back:false,direction:2}
        {mapx:1,mapy:2,cost:4,back:false,direction:2}
      ]
      c = new nz.Character(mapx:0,mapy:0,direction:3)
      c.addMoveCommand(0,route)
      c.getActionCost(0).should.equals 4
      actions = c.commands[0].actions
      actions.length.should.equals 3
      actions[0].cost.should.equals 1
      actions[1].cost.should.equals 1
      actions[2].cost.should.equals 2
    it 'addShotCommand 1', ->
      c.addShotCommand(0,0)
      c.getActionCost(0).should.equals 6
    it 'clearMoveCommand 2', ->
      c.clearMoveCommand(0)
      c.getActionCost(0).should.equals 2
      actions = c.commands[0].actions
      actions.length.should.equals 1
    it 'clearShotCommand 1', ->
      c.clearShotCommand(0)
      c.getActionCost(0).should.equals 0
      actions = c.commands[0].actions
      actions.length.should.equals 0
