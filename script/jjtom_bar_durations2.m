function jjtom_bar_durations2(varargin)

defaults.do_normalize = true;
defaults.per_monkey = true;
defaults.do_save = false;
defaults.target_roi = 'apparatus-lr';
defaults.apple_or_hand = 'apple';
defaults.config = jjtom.config.load();
defaults.files = {};
defaults.not_files = {};
defaults.separate_apparatus_and_face = false;

params = jjtom.parsestruct( defaults, varargin );

conf = params.config;

base_plotp = fullfile( conf.PATHS.data_root, 'plots' );

fix_p = jjtom.get_datadir( 'edf/events', conf );
roi_p = jjtom.get_datadir( 'roi', conf );
lab_p = jjtom.get_datadir( 'labels', conf );

evt_mats = jjtom.get_datafiles( 'events', conf );
evt_mats = shared_utils.io.filter_files( evt_mats, params.files, params.not_files );

do_normalize = params.do_normalize;
per_monk = params.per_monkey;
do_save = params.do_save;

min_dur = 25;
look_back = -2e3;
look_ahead = 10e3;

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
  
  evt1 = strcmp( evt_file.key, 'od-3' );
  evt2 = strcmp( evt_file.key, 'test-reach' );
  assert( sum(evt1 | evt2) == 2, 'Missing events' );
  
  evt1 = evt_file.events(evt1);
  evt2 = evt_file.events(evt2);
  
  ib_t = fix_starts >= evt1 & fix_starts <= evt2;
  
  for j = 1:numel(rois)
    roi = rois{j};
    
    ib_pos = ib_fixs{j};
    
    ib_evts = ib_t & ib_pos;
    
    evtlabs = setcat( addcat(fcat(), 'roi'), 'roi', roi_names{j} );
    jointlabs = join( evtlabs, metalabs );
    
    append( normlabs, jointlabs );
    normdat = [ normdat; sum(fix_durs(ib_evts)) ];
  end
end


%%  norm

if ( do_normalize )
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

%%  overall looking

pltdat = alldata;
pltlabs = replabs';

prefix = 'overall__duration';

normpref = ternary( do_normalize, 'normalized', 'non-normalized' );
prefix = sprintf( '%s_%s', normpref, prefix );

pl = plotlabeled.make_common();
pl.x_tick_rotation = 0;

xs = { 'reach_type' };
groups = { 'event' };
panels = { 'target', 'measure', 'roi', 'monkey' };

if ( ~per_monk )
  collapsecat( pltlabs, 'monkey' );
end

mask = fcat.mask( pltlabs, @find, {'test-reach', 'duration', 'apparatus'} );

pl.bar( pltdat(mask), pltlabs(mask), xs, groups, panels );

plot_p = fullfile( jjtom.fname(pltlabs(mask), 'measure'), jjtom.datedir );
plot_p = fullfile( base_plotp, plot_p );

if ( do_save )  
  cats = dsp3.nonun_or_all( pltlabs, unique(cshorzcat(xs, groups, panels)) );
  dsp3.req_savefig( gcf, plot_p, pltlabs(mask), cats, prefix );
  
end

%%  overall looking

pltdat = alldata;
pltlabs = replabs';

target_roi = params.target_roi;

replace( pltlabs, {'box-left', 'box-right'}, 'box-lr' );
% replace( pltlabs, {'apparatus-left', 'apparatus-right'}, target_roi );
replace( pltlabs, {'apparatus-left', 'apparatus-right'}, 'apparatus-lr' );
replace( pltlabs, {'face-left', 'face-right'}, 'face-lr' );

prefix = 'overall__duration';

normpref = ternary( do_normalize, 'normalized', 'non-normalized' );
prefix = sprintf( '%s_%s', normpref, prefix );

pl = plotlabeled.make_common();
pl.x_tick_rotation = 0;

xs = { 'reach_type' };
groups = { 'event' };
panels = { 'target', 'measure', 'roi', 'monkey' };

if ( ~per_monk )
  collapsecat( pltlabs, 'monkey' );
end

mask = fcat.mask( pltlabs, @find, {'test-reach', 'duration', params.apple_or_hand, target_roi} );

pl.bar( pltdat(mask), pltlabs(mask), xs, groups, panels );

plot_p = fullfile( jjtom.fname(pltlabs(mask), 'measure'), jjtom.datedir );
plot_p = fullfile( base_plotp, plot_p );

if ( do_save )  
  cats = dsp3.nonun_or_all( pltlabs, unique(cshorzcat(xs, groups, panels)) );
  dsp3.req_savefig( gcf, plot_p, pltlabs(mask), cats, prefix );
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


