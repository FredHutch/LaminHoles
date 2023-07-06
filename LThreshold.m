function LaminBW=LThreshold(LaminStack, ThreshFactor)

Lg=imgaussfilt3(LaminStack,5);
T=graythresh(Lg)*ThreshFactor;
LW=imbinarize(LaminStack,T);
%[x, y, z]=size(LW);



LW2c=bwmorph3(LW,'clean');
LaminBW=bwmorph3(LW2c,'majority');
LaminBW=bwareaopen(LaminBW,1e5);
LaminBW=imclose(LaminBW,strel('disk',2));
LaminBW=imfill(LaminBW,'holes');


% LWC=mat2cell(LaminBW,x,y,ones(z,1));
% LWC=squeeze(LWC);
% LWCC=cellfun(@(x) imfill(x,'holes'),LWC,'UniformOutput',false);
% LaminBW=cat(3,LWCC{:}) & LBWC;



