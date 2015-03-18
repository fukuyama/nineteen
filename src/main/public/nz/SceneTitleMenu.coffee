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
      screenWidth: nz.system.screen.width
      screenHeight: nz.system.screen.height
      menu: for menu in menus then menu.name
      menuDesctiptions: for menu in menus then menu.desctiption
    @box.setStrokeStyle nz.system.dialog.strokeStyle
    @box.setFillStyle nz.system.dialog.fillStyle

    @index = 0
    @on 'menuselected', (e) -> @index = e.selectIndex
    @on 'exit', (e) -> menus[@index].callback.call(@, e)
    @on 'enter', (e) -> @app.pushScene tm.scene.TitleScene(title:nz.system.title)

    return

  ###* 新しいゲームを開始
  * @constructor nz.SceneTitleMenu#
  ###
  _new_game: ->
    @app.replaceScene nz.SceneBattle(
      mapId:0
      characters: [
        nz.Character(name:'キャラクター１',mapx:5,mapy:5)
        nz.Character(name:'キャラクター２',mapx:0,mapy:0,direction:3)
      ]
    )
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
