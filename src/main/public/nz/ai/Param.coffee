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

###* AI namespace.
* @namespace nz.ai
###
nz.ai = nz.ai ? {}

DIRECTIONS = nz.system.character.directions

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

  ###*
  * @private
  ###
  _searchCharacters: (rotatedir, distance, characters, character = @character) ->
    {
      mapx
      mapy
      direction
    } = character
    nodes = nz.Graph.frontArea(
      mapx:      mapx
      mapy:      mapy
      direction: direction + rotatedir
      distance:  distance
    )
    r = []
    for n in nodes
      for c in characters
        if n.mapx is c.mapx and n.mapy is c.mapy
          r.push c
    return r

  ###* 敵の範囲検索
  * @memberof nz.ai.Param#
  * @method searchTargets
  * @param {number} rotatedir 向いている方向に対する検索する回転方向
  * @param {number} distance  検索距離
  * @return {Array<nz.Character>} 見つかったキャラクター配列
  ###
  searchTargets: (rotatedir,distance) ->
    return @_searchCharacters rotatedir,distance,@targets

  ###* 味方の範囲検索
  * @memberof nz.ai.Param#
  * @method searchFriends
  * @param {number} rotatedir 向いている方向に対する検索する回転方向
  * @param {number} distance  検索距離
  * @return {Array<nz.Character>} 見つかったキャラクター配列
  ###
  searchFriends: (rotatedir,distance) ->
    return @_searchCharacters rotatedir,distance,@friends

  ###* 近くの敵をターゲットとして検索する
  * @memberof nz.ai.Param#
  * @method findNearTarget
  ###
  findNearTarget: ->
    result = {
      target: null
      distance: 99
      rotation: null
    }
    for t in @targets
      d = nz.Graph.distance(@character,t)
      if d < result.distance
        result.distance = d
        result.target = t
    if result.target?
      d = @character.getLastDirection @turn
      r = DIRECTIONS[d].rotation
      c = nz.utils.mapxy2screenxy @character
      t = nz.utils.mapxy2screenxy result.target
      #console.log "#{d} #{r} #{c} #{t}"
      result.rotation = nz.utils.relativeRotation(r,c,t)
    return result

  ###* 周囲6方向の位置を座標を取得
  * @param {number} n 距離
  * @return {Array} {mapx,mapy} の座標を表したオブジェクトは配列
  ###
  getHexPosition: (n=6) ->
    c = @character
    nx = n
    ny1 = n / 2
    ny2 = n / 2
    if n % 2 != 0
      if c.mapx % 2 == 0
        ny1 -= 0.5
        ny2 += 0.5
      else
        ny1 += 0.5
        ny2 -= 0.5
    return (
      for res in [
        {mapx: c.mapx     , mapy: c.mapy - n  }
        {mapx: c.mapx     , mapy: c.mapy + n  }
        {mapx: c.mapx - nx, mapy: c.mapy - ny1}
        {mapx: c.mapx - nx, mapy: c.mapy + ny2}
        {mapx: c.mapx + nx, mapy: c.mapy - ny1}
        {mapx: c.mapx + nx, mapy: c.mapy + ny2}
      ] when @graph.grid[res.mapx]?[res.mapy]?
        res
    )

  ###* 戦闘参加キャラクターの敵と味方を分ける。
  * @memberof nz.ai.Param#
  * @method setFriendsAndTargets
  ###
  setFriendsAndTargets: ->
    @friends = []
    @targets = []
    for c in @characters when c.name != @character.name and c.isAlive()
      if @character.team == c.team
        @friends.push c
      else
        @targets.push c
    return

  ###* 近くにいる敵キャラクターをターゲットに設定。距離と方向も設定する。
  * @memberof nz.ai.Param#
  * @method setNearTarget
  ###
  setNearTarget: ->
    r = @findNearTarget()
    @target   = r.target
    @distance = r.distance
    @rotation = r.rotation
    return

  ###* 射撃範囲にターゲットがいるか確認する
  * @memberof nz.ai.Param#
  * @method checkShotRange
  ###
  checkShotRange: ->
    self = @
    source = nz.utils.mapxy2screenxy @character
    source.direction = @character.direction
    target = nz.utils.mapxy2screenxy @target
    data = {
      source: source
      target: target
      range: @character.shot.range
      callback: (res,r) ->
        self.rotation = r if res
    }
    return nz.utils.checkDirectionRange(data)

  ###* 指定した座標が移動できるか確認する(コスト計算含まない)
  * @memberof nz.ai.Param#
  * @method checkMovePosition
  * @param {Object} p {mapx,mapy}
  ###
  checkMovePosition: (p) ->
    return false unless p?
    node = @graph.grid[p.mapx]?[p.mapy]
    return false unless node?
    return false if node.isWall()
    for c in @characters
      if c.mapx is p.mapx and c.mapy is p.mapy
        return false
    return true

  getFrontPosition: ->
    c = @character.getLastPosition(@turn)
    c.direction = @character.getLastDirection(@turn)
    return nz.Graph.frontPosition c

  getBackPosition: ->
    c = @character.getLastPosition(@turn)
    c.direction = @character.getLastDirection(@turn)
    return nz.Graph.backPosition c

  ###* 前に移動できるか確認する(コスト計算含む)
  * @memberof nz.ai.Param#
  * @method checkFrontPosition
  ###
  checkFrontPosition: ->
    p = @getFrontPosition()
    unless @checkMovePosition(p)
      return false
    node = @graph.grid[p.mapx][p.mapy]
    if @character.getRemnantAp() < node.weight + 1
      return false
    return true

  ###* 後ろに移動できるか確認する(コスト計算含む)
  * @memberof nz.ai.Param#
  * @method checkBackPosition
  ###
  checkBackPosition: ->
    p = @getBackPosition()
    unless @checkMovePosition(p)
      return false
    node = @graph.grid[p.mapx][p.mapy]
    if @character.getRemnantAp() < node.weight + 1
      return false
    return true

  ###* 移動コマンドを設定する
  * @memberof nz.ai.Param#
  * @method setMoveCommand
  ###
  setMoveCommand: (args={}) ->
    target = args.target ? @target
    length = args.length ? 99
    c = @character.getLastPosition(@turn)
    c.direction = @character.getLastDirection(@turn)
    route  = nz.utils.searchRoute @graph,c,target,@characters
    if length < route.length
      route = route[0 ... length]
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
    direction = @character.getLastDirection @turn
    rotation = DIRECTIONS[direction].rotation
    @character.addShotCommand @turn,@rotation + rotation
    return

  ###* 後ろに移動するコマンドを設定する
  * @memberof nz.ai.Param#
  * @method setMoveBackCommand
  * @param {number} num 後退する歩数
  ###
  setMoveBackCommand: (num=1) ->
    for i in [0 .. num]
      if @checkBackPosition()
        pos  = @getBackPosition()
        node = @graph.grid[pos.mapx][pos.mapy]
        cost = node.weight + 1
        route = {
          mapx: pos.mapx
          mapy: pos.mapy
          cost: cost
          back: true
          direction: pos.direction
        }
        @character.addMoveCommand @turn, [route]
    return

  ###* 前に移動するコマンドを設定する
  * @memberof nz.ai.Param#
  * @method setMoveFrontCommand
  * @param {number} num 前進する歩数
  ###
  setMoveFrontCommand: (num=1) ->
    for i in [0 .. num]
      if @checkFrontPosition()
        pos  = @getFrontPosition()
        node = @graph.grid[pos.mapx][pos.mapy]
        cost = node.weight + 1
        route = {
          mapx: pos.mapx
          mapy: pos.mapy
          cost: cost
          back: false
          direction: pos.direction
        }
        @character.addMoveCommand @turn, [route]
    return

  ###* 方向転換コマンドを設定する（相対値）
  * @memberof nz.ai.Param#
  * @method setRotateCommand
  * @param {number} rotate 方向転換する値(-3から+3の相対値)
  ###
  setRotateCommand: (rotate) ->
    d = @character.getLastDirection @turn
    @character.addRotateCommand @turn, d, rotate
    return

  ###* 方向転換コマンドを設定する（絶対値）
  * @memberof nz.ai.Param#
  * @method setDirectionCommand
  * @param {number} direction 方向転換する方向(0から5の絶対値)
  ###
  setDirectionCommand: (direction) ->
    if 0 <= direction and direction <= 5
      d = @character.getLastDirection @turn
      @character.addRotateCommand @turn, d, DIRECTIONS[d].rotateIndex[direction]
    return
