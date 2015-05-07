# AStarTest.coffee

require('chai').should()

{
  astar
  Graph
} = require('../../main/express/public/lib/develop/astar.js')
global.astar = astar

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
      result.length.should.equals 3
      result[0].x.should.equals 0
      result[0].y.should.equals 1
      result[1].x.should.equals 1
      result[1].y.should.equals 1
      result[2].x.should.equals 1
      result[2].y.should.equals 2
