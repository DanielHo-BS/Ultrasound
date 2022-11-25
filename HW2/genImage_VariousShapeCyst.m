% matlab program to simulate ultrasound images
% with a cyst in the middle 
%
% user-specified parameters are:
% 		cystdB: cyst contrast relative to background in dB
% 		displayDR: display dynamic range in dB
%		masterG: master gain

                                                                         
clear
clc
%% STEP1: Construct the map of scatter magnitude

% define parameters
cystdB=-20;  % if cystdB>0, cyst looks bright; on the contrary, it looks dark.
displayDR=40; %40
masterG=0;

% define raw image
xpixel=256;  % image size
ypixel=256;

cystL=10^(cystdB/20);      % original magnitude (gray level value) of cyst, which comes from the equation:
xpixel2=fix((xpixel+1)/2);        % find the center of the whole image
ypixel2=fix((ypixel+1)/2);
xyaxis=([1:xpixel]'-xpixel2)*ones(1,ypixel)+sqrt(-1)*ones(xpixel,1)*([1:ypixel]-ypixel2); % change the coordinate to make center be (0, 0)
mag=ones(xpixel,ypixel);  

% Variety of Cyst
inclusion_temp=imresize(imread('cat.png'),0.2);
%inclusion_temp=imread('irregular.bmp');

[row column]=find(double(inclusion_temp(:,:))==0);
%[row column]=find(double(inclusion_temp(:,:,1))==0);

centerX_cyst=fix((column(1)+column(end))/2);
centerY_cyst=fix((row(1)+row(end))/2);
calibrateX=xpixel2-centerX_cyst;
calibrateY=ypixel2-centerY_cyst;

for i=1:length(row)
    mag(row(i)+calibrateY, column(i)+calibrateX)=cystL;
end
figure; imagesc(mag);colorbar;title('Map of scatter magnitude ')
%% STEP2: Construct the map of scatter phasor and multiply with scatter magnitude
ii = round(1000*rand(1));
randn('state',ii);  % 0
rawr=randn(xpixel,ypixel); % real part
randn('state',ii+10); % 10
rawi=randn(xpixel,ypixel);  % imaginary part
raw=rawr+sqrt(-1)*rawi;
raw=raw.*mag; %!!!!!!
figure; imagesc(abs(raw));colorbar;title('Magnitude of scatter function ')

%% STEP3: Define the PSF 

% define point spread function
% psfx is the axial PSF
bw_x = 2;
psfx=exp(-pi*(([1:xpixel]'-xpixel2)/bw_x).^2);  % exp(-pi* x^2/ £mx^2) , x= [1:xpixel]'-xpixel2, £mx=bw_x
psfx=psfx/max(abs(psfx));
% psfy is the lateral PSF
bw_y = 2;
psfy=exp(-pi*(([1:ypixel]'-ypixel2)/bw_y).^2);  % exp(-pi* y^2/ £my^2) , y= [1:ypixel]'-ypixel2, £mx=bw_y
psfy=psfy/max(abs(psfy));
% axial PSF multiply lateral PSF ---> 2D PSF
psf1=(psfx*psfy.'); 
figure;imagesc(psf1);colorbar
psf1=fftshift(psf1); 
                                                                                     
%% STEP4: Obtain the image by convolving the PSF with the scatter function
% obtain the image
imagedata1=ifft2(fft2(raw).*fft2(psf1));  %fft--> map to frequency domain 

%% STEP5: Display the image
imagelog1=20*log10(abs(imagedata1));
imagelog1=imagelog1-max(max(imagelog1));
figure, image(imagelog1+displayDR);colormap(gray(displayDR))

%% 
pre_dB_Image_Magnitude_E=abs(imagedata1);
pre_dB_Image_Intensity_I=abs(imagedata1).^2;

figure
subplot(211)
histogram(pre_dB_Image_Intensity_I, 'Normalization', 'pdf')
title("Image Intensity (Exponential)")
subplot(212)
histogram(pre_dB_Image_Magnitude_E, 'Normalization', 'pdf')
title("Image Magnitude (Rayleigh)")
%% 
SNR_I = mean(pre_dB_Image_Intensity_I(:))/std(pre_dB_Image_Intensity_I(:))
SNR_E = mean(pre_dB_Image_Magnitude_E(:))/std(pre_dB_Image_Magnitude_E(:))