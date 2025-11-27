%% ============================
%  1. Define Scenario Time Window
% =============================

% Create a datetime object marking the start time of our simulation.
% Format: datetime(year, month, day, hour, minute, second)
startTime = datetime(2022,6,02,8,23,0);

% Define the end time of the scenario by adding 24 hours.
stopTime = startTime + hours(24);

% Set the simulation time step (seconds per sample).
% Here we sample satellite positions every 60 seconds.
sampleTime = 60;

% Create a satelliteScenario object. This is the container/environment
% that holds satellites, ground stations, access calculations, etc.
sc = satelliteScenario(startTime,stopTime,sampleTime);


%% ============================
%  2. Add Walker Constellation Satellites
% =============================

% Create a Walker Delta constellation using MATLAB's built-in function.
% Parameters:
% sc                 - scenario object
% 570e3+6378.14e3    - orbital radius = Earth radius + altitude (meters)
% 70                 - inclination (degrees)
% 720                - total satellites
% 36                 - number of planes
% 1                  - phasing factor (relative spacing)
% ArgumentOfLatitude - position offset in orbital plane
% Name               - constellation name
sat = walkerDelta(sc, ...
    570e3+6378.14e3, 70, 720, 36, 1, ...
    ArgumentOfLatitude=15, Name="Starlink");


%% ============================
%  3. Add a Ground Station
% =============================

% Define the ground station's name, latitude, and longitude.
name = ["Canberra Deep Space Communications Complex"];
lat = [-35.40139];          % Degrees
lon = [148.98167];          % Degrees

% Create the ground station in the scenario.
gs = groundStation(sc, "Name", name, ...
    "Latitude", lat, "Longitude", lon);


%% ============================
%  4. Visualize the Scenario
% =============================

% Open the interactive 3D viewer to visualize satellites and Earth.
satelliteScenarioViewer(sc);


%% ============================
%  5. Add Gimbals, Receiver, Transmitter, Antennas
% =============================

% Gimbals are steerable mounts that allow pointing of antennas/payloads.
% Here we attach two gimbals to satellite number 518:
% one for receiver, one for transmitter.
gimbalrxSat = gimbal(sat(518));
gimbaltxSat = gimbal(sat(518));

% ------------------------------
% Add Receiver on the first gimbal
% ------------------------------
gainToNoiseTemperatureRatio = 5;  % Receiver performance measure (dB/K)
systemLoss = 3;                    % Loss inside receiver hardware (dB)

% Attach receiver to gimbalrxSat
rxSat = receiver(gimbalrxSat, ...
    Name="Satellite Receiver", ...
    GainToNoiseTemperatureRatio=gainToNoiseTemperatureRatio, ...
    SystemLoss=systemLoss);

% ------------------------------
% Add Transmitter on the second gimbal
% ------------------------------
frequency = 27e9;   % Carrier frequency (Hz)
power = 20;         % Transmit power (dBW)
bitRate = 20;       % Desired data rate (Mbps)
systemLoss = 3;     % Hardware/system loss (dB)

% Attach transmitter to gimbaltxSat
txSat = transmitter(gimbaltxSat, ...
    Name="Satellite Transmitter", ...
    Frequency=frequency, ...
    power=power, ...
    BitRate=bitRate, ...
    SystemLoss=systemLoss);

% ------------------------------
% Add antennas to both Tx and Rx
% ------------------------------
dishDiameter = 0.5;           % Antenna diameter in meters
apertureEfficiency = 0.5;     % Realistic efficiency (~50%)

% Apply Gaussian dish antennas for realistic link budget modeling.
gaussianAntenna(txSat, ...
    DishDiameter=dishDiameter, ApertureEfficiency=apertureEfficiency);

gaussianAntenna(rxSat, ...
    DishDiameter=dishDiameter, ApertureEfficiency=apertureEfficiency);


%% ============================
%  6. Compute Access Between ALL Satellites and Ground Station
% =============================

% Compute line-of-sight access between every Starlink satellite and gs.
% ac is an ARRAY of access objects, NOT a table.
ac = access(sat, gs);

% Inspect the first few access objects
ac(1:5)       % Basic info for the first 5 satellites
size(ac)      % Check how many access objects exist
class(ac)     % Confirm object type


%% ============================
%  7. Convert Access Objects into Interval Tables
% =============================

% ------------------------------
% (A) Access intervals for ONE satellite (satellite 1)
% ------------------------------
TestOne = accessIntervals(ac(1));    % Convert to table of intervals

% Show first 5 rows of full interval table
TestOne(1:5,:)

% Show only StartTime and EndTime for first 5 intervals
TestOne(1:5, {'StartTime','EndTime'})

% ------------------------------
% (B) Access intervals for ALL satellites
% ------------------------------
TestAll = accessIntervals(ac);  % Convert ALL access objects to ONE big table

% Build a cleaner table used for further time filtering
VisitTime = TestAll(:, {'Source','StartTime','EndTime'});


%% ============================
%  8. Datetime Handling — Teaching Moment
% =============================

% DO NOT USE strfind — StartTime is datetime, not a string.
% This would fail:
% r = strfind(VisitTime.StartTime,'08:49:00');

% Check data types
class(VisitTime.StartTime)   % Should be datetime
class(VisitTime.Source)      % Usually string/categorical

% Build a logical mask to identify intervals starting exactly at hh:00:00
idx_test = (VisitTime.StartTime.Minute == 0) & ...
           (VisitTime.StartTime.Second == 0);

% Display TRUE/FALSE mask
idx_test


%% ============================
%  9. Sort Intervals and Filter by Time
% =============================

% Sort all intervals by their StartTime (earliest → latest)
SortedVisitTim = sortrows(VisitTime, 'StartTime');

% Create a logical mask selecting:
% Minute between 25–30
% AND hour equals 0 (midnight to 1 AM)
SortedVisitMask = (SortedVisitTim.StartTime.Minute >= 25 & ...
                   SortedVisitTim.StartTime.Minute <= 30 & ...
                   SortedVisitTim.StartTime.Hour == 0);

% Apply mask to extract selected intervals
MnistVisit = SortedVisitTim(SortedVisitMask, :);

% Show the final filtered table of desired access windows
MnistVisit