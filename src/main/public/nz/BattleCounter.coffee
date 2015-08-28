###*
* @file BattleCounter.coffee
* 戦闘用のカウンター
###

###* nineteen namespace.
* @namespace nz
###

# node.js と ブラウザでの this.nz を同じインスタンスにする
_g = window ? global
nz = _g.nz = _g.nz ? {}
_g = undefined

class nz.BattleCounter

  ###* 初期化
  * @classdesc 戦闘用のカウンター
  * @constructor nz.BattleCounter
  ###
  constructor: (param = {}) ->
    @clear()
    return

  clear: ->
    @move = 0
    @dead = 0
    @kill = []
    @ballet =
      atk:
        hit: 0
        miss: 0
        damage:
          max: 0
          total: 0
      def:
        hit: 0
        damage:
          max: 0
          total: 0
    @weapon =
      atk:
        hit: 0
        miss: 0
        damage:
          max: 0
          total: 0
      def:
        hit: 0
        damage:
          max: 0
          total: 0
    return

  killing: (name) ->
    @kill.push name
    return
  deadCount: ->
    @dead += 1
    return
  moveCount: ->
    @move += 1
    return

  missBallet: ->
    @ballet.atk.miss += 1
    return
  hitBallet: (n) ->
    @ballet.atk.hit += 1
    d = @ballet.atk.damage
    d.max = Math.max d.max, n
    d.total += n
    return
  receiveBallet: (n) ->
    @ballet.def.hit += 1
    d = @ballet.def.damage
    d.max = Math.max d.max, n
    d.total += n
    return

  missWeapon: ->
    @weapon.atk.miss += 1
    return
  hitWeapon: (n) ->
    @weapon.atk.hit += 1
    d = @weapon.atk.damage
    d.max = Math.max d.max, n
    d.total += n
    return
  receiveWeapon: (n) ->
    @weapon.def.hit += 1
    d = @weapon.def.damage
    d.max = Math.max d.max, n
    d.total += n
    return
