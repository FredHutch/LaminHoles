function [reader, omeMeta, sinfo]=bfGetInfo(filename)

reader=bfGetReader(filename);
omeMeta = reader.getMetadataStore();

nseries=reader.getSeriesCount();
if nseries==1
    stackSizeX = omeMeta.getPixelsSizeX(0).getValue(); % image width, pixels
    stackSizeY = omeMeta.getPixelsSizeY(0).getValue(); % image height, pixels
    stackSizeZ = omeMeta.getPixelsSizeZ(0).getValue(); % number of Z slices
    stackSizeC = omeMeta.getPixelsSizeC(0).getValue();
    WL=zeros(stackSizeC,1);
    for i=1:stackSizeC
        waveL=omeMeta.getChannelExcitationWavelength(0,i-1);
        if ~isempty(waveL)
        WL(i)=waveL.value();
        end
    end
    stackSizeT= omeMeta.getPixelsSizeT(0).getValue();
    stackDimension= char(omeMeta.getPixelsDimensionOrder(0).getValue());


    voxelSizeXdefaultValue = omeMeta.getPixelsPhysicalSizeX(0);  % returns value in default unit
    if ~isempty(voxelSizeXdefaultValue)
        voxelSizeXdefaultUnit = omeMeta.getPixelsPhysicalSizeX(0).unit().getSymbol(); % returns the default unit type
    else
        voxelSizeXdefaultUnit=[];
    end
    %voxelSizeX = omeMeta.getPixelsPhysicalSizeX(0).value(ome.units.UNITS.MICROMETER); % in µm
    %voxelSizeXdouble = voxelSizeX.doubleValue();                                  % The numeric value represented by this object after conversion to type double
    %voxelSizeY = omeMeta.getPixelsPhysicalSizeY(0).value(ome.units.UNITS.MICROMETER); % in µm
    %voxelSizeYdouble = voxelSizeY.doubleValue();                                  % The numeric value represented by this object after conversion to type double
    %voxelSizeZ = omeMeta.getPixelsPhysicalSizeZ(0).value(ome.units.UNITS.MICROMETER); % in µm
    voxelSizeZdouble = omeMeta.getPixelsPhysicalSizeZ(0);
    s.Name=filename(1:end-4);
    s.X=stackSizeX;
    s.Y=stackSizeY;
    s.Z=stackSizeZ;
    s.C=stackSizeC;
    s.T=stackSizeT;
    s.Dim=stackDimension;
    s.nseries=nseries;
    if ~isempty(voxelSizeXdefaultValue) && stackSizeZ>1
        s.PhysicalXY=double(voxelSizeXdefaultValue.value());
        s.PhysicalZ=double(voxelSizeZdouble.value());
    elseif ~isempty(voxelSizeXdefaultValue) && stackSizeZ==1
        s.PhysicalXY=double(voxelSizeXdefaultValue.value());
        s.PhysicalZ=0;
    else
        s.PhysicalXY=1;
        s.PhysicalZ=1;
    end
    s.PixelType=char(omeMeta.getPixelsType(0));
    s.DeltaT=omeMeta.getPixelsTimeIncrement(0);
    if ~isempty(voxelSizeXdefaultUnit)
        s.pixUnit=char(voxelSizeXdefaultUnit);
    else
        s.pixUnit='Pixel';
    end
    s.wavelength=double(WL);
    sinfo=s;

else
    for i=1:nseries
        fname=omeMeta.getImageName(i-1);
        stackSizeX = omeMeta.getPixelsSizeX(i-1).getValue(); % image width, pixels
        stackSizeY = omeMeta.getPixelsSizeY(i-1).getValue(); % image height, pixels
        stackSizeZ = omeMeta.getPixelsSizeZ(i-1).getValue(); % number of Z slices
        stackSizeC = omeMeta.getPixelsSizeC(i-1).getValue();
        WL=zeros(stackSizeC,1);
        for j=1:stackSizeC
            waveL=omeMeta.getChannelExcitationWavelength(0,j-1);
            if ~isempty(waveL)
                WL(j)=waveL.value();
            else
                WL(j)=NaN;
            end
        end
        stackSizeT= omeMeta.getPixelsSizeT(i-1).getValue();
        stackDimension= char(omeMeta.getPixelsDimensionOrder(i-1).getValue());
        voxelSizeXdefaultValue = omeMeta.getPixelsPhysicalSizeX(i-1);  % returns value in default unit
        if ~isempty(voxelSizeXdefaultValue)
            voxelSizeXdefaultUnit = omeMeta.getPixelsPhysicalSizeX(i-1).unit().getSymbol(); % returns the default unit type
        else
            voxelSizeXdefaultUnit=[];
        end
        %voxelSizeX = omeMeta.getPixelsPhysicalSizeX(0).value(ome.units.UNITS.MICROMETER); % in µm
        %voxelSizeXdouble = voxelSizeX.doubleValue();                                  % The numeric value represented by this object after conversion to type double
        %voxelSizeY = omeMeta.getPixelsPhysicalSizeY(0).value(ome.units.UNITS.MICROMETER); % in µm
        %voxelSizeYdouble = voxelSizeY.doubleValue();                                  % The numeric value represented by this object after conversion to type double
        %voxelSizeZ = omeMeta.getPixelsPhysicalSizeZ(0).value(ome.units.UNITS.MICROMETER); % in µm
        voxelSizeZdouble = omeMeta.getPixelsPhysicalSizeZ(i-1);
        s(i).Name=char(fname);
        s(i).X=stackSizeX;
        s(i).Y=stackSizeY;
        s(i).Z=stackSizeZ;
        s(i).C=stackSizeC;
        s(i).T=stackSizeT;
        s(i).Dim=stackDimension;
        if ~isempty(voxelSizeXdefaultValue) && stackSizeZ>1
            s(i).PhysicalXY=double(voxelSizeXdefaultValue.value());
            if ~isempty(voxelSizeZdouble)
            s(i).PhysicalZ=double(voxelSizeZdouble.value());
            else
                s(i).PhysicalZ=NaN;
            end
        elseif ~isempty(voxelSizeXdefaultValue) && stackSizeZ==1
            s(i).PhysicalXY=double(voxelSizeXdefaultValue.value());
            s(i).PhysicalZ=0;
        else
            s(i).PhysicalXY=1;
            s(i).PhysicalZ=1;
        end
        s(i).PixelType=char(omeMeta.getPixelsType(i-1));
        s(i).DeltaT=omeMeta.getPixelsTimeIncrement(i-1);
        if ~isempty(voxelSizeXdefaultUnit)
            s(i).pixUnit=char(voxelSizeXdefaultUnit);
        else
            s(i).pixUnit='Pixel';
        end
        s(i).wavelength=double(WL);
    end
    sinfo=s;
end

