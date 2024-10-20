%clear all;

dataPosition = '../../Data/';
filename = 'dataMultivib001';

mediaposition = '../../Media/';
medianame = strcat('plot', filename);

flagSave = false;
flagFit = true;
flagResiduals = true;


% data import and creation of variance array
rawData = readmatrix(strcat(dataPosition, filename, '.txt'));

tt = rawData(:, 1);
vi = rawData(:, 3);
s_i =  repelem(0.1, length(tt));
%s_i = repelem(2.2e-2, length(tt));
vo = rawData(:, 2);
s_o = repelem(5.3e-2, length(tt));



% preparation of fitting function and p0 parameters
function y = funcSine(params, t)
    w = 2 * pi * params(2);
    y = params(1) .* sin( w*t + params(3) );
end

function y = funcSquare(params, t)
    w = 2 * pi .* params(2);
    y = params(1) .* sign( sin( w*t + params(3) ) ) + params(4);
end



f0 = 435;
ai = ( max(vi) - min(vi) )/2;
ao = ( max(vo) - min(vo) )/2;
ph0i = pi*10/16;
ph0o = -pi/4;
oi = mean(vi);
oo = mean(vo);


p0i = [ ai, f0, ph0i, oi];
p0o = [ ao, f0, ph0o];


% fit and k^2 calculation

%sqwave in, sharkfin out
%[betai, Ri, ~, covbetai] = nlinfit(tt, vi, @funcSquare, p0i);
%[betao, Ro, ~, covbetao] = nlinfit(tt, vo, @funcSine, p0o);

%betao = p0o;
%Ro = repelem(0, length(tt));




%Second data fit, done in order to remove outliers
vi1 = [];
tt1 = [];
s_i1 = [];
for i = 1:length(vi)
    if abs(vi(i)) > 4.6
        vi1 = [vi1, vi(i)];
        tt1 = [tt1, tt(i)];
        s_i1 = [s_i1, s_i(1)];
    end
end

length(s_i1)

vi = vi1;
tt = tt1;
s_i = s_i1;


length(s_i)
length(vi)
length(tt)
[betai, Ri, ~, covbetai] = nlinfit(tt, vi, @funcSquare, p0i );
%[betai, Ri, ~, covbetai] = nlinfit(tt, vi, @funcSquare, p0i, Weights= s_i );
%[betai, Ri] = lsqcurvefit(@funcSquare, p0i, tt1, vi1);
Ri;
betai


ki = 0;
for i = 1:length(Ri)
    ki = ki + Ri(i)^2/s_i1(i)^2;
end
ki = ki/(length(tt)-4);

ko = 0;
for i = 1:length(Ro)
    ko = ko + Ro(i)^2/s_o(i)^2;
end
ko = ko/(length(tt)-4);


ki;
ko;

if flagFit
    % plot seffing and execution
    if(flagResiduals)
        t = tiledlayout(2, 2, "TileSpacing","tight", "Padding","tight");
    end
    
    % plot of the data, prefit and fit
    ax1 = nexttile([1 2]);
    
    errorbar(tt, vi, s_i, 'o', Color= "#0027BD");
    hold on
    %errorbar(tt, vo, s_o, 'v', Color= "Red");
%    errorbar(tt1, vo1, s_o(1:length(vo1)), 'v', Color= 'Green');
    
    plot(tt, funcSquare(p0i, tt), '--', Color = 'cyan');
    %plot(tt, funcSine(p0o, tt), '--', Color = '#FFa500');
    
    plot(tt, funcSquare(betai, tt), '-', Color = '#0047AB');
    %plot(tt, funcSine(betao, tt), '-', Color = 'Magenta');

    hold off
    grid on
    grid minor
    
    if flagResiduals
        % residual plots for both fits
        ax2 = nexttile([1 1]);
        plot(tt, repelem(0, length(tt)), '--', Color= 'black');
        hold on
        errorbar(tt, Ri, s_i, 'o', Color= '#0072BD');
        hold off
        grid on
        grid minor
        
        
        
        ax3 = nexttile([1 1]);
        %plot(tt, repelem(0, length(tt)), '--', Color= 'black');
        hold on
        %errorbar(tt, Ro, s_o, 'v', Color= 'Red');
%        errorbar(tt1, Ro1, s_o(1:length(Ro1)), 'v', Color= 'green');
        hold off
        grid on
        grid minor
        
        
        
        % plot seffings
        title(t, strcat('Fit and residuals of Amplitude Fit - ', filename));
        t.TileSpacing = "tight";
        %linkaxes([ax1, ax2, ax3], 'x');
        linkaxes([ax2, ax3], 'y');
    
        
        
        %xlabel(ax1, 'frequency [Hz]')
        ylabel(ax1, 'Amplitude [V]')
        legend(ax1, 'data - in', 'data - out', 'data - out (to fit)', 'modell in - p0', 'model out - p0', 'model in - fitted', 'model out - fitted', Location= 'ne')
        dimi = [.06 .65 .3 .3];
        dimo = [.06 .60 .3 .3];
        stri = ['$ k^2 \,\,\,in$ = ' sprintf('%.2f', ki) ];
        stro = ['$ k^2 \,\,\,out$ = ' sprintf('%.2f', ko) ];
        annotation('textbox', dimi, 'interpreter','latex','String',stri,'FitBoxToText','on', 'BackgroundColor', 'white');
        annotation('textbox', dimo, 'interpreter','latex','String',stro,'FitBoxToText','on', 'BackgroundColor', 'white');
        
        
        xlabel(ax1, 'time [s]');
        xlabel(ax2, 'time [s]');
        xlabel(ax3, 'time [s]');
        ylabel(ax2, 'Amplitude - Residuals [V]');
    end
else
    errorbar(tt, vi, s_i, 'o', Color= "#0027BD");
    hold on
    errorbar(tt, vo, s_o, 'o', Color= "Red");
    grid on
    grid minor
end

if ~flagFit | ( flagFit & ~flagResiduals )
    title(strcat('Data plot - ', filename))
    xlabel('time [s]');
    ylabel('Amplitude [V]')
    if flagFit
        legend(ax1, 'data - in', 'data - out', 'modell in - p0', 'model out - p0', 'model in - fitted', 'model out - fitted', Location= 'ne')
    else
        legend('data - in', 'data - out');
    end
    hold off


end

% image saving
if flagSave
    fig = gcf;
    orient(fig, 'landscape')
    print(fig, strcat(mediaposition, medianame, '.pdf'), '-dpdf')
end


betai
covbetai
%betao





%sqrt(covbetao(1))/sqrt(covbetai(1))

