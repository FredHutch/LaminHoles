function newHOLESW=removeFloorHoles(HOLESW,LaminHULLW,PhysicalSizeZ)

SH=regionprops3(HOLESW,'Centroid','VoxelList','VoxelIdxList');
SP=regionprops3(bwperim(LaminHULLW),'VoxelList');
ZP=SP.VoxelList{1,1}(:,3);
f=mode(ZP);
VSH=SH.VoxelList;
r=cellfun(@(x) range(x(:,3)), VSH);
r=r*PhysicalSizeZ;
m=cellfun(@(x) median(x(:,3)), VSH);
df=abs(m-f);

tf=df<=4 & r<=1;

SH(tf,:)=[];
Pix=vertcat(SH.VoxelIdxList{:});
newHOLESW=false(size(HOLESW));
if ~isempty(Pix)
newHOLESW(Pix)=true;
end











