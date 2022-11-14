%Example single image crevasse extraction
%
% All the data to run this is in the folder. If it does not work first
% check if you are missing any matlab dependencies. If issues persist or
% you are trying to edit this to run in bulk on your own area, you can
% contact me at maximillian.vanwykdevries@ouce.ox.ac.uk

%Load a binary mask of glacier area.
load('glacier_mask.mat');

% Set the Gabor filtering parameters (see function mygabor for details)
separation = 10;                    %Angular resolution (degrees)
gab_band = 2;                       %Gabor spatial bandwith
gab_size = 2;                       %Gabor filter scale
gab_ar = 0.1;                       %Gabor angular ratio
clip_threshold = 1.25;              %Clipping threshold for binary crevasse mask
downsamp = 20;                      %Degree of downsampling for summary statistics


%Read a portion of the image (edit PIXEL REGION command or remove to get
%the whole image)
image_crevasses = imread('20210823.tif','PixelRegion',{[600 2400],[500 3800]});

%Set NaNs to zero
image_crevasses(isnan(image_crevasses))=0;

%Calculate crevasse locations with GCD. This takes about 7 seconds on my
%computer with default settings.
tic;
[binary_crevasse_locations,binary_crevasse_orientations,binned_crevasse_intensity,binned_crevasse_orientation,binned_crevasse_MAD] =...
 extract_crevasses(image_crevasses,separation,gab_size,gab_band,gab_ar,clip_threshold,downsamp,glacier_mask);
toc;

%% Make plots of the data
figure; imagesc(binary_crevasse_orientations);colormap('bone');colorbar;title('Crevase Orientation')
figure; imagesc(binned_crevasse_intensity);colormap('copper');colorbar;title('Binned crevasse intensity')

%Note, I would highly recommend downloading one of the scientific colormap
%suites to plot this (E.g. crameri's romaO is good for plotting
%orientations

