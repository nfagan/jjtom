%%  bar

% conf = jjtom.tmp_setdataroot( '/Volumes/My Passport/NICK/Chang Lab 2016/jess/tom' );

do_save = true;

norms = [true, false];
monks = [true, false];
% targets = { 'apparatus-lr', 'box-lr', 'face-lr' };
% targets = { 'apparatus-lr', 'face-lr' };
targets = { 'face-lr' };

c = combvec( 1:numel(norms), 1:numel(monks), 1:numel(targets) );

for i = 1:size(c, 2)
  do_norm = norms(c(1, i));
  per_monk = monks(c(2, i));
  target = targets{c(3, i)};
  
  jjtom_bar_durations2( ...
      'per_monkey',   per_monk ...
    , 'do_normalize', do_norm ...
    , 'apple_or_hand', 'hand' ...
    , 'target_roi',   target ...
    , 'do_save',      do_save ...
    , 'config',       conf ...
    , 'not_files',    {'Cn', 'Kr'} ...
    , 'separate_apparatus_and_face', true ...
  );
end

%%  timecourse

do_save = true;

norms = [ true, false ];
targets = { 'box-lr', 'apparatus-lr', 'face-lr' };

c = combvec( 1:numel(norms), 1:numel(targets) );

for i = 1:size(c, 2)
  do_norm = norms(c(1, i));
  target = targets{c(2, i)};
  
  jjtom_timecourse_2( ...
      'do_normalize',   do_norm ...
    , 'target_roi',     target ...
    , 'do_save',        do_save ...
    , 'config',         conf ...
    , 'not_files',      {'Cn', 'Kr'} ...
  );
end