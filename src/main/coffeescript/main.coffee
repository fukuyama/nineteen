
phina.globalize()

# メイン処理(ページ読み込み後に実行される)
phina.main ->

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
    scene 'menu',
      className: 'MenuScene'
      arguments:
        menus: [
          {text: 'menu1'}
          {text: 'menu2test'}
          {text: 'menu3'}
        ]

    scene 'loading',
      className: 'LoadingScene'
      # nextLabel: 'splash'
      nextLabel: 'menu'

    scene 'splash',
      className: 'SplashScene'

    scene 'title',
      className: 'TitleScene'
  ]

  return
