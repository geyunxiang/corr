function xz_ttest

load('run_modality_config.mat','modality_config');
csvspath = modality_config.modality_folder;
subpathnormal = modality_config.modality_group{1};
subpathpatient = modality_config.modality_group{2};
fnametemplate = modality_config.atlasfname;


ttestdir = 't-test';
ttestpath = fullfile(csvspath,ttestdir);
if ~isdir(ttestpath)
    mkdir(ttestpath);
end
reportdir = 't-test-report';
reportpath = fullfile(csvspath,reportdir);
if ~isdir(reportpath)
    mkdir(reportpath);
end

csvpath_normalGSR  = fullfile(csvspath, subpathnormal);
attrs = xzfn_get_folder_attrs(csvpath_normalGSR);
csvpath_patientGSR = fullfile(csvspath, subpathpatient);


for iattr = 1:length(attrs)
    [nn,np,nt] = gen_normal_patient_ttest_name(attrs{iattr});
    proc_file(nn,np,nt);
    fprintf('.');
end
for iattr = 1:length(attrs)
    [nt,nr] = gen_normal_patient_ttest_name_report(attrs{iattr});
    proc_file_report(nt,nr);
    %fprintf('.');
end
fprintf('-\n');


    function [name_normal, name_patient, name_ttest] = gen_normal_patient_ttest_name(attr)
        t = dir(fullfile(csvpath_normalGSR,['*_',attr,'.csv']));
        name_normal = fullfile(csvpath_normalGSR,t(1).name);
        t = dir(fullfile(csvpath_patientGSR,['*_',attr,'.csv']));
        name_patient = fullfile(csvpath_patientGSR,t(1).name);
        name_ttest = fullfile(ttestpath,['ttest','_',attr,'.csv']);
    end
    function [name_ttest, name_ttestreport] = gen_normal_patient_ttest_name_report(attr)
        name_ttest = fullfile(ttestpath,['ttest','_',attr,'.csv']);
        name_ttestreport = fullfile(reportpath,['ttestreport', '_', attr, '.csv']);
    end

    function proc_file(csvnormal,csvpatient,csvttest)

        [~,Mnormal]  = parsecsv(csvnormal);
        [~,Mpatient] = parsecsv(csvpatient);
        
        for iregion = 1:116
            nsdata = Mnormal(iregion,:);
            psdata = Mpatient(iregion,:);
            if any([nsdata,psdata])==0
                h = 0;
                p = 0;
                statststat = 0;
            else
                varTData = [nsdata,psdata]';
                varTGroup = [ones(1,length(nsdata)),2*ones(1,length(psdata))]';
                varTp = vartestn(varTData,varTGroup,'TestType','LeveneAbsolute','display','off');
                if varTp > 0.05
                    fprintf(',');
                    [h,p,ci,stats] = ttest2(nsdata,psdata,'Vartype','equal');%default is equal
                else
                    fprintf('|');
                    [h,p,ci,stats] = ttest2(nsdata,psdata,'Vartype','unequal');%
                end
                statststat = stats.tstat;
            end
            hs(iregion) = h;
            ps(iregion) = p;
            %means(iregion) = mean(nsdata) - mean(psdata);
            meansnormal(iregion) = mean(nsdata);
            meanspatient(iregion) = mean(psdata);
            stdsnormal(iregion) = std(nsdata);
            stdspatient(iregion) = std(psdata);
            
            tstats(iregion) = statststat;
        end
     
        
        fttestout = fopen(csvttest,'w');
        %fprintf(fttestout,'No,h,p,t(normal-patient),meannormal,meanpatient\n');
        fprintf(fttestout,'No,h,p,t(normal-patient),meannormal,meanpatient,stdnormal,stdpatient\n');
        for iregion = 1:116
            h = hs(iregion);
            p = ps(iregion);
            t = tstats(iregion);
            meannormal = meansnormal(iregion);
            meanpatient = meanspatient(iregion);
            stdnormal = stdsnormal(iregion);
            stdpatient = stdspatient(iregion);
            
            %TODO,LorR,below ttestres = csvread(ttestinname, 1, 0);cause
            %problems
            fprintf(fttestout,[int2str(iregion),',',...
                int2str(h),',',...
                num2str(p),',',...
                num2str(t),',',...
                num2str(meannormal),',',...
                num2str(meanpatient),',',...
                num2str(stdnormal),',',...
                num2str(stdpatient),...
                '\n']);
        end
        fclose(fttestout);
    end  % function proc_spa_attr(spa,attr)


    function proc_file_report(ttestinname,reportoutname)

        ttestres = csvread(ttestinname, 1, 0);
        %No,h,p,t(normal-patient),meannormal,meanpatient
        % 1,2,3,                4,         5,          6
        detectnum = 0;
        for iregion = 1:116
            h = ttestres(iregion, 2);
            if h == 1
                detectnum = detectnum + 1;
                p = ttestres(iregion, 3);
                t = ttestres(iregion, 4);
                meannormal = ttestres(iregion, 5);
                meanpatient = ttestres(iregion, 6);
                stdnormal = ttestres(iregion, 7);
                stdpatient = ttestres(iregion, 8);
                outreportmat(detectnum,:) = [iregion,h,p,t,meannormal,meanpatient,stdnormal,stdpatient];
                
            end
        end
        if detectnum ~= 0
            freport = fopen(reportoutname,'w');
            %freport = fopen([reportdir,'ttest','_spa', spa, '_', attr,'.', fnametemplate, '.csv'],'w');
            fprintf(freport,'No,h,p,t(normal-patient),meannormal,meanpatient,stdnormal,stdpatient\n');
            for ide = 1:detectnum
                ir = outreportmat(ide,:);
                fprintf(freport,[myirtoLRn(ir(1)),',',... %int2str(ir(1))
                    num2str(ir(2)),',',...
                    num2str(ir(3)),',',...
                    num2str(ir(4)),',',...
                    num2str(ir(5)),',',...
                    num2str(ir(6)),',',...
                    num2str(ir(7)),',',...
                    num2str(ir(8)),...
                    '\n',...
                    ]);
            end
            fclose(freport);
            
        end
    end

end


function s = myirtoLRn(irdx)
    if irdx <= 58
        s = ['L',int2str(irdx)];
    else
        s = ['R',int2str(irdx-68)];
    end

end






