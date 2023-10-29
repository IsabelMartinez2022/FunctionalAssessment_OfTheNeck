%Task 2
%Calculation of the spectrogram of each patient

%for i = 1:200
    if isfile("Pte_"+"19"+"​_extracted.csv")
        read_data= readtable("Pte_"+"19"+"​_extracted.csv");
        read_data_array = table2array(read_data);
        %patient_xyz contains the Euler angles
        patient_xyz= str2double(strrep(read_data_array,',','.')); 
    
        %First, transformation of the Euler angles to a quaternion
        patient_quaternion = eul2quat(patient_xyz,"XYZ");
        fs= 50; %sampling rate of Unity's fixedUpdate()
        t = (0:(6735))/fs; %creation of a time vector 
        
        %QUESTION: TRANSFORM TO QUATERNION??? 
        %With eul2quat()
        %With quatmultiply()
        %or slerp()
        
        window_length = 256;
        overlap = window_length/2;
        nfft = 512;
      
        [s_x,f_x,t_x]=spectrogram(continuous_x,window_length,overlap,nfft,fs);
        figure;
        subplot(3,1,1)
        waterplot(s_x,f_x,t_x);

        [s_y,f_y,t_y]=spectrogram(patient_xyz(:,2),window_length,overlap,nfft,fs);
        subplot(3,1,2)
        waterplot(s_y,f_y,t_y);
        
        [s_z,f_z,t_z]=spectrogram(patient_xyz(:,3),window_length,overlap,nfft,fs);
        subplot(3,1,3)
        waterplot(s_z,f_z,t_z);
    end 
%end

function waterplot(s,f,t)
% Waterfall plot of spectrogram from MatLab libreries
    waterfall(f,t,power(abs(s)',2))
    set(gca,XDir="reverse",View=[30 50])
    xlabel("Frequency (Hz)")
    ylabel("Time (s)")
end