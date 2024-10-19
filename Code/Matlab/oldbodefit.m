clear all;

dataPosition = '../../Data/';
filename = 'dataBode008';
%filename = 'OP77';

mediaposition = '../../Media/';
medianame = strcat('bodePlotAndFit-', filename);

flagSave = false;
flagdB = false;
flagDeg = galse;
flagLimited = false;
limit = 730;

% data import and creation of variance array
rawData = readmatrix(strcat(dataPosition, filename, '.txt'));

ff = rawData(:, 1);
A = rawData(:, 2);
ph = rawData(:, 3);


if flagdB
    A = 10.^(A/20);
end
if flagDeg
    ph = ph.*pi/180;
end
if flagLimited
    A2 = A(1 : limit);
    f2 = ff(1 : limit);
    p2 = ph(1 : limit);
end


R1 = 1000;
R2 = 1e5;
b0 = R2/(R1+R2);

fc0 = 1e4;
t0 = 1/(2*pi*fc0);
A0 = 100;

p0 = [A0, t0];


%{
function y = gain(params, f)

    w = 2 * pi .* f;

    A = params(1) ./ ( 1 + 1i * params(2) .* w);
    G =  A ./ ( 1 + 1/101 .* A);    
    y = abs(G);

end
%}

G0 = 100;
f0 = 1e4;
tau0 = 1/(2*pi*f0);
p0tf = [G0, tau0];

function y = tf(params, f)
    
    w = 2 * pi * f;
    G = params(1) ./ ( 1 +  w .* 1i * params(2) );
    y = abs(G);
end

function y = tp(params, f)
    
    w = 2 * pi * f;

    G = params(1) ./ ( 1 +  w .* 1i * params(2) );
    y = angle(G);
end


%[beta, R, ~, covbeta] = nlinfit(ff, A, @gain, p0);
%[beta2, R2, ~, covbeta2] = nlinfit(f2, A2, @gain, p0);
if flagLimited
    [beta3, R3, ~, covbeta3] = nlinfit(f2, A2, @tf, p0tf);
else
    [beta3, R3, ~, covbeta3] = nlinfit(ff, A, @tf, p0tf);
end







t = tiledlayout(2, 1, "TileSpacing", 'tight', 'Padding', 'compact');

ax1 = nexttile;
loglog(ff, A, 'o', Color = '#0027BD');
hold on
if flagLimited
    loglog(f2, A2, 'v', Color = 'green');
    loglog(f2, tf(p0tf, f2), '--', Color= 'magenta')
    loglog(f2, tf(beta3, f2), '-', Color= 'red');
else
    loglog(ff, tf(p0tf, ff), '-', Color= 'magenta');
    loglog(ff, tf(beta3, ff), '-', Color= 'red');
end
%loglog(ff, abs( gain(p0, ff) ), '--', Color = '#a020f0');
%loglog(ff, abs( gain(beta, ff) ), '-', Color = 'red');
%loglog(f2, abs( gain(beta2, f2) ), '-', Color = '#edb120');



grid on
grid minor

hold off


ax2 = nexttile;
semilogx(ff, ph, 'o', Color= '#0027bd');
hold on
if flagLimited
    semilogx(f2, p2, 'v', Color= 'green');
    semilogx(f2, tp(p0tf, f2), '--', Color= 'magenta')
    semilogx(f2, tp(beta3, f2), '-', Color= 'red');
else
    semilogx(ff, tp(p0tf, ff), '-', Color= 'magenta');
    semilogx(ff, tp(beta3, ff), '-', Color= 'red');
end

grid on
grid minor
hold off

title(t, strcat('Gain and Phase of Amplifier - Simulation  ', filename));

if flagLimited
    legend(ax1, 'Original Data', 'Fit Data', 'model - p0', 'model - fit', Location= 'ne');
else
    legend(ax1, 'Original Data', 'model - p0', 'model - fit', Location= 'ne');
end
linkaxes([ax1 ax2], 'x')
ylabel(ax1, 'Gain [pure]');
ylabel(ax2, 'Phase [radians]');
xlabel(ax2, 'Frequency [Hz]');


yticks(ax2, [-pi, -0.75*pi, -pi/2, -pi/4, 0, pi/4, pi/2, 0.75*pi, pi])
yticklabels(ax2, {'-pi', '-3/4\pi', '-\pi/2', '-\pi/4', '0', '\pi/4', '\pi/2', '3/4\pi', '\pi'})





if flagSave
    fig = gcf;
    orient(fig, 'landscape')
    print(fig, strcat(mediaposition, medianame, '.pdf'), '-dpdf')
end
