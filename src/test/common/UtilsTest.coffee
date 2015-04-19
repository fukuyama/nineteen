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
  it.skip 'linePositions (5,5),(5,6)', ->
    p1 = {
      mapx:5
      mapy:5
    }
    p2 = {
      mapx:5
      mapy:6
    }
    ret = nz.utils.linePositions(p1,p2)
    ret[0].mapx.should.equals 5
    ret[0].mapy.should.equals 5
    ret[1].mapx.should.equals 5
    ret[1].mapy.should.equals 6
  it.skip 'linePositions (5,5),(5,7)', ->
    p1 = {
      mapx:5
      mapy:5
    }
    p2 = {
      mapx:5
      mapy:7
    }
    ret = nz.utils.linePositions(p1,p2)
    ret[0].mapx.should.equals 5,'x5'
    ret[0].mapy.should.equals 5,'y5'
    ret[1].mapx.should.equals 5,'x5'
    ret[1].mapy.should.equals 6,'y6'
    ret[2].mapx.should.equals 5,'x5'
    ret[2].mapy.should.equals 7,'y7'
  it 'linePositions (5,5),(7,6)', ->
    p1 = {
      mapx:5
      mapy:5
    }
    p2 = {
      mapx:7
      mapy:6
    }
    ret = nz.utils.linePositions(p1,p2)
    console.log ret
