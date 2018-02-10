%% GUI-Parameter
function optimSetting()
    global oVehicle oCourse oIdeal oHorizont
    
    start_line = findobj('Tag','optim_preview:start');
    start = start_line.UserData;
    ziel_line = findobj('Tag','optim_preview:ziel');
    ziel = ziel_line.UserData;
    quer_sl1 = findobj('Tag','quer_sl1');
    quer_sl2 = findobj('Tag','quer_sl2');
    sp = [quer_sl1.Value , quer_sl2.Value];
    zp = [-1 1];
    orient_obj = findobj('Tag','orient_sl');
    oVehicle.o = orient_obj.Value;
    v_obj = findobj('Tag','v_sl');
    oVehicle.v = v_obj.Value;

    if 0
        inputs = inputdlg({'v0:', 'vmax:', 'l_faktor:', 'q_faktor:'}, 'Test', 1, {'10', '100', '1', '1'});  
        oVehicle.v = str2double(inputs{1});
        oVehicle.vmax = str2double(inputs{2});
        oVehicle.a.l_faktor = str2double(inputs{3});
        oVehicle.a.q_faktor = str2double(inputs{4});
    end

    v_output = findobj('Tag','v_output');
    aOptional = {};
    if v_output.Value == 1
        sv = 'sv=true';
        aOptional{end+1} = 'SpeedVec';
%     else
%         sv = 'sv=false';
    end

    %% Optimierungshorizont
    oHorizont = Idealfinder.Course(oCourse.XYZ(start:ziel, :), oCourse.B(start:ziel, :));
    n = size(oHorizont.XYZ, 1);
    cols = 1;

    %% Problemdefinition
    sProblem.solver = 'fmincon';
    sProblem.Aineq = []; % linInequalityCon
    sProblem.bineq = []; % linInequalityCon
    sProblem.Aeq = []; % linEqualityCon
    sProblem.beq = []; % linEqualityCon
    sProblem.lb = ones(n, cols); % lowerBounds
    sProblem.ub = ones(n, cols); % upperBounds
    if cols > 0    
        % Querablage
        sProblem.lb(:,1) = sProblem.lb(:,1)*(-1);
        sProblem.ub(:,1) = sProblem.ub(:,1)*( 1);
        sProblem.lb(1,1) = min(sp);
        sProblem.ub(1,1) = max(sp);
        sProblem.lb(end,1) = zp(1);
        sProblem.ub(end,1) = zp(2);
    end
    if cols > 1
        % Geschwindigkeit
        sProblem.lb(:,2) = sProblem.lb(:,2)*(0);
        sProblem.ub(:,2) = sProblem.ub(:,2)*(oVehicle.vmax);
        sProblem.lb(1,2) = oVehicle.v;
        sProblem.ub(1,2) = oVehicle.v;
    end

    % Initialisierung
    sProblem.x0 = ones(n,cols)*(0); % initial
    sProblem.x0(:,1) = (sProblem.ub(:,1) - sProblem.lb(:,1))/2 + sProblem.lb(:,1);
    if cols > 1
        sProblem.x0(:,2) = ones(n,1)*oVehicle.v;
    end

    oInitialPath = oHorizont.getPathforOptimization(sProblem.x0(:,1));
    oVehicle.oPath = oInitialPath;
    [init.v, init.t, ~, v_grenz] = oVehicle.getSpeed();
    % Weg
    wSedit = findobj('Tag', 'optim:wS');
    if ~isempty(wSedit)
        sInitial.L.value = sum(oInitialPath.L);
        sInitial.L.w = str2double(wSedit.String);
    end
    % Zeit
    wTedit = findobj('Tag','optim:wT');
    if ~isempty(wTedit)
        sInitial.T.value = sum(init.t);
        sInitial.T.w = str2double(wTedit.String);
    end
    % Geschwindigkeit
    wVedit = findobj('Tag','optim:wV');
    if ~isempty(wVedit)
        sInitial.V.value = sum(init.v);
        sInitial.V.w = str2double(wVedit.String);
    end
    % Krümmung
    wKedit = findobj('Tag','optim:wK');
    if ~isempty(wKedit)
        sInitial.K.value = sum(abs(oInitialPath.K));
        sInitial.K.w = str2double(wKedit.String);
    end
    % Geschwindigkeitsunterschied
    w_dV = findobj('Tag','optim:w_dV');
    if ~isempty(w_dV)
        dV = v_grenz-init.v;
        sInitial.dV.value = sum(dV);
        sInitial.dV.w = str2double(w_dV.String);
    end
    % Querbeschleunigungsminimal
    w_aq_edit = findobj('Tag','optim:a_qmin');
    if ~isempty(w_aq_edit)
        a_q = abs(oInitialPath.K).*init.v.^2;
        sInitial.a_qmin.value = sum(a_q);
        sInitial.a_qmin.w = str2double(w_aq_edit.String);
    end
    
    %% Zusammenfuehrung
    sProblem.objective = @(x)Idealfinder.Optimize.optimize(x, oHorizont, sInitial, oVehicle);
    sProblem.nonlcon = ''; %@(x) nonlcon2(x, oHorizont, oVehicle);
    sProblem.options = optimoptions(str2func(sProblem.solver) ...
                                   , 'Algorithm', 'interior-point' ...
                                   ..., 'sqp' ...
                                   ..., 'active-set' ...
                                   , 'Display', 'iter' ...
                                   , 'PlotFcns', { ...@optimplotx ...
                                                 @optimplotfunccount ...
                                                 @optimplotfval ...
                                                 @Idealfinder.Optimize.plotXValues ...Ausgabe in optimFigure
                                                 ... @optimplotconstrviolation...
                                                 ... @optimplotstepsize...
                                                 ... @optimplotfirstorderopt...
                                                 } ...
                                   , 'OutputFcn', { @(x, oV, state) Idealfinder.Optimize.outfun(x, oHorizont, oVehicle, aOptional{:}) } ...Ausgabe in hMainAxes
                                   ..., 'FunValCheck', 'on',...
                                   , 'TolFun', 1e-4 ...
                                   , 'TolX', 1e-20 ...
                                   ..., 'DiffMinChange', 0.01 ...
                                   , 'MaxFunEvals', 1e5 ...
                                   , 'MaxIter', inf ...
                                   ..., 'Hessian', {'lbfgs', 5} ...
                                   , 'ScaleProblem', 'obj-and-constr' ...
                                   ..., 'FinDiffType', 'central' ...
                                   ..., 'GradObj', 'on', 'GradConstr', 'on' ...
                                   , 'Diagnostics', 'on' ...
                                   );
    %% startet Optimierung
    %profile on
    tic
    sOptimResults = Idealfinder.Optimize.runFmincon(sProblem);
    toc
    %profile viewer

    oIdeal = oHorizont.getPathforOptimization(sOptimResults.x(:, 1));
    if true
        oVehicle.oPath = oIdeal;
        oVehicle.getSpeed(true, 'animated');
    end
end