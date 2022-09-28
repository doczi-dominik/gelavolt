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
project.addParameter("--macro Safety.safeNavigation('utils')")
project.addParameter("--macro Safety.safeNavigation('main')")
project.addParameter("--macro Safety.safeNavigation('ui')")
project.addParameter("--macro nullSafety('utils', Strict)")
project.addParameter("--macro nullSafety('main', Strict)")
project.addParameter("--macro nullSafety('ui', Strict)")

project.windowOptions.width = 1920;
project.windowOptions.height = 1080;

resolve(project);
