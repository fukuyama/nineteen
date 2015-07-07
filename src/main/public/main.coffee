
tm.main ->
  screen = nz.system.screen
  assets = nz.system.assets

  nz.system.app = app = tm.display.CanvasApp '#world'
  # app.enableStats()

  # リサイズ
  app.resize screen.width, screen.height

  # フィット
  app.fitWindow()

  # APバックグラウンド
  app.background = 'gray'
  
  # 最初のシーンに切り替える
  app.pushScene tm.game.LoadingScene(
    assets: assets
    width: screen.width
    height: screen.height
  ).on 'load', (e) ->
    @app.fitWindow()
    nz.system.start()
    return

  #app.pushScene SplashScene(
  #  width: screen.width
  #  height: screen.height
  #)

  # 実行
  app.run()

  #tm.inform()
