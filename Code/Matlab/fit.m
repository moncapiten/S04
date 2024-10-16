dataPosition = '../../Data/';
filename = 'data001';

mediaposition = '../Media/';
medianame = strcat('plot', filename);

flagSave = true;
flagFit = true;
% data import and creation of variance array
rawData = readmatrix(strcat(dataPosition, filename, '.txt'));

tt = rawData(:, 1);
vi = rawData(:, 2);
s_i = repelem(2.1e-3, length(tt));
vo = rawData(:, 3);
s_o = repelem(1.5e-2, length(tt));

% preparation of fitting function and p0 parameters
function y = funcSine(params, t)
    w = 2 * pi * params(2);
    y = params(1) * sin( w*t + params(3)) + params(4);

end

R1 = 997.1;
R2 = 100200;
G = 1+R2/R1;

Ra = 3282.2;
Rb = 1490.3;
A = Rb/(Ra+Rb)

f0 = 1e3;
ai = A*0.1;
ao = G * ai;
ph0 = 0;
oi = 0;
oo = G * oi;


p0i = [ ai, f0, ph0, oi];
p0o = [ ao, f0, ph0, oo];


% fit and k^2 calculation
[betai, Ri, ~, covbetai] = nlinfit(tt, vi, @funcSine, p0i);
[betao, Ro, ~, covbetao] = nlinfit(tt, vo, @funcSine, p0o);


ki = 0;
for i = 1:length(Ri)
    ki = ki + Ri(i)^2/s_i(i)^2;
end
ki = ki/(length(tt)-4);

ko = 0;
for i = 1:length(Ro)
    ko = ko + Ro(i)^2/s_o(i)^2;
end
ko = ko/(length(tt)-4);


ki
ko

if flagFit
    % plot seffing and execution
    t = tiledlayout(2, 2);
    
    % plot of the data, prefit and fit
    ax1 = nexttile([1 2]);
    
    %errorbar(tt, vi, s_i, )
    %plot(tt, vi, 'o', Color="#0072BD");
    errorbar(tt, vi, s_i, 'o', Color= "#0027BD");
    hold on
    errorbar(tt, vo, s_o, 'o', Color= "Red");
    %plot(tt, vo, 'o', Color="Red");
    
    plot(tt, funcSine(p0i, tt), '--', Color = 'cyan');
    plot(tt, funcSine(p0o, tt), '--', Color = '#FFa500');
    
    plot(tt, funcSine(betai, tt), '-', Color = '#0047AB');
    plot(tt, funcSine(betao, tt), '-', Color = 'Magenta');
    
    hold off
    grid on
    grid minor
    
    
    % residual plots for both fits
    ax2 = nexttile([1 1]);
    plot(tt, repelem(0, length(tt)), '--', Color= 'black');
    hold on
    %errorbar(Ri, s_i, 'o', Color= '#0027BD');
    %plot(tt, Ri, 'o', Color= '#0072BD');
    errorbar(tt, Ri, s_i, Color= '#0072BD');
    %set(gca, 'XScale','log', 'YScale','lin')
    hold off
    grid on
    grid minor
    
    
    
    ax3 = nexttile([1 1]);
    plot(tt, repelem(0, length(tt)), '--', Color= 'black');
    hold on
    %errorbar(Ri, s_i, 'o', Color= '#0027BD');
    %plot(tt, Ri, 'o', Color= '#0072BD');
    errorbar(tt, Ro, s_o, Color= 'Red');
    %set(gca, 'XScale','log', 'YScale','lin')
    hold off
    grid on
    grid minor
    
    
    
    % plot seffings
    title(t, strcat('Fit and residuals of Amplitude Fit - ', filename));
    t.TileSpacing = "tight";
    linkaxes([ax2, ax3], 'y');
    
    
    %xlabel(ax1, 'frequency [Hz]')
    ylabel(ax1, 'Amplitude [V]')
    legend(ax1, 'data - in', 'data - out', 'modell in - p0', 'model out - p0', 'model in - fitted', 'model out - fitted', Location= 'ne')
    dimi = [.15 .61 .3 .3];
    dimo = [.28 .61 .3 .3];
    stri = ['$ k^2 \,\,\,in$ = ' sprintf('%.2f', ki) ];
    stro = ['$ k^2 \,\,\,out$ = ' sprintf('%.2f', ko) ];
    annotation('textbox', dimi, 'interpreter','latex','String',stri,'FitBoxToText','on');
    annotation('textbox', dimo, 'interpreter','latex','String',stro,'FitBoxToText','on');
    
    
    xlabel(ax1, 'time [s]');
    ylabel(ax2, 'Amplitude - Residuals [V]');
else
    errorbar(tt, vi, s_i, 'o', Color= "#0027BD");
    hold on
    errorbar(tt, vo, s_o, 'o', Color= "Red");
    grid on
    grid minor
    

    title(strcat('Data plot - ', filename))
    xlabel('time [s]');
    ylabel('Amplitude [V]')
    legend('data - in', 'data - out');
    hold off



end

% image saving
if flagSave
    fig = gcf;
    orient(fig, 'landscape')
    print(fig, strcat(mediaposition, medianame, '.pdf'), '-dpdf')
end


betai
betao





%sqrt(covbetao(1))/sqrt(covbetai(1))

