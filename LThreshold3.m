function LaminBW=LThreshold3(LaminStack)

% LThreshold3() uses imgaussfilt before Otsu to smooth deconvolution
% artefacts


[x, y, z]=size(LaminStack);
LC=mat2cell(LaminStack,x,y,ones(z,1));
LCg=cellfun(@(x) imgaussfilt(x,2),LC,'UniformOutput',false);
Lg=cat(3,LCg{:});
LaminBW=bwareaopen(imbinarize(Lg),1e4);



