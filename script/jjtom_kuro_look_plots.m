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
  , 'files', files ...
  , 'bin_width', 500 ...
  , 'look_back', 0 ...
  , 'look_ahead', max_t ...
  , 'is_parallel', true ...
  , 'separate_apparatus_and_face', true ...
  , 'normalize_looking_duration', true ...
  , 'proportional_fixation_looking_duration', false ...
  , 'maximum_normalization_window', Inf ...
  , 'fixation_looking_duration_proportions_each', {'apparatusl', 'apparatusr', 'face'} ...
);

plot_p = jjtom.get_datadir( 'plots', conf );

%%  time course -- apparatus expected vs. unexpected

pltdat = outs.probabilities;
pltlabs = outs.labels';
time_course = outs.t;

assert_ispair( pltdat, pltlabs );

mask = fcat.mask( pltlabs ...
  , @find, {'test-reach'} ...
  , @find, {'apparatus'} ...
);

pl = plotlabeled();
pl.one_legend = true;
pl.x = time_course;
pl.add_errors = false;

% gcats = { 'roi' };
% pcats = { 'monkey', 'event',  'expected_type' };

gcats = { 'expected_type' };
pcats = { 'roi', 'monkey' };

axs = pl.lines( pltdat(mask, :), pltlabs(mask), gcats, pcats );

shared_utils.plot.hold( axs, 'on' );
shared_utils.plot.add_vertical_lines( axs, find(time_course == 0) );

%%  time course -- apparatus left vs right

pltdat = outs.probabilities;
% pltdat = outs.duration_timecourse;
pltlabs = outs.labels';
time_course = outs.t;

do_save = false;

assert_ispair( pltdat, pltlabs );

mask = fcat.mask( pltlabs ...
  , @find, {'test-reach'} ...
  , @find, {'apparatusl', 'apparatusr'} ...
  , @find, 'cron' ...
);

pl = plotlabeled();
pl.one_legend = true;
pl.x = time_course;
pl.add_errors = false;
pl.fig = figure(3);

% gcats = { 'roi' };
% pcats = { 'monkey', 'event',  'expected_type' };

gcats = { 'roi' };
pcats = { 'expected_type', 'target_direction', 'reach_direction', 'id' };

axs = pl.lines( pltdat(mask, :), pltlabs(mask), gcats, pcats );

shared_utils.plot.hold( axs, 'on' );
shared_utils.plot.add_vertical_lines( axs, find(time_course == 0) );

if ( do_save )
  save_p = fullfile( plot_p, 'timecourse', datestr(now, 'mmddyy') );
  dsp3.req_savefig( gcf, save_p, pltlabs(mask), csunion(gcats, pcats) );
end

%%  time course -- looks to reach

do_save = true;

% pltdat = outs.probabilities;
pltdat = outs.duration_timecourse;
pltlabs = outs.labels';
time_course = outs.t;

side_roi = 'apparatus';
left_roi = sprintf( '%sl', side_roi );
right_roi = sprintf( '%sr', side_roi );

t_window = [ 0, 1e3 ];

assert_ispair( pltdat, pltlabs );

mask = fcat.mask( pltlabs ...
  , @find, {'test-reach'} ...
  , @find, {left_roi, right_roi} ...
);

is_look_to_reach_right = find( pltlabs, {'reach-right', right_roi } );
is_look_to_reach_left = find( pltlabs, {'reach-left', left_roi } );
is_look_to_reach = union( is_look_to_reach_left, is_look_to_reach_right );

is_look_to_non_reach_right = find( pltlabs, {'reach-right', left_roi } );
is_look_to_non_reach_left = find( pltlabs, {'reach-left', right_roi } );
is_look_to_non_reach = union( is_look_to_non_reach_left, is_look_to_non_reach_right );

setcat( pltlabs, 'roi', 'reach', is_look_to_reach );
setcat( pltlabs, 'roi', 'non-reach', is_look_to_non_reach );

pl = plotlabeled();
pl.one_legend = true;
pl.x = time_course;
pl.add_errors = false;
pl.fig = figure(2);

% gcats = { 'roi' };
% pcats = { 'monkey', 'event',  'expected_type' };

gcats = { 'expected_type' };
pcats = { 'monkey', 'event',  'roi' };

mask = fcat.mask( pltlabs, mask, @find, 'reach' );

axs = pl.lines( pltdat(mask, :), pltlabs(mask), gcats, pcats );

shared_utils.plot.hold( axs, 'on' );
shared_utils.plot.add_vertical_lines( axs, find(time_course == 0) );

if ( do_save )
  save_p = fullfile( plot_p, 'duration_timecourse', datestr(now, 'mmddyy') );
  dsp3.req_savefig( gcf, save_p, pltlabs(mask), cshorzcat(gcats, pcats) ...
    , side_roi );
end

pl = plotlabeled.make_common();
pl.fig = figure(2);
t_ind = outs.t >= t_window(1) & outs.t <= t_window(2);

meandat = nanmean( pltdat(:, t_ind), 2 );

xcats = {};

% pl.bar( meandat(mask), pltlabs(mask), xcats, gcats, pcats );

%%  time course -- looks to apple

pltdat = outs.probabilities;
pltlabs = outs.labels';
time_course = outs.t;

assert_ispair( pltdat, pltlabs );

mask = fcat.mask( pltlabs ...
  , @find, {'test-reach'} ...
  , @find, {'apparatusl', 'apparatusr'} ...
  , @find, 'cron' ...
);

is_look_to_apple_right = find( pltlabs, {'apparatusr', 'KrRe', 'KrRu', 'CnRe', 'CnRu'}, mask );
is_look_to_apple_left = find( pltlabs, {'apparatusl', 'KrLe', 'KrLu', 'CnLe', 'CnLu'}, mask );
is_look_to_apple = union( is_look_to_apple_left, is_look_to_apple_right );

is_look_to_hand_right = find( pltlabs, {'apparatusr', 'KrRu', 'KrLe', 'CnRu', 'CnLe'}, mask );
is_look_to_hand_left = find( pltlabs, {'apparatusl', 'KrLu', 'KrRe', 'CnLu', 'CnRe'}, mask );
is_look_to_hand = union( is_look_to_hand_left, is_look_to_hand_right );

setcat( pltlabs, 'roi', 'apple', is_look_to_apple );
setcat( pltlabs, 'roi', 'hand', is_look_to_hand );

% is_coherence = find( pltlabs, {'KrLu', 'KrRu'

pl = plotlabeled();
pl.one_legend = true;
pl.x = time_course;
pl.add_errors = false;

gcats = { 'roi' };
pcats = { 'monkey', 'event',  'expected_type' };

mask = fcat.mask( pltlabs, is_look_to_apple, @find, {'apple', 'hand'} );

axs = pl.lines( pltdat(mask, :), pltlabs(mask), gcats, pcats );

shared_utils.plot.hold( axs, 'on' );
shared_utils.plot.add_vertical_lines( axs, find(time_course == 0) );

%%  looking duration -- to apparatus

pltdat = outs.looking_duration;
pltlabs = outs.labels';

assert_ispair( pltdat, pltlabs );

mask = fcat.mask( pltlabs ...
  , @find, {'test-reach'} ...
  , @find, {'apparatusl', 'apparatusr'} ...
);

is_look_to_reach_right = find( pltlabs, {'reach-right', 'apparatusr' } );
is_look_to_reach_left = find( pltlabs, {'reach-left', 'apparatusl' } );
is_look_to_reach = union( is_look_to_reach_left, is_look_to_reach_right );

is_look_to_non_reach_right = find( pltlabs, {'reach-right', 'apparatusl' } );
is_look_to_non_reach_left = find( pltlabs, {'reach-left', 'apparatusr' } );
is_look_to_non_reach = union( is_look_to_non_reach_left, is_look_to_non_reach_right );

setcat( pltlabs, 'roi', 'reach', is_look_to_reach );
setcat( pltlabs, 'roi', 'non-reach', is_look_to_non_reach );

pl = plotlabeled.make_common();
pl.x_tick_rotation = 0;
pl.fig = figure(3);

xcats = { 'roi' };
gcats = { 'expected_type' };
pcats = { 'monkey', 'event' };

axs = pl.bar( pltdat(mask), pltlabs(mask), xcats, gcats, pcats );

%%  looking duratinon -- to apparatus overall

pltdat = outs.fix_looking_duration;
pltlabs = outs.labels';

assert_ispair( pltdat, pltlabs );

mask = fcat.mask( pltlabs ...
  , @find, {'test-reach'} ...
  , @find, {'apparatus'} ...
);

pl = plotlabeled.make_common();
pl.x_tick_rotation = 0;
pl.fig = figure(3);

xcats = { 'roi' };
gcats = { 'expected_type' };
pcats = { 'event', 'monkey' };

axs = pl.bar( pltdat(mask), pltlabs(mask), xcats, gcats, pcats );

if ( do_save )
  save_p = fullfile( plot_p, 'fixation_dur' );
  dsp3.req_savefig( gcf, save_p, pltlabs(mask), cshorzcat(gcats, pcats, xcats) ...
    , 'overall_looking_to_apparatus' );
end

%%  looking duration -- to apple or hand

do_save = true;
is_per_monkey = false;

pltdat = outs.fix_looking_duration;
pltlabs = outs.labels';

use_roi = 'apple';
side_roi = 'face';

assert_ispair( pltdat, pltlabs );

mask = fcat.mask( pltlabs ...
  , @find, {'test-reach'} ...
  , @find, {sprintf('%sl', side_roi), sprintf('%sr', side_roi)} ...
);

switch ( use_roi )
  case 'hand'
    jjtom.fb_label_hand( pltlabs, mask );
  case 'apple'
    jjtom.fb_label_apple( pltlabs, mask );
  otherwise
    error( 'Missing: %s.', use_roi );
end

mask = find( pltlabs, use_roi, mask );

pl = plotlabeled.make_common();
pl.x_tick_rotation = 0;
pl.fig = figure(3);

xcats = { 'roi' };
gcats = { 'expected_type' };
pcats = { 'event', 'monkey' };

if ( ~is_per_monkey )
  collapsecat( pltlabs, 'monkey' );
end

axs = pl.bar( pltdat(mask), pltlabs(mask), xcats, gcats, pcats );

if ( do_save )
  save_p = fullfile( plot_p, 'fixation_dur' );
  dsp3.req_savefig( gcf, save_p, pltlabs(mask), cshorzcat(gcats, pcats, xcats), side_roi );
end

%%  looking proportions -- to apple or hand

pltdat = outs.n_fix_proportions;
pltlabs = outs.labels';

assert_ispair( pltdat, pltlabs );

mask = fcat.mask( pltlabs ...
  , @find, {'test-reach'} ...
  , @find, {'apparatusl', 'apparatusr', 'face'} ...
  , @find, 'cron' ...
);

% [roi_labs, roi_mask] = jjtom.fb_label_hand( pltlabs', mask );
% roi_labs = roi_labs(roi_mask);
% roi_dat = pltdat(roi_mask);
% 
% rest_ind = find( pltlabs, 'face', setdiff(mask, roi_mask) );
% rest_labs = pltlabs( rest_ind );
% rest_dat = pltdat( rest_ind );
% 
% pltdat = [ rest_dat; roi_dat ];
% pltlabs = [ rest_labs; roi_labs ];
% 
pl = plotlabeled.make_common();
pl.x_tick_rotation = 0;
pl.y_lims = [0, 1];
pl.fig = figure(2);

xcats = { 'roi' };
gcats = { };
pcats = { 'event', 'id', 'expected_type' };

axs = pl.bar( pltdat(mask), pltlabs(mask), xcats, gcats, pcats );
% axs = pl.bar( pltdat, pltlabs, xcats, gcats, pcats );

if ( do_save )
  save_p = fullfile( plot_p, 'n_fix_proportions', datestr(now, 'mmddyy') );
  dsp3.req_savefig( gcf, save_p, pltlabs(mask), cshorzcat(gcats, pcats, xcats) );
end



