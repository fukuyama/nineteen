###*
* @file GridNode.coffee
* A*用ノードクラス
###

# node.js と ブラウザでの this.nz を同じインスタンスにする
_g = window ? global
nz = _g.nz = _g.nz ? {}
_g = undefined

class nz.GridNode

  ###*
  * @param {Object} chipdata
  * @param {number} chipdata.weight
  * @param {number} chipdata.frame
  * @param {string} chipdata.name
  ###
  constructor: (x, y, chipdata={weight:0}) ->
    @x      = x
    @y      = y
    {
      @weight
      @frame
      @name
    } = chipdata
    @clean()

  clean: ->
    @direction = 0
    return

  toString: ->
    return "[#{@x},#{@y}]"

  ###*
  * 指定されたノードが、自分から見てどの方向にあるか
  * @param node {GridNode} 調査対象ノード
  ###
  calcDirection: (node) ->
    direction = 0
    if @x == node.x
      direction = 1 if @y > node.y
      direction = 4 if @y < node.y
    else if @x > node.x # 左側
      if @y == node.y
        direction = if @x % 2 == 0 then 6 else 5
      else if @y > node.y
        direction = 6
      else if @y < node.y
        direction = 5
    else if @x < node.x # 右側
      if @y == node.y
        direction = if @x % 2 == 0 then 2 else 3
      else if @y > node.y
        direction = 2
      else if @y < node.y
        direction = 3
    return direction
  calcDirectionTo: (node) -> @calcDirection(node)
  calcDirectionBy: (node) -> node.calcDirection(@)

  ###*
  * 曲がる場合のコスト
  * @param direction {number} 方向(1-6)
  ###
  getDirectionCost: (direction) ->
    Math.abs(3 - Math.abs((direction - @direction - 3) % 6))

  ###*
  * 自分のノードに、指定されたノードから移動する（入る）場合のコスト
  * @param node {GridNode} 移動元ノード
  ###
  getCost: (node) ->
    cost = @weight
    # 移動元からの方向
    direction = node.calcDirection(@)
    # 方向転換のコスト
    cost += node.getDirectionCost(direction)
    # ここまでのコストが今までのコストより低い場合方向を更新
    if not @visited or node.g + cost < @g
      @direction = direction
    return cost

  ###*
  * 壁判定
  ###
  isWall: ->
    return @weight == 0
