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
    @.$extend
      title: 'Nineteen'
      map:
        chip:
          width: 32
          height: 32
      screen:
        width: 32*20
        height: 32*15
      assets:
        chipdata: 'data/chipdata.json'
        map_object: 'img/map_object.png'
        map_chip: 'img/map_chip.png'
        character_001:
          type: 'tmss'
          src: 'data/character_001.json'
    return

nz.system = nz.System()
