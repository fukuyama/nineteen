###*
* @file SceneTitleMenu.coffee
* タイトルシーン
###

tm.define 'nz.SceneTitleMenu',
  superClass: tm.ui.MenuDialog

  ###* 初期化
  * @classdesc タイトルシーンクラス
  * @constructor nz.SceneTitleMenu
  ###
  init: () ->
    console.log 'SceneTitleMenu'
    screen = nz.system.screen
    menus = [
      {
        name: 'New Game'
        desctiption: '新しいゲームをはじめる'
        callback: @_new_game
      }
      {
        name: 'Load Game'
        desctiption: '保存したゲームをはじめる'
        callback: @_load_game
      }
      {
        name: 'Option'
        desctiption: 'ゲームオプション'
        callback: @_option
      }
    ]

    @superInit
      title: nz.system.title
      screenWidth: screen.width
      screenHeight: screen.height
      menu: for menu in menus then menu.name
      menuDesctiptions: for menu in menus then menu.desctiption
    @box.setStrokeStyle 'rgba(255,255,255, 0.8)'
    @box.setFillStyle 'rgba(0,0,128, 0.8)'

    @index = 0
    @on 'menuselected', (e) -> @index = e.selectIndex
    @on 'exit', (e) -> menus[@index].callback.call(@, e)

    return

  ###* 新しいゲームを開始
  * @constructor nz.SceneTitleMenu#
  ###
  _new_game: ->
    scene = nz.SceneBattle(mapId:1)
    @app.replaceScene scene
    scene.load()
    return

  ###* ゲームをロード
  * @constructor nz.SceneTitleMenu#
  ###
  _load_game: ->
    console.log 'load game'
    return

  ###* システムオプション
  * @constructor nz.SceneTitleMenu#
  ###
  _option: ->
    console.log 'option'
    return
