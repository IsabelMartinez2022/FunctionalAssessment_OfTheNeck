%Task 2
%Calculation of the spectrogram of each patient and saved as a png image
%The position of the stored appears in the same graph



createSpectrogram('GroupA');
createSpectrogram('GroupB');

function createSpectrogram (groupname)

rootfolder = pwd;
addpath(rootfolder);
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
        %Array containing all interesting data
        read_data_array = table2array(read_data);

        %Rows not containing information about the stored apples
        %rowsEuler= ~contains(read_data_array(:, 3), "stored");
        rowsEuler= ~contains(read_data_array(:, 3), "stored");
        %Rows containing information about the stored apples
        rowsApples= contains(read_data_array(:, 3), "stored");
        %patient_xyz contains the Euler angles
        patient_xyz= str2double(strrep(read_data_array(rowsEuler,:),',','.')); 
        %samples_storedApples contains the samples when an apple was stored
        samples_storedApples= str2double(strrep(read_data_array(rowsApples,1:2),',','.'));

        fs= 50; %sampling rate of Unity's fixedUpdate()
        window_length =256;
        overlap = 32;
        f=[1, 3, 7, 9, 11, 13, 15, 17, 19, 21, 23];
        
        
        %Calculation of the spectrogram for each time series
      
        figure;
        sub1=subplot(2,2,1);
        %We substract the neutral positions (first row angles)
        patient_x=patient_xyz(:,4)-patient_xyz(1,4);
        [s,f,t] =spectrogram(patient_x,window_length,overlap,f,  fs, 'yaxis');
        myPlotSpectrogram (s,f,t);
   
        % We also add a vertical line for each time sample 
        time_storedApples = samples_storedApples(:, 2)/1000; %conversion to seconds
        %time_storedApples= samples_storedApples(:,1)* ((window_length -overlap) / fs); %THIS GIVES ERROR
        %How the time axis is calculated using STFT:
        %for n= 1:length(patient_x)
        %t_spectrogram = 2.5600+(n-1) * (window_length - overlap) / fs;
        %end
        y_lim= get(gca, 'YLim');
        z_lim= max(max(20*log10(abs(s)))); %maximum value of intensity
        
        sub1.Tag='1';
        ax1 = findobj(gcf,'Tag','1'); 
        hold(ax1,'on');
        for index = 1:length(time_storedApples)
        line([time_storedApples(index),time_storedApples(index)], y_lim, [z_lim z_lim],'Color', 'w', 'LineWidth', 1);
        end

        sub2= subplot(2,2,2);
        patient_y=patient_xyz(:,5)-patient_xyz(1,5);
        [s,f,t] = spectrogram(patient_y,window_length,overlap, f, fs,'yaxis');
        myPlotSpectrogram (s,f,t);      
        sub2.Tag='1';
        ax2 = findobj(gcf,'Tag','1'); 
        hold(ax2,'on');
        for index = 1:length(time_storedApples)
        line([time_storedApples(index),time_storedApples(index)], y_lim, [z_lim z_lim],'Color', 'w', 'LineWidth', 1);
        end
        
        sub3= subplot(2,2,3);
        patient_z=patient_xyz(:,6)-patient_xyz(1,6);
        [s,f,t] = spectrogram(patient_z,window_length,overlap, f, fs,'yaxis');
        myPlotSpectrogram (s,f,t);
        sub3.Tag='1';
        ax3 = findobj(gcf,'Tag','1'); 
        hold(ax3,'on');
        for index = 1:length(time_storedApples)
        line([time_storedApples(index),time_storedApples(index)], y_lim, [z_lim z_lim],'Color', 'w', 'LineWidth', 1);
        end

        sub4= subplot(2,2,4);
        [s,f,t] = spectrogram((abs(patient_x)+abs(patient_y)+abs(patient_z)),window_length,overlap, f, fs,'yaxis');
        myPlotSpectrogram (s,f,t);
        sub4.Tag='1';
        ax4 = findobj(gcf,'Tag','1'); 
        hold(ax4,'on');
        for index = 1:length(time_storedApples)
        line([time_storedApples(index),time_storedApples(index)], y_lim, [z_lim z_lim],'Color', 'w', 'LineWidth', 1);
        end

        cd (groupfolder+"\"+groupname+"_spectrograms\");
        saveas(gcf,"Spectrogram_Patient"+i+".png");
        close(gcf);
        cd (groupfolder);
    end 
end
cd (rootfolder)

end 
