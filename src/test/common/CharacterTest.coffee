# CharacterTest.coffee

require('chai').should()

require('../../main/public/nz/System.coffee')
require('../../main/public/nz/Utils.coffee')
require('../../main/public/nz/Character.coffee')

# 価値は何か，誰にとっての価値か，実際の機能は何か
describe 'nz.CharacterTest', () ->
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
