###* AIパラメータ.
* @file Param.coffee
###

###* nineteen namespace.
* @namespace nz
###

# node.js と ブラウザでの this.nz を同じインスタンスにする
_g = window ? global
nz = _g.nz = _g.nz ? {}
_g = undefined

###*
* @namespace nz.ai
###
nz.ai = nz.ai ? {}

class nz.ai.Param

  ###* 戦闘ターン数
  * @var {number} nz.ai.Param#turn
  ###
  ###* 設定対象キャラクター
  * @var {nz.Character} nz.ai.Param#character
  ###
  ###* 設定対象を含む戦闘に参加しているキャラクターの配列
  * @var {Array<nz.Character>} nz.ai.Param#characters
  ###
  ###* マップ情報
  * @var {nz.Graph} nz.ai.Param#graph
  ###

  ###* コンストラクタ.
  * @classdesc AIパラメータ.
  * @constructor nz.ai.Param
  ###
  constructor: (param) ->
    {
      @character
      @characters
      @graph
      @turn
    } = param
    @setFriendsAndTargets()
    @setNearTarget()
    return

  ###*
  * @memberof nz.ai.Param#
  * @method findNearTarget
  ###
  searchRoute: nz.utils.searchRoute

  ###*
  * @memberof nz.ai.Param#
  * @method distance
  ###
  distance: nz.Graph.distance

  ###*
  * @memberof nz.ai.Param#
  * @method direction
  ###
  direction: nz.Graph.direction

  ###*
  * @memberof nz.ai.Param#
  * @method checkDirectionRange
  ###
  checkDirectionRange: nz.utils.checkDirectionRange

  ###* 後ろの座標を取得する
  * @memberof nz.ai.Param#
  * @method backPosition
  * @param {Object} character 基準になる位置情報
  ###
  backPosition: nz.Graph.backPosition

  ###* 近くの敵をターゲットとして検索する
  * @memberof nz.ai.Param#
  * @method findNearTarget
  ###
  findNearTarget: ->
    result = {
      target: null
      distance: 99
    }
    for t in @targets
      d = @distance(@character,t)
      if d < result.distance
        result.distance = d
        result.target = t
    return result

  ###* 戦闘参加キャラクターの敵と味方を分ける。
  * @memberof nz.ai.Param#
  * @method setFriendsAndTargets
  ###
  setFriendsAndTargets: ->
    @friends = []
    @targets = []
    for c in @characters when c.name != @character.name
      if @character.team == c.team
        @friends.push c
      else
        @targets.push c
    return

  ###* 近くにいる敵キャラクターをターゲットに設定。距離も設定する。
  * @memberof nz.ai.Param#
  * @method setNearTarget
  ###
  setNearTarget: ->
    r = @findNearTarget()
    @target   = r.target
    @distance = r.distance
    return

  ###* 射撃葉ににターゲットがいるか確認する
  * @memberof nz.ai.Param#
  * @method checkShotRange
  ###
  checkShotRange: ->
    self = @
    data = {
      source: @character
      target: @target
      range: @character.shot.range
      callback: (res,r) ->
        self.rotation = r if res
    }
    return @checkDirectionRange(data)

  ###* 後ろに移動できるか確認する
  * @memberof nz.ai.Param#
  * @method checkBackPosition
  ###
  checkBackPosition: ->
    r = @backPosition @character
    node = @graph.grid[r.mapx][r.mapy]
    unless node?
      return false
    if node.isWall()
      return false
    for c in @characters
      if c.mapx is r.mapx and c.mapy is r.mapy
        return false
    return true

  ###* 移動コマンドを設定する
  * @memberof nz.ai.Param#
  * @method setMoveCommand
  ###
  setMoveCommand: ->
    route = @searchRoute @graph,@character,@target,@characters
    @character.addMoveCommand @turn,route
    return

  ###* 攻撃コマンドを設定する
  * @memberof nz.ai.Param#
  * @method setAttackCommand
  ###
  setAttackCommand: ->
    route = @searchRoute @graph,@character,@target,@characters
    @character.setAttackCommand @turn
    @character.addMoveCommand @turn,route
    return

  ###* 射撃コマンドを設定する
  * @memberof nz.ai.Param#
  * @method setShotCommand
  ###
  setShotCommand: ->
    route = @searchRoute @graph,@character,@target,@characters
    @character.addShotCommand @turn,@rotation
    @character.addMoveCommand @turn,route
    return
