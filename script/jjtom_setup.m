conf = jjtom.config.create();

%   the repositories folder is assumed to be the folder housing the
%   jjtom/ repository. Dependencies will be installed in this folder.
%   Specify a different folder if you want dependencies to be installed
%   elswhere.
conf.PATHS.repositories = jjtom.util.get_repo_dir();

 %  fill in with custom folder to where you want data to be saved. By
 %  default, this is in a folder data/ alongside the +jjtom/ folder.
conf.PATHS.data_root = jjtom.util.get_data_dir();

%   installs + adds dependencies to path, if necessary.
jjtom.util.require_depends( conf );
jjtom.util.add_depends( conf );

jjtom.config.save( conf );