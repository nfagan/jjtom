conf = jjtom.config.create();

conf.PATHS.repositories = jjtom.util.get_repo_dir();
% conf.PATHS.repositories = ''; % fill in with a custom folder if you want.

jjtom.util.require_depends( conf );
jjtom.util.add_depends( conf );

jjtom.config.save( conf );