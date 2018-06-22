
function add_depends()

%   ADD_DEPENDS -- Add dependencies as defined in the config file.

conf = jjtom.config.load();

repos = conf.DEPENDS.repositories;
repo_dir = conf.PATHS.repositories;

for i = 1:numel(repos)
  addpath( genpath(fullfile(repo_dir, repos{i})) );
end

if ( isfield(conf.DEPENDS, 'others') )
  others = conf.DEPENDS.others;
  
  if ( ~iscell(others) ), others = { others }; end
  
  cellfun( @(x) addpath(genpath(x)), others );
end

end