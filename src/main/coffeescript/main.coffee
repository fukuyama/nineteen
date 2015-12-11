
phina.globalize()

# メイン処理(ページ読み込み後に実行される)
phina.main ->

  config =
    assets: nz.system.assets
  config.$safe nz.system.screen

  run = (scenes) ->
    # アプリケーション生成
    app = CanvasApp(config)

    # シーン設定
    app.replaceScene ManagerScene scenes: scenes

    # アプリケーション実行
    app.run()
    return

  scene = (label, param) ->
    if param.arguments?
      param.arguments.$safe config
    param.$safe
      label:     label
      arguments: config
      nextLabel: 'title'

  run [
    scene 'loading',
      className: 'LoadingScene'
      # nextLabel: 'splash'

    scene 'splash',
      className: 'SplashScene'

    scene 'title',
      className: 'TitleScene'
      nextLabel: 'title_menu'

    scene 'title_menu',
      className: 'nz.SceneTitleMenu'

    scene 'menu',
      className: 'MenuScene'
      arguments:
        fontSize: 24
        menus: [
          {text: 'menu1'}
          {text: 'menu2test'}
          {text: 'menu3'}
        ]
  ]

  return
