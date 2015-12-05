###*
* @file GridNode.coffee
* A*用ノードクラス
###

# node.js と ブラウザでの this.nz を同じインスタンスにする
_g = window ? global
nz = _g.nz = _g.nz ? {}
_g = undefined

class nz.GridNodeWrap
  constructor: (node, direction=-1) ->
    @node      = node
    @direction = direction
    @back      = false

  clean: -> @node.clean()

  ###*
  * 自分のノードに、指定されたノードから移動する（入る）場合のコスト
  * @param wrap {nz.GridNodeWrap} 移動元ノード
  ###
  getCost: (wrap) ->
    cost = @node.weight
    if @mapx is wrap.mapx and @mapy is wrap.mapy
      # 方向転換のコスト（１づつ方向転換するからコストは1）
      cost = 1
    else if nz.Graph.direction(@,wrap) is wrap.direction
      cost += 1
      @back = true
    return cost

  isWall: -> @node.isWall()

Object.defineProperty nz.GridNodeWrap.prototype,'mapx',
  get: -> @node.mapx
  enumerable: true
Object.defineProperty nz.GridNodeWrap.prototype,'mapy',
  get: -> @node.mapy
  enumerable: true

class nz.GridNode

  ###*
  * @param {Object} chipdata
  * @param {number} chipdata.weight
  * @param {number} chipdata.frame
  * @param {string} chipdata.name
  ###
  constructor: (mapx, mapy, chipdata={weight:0}) ->
    @mapx = mapx
    @mapy = mapy
    {
      @weight
      @frame
      @name
      @object
    } = chipdata
    @clean()

  clean: ->
    return

  toString: -> "[#{@mapx},#{@mapy}]"

  ###*
  * 指定されたノードが、自分から見てどの方向にあるか
  * @param node {GridNode|GridNodeWrap} 調査対象ノード
  ###
  calcDirection:   (node) -> nz.Graph.direction(@,node)
  calcDirectionTo: (node) -> nz.Graph.direction(@,node)
  calcDirectionBy: (node) -> nz.Graph.direction(node,@)

  ###*
  * 壁判定
  ###
  isWall: -> @weight is 0 or @options?.isWall
