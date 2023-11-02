%Task 2
%Calculation of the spectrogram of each patient and saved as a png image
%The position of the stored appears in the same graph

createSpectrogram('GroupA');
createSpectrogram('GroupB');

function createSpectrogram (groupname)

rootfolder = pwd;
groupfolder= rootfolder+"\"+groupname+"_extracted\";
cd (groupfolder);

if not(isfolder(groupname+"_spectrograms"))
mkdir(groupname+"_spectrograms")
end

for i=1:200
    if isfile("Pte_"+i+"​_extracted.csv")
        read_data= readtable("Pte_"+i+"​_extracted.csv");

        read_data.Var3 = string(read_data.Var3);
        read_data.Var1 = num2str(read_data.Var1);
        read_data_array = table2array(read_data);

        %We delete the rows containing information about the stored apples
        rowsEuler= ~contains(read_data_array(:, 2), "stored");
        %rowsApples= contains(read_data_array(:, 2), "stored");
        %patient_xyz contains the Euler angles
        patient_xyz= str2double(strrep(read_data_array(rowsEuler,:),',','.')); 
        %patient_storedApples= read_data_array(rowsApples);
        %samples_storedApples= str2double(patient_storedApples(:,1));

        fs= 50; %sampling rate of Unity's fixedUpdate()
        window_length = 256;
        overlap = window_length/2;
        nfft=256;
      
        %Calculation of the spectrogram for each time series
        %We substract the neutral positions (first row angles)
        figure;
        subplot(3,1,1)
        spectrogram(patient_xyz(:,3)-patient_xyz(1,3),window_length,overlap,nfft,fs);
        %waterplot(s_x,f_x,t_x);

        subplot(3,1,2);
        spectrogram(patient_xyz(:,4)-patient_xyz(1,4),window_length,overlap,nfft,fs);
        %waterplot(s_y,f_y,t_y);

        subplot(3,1,3);
        spectrogram(patient_xyz(:,5)-patient_xyz(1,5),window_length,overlap,nfft,fs);
        %waterplot(s_z,f_z,t_z);

        cd (groupfolder+"\"+groupname+"_spectrograms\");
        saveas(gcf,"Spectrogram_Patient"+i+".png");
        close(gcf);
        cd (groupfolder);
    end 
end
cd (rootfolder)

end 
%{
groupBfolder= rootfolder+"\GroupB_extracted\";
cd (groupBfolder);


for j = 1:200
    if isfile("Pte_"+j+"​_extracted.csv")
        read_data= readtable("Pte_"+j+"​_extracted.csv");
        read_data_array = table2array(read_data);
        %patient_xyz contains the Euler angles
        patient_xyz= str2double(strrep(read_data_array,',','.')); 

        fs= 50; %sampling rate of Unity's fixedUpdate()
        window_length = 256;
        overlap = window_length/2;
        nfft = 512;
      
        %Calculation of the spectrogram for each time series
        figure;
        subplot(3,1,1);
        spectrogram(patient_xyz(:,1),window_length,overlap,nfft,fs);
        %waterplot(s_x,f_x,t_x);

        subplot(3,1,2);
        spectrogram(patient_xyz(:,2),window_length,overlap,nfft,fs);        
        %waterplot(s_y,f_y,t_y);
        
        subplot(3,1,3);
        spectrogram(patient_xyz(:,3),window_length,overlap,nfft,fs);
        %waterplot(s_z,f_z,t_z);

        cd (groupBfolder+"\GroupB_spectrograms\");
        saveas(gcf,"Spectrogram_Patient"+j+".png");
        close(gcf);
        cd (groupBfolder);
    end 
end

%{
function waterplot(s,f,t)
% Waterfall plot of spectrogram from MatLab libreries
    waterfall(f,t,abs(s)'.^2);
    %Another option for the amplitude: 10 * log10(abs(s)')
    set(gca,XDir="reverse",View=[30 50])
    xlabel("Frequency (Hz)")
    ylabel("Time (s)")
end
%}
%}