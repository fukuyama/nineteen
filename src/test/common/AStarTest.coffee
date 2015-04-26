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
  chkxy = (node,x,y,i) ->
    node.x.should.equals x,"x #{i}"
    node.y.should.equals y,"y #{i}"
    return
  chkmapxy = (node,x,y,i) ->
    node.mapx.should.equals x,"x #{i}"
    node.mapy.should.equals y,"y #{i}"
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
        s = new nz.GridNode(0,0)
        s.direction = 0 # 上
        s.getDirectionCost(0).should.equals 0,'0'
        s.getDirectionCost(1).should.equals 1,'1'
        s.getDirectionCost(2).should.equals 2,'2'
        s.getDirectionCost(3).should.equals 3,'3'
        s.getDirectionCost(4).should.equals 2,'4'
        s.getDirectionCost(5).should.equals 1,'5'
      it '方向転換のコスト計算2', ->
        s = new nz.GridNode(0,0)
        s.direction = 1 # 右上
        s.getDirectionCost(0).should.equals 1,'0'
        s.getDirectionCost(1).should.equals 0,'1'
        s.getDirectionCost(2).should.equals 1,'2'
        s.getDirectionCost(3).should.equals 2,'3'
        s.getDirectionCost(4).should.equals 3,'4'
        s.getDirectionCost(5).should.equals 2,'5'
        s.direction = 5 # 左上
        s.getDirectionCost(0).should.equals 1,'0`'
        s.getDirectionCost(1).should.equals 2,'1`'
        s.getDirectionCost(2).should.equals 3,'2`'
        s.getDirectionCost(3).should.equals 2,'3`'
        s.getDirectionCost(4).should.equals 1,'4`'
        s.getDirectionCost(5).should.equals 0,'5`'
      it '方向転換のコスト計算3', ->
        s = new nz.GridNode(0,0)
        s.direction = 2 # 右下
        s.getDirectionCost(0).should.equals 2,'0'
        s.getDirectionCost(1).should.equals 1,'1'
        s.getDirectionCost(2).should.equals 0,'2'
        s.getDirectionCost(3).should.equals 1,'3'
        s.getDirectionCost(4).should.equals 2,'4'
        s.getDirectionCost(5).should.equals 3,'5'
        s.direction = 4 # 左下
        s.getDirectionCost(0).should.equals 2,'0`'
        s.getDirectionCost(1).should.equals 3,'1`'
        s.getDirectionCost(2).should.equals 2,'2`'
        s.getDirectionCost(3).should.equals 1,'3`'
        s.getDirectionCost(4).should.equals 0,'4`'
        s.getDirectionCost(5).should.equals 1,'5`'
      it '方向転換のコスト計算4', ->
        s = new nz.GridNode(0,0)
        s.direction = 3 # 下
        s.getDirectionCost(0).should.equals 3,'0'
        s.getDirectionCost(1).should.equals 2,'1'
        s.getDirectionCost(2).should.equals 1,'2'
        s.getDirectionCost(3).should.equals 0,'3'
        s.getDirectionCost(4).should.equals 1,'4'
        s.getDirectionCost(5).should.equals 2,'5'

      it '隣接ノードの方向1', ->
        x = 2
        y = 2
        s = new nz.GridNode(x,y)
        s.calcDirection(new nz.GridNode(x  ,y-1)).should.equals 0
        s.calcDirection(new nz.GridNode(x  ,y+1)).should.equals 3
        s.calcDirection(new nz.GridNode(x-1,y  )).should.equals 5
        s.calcDirection(new nz.GridNode(x-1,y+1)).should.equals 4
        s.calcDirection(new nz.GridNode(x+1,y  )).should.equals 1
        s.calcDirection(new nz.GridNode(x+1,y+1)).should.equals 2

        s = new nz.GridNode(0,0)
        s.calcDirection(new nz.GridNode(1  ,1  )).should.equals 2
      it '隣接ノードの方向2', ->
        x = 3
        y = 2
        s = new nz.GridNode(x,y)
        s.calcDirection(new nz.GridNode(x  ,y-1)).should.equals 0
        s.calcDirection(new nz.GridNode(x  ,y+1)).should.equals 3
        s.calcDirection(new nz.GridNode(x-1,y-1)).should.equals 5
        s.calcDirection(new nz.GridNode(x-1,y  )).should.equals 4
        s.calcDirection(new nz.GridNode(x+1,y-1)).should.equals 1
        s.calcDirection(new nz.GridNode(x+1,y  )).should.equals 2

    describe 'nz.GridNode', ->
      it '指定ノードへのコスト計算1', ->
        x = 2
        y = 2
        s = new nz.GridNode(x  ,y  ,weight:1)
        e = new nz.GridNode(x  ,y-1,weight:1)
        s.direction = 0
        direction = s.calcDirection(e)
        direction.should.equals 0,'direction'
        s.getDirectionCost(direction).should.equals 0,'direction cost'
        e.getCost(s).should.equals 1,'cost'

    describe 'nz.Graph', ->
      describe 'ヒューリスティック関数', ->
        it 'ヒューリスティック関数1', ->
          s = new nz.GridNode(5,5,weight:1)
          data = [
            [5,4,1]
            [6,4,2]
            [6,5,3]
            [5,6,4]
            [4,5,3]
            [4,4,2]
          ]
          s.direction = 0
          for d,i in data
            e = new nz.GridNode(d[0],d[1],weight:1)
            result = nz.Graph.heuristic(s,e)
            result.should.equals d[2], "a #{i}=#{d[2]}"
        it 'ヒューリスティック関数1-1', ->
          s = new nz.GridNode(5,4,weight:1)
          data = [
            [5,3,2]
            [6,3,1]
            [6,4,2]
            [5,5,3]
            [4,4,4]
            [4,3,3]
          ]
          s.direction = 1
          for d,i in data
            e = new nz.GridNode(d[0],d[1],weight:1)
            result = nz.Graph.heuristic(s,e)
            result.should.equals d[2], "a #{i}=#{d[2]}"
        it 'ヒューリスティック関数2', ->
          s = new nz.GridNode(0,0,weight:1)
          s.direction = 0
          e = new nz.GridNode(0,1,weight:1)
          result = nz.Graph.heuristic(s,e)
          result.should.equals 4
        it 'ヒューリスティック関数3', ->
          s = new nz.GridNode(10,10,weight:1)
          s.direction = 5
          e = new nz.GridNode(9,10,weight:1)
          result = nz.Graph.heuristic(s,e)
          result.should.equals 1
        it 'ヒューリスティック関数4', ->
          s = new nz.GridNode(10,10,weight:1)
          s.direction = 5
          e = new nz.GridNode(4,7,weight:1)
          result = nz.Graph.heuristic(s,e)
          result.should.equals 6
        it 'ヒューリスティック関数5', ->
          s = new nz.GridNode(10,6,weight:1)
          s.direction = 5
          e = new nz.GridNode(7,7,weight:1)
          result = nz.Graph.heuristic(s,e)
          result.should.equals 4
        it 'ヒューリスティック関数5-1', ->
          s = new nz.GridNode(9,6,weight:1)
          s.direction = 5
          e = new nz.GridNode(7,7,weight:1)
          result = nz.Graph.heuristic(s,e)
          result.should.equals 3
        it 'ヒューリスティック関数5-2', ->
          s = new nz.GridNode(9,7,weight:1)
          s.direction = 5
          e = new nz.GridNode(7,7,weight:1)
          result = s.calcDirection(e)
          result.should.equals 4,'calcDirection'
          result = nz.Graph.heuristic(s,e)
          result.should.equals 3,'heuristic'
        it 'ヒューリスティック関数6', ->
          s = new nz.GridNode(13,8,weight:1)
          s.direction = 5
          e = new nz.GridNode(7,7,weight:1)
          result = nz.Graph.heuristic(s,e)
          result.should.equals 7
        it 'ヒューリスティック関数7', ->
          s = new nz.GridNode(3,9,weight:1)
          s.direction = 2
          e = new nz.GridNode(7,6,weight:1)
          result = nz.Graph.heuristic(s,e)
          result.should.equals 6
        it 'ヒューリスティック関数8', ->
          s = new nz.GridNode(3,8,weight:1)
          s.direction = 2
          e = new nz.GridNode(7,5,weight:1)
          result = nz.Graph.heuristic(s,e)
          result.should.equals 6

      describe '隣接ノード', ->
        it '角', ->
          graph = new nz.Graph(testdata)
          result = graph.neighbors graph.grid[0][0]
          result.length.should.equals 3, 'length'
      describe 'ルート検索', ->
        route_search_test = (s,e,r,graph,op={}) ->
          graph = new nz.Graph(testdata) unless graph?
          result = graph.searchRoute(s.dir,s.x,s.y,e.x,e.y,op)
          #start = graph.grid[s.x][s.y]
          end = graph.grid[e.x][e.y]
          #start.direction = s.dir
          #result = astar.search(graph, start, end, options)
          result.length.should.equals r.len,'length'
          for pos,i in r.route
            chkmapxy result[i],pos[0],pos[1],i
            result[i].cost.should.equals r.costs[i],'costs' if r.costs?[i]?
          end.g.should.equals r.cost,'cost'
          end.direction.should.equals r.dir,'direction'
          #graph.clear()
          return graph
        it.skip 'Debug 1', ->
          console.log 'Debug1'
          route_search_test(
            {x:3,y:12,dir:0}
            {x:7,y:9}
            {
              len: 5
              cost: 6
              dir: 1
              route: [
                [3,11]
                [4,10]
                [5,10]
                [6,9]
                [7,9]
              ]
            }
            undefined
            {closest:true}
          )
      describe.skip 'ルート検索', ->
        it 'ほぼ真横の移動', ->
          # まだうまく行かない 2015/02/14
          route_search_test(
            {x:13,y:8,dir:5}
            {x:7,y:7}
            {
              len: 6
              cost: 7
              dir: 4
              route: [
                [12,7]
                [11,7]
                [10,6]
                [9,6]
                [8,6]
                [7,7]
              ]
            }
          )
        it 'ほぼ真横の移動切り出し', ->
          # まだうまく行かない 2015/02/14
          route_search_test(
            {x:10,y:6,dir:5}
            {x:7,y:7}
            {
              len: 3
              cost: 4
              dir: 4
              route: [
                [9,6]
                [8,6]
                [7,7]
              ]
            }
          )
        it '上1', ->
          route_search_test(
            {x:10,y:10,dir:0}
            {x:10,y:5}
            {
              len: 5
              cost: 5
              costs: [1,2,3,4,5]
              dir: 0
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
            {x:10,y:10,dir:0}
            {x:9,y:5}
            {
              len: 6
              cost: 7
              costs: [1,2,3,4,5,7]
              dir: 5
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
            {x:10,y:10,dir:0}
            {x:9,y:4}
            {
              len: 7
              cost: 8
              dir: 5
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
        it '下 reuse', ->
          graph = route_search_test(
            {x:0,y:0,dir:3}
            {x:0,y:1}
            {
              len: 1
              cost: 1
              dir: 3
              route: [
                [0,1]
              ]
            }
          )
          route_search_test(
            {x:0,y:0,dir:3}
            {x:0,y:2}
            {
              len: 2
              cost: 2
              dir: 3
              route: [
                [0,1]
                [0,2]
              ]
            }
            graph
          )
        it '右下', ->
          graph = route_search_test(
            {x:0,y:0,dir:3}
            {x:1,y:1}
            {
              len: 1
              cost: 2
              dir: 2
              route: [
                [1,1]
              ]
            }
          )
          route_search_test(
            {x:0,y:0,dir:3}
            {x:1,y:2}
            {
              len: 2
              cost: 3
              dir: 2
              route: [
                [0,1]
                [1,2]
              ]
            }
            graph
          )
          route_search_test(
            {x:0,y:0,dir:2}
            {x:1,y:2}
            {
              len: 2
              cost: 3
              dir: 3
              route: [
                [1,1]
                [1,2]
              ]
            }
            graph
          )
          route_search_test(
            {x:0,y:0,dir:2}
            {x:1,y:2}
            {
              len: 2
              cost: 3
              dir: 3
              route: [
                [1,1]
                [1,2]
              ]
            }
            graph
          )
          route_search_test(
            {x:1,y:0,dir:2}
            {x:2,y:0}
            {
              len: 1
              cost: 1
              dir: 2
              route: [
                [2,0]
              ]
            }
            graph
          )
          route_search_test(
            {x:1,y:0,dir:3}
            {x:2,y:0}
            {
              len: 1
              cost: 2
              dir: 2
              route: [
                [2,0]
              ]
            }
            graph
          )
          route_search_test(
            {x:1,y:0,dir:3}
            {x:2,y:1}
            {
              len: 2
              cost: 3
              dir: 2
              route: [
                [1,1]
                [2,1]
              ]
            }
            graph
          )
          route_search_test(
            {x:1,y:0,dir:2}
            {x:2,y:1}
            {
              len: 2
              cost: 3
              dir: 3
              route: [
                [2,0]
                [2,1]
              ]
            }
            graph
          )
        it '移動不可', ->
          data =
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
          data.mapdata.data[5][5] = 0
          graph = new nz.Graph(data)
          route_search_test(
            {x:1,y:0,dir:2}
            {x:5,y:5}
            {
              len: 0
              cost: 0
              dir: 0
              route: []
            }
            graph
          )
          graph.dirtyNodes.length.should.equals 0
