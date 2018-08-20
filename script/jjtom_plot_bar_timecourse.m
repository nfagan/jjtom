%%  bar

do_save = true;

norms = [true, false];
monks = [true, false];
targets = { 'apparatus-lr', 'box-lr', 'face-lr' };

c = combvec( 1:numel(norms), 1:numel(monks), 1:numel(targets) );

for i = 1:size(c, 2)
  do_norm = norms(c(1, i));
  per_monk = monks(c(2, i));
  target = targets{c(3, i)};
  
  jjtom_bar_durations2( ...
      'per_monkey',   per_monk ...
    , 'do_normalize', do_norm ...
    , 'target_roi',   target ...
    , 'do_save',      do_save ...
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
  );
end