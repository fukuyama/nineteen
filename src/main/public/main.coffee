
tm.main ->
  screen = nz.system.screen
  assets = nz.system.assets

  nz.app = app = tm.display.CanvasApp '#world'

  # リサイズ
  app.resize screen.width, screen.height

  # フィット
  app.fitWindow()

  # APバックグラウンド
  app.background = 'gray'
  
  # 最初のシーンに切り替える
  app.pushScene tm.scene.LoadingScene(
    assets: assets
    width: screen.width
    height: screen.height
  ).on 'load', ->
    @app.pushScene nz.SceneTitleMenu()
    @app.pushScene tm.scene.TitleScene()
    return

  # 実行
  app.run()
