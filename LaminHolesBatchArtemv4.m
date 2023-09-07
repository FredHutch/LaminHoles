function data=LaminHolesBatchArtemv4()
% LaminHolesBatchArtem is a funtion used to batch-analyzed .lif files
% containing multiple series of 3D stacks of Lamin stained nuclei. It
% computes stats about holes in the lamina mesh, as well as stats of the
% nuclear shape.
%
% Versions:
%
% v2 uses DAPI to get the convex hull
% v3 gets rays from outside, hitting the DAPI convexhull where gaps are.
% More accurate description of gaps. v3 also improves overall quality
% control of input
%
%
% INPUT:    -filename   String of the name of the lif file
%           -sizeFilt   filter value for size in microns. Holes smaller
%           than this value are not analyzed
%           -LaminChannel   scalar defining the number of the lamin channel
%           -DAPIChannel   scalar defining the number of the DAPI channel
%           -OtherChannel scalar defining the other channel intensity needs
%           to be derived (usually second lamin) specify 0 if none
%           -regswitch boolean defining whether to register DAPI channel
%           with Lamin channel or not. Usefule when the z- shift between
%           DAPI and Lamin is of several voxels (chromatic aberration?)
%
% OUTPUT:   -data   a table gathering all the stats

%% Load and read lif files, extract metadata


close all;clc;


[fname, foldername, seriesList, sname, ppath]=dialogHolesfiles();
if ~isempty(fname)
    [reader, ~, sinfo]=bfGetInfo(fname);
    testlist={sinfo.Name};
    [~, ~, imgidx]=intersect(seriesList,testlist,'stable');
    imgidx=imgidx';
    filename=fname;
elseif ~isempty(foldername)
    npd=numel(seriesList);
    nreader=cell(npd,1);
    nsinfo=cell(npd,1);
    imgidx=1:npd;
    for i=1:npd
        loadname=fullfile(foldername,seriesList{i});
        [reader, ~, sinfo]=bfGetInfo(loadname);
        nreader{i}=reader;
        nsinfo{i}=sinfo;
    end
    filename=foldername;
else
    warning('No File(s) Selected!');
    data=[];
    return;
end

[DAPIChannel, LaminChannel, OtherChannel, sizeFilt, regswitch,removeswitch,...
    OI, IO]=dialogHoles();

SeriesFinalT=[];


for i=imgidx % outer loop thru each series
    nucFinalT=[];
    if ~isempty(fname)
        curinfo=sinfo(i);
    else
        curinfo=nsinfo{i};
    end
    x=curinfo.X; y=curinfo.Y; z=curinfo.Z;nC=curinfo.C;
    type=curinfo.PixelType;
    realdapi=find(curinfo.wavelength==405);
    S=curinfo.Name;
    F=filename;
    if isempty(realdapi)
        formatf="DAPI channel cannot be asserted for series %s of file %s.\n";

        warning(formatf,S, F);
    elseif realdapi~=DAPIChannel
        formatf="Input DAPI channel index doesn't match retrieved wavelength. \n" + ...
            "ABORTING series %s of file %s.\n";

        warning(formatf,S, F);pause(0.5);
        continue
    end

    if max([DAPIChannel LaminChannel OtherChannel])>nC
        formatf="Number of input channels doesn't match number of retrieved channels. \n" + ...
            "ABORTING series %s of file %s.\n";
        S=curinfo.Name;
        F=filename;
        warning(formatf,S, F);
        continue
    end


    LStack=zeros(x,y,z,type); % Lamin
    DStack=zeros(x,y,z,type); % DAPI
    if OtherChannel
        OStack=zeros(x, y, z, type);
    end
    if isempty(fname)
        reader=nreader{i};
    else
        reader.setSeries(i-1);
    end
    for zslice=1:z
        iplane=reader.getIndex(zslice-1,LaminChannel-1,0)+1;
        LStack(:,:,zslice)=bfGetPlane(reader,iplane);
        iplaned=reader.getIndex(zslice-1,DAPIChannel-1,0)+1;
        DStack(:,:,zslice)=bfGetPlane(reader,iplaned);
        if OtherChannel
            iplaned=reader.getIndex(zslice-1,OtherChannel-1,0)+1;
            OStack(:,:,zslice)=bfGetPlane(reader,iplaned);
        end
    end

    %% identify each nucleus

    maxDStack=max(DStack,[],3);
    maxDAPIBW=imbinarize(maxDStack);
    fp=fspecial('average',10);
    LMWf=imfilter(maxDAPIBW,fp);
    %%%% remove nuclei that are less than 10 pixels from image border
    ROI=true(size(LMWf));
    ROI=bwmorph(ROI,'shrink',11);
    J=imreconstruct(~ROI, LMWf);
    LMWf(J)=false;
    %%%% 
    LMWf=bwareaopen(LMWf,5000);
    StatsLamin=regionprops(LMWf,'PixelIdxList','BoundingBox','Centroid','Solidity');


    %% Analyze holes in each nucleus

    for j=1:numel(StatsLamin) %% inner loop thru each nucleus of a serie
        formatspec="Computing nucleus %d of series %s of lif file %s. \n";
        A1=j;
        A2=curinfo.Name;
        A3=filename;
        fprintf(formatspec,A1,A2,A3);
        BBox=StatsLamin(j).BoundingBox;
        BBox=BBox + [-10 -10 20 20]; % extend bounding box to give some room

        cub=[BBox(1) BBox(2) 1 BBox(3) BBox(4) z-1];
        try
        LaminStackCrop=imcrop3(LStack,cub);
        catch
            keyboard
        end
        origLamin=zeros(BBox(4)+10,BBox(3)+10,curinfo.Z,type);
        origLamin(5:end-5,5:end-5,:)=LaminStackCrop;

        DAPIStackCrop=imcrop3(DStack,cub);
        origDAPI=zeros(BBox(4)+10,BBox(3)+10,curinfo.Z,type);
        origDAPI(5:end-5,5:end-5,:)=DAPIStackCrop;
        if OtherChannel
            OStackCrop=imcrop3(OStack,cub);
            origOther=zeros(BBox(4)+10,BBox(3)+10,curinfo.Z,type);
            origOther(5:end-5,5:end-5,:)=OStackCrop;
        end

        DAPIBW=LThreshold(origDAPI,1);
        LaminBW=LThreshold3(origLamin);
        CCL=bwconncomp(LaminBW, 26);
        CCD=bwconncomp(DAPIBW,26);
        if CCL.NumObjects~=1 || CCD.NumObjects~=1
            continue
        end

        [HOLESW, PerimW, LaminHULLW]=computeLaminHolesv2(DAPIBW,LaminBW,regswitch, OI, IO);

        if removeswitch
            HOLESW=removeFloorHoles(HOLESW,LaminHULLW,curinfo.PhysicalZ);
        end

        DAPIHULLW=imfill(PerimW,'holes');
        CC=bwconncomp(DAPIHULLW,26);
        if CC.NumObjects~=1
            continue
        end
        PWP=PerimW;
        kk=find(PWP);
        [xx,yy,zz]=ind2sub(size(PWP),kk);
        S=regionprops3(PWP,'SurfaceArea');
        sa=S.SurfaceArea*curinfo.PhysicalXY^2;

        %pden=numel(kk)/sa;
        if round(sa*20)<numel(kk)

            r=randperm(numel(kk),round(sa*20));

        else
            r=1:numel(kk);
        end
        P=[xx yy zz];
        P(:,1:2)=P(:,1:2)*curinfo.PhysicalXY;
        P(:,3)=P(:,3)*curinfo.PhysicalZ;
        Pr=P(r,:);
        shp=alphaShape(Pr,inf);
        [~, Prb]=shp.boundaryFacets;
        [ ~, curvature ] = findPointNormals(Prb);

        S=regionprops3(HOLESW,'Volume','Centroid','Solidity');
        S.Volume=S.Volume*curinfo.PhysicalXY^2*curinfo.PhysicalZ;
        tf=S.Volume<sizeFilt;
        S(tf,:)=[];
        if isempty(S)
            S=table(NaN,[NaN NaN NaN],NaN, NaN,'VariableNames',{'Volume','Centroid','Solidity','meanCurvature'});
        else
            S.Centroid=S.Centroid(:,[2 1 3]).*[curinfo.PhysicalXY ...
                curinfo.PhysicalXY curinfo.PhysicalZ];



            cent=S.Centroid;

            [idxcurv, ~]=knnsearch(Prb,cent,"K",20);

            centcurv=curvature(idxcurv);
            if size(idxcurv,1)>1
                mcentcurv=mean(centcurv,2);
            elseif size(idxcurv,1)==1
                mcentcurv=mean(centcurv);
            end
            tmcc=array2table(mcentcurv,'VariableNames',{'meanCurvature'});
            S=[S tmcc]; %#ok<AGROW>
        end
        %S=table2struct(S,'ToScalar',true);

        NucID=repmat(j,size(S.Volume,1),1);
        NucIDT=array2table(NucID,'VariableNames',{'NucID'});

        SN=regionprops3(DAPIHULLW,origDAPI,'Volume','SurfaceArea','PrincipalAxisLength','MeanIntensity');
        SN=table2struct(SN,'ToScalar',true);
        SN.VolRatio=SN.Volume/numel(find(LaminHULLW));
        SN.Volume=SN.Volume*curinfo.PhysicalXY^2*curinfo.PhysicalZ;
        SN.SurfaceArea=SN.SurfaceArea*curinfo.PhysicalXY^2;
        SN.PrincipalAxisLength(:,1:2)=SN.PrincipalAxisLength(:,1:2)*...
            curinfo.PhysicalXY;
        SN.PrincipalAxisLength(:,3)=SN.PrincipalAxisLength(:,3)*...
            curinfo.PhysicalZ;

        zp=squeeze(max(DAPIHULLW,[],[1 2]));
        zs=find(zp);
        SN.NucHeight=curinfo.PhysicalZ*(max(zs)-min(zs));

        SI=regionprops3(LaminBW,origLamin,'MeanIntensity');
        SN.LaminMI=SI.MeanIntensity;
        if OtherChannel
            SN.OtherMI=mean(origOther(LaminBW));
        else
            SN.OtherMI=NaN;
        end

        NucAr=table2array(struct2table(SN));
        repNucAr=repmat(NucAr,size(NucID,1),1);
        repNucAr=repNucAr(:,[1 7 5 2 3 4 8 6 9 10]);
        repNucArT=array2table(repNucAr,'variableNames',{'NucVol','VolRatio','NucSurfArea',...
            'NucAxisLength_x','NucAxisLength_y','NucAxisLength_z','NucleusHeight','NucDAPIIntensity','NucLaminIntensity','NucOtherIntensity'});
        nucFinalTcur=[NucIDT, repNucArT S];
        nucFinalT=[nucFinalT;nucFinalTcur]; %#ok<AGROW>





    end
    sizeTFile=size(nucFinalT,1);

    repfileT=array2table(cellstr(repmat(curinfo.Name,sizeTFile,1)),'VariableNames',{'Series_Name'});

    SeriesFinalTcur=[repfileT, nucFinalT];

    SeriesFinalT=[SeriesFinalT; SeriesFinalTcur]; %#ok<AGROW>

    CentShow=[StatsLamin.Centroid];
    figure, imshow(maxDStack,[]);
    nn=1:numel(StatsLamin);
    Centshow=reshape(CentShow,2,numel(nn))';
    for kk=1:numel(nn)
        text(gca,Centshow(kk,1),Centshow(kk,2),int2str(nn(kk)),'Color','y','FontWeight','bold');
    end
    drawnow;
    [~, fff]=fileparts(curinfo.Name);
    sfname=[fff '.jpg'];
    sfname=fullfile(ppath,sfname);
    saveas(gcf,sfname);
    close;



end

data=SeriesFinalT;
%csvname=[filename(1:end-4) '.csv'];
if ~isempty(data)
    writetable(data,sname);
end




