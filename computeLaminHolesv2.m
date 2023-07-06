function [HOLESW, PerimW, LaminHULLW]=computeLaminHolesv2(DAPIBW,LaminBW,regswitch, OI, IO)


z=size(LaminBW,3);
LaminHULLW=false(size(LaminBW));

for i=1:z
LaminHULLW(:,:,i)=imfill(bwconvhull(LaminBW(:,:,i),"union"),'holes');
end

if regswitch

SD=regionprops3(DAPIBW,'Centroid');
SL=regionprops3(LaminBW,'Centroid');

DD=fix(SL.Centroid-SD.Centroid);

DAPIBW=circshift(DAPIBW,DD(3),3);


SD=regionprops(max(DAPIBW,[],3),'Centroid');
SL=regionprops(max(LaminBW,[],3),'Centroid');

DD=round(SL.Centroid-SD.Centroid);

DAPIBW=circshift(DAPIBW,DD(2),1);
DAPIBW=circshift(DAPIBW,DD(1),2);




md=find(squeeze(max(DAPIBW,[],[1 2])));
ml=find(squeeze(max(LaminBW,[],[1 2])));

while range(md)-range(ml)>=-1
    DAPIBW=imerode(DAPIBW,ones(3,3,3));
    DAPIBW=bwareaopen(DAPIBW,1e4);
    md=find(squeeze(max(DAPIBW,[],[1 2])));
end

if min(md)-min(ml)==0
    DAPIBW=circshift(DAPIBW,1,3);
end

if max(md)-max(ml)==0
    DAPIBW=circshift(DAPIBW,-1,3);
end


end

if OI
CoreW=false(size(DAPIBW));
CoreW([1 end],:,:)=true;
CoreW(:,[1 end],:)=true;
CoreW(:,:,[1 end])=true;

Dist=bwdist(CoreW,'chessboard');
GeoD=bwdistgeodesic(~LaminBW,CoreW,'chessboard');
GDMatch=Dist==GeoD;
else
    GDMatch=true(size(DAPIBW));
end

PerimW=bwperim(DAPIBW);

HOLESW=GDMatch & PerimW;

if IO
CoreinW=imerode(LaminHULLW,strel('sphere',8));
Distin=bwdist(CoreinW,'chessboard');
GeoDin=bwdistgeodesic(~LaminBW,CoreinW,'chessboard');
GDMatchin=Distin==GeoDin;

HOLESW=HOLESW & GDMatchin;
end

