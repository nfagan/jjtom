conf = jjtom.tmp_setdataroot( '/Volumes/My Passport/NICK/Chang Lab 2016/jess/tom' );
data_root = conf.PATHS.data_root;

plot_p = fullfile( data_root, 'plots', 'p_inbounds', datestr(now, 'mmddyy') );

kuro_files = { 'KrLu', 'KrRu', 'KrLe', 'KrRe' };
cron_files = { 'CnLu', 'CnRu', 'CnLe', 'CnRe' };

files = union( kuro_files, cron_files );
% files = cron_files;

max_t = 10e3;

outs = jjtom_get_looking_probability_timecourse( ...
    'config', conf ...
  , 'not_files', files ...
  , 'bin_width', 200 ...
  , 'look_back', 0 ...
  , 'look_ahead', max_t ...
  , 'is_parallel', true ...
  , 'separate_apparatus_and_face', true ...
  , 'normalize_looking_duration', true ...
  , 'proportional_fixation_looking_duration', false ...
  , 'maximum_normalization_window', Inf ...
  , 'fixation_looking_duration_proportions_each', {'apparatusl', 'apparatusr', 'facel', 'facer'} ...
  , 'event_subdir', 'recoded_events' ...
);

plot_p = jjtom.get_datadir( 'plots', conf );

%%  looking proportions -- to apple or hand

do_save = false;

pltdat = outs.n_fix_proportions;
pltlabs = outs.labels';

assert_ispair( pltdat, pltlabs );

mask = fcat.mask( pltlabs ...
  , @find, {'hand in box'} ...
  , @find, {'apparatusl', 'apparatusr', 'facel', 'facer'} ...
  , @find, 'tarantino' ...
);

pl = plotlabeled.make_common();
pl.x_tick_rotation = 0;
pl.y_lims = [0, 1];
pl.fig = figure(2);

xcats = { 'roi' };
gcats = { 'reach_type' };
pcats = { 'event', 'monkey', 'id', 'reach_direction' };

axs = pl.bar( pltdat(mask), pltlabs(mask), xcats, gcats, pcats );

if ( do_save )
  save_p = fullfile( plot_p, 'n_fix_proportions', datestr(now, 'mmddyy') );
  dsp3.req_savefig( gcf, save_p, pltlabs(mask), cshorzcat(gcats, pcats, xcats) );
end


