# GraphTest.coffee

require('chai').should()

{
  astar
  Graph
} = require('../../main/express/public/lib/develop/astar.js')
require('../../main/public/nz/Graph.coffee')
require('../../main/public/nz/GridNode.coffee')
global.astar = astar

# 価値は何か，誰にとっての価値か，実際の機能は何か
describe 'GraphTest', () ->

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

  chkmapxy = (node,x,y,i) ->
    node.mapx.should.equals x,"x #{i}"
    node.mapy.should.equals y,"y #{i}"
    return
  route_search_test = (s,e,r,graph,op={}) ->
    graph = new nz.Graph(testdata) unless graph?
    result = graph.searchRoute(s.dir,s.x,s.y,e.x,e.y,op)
    result.length.should.equals r.len,'length'
    for pos,i in r.route
      [mapx,mapy,dir,back] = pos
      chkmapxy result[i],mapx,mapy,i
      result[i].direction.should.equals dir, 'r dir' if dir?
      result[i].back.should.equals back, 'r back' if back?
      result[i].cost.should.equals r.costs[i],'costs' if r.costs?[i]?
    if result.length != 0
      end = result[r.len - 1]
      end.cost.should.equals r.cost, 'end cost'
      end.direction.should.equals r.dir, 'end dir'
    return graph
  describe 'nz.Graph', ->
    describe 'backPosition', ->
      it '5,5,0', ->
        r = nz.Graph.backPosition(5,5,0)
        r.mapx.should.equals 5,'5'
        r.mapy.should.equals 6,'6'
        r.direction.should.equals 0,'0'
        r = nz.Graph.backPosition direction:0,mapx:5,mapy:5
        r.mapx.should.equals 5,'5'
        r.mapy.should.equals 6,'6'
        r.direction.should.equals 0,'0'
      it '5,5,3', ->
        r = nz.Graph.backPosition direction:3,mapx:5,mapy:5
        r.mapx.should.equals 5,'5'
        r.mapy.should.equals 4,'4'
        r.direction.should.equals 3,'3'
      it '6,5,3', ->
        r = nz.Graph.backPosition direction:3,mapx:6,mapy:5
        r.mapx.should.equals 6,'6'
        r.mapy.should.equals 4,'4'
        r.direction.should.equals 3,'3'
      it '5,5,1', ->
        r = nz.Graph.backPosition direction:1,mapx:5,mapy:5
        r.mapx.should.equals 4,'4'
        r.mapy.should.equals 5,'5'
        r.direction.should.equals 1,'1'
      it '6,5,1', ->
        r = nz.Graph.backPosition direction:1,mapx:6,mapy:5
        r.mapx.should.equals 5,'5'
        r.mapy.should.equals 6,'6'
        r.direction.should.equals 1,'1'
      it '5,5,5', ->
        r = nz.Graph.backPosition direction:5,mapx:5,mapy:5
        r.mapx.should.equals 6,'6'
        r.mapy.should.equals 5,'5'
        r.direction.should.equals 5,'5'
      it '6,5,5', ->
        r = nz.Graph.backPosition direction:5,mapx:6,mapy:5
        r.mapx.should.equals 7,'7'
        r.mapy.should.equals 6,'6'
        r.direction.should.equals 5,'5'
      it '5,5,2', ->
        r = nz.Graph.backPosition direction:2,mapx:5,mapy:5
        r.mapx.should.equals 4,'4'
        r.mapy.should.equals 4,'4'
        r.direction.should.equals 2,'2'
      it '6,5,2', ->
        r = nz.Graph.backPosition direction:2,mapx:6,mapy:5
        r.mapx.should.equals 5,'5'
        r.mapy.should.equals 5,'5'
        r.direction.should.equals 2,'2'
      it '5,5,4', ->
        r = nz.Graph.backPosition direction:4,mapx:5,mapy:5
        r.mapx.should.equals 6,'6'
        r.mapy.should.equals 4,'4'
        r.direction.should.equals 4,'4'
      it '6,5,4', ->
        r = nz.Graph.backPosition direction:4,mapx:6,mapy:5
        r.mapx.should.equals 7,'7'
        r.mapy.should.equals 5,'5'
        r.direction.should.equals 4,'4'

    describe 'directionCost', ->
      it '方向転換のコスト計算1', ->
        nz.Graph.directionCost(0,0).should.equals 0,'0'
        nz.Graph.directionCost(0,1).should.equals 1,'1'
        nz.Graph.directionCost(0,2).should.equals 2,'2'
        nz.Graph.directionCost(0,3).should.equals 3,'3'
        nz.Graph.directionCost(0,4).should.equals 2,'4'
        nz.Graph.directionCost(0,5).should.equals 1,'5'
      it '方向転換のコスト計算2', ->
        nz.Graph.directionCost(1,0).should.equals 1,'0'
        nz.Graph.directionCost(1,1).should.equals 0,'1'
        nz.Graph.directionCost(1,2).should.equals 1,'2'
        nz.Graph.directionCost(1,3).should.equals 2,'3'
        nz.Graph.directionCost(1,4).should.equals 3,'4'
        nz.Graph.directionCost(1,5).should.equals 2,'5'
        nz.Graph.directionCost(5,0).should.equals 1,'0`'
        nz.Graph.directionCost(5,1).should.equals 2,'1`'
        nz.Graph.directionCost(5,2).should.equals 3,'2`'
        nz.Graph.directionCost(5,3).should.equals 2,'3`'
        nz.Graph.directionCost(5,4).should.equals 1,'4`'
        nz.Graph.directionCost(5,5).should.equals 0,'5`'
      it '方向転換のコスト計算3', ->
        nz.Graph.directionCost(2,0).should.equals 2,'0'
        nz.Graph.directionCost(2,1).should.equals 1,'1'
        nz.Graph.directionCost(2,2).should.equals 0,'2'
        nz.Graph.directionCost(2,3).should.equals 1,'3'
        nz.Graph.directionCost(2,4).should.equals 2,'4'
        nz.Graph.directionCost(2,5).should.equals 3,'5'
        nz.Graph.directionCost(4,0).should.equals 2,'0`'
        nz.Graph.directionCost(4,1).should.equals 3,'1`'
        nz.Graph.directionCost(4,2).should.equals 2,'2`'
        nz.Graph.directionCost(4,3).should.equals 1,'3`'
        nz.Graph.directionCost(4,4).should.equals 0,'4`'
        nz.Graph.directionCost(4,5).should.equals 1,'5`'
      it '方向転換のコスト計算4', ->
        nz.Graph.directionCost(3,0).should.equals 3,'0'
        nz.Graph.directionCost(3,1).should.equals 2,'1'
        nz.Graph.directionCost(3,2).should.equals 1,'2'
        nz.Graph.directionCost(3,3).should.equals 0,'3'
        nz.Graph.directionCost(3,4).should.equals 1,'4'
        nz.Graph.directionCost(3,5).should.equals 2,'5'
    describe 'direction', ->
      it '隣接ノードの方向0', ->
        node = new nz.GridNode(0,0)
        nz.Graph.direction(node,new nz.GridNode(1  ,1  )).should.equals 2
      it '隣接ノードの方向1', ->
        x = 2
        y = 2
        node = new nz.GridNode(x,y)
        nz.Graph.direction(node,new nz.GridNode(x  ,y-1)).should.equals 0
        nz.Graph.direction(node,new nz.GridNode(x  ,y+1)).should.equals 3
        nz.Graph.direction(node,new nz.GridNode(x-1,y  )).should.equals 5
        nz.Graph.direction(node,new nz.GridNode(x-1,y+1)).should.equals 4
        nz.Graph.direction(node,new nz.GridNode(x+1,y  )).should.equals 1
        nz.Graph.direction(node,new nz.GridNode(x+1,y+1)).should.equals 2
      it '隣接ノードの方向2', ->
        x = 3
        y = 2
        node = new nz.GridNode(x,y)
        nz.Graph.direction(node,new nz.GridNode(x  ,y-1)).should.equals 0
        nz.Graph.direction(node,new nz.GridNode(x  ,y+1)).should.equals 3
        nz.Graph.direction(node,new nz.GridNode(x-1,y-1)).should.equals 5
        nz.Graph.direction(node,new nz.GridNode(x-1,y  )).should.equals 4
        nz.Graph.direction(node,new nz.GridNode(x+1,y-1)).should.equals 1
        nz.Graph.direction(node,new nz.GridNode(x+1,y  )).should.equals 2
    describe 'ヒューリスティック関数', ->
      it 'ヒューリスティック関数1', ->
        n = new nz.GridNode(5,5,weight:1)
        s = new nz.GridNodeWrap n
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
          n = new nz.GridNode(d[0],d[1],weight:1)
          e = new nz.GridNodeWrap n
          result = nz.Graph.heuristic(s,e)
          result.should.equals d[2], "a #{i}=#{d[2]}"
      it 'ヒューリスティック関数1-1', ->
        n = new nz.GridNode(5,4,weight:1)
        s = new nz.GridNodeWrap n
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
          n = new nz.GridNode(d[0],d[1],weight:1)
          e = new nz.GridNodeWrap n
          result = nz.Graph.heuristic(s,e)
          result.should.equals d[2], "a #{i}=#{d[2]}"
      it 'ヒューリスティック関数2', ->
        n = new nz.GridNode(0,0,weight:1)
        s = new nz.GridNodeWrap n
        s.direction = 0
        n = new nz.GridNode(0,1,weight:1)
        e = new nz.GridNodeWrap n
        result = nz.Graph.heuristic(s,e)
        result.should.equals 4
      it 'ヒューリスティック関数3', ->
        n = new nz.GridNode(10,10,weight:1)
        s = new nz.GridNodeWrap n
        s.direction = 5
        n = new nz.GridNode(9,10,weight:1)
        e = new nz.GridNodeWrap n
        result = nz.Graph.heuristic(s,e)
        result.should.equals 1
      it 'ヒューリスティック関数4', ->
        n = new nz.GridNode(10,10,weight:1)
        s = new nz.GridNodeWrap n
        s.direction = 5
        n = new nz.GridNode(4,7,weight:1)
        e = new nz.GridNodeWrap n
        result = nz.Graph.heuristic(s,e)
        result.should.equals 6
      it 'ヒューリスティック関数5', ->
        n = new nz.GridNode(10,6,weight:1)
        s = new nz.GridNodeWrap n
        s.direction = 5
        n = new nz.GridNode(7,7,weight:1)
        e = new nz.GridNodeWrap n
        result = nz.Graph.heuristic(s,e)
        result.should.equals 4
      it 'ヒューリスティック関数5-1', ->
        n = new nz.GridNode(9,6,weight:1)
        s = new nz.GridNodeWrap n
        s.direction = 5
        n = new nz.GridNode(7,7,weight:1)
        e = new nz.GridNodeWrap n
        result = nz.Graph.heuristic(s,e)
        result.should.equals 3
      it 'ヒューリスティック関数5-2', ->
        n = new nz.GridNode(9,7,weight:1)
        s = new nz.GridNodeWrap n
        s.direction = 5
        n = new nz.GridNode(7,7,weight:1)
        e = new nz.GridNodeWrap n
        result = s.node.calcDirection(e)
        result.should.equals 4,'calcDirection'
        result = nz.Graph.heuristic(s,e)
        result.should.equals 3,'heuristic'
      it 'ヒューリスティック関数6', ->
        n = new nz.GridNode(13,8,weight:1)
        s = new nz.GridNodeWrap n
        s.direction = 5
        n = new nz.GridNode(7,7,weight:1)
        e = new nz.GridNodeWrap n
        result = nz.Graph.heuristic(s,e)
        result.should.equals 7
      it 'ヒューリスティック関数7', ->
        n = new nz.GridNode(3,9,weight:1)
        s = new nz.GridNodeWrap n
        s.direction = 2
        n = new nz.GridNode(7,6,weight:1)
        e = new nz.GridNodeWrap n
        result = nz.Graph.heuristic(s,e)
        result.should.equals 6
      it 'ヒューリスティック関数8', ->
        n = new nz.GridNode(3,8,weight:1)
        s = new nz.GridNodeWrap n
        s.direction = 2
        n = new nz.GridNode(7,5,weight:1)
        e = new nz.GridNodeWrap n
        result = nz.Graph.heuristic(s,e)
        result.should.equals 6

    describe '隣接ノード', ->
      it '角', ->
        graph = new nz.Graph(testdata)
        result = graph.neighbors new nz.GridNodeWrap(graph.grid[0][0],0)
        result.length.should.equals 3, 'length'
        result[0].mapx.should.equals 0
        result[0].mapy.should.equals 0
        result[0].direction.should.equals 5
        result[1].mapx.should.equals 0
        result[1].mapy.should.equals 0
        result[1].direction.should.equals 1
        result[2].mapx.should.equals 0
        result[2].mapy.should.equals 1
        result[2].direction.should.equals 0
    describe 'ルート検索', ->
      it 'Debug 1', ->
        route_search_test(
          {x:3,y:12,dir:0}
          {x:7,y:9}
          {
            len: 6
            cost: 6
            dir: 1
            costs: [1,2,3,4,5,6]
            route: [
              [3,11,0,false]
              [3,11,1,false]
              [4,10,1,false]
              [5,10,1,false]
              [6,9,1,false]
              [7,9,1,false]
            ]
          }
          undefined
          {closest:true}
        )
      it 'ほぼ真横の移動', ->
        route_search_test(
          {x:13,y:8,dir:5}
          {x:7,y:7}
          {
            len: 7
            cost: 7
            dir: 4
            route: [
              [12,7,5]
              [11,7,5]
              [10,6,5]
              [9,6,5]
              [9,6,4]
              [8,6,4]
              [7,7,4]
            ]
          }
        )
      it 'ほぼ真横の移動切り出し', ->
        route_search_test(
          {x:10,y:6,dir:5}
          {x:7,y:7}
          {
            len: 4
            cost: 4
            dir: 4
            route: [
              [9,6,5]
              [9,6,4]
              [8,6,4]
              [7,7,4]
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
              [10,9,0]
              [10,8,0]
              [10,7,0]
              [10,6,0]
              [10,5,0]
            ]
          }
        )
      it '上2', ->
        route_search_test(
          {x:10,y:10,dir:0}
          {x:9,y:5}
          {
            len: 7
            cost: 7
            costs: [1,2,3,4,5,6,7]
            dir: 5
            route: [
              [10,9,0]
              [10,8,0]
              [10,7,0]
              [10,6,0]
              [10,5,0]
              [10,5,5]
              [9,5,5]
            ]
          }
        )
      it '上3', ->
        route_search_test(
          {x:10,y:10,dir:0}
          {x:9,y:4}
          {
            len: 8
            cost: 8
            dir: 5
            route: [
              [10,9,0]
              [10,8,0]
              [10,7,0]
              [10,6,0]
              [10,5,0]
              [10,4,0]
              [10,4,5]
              [9,4,5]
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
              [0,1,3]
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
              [0,1,3]
              [0,2,3]
            ]
          }
          graph
        )
      it '右下', ->
        graph = route_search_test(
          {x:0,y:0,dir:3}
          {x:1,y:1}
          {
            len: 2
            cost: 2
            dir: 2
            route: [
              [0,0,2]
              [1,1,2]
            ]
          }
        )
        route_search_test(
          {x:0,y:0,dir:3}
          {x:1,y:2}
          {
            len: 3
            cost: 3
            dir: 2
            route: [
              [0,1,3]
              [0,1,2]
              [1,2,2]
            ]
          }
          graph
        )
        route_search_test(
          {x:0,y:0,dir:2}
          {x:1,y:2}
          {
            len: 3
            cost: 3
            dir: 3
            route: [
              [1,1,2]
              [1,1,3]
              [1,2,3]
            ]
          }
          graph
        )
        route_search_test(
          {x:0,y:0,dir:2}
          {x:1,y:2}
          {
            len: 3
            cost: 3
            dir: 3
            route: [
              [1,1,2]
              [1,1,3]
              [1,2,3]
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
              [2,0,2]
            ]
          }
          graph
        )
        route_search_test(
          {x:1,y:0,dir:3}
          {x:2,y:0}
          {
            len: 2
            cost: 2
            dir: 2
            route: [
              [1,0,2]
              [2,0,2]
            ]
          }
          graph
        )
        route_search_test(
          {x:1,y:0,dir:3}
          {x:2,y:1}
          {
            len: 3
            cost: 3
            dir: 2
            route: [
              [1,1,3]
              [1,1,2]
              [2,1,2]
            ]
          }
          graph
        )
        route_search_test(
          {x:1,y:0,dir:2}
          {x:2,y:1}
          {
            len: 3
            cost: 3
            dir: 3
            route: [
              [2,0,2]
              [2,0,3]
              [2,1,3]
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
      it '真後ろの1-1', ->
        route_search_test(
          {x:4,y:4,dir:0}
          {x:4,y:5}
          {
            len: 1
            cost: 2
            dir: 0
            route: [
              [4,5,0,true]
            ]
          }
        )
      it '真後ろの1-1', ->
        route_search_test(
          {x:6,y:6,dir:3}
          {x:6,y:5}
          {
            len: 1
            cost: 2
            dir: 3
            route: [
              [6,5,3,true]
            ]
          }
        )
      it '真後ろの2-1', ->
        route_search_test(
          {x:4,y:4,dir:0}
          {x:4,y:6}
          {
            len: 2
            cost: 4
            dir: 0
            route: [
              [4,5,0,true]
              [4,6,0,true]
            ]
          }
        )
      it '真後ろの3-1 バックしないほうが早くなる', ->
        # 実際には同じぽいけど…
        route_search_test(
          {x:4,y:4,dir:0}
          {x:4,y:7}
          {
            len: 6
            cost: 6
            dir: 3
            route: [
              [4,4,5,false]
              [4,4,4,false]
              [4,4,3,false]
              [4,5,3,false]
              [4,6,3,false]
              [4,7,3,false]
            ]
          }
        )
