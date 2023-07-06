function [dapich, laminch, lamin2ch, sizefilt, registerbool,removeholesbool, OIbool, IObool]=dialogHoles()

dapich=1;laminch=2;lamin2ch=3; sizefilt=0;
registerbool=0;removeholesbool=0;
OIbool=1;IObool=1;

d=uifigure('Name','Select Parameters','Position',[584 595 200 400],...
    'Color',[0.7020    0.9412    0.5451]);

dapitext=uicontrol(d,'Style','text','Position',[20 360 120 20],...
    'String','dapi#  ','HorizontalAlignment','center',...
    'BackgroundColor',[0.702 0.9412 0.5451]);
dapi=uicontrol(d,'Style','Edit','Position',[120 360 40 20],...
    'String','1');
dapi.Callback=@dapi_callback;

lamintext=uicontrol(d,'Style','text','Position',[20 320 120 20],...
    'String','lamin# ','HorizontalAlignment','center',...
    'BackgroundColor',[0.702 0.9412 0.5451]);
lamin=uicontrol(d,'Style','Edit','Position',[120 320 40 20],...
    'String','2');
lamin.Callback=@lamin_callback;

lamin2text=uicontrol(d,'Style','text','Position',[20 280 120 20],...
    'String','lamin2#','HorizontalAlignment','center',...
    'BackgroundColor',[0.702 0.9412 0.5451]);
lamin2=uicontrol(d,'Style','Edit','Position',[120 280 40 20],...
    'String','3');
lamin2.Callback=@lamin2_callback;

sizefiltertext=uicontrol(d,'Style','text','Position',[20 240 120 20],...
    'String','size filter','HorizontalAlignment','center',...
    'BackgroundColor',[0.702 0.9412 0.5451]);
sizefilter=uicontrol(d,'Style','Edit','Position',[120 240 40 20],...
    'String','0');
sizefilter.Callback=@sizefilter_callback;

registerdapitext=uicontrol(d,'Style','text','Position',[20 200 140 20],...
    'String','z-register dapi ','HorizontalAlignment','center',...
    'BackgroundColor',[0.702 0.9412 0.5451]);
registerdapi=uicontrol(d,'Style','checkbox','Position',[150 200 20 20],...
    'BackgroundColor',[0.702 0.9412 0.5451]);
registerdapi.Callback=@registerdapi_callback;

removefloorholestext=uicontrol(d,'Style','text','Position',[20 160 140 20],...
    'String','ignore floor holes','HorizontalAlignment','center',...
    'BackgroundColor',[0.702 0.9412 0.5451]);
removefloorholes=uicontrol(d,'Style','checkbox','Position',[150 160 20 20],...
    'BackgroundColor',[0.702 0.9412 0.5451]);
removefloorholes.Callback=@removefloorholes_callback;

OItext=uicontrol(d,'Style','text','Position',[20 120 140 20],...
    'String','Outside in rays','HorizontalAlignment','center',...
    'BackgroundColor',[0.702 0.9412 0.5451]);
OI=uicontrol(d,'Style','Checkbox','Position',[20 120 20 20],...
    'BackgroundColor',[0.702 0.9412 0.5451]);
OI.Value=1;
OI.Callback=@OI_callback;

IOtext=uicontrol(d,'Style','text','Position',[20 80 140 20],...
    'String','Inside out rays','HorizontalAlignment','center',...
    'BackgroundColor',[0.702 0.9412 0.5451]);
IO=uicontrol(d,'Style','Checkbox','Position',[20 80 20 20],...
    'BackgroundColor',[0.702 0.9412 0.5451]);
IO.Value=1;
IO.Callback=@IO_callback;



okbutton=uicontrol(d,"Style","pushbutton","String","OK", "Position",[80 30 60 20]);
okbutton.Callback=@okbutton_callback;


uiwait(d);


    function dapi_callback(dapi,event)
        dstring=dapi.String;
        dapich=str2double(dstring);
    end

    function lamin_callback(lamin,event)
        lstring=lamin.String;
        laminch=str2double(lstring);
    end

    function lamin2_callback(lamin2,event)
        l2string=lamin2.String;
        lamin2ch=str2double(l2string);
    end

    function sizefilter_callback(sizefilter,event)
        sfstring=sizefilter.String;
        sizefilt=str2double(sfstring);
    end

    function registerdapi_callback(registerdapi,event)
        registerbool=registerdapi.Value;
    end

    function removefloorholes_callback(removefloorholes,event)
        removeholesbool=removefloorholes.Value;
    end

    function OI_callback(OI,event)
        OIbool=OI.Value;
        if ~OIbool
            IO.Value=1;

        end
    end

    function IO_callback(IO,event)
        IObool=IO.Value;
        if ~IObool
            OI.Value=1;

        end
    end



    function okbutton_callback(okbutton,event)
        OIbool=OI.Value;
        IObool=IO.Value;
        uiresume(d);
        close(d);
    end

end

