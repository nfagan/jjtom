function make_rois(varargin)

defaults = jjtom.get_common_make_defaults();
defaults.pad_x = 0;
defaults.pad_y = 0;

params = jjtom.parsestruct( defaults, varargin );

conf = params.config;
padding = struct( 'x', params.pad_x, 'y', params.pad_y );

isd = params.input_subdir;
osd = params.output_subdir;

edf_id = fullfile( 'edf', isd );
roi_p = jjtom.get_datadir( fullfile('roi', osd), conf );
monitor_p = jjtom.get_datadir( 'measurements/monitor', conf );
set_p = fullfile( monitor_p, 'sets' );
monk_p = jjtom.get_datadir( 'measurements/monkey', conf );

edf_mats = jjtom.get_datafiles( edf_id, conf, '.mat', params.files );

app_consts = jjtom.get_apparatus_constants();
app_dists = jjtom.get_apparatus_distances();
screen_consts = jjtom.get_screen_constants();

for i = 1:numel(edf_mats)
  shared_utils.general.progress( i, numel(edf_mats), mfilename );
  
  edf_file = shared_utils.io.fload( edf_mats{i} );
  screen_dist_file = jsonload( monitor_p, edf_file.fileid );
  
  const_dists = jsonload( set_p, screen_dist_file.set );
  dists = jsonload( monk_p, edf_file.fileid );
  
  fname = jjtom.ext( edf_file.fileid, '.mat' );
  output_fname = fullfile( roi_p, fname );
  
  if ( jjtom.check_overwrite(output_fname, params.overwrite) ), continue; end
  
  rois = struct();
  
  [app_dists, dists] = assign_dists( app_dists, dists, const_dists );
  
  rois.boxl = jjtom.get_lbox_roi( dists, screen_consts, app_dists, app_consts, padding );
  rois.boxr = jjtom.get_rbox_roi( dists, screen_consts, app_dists, app_consts, padding  );
  rois.lemon = jjtom.get_lemon_roi( dists, screen_consts, app_dists, app_consts, padding );  
  
  roi_file = struct();
  roi_file.params = params;
  roi_file.fileid = edf_file.fileid;
  roi_file.rois = rois;
  
  shared_utils.io.require_dir( roi_p );
  save( output_fname, 'roi_file' );
end

end

function [app_dists, dists] = assign_dists(app_dists, dists, const_dists)
app_dists.monitor_origin_to_app_origin_front_cm = const_dists.monitor_origin_to_app_origin_front_cm;
app_dists.monitor_origin_to_app_origin_left_cm = const_dists.monitor_origin_to_app_origin_left_cm;

dists.eye_to_monitor_top_cm = const_dists.monitor_origin_to_ground_cm - dists.eye_to_ground_cm;
end

function x = jsonload(p, id)
x = jsondecode(fileread(fullfile(p, jjtom.ext(id, '.json'))));
end