function xz_corr

load('run_modality_config.mat','modality_config');
csvspath = modality_config.modality_folder;
subpathnormal = modality_config.modality_group{1};
subpathpatient = modality_config.modality_group{2};
fnametemplate = modality_config.atlasfname;
fnamescores = modality_config.scoresfname;

testdir = 'corrtest';
testpath = fullfile(csvspath,testdir);
if ~isdir(testpath)
    mkdir(testpath);
end
ttestdir = 't-test';
ttestpath = fullfile(csvspath,ttestdir);

csvpath_patientGSR = fullfile(csvspath, subpathpatient);
attrs = xzfn_get_folder_attrs(csvpath_patientGSR);

scoreitemdesc = get_score_item_desc_from_scores_csv(fnamescores);
% {'病程month';'治疗前运动评分';'治疗前感觉评分';'VAS疼痛评分';'痉挛';'WISCI步行指数';'SCIM日常生活能力'};

scoreitem_cnt = length(scoreitemdesc);
patientscore = csvread(fnamescores,1,2);%row for one patient, col for one item

for iattr = 1:length(attrs)
    [np,nt] = gen_normal_patient_test_name(attrs{iattr});
    proc_file(np,nt);
    fprintf('.');
end

reportdir = 'corrtest-report';
reportpath = fullfile(csvspath,reportdir);
if ~isdir(reportpath)
    mkdir(reportpath);
end
reportdir = 'corrtest-report2';
reportpath2 = fullfile(csvspath,reportdir);
if ~isdir(reportpath2)
    mkdir(reportpath2);
end
reportdir = 'corrtest-report3';
reportpath3 = fullfile(csvspath,reportdir);
if ~isdir(reportpath3)
    mkdir(reportpath3);
end
reportdir = 'corrtest-report4';
reportpath4 = fullfile(csvspath, reportdir);
if ~isdir(reportpath4)
    mkdir(reportpath4)
end

for iattr = 1:length(attrs)
    [nt,nr] = gen_normal_patient_test_name_report(attrs{iattr},reportpath,'');
    proc_file_report(nt,nr);
    [nt,nr] = gen_normal_patient_test_name_report(attrs{iattr},reportpath2,'2');
    proc_file_report2(nt,nr);
    [nt,nr] = gen_normal_patient_test_name_report(attrs{iattr},reportpath3,'3');
    name_ttest = fullfile(ttestpath, ['ttest','_', attrs{iattr}, '.csv']);
    proc_file_report3(nt,nr,name_ttest);
    [nt,nr] = gen_normal_patient_test_name_report(attrs{iattr},reportpath4,'4');
    proc_file_report4(nt,nr,name_ttest);
end


fprintf('-\n');


    function [name_test, name_testreport] = gen_normal_patient_test_name_report(attr,thereportpath,ireportdir)
        name_test = fullfile(testpath, ['corrtest', '_', attr, '.csv']);
        name_testreport = fullfile(thereportpath, ['corrtestreport',ireportdir, '_', attr, '.csv']);
    end

    function [name_patient, name_test] = gen_normal_patient_test_name(attr)
        t = dir(fullfile(csvpath_patientGSR,['*_',attr,'.csv']));
        name_patient = fullfile(csvpath_patientGSR, t(1).name);
        name_test = fullfile(testpath, ['corrtest', '_', attr, '.csv']);
    end

%scoreitemdesc
%patientscore

    function proc_file(csvpatient,csvtest)
        [~,Mpatient] = parsecsv(csvpatient);
        corrtestres = zeros(116,scoreitem_cnt*2);
        for iregion = 1:116
            
            psdata = Mpatient(iregion,:);
            if any(psdata)==0
                %not a region, skip
            else
                for iscoreitem = 1:scoreitem_cnt
                    [rho,pval] = corr(psdata',patientscore(:,iscoreitem),'type','Spearman');
                    corrtestres(iregion,iscoreitem*2-2 + 1) = rho;
                    corrtestres(iregion,iscoreitem*2-2 + 2) = pval;
                end%end for each score item
            end%end if is a region
        end%end for each region
        
        %write header of csv
        fcorrtestout = fopen(csvtest,'w');
        fprintf(fcorrtestout,'No,');
        for iscoreitem = 1:scoreitem_cnt-1
            fprintf(fcorrtestout,['rho_',scoreitemdesc{iscoreitem},',','pval_',scoreitemdesc{iscoreitem},',']);
        end
        iscoreitem = iscoreitem + 1;
        fprintf(fcorrtestout,['rho_',scoreitemdesc{iscoreitem},',','pval_',scoreitemdesc{iscoreitem},'\n']);
        %write content of csv
        for iregion = 1:116
            fprintf(fcorrtestout,[int2str(iregion),',']);
            for iscoreitem = 1:scoreitem_cnt-1
                fprintf(fcorrtestout,[num2str(corrtestres(iregion,iscoreitem*2-2 + 1)),',',...
                    num2str(corrtestres(iregion,iscoreitem*2-2 + 2)),',']);
            end
            iscoreitem = iscoreitem + 1;
                fprintf(fcorrtestout,[num2str(corrtestres(iregion,iscoreitem*2-2 + 1)),',',...
                    num2str(corrtestres(iregion,iscoreitem*2-2 + 2)),'\n']);
        end
        fclose(fcorrtestout);
    end%end function proc_spa_attr


    function proc_file_report(testinname,reportoutname)
        corrtestinname = testinname;
        %corrtestinname = [csvspath(1:end-1),fnametemplate,'/', corrtestdir, 'corrtest','_spa', spa, '_', attr,'.', fnametemplate, '.csv'];
        corrtestres = csvread(corrtestinname, 1, 0);
        fcorrtestres = fopen(corrtestinname,'r');
        corrtesthead = fgetl(fcorrtestres);
        fclose(fcorrtestres);
        %No,rho1,pval1,rho2,pval2,...rho7,pval7
        sizecorrtestres = size(corrtestres);
        corrtestreport = zeros(1, sizecorrtestres(2));
        scoreitem_cnt = (sizecorrtestres(2) -  1) / 2;
        detectnum = 0;
        
        for iregion = 1:116
            corrtestregion = corrtestres(iregion,:);
            iregioncorrfound = 0;
            for iscoreitem = 1:scoreitem_cnt
                icolpval = iscoreitem*2-2 + 3;
                icurp = corrtestregion(icolpval);
                if icurp < 0.05 && icurp > 0
                    %a p < 0.05 found
                    corrtestreport(detectnum+1,1) = iregion;
                    corrtestreport(detectnum+1, icolpval-1:icolpval) = ...
                        [corrtestregion(icolpval-1), corrtestregion(icolpval)];
                    iregioncorrfound = 1;
                end
            end
            if iregioncorrfound == 1
                detectnum = detectnum + 1;
            end
        end
        
        if detectnum ~= 0
            
            freport = fopen(reportoutname,'w');
            fprintf(freport,[corrtesthead,'\n']);
            for ide = 1:detectnum
                ir = corrtestreport(ide,:);
                fprintf(freport,[int2str(ir(1)),',']);
                for iscoreitemd = 1:scoreitem_cnt*2-1
                    fprintf(freport,[mynum2str(ir(iscoreitemd + 1)),',']);
                end
                fprintf(freport,[mynum2str(ir(iscoreitemd + 1 + 1)),'\n']);
            end
            fclose(freport);
        
        end
    end


    %report2
    function proc_file_report2(testinname,reportoutname)
        corrtestinname = testinname;
        corrtestres = csvread(corrtestinname, 1, 0);
        fcorrtestres = fopen(corrtestinname,'r');
        corrtesthead = fgetl(fcorrtestres);
        fclose(fcorrtestres);
        %No,rho1,pval1,rho2,pval2,...rho7,pval7
        sizecorrtestres = size(corrtestres);
        corrtestreport = zeros(1, sizecorrtestres(2));
        scoreitem_cnt = (sizecorrtestres(2) -  1) / 2;
        detectnum = 0;
        
        for iregion = 1:116
            corrtestregion = corrtestres(iregion,:);
            iregioncorrfound = 0;
            for iscoreitem = 1:scoreitem_cnt
                icolpval = iscoreitem*2-2 + 3;
                icurp = corrtestregion(icolpval);
                if icurp < 0.05 && icurp > 0
                    %a p < 0.05 found
                    corrtestreport(detectnum+1,1) = iregion;
                    corrtestreport(detectnum+1, icolpval-1:icolpval) = ...
                        [corrtestregion(icolpval-1), corrtestregion(icolpval)];
                    iregioncorrfound = 1;
                end
            end
            if iregioncorrfound == 1
                detectnum = detectnum + 1;
            end
        end
        
        if detectnum ~= 0
            
            freport = fopen(reportoutname,'w');
            s = myprochead(corrtesthead);
            fprintf(freport,s);
            for ide = 1:detectnum
                %region row
                ir = corrtestreport(ide,:);
                %region number
                s = myirtoLRn(ir(1));
                fprintf(freport,[s,',']);
                for iscoreitem = 1:scoreitem_cnt-1
                    %scoreitem + or -
                    s = mynumto_plusminus(ir(iscoreitem*2),ir(iscoreitem*2+1));
                    fprintf(freport,[s,',']);
                end
                iscoreitem = iscoreitem + 1;
                s = mynumto_plusminus(ir(iscoreitem*2),ir(iscoreitem*2+1));
                fprintf(freport,[s,'\n']);
            end
            fclose(freport);
        
        end
    end

    
    %report3
    function proc_file_report3(testinname,reportoutname,ttestinname)
        corrtestinname = testinname;
        corrtestres = csvread(corrtestinname, 1, 0);
        fcorrtestres = fopen(corrtestinname,'r');
        corrtesthead = fgetl(fcorrtestres);
        fclose(fcorrtestres);
        %No,rho1,pval1,rho2,pval2,...rho7,pval7
        sizecorrtestres = size(corrtestres);
        corrtestreport = zeros(1, sizecorrtestres(2));
        scoreitem_cnt = (sizecorrtestres(2) -  1) / 2;
        detectnum = 0;
        
        %t-test result
        ttestres = csvread(ttestinname,1,0);
        ttestres_h = ttestres(:,2);%all the h, 0 or 1
        ttestres_T = ttestres(:,4);%all the T, >0 or <0
        %
        
        
        for iregion = 1:116
            corrtestregion = corrtestres(iregion,:);
            iregioncorrfound = 0;
            for iscoreitem = 1:scoreitem_cnt
                icolpval = iscoreitem*2-2 + 3;
                icurp = corrtestregion(icolpval);
                if icurp < 0.05 && icurp > 0
                    %a p < 0.05 found
                    corrtestreport(detectnum+1,1) = iregion;
                    corrtestreport(detectnum+1, icolpval-1:icolpval) = ...
                        [corrtestregion(icolpval-1), corrtestregion(icolpval)];
                    iregioncorrfound = 1;
                end
            end
            if iregioncorrfound == 1
                detectnum = detectnum + 1;
            end
        end
        
        if detectnum ~= 0
            
            freport = fopen(reportoutname,'w');
            s = myprochead_report3(corrtesthead);
            fprintf(freport,s);
            for ide = 1:detectnum
                %region row
                ir = corrtestreport(ide,:);
                %region number
                s = myirtoLRn(ir(1));
                fprintf(freport,[s,',']);
                %t-test result
                s = myttestto_plusminus(ttestres_h(ir(1)),ttestres_T(ir(1)));
                fprintf(freport,[s,',']);
                
                for iscoreitem = 1:scoreitem_cnt-1
                    %scoreitem + or -
                    s = mynumto_plusminus(ir(iscoreitem*2),ir(iscoreitem*2+1));
                    fprintf(freport,[s,',']);
                end
                iscoreitem = iscoreitem + 1;
                s = mynumto_plusminus(ir(iscoreitem*2),ir(iscoreitem*2+1));
                fprintf(freport,[s,'\n']);
            end
            fclose(freport);
        
        end
    end


   
    %report4
    function proc_file_report4(testinname,reportoutname,ttestinname)
        corrtestinname = testinname;
        corrtestres = csvread(corrtestinname, 1, 0);
        fcorrtestres = fopen(corrtestinname,'r');
        corrtesthead = fgetl(fcorrtestres);
        fclose(fcorrtestres);
        %No,rho1,pval1,rho2,pval2,...rho7,pval7
        sizecorrtestres = size(corrtestres);
        corrtestreport = zeros(1, sizecorrtestres(2));
        scoreitem_cnt = (sizecorrtestres(2) -  1) / 2;
        detectnum = 0;
        
        %t-test result
        ttestres = csvread(ttestinname,1,0);
        ttestres_h = ttestres(:,2);%all the h, 0 or 1
        ttestres_T = ttestres(:,4);%all the T, >0 or <0
        %
        
        
        for iregion = 1:116
            corrtestregion = corrtestres(iregion,:);
            iregioncorrfound = 0;
            for iscoreitem = 1:scoreitem_cnt
                icolpval = iscoreitem*2-2 + 3;
                icurp = corrtestregion(icolpval);
                if icurp < 0.05 && icurp > 0
                    %a p < 0.05 found
                    corrtestreport(detectnum+1,1) = iregion;
                    corrtestreport(detectnum+1, icolpval-1:icolpval) = ...
                        [corrtestregion(icolpval-1), corrtestregion(icolpval)];
                    iregioncorrfound = 1;
                end
            end
            if iregioncorrfound == 1
                detectnum = detectnum + 1;
            end
        end
        
        if detectnum ~= 0
            
            freport = fopen(reportoutname,'w');
            s = myprochead_report3(corrtesthead);
            fprintf(freport,s);
            for ide = 1:detectnum
                %region row
                ir = corrtestreport(ide,:);
                %only with T-test significant
                if ttestres_h(ir(1)) == 0
                    continue;
                end
                %region number
                s = myirtoLRn(ir(1));
                fprintf(freport,[s,',']);
                %t-test result
                s = myttestto_plusminus(ttestres_h(ir(1)),ttestres_T(ir(1)));
                fprintf(freport,[s,',']);
                
                for iscoreitem = 1:scoreitem_cnt-1
                    %scoreitem + or -
                    s = mynumto_plusminus(ir(iscoreitem*2),ir(iscoreitem*2+1));
                    fprintf(freport,[s,',']);
                end
                iscoreitem = iscoreitem + 1;
                s = mynumto_plusminus(ir(iscoreitem*2),ir(iscoreitem*2+1));
                fprintf(freport,[s,'\n']);
            end
            fclose(freport);
        
        end
    end


end%end function xz_corr

function s = mynum2str(thenum)
    %return '' for 0
    if thenum==0
        s = '';
    else
        s = num2str(thenum);
    end
end


function s = myttestto_plusminus(theh,theT)
    if theh == 0
        s = '';
    elseif theT > 0
        s = '-';
    else
        s = '+';
    end
    
end


function s = mynumto_plusminus(rho,pval)
    if pval==0
        s = '';
    elseif rho>0
        s = '+';
    else
        s = '-';
    end

end

function s = myirtoLRn(irdx)
    if irdx <= 48
        s = ['L',int2str(irdx)];
    else
        s = ['R',int2str(irdx-68)];
    end

end

function s = myprochead(inhead)
    heads = strsplit(inhead, ',');
    headshalf = heads(3:2:end);
    for i = 1:length(headshalf);
        headshalfd{i} = headshalf{i}(6:end); 
    end
    s = 'No,';
    for i = 1:length(headshalf)-1
        s = [s,headshalfd{i},','];
    end
    i = i+1;
    s = [s,headshalfd{i},'\n'];

end

function s = myprochead_report3(inhead)
    heads = strsplit(inhead, ',');
    headshalf = heads(3:2:end);
    for i = 1:length(headshalf);
        headshalfd{i} = headshalf{i}(6:end); 
    end
    s = 'No,ttest_T(patient-normal),';
    for i = 1:length(headshalf)-1
        s = [s,headshalfd{i},','];
    end
    i = i+1;
    s = [s,headshalfd{i},'\n'];

end

function scoreitems = get_score_item_desc_from_scores_csv(fscorecsv)
    fin = fopen(fscorecsv,'r');
    if fin<0
        fprintf('fscore csv open error, %s',fscorecsv);
        return;
    end
    firstline = fgetl(fin);
    head = strsplit(firstline, ',');
    scoreitems = head(3:end);
    fclose(fin);
end

