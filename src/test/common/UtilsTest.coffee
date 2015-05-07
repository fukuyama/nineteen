# UtilsTest.coffee

require('chai').should()

require('../../main/public/nz/System.coffee')
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
