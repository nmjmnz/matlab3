Almost out of storage … 
If you run out, you can't create or edit files, send or receive email on Gmail, or back up to Google Photos.

fs = 44100;
hfs = fs/2;
[P,Q] = rat(hfs/fs);
dt = 1/fs;

%FS1->FS2
michaelOriginal = audioread("michael.wav");    %gets data from original signal 
lpVocals1 = lowPass(michaelOriginal,fs,5000);  %lowpass to isolate vocals

%FS2->FS3
ds1 = resample(lpVocals1,P,Q);                 %downsamples vocals                     
lpDS1 = lowPass(ds1,fs/2,1000);                %lowpass downsampled vocals
hpDS1 = highPass(ds1,fs/2,1000);               %highpass downsamplevocals
lpDS2 = resample(lpDS1,P,Q);                   %downsample lowpassed elements
hpDS2 = resample(hpDS1,P,Q);                   %downsample highpassed elements

%FS3->FS4
lpLPDS2 = lowPass(lpDS2,fs/4,500);             %low of low
hpLPDS2 = highPass(lpDS2,fs/4,500);            %high of low 
lpHPDS2 = lowPass(hpDS2,fs/4,2000);            %low of high     
hpHPDS2 = highPass(hpDS2,fs/4,2000);           %high of high
dsLPLPDS2 = resample(lpLPDS2,P,Q);             %downsample low of low
dsHPLPDS2 = resample(hpLPDS2,P,Q);             %downsample high of low    
dsLPHPDS2 = resample(lpHPDS2,P,Q);             %downsample low of high 
dsHPHPDS2 = resample(hpHPDS2,P,Q);             %downsample high of high 

%synthesis [broken, causing phase issues]
usLPLPDS2 = upsample(dsLPLPDS2,2);                                  %upsample low of low
usHPLPDS2 = upsample(dsHPLPDS2,2);                                  %upsample high of low    
usLPHPDS2 = upsample(dsLPHPDS2,2);                                  %upsample low of high    
usHPHPDS2 = upsample(dsHPHPDS2,2);                                  %upsample high of high        
lpFS3 = lowPass(usLPLPDS2,fs/4,500)+highPass(usHPLPDS2,fs/4,500);   %combine low of low & high of low    
hpFS3 = lowPass(usLPHPDS2,fs/4,2000)+highPass(usHPHPDS2,fs/4,2000); %combine low of high & high of high        
usLPFS3 = upsample(lpFS3,2);                                        %upsample low frequencies    
usHPFS3 = upsample(hpFS3,2);                                        %upsample high frequencies        
FS2 = lowPass(usLPFS3,fs/2,1000) + highPass(usHPFS3,fs/2,1000);     %combine low and high frequencies        
usFS2 = upsample(FS2,2);                                            %                                             
usFS1 = upsample(usFS2,2);                                          %                      
FS1 = lowPass(usFS1,fs,5000);                                     %                    
sound(FS1,fs*2,8);                                                                  

%filter bank analysis graphs
% plotGraph(michaelOriginal);
% plotGraph(lpVocals1);
plotGraph(FS1);
% plotGraph(hpDS1);
% plotGraph(dsLPLPDS2);
% plotGraph(dsHPLPDS2);
% plotGraph(dsLPHPDS2);
% plotGraph(dsHPHPDS2);

%synthesis graph

plotGraph(FS1);

% plotGraph(usFS2);
% plotGraph(FS1);

function plotGraph(dataSet)
    frequencySample = 44100;
    window = hamming(512);
    N_overlap = 256;
    N_fft = 1024;
    [~,F,T,P] = spectrogram(dataSet,window,N_overlap,N_fft,frequencySample,'yaxis');
    figure;
    surf(T,F,10*log10(P),'EdgeColor','none');
    axis tight;
    view(0,90);
    colormap(jet);
    set(gca,'clim',[-80,-20]);
    set(gca, 'color', [0 0 0.5137]);
    ylim([0 10000]);
    xlabel('Time (s)');ylabel('Frequency (Hz)')
end

function lowPassSignal = lowPass(x, fs, cutoff_freq)
    filter_order = 2000;
    normalized_cutoff = cutoff_freq / (fs/2);
    freq_resp = [1, 1, 0, 0];
    freq_vec = [0, normalized_cutoff, normalized_cutoff, 1];
    filter_coeffs = firls(filter_order, freq_vec, freq_resp);
    lowPassSignal = filter(filter_coeffs, 1, x);
end

function highPassSignal = highPass(x, fs, cutoff_freq)
    filter_order = 2000;
    normalized_cutoff = cutoff_freq / (fs/2);
    filter_coeffs = fir1(filter_order, normalized_cutoff, 'high');
    highPassSignal = filter(filter_coeffs, 1, x);
end
