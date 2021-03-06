
phina.asset.AssetLoader.assetLoadFunctions.json = (key, path) ->
  file = phina.asset.File()
  return file.load
    path: path
    dataType: 'json'

phina.globalize()

# メイン処理(ページ読み込み後に実行される)
phina.main ->
  config = {}
  config.$safe
    title: nz.system.title
    assets: nz.system.assets
  config.$safe nz.system.screen

  run = (scenes) ->
    # アプリケーション生成
    nz.system.app = app = CanvasApp(config)

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
      nextLabel: 'titleMenu'

    scene 'titleMenu',
      className: 'nz.SceneTitleMenu'

    scene 'battle',
      className: 'nz.SceneBattle'
      arguments:
        mapId: 1

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
