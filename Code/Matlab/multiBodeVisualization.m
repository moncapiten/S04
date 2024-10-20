clear all;

dataPosition = '../../Data/';
filename = 'dataBode006';
filename2 = 'dataBode007';
filename3 = 'dataBode008';

mediaposition = '../../Media/';
medianame = 'GBWP-OP77';

flagSave = true;


rawData = readmatrix(strcat(dataPosition, filename, '.txt'));
rawData2 = readmatrix(strcat(dataPosition, filename2, '.txt'));
rawData3 = readmatrix(strcat(dataPosition, filename3, '.txt'));

ff = rawData(:, 1);
AA = rawData(:, 2);
ph = rawData(:, 8);

ff2 = rawData2(:, 1);
AA2 = rawData2(:, 2);
ph2 = rawData2(:, 8);

ff3 = rawData3(:, 1);
AA3 = rawData3(:, 2);
ph3 = rawData3(:, 8);

Ra = 3.2822e3;
Ra2 = 14.990e3;
Ra3 = 221.00e3;
Rb = 1.4903e3;

b1 = Rb/(Rb + Ra);
b2 = Rb/(Rb + Ra2);
b3 = Rb/(Rb + Ra3);

AA = AA / b1;
AA2 = AA2 / b2;
AA3 = AA3 / b3;


loglog(ff, AA, 'o', Color = '#0027BD');
hold on
loglog(ff2, AA2, 'v', Color= 'red');
loglog(ff3, AA3, 'x', Color= 'green');
%semilogx(ff, oi, 'o', Color = 'blue');
%semilogx(ff, vi2, 'v', Color = 'magenta');
%semilogx(ff, oi2, 'v', Color = 'red');

grid on
grid minor
title(medianame);
%legend('AAmplitude in - 4.5k divider', 'Offset in - 4.5k divider', 'AAmplitude in - 45k divider', 'Offset in - 45k divider', Location= 'ne')
legend('G = 100', 'G = 330', 'G = 1000');
ylabel('Gain [pure]');
xlabel('frequency [Hz]');
ylim([1e1 1.1e3])

hold off



dim = [.14 .20 .3 .3];
str = sprintf('GBWP = %.2e', 4.40e5  ) ;
annotation('textbox',dim,'String',str,'FitBoxToText','on', 'Interpreter', 'tex', 'BackgroundColor', 'white');

dim = [.14 .40 .3 .3];
str = sprintf('GBWP = %.2e', 4.55e5  ) ;
annotation('textbox',dim,'String',str,'FitBoxToText','on', 'Interpreter', 'tex', 'BackgroundColor', 'white');

dim = [.14 .60 .3 .3];
str = sprintf('GBWP = %.2e', 4.54e5  ) ;
annotation('textbox',dim,'String',str,'FitBoxToText','on', 'Interpreter', 'tex', 'BackgroundColor', 'white');








if flagSave
    fig = gcf;
    orient(fig, 'landscape')
    print(fig, strcat(mediaposition, medianame, '.pdf'), '-dpdf')
end

