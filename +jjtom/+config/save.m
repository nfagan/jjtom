
function save(conf)

%   SAVE -- Save the config file.

jjtom.util.assertions.assert__is_config( conf );
const = jjtom.config.constants();
fprintf( '\n Config file saved\n\n' );
save( fullfile(const.config_folder, const.config_filename), 'conf' );

%   mark that config needs updating
jjtom.config.load( '-clear' );

end