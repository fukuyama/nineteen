# UtilsTest.coffee

require('chai').should()

require('../../main/coffeescript/nz/System.coffee')
require('../../main/coffeescript/nz/Utils.coffee')

Math.RAD_TO_DEG = 180/Math.PI
Math.degToRad = (deg) -> deg * Math.DEG_TO_RAD
Math.radToDeg = (rad) -> rad * Math.RAD_TO_DEG

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
  describe 'relativeRotation', () ->
    it 'front target. relative 0', ->
      r = nz.utils.relativeRotation(-90,{x:10,y:10},{x:10,y:5})
      r.should.equals 0
      r = nz.utils.relativeRotation(90,{x:10,y:10},{x:10,y:15})
      r.should.equals 0
      r = nz.utils.relativeRotation(0,{x:10,y:10},{x:15,y:10})
      r.should.equals 0
      r = nz.utils.relativeRotation(180,{x:10,y:10},{x:5,y:10})
      r.should.equals 0
      r = nz.utils.relativeRotation(-180,{x:10,y:10},{x:5,y:10})
      r.should.equals 0
      r = nz.utils.relativeRotation(90,90)
      r.should.equals 0
    it 'side target. relative 90', ->
      r = nz.utils.relativeRotation(0,{x:10,y:10},{x:10,y:15})
      r.should.equals 90
      r = nz.utils.relativeRotation(0,{x:10,y:10},{x:10,y:5})
      r.should.equals -90
      r = nz.utils.relativeRotation(90,{x:10,y:10},{x:5,y:10})
      r.should.equals 90
      r = nz.utils.relativeRotation(90,{x:10,y:10},{x:15,y:10})
      r.should.equals -90
      r = nz.utils.relativeRotation(135,{x:10,y:10},{x:15,y:15})
      r.should.equals -90
      r = nz.utils.relativeRotation(190,100)
      r.should.equals -90
      r = nz.utils.relativeRotation(190,280)
      r.should.equals 90
      r = nz.utils.relativeRotation(170,-100)
      r.should.equals 90
  describe 'normalizRotation', () ->
    it '90 = 90', ->
      nz.utils.normalizRotation(90).should.equals 90
    it '-90 = -90', ->
      nz.utils.normalizRotation(-90).should.equals -90
    it '190 = -170', ->
      nz.utils.normalizRotation(190).should.equals -170
    it '180 = 180', ->
      nz.utils.normalizRotation(180).should.equals 180
    it '-180 = -180', ->
      nz.utils.normalizRotation(-180).should.equals -180
    it '360 = 0', ->
      nz.utils.normalizRotation(360).should.equals 0
    it '-360 = 0', ->
      nz.utils.normalizRotation(-360).should.equals 0
    it '300 = -60', ->
      nz.utils.normalizRotation(300).should.equals -60
    it '400 = 40', ->
      nz.utils.normalizRotation(400).should.equals 40
    it '760 = 40', ->
      nz.utils.normalizRotation(760).should.equals 40
    it '-1090 = -10', ->
      nz.utils.normalizRotation(-1090).should.equals -10
  describe 'mapxy2screenxy 1', () ->
    it '0,0', ->
      p = nz.utils.mapxy2screenxy mapx:0, mapy:0
      p.x.should.equals 16,'x'
      p.y.should.equals 32,'y'
    it '1,1', ->
      p = nz.utils.mapxy2screenxy mapx:1, mapy:1
      p.x.should.equals 48,'x'
      p.y.should.equals 48,'y'
    it '1,2', ->
      p = nz.utils.mapxy2screenxy mapx:1, mapy:2
      p.x.should.equals 48,'x'
      p.y.should.equals 80,'y'
    it '2,1', ->
      p = nz.utils.mapxy2screenxy mapx:2, mapy:1
      p.x.should.equals 80,'x'
      p.y.should.equals 64,'y'
    it '5,5', ->
      p = nz.utils.mapxy2screenxy mapx:5, mapy:5
      p.x.should.equals 176,'x'
      p.y.should.equals 176,'y'
    it '6,5', ->
      p = nz.utils.mapxy2screenxy mapx:6, mapy:5
      p.x.should.equals 208,'x'
      p.y.should.equals 192,'y'
  describe 'screenxy2mapxy 1', () ->
    it '16,32', ->
      p = nz.utils.screenxy2mapxy x:16, y:32
      p.mapx.should.equals 0,'mapx1'
      p.mapy.should.equals 0,'mapy1'
      p = nz.utils.screenxy2mapxy x:0, y:0
      p.mapx.should.equals 0,'mapx2'
      p.mapy.should.equals 0,'mapy2'
      p = nz.utils.screenxy2mapxy x:31, y:0
      p.mapx.should.equals 0,'mapx3'
      p.mapy.should.equals 0,'mapy3'
      p = nz.utils.screenxy2mapxy x:0, y:16
      p.mapx.should.equals 0,'mapx3'
      p.mapy.should.equals 0,'mapy3'
      p = nz.utils.screenxy2mapxy x:31, y:47
      p.mapx.should.equals 0,'mapx4'
      p.mapy.should.equals 0,'mapy4'
    it '48,48', ->
      p = nz.utils.screenxy2mapxy x:48, y:48
      p.mapx.should.equals 1,'mapx1'
      p.mapy.should.equals 1,'mapy1'
      p = nz.utils.screenxy2mapxy x:32, y:32
      p.mapx.should.equals 1,'mapx2'
      p.mapy.should.equals 1,'mapy2'
      p = nz.utils.screenxy2mapxy x:32, y:63
      p.mapx.should.equals 1,'mapx3'
      p.mapy.should.equals 1,'mapy3'
      p = nz.utils.screenxy2mapxy x:63, y:32
      p.mapx.should.equals 1,'mapx4'
      p.mapy.should.equals 1,'mapy4'
      p = nz.utils.screenxy2mapxy x:63, y:63
      p.mapx.should.equals 1,'mapx4'
      p.mapy.should.equals 1,'mapy4'
    it '48,80', ->
      p = nz.utils.screenxy2mapxy x:48, y:80
      p.mapx.should.equals 1,'mapx'
      p.mapy.should.equals 2,'mapy'
    it '80,64', ->
      p = nz.utils.screenxy2mapxy x:80, y:64
      p.mapx.should.equals 2,'mapx'
      p.mapy.should.equals 1,'mapy'
    it '176,176', ->
      p = nz.utils.screenxy2mapxy x:176, y:176
      p.mapx.should.equals 5,'mapx'
      p.mapy.should.equals 5,'mapy'
      p = nz.utils.screenxy2mapxy x:159, y:176
      p.mapx.should.equals 4,'mapx'
      p.mapy.should.equals 5,'mapy'
      p = nz.utils.screenxy2mapxy x:192, y:176
      p.mapx.should.equals 6,'mapx'
      p.mapy.should.equals 5,'mapy'
      p = nz.utils.screenxy2mapxy x:160, y:160
      p.mapx.should.equals 5,'mapx'
      p.mapy.should.equals 5,'mapy'
      p = nz.utils.screenxy2mapxy x:160, y:191
      p.mapx.should.equals 5,'mapx'
      p.mapy.should.equals 5,'mapy'
      p = nz.utils.screenxy2mapxy x:191, y:160
      p.mapx.should.equals 5,'mapx'
      p.mapy.should.equals 5,'mapy'
      p = nz.utils.screenxy2mapxy x:191, y:191
      p.mapx.should.equals 5,'mapx'
      p.mapy.should.equals 5,'mapy'
      p = nz.utils.screenxy2mapxy x:191, y:159
      p.mapx.should.equals 5,'mapx'
      p.mapy.should.equals 4,'mapy'
      p = nz.utils.screenxy2mapxy x:191, y:192
      p.mapx.should.equals 5,'mapx'
      p.mapy.should.equals 6,'mapy'
    it '208,192', ->
      p = nz.utils.screenxy2mapxy x:208, y:192
      p.mapx.should.equals 6,'mapx'
      p.mapy.should.equals 5,'mapy'
      p = nz.utils.screenxy2mapxy x:208, y:175
      p.mapx.should.equals 6,'mapx'
      p.mapy.should.equals 4,'mapy'
      p = nz.utils.screenxy2mapxy x:208, y:176
      p.mapx.should.equals 6,'mapx'
      p.mapy.should.equals 5,'mapy'
      p = nz.utils.screenxy2mapxy x:192, y:176
      p.mapx.should.equals 6,'mapx'
      p.mapy.should.equals 5,'mapy'
      p = nz.utils.screenxy2mapxy x:223, y:176
      p.mapx.should.equals 6,'mapx'
      p.mapy.should.equals 5,'mapy'
      p = nz.utils.screenxy2mapxy x:223, y:207
      p.mapx.should.equals 6,'mapx'
      p.mapy.should.equals 5,'mapy'
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
