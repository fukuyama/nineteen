###*
* @file System.coffee
* システム情報
###

tm.define 'nz.System',

  ###* 初期化
  * @classdesc システムクラス
  * @constructor nz.System
  ###
  init: () ->
    @screen =
      width: 32*20
      height: 32*15
    @assets =
      map_chip: 'img/map_chip.png'
      chara001: 'data/chara001.json'
    return

nz.system = nz.System()
