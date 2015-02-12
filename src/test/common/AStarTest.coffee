# AStarTest.coffee

require('chai').should()

{
  astar
  Graph
} = require('../../main/express/public/lib/develop/astar.js')
require('../../main/public/nz/Graph.coffee')
require('../../main/public/nz/GridNode.coffee')
global.astar = astar

# 価値は何か，誰にとっての価値か，実際の機能は何か
describe 'AStarTest', () ->
  chkxy = (node,x,y) ->
    node.x.should.equals x,"x"
    node.y.should.equals y,"y"
    return

  nz.astar = astar
  options =
    heuristic: nz.Graph.heuristic
  testdata =
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
  describe '１９', ->
    describe 'nz.GridNode', ->
      it '方向転換のコスト計算1', ->
        s = new nz.GridNode(0,0,1)
        s.direction = 1 # 上
        s.getDirectionCost(1).should.equals 0,'1'
        s.getDirectionCost(2).should.equals 1,'2'
        s.getDirectionCost(3).should.equals 2,'3'
        s.getDirectionCost(4).should.equals 3,'4'
        s.getDirectionCost(5).should.equals 2,'5'
        s.getDirectionCost(6).should.equals 1,'6'
      it '方向転換のコスト計算2', ->
        s = new nz.GridNode(0,0)
        s.direction = 2 # 右上
        s.getDirectionCost(1).should.equals 1,'1'
        s.getDirectionCost(2).should.equals 0,'2'
        s.getDirectionCost(3).should.equals 1,'3'
        s.getDirectionCost(4).should.equals 2,'4'
        s.getDirectionCost(5).should.equals 3,'5'
        s.getDirectionCost(6).should.equals 2,'6'
        s.direction = 6 # 左上
        s.getDirectionCost(1).should.equals 1,'7'
        s.getDirectionCost(2).should.equals 2,'8'
        s.getDirectionCost(3).should.equals 3,'9'
        s.getDirectionCost(4).should.equals 2,'a'
        s.getDirectionCost(5).should.equals 1,'b'
        s.getDirectionCost(6).should.equals 0,'c'
      it '方向転換のコスト計算3', ->
        s = new nz.GridNode(0,0)
        s.direction = 3 # 右下
        s.getDirectionCost(1).should.equals 2,'1'
        s.getDirectionCost(2).should.equals 1,'2'
        s.getDirectionCost(3).should.equals 0,'3'
        s.getDirectionCost(4).should.equals 1,'4'
        s.getDirectionCost(5).should.equals 2,'5'
        s.getDirectionCost(6).should.equals 3,'6'
        s.direction = 5 # 左下
        s.getDirectionCost(1).should.equals 2,'7'
        s.getDirectionCost(2).should.equals 3,'8'
        s.getDirectionCost(3).should.equals 2,'9'
        s.getDirectionCost(4).should.equals 1,'a'
        s.getDirectionCost(5).should.equals 0,'b'
        s.getDirectionCost(6).should.equals 1,'c'
      it '方向転換のコスト計算4', ->
        s = new nz.GridNode(0,0)
        s.direction = 4 # 下
        s.getDirectionCost(1).should.equals 3,'1'
        s.getDirectionCost(2).should.equals 2,'2'
        s.getDirectionCost(3).should.equals 1,'3'
        s.getDirectionCost(4).should.equals 0,'4'
        s.getDirectionCost(5).should.equals 1,'5'
        s.getDirectionCost(6).should.equals 2,'6'

      it '隣接ノードの方向1', ->
        x = 2
        y = 2
        s = new nz.GridNode(x,y)
        s.calcDirection(new nz.GridNode(x  ,y-1)).should.equals 1
        s.calcDirection(new nz.GridNode(x  ,y+1)).should.equals 4
        s.calcDirection(new nz.GridNode(x-1,y  )).should.equals 6
        s.calcDirection(new nz.GridNode(x-1,y+1)).should.equals 5
        s.calcDirection(new nz.GridNode(x+1,y  )).should.equals 2
        s.calcDirection(new nz.GridNode(x+1,y+1)).should.equals 3

        s = new nz.GridNode(0,0)
        s.calcDirection(new nz.GridNode(1  ,1  )).should.equals 3
      it '隣接ノードの方向2', ->
        x = 3
        y = 2
        s = new nz.GridNode(x,y)
        s.calcDirection(new nz.GridNode(x  ,y-1)).should.equals 1
        s.calcDirection(new nz.GridNode(x  ,y+1)).should.equals 4
        s.calcDirection(new nz.GridNode(x-1,y-1)).should.equals 6
        s.calcDirection(new nz.GridNode(x-1,y  )).should.equals 5
        s.calcDirection(new nz.GridNode(x+1,y-1)).should.equals 2
        s.calcDirection(new nz.GridNode(x+1,y  )).should.equals 3

    describe 'nz.GridNode', ->
      it '指定ノードへのコスト計算1', ->
        x = 2
        y = 2
        s = new nz.GridNode(x  ,y  ,weight:1)
        e = new nz.GridNode(x  ,y-1,weight:1)
        s.direction = 1
        direction = s.calcDirection(e)
        direction.should.equals 1,'direction'
        s.getDirectionCost(direction).should.equals 0,'direction cost'
        e.getCost(s).should.equals 1,'cost'

    describe 'nz.Graph', ->
      describe 'ヒューリスティック関数', ->
        it 'ヒューリスティック関数1', ->
          s = new nz.GridNode(1,1,weight:1)
          s.direction = 1
          e = new nz.GridNode(2,1,weight:1)
          result = nz.Graph.heuristic(s,e)
          result.should.equals 3
        it 'ヒューリスティック関数2', ->
          s = new nz.GridNode(0,0,weight:1)
          s.direction = 1
          e = new nz.GridNode(0,1,weight:1)
          result = nz.Graph.heuristic(s,e)
          result.should.equals 4
        it 'ヒューリスティック関数3', ->
          s = new nz.GridNode(10,10,weight:1)
          s.direction = 6
          e = new nz.GridNode(9,10,weight:1)
          result = nz.Graph.heuristic(s,e)
          result.should.equals 1
        it 'ヒューリスティック関数4', ->
          s = new nz.GridNode(10,10,weight:1)
          s.direction = 6
          e = new nz.GridNode(4,7,weight:1)
          result = nz.Graph.heuristic(s,e)
          result.should.equals 6

      describe '隣接ノード', ->
        it '角', ->
          graph = new nz.Graph(testdata)
          result = graph.neighbors graph.grid[0][0]
          result.length.should.equals 3, 'length'
      describe 'ルート検索', ->
        route_search_test = (s,e,r) ->
          graph = new nz.Graph(testdata)
          start = graph.grid[s.x][s.y]
          end = graph.grid[e.x][e.y]
          start.direction = s.dir
          result = astar.search(graph, start, end, options)
          result.length.should.equals r.len,'length'
          for pos,i in r.route
            chkxy result[i],pos[0],pos[1]
          end.g.should.equals r.cost
          end.direction.should.equals r.dir,'direction'

        it '上1', ->
          route_search_test(
            {x:10,y:10,dir:1}
            {x:10,y:5}
            {
              len: 5
              cost: 5
              dir: 1
              route: [
                [10,9]
                [10,8]
                [10,7]
                [10,6]
                [10,5]
              ]
            }
          )
        it '上2', ->
          route_search_test(
            {x:10,y:10,dir:1}
            {x:9,y:5}
            {
              len: 6
              cost: 7
              dir: 6
              route: [
                [10,9]
                [10,8]
                [10,7]
                [10,6]
                [10,5]
                [9,5]
              ]
            }
          )
        it '上3', ->
          route_search_test(
            {x:10,y:10,dir:1}
            {x:9,y:4}
            {
              len: 7
              cost: 8
              dir: 6
              route: [
                [10,9]
                [10,8]
                [10,7]
                [10,6]
                [10,5]
                [10,4]
                [9,4]
              ]
            }
          )
        it '下', ->
          graph = new nz.Graph(testdata)
          start = graph.grid[0][0]
          end = graph.grid[0][1]
          start.direction = 4
          result = astar.search(graph, start, end, options)
          result.length.should.equals 1,'length'
          result[0].x.should.equals 0
          result[0].y.should.equals 1
          end.g.should.equals 1
          end.direction.should.equals 4,'direction'

          end = graph.grid[0][2]
          graph.init()
          start.direction = 4
          result = astar.search(graph, start, end, options)
          result.length.should.equals 2,'length'
          result[0].x.should.equals 0
          result[0].y.should.equals 1
          result[1].x.should.equals 0
          result[1].y.should.equals 2
          end.g.should.equals 2
        it '右下', ->
          graph = new nz.Graph(testdata)
          start = graph.grid[0][0]
          end = graph.grid[1][1]
          start.direction = 4
          result = astar.search(graph, start, end, options)
          result.length.should.equals 1,'length'
          result[0].x.should.equals 1
          result[0].y.should.equals 1
          end.direction.should.equals 3,'direction'

          end = graph.grid[1][2]
          graph.init()
          start.direction = 4
          result = astar.search(graph, start, end, options)
          result.length.should.equals 2,'length'
          result[0].x.should.equals 0
          result[0].y.should.equals 1
          result[1].x.should.equals 1
          result[1].y.should.equals 2
          end.g.should.equals 3

          end = graph.grid[1][2]
          graph.init()
          start.direction = 3
          result = astar.search(graph, start, end, options)
          result.length.should.equals 2,'length'
          result[0].x.should.equals 1
          result[0].y.should.equals 1
          result[1].x.should.equals 1
          result[1].y.should.equals 2

          end = graph.grid[1][2]
          graph.init()
          start.direction = 2
          result = astar.search(graph, start, end, options)
          result.length.should.equals 2,'length'
          result[0].x.should.equals 1
          result[0].y.should.equals 1
          result[1].x.should.equals 1
          result[1].y.should.equals 2

          start = graph.grid[1][0]
          end = graph.grid[2][0]
          graph.init()
          start.direction = 4
          result = astar.search(graph, start, end, options)
          result.length.should.equals 1,'length'
          result[0].x.should.equals 2
          result[0].y.should.equals 0

          end = graph.grid[2][1]
          graph.init()
          start.direction = 4
          result = astar.search(graph, start, end, options)
          result.length.should.equals 2,'length'
          result[0].x.should.equals 1
          result[0].y.should.equals 1
          result[1].x.should.equals 2
          result[1].y.should.equals 1

          end = graph.grid[2][1]
          graph.init()
          start.direction = 3
          result = astar.search(graph, start, end, options)
          result.length.should.equals 2,'length'
          result[0].x.should.equals 2
          result[0].y.should.equals 0
          result[1].x.should.equals 2
          result[1].y.should.equals 1
