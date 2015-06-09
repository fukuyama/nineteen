###*
* @file SceneTitleMenu.coffee
* タイトルシーン
###

tm.define 'nz.SceneTitleMenu',
  superClass: nz.SceneMenu

  ###* 初期化
  * @classdesc タイトルシーンクラス
  * @constructor nz.SceneTitleMenu
  ###
  init: () ->
    menu = [
      {
        name: 'New Game'
        desctiption: '新しいゲームをはじめる'
        func: @_new_game
      }
      {
        name: 'Load Game'
        desctiption: '保存したゲームをはじめる'
        func: @_load_game
      }
      {
        name: 'Option'
        desctiption: 'ゲームオプション'
        func: @_option
      }
      {
        name: 'Debug Game'
        desctiption: 'デバックゲーム'
        func: @_debug_game
      }
    ]

    @superInit
      title: nz.system.title
      menu: menu
    @box.setStrokeStyle nz.system.dialog.strokeStyle
    @box.setFillStyle nz.system.dialog.fillStyle

    @on 'enter', (e) -> @app.pushScene tm.game.TitleScene(title:nz.system.title)

    return

  ###* 新しいゲームを開始
  * @constructor nz.SceneTitleMenu#
  ###
  _new_game: ->
    @app.pushScene nz.SceneBattle(
      mapId: 1
      controlTeam: ['teamA']
      characters: [
        new nz.Character(name:'キャラクター1',team:'teamA')
        new nz.Character(name:'キャラクター2',team:'teamA')
        new nz.Character(name:'キャラクター3',team:'teamA')
        new nz.Character(name:'キャラクター4',team:'teamB')
        new nz.Character(name:'キャラクター5',team:'teamB')
        new nz.Character(name:'キャラクター6',team:'teamB')
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

  ###* 新しいゲームを開始
  * @constructor nz.SceneTitleMenu#
  ###
  _debug_game: ->
    @app.pushScene nz.SceneBattle(
      mapId: 0
      controlTeam: ['teamA']
      characters: [
        new nz.Character(
          name:'キャラクター1'
          team:'teamA'
          spriteSheet:'character_test'
          weapon:
            damage: 20
        )
        new nz.Character(name:'キャラクター2',team:'teamA',spriteSheet:'character_test')
        new nz.Character(name:'キャラクター3',team:'teamA',spriteSheet:'character_test')
        new nz.Character(name:'キャラクター4',team:'teamB',spriteSheet:'character_test')
        #new nz.Character(name:'キャラクター5',team:'teamB',spriteSheet:'character_test')
        #new nz.Character(name:'キャラクター6',team:'teamB',spriteSheet:'character_test')
      ]
    )
    return
