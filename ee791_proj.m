clc
clear all
% Parameters for the simulation
area_side = 500;         % Side length of the simulation area (square area)
lambda_vec = linspace(1e-3,5e-2,20);
carrier_sensing_threshold = -75; % Carrier-sensing threshold in dB
path_loss_exponent = 4;  % Path-loss exponent
required_SIR = 8;       % Required SIR for successful transmission (linear scale)
transmit_power = 10;      % Transmit power of each transmitter
fading_variance = 1;     % Variance of Rayleigh fading
cont_radius = 30;   % Contention radius (fixed for simplicity)
sims = 2000;
results = zeros(length(lambda_vec),4);
for q = 1:length(lambda_vec)
    lambda = lambda_vec(q);
    SIR_avg=0;
    outages = 0;
    for p = 1:sims
            [node_locations,node_locations_pp,num_nodes] = generate_HCPP(lambda,area_side,cont_radius);
            % Step 2: Calculate outage probability
            rx_loc = [area_side/2,area_side/2];
            dist = sqrt(sum((rx_loc-node_locations).^2,2));
            [min_dist,k] = min(dist);    
                % Compute interference from other active nodes
            interference = 0;
              for j = 1:size(node_locations,1)
                  if k ~= j
                      fading_gain = raylrnd(sqrt(fading_variance/2));
                      if(dist(j)<1)
                          interference = interference + transmit_power * fading_gain/(1);
                      else
                          interference = interference + transmit_power * fading_gain / (dist(j))^path_loss_exponent;
                      end
                   end
               end
                
                % Calculate received signal power and SIR
                signal_power = transmit_power * raylrnd(sqrt(fading_variance/2)) / ((min_dist)^path_loss_exponent);
                SIR = (signal_power / interference);
                SIR_avg = SIR_avg + SIR;
                % Check if SIR is below required threshold (outage condition)
                if(SIR<required_SIR)
                    outages = outages + 1;
                end    
    end
            % Calculate and display outage probability
            outage_probability = outages / sims;
            SIR_avg = SIR_avg/sims;
            disp(['Outage Probability: ', num2str(outage_probability)]);
            disp(['SIR: ', num2str(SIR)]);
            disp(['Active Nodes: ', num2str(size(node_locations,1))]);
            disp(['Total Nodes: ', num2str(size(node_locations_pp,1))]);
            results(q,1) = outage_probability;
            results(q,2) = SIR_avg;
            results(q,3) = size(node_locations,1);
            results(q,4) = size(node_locations_pp,1);
end
Plotting the network
figure;
plot(node_locations_pp(:,1), node_locations_pp(:,2), 'bo'); % All nodes
axis([0 area_side 0 area_side]);
figure;
plot(node_locations(:,1), node_locations(:,2), 'ro'); % Active nodes
axis([0 area_side 0 area_side]);
figure;
plot(lambda_vec,1-results(:,1));
xlabel('lambda');
ylabel('Coverage Probability');
ylim([0,1]);
figure;
plot(lambda_vec,10*log(results(:,2)));
xlabel('lambda');
ylabel('average SIR(dB)');
ylim([0,150]);
figure;
plot(lambda_vec,results(:,3));
xlabel('lambda');
ylabel('No of Active Nodes'); 