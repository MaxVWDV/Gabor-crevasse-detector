function [binary_crevasse_locations,binary_crevasse_orientations,binned_crevasse_intensity,binned_crevasse_orientation,binned_crevasse_MAD] =...
 extract_crevasses(image_crevasses,separation,gab_size,gab_band,gab_ar,clip_threshold,downsamp,glacier_mask)
%EXTRACT_CREVASSES
%Inputs:
%image: image to filter
%separation: angle separation of gabor filters (e.g. 10 degrees for 18
%            filters between 0 and 170 degrees)
%gab_size: scale of the gabor filter
%gab_band: Gabor spatial frequency bandwidth (see:
%           https://uk.mathworks.com/help/images/ref/imgaborfilt.html)
%gab_ar: Gabor filter spatial aspect ratio
%clip_threshold: threshold for extracting crevasses
%downsamp: downsampling value for binned crevasse intensities
%glacier_mask: binary mask of glacier location (1) and not glacier location
%(0)
%
%Max Van Wyk de Vries @ University of Oxford, November 2022




if nargin<8
    glacier_mask=ones(size(image_crevasses));
end

%Create GABOR phase map
[phase,phasedir] = mygabor(image_crevasses,separation,gab_size,gab_band,gab_ar);

%Correct phase for geogrpahic orientations
phasedir=180-phasedir;

%Remove no data areas
phase(image_crevasses==0)=NaN;
phasedir(image_crevasses==0)=NaN;

%Remove non-glaciated areas
phase(glacier_mask==0)=NaN;
phasedir(glacier_mask==0)=NaN;

%Calculate binary crevasse locations
binary_crevasse_locations = phase;

binary_crevasse_locations = rescale(binary_crevasse_locations);

binary_crevasse_locations(binary_crevasse_locations>clip_threshold*median(binary_crevasse_locations,'all','omitnan'))=1;

binary_crevasse_locations(binary_crevasse_locations~=1)=0;

%Calculate binary crevasse orientation
binary_crevasse_orientations = binary_crevasse_locations.*phasedir;

%Calculate binned crevasse intensity
meanFilterFunction = @(theBlockStructure) mean(theBlockStructure.data(:),'omitnan');
binned_crevasse_intensity = blockproc(binary_crevasse_locations, [downsamp,downsamp], meanFilterFunction);

binary_crevasse_orientations(binary_crevasse_orientations==0)=NaN;

%Calculate binned crevasse orientation
binned_crevasse_orientation = blockproc(binary_crevasse_orientations, [downsamp,downsamp], meanFilterFunction);

%Calculate binned crevase orientation variance
MADFilterFunction = @(theBlockStructure) myMAD(theBlockStructure.data(:),0,'omitnan');
binned_crevasse_MAD = blockproc(binary_crevasse_orientations, [downsamp,downsamp], MADFilterFunction);

end

