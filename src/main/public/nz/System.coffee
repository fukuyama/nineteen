###*
* @file System.coffee
* システム情報
###

# node.js と ブラウザでの this.nz を同じインスタンスにする
_g = window ? global
nz = _g.nz = _g.nz ? {}
_g = undefined

class nz.System

  title: 'Nineteen'
  direction_num:
    UP:         0
    UP_RIGHT:   1
    DOWN_RIGHT: 2
    DOWN:       3
    DOWN_LEFT:  4
    UP_LEFT:    5
  character:
    directions: [
      {name:'up'        , rotation:  -90, index:0, rotateIndex:[ 0, 1, 2, 3,-2,-1]}
      {name:'up_right'  , rotation:  -30, index:1, rotateIndex:[-1, 0, 1, 2, 3,-2]}
      {name:'down_right', rotation:   30, index:2, rotateIndex:[-2,-1, 0, 1, 2, 3]}
      {name:'down'      , rotation:   90, index:3, rotateIndex:[ 3,-2,-1, 0, 1, 2]}
      {name:'down_left' , rotation:  150, index:4, rotateIndex:[ 2, 3,-2,-1, 0, 1]}
      {name:'up_left'   , rotation: -150, index:5, rotateIndex:[ 1, 2, 3,-2,-1, 0]}
      {name:'default'   , rotation:   90, index:6, rotateIndex:[ 0, 1, 2, 3,-2,-1]}
    ]
    action_cost:
      move:   1
      rotate: 1
      attack: 2
      shot:   2
    stamina_cost:
      move:   1
      rotate: 1
      attack: 4
      shot:   2
  map:
    chip:
      width:  32
      height: 32
  screen:
    width:  640
    height: 480
  dialog:
    strokeStyle: 'rgba(255,255,255,1.0)'
    fillStyle:   'rgba(128,128,128,1.0)'
  assets:
    chipdata:    'data/chipdata.json'
    map_object:  'img/map_object.png'
    map_chip:    'img/map_chip.png'
    character_001:
      type:      'tmss'
      src:       'data/character_001.json'
    character_test:
      type:      'tmss'
      src:       'data/character_test.json'
  messages:
    battle:
      position:
        setiing: '{name} の開始位置を選択してください。'

  ###* 初期化
  * @classdesc システムクラス
  * @constructor nz.System
  ###
  constructor: () ->
    @ai = {}
    return

  addAI: (name,ai) -> @ai[name] = ai

  start: ->
    @app.replaceScene nz.SceneTitleMenu()
    return

  restart: ->
    @start()
    return


nz.system = new nz.System()
