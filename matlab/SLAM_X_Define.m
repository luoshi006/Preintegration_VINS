function X_Def = InertialDelta_X_Define( nPts, nPoses, nIMUrate )

    global PreIntegration_options %global PreIntegration_options
    
    Angle_Def = struct( ...
        'val', zeros(3, 1), ...
        'col', [] ...
        );

    Trans_Def = struct( ...
        'xyz', zeros(3, 1), ...
        'col', [] ...
        );

    Pose_Def = struct( ...
        'ang',      Angle_Def, ...
        'trans',    Trans_Def ...
        );

    Feature_Def = struct( ...
        'xyz',      zeros(3, 1), ...
        'col',      [] ...
        );

    Velocity_Def = struct ( ...
        'xyz',      zeros(3, 1), ...
        'col',      [] ...
        );
    
    G_Def =  struct( ...
        'val', zeros(3, 1), ...
        'col', [] ...
        );

    if PreIntegration_options.bVarBias == 0
        Bf_Def = struct( ...
            'val', zeros(3, 1), ...
            'col', [] ...
            );

        Bw_Def = struct( ...
            'val', zeros(3, 1), ...
            'col', [] ...
            );
    else
        Bf1_Def = struct( ...
            'val', zeros(3, 1), ...
            'col', [] ...
            );

        Bw1_Def = struct( ...
            'val', zeros(3, 1), ...
            'col', [] ...
            );
        
        Bf_Def = struct( ...
            'iter', repmat( Bf1_Def, nPoses-1, 1 ) ...
            );
        
        Bw_Def = struct( ...
            'iter', repmat( Bw1_Def, nPoses-1, 1 ) ...
            );
    end

    if ( PreIntegration_options.bPreInt == 1 )
        X_Def = struct( ...
            'pose',     repmat( Pose_Def, nPoses - 1, 1 ) , ...
            'feature',  repmat( Feature_Def, nPts, 1 ), ...
            'velocity', repmat( Velocity_Def, nPoses, 1), ...
            'g',        G_Def, ...
            'Au2c',     Angle_Def, ...
            'Tu2c',     Trans_Def, ...
            'Bf',       Bf_Def, ...
            'Bw',       Bw_Def ...
            );
    else
        nSamples = (nPoses - 1) * nIMUrate;
        X_Def = struct( ...
            'pose',     repmat( Pose_Def, nSamples, 1 ) , ...
            'feature',  repmat( Feature_Def, nPts, 1 ), ...
            'velocity', repmat( Velocity_Def, nSamples + 1, 1), ...
            'g',        G_Def, ...
            'Au2c',     Angle_Def, ...
            'Tu2c',     Trans_Def, ...
            'Bf',       Bf_Def, ...
            'Bw',       Bw_Def ...
            );
    end
    %% Compose initial value x:
    %% if(bPreInt == 0)
    %%    x = zeros((nPoses-1)*nIMUrate*6+nPts*3+3*((nPoses-1)*nIMUrate+1)+15+6,1);% one additional 6 for convenience
    %% else
    %%    x = zeros((nPoses-1)*6+nPts*3+3*nPoses+3+6+6, 1); 
    %% end 
