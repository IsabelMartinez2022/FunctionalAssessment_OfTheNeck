
function myPlotSpectrogram (s,f,t)
    surf(t, f, 20*log10(abs(s)), 'EdgeColor', 'none');
    axis xy; 
    axis tight; 
    colormap(jet); view(0,90);
    xlabel('Time (secs)');
    colorbar;
    ylabel('Frequency(HZ)');
    clim([-10, 90])

end