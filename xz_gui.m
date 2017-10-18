function xz_gui
%xzguiholder:xgh

%size callback will be called if visible is on(default)
f = figure('Name','xzDataProc','NumberTitle','off','SizeChangedFcn', @cb_figure_size_change, 'Visible', 'off',...
    'MenuBar','none','ToolBar','none','Position',[100,100,500,600]);
%two panel, DataProc and Info
xgh = struct('structname','xzguiholder');
xgh.g_panel1 = uipanel(f,'Title','DataProc');
xgh.g_panel2 = uipanel(f,'Title','Info');

btnshorz = 2;
btnsvert = 12;
%bottom-left buttons
ibtn = 0;
btnpos = [0,ibtn/btnsvert,1/btnshorz,1/btnsvert];
uicontrol(xgh.g_panel1,'Style','pushbutton','String','Help','Units','normalized',...
    'Position',btnpos,'Callback',@cb_btn_help);
ibtn = ibtn + 1;
btnpos = [0,ibtn/btnsvert,1/btnshorz,1/btnsvert];
xgh.g_panel1_botleft_run = uicontrol(xgh.g_panel1,'Style','pushbutton','String','Run','Units','normalized',...
    'Position',btnpos,'BackgroundColor',[0.7,0.9,0.7],'Callback',@cb_btn_run);
ibtn = ibtn + 1;
btnpos = [0,ibtn/btnsvert,1/btnshorz/2,1/btnsvert];
uicontrol(xgh.g_panel1,'Style','pushbutton','String','Load Config','Units','normalized',...
    'Position',btnpos,'Callback',@cb_btn_loadsave);
btnpos = [1/btnshorz/2,ibtn/btnsvert,1/btnshorz/2,1/btnsvert];
uicontrol(xgh.g_panel1,'Style','pushbutton','String','Save Config','Units','normalized',...
    'Position',btnpos,'Callback',@cb_btn_loadsave);

%top-right items
xgh.g_panel1_btngrp = uipanel(xgh.g_panel1,'Title','Items to Run','Units','normalized',...
    'Position',[0.5,0.3,0.5,0.7]);
icks = 0;
xgh.g_panel1_btngrp_ck1 = uicontrol(xgh.g_panel1_btngrp,'Style','checkbox','String','T-Test','Units','normalized',...
    'Position',[0.03,0.8-icks*0.15,0.4,0.12],'Value',1);
icks = icks + 1;
xgh.g_panel1_btngrp_ck2 = uicontrol(xgh.g_panel1_btngrp,'Style','checkbox','String','BrainNetMap','Units','normalized',...
    'Position',[0.03,0.8-icks*0.15,0.4,0.12],'Value',1);
icks = icks + 1;
xgh.g_panel1_btngrp_ck3 = uicontrol(xgh.g_panel1_btngrp,'Style','checkbox','String','Corr-Test','Units','normalized',...
    'Position',[0.03,0.8-icks*0.15,0.4,0.12],'Value',1);
icks = icks + 2;
%atlas
xgh.g_panel1_btngrp_lblatlas = uicontrol(xgh.g_panel1_btngrp,'Style','text','String','Atlas','Units','normalized',...
    'Position',[0.03,0.8-icks*0.15,0.3,0.12],'HorizontalAlignment','left');
xgh.g_panel1_btngrp_fileatlas = uicontrol(xgh.g_panel1_btngrp,'Style','edit','Units','normalized',...
    'Position',[0.3,0.8-icks*0.15,0.65,0.14],'Enable','Inactive',...
    'Tag','Atlas','ButtonDownFcn',@cb_panel1_btngrp_atlas_score,'Max',2,'FontSize',9);
%scores
icks = icks + 1;
xgh.g_panel1_btngrp_lblatlas = uicontrol(xgh.g_panel1_btngrp,'Style','text','String','Scores','Units','normalized',...
    'Position',[0.03,0.8-icks*0.15,0.3,0.12],'HorizontalAlignment','left');
xgh.g_panel1_btngrp_filescores = uicontrol(xgh.g_panel1_btngrp,'Style','edit','Units','normalized',...
    'Position',[0.3,0.8-icks*0.15,0.65,0.14],'Enable','Inactive',...
    'Tag','Scores','ButtonDownFcn',@cb_panel1_btngrp_atlas_score,'Max',2,'FontSize',9);

%top-left modality table
colname = {'Modality','Folder','Run'};
colformat = {'char','char','logical'};
coledit = [true, true, true];
xgh.g_panel1_table = uipanel(xgh.g_panel1,'Title','Modalities','Units','normalized',...
    'Position',[0,0.3,0.5,0.7],'SizeChangedFcn',@cb_table_modalities_size);
xgh.g_panel1_table_table = uitable(xgh.g_panel1_table,'Units','normalized','Position',[0,0.41,1,0.59],...
    'ColumnName',colname,'ColumnFormat',colformat,'ColumnEditable',coledit,'RowName',[],...
    'CellSelectionCallback',@cb_table_modalities);
xgh.g_panel1_table_table.Data = {'inter-region','',true;...
    'intra-region','',true;...
    'inter-voxel','',true};
xgh.g_panel1_table_groupl1 = uicontrol(xgh.g_panel1_table,'Style','text','Units','normalized','Position',[0,0.2,0.2,0.2],...
    'String',{'Group1','Normal'});
xgh.g_panel1_table_groupname1 = uicontrol(xgh.g_panel1_table,'Style','edit','Units','normalized','Position',[0.2,0.205,0.3,0.19],...
    'String','normal_GSR');
xgh.g_panel1_table_groupl2 = uicontrol(xgh.g_panel1_table,'Style','text','Units','normalized','Position',[0.5,0.2,0.2,0.2],...
    'String',{'Group2','Patient'});
xgh.g_panel1_table_groupname2 = uicontrol(xgh.g_panel1_table,'Style','edit','Units','normalized','Position',[0.7,0.205,0.3,0.19],...
    'String','patient_GSR');

xgh.g_panel1_table_btn1 = uicontrol(xgh.g_panel1_table,'Style','pushbutton','Units','normalized','Position',[0,0,0.3,0.2],...
    'String','Add','Callback',@cb_btn_table_addremove);
xgh.g_panel1_table_btn2 = uicontrol(xgh.g_panel1_table,'Style','pushbutton','Units','normalized','Position',[0.3,0,0.3,0.2],...
    'String','Remove','Callback',@cb_btn_table_addremove);



guidata(f,xgh);
f.Visible = 'on';

end

function cb_panel1_btngrp_atlas_score(hObject, eventdata)
    edittag = hObject.Tag
    if strcmp(edittag,'Atlas')
        [fname,pname,~] = uigetfile('*.nii');
        if fname ~= 0
            hObject.String = [pname,fname];%BE careful!
            %hObject.UserData=[pname,fname];
        end
    elseif strcmp(edittag,'Scores')
        [fname,pname,~] = uigetfile('*.csv');
        if fname ~= 0
            hObject.String = [pname,fname];%BE careful!            
            %hObject.UserData = [pname,fname];
        end
    else
        
    end

end
function cb_btn_loadsave(hObject, eventdata)
    btnstr = hObject.String;
    if strcmp(btnstr,'Load Config')
        fname_config = uigetfile('*.mat');
        if fname_config == 0
            return;
        else
            fname_config
            load(fname_config,'xzconfig');
            fig = gcbo;
            xgh = guidata(fig);
            tabmod = xgh.g_panel1_table_table;
            tabmod.Data = xzconfig.ModalitiesData;
            itemcks = xzconfig.ItemsCheckBoxValue;
            xgh.g_panel1_btngrp_ck1.Value = itemcks(1);
            xgh.g_panel1_btngrp_ck2.Value = itemcks(2);
            xgh.g_panel1_btngrp_ck3.Value = itemcks(3);
            xgh.g_panel1_table_groupname1.String = xzconfig.ModalitiesGroup{1};
            xgh.g_panel1_table_groupname2.String = xzconfig.ModalitiesGroup{2};
            xgh.g_panel1_btngrp_fileatlas.String = xzconfig.Atlasfname;
            xgh.g_panel1_btngrp_filescores.String = xzconfig.Scoresfname;
        end
    elseif strcmp(btnstr,'Save Config')
        fname_config = uiputfile('*.mat');
        if fname_config == 0
            return;
        else
            fname_config
            fig = gcbo;
            xzsave_config(fig,fname_config);
        end
    end

end
function cb_table_modalities_size(hObject, eventdata)
    fig = gcbo;
    xgh = guidata(fig);
    tabmod = xgh.g_panel1_table_table;
    unitsold = tabmod.Units;
    tabmod.Units = 'pixels';
    tabpos = tabmod.Position;
    tabwidth = tabpos(3);
    tabcolwidth = {tabwidth*0.35 tabwidth*0.45 tabwidth*0.18};
    tabmod.ColumnWidth = tabcolwidth;
    tabmod.Units = unitsold;
end
function cb_btn_table_addremove(hObject, eventdata)
    btnstr = hObject.String;
    fig = gcbo;
    xgh = guidata(fig);
    tabmod = xgh.g_panel1_table_table;
    tabdata = tabmod.Data;
    if strcmp(btnstr,'Add')
        tabdata(end+1,:) = {'new-modality','',false};
    else
        tabcurrow = tabmod.UserData
        if numel(tabcurrow) == 0 || tabcurrow(1)==0
            return;
        else
            tabdata(tabcurrow,:) = [];%remove row
        end
    end
    tabmod.Data = tabdata;
    
end

function cb_table_modalities(hObject, eventdata)
    indices = eventdata.Indices;
    if numel(indices)==0 %not folder, and save last selected row number
        hObject.UserData(1) = 0;
        return;
    elseif indices(2) ~= 2 
        hObject.UserData(1) = indices(1);
        return;
    end
    fig = gcbo;
    xgh = guidata(fig);
    tabmod = xgh.g_panel1_table_table;
    tabdata = tabmod.Data;
    dirname = uigetdir();
    if dirname ~= 0
        tabdata{indices(1),indices(2)} = dirname;
    end
    tabmod.Data = tabdata;
end

function cb_btn_help(hObject, eventdata)
    open('DataProcManual.docx');
end

function xzsave_config(fig,fname_config)
    xgh = guidata(fig);
    tabmod = xgh.g_panel1_table_table;
    itemcks(1) = xgh.g_panel1_btngrp_ck1.Value;
    itemcks(2) = xgh.g_panel1_btngrp_ck2.Value;
    itemcks(3) = xgh.g_panel1_btngrp_ck3.Value;
    xzconfig=struct();
    xzconfig.ModalitiesData = tabmod.Data;
    xzconfig.ModalitiesGroup{1} = xgh.g_panel1_table_groupname1.String;
    xzconfig.ModalitiesGroup{2} = xgh.g_panel1_table_groupname2.String;
    xzconfig.ItemsCheckBoxValue = itemcks;
    xzconfig.Atlasfname = xgh.g_panel1_btngrp_fileatlas.String;
    xzconfig.Scoresfname = xgh.g_panel1_btngrp_filescores.String;
    save(fname_config,'xzconfig');            
end

function cb_btn_run(hObject, eventdata)
    fig = gcbo;
    xzsave_config(fig,'current_config.mat');
    %RUN BATCH
    xgh = guidata(fig);
    runbtn = xgh.g_panel1_botleft_run;
    runbtn.Enable = 'off'; %disable run button while running
    xz_gui_run;
    runbtn.Enable = 'on';
    %fprintf('%d%d%d\n',ck1v,ck2v,ck3v);
end

function cb_figure_size_change(hObject, eventdata)
    fig = hObject;
    
    xgh = guidata(fig);
    %panel use normalized units for default,[0 0 1 1]
    p1 = xgh.g_panel1;
    p2 = xgh.g_panel2;
    p1.Position = [0 0.3 1 0.7];
    p2.Position = [0 0 1 0.3];
    %restore units 
end