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
  ###* 設定対象を含まない味方キャラクターの配列
  * @var {Array<nz.Character>} nz.ai.Param#friends
  ###
  ###* 敵キャラクターの配列
  * @var {Array<nz.Character>} nz.ai.Param#targets
  ###
  ###* 対象キャラクター／場所。主にアクション設定時の対象として使用される。初期値は一番近い敵キャラクター。
  * @var {Array<nz.Character|Object>} nz.ai.Param#target
  ###
  ###* 対象キャラクター／場所までの距離。初期値は一番近い敵キャラクターまでの距離。
  * @var {Array<nz.Character|Object>} nz.ai.Param#distance
  ###
  ###* マップ情報
  * @var {nz.Graph} nz.ai.Param#graph
  ###

  ###* コンストラクタ.
  * @classdesc AIパラメータ.
  * @constructor nz.ai.Param
  * @param {Object}              param            初期化パラメータ
  * @param {nz.Character}        param.character  AI対象キャラクター
  * @param {Array<nz.Character>} param.characters AI対象外の戦闘参加キャラクター
  * @param {nz.Graph}            param.graph      マップ情報
  * @param {number}              param.turn       現在の戦闘ターン数
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

  findTarget: (key,len=1) ->
    result = null
    return result

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
      d = nz.Graph.distance(@character,t)
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
    return nz.utils.checkDirectionRange(data)

  ###* 後ろに移動できるか確認する(コスト計算含む)
  * @memberof nz.ai.Param#
  * @method checkBackPosition
  ###
  checkBackPosition: ->
    r = nz.Graph.backPosition @character
    node = @graph.grid[r.mapx][r.mapy]
    unless node?
      return false
    if node.isWall()
      return false
    for c in @characters
      if c.mapx is r.mapx and c.mapy is r.mapy
        return false
    if @character.getRemnantAp() < node.getCost(r)
      return false
    return true

  ###* 移動コマンドを設定する
  * @memberof nz.ai.Param#
  * @method setMoveCommand
  ###
  setMoveCommand: ->
    route = nz.utils.searchRoute @graph,@character,@target,@characters
    @character.addMoveCommand @turn,route
    return

  ###* 攻撃コマンドを設定する
  * @memberof nz.ai.Param#
  * @method setAttackCommand
  ###
  setAttackCommand: ->
    @character.setAttackCommand @turn
    return

  ###* 射撃コマンドを設定する
  * @memberof nz.ai.Param#
  * @method setShotCommand
  ###
  setShotCommand: ->
    @character.addShotCommand @turn,@rotation
    return

  ###* 後ろに移動するコマンドを設定する
  * @memberof nz.ai.Param#
  * @method setBackCommand
  * @param {number} num 後退する歩数
  ###
  setBackCommand: (num=1) ->
    pos = nz.Graph.backPosition @character
    for i in [0 .. num]
      if @checkBackPosition()
        route = {
          mapx: pos.mapx
          mapy: pos.mapy
          cost: cost
          back: true
          direction: pos.direction
        }
        @character.addMoveCommand @turn, [route]
    return
