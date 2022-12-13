% Given the received channel data by a 128-channel linear array with sampling
% frequency of 20 MHz and 100 MHz from three reflectors in the central
% scanline (i.e., X=0) at range of 10, 25 and 40 mm, perform the delay-and-sum
% beamforming for the central scanline and demonstrate your beam-sum
% scanline waveform.

clc; clear;
%% load channel data [100MHz]
load("ch_data_20M.mat")
%% initlization
X = 0;
Nr=1200;
Delayed_chdata = zeros(Nr,128);

%% delay data
for R = 1:Nr
    Z =range(R);
    for Ch = 1:128
        X_ch = ch_position(Ch);
        Ch_delay = round(fss*(Z+sqrt((X-X_ch)^2+(Z-0)^2))/soundv);
        Delayed_chdata(R, Ch) = ch_data(Ch_delay, Ch);
    end
end

%% sum data
Beamformed_SL = sum(Delayed_chdata,2);

%% show the channel data
figure();
imagesc(ch_data)
title("Channel data")
xlabel("channel index")
ylabel("time sample index [fs=20MHz]")

figure();
imagesc(Delayed_chdata)

title("Delayed Channel data")
xlabel("channel index")
ylabel("Range Sample Index")

%% change sample range to depth
% figure();
% imagesc([1:128],[0:5999]/fss*soundv/2,ch_data)
% figure();
% imagesc([1:128],range,Delayed_chdata)

%% show Beam-sum Scanline
figure();
plot(range,Beamformed_SL)
xlabel("Range[m]")
ylabel("Amplitude")
title("Beam-sum Scanline")
grid on;