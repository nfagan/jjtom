do_save = true;

inputs = struct();
inputs.base_subdir = '';
inputs.pad_face_y = 0.05;
inputs.do_save = do_save;
inputs.is_parallel = true;
inputs.is_per_monkey = false;

%%

jjtom_task1_interval_look_counts( inputs );

%%

jjtom_task2_interval_look_counts( inputs );