function xz_gui_run


load('current_config.mat','xzconfig');
%ModalitiesData  row:Modality,Folder,Run
%itemcks(1:3)  T-Test, BrainNetMap, Corr-Test
%ModalitiesGroup{1:2}  char normal patient
%Atlasfname char filename
%Scoresfname char filename
ModalitiesData = xzconfig.ModalitiesData;
sizeModalities = size(ModalitiesData);
modality_cnt = sizeModalities(1);
modality_group = xzconfig.ModalitiesGroup;
atlasfname = xzconfig.Atlasfname;
scoresfname = xzconfig.Scoresfname;
itemcks = xzconfig.ItemsCheckBoxValue;
printf_divide = '----------------------------------';

for imodality = 1:modality_cnt
    ismodrun = ModalitiesData{imodality, 3}; %1:run, 0:no run
    if ismodrun == 1
        modality_config = struct();
        modality_config.modality_name = ModalitiesData{imodality,1};
        modality_config.modality_folder = ModalitiesData{imodality,2};
        modality_config.modality_group = modality_group;
        modality_config.atlasfname = atlasfname;
        modality_config.scoresfname = scoresfname;
        
        save('run_modality_config.mat','modality_config');
        
        fprintf('\n%s\nmain: %s\n', printf_divide, modality_config.modality_name);
        if itemcks(1) == 1 %T-Test
            fprintf('T-Test\n');
            xz_ttest;
        end
        if itemcks(2) == 1 %BrainNetMap
            fprintf('BrainNetMap\n');
            xz_ttest_BrainNet;
        end
        if itemcks(3) == 1 %Corr-Test
            fprintf('Corr-Test\n');
            xz_corr;
        end
        
    end
end

return;

