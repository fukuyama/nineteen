# UtilsTest.coffee

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

require('../../main/public/nz/System.coffee')
require('../../main/public/nz/GridNode.coffee')
require('../../main/public/nz/Utils.coffee')

lineRouteTest = (p1,p2,data ... ) ->
  ret = nz.utils.lineRoute(
    {
      mapx:p1[0]
      mapy:p1[1]
    }
    {
      mapx:p2[0]
      mapy:p2[1]
    }
  )
  ret.length.should.equals data.length, 'length'
  for r,i in ret
    x = data[i][0]
    y = data[i][1]
    r.mapx.should.equals x,"index #{i}[#{x},#{y}]: x #{x}: [#{r.mapx},#{r.mapy}]"
    r.mapy.should.equals y,"index #{i}[#{x},#{y}]: y #{y}: [#{r.mapx},#{r.mapy}]"
  return

# 価値は何か，誰にとっての価値か，実際の機能は何か
describe 'UtilsTest', () ->
  #describe 'searchRoute 1', () ->
  #  it '', ->

  describe 'nz.GridNode', ->
    it '方向転換のコスト計算1', ->
      nz.utils.calcDirectionCost(0,0).should.equals 0,'0'
      nz.utils.calcDirectionCost(0,1).should.equals 1,'1'
      nz.utils.calcDirectionCost(0,2).should.equals 2,'2'
      nz.utils.calcDirectionCost(0,3).should.equals 3,'3'
      nz.utils.calcDirectionCost(0,4).should.equals 2,'4'
      nz.utils.calcDirectionCost(0,5).should.equals 1,'5'
    it '方向転換のコスト計算2', ->
      nz.utils.calcDirectionCost(1,0).should.equals 1,'0'
      nz.utils.calcDirectionCost(1,1).should.equals 0,'1'
      nz.utils.calcDirectionCost(1,2).should.equals 1,'2'
      nz.utils.calcDirectionCost(1,3).should.equals 2,'3'
      nz.utils.calcDirectionCost(1,4).should.equals 3,'4'
      nz.utils.calcDirectionCost(1,5).should.equals 2,'5'
      nz.utils.calcDirectionCost(5,0).should.equals 1,'0`'
      nz.utils.calcDirectionCost(5,1).should.equals 2,'1`'
      nz.utils.calcDirectionCost(5,2).should.equals 3,'2`'
      nz.utils.calcDirectionCost(5,3).should.equals 2,'3`'
      nz.utils.calcDirectionCost(5,4).should.equals 1,'4`'
      nz.utils.calcDirectionCost(5,5).should.equals 0,'5`'
    it '方向転換のコスト計算3', ->
      nz.utils.calcDirectionCost(2,0).should.equals 2,'0'
      nz.utils.calcDirectionCost(2,1).should.equals 1,'1'
      nz.utils.calcDirectionCost(2,2).should.equals 0,'2'
      nz.utils.calcDirectionCost(2,3).should.equals 1,'3'
      nz.utils.calcDirectionCost(2,4).should.equals 2,'4'
      nz.utils.calcDirectionCost(2,5).should.equals 3,'5'
      nz.utils.calcDirectionCost(4,0).should.equals 2,'0`'
      nz.utils.calcDirectionCost(4,1).should.equals 3,'1`'
      nz.utils.calcDirectionCost(4,2).should.equals 2,'2`'
      nz.utils.calcDirectionCost(4,3).should.equals 1,'3`'
      nz.utils.calcDirectionCost(4,4).should.equals 0,'4`'
      nz.utils.calcDirectionCost(4,5).should.equals 1,'5`'
    it '方向転換のコスト計算4', ->
      nz.utils.calcDirectionCost(3,0).should.equals 3,'0'
      nz.utils.calcDirectionCost(3,1).should.equals 2,'1'
      nz.utils.calcDirectionCost(3,2).should.equals 1,'2'
      nz.utils.calcDirectionCost(3,3).should.equals 0,'3'
      nz.utils.calcDirectionCost(3,4).should.equals 1,'4'
      nz.utils.calcDirectionCost(3,5).should.equals 2,'5'

    it '隣接ノードの方向0', ->
      node = new nz.GridNode(0,0)
      nz.utils.direction(node,new nz.GridNode(1  ,1  )).should.equals 2
    it '隣接ノードの方向1', ->
      x = 2
      y = 2
      node = new nz.GridNode(x,y)
      nz.utils.direction(node,new nz.GridNode(x  ,y-1)).should.equals 0
      nz.utils.direction(node,new nz.GridNode(x  ,y+1)).should.equals 3
      nz.utils.direction(node,new nz.GridNode(x-1,y  )).should.equals 5
      nz.utils.direction(node,new nz.GridNode(x-1,y+1)).should.equals 4
      nz.utils.direction(node,new nz.GridNode(x+1,y  )).should.equals 1
      nz.utils.direction(node,new nz.GridNode(x+1,y+1)).should.equals 2
    it '隣接ノードの方向2', ->
      x = 3
      y = 2
      node = new nz.GridNode(x,y)
      nz.utils.direction(node,new nz.GridNode(x  ,y-1)).should.equals 0
      nz.utils.direction(node,new nz.GridNode(x  ,y+1)).should.equals 3
      nz.utils.direction(node,new nz.GridNode(x-1,y-1)).should.equals 5
      nz.utils.direction(node,new nz.GridNode(x-1,y  )).should.equals 4
      nz.utils.direction(node,new nz.GridNode(x+1,y-1)).should.equals 1
      nz.utils.direction(node,new nz.GridNode(x+1,y  )).should.equals 2

  describe 'lineRoute 1', () ->
    it '(5,5),(5,6)', ->
      lineRouteTest [5,5],[5,6],[5,5],[5,6]
    it '(5,5),(5,4)', ->
      lineRouteTest [5,5],[5,4],[5,5],[5,4]
    it '(5,5),(6,5)', ->
      lineRouteTest [5,5],[6,5],[5,5],[6,5]
    it '(5,5),(6,4)', ->
      lineRouteTest [5,5],[6,4],[5,5],[6,4]
    it '(5,5),(4,5)', ->
      lineRouteTest [5,5],[4,5],[5,5],[4,5]
    it '(5,5),(4,4)', ->
      lineRouteTest [5,5],[4,4],[5,5],[4,4]
  describe 'lineRoute 2', () ->
    it '(5,5),(5,3)', ->
      lineRouteTest [5,5],[5,3],[5,5],[5,4],[5,3]
    it '(5,5),(4,3)', ->
      lineRouteTest [5,5],[4,3],[5,5],[5,4],[4,3]
    it '(5,5),(3,4)', ->
      lineRouteTest [5,5],[3,4],[5,5],[4,4],[3,4]
    it '(5,5),(3,5)', ->
      lineRouteTest [5,5],[3,5],[5,5],[4,5],[3,5]
    it '(5,5),(3,6)', ->
      lineRouteTest [5,5],[3,6],[5,5],[4,5],[3,6]
    it '(5,5),(4,6)', ->
      lineRouteTest [5,5],[4,6],[5,5],[4,5],[4,6]
    it '(5,5),(5,7)', ->
      lineRouteTest [5,5],[5,7],[5,5],[5,6],[5,7]
    it '(5,5),(6,6)', ->
      lineRouteTest [5,5],[6,6],[5,5],[6,5],[6,6]
    it '(5,5),(7,6)', ->
      lineRouteTest [5,5],[7,6],[5,5],[6,5],[7,6]
    it '(5,5),(7,5)', ->
      lineRouteTest [5,5],[7,5],[5,5],[6,5],[7,5]
    it '(5,5),(7,4)', ->
      lineRouteTest [5,5],[7,4],[5,5],[6,4],[7,4]
    it '(5,5),(6,3)', ->
      lineRouteTest [5,5],[6,3],[5,5],[6,4],[6,3]
  describe 'lineRoute 3', () ->
    it '(5,5),(5,2)', ->
      lineRouteTest [5,5],[5,2],[5,5],[5,4],[5,3],[5,2]
    it '(5,5),(4,2)', ->
      lineRouteTest [5,5],[4,2],[5,5],[5,4],[4,3],[4,2]
    it '(5,5),(3,3)', ->
      lineRouteTest [5,5],[3,3],[5,5],[4,4],[3,4],[3,3]
    it '(5,5),(6,7)', ->
      lineRouteTest [5,5],[6,7],[5,5],[5,6],[6,6],[6,7]
