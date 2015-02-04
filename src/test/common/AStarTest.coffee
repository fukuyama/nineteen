# AStarTest.coffee

require('chai').should()

{
  astar
  Graph
} = require('../../main/express/public/lib/develop/astar.js')
require('../../main/public/nz/Graph.coffee')

# 価値は何か，誰にとっての価値か，実際の機能は何か
describe 'AStarTest', () ->
  describe 'オリジナル', ->
    it 'サンプル', ->
      graph = new Graph [
        [1,1,1,1]
        [0,1,1,0]
        [0,0,1,1]
      ]
      start = graph.grid[0][0]
      end = graph.grid[1][2]
      result = astar.search(graph, start, end)
      result[0].x.should.equals 0
      result[0].y.should.equals 1
      result[1].x.should.equals 1
      result[1].y.should.equals 1
      result[2].x.should.equals 1
      result[2].y.should.equals 2
  describe '１９', ->
    describe 'nz.Graph', ->
      it '初期化', ->
        chipdata = [
          {
            weight: 1
          }
        ]
        mapdata =
          width:  15 # マップの幅
          height: 15 # マップの高さ
          data: for y in [0 ... 15] then for x in [0 ... 15] then 0

