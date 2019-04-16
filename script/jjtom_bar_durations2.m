function jjtom_bar_durations2(varargin)

defaults.do_normalize = true;
defaults.normalize_per_roi = true;
defaults.per_monkey = true;
defaults.do_save = false;
defaults.target_roi = 'apparatus-lr';
defaults.apple_or_hand = 'apple';
defaults.config = jjtom.config.load();
defaults.files = {};
defaults.not_files = {};
defaults.separate_apparatus_and_face = false;
defaults.event_subdir = 'events';
defaults.recoded_reach_event_name = 'hand in box';
defaults.recoded_normalization_event_name = 'ft2-start';
defaults.recoded_normalization_look_ahead = 5e3;
defaults.base_prefix = '';
defaults.base_subdir = '';
defaults.start_event_name = 'test-reach';
defaults.look_ahead = 5e3;
defaults.look_back = 0;

params = jjtom.parsestruct( defaults, varargin );

conf = params.config;
events_subdir = validatestring( params.event_subdir, {'events', 'recoded_events'} );

is_recoded_events = strcmp( events_subdir, 'recoded_events' );

params.base_plotp = fullfile( conf.PATHS.data_root, 'plots' );
params.base_analysisp = fullfile( conf.PATHS.data_root, 'analyses' );

fix_p = jjtom.get_datadir( 'edf/events', conf );
roi_p = jjtom.get_datadir( 'roi', conf );
lab_p = jjtom.get_datadir( 'labels', conf );

evt_mats = jjtom.get_datafiles( events_subdir, conf );
evt_mats = shared_utils.io.filter_files( evt_mats, params.files, params.not_files );

min_dur = 25;
look_back = params.look_back;
look_ahead = params.look_ahead;

nfixs = [];
durs = [];
durlabs = fcat();

normdat = [];
normlabs = fcat();

for i = 1:numel(evt_mats)
  evt_file = jjtom.fload( evt_mats{i} );
  fname = jjtom.ext( evt_file.fileid, '.mat' );
  lab_file = jjtom.fload( fullfile(lab_p, fname) );
  fix_file = jjtom.fload( fullfile(fix_p, fname) );
  roi_file = jjtom.fload( fullfile(roi_p, fname) );
  
  metalabs = fcat.from( lab_file.labels, lab_file.categories );
  
  if ( is_recoded_events )
    recoded_reach_event_name = params.recoded_reach_event_name;
    recoded_reach_event_name_idx = strcmp( evt_file.key, recoded_reach_event_name );    
    
    assert( nnz(recoded_reach_event_name_idx) == 1, 'Missing recoded event name: "%s".' ...
      , recoded_reach_event_name );
    
    evt_file.key{recoded_reach_event_name_idx} = 'test-reach';
  end
  
  evts = evt_file.events;
  
  fix_x = fix_file.fix_x;
  fix_y = fix_file.fix_y;
  fix_starts = fix_file.fix_start;
  fix_stops = fix_file.fix_stop;
  fix_durs = fix_stops - fix_starts;
  
  rois = struct2cell( roi_file.rois );
  roi_names = fieldnames( roi_file.rois );
  
  inds = combvec( 1:numel(evts), 1:numel(roi_names) );
  n_combs = size( inds, 2 );
  
  ib_fixs = cell( numel(rois), 1 );
  for j = 1:numel(rois)
    ib_fixs{j} = jjtom.rectbounds( fix_x, fix_y, rois{j} );
  end
  
  if ( params.separate_apparatus_and_face )
    ib_fixs = separate_apparatus_and_face( ib_fixs, roi_names );
  end
  
  for j = 1:n_combs
    evt_ind = inds(1, j);
    roi_ind = inds(2, j);
    
%     roi = rois{roi_ind};
    roi_name = roi_names{roi_ind};
    
    evt = evts(evt_ind);
    evt_name = evt_file.key(evt_ind);
    
    cats = { 'event', 'roi' };
    labs = [ evt_name, roi_name ];
    
    evtlabs = setcat( addcat(fcat(), cats), cats, [evt_name, roi_name] );
    jointlabs = join( evtlabs, metalabs );
    
    start = evt + look_back;
    stop = evt + look_ahead;
    
    ib_t = fix_starts >= evt + look_back & fix_starts <= evt + look_ahead;
    ib_pos = ib_fixs{roi_ind};
    
    ib = ib_t & ib_pos;
    
    nfixs = [ nfixs; sum(ib) ];
    durs = [ durs; sum(fix_durs(ib)) ];
    
    append( durlabs, jointlabs );
  end    
  
  %
  % norm
  %
  
  if ( is_recoded_events )
    evt1 = evt_file.events( strcmp(evt_file.key, params.recoded_normalization_event_name) );
    evt2 = evt1 + params.recoded_normalization_look_ahead;
    
  else
    evt1 = strcmp( evt_file.key, 'od-3' );
    evt2 = strcmp( evt_file.key, 'test-reach' );

    assert( sum(evt1 | evt2) == 2, 'Missing events' );

    evt1 = evt_file.events(evt1);
    evt2 = evt_file.events(evt2);
  end
  
  ib_t = fix_starts >= evt1 & fix_starts <= evt2;
  
  for j = 1:numel(rois)
    if ( params.normalize_per_roi )
      ib_pos = ib_fixs{j};
    else
      ib_pos = ib_fixs{strcmp(roi_names, 'apparatus')};
    end
    
    ib_evts = ib_t & ib_pos;
    
    evtlabs = setcat( addcat(fcat(), 'roi'), 'roi', roi_names{j} );
    jointlabs = join( evtlabs, metalabs );
    
    append( normlabs, jointlabs );
    normdat = [ normdat; sum(fix_durs(ib_evts)) ];
  end
end


%%  norm

if ( params.do_normalize )
  [I_time, C] = findall( durlabs, getcats(normlabs) );
  
  for i = 1:numel(I_time)
    matching = find( normlabs, C(:, i) );
    
    assert( numel(matching) == 1 );
    
    durs(I_time{i}) = durs(I_time{i}) / normdat(matching);
  end
end

durs( isinf(durs) ) = NaN;

%%

targcat = 'target';

pltlabs = durlabs';

all_apples = jjtom.get_apple_indices( pltlabs );
all_hands = jjtom.get_hand_indices( pltlabs );

replace( pltlabs, 'left', 'reach-to-left' );
replace( pltlabs, 'right', 'reach-to-right' );
replace( pltlabs, 'apparatusl', 'apparatus-left' );
replace( pltlabs, 'apparatusr', 'apparatus-right' );
replace( pltlabs, 'boxl', 'box-left' );
replace( pltlabs, 'boxr', 'box-right' );
replace( pltlabs, 'facel', 'face-left' );
replace( pltlabs, 'facer', 'face-right' );

replabs = addcat( pltlabs', targcat );

applelabs = setcat( replabs', targcat, 'apple', all_apples );
handlabs = setcat( replabs', targcat, 'hand', all_hands );
replabs = append( applelabs', handlabs );

repdur = repmat( durs, 2, 1 );
repfix = repmat( nfixs, 2, 1 );

alldata = [ repdur; repfix ];

repset( addcat(replabs, 'measure'), 'measure', {'duration', 'nfix'} );
prune( replabs );

%%

handle_apparatus_looking( alldata, replabs', params );
handle_per_roi_looking( alldata, replabs', params )

end

function handle_apparatus_looking(pltdat, pltlabs, params)

%%  overall looking

prefix = sprintf( '%soverall__duration', params.base_prefix );

normpref = ternary( params.do_normalize, 'normalized', 'non-normalized' );
monkpref = ternary( params.per_monkey, 'per-monkey', 'across-monkey' );

prefix = sprintf( '%s_%s', normpref, prefix );

pl = plotlabeled.make_common();
pl.x_tick_rotation = 0;

xs = { 'reach_type' };
groups = { 'event' };
panels = { 'target', 'measure', 'roi', 'monkey' };

mask = fcat.mask( pltlabs, @find, {params.start_event_name, 'duration', 'apparatus'} );
mask = findnone( pltlabs, 'ephron', mask );

if ( ~params.per_monkey )
  collapsecat( pltlabs, 'monkey' );
end

pl.bar( pltdat(mask), pltlabs(mask), xs, groups, panels );

plot_p = fullfile( jjtom.fname(pltlabs(mask), 'measure'), jjtom.datedir );
plot_p = fullfile( params.base_plotp, plot_p, params.base_subdir, normpref );

if ( params.do_save )  
  cats = dsp3.nonun_or_all( pltlabs, unique(cshorzcat(xs, groups, panels)) );
  dsp3.req_savefig( gcf, plot_p, pltlabs(mask), cats, prefix );
  
end

%%  ttest

ttest_mask = intersect( mask, find(~isnan(pltdat)) );

ttest_outs = dsp3.ttest2( pltdat, pltlabs', {'monkey'}, 'consistent', 'inconsistent' ...
  , 'mask', ttest_mask );

if ( params.do_save )
  plot_path_components = fullfile( 'duration', dsp3.datedir, 'task1', params.base_subdir, 'overall', normpref, monkpref );
  analysis_p = fullfile( params.base_analysisp, plot_path_components );
  
  dsp3.save_ttest2_outputs( ttest_outs, analysis_p );
end

end

function handle_per_roi_looking(pltdat, pltlabs, params)

%%  overall looking

target_roi = params.target_roi;

replace( pltlabs, {'box-left', 'box-right'}, 'box-lr' );
% replace( pltlabs, {'apparatus-left', 'apparatus-right'}, target_roi );
replace( pltlabs, {'apparatus-left', 'apparatus-right'}, 'apparatus-lr' );
replace( pltlabs, {'face-left', 'face-right'}, 'face-lr' );

prefix = sprintf( '%soverall__duration', params.base_prefix );

normpref = ternary( params.do_normalize, 'normalized', 'non-normalized' );
monkpref = ternary( params.per_monkey, 'per-monkey', 'across-monkey' );

prefix = sprintf( '%s_%s', normpref, prefix );

pl = plotlabeled.make_common();
pl.x_tick_rotation = 0;

xs = { 'reach_type' };
groups = { 'event' };
panels = { 'target', 'measure', 'roi', 'monkey' };

mask = fcat.mask( pltlabs, @find, {params.start_event_name, 'duration', params.apple_or_hand, target_roi} );
mask = findnone( pltlabs, 'ephron', mask );

if ( ~params.per_monkey )
  collapsecat( pltlabs, 'monkey' );
end

pl.bar( pltdat(mask), pltlabs(mask), xs, groups, panels );

plot_p = fullfile( jjtom.fname(pltlabs(mask), 'measure'), jjtom.datedir );
plot_p = fullfile( params.base_plotp, plot_p, params.base_subdir, normpref );

if ( params.do_save )  
  cats = dsp3.nonun_or_all( pltlabs, unique(cshorzcat(xs, groups, panels)) );
  dsp3.req_savefig( gcf, plot_p, pltlabs(mask), cats, prefix );
end

%%  ttest

ttest_mask = intersect( mask, find(~isnan(pltdat)) );

ttest_outs = dsp3.ttest2( pltdat, pltlabs', {'monkey', 'roi'} ...
  , 'consistent', 'inconsistent' ...
  , 'mask', ttest_mask );

if ( params.do_save )
  plot_path_components = fullfile( 'duration', dsp3.datedir, 'task1', params.base_subdir, 'per-roi', normpref, monkpref );
  analysis_p = fullfile( params.base_analysisp, plot_path_components );
  
  dsp3.save_ttest2_outputs( ttest_outs, analysis_p );
end

end

function ib_fixs = separate_apparatus_and_face(ib_fixs, roi_names)

apparatus_l = strcmp( roi_names, 'apparatusl' );
apparatus_r = strcmp( roi_names, 'apparatusr' );

face_l = strcmp( roi_names, 'facel' );
face_r = strcmp( roi_names, 'facer' );

assert( nnz(apparatus_l | apparatus_r | face_l | face_r) == 4 );

is_ib_face = ib_fixs{face_l} | ib_fixs{face_r};

% Remove fixations that overlap between face and apparatus
ib_fixs{apparatus_l}(is_ib_face) = false;
ib_fixs{apparatus_r}(is_ib_face) = false;

end


