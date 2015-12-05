# GridNodeTest.coffee

require('chai').should()

require('../../main/coffeescript/nz/GridNode.coffee')

# 価値は何か，誰にとっての価値か，実際の機能は何か
describe 'GridNodeTest', () ->
  describe 'nz.GridNodeWrap', ->
    it 'mapx,mapy', ->
      node = new nz.GridNode(8,9,weight:1)
      wrap = new nz.GridNodeWrap(node)
      wrap.mapx.should.equals 8
      wrap.mapy.should.equals 9
    it '指定ノードへのコスト計算1', ->
      x = 2
      y = 2
      s = new nz.GridNodeWrap(x  ,y  ,weight:1)
      e = new nz.GridNodeWrap(x  ,y-1,weight:1)
      e.getCost(s).should.equals 1,'cost'

  describe 'nz.GridNode', ->
    it 'mapx,mapy', ->
      node = new nz.GridNode(8,9,weight:1)
      node.mapx.should.equals 8
      node.mapy.should.equals 9
    it 'calcDirection', ->
      s = new nz.GridNode(8,8,weight:1)
      e = new nz.GridNode(8,9,weight:1)
      s.calcDirection(e).should.equals 3
    it 'calcDirectionTo', ->
      s = new nz.GridNode(8,8,weight:1)
      e = new nz.GridNode(8,9,weight:1)
      s.calcDirectionTo(e).should.equals 3
    it 'calcDirectionBy', ->
      s = new nz.GridNode(8,8,weight:1)
      e = new nz.GridNode(8,9,weight:1)
      s.calcDirectionBy(e).should.equals 0
