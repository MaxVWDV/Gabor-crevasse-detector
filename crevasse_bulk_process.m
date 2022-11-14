%Example batch script for processing entire folder of .tif satellite
%images). You may want to make some edits depending on your system
%configuration.

% Get file names. Note this works on WINDOWS but you probably need to used
% dir() on mac/linux.
filen=ls('../narsap_imagery_sentinel_filtered');

filen = filen(3:end-3,:);

%Load a binary mask of glacier area.
load('glacier_mask.mat');

%Pre-create arrays
binary_crevasse_locations=NaN(1801,3301,224);
binary_crevasse_orientations=NaN(1801,3301,224);
binary_crevasse_size=NaN(1801,3301,224);
binned_crevasse_intensity=NaN(91,166,224);
binned_crevasse_orientation=NaN(91,166,224);
binned_crevasse_size=NaN(91,166,224);
binned_crevasse_MAD=NaN(91,166,224);



    separation = 10; 
    gab_band = 2;
    gab_ar = 0.1;
    clip_threshold = 1.25;
    downsamp = 20;

for loop = 1:size(filen,1)

    %Read a portion of an image (edit PIXEL REGION command or remove to get
    %the whole image)
    image_crevasses = ...
        imread(strcat('../narsap_imagery_sentinel_filtered/',filen(loop,:)),'PixelRegion',{[600 2400],[500 3800]});

    image_crevasses(isnan(image_crevasses))=0;

    %Calculate crevasse locations with GCD
    tic;
    [binary_crevasse_locations(:,:,loop),binary_crevasse_orientations(:,:,loop),binary_crevasse_size(:,:,loop),binned_crevasse_intensity(:,:,loop)...
        ,binned_crevasse_orientation(:,:,loop),binned_crevasse_size(:,:,loop),binned_crevasse_MAD(:,:,loop)] =...
        extract_crevasses(image_crevasses,separation,gab_band,gab_ar,clip_threshold,downsamp,glacier_mask);
    toc;

    disp(loop)



end


save('crev_results_10.mat','binary_crevasse_locations','binary_crevasse_orientations','binary_crevasse_size','binned_crevasse_intensity','binned_crevasse_orientation','binned_crevasse_size','binned_crevasse_MAD','-v7.3')