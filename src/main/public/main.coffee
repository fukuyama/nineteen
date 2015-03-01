
tm.main ->
  screen = nz.system.screen
  assets = nz.system.assets

  app = tm.display.CanvasApp '#world'

  # リサイズ
  app.resize screen.width, screen.height

  # フィット
  app.fitWindow()

  # APバックグラウンド
  app.background = 'gray'
  
  # 最初のシーンに切り替える
  app.replaceScene tm.scene.LoadingScene(
    assets: assets
    width: screen.width
    height: screen.height
  ).on 'load', ->
    @app.replaceScene nz.SceneTitleMenu()
    return

  # 実行
  app.run()
