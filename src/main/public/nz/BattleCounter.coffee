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

  missBallet: ->
    @ballet.atk.miss += 1
    return
  hitBallet: (d) ->
    @ballet.atk.hit += 1
    @ballet.atk.damage.max = Math.max @ballet.atk.damage.max, d
    @ballet.atk.damage.total += d
    return
  receiveBallet: (d) ->
    @ballet.def.hit += 1
    @ballet.def.damage.max = Math.max @ballet.def.damage.max, d
    @ballet.def.damage.total += d
    return

  missWeapon: ->
    @weapon.atk.miss += 1
    return
  hitWeapon: (d) ->
    @weapon.atk.hit += 1
    @weapon.atk.damage.max = Math.max @weapon.atk.damage.max, d
    @weapon.atk.damage.total += d
    return
  receiveWeapon: (d) ->
    @weapon.def.hit += 1
    @weapon.def.damage.max = Math.max @weapon.def.damage.max, d
    @weapon.def.damage.total += d
    return
