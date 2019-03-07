function defaults = get_common_make_defaults()

defaults = struct();
defaults.config = jjtom.config.load();
defaults.files = [];
defaults.overwrite = false;
defaults.append = true;
defaults.save = true;
defaults.input_subdir = '';
defaults.output_subdir = '';
defaults.is_parallel = true;
defaults.skip_existing = true;

end