function [phase,phasedir] = mygabor(image,separation,gab_size,gab_band,gab_ar,minangle,maxangle)
%Gabor phase maxima edge detection. Calculates the 'line intensity' and
%'line orientation' in an image, with some advantages over other edge
%detection techniques (i.e. less sensitive to 'points', etc).
%
%USAGE:
%[phase,phasedir] = mygabor(image,separation,gab_size,gab_band,gab_ar,minangle,maxangle)
%
%Inputs:
%image: image to filter
%separation: angle separation of gabor filters (e.g. 10 degrees for 18
%            filters between 0 and 170 degrees)
%gab_size: scale of the gabor filter
%gab_band: Gabor spatial frequency bandwidth (see:
%           https://uk.mathworks.com/help/images/ref/imgaborfilt.html)
%gab_ar: Gabor filter spatial aspect ratio
%(optional) minangle = minimum gabor filter angle
%(optional) maxangle = maximum gabor filter angle
%
%Outputs:
%phase: local gabor phase angle maxima. A measure of how strongly linear a
%       cetain area of the image is
%phasedir: local dominant line direction.
%
%Max Van Wyk de Vries @ University of Oxford, November 2022

%Turn warnings off (can produce a lot of unnecessary outputs otherwise)
warning('off','all')

%Optional parameters. Set to default (0 to 179 degrees) if not entered.
if nargin==5
minangle = 0;
maxangle = 179.99;
end


%Build bank of oriented Gabor filter. Use default MATLAB function for this.
gabor_bank = gabor(gab_size,minangle:separation:maxangle,'SpatialFrequencyBandwidth',gab_band,'SpatialAspectRatio',gab_ar);

%Find the size of input image
outSize = size(image);

%Find the size of the largest filter
sizeLargestKernel = findMaximumKernelSize(gabor_bank);

% Gabor always returns odd length kernels
padSize = (sizeLargestKernel-1)/2;
image = padarray(single(image),padSize,'replicate'); %Pad the image to a size that can be used (even).
sizeAPadded = size(image);

image = fft2(image); %Fourrier transform the image

out = zeros([outSize,length(gabor_bank)],'like',image); %Create array in memory to save time

start = padSize+1;      %Limits of the image
stop = start+outSize-1;

%Loop through the gabor filters. See function myFDTF at the bottom of this
%script. Trimmed here to reduce computational cost.
for p = 1:length(gabor_bank)       
    out_temp = ifft2(image .* ifftshift(myFDTF(struct(gabor_bank(1,p)),sizeAPadded,class(image)))); %I have condensed this for computational efficiency.
    out(:,:,p) = out_temp(start(1):stop(1),start(2):stop(2));%Save a cropped out portion to the output array
end

[phase,phasedir] = max((rescale(angle(out))),[],3); %Calculate phase angle portion (using both IMAGINARY and REAL portions)
%Note the second output here is the direction. This is quite elegant to
%calculate in MATLAB.

phasedir = (phasedir-1)*separation;

end

function sizeH = findMaximumKernelSize(gabor_bank)

sizeH = [0 0];
for p = 1:length(gabor_bank)
    thisKernelSize = gabor_bank(p).KernelSize;
    % Kernels are always square, gabor enforces this.
    if  thisKernelSize(1) > sizeH(1)
         sizeH = thisKernelSize;
     end
end

end

function H = myFDTF(self, imageSize, classA)
            %Frequency domain Gabor filtering. 
            %
            % Directly construct frequency domain transfer function of
            % Gabor filter. (Jain, Farrokhnia, "Unsupervised Texture
            % Segmentation Using Gabor Filters", 1999)



            [U,V] = meshgrid(cast(images.internal.createNormalizedFrequencyVector(imageSize(2)),classA),...
                cast(images.internal.createNormalizedFrequencyVector(imageSize(1)),classA));

            H = (2*pi*self.SigmaX*self.SigmaY).*...
                exp(-0.5*( (((U .*cosd(self.Orientation) - V .*sind(self.Orientation))...
                -(1/self.Wavelength)).^2)./(1/(2*pi*self.SigmaX))^2 + (U .*sind(self.Orientation) +...
                V .*cosd(self.Orientation)).^2 ./ (1/(2*pi*self.SigmaY))^2) );

        end


