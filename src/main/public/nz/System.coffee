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
      character:
        directions: [
          {name:'up'        , rotation:  -90, index:0, next:[ 0, 1, 2, 3,-2,-1]}
          {name:'up_right'  , rotation:  -30, index:1, next:[-1, 0, 1, 2, 3,-2]}
          {name:'down_right', rotation:   30, index:2, next:[-2,-1, 0, 1, 2, 3]}
          {name:'down'      , rotation:   90, index:3, next:[ 3,-2,-1, 0, 1, 2]}
          {name:'down_left' , rotation:  150, index:4, next:[ 2, 3,-2,-1, 0, 1]}
          {name:'up_left'   , rotation: -150, index:5, next:[ 1, 2, 3,-2,-1, 0]}
          {name:'default'   , rotation:   90, index:6, next:[ 0, 1, 2, 3,-2,-1]}
        ]
      map:
        chip:
          width: 32
          height: 32
      screen:
        width: 32*20
        height: 32*15
      dialog:
        strokeStyle:'rgba(255,255,255,1.0)'
        fillStyle:'rgba(  0,  0, 64,1.0)'
      assets:
        chipdata: 'data/chipdata.json'
        map_object: 'img/map_object.png'
        map_chip: 'img/map_chip.png'
        character_001:
          type: 'tmss'
          src: 'data/character_001.json'
    return

nz.system = nz.System()
