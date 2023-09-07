function [fname, foldername, seriesList, sname, ppath]=dialogHolesfiles()

fname=[];
foldername=[];seriesList=[];sname=[pwd '/data.xlsx'];ppath=[];

d=uifigure('Name','Select&Save','Position',[584 595 800 200],...
    'Color',[0.6784    0.4196    0.0275]);

choosefbutton=uibutton(d,"Text",'Choose File...','Position',[20 150 120 40]);
choosefbutton.ButtonPushedFcn=@cfb_callback;

choosedbutton=uibutton(d,"Text",'Choose Folder...','Position',[20 100 120 40]);
choosedbutton.ButtonPushedFcn=@cdb_callback;

filetext=uicontrol(d,'Style','text','Position',[200 160 600 20],...
    'String','selected file  ','HorizontalAlignment','center',...
    'BackgroundColor',[0.6784    0.4196    0.0275],'FontSize',8);

dirtext=uicontrol(d,'Style','text','Position',[200 110 600 20],...
    'String','selected folder  ','HorizontalAlignment','center',...
    'BackgroundColor',[0.6784    0.4196    0.0275],'FontSize',8);

checkfilebutton=uibutton(d,"Text",'Select files','Position',[140 50 120 40]);
checkfilebutton.ButtonPushedFcn=@checkf_callback;
checkfilebutton.Enable='off';

savefilebutton=uibutton(d,"Text",'Save As...','Position',[300 50 120 40]);
savefilebutton.ButtonPushedFcn=@savef_callback;
savefilebutton.Enable='off';

savetext=uicontrol(d,'Style','text','Position',[450 60 350 20],...
    'String','saved files location ','HorizontalAlignment','center',...
    'BackgroundColor',[0.6784    0.4196    0.0275],'FontSize',8);


okbutton=uicontrol(d,"Style","pushbutton","String","OK", "Position",[370 20 60 20],'Enable','off');
okbutton.Callback=@okbutton_callback;


uiwait(d);


    function cfb_callback(choosefbutton,event)
        d.Visible='off';
        [file,folder]=uigetfile('*.*');
        fname=fullfile(folder,file);
%         [wrappedf, fpos]=textwrap(filetext,cellstr(fname));
%         fpos(4)=fpos(4)*2;
%         filetext.Position=fpos;
        filetext.String=fname;
        d.Visible='on';
        choosedbutton.Enable='off';
        choosefbutton.Enable='off';
        checkfilebutton.Enable='on';
        savefilebutton.Enable='on';
        dirtext.ForegroundColor=[0.5 0.5 0.5];
    end

    function cdb_callback(choosedbutton,event)
        d.Visible='off';
        foldername=uigetdir;
        [wrappedd, dpos]=textwrap(dirtext,cellstr(foldername));
        dpos(4)=dpos(4)*2;
        dirtext.Position=dpos;
        dirtext.String=wrappedd;
        d.Visible='on';
        choosefbutton.Enable='off';
        choosedbutton.Enable='off';
        checkfilebutton.Enable='on';
        savefilebutton.Enable='on';
        filetext.ForegroundColor=[0.5 0.5 0.5];
    end

    function checkf_callback(checkfilebutton,event)
        if ~isempty(fname)
            [~, ~, sinfo]=bfGetInfo(fname);
            NameList={sinfo.Name}';
            
        elseif ~isempty(foldername)
            pd=dir(foldername);
            NameList={pd.name};
        else
            NameList={''};
        end


            flist=uifigure("Name",'Selected files','Position',[700 100 400 400]);
            il=uilistbox(flist,'position',[10 10 380 380],"Items",NameList);
            il.Multiselect='on';
            il.Value={};
            il.ValueChangedFcn=@SelectList;

        function SelectList(src,event)
            seriesList=src.Value;
            if ~isempty(ppath)
                okbutton.Enable='on';
            end
        end

    end

    function savef_callback(src,event)
        d.Visible='off';
        [ffile, ppath]=uiputfile({'*.xlsx';'*.csv'},'Save Data as');
        if ffile==0
            return
        else
        sname=fullfile(ppath,ffile);
        end
        d.Visible='on';
        [wrappesf, sfpos]=textwrap(savetext,cellstr(sname));
        sfpos(4)=sfpos(4)*2;
        savetext.Position=sfpos;
        savetext.String=wrappesf;
        if ~isempty(seriesList)
            okbutton.Enable='on';
        end
    end




    function okbutton_callback(okbutton,event)

        uiresume(d);
        close(d);
    end

end

