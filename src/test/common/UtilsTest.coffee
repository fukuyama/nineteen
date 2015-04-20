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
require('../../main/public/nz/Utils.coffee')

# 価値は何か，誰にとっての価値か，実際の機能は何か
describe 'UtilsTest', () ->
  describe 'lineRoute 1', () ->
    it '(5,5),(5,6)', ->
      p1 = {
        mapx:5
        mapy:5
      }
      p2 = {
        mapx:5
        mapy:6
      }
      ret = nz.utils.lineRoute(p1,p2)
      ret[0].mapx.should.equals 5
      ret[0].mapy.should.equals 5
      ret[1].mapx.should.equals 5
      ret[1].mapy.should.equals 6
    it '(5,5),(5,4)', ->
      p1 = {
        mapx:5
        mapy:5
      }
      p2 = {
        mapx:5
        mapy:4
      }
      ret = nz.utils.lineRoute(p1,p2)
      ret[0].mapx.should.equals 5
      ret[0].mapy.should.equals 5
      ret[1].mapx.should.equals 5
      ret[1].mapy.should.equals 4
    it '(5,5),(6,5)', ->
      p1 = {
        mapx:5
        mapy:5
      }
      p2 = {
        mapx:6
        mapy:5
      }
      ret = nz.utils.lineRoute(p1,p2)
      ret[0].mapx.should.equals 5
      ret[0].mapy.should.equals 5
      ret[1].mapx.should.equals 6
      ret[1].mapy.should.equals 5
    it '(5,5),(6,4)', ->
      p1 = {
        mapx:5
        mapy:5
      }
      p2 = {
        mapx:6
        mapy:4
      }
      ret = nz.utils.lineRoute(p1,p2)
      ret[0].mapx.should.equals 5
      ret[0].mapy.should.equals 5
      ret[1].mapx.should.equals 6
      ret[1].mapy.should.equals 4
    it '(5,5),(4,5)', ->
      p1 = {
        mapx:5
        mapy:5
      }
      p2 = {
        mapx:4
        mapy:5
      }
      ret = nz.utils.lineRoute(p1,p2)
      ret[0].mapx.should.equals 5
      ret[0].mapy.should.equals 5
      ret[1].mapx.should.equals 4
      ret[1].mapy.should.equals 5
    it '(5,5),(4,4)', ->
      p1 = {
        mapx:5
        mapy:5
      }
      p2 = {
        mapx:4
        mapy:4
      }
      ret = nz.utils.lineRoute(p1,p2)
      ret[0].mapx.should.equals 5
      ret[0].mapy.should.equals 5
      ret[1].mapx.should.equals 4
      ret[1].mapy.should.equals 4
  describe 'lineRoute 2', () ->
    it '(5,5),(5,7)', ->
      p1 = {
        mapx:5
        mapy:5
      }
      p2 = {
        mapx:5
        mapy:7
      }
      ret = nz.utils.lineRoute(p1,p2)
      ret[0].mapx.should.equals 5,'x5'
      ret[0].mapy.should.equals 5,'y5'
      ret[1].mapx.should.equals 5,'x5'
      ret[1].mapy.should.equals 6,'y6'
      ret[2].mapx.should.equals 5,'x5'
      ret[2].mapy.should.equals 7,'y7'
    it '(5,5),(7,6)', ->
      p1 = {
        mapx:5
        mapy:5
      }
      p2 = {
        mapx:7
        mapy:6
      }
      ret = nz.utils.lineRoute(p1,p2)
      ret[0].mapx.should.equals 5,'x5'
      ret[0].mapy.should.equals 5,'y5'
      ret[1].mapx.should.equals 6,'x6'
      ret[1].mapy.should.equals 5,'y5'
      ret[2].mapx.should.equals 7,'x7'
      ret[2].mapy.should.equals 6,'y6'
    it '(5,5),(6,7)', ->
      p1 = {
        mapx:5
        mapy:5
      }
      p2 = {
        mapx:6
        mapy:7
      }
      ret = nz.utils.lineRoute(p1,p2)
      ret[0].mapx.should.equals 5,'x5'
      ret[0].mapy.should.equals 5,'y5'
      ret[1].mapx.should.equals 5,'x5'
      ret[1].mapy.should.equals 6,'y6'
      ret[2].mapx.should.equals 6,'x6'
      ret[2].mapy.should.equals 6,'y6'
      ret[3].mapx.should.equals 6,'x6'
      ret[3].mapy.should.equals 7,'y7'
    it '(5,5),(6,6)', ->
      p1 = {
        mapx:5
        mapy:5
      }
      p2 = {
        mapx:6
        mapy:6
      }
      ret = nz.utils.lineRoute(p1,p2)
      ret[0].mapx.should.equals 5,'0x5'
      ret[0].mapy.should.equals 5,'0y5'
      ret[1].mapx.should.equals 6,'1x6'
      ret[1].mapy.should.equals 5,'1y5'
      ret[2].mapx.should.equals 6,'2x6'
      ret[2].mapy.should.equals 6,'2y6'
