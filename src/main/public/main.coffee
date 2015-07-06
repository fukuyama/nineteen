
tm.main ->
  screen = nz.system.screen
  assets = nz.system.assets

  app = tm.display.CanvasApp '#world'
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
    if nz.system.loaded?
      nz.system.loaded.call(@,@app)
    else
      @app.replaceScene nz.SceneTitleMenu()
    return

  #app.pushScene SplashScene(
  #  width: screen.width
  #  height: screen.height
  #)

  # 実行
  app.run()

  #tm.inform()
