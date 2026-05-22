%% Radar Design Parameter choices

clear;
clc

% INPUTS
freq = 1.5*10^11; %Hertz
Alt_max = 2.5*10^3; %Meters
boresight = 5.4; % in degrees
D_el = .85; %meters
D_az = .85; %meters
Spin_rate = 60; % RPM
azimuth_limit = 75; % in degrees
Transmitter_power = 110;
Xmt_pulse_width = .6*10^-6;
PRF = 160000;
N = 10;
Tfa = 15;
PCR= 1;

Bandwidth = 1./Xmt_pulse_width;
K = 1.38*10^(-23);
Atmospheric_loss_db = -0.40;
Tsys = 700;

% Calculating Wavelength
c = 3*10^8; %Speed of Light
wavelength = c/freq;

% Calculating Beamwidths
B_el_rad = 1.2.*wavelength./D_el;
B_el_deg = B_el_rad.*180./pi;
B_az_rad = 1.2.*wavelength./D_az;
B_az_deg = B_az_rad.*180./pi;

% Calculating Antenna Gain
Antenna_gain = (0.6.*4.*pi)./(B_el_rad.*B_az_rad);

disp("-----DIAGNOSTICS-----");
disp(" ");

% Grazing near,bore, and far
cone_angle  =  90 -boresight;
grazing_near = 90 - (cone_angle - B_el_deg./2);
grazing_bore = boresight;
grazing_far = 90 - (cone_angle + B_el_deg./2);

disp("---Grazing Angles---");
disp("Grazing near is : " +grazing_near +" degrees");
disp("Grazing boresight is : " +grazing_bore +" degrees")
disp("Grazing far is : " +grazing_far +" degrees")
disp(" ");

% Calculating Range
R_near = Alt_max./sind(grazing_near);
R_bore = Alt_max./sind(grazing_bore);
R_far = Alt_max./sind(grazing_far);

disp("---Ranges---");
disp("The near range is: " +R_near +" meters");
disp("The bore range is: " +R_bore +" meters");
disp("The far  range is: " +R_far +" meters");
disp(" ");

% Pulse Range Resolution (ASK Dr.Jones to verify equation)
Resolution_near = c*Xmt_pulse_width./(2.*cosd(grazing_near));
Resolution_bore = c*Xmt_pulse_width./(2.*cosd(grazing_bore));
Resolution_far = c*Xmt_pulse_width./(2.*cosd(grazing_far));

disp("---Range Resolution---")
disp("The Range Resolution at near is: " +Resolution_near +" meters");
disp("The Range Resolution at bore is: " +Resolution_bore +" meters");
disp("The Range Resolution at far is: " +Resolution_far +" meters");
disp(" ");

% Pulse Azimuth resolution
Azimuth_near = R_near.*B_az_rad;
Azimuth_bore = R_bore.*B_az_rad;
Azimuth_far = R_far.*B_az_rad;

disp("---Azimuth Resolution---");
disp("The Azimuth Resolution near is: " +Azimuth_near +" meters");
disp("The Azimuth Resolution bore is: " +Azimuth_bore +" meters");
disp("The Azimuth Resolution far is: " +Azimuth_far +" meters");
disp(" ");

% Pulse IFOV
IFOV_near = Azimuth_near.*Resolution_near;
IFOV_bore = Azimuth_bore.*Resolution_bore;
IFOV_far = Azimuth_far.*Resolution_far;

disp("---Pulse IFOV---");
disp("The Pulse IFOV near: " +IFOV_near +" meters squared");
disp("The Pulse IFOV bore: " +IFOV_bore +" meters squared");
disp("The Pulse IFOV far: " +IFOV_far +" meters squared");
disp(" ");
% Calculating Target Cross
p1 = -4.41228*10^(-9);
p2 = 1.24415*10^(-6);
p3 = -1.2775*10^(-4);
p4 =  5.7724*10^(-3);
p5 = -0.1075;
p6 = 0.5756;
p7 = 5.90;

x = grazing_near;
target_cross_near = p1*x.^6 +p2*x.^5 + p3*x.^4 +p4*x.^3 + p5*x.^2 + p6*x + p7;

x = grazing_bore;
target_cross_bore = p1*x.^6 +p2*x.^5 + p3*x.^4 +p4*x.^3 + p5*x.^2 + p6*x + p7;

x = grazing_far;
target_cross_far = p1*x.^6 +p2*x.^5 + p3*x.^4 +p4*x.^3 + p5*x.^2 + p6*x + p7;
disp("---Target Cross Section---");
disp("Target Cross section near is: " +target_cross_near +" meters squared")
disp("Target Cross section bore is: " +target_cross_bore +" meters squared")
disp("Target Cross section far is: " +target_cross_far +" meters squared")
disp(" ");


% Clutter cross section

p1 = -4.3868*10^(-6);
p2 = 0.00098614;
p3 = -0.071347;
p4 = 2.2443;
p5 = -44.959;

x = grazing_near;
sigma_near_db = p1*x.^(4) + p2*x.^(3) + p3.*x.^(2) +p4.*x + p5;

x = grazing_bore;
sigma_bore_db = p1*x.^(4) + p2*x.^(3) + p3*x.^(2) +p4*x + p5;

x = grazing_far;
sigma_far_db = p1*x.^(4) + p2*x.^(3) + p3*x.^(2) +p4*x + p5;

sigma_near_lin = 10.^(sigma_near_db/10);
sigma_bore_lin = 10.^(sigma_bore_db/10);
sigma_far_lin = 10.^(sigma_far_db/10);

clutter_near = IFOV_near.*sigma_near_lin;
clutter_bore = IFOV_bore.*sigma_bore_lin;
clutter_far = IFOV_far.*sigma_far_lin;

disp("---Clutter Cross Section---");
disp("Clutter Cross section near is: " +clutter_near +" meters squared");
disp("Clutter Cross section bore is: " +clutter_bore +" meters squared");
disp("Clutter Cross section far is: " +clutter_far +" meters squared");
disp(" ");

% Time on Target (TOT)
Rotation_rate = Spin_rate.*(360/60);
ToT = B_az_deg./Rotation_rate;

disp("Time on target is : " +ToT);
disp(" ");

% Pulses on target
POT = floor(ToT.*PRF);

disp("Numbers of Pulses is: " +POT );
disp(" ");


% Atmospheric Propagation
one_way_loss_db_near = ((Alt_max./1000)./sind(grazing_near)).*Atmospheric_loss_db;
two_way_loss_db_near = 2.*one_way_loss_db_near;
loss_near = 10.^(two_way_loss_db_near./10);

one_way_loss_db_bore = ((Alt_max./1000)./sind(grazing_bore)).*Atmospheric_loss_db;
two_way_loss_db_bore = 2.*one_way_loss_db_bore;
loss_bore = 10.^(two_way_loss_db_bore./10);

one_way_loss_db_far = ((Alt_max./1000)./sind(grazing_far)).*Atmospheric_loss_db;
two_way_loss_db_far = 2.*one_way_loss_db_far;
loss_far = 10.^(two_way_loss_db_far./10);

% Noise Calculation
Noise = Tsys.*Bandwidth.*K;


% Calculating Radar 'X' factor
X_near = (Transmitter_power.*((Antenna_gain).^2).*((wavelength).^2).*loss_near)./((4.*pi).^3);
X_bore = (Transmitter_power.*((Antenna_gain).^2).*((wavelength).^2).*loss_bore)./((4.*pi).^3);
X_far = (Transmitter_power.*((Antenna_gain).^2).*((wavelength).^2).*loss_far)./((4.*pi).^3);

X_near_db = 10.*log10(X_near);
X_bore_db = 10.*log10(X_bore);
X_far_db = 10.*log10(X_far);
disp("Radar 'X' factor near is: " +X_near_db);
disp("Radar 'X' factor bore is: " +X_bore_db);
disp("Radar 'X' factor far is: " +X_far_db);
disp("  ");

%Calculating Swath measurement
Swath_width = 2.*R_near.*cosd(grazing_near).*sind(azimuth_limit);

disp("The Swath Width is: " +Swath_width +" m");
disp("  ");

% Max allowable PRF
PRFmax = c./(2.*(R_far-R_near));
disp("The Max PRF is: " +PRFmax +" Hertz");
disp("  ");

% Antenna footprint
footprint = R_far.*cosd(grazing_far) -R_near.*cosd(grazing_near);

disp("Antenna footprint is: " +footprint);
disp("  ");

% Minimum spin rate
ground_speed = (5/18).*115;
target_speed_max = (5/18).*170;
Period = (footprint./N)/((ground_speed - target_speed_max*cosd(180)));
Spinrate = 60./Period;

disp("The minimum spin rate is : " +Spinrate)
disp("  ");

% Min warning time @ worst case
cone_angle_1 = 90 - grazing_bore;
d_min = Alt_max.*tand(cone_angle_1 - (B_el_deg./2));
T_war = d_min./(ground_speed+target_speed_max);
T_war_min = T_war.*cosd(azimuth_limit);
disp("The Minimum Warning time is: " +T_war_min);
disp("  ");

% Calculating Target/Clutter
T_C_near = target_cross_near./clutter_near;
T_C_bore = target_cross_bore./clutter_bore;
T_C_far = target_cross_far./clutter_far;

disp("The T/C near is: " +T_C_near);
disp("The T/C bore is: " +T_C_bore);
disp("The T/C far is: " +T_C_far);
disp("  ");

% Calculating Target/Noise
Pr_near = X_near.*target_cross_near./(R_near).^4;
Pr_bore = X_bore.*target_cross_bore./(R_bore).^4;
Pr_far = X_far.*target_cross_far./(R_far).^4;

T_N_near = Pr_near./Noise;
T_N_bore = Pr_bore./Noise;
T_N_far = Pr_far./Noise;

T_N_neardb = 10.*log10(T_N_near);
T_N_boredb = 10.*log10(T_N_bore);
T_N_fardb = 10.*log10(T_N_far);

disp("The T/N near is : " +T_N_near);
disp("The T/N bore is : " +T_N_bore);
disp("The T/N far is : " +T_N_far);
disp("  ");

% Clutter/Noise
Clutter_power_near = X_near.*clutter_near./(R_near).^4;
Clutter_power_bore = X_bore.*clutter_bore./(R_bore).^4;
Clutter_power_far = X_far.*clutter_far./(R_far).^4;

C_N_near = Clutter_power_near./Noise;
C_N_bore = Clutter_power_bore./Noise;
C_N_far = Clutter_power_far./Noise;

C_N_near_db = 10.*log10(C_N_near);
C_N_bore_db = 10.*log10(C_N_bore);
C_N_far_db = 10.*log10(C_N_far);

disp("The C/N ratio near is : " +C_N_near);
disp("The C/N ratio bore is : " +C_N_bore);
disp("The C/N ratio far is : " +C_N_far);
disp("  ");

% T/(C+N)
T_C_N_near = Pr_near./(Clutter_power_near + Noise);
T_C_N_bore = Pr_bore./(Clutter_power_bore+Noise);
T_C_N_far = Pr_far./(Clutter_power_far+Noise);

T_C_N_near_db = 10.*log10(T_C_N_near);
T_C_N_bore_db = 10.*log10(T_C_N_bore);
T_C_N_far_db = 10.*log10(T_C_N_far);

disp("The T/(C+N) near is: " +T_C_N_near);
disp("The T/(C+N) bore is: " +T_C_N_bore);
disp("The T/(C+N) far is: " +T_C_N_far);
disp("  ");

% Calculating Probability of False alarm
Pfa = 1./(Tfa.*PRF);

% Calculating Probaility of Detection
E = (0.62 +0.454./(sqrt(POT+0.44))).^-1;
A = log(.62/Pfa);
C_factor_near = T_C_N_near.*sqrt(POT);
C_factor_bore = T_C_N_bore.*sqrt(POT);
C_factor_far = T_C_N_far.*sqrt(POT);

C_near = C_factor_near.^E;
C_bore = C_factor_bore.^E;
C_far = C_factor_far.^E;

B_near = (C_near-A)./(0.12.*A +1.7);
B_bore = (C_bore-A)./(0.12.*A +1.7);
B_far = (C_far-A)./(0.12.*A +1.7);

Pd_near = exp(B_near)./(1+exp(B_near));
Pd_bore = exp(B_bore)./(1+exp(B_bore));
Pd_far = exp(B_far)./(1+exp(B_far));


disp("The probability of detection at range near is:  " +Pd_near);
disp("The probability of detection at range bore is:  " +Pd_bore);
disp("The probability of detection at range far is:  " +Pd_far);
disp("  ");

% Pd for 2 of 'N'
Pd_max_near = Pd_bore.^2.*(4.*(1-Pd_bore)) + Pd_bore.^4;
Pd_max_bore = 1 - binocdf(1,10,Pd_bore);
Pd_max_far = 1 - binocdf(1,10,Pd_far);

disp("Probability of Detection of near for 2 out of " +N +" Scans is : " +Pd_max_near);
disp("Probability of Detection of bore for 2 out of " +N +" Scans is : " +Pd_max_bore);
disp("Probability of Detection of far for 2 out of " +N +" Scans is : " +Pd_max_far);
disp("  ");

% Doppler ToT
Doppler_ToT = N.*(POT)./PRF;

disp("The Doppler Time on Target is: " +Doppler_ToT);

% Doppler Precision
Echo_energy = Pr_far.*Xmt_pulse_width;

No = K.*Tsys;

Doppler_Measurement_Precision = 1./(Doppler_ToT.*sqrt(Echo_energy.*2./No));

disp("Dopplear Measurement Precision is: " +Doppler_Measurement_Precision);

% Nyquist PRF
V = (ground_speed+target_speed_max).*cosd(grazing_far);
Fd = 2.*V./wavelength;
Nyquist_PRF = 2.*Fd;

disp("The Max Doppler is : " +Fd);
disp("The Nyquist PRF is : " +Nyquist_PRF)

figure;
plot(N,Spinrate);
title("Number of Scans vs Minimum Spin rate");
xlabel("Number of Scans");
ylabel("Spin rate RPM");

cone_angle_ = 90 - grazing_bore;
d_min = Alt_max.*tand(cone_angle_1 - (B_el_deg./2));

T_war = d_min./(ground_speed- target_speed_max*cosd(180));
T_war_min = T_war.*cosd(0);
disp("The Minimum Warning time is: " +T_war_min);
disp("  ");
