let project = new Project('Project GelaVolt');

project.addAssets('Assets/**');
project.addShaders('Shaders/**');
project.addSources('Sources');
project.addLibrary('hxbit');
project.addLibrary('colyseus-websocket')
project.addLibrary('colyseus-haxe')
project.addLibrary('peerhx')
project.addLibrary('safety')

project.addParameter('-main main.Main')
project.addParameter("--macro nullSafety('utils', Strict)")
project.addParameter("--macro nullSafety('main', Strict)")
project.addParameter("--macro nullSafety('ui', Strict)")
project.addParameter("--macro nullSafety('save_data', Strict)")
project.addParameter("--macro nullSafety('main_menu', Strict)")
project.addParameter("--macro nullSafety('input', Strict)")
project.addParameter("--macro nullSafety('lobby', Strict)")
project.addParameter("--macro Safety.safeNavigation('utils')")
project.addParameter("--macro Safety.safeNavigation('main')")
project.addParameter("--macro Safety.safeNavigation('ui')")
project.addParameter("--macro Safety.safeNavigation('save_data')")
project.addParameter("--macro Safety.safeNavigation('main_menu')")
project.addParameter("--macro Safety.safeNavigation('input')")
project.addParameter("--macro Safety.safeNavigation('lobby')")

project.addParameter("--macro nullSafety('game.actionbuffers', Strict)")
project.addParameter("--macro nullSafety('game.actions', Strict)")
project.addParameter("--macro nullSafety('game.auto_attack', Strict)")
project.addParameter("--macro nullSafety('game.backgrounds', Strict)")
project.addParameter("--macro nullSafety('game.boardmanagers', Strict)")
project.addParameter("--macro nullSafety('game.boards', Strict)")
project.addParameter("--macro nullSafety('game.boardstates', Strict)")
project.addParameter("--macro nullSafety('game.copying', Strict)")
project.addParameter("--macro nullSafety('game.fields', Strict)")
project.addParameter("--macro Safety.safeNavigation('game.actionbuffers')")
project.addParameter("--macro Safety.safeNavigation('game.actions')")
project.addParameter("--macro Safety.safeNavigation('game.auto_attack')")
project.addParameter("--macro Safety.safeNavigation('game.backgrounds')")
project.addParameter("--macro Safety.safeNavigation('game.boardmanagers')")
project.addParameter("--macro Safety.safeNavigation('game.boards')")
project.addParameter("--macro Safety.safeNavigation('game.boardstates')")
project.addParameter("--macro Safety.safeNavigation('game.copying')")
project.addParameter("--macro Safety.safeNavigation('game.fields')")

project.windowOptions.width = 1920;
project.windowOptions.height = 1080;

//project.addCDefine("HXCPP_STACK_LINE")
//project.addCDefine("HXCPP_DEBUG_LINK")

project.addDefine("kha_html5_disable_automatic_size_adjust")

resolve(project);
