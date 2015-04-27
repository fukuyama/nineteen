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
    @x = x
    @y = y
    {
      @weight
      @frame
      @name
      @object
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
  calcDirection: (node) -> nz.GridNode.calcDirection(@,node)
  calcDirectionTo: (node) -> @calcDirection(node)
  calcDirectionBy: (node) -> node.calcDirection(@)

  ###*
  * 曲がる場合のコスト
  * @param direction {number} 方向(1-6)
  ###
  getDirectionCost: (direction) -> nz.GridNode.calcDirectionCost(@direction,direction)

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
    return @weight == 0 or @options?.isWall

nz.GridNode.calcDirection = (node1,node2) ->
  direction = 0
  if node1.x == node2.x
    direction = 0 if node1.y > node2.y
    direction = 3 if node1.y < node2.y
  else if node1.x > node2.x # 左側
    if node1.y == node2.y
      direction = if node1.x % 2 == 0 then 5 else 4
    else if node1.y > node2.y
      direction = 5
    else if node1.y < node2.y
      direction = 4
  else if node1.x < node2.x # 右側
    if node1.y == node2.y
      direction = if node1.x % 2 == 0 then 1 else 2
    else if node1.y > node2.y
      direction = 1
    else if node1.y < node2.y
      direction = 2
  return direction

nz.GridNode.calcDirectionCost = (direction1,direction2) ->
  Math.abs(3 - Math.abs((direction2 - direction1 - 3) % 6))
