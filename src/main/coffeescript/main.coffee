
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

  scene = (param) ->
    {
      arguments: config
      nextLabel: 'title'
    }.$safe param

  run [
    scene
      className: 'LoadingScene'
      label:     'loading'
      nextLabel: 'splash'
    scene
      className: 'SplashScene'
      label:     'splash'
    scene
      className: 'TitleScene'
      label:     'title'
  ]

  return
