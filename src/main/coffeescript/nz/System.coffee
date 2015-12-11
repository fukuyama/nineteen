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
  screen:
    width:  640
    height: 480
    backgroundColor: '#ddd'
  assets:
    #file:
    #  chipdata:
    #    path: 'data/chipdata.json'
    #    dataType: 'json'
    image:
      map_object:  'img/map_object.png'
      map_chip:    'img/map_chip.png'
    spritesheet:
      character_001:  'data/character_001.json'
      character_test: 'data/character_test.json'
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
  dialog:
    strokeStyle: 'rgba(255,255,255,1.0)'
    fillStyle:   'rgba(128,128,128,1.0)'
  team:
    colors: [
      [255,255,255]
      [  0,255,255]
      [255,  0,255]
      [255,255,  0]
      [255,  0,  0]
      [  0,255,  0]
      [  0,  0,255]
      [  0,  0,  0]
    ]
  messages:
    battle:
      phase:
        command:    'キャラクターを選択し行動を設定してください。'
        exit_game:  'ゲームを終了します。'
        close_menu: 'メニューを閉じます。'
      command:
        move:       '移動先の設定をします。'
        attack:     '攻撃範囲に入った敵に対して武器による攻撃をします'
        shot:       '指定した方向へ、射撃を行います。'
        rotate:     '向いている方向を、変更します。'
        reset:      '行動をリセッットします。'
        next_turn:  '次のターンは開始します。'
        option:     'オプション'
        exit_game:  'ゲームを終了します。'
        close_menu: 'メニューを閉じます。'
      position:
        setiing:    '{name} の開始位置を選択してください。'
      result:
        replay:     'リプレイします。'
        rematch:    '再戦します。'
        end_battle: '戦闘を終わります。'
        exit_game:  'ゲームを終了します。'
        close_menu: 'メニューを閉じます。'

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
