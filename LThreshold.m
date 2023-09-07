function DAPIBW=LThreshold(DAPIStack, ThreshFactor)

Lg=imgaussfilt3(DAPIStack,5);
T=graythresh(Lg)*ThreshFactor;
LW=imbinarize(DAPIStack,T);
%[x, y, z]=size(LW);



LW2c=bwmorph3(LW,'clean');
DAPIBW=bwmorph3(LW2c,'majority');
DAPIBW=bwareaopen(DAPIBW,1e5);
DAPIBW=imclose(DAPIBW,strel('disk',2));
DAPIBW=imfill(DAPIBW,'holes');






