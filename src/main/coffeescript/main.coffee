
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
    param.$safe
      label:     label
      arguments: config
      nextLabel: 'title'

  run [
    scene 'loading',
      className: 'LoadingScene'
      nextLabel: 'splash'

    scene 'splash',
      className: 'SplashScene'

    scene 'title',
      className: 'TitleScene'
      nextLabel: 'menu'

    scene 'menu',
      className: 'MenuScene'
      arguments: {
        bg:
          width: 100
          height: 100
      }.$safe config
  ]

  return
