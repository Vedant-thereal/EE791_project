function [node_locations,node_loc_pp, num_nodes] = generate_HCPP(lambda, area_side, r_min)

    % Step 1: Generate a homogeneous Poisson Point Process (PPP)
    total_area = area_side^2;
    num_points = poissrnd(lambda * total_area); % Number of points to generate
    x_coords = area_side * rand(num_points, 1); % x-coordinates
    y_coords = area_side * rand(num_points, 1); % y-coordinates
    node_locations = [x_coords, y_coords];
    node_loc_pp = node_locations;
    % Step 2: Assign a random mark to each point
    marks = rand(num_points, 1); % Marks uniformly distributed in [0, 1]

    % Step 3: Apply Matérn Type II thinning
    is_retained = true(num_points, 1); % Initialize all points as retained
    for i = 1:num_points
        if ~is_retained(i)
            continue; % Skip if the point is already marked for removal
        end
        
        % Find neighbors within the hard core radius r_min
        distances = sqrt((x_coords - x_coords(i)).^2 + (y_coords - y_coords(i)).^2);
        neighbors = find(distances < r_min & (1:num_points)' ~= i);

        % Remove neighbors with higher marks
        for j = neighbors'
            if marks(j) > marks(i)
                is_retained(j) = false;
            end
        end
    end

    % Step 4: Filter out the points that are not retained
    node_locations = node_locations(is_retained, :);
    num_nodes = size(node_locations, 1);

end
