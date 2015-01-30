###*
* @file SceneTitle.coffee
* タイトルシーン
###

tm.define 'nz.SceneTitle',
  superClass: tm.ui.MenuDialog

  ###* 初期化
  * @classdesc タイトルシーンクラス
  * @constructor nz.SceneTitle
  ###
  init: () ->
    console.log 'SceneTitle'
    sys = nz.system
    @superInit
      screenWidth: sys.screen.width
      screenHeight: sys.screen.height
      menu: [
        'New Game'
        'TEST'
      ]
      menuDesctiptions: [
        '新しいゲームをはじめる'
        'テスト'
      ]
    @_fn = [
      @_new_game
      @_test
    ]
    @on 'menuselected', (e) -> @_fn[e.selectIndex].call(@)
    return

  ###* 新しいゲームを開始
  * @constructor nz.SceneTitle#
  ###
  _new_game: ->
    @app.replaceScene nz.SceneBattle()
    return

  ###* TEST
  * @constructor nz.SceneTitle#
  ###
  _test: ->
    console.log 'test'
    return
