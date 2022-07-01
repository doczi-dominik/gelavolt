let project = new Project('Project GelaVolt');

project.addAssets('Assets/**');
project.addShaders('Shaders/**');
project.addSources('Sources');
project.addLibrary('haxe-ws');

project.windowOptions.width = 1920;
project.windowOptions.height = 1080;

resolve(project);
