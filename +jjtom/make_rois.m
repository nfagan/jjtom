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

parfor i = 1:numel(edf_mats)
  shared_utils.general.progress( i, numel(edf_mats), mfilename );
  
  edf_file = shared_utils.io.fload( edf_mats{i} );
  screen_dist_file = jsonload( monitor_p, edf_file.fileid );
  
  const_dists = jsonload( set_p, screen_dist_file.set );
  dists = jsonload( monk_p, edf_file.fileid );
  
  fname = jjtom.ext( edf_file.fileid, '.mat' );
  output_fname = fullfile( roi_p, fname );
  
  if ( jjtom.check_overwrite(output_fname, params.overwrite) ), continue; end
  
  [adists, dists] = assign_dists( app_dists, dists, const_dists );
  
  rois = struct();
  
  roi_info = { dists, screen_consts, adists, app_consts, padding };
  
  rois.apparatus =  jjtom.get_apparatus_roi( roi_info{:} );
  rois.apparatusl = jjtom.get_lapparatus_roi( roi_info{:}, true );
  rois.apparatusr = jjtom.get_rapparatus_roi( roi_info{:}, true );
  rois.boxl =       jjtom.get_lbox_roi( roi_info{:} );
  rois.boxr =       jjtom.get_rbox_roi( roi_info{:}  );
  rois.lemon =      jjtom.get_lemon_roi( roi_info{:} );
  rois.face =       jjtom.get_face_roi( roi_info{:} );
  rois.facel =      jjtom.get_lface_roi( roi_info{:} );
  rois.facer =      jjtom.get_rface_roi( roi_info{:} );
  %   no restriction
  rois.all =        [ -Inf, -Inf, Inf, Inf ];
  
  roi_file = struct();
  roi_file.params = params;
  roi_file.fileid = edf_file.fileid;
  roi_file.rois = rois;
  
  shared_utils.io.require_dir( roi_p );
  shared_utils.io.psave( output_fname, roi_file, 'roi_file' );
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