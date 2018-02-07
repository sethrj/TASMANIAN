function tsgCoreTests()

disp(['']);
disp(['Testing TASMANIAN MATLAB interface']);
[sFiles, sTasGrid] = tsgGetPaths();
disp(['Tasmanian executable: ']);
disp(['  ',sTasGrid]);
disp(['Tasmanian work folder:']);
disp(['  ', sFiles]);
disp(['']);
[status, cmdout] = system([sTasGrid, ' -v']);
if (status ~= 0)
    disp(cmdout);
    error('There was an error while executing tasgrid.');
end
k = 1;
ll = 0;
while(((k + 6) < length(cmdout)) && (ll < 9))
    if ((cmdout(k) == ' ') && (cmdout(k+1) == ' ') && (cmdout(k+2) == ' ') && (cmdout(k+3) == ' '))
        ll = ll + 1;
        k = k + 4;
    else
        k = k + 1;
    end
end
disp(cmdout(1:k));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                     tsgMakeQuadrature()                          %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO: custom and conformal

% Basic quadrature calls and check for correct points and weight
[weights, points] = tsgMakeQuadrature(2, 'clenshaw-curtis', 'level', 1, 0);
tw = [4.0/3.0, 2.0/3.0, 2.0/3.0, 2.0/3.0, 2.0/3.0]';
tp = [0.0, 0.0; 0.0, -1.0; 0.0, 1.0; -1.0, 0.0; 1.0, 0.0; ];
if ((norm(tw - weights) > 1.E-11) || (norm(tp - points) > 1.E-11))
    error('Mismatch in points and weights of simple quadrature 1');
end

[weights, points] = tsgMakeQuadrature(2, 'clenshaw-curtis', 'level', 2, 0);
if ((norm(points(4,2) + 1.0 / sqrt(2.0)) > 1.E-11) || (norm(points(5,2) - 1.0 / sqrt(2.0)) > 1.E-11) ...
    || (norm(weights(7) - 1.0 / 9.0) > 1.E-11))
    error('Mismatch in points and weights of simple quadrature 2');
end

[weights, points] = tsgMakeQuadrature(3, 'fejer2', 'level', 4, 0);
if ((norm(sum(weights) - 2.0^3) > 1.E-11) || (abs(sum(sum(points))) > 1.E-11))
    error('Mismatch in points and weights of simple quadrature 3');
end

[weights, points] = tsgMakeQuadrature(1, 'leja', 'level', 3, 0);
tw = [4.0/3.0, 1.0/3.0, 1.0/3.0, 0.0]';
tp = [0.0, 1.0, -1.0, sqrt(1.0/3.0)]';
if ((norm(tw - weights) > 1.E-11) || (norm(tp - points) > 1.E-11))
    error('Mismatch in points and weights of simple quadrature 4');
end

% test transform
[w, p] = tsgMakeQuadrature(3, 'clenshaw-curtis', 'level', 2, 0, [3.0 5.0; -7.0 -6.0; -12.0 17.0]);
if ((abs(norm(sum(w)) - 58.0) > 1.E-11) || (abs(max(p(:, 1)) - 5.0) > 1.E-11) ...
    || (abs(min(p(:, 1)) - 3.0) > 1.E-11) || (abs(max(p(:, 2)) + 6.0) > 1.E-11) ...
    || (abs(min(p(:, 2)) + 7.0) > 1.E-11) || (abs(max(p(:, 3)) - 17.0) > 1.E-11) ...
    || (abs(min(p(:, 3)) + 12.0) > 1.E-11))
    error('Mismatch in points and weights of simple quadrature: transform');
end

% test alpha/beta
[w, p] = tsgMakeQuadrature(1, 'gauss-hermite', 'level', 4, 0, [], [2.0;]);
if (abs(norm(sum(w)) - 0.5 * pi^0.5) > 1.E-11)
    error('Mismatch in points and weights of simple quadrature: alpha/beta');
end

% test anisotropy
[w, p] = tsgMakeQuadrature(2, 'leja', 'level', 2, 0, [], [], [2, 1]');
tp = [0.0 0.0; 0.0 1.0; 0.0 -1.0; 1.0 0.0;];
if ((abs(sum(w) - 4.0) > 1.E-11) || (norm(p - tp) > 1.E-11))
    error('Mismatch in points and weights of simple quadrature: anisotropy');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                     tsgMakeGlobal()                              %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO: custom and conformal
[lGrid, p] = tsgMakeGlobal('_tsgcoretests_lgrid', 2, 1, 'clenshaw-curtis', 'level', 1);
tp = [0.0, 0.0; 0.0, -1.0; 0.0, 1.0; -1.0, 0.0; 1.0, 0.0;];
if (norm(tp - p) > 1.E-11)
    error('Mismatch in tsgMakeGlobal: core case 1');
end

% test transform
[lGrid, p] = tsgMakeGlobal('_tsgcoretests_lgrid', 3, 1, 'clenshaw-curtis', 'level', 2, [3.0 5.0; -7.0 -6.0; -12.0 17.0]);
if ((abs(max(p(:, 1)) - 5.0) > 1.E-11) || (abs(min(p(:, 1)) - 3.0) > 1.E-11) ...
    || (abs(max(p(:, 2)) + 6.0) > 1.E-11) || (abs(min(p(:, 2)) + 7.0) > 1.E-11) ...
    || (abs(max(p(:, 3)) - 17.0) > 1.E-11) || (abs(min(p(:, 3)) + 12.0) > 1.E-11))
    error('Mismatch in tsgMakeGlobal: transform');
end
[w, p] = tsgGetQuadrature(lGrid);
if ((abs(norm(sum(w)) - 58.0) > 1.E-11) || (abs(max(p(:, 1)) - 5.0) > 1.E-11) ...
    || (abs(min(p(:, 1)) - 3.0) > 1.E-11) || (abs(max(p(:, 2)) + 6.0) > 1.E-11) ...
    || (abs(min(p(:, 2)) + 7.0) > 1.E-11) || (abs(max(p(:, 3)) - 17.0) > 1.E-11) ...
    || (abs(min(p(:, 3)) + 12.0) > 1.E-11))
    error('Mismatch in tsgMakeGlobal: getQuadrature');
end

% test alpha/beta
[lGrid] = tsgMakeGlobal('_tsgcoretests_lgrid', 1, 1, 'gauss-hermite', 'level', 4, [], [2.0;]);
[w, p] = tsgGetQuadrature(lGrid);
if (abs(norm(sum(w)) - 0.5 * pi^0.5) > 1.E-11)
    error('Mismatch in tsgMakeGlobal: alpha/beta');
end

% test anisotropy
[lGrid] = tsgMakeGlobal('_tsgcoretests_lgrid', 2, 1, 'leja', 'level', 2, [], [], [2, 1]);
w = []; p = [];
[w, p] = tsgGetQuadrature(lGrid);
tp = [0.0 0.0; 0.0 1.0; 0.0 -1.0; 1.0 0.0;];
if ((abs(sum(w) - 4.0) > 1.E-11) || (norm(p - tp) > 1.E-11))
    error('Mismatch in tsgMakeGlobal: anisotropy');
end
[lGrid] = tsgMakeGlobal('_tsgcoretests_lgrid', 2, 1, 'leja', 'level', 2, [], [], [2, 1]');
w = []; p = [];
[w, p] = tsgGetQuadrature(lGrid);
tp = [0.0 0.0; 0.0 1.0; 0.0 -1.0; 1.0 0.0;];
if ((abs(sum(w) - 4.0) > 1.E-11) || (norm(p - tp) > 1.E-11))
    error('Mismatch in tsgMakeGlobal: anisotropy');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                     tsgDeleteGrid()                              %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[sFiles, sTasGrid] = tsgGetPaths();
if (~exist([sFiles,'_tsgcoretests_lgrid_FileG'], 'file'))
    error('Mismatch in tsgDeleteGrid: cannot file file that should exist');
end
tsgDeleteGrid(lGrid);
if (exist([sFiles,'_tsgcoretests_lgrid_FileG'], 'file'))
    error('Mismatch in tsgDeleteGrid: did not delete the file');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                     tsgMakeSequence()                            %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO: custom and conformal
[lGrid, p] = tsgMakeSequence('_tsgcoretests_lgrid2', 2, 1, 'min-lebesgue', 'level', 3);
tp = [0.0, 0.0; 0.0, 1.0; 0.0, -1.0; 0.0, sqrt(1.0/3.0); 1.0, 0.0; 1.0, 1.0; 1.0, -1.0; -1.0, 0.0; -1.0, 1.0; sqrt(1.0/3.0), 0.0;];
if (norm(tp - p) > 1.E-11)
    error('Mismatch in tsgMakeSequence: core case 1');
end

% test transform
[lGrid, p] = tsgMakeSequence('_tsgcoretests_lgrid2', 3, 1, 'rleja', 'level', 2, [3.0 5.0; -7.0 -6.0; -12.0 17.0]);
if ((abs(max(p(:, 1)) - 5.0) > 1.E-11) || (abs(min(p(:, 1)) - 3.0) > 1.E-11) ...
    || (abs(max(p(:, 2)) + 6.0) > 1.E-11) || (abs(min(p(:, 2)) + 7.0) > 1.E-11) ...
    || (abs(max(p(:, 3)) - 17.0) > 1.E-11) || (abs(min(p(:, 3)) + 12.0) > 1.E-11))
    error('Mismatch in tsgMakeSequence: transform');
end
[w, p] = tsgGetQuadrature(lGrid);
if ((abs(norm(sum(w)) - 58.0) > 1.E-11) || (abs(max(p(:, 1)) - 5.0) > 1.E-11) ...
    || (abs(min(p(:, 1)) - 3.0) > 1.E-11) || (abs(max(p(:, 2)) + 6.0) > 1.E-11) ...
    || (abs(min(p(:, 2)) + 7.0) > 1.E-11) || (abs(max(p(:, 3)) - 17.0) > 1.E-11) ...
    || (abs(min(p(:, 3)) + 12.0) > 1.E-11))
    error('Mismatch in tsgMakeSequence: getQuadrature');
end

% test anisotropy
[lGrid] = tsgMakeSequence('_tsgcoretests_lgrid2', 2, 1, 'leja', 'level', 2, [], [2, 1]);
w = []; p = [];
[w, p] = tsgGetQuadrature(lGrid);
tp = [0.0 0.0; 0.0 1.0; 0.0 -1.0; 1.0 0.0;];
if ((abs(sum(w) - 4.0) > 1.E-11) || (norm(p - tp) > 1.E-11))
    error('Mismatch in tsgMakeGlobal: anisotropy');
end
[lGrid] = tsgMakeSequence('_tsgcoretests_lgrid2', 2, 1, 'leja', 'level', 2, [], [2, 1]');
w = []; p = [];
[w, p] = tsgGetQuadrature(lGrid);
tp = [0.0 0.0; 0.0 1.0; 0.0 -1.0; 1.0 0.0;];
if ((abs(sum(w) - 4.0) > 1.E-11) || (norm(p - tp) > 1.E-11))
    error('Mismatch in tsgMakeGlobal: anisotropy');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                     tsgDeleteGridByName()                        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[sFiles, sTasGrid] = tsgGetPaths();
if (~exist([sFiles,'_tsgcoretests_lgrid2_FileG'], 'file'))
    error('Mismatch in tsgDeleteGrid: cannot file file that should exist');
end
tsgDeleteGridByName('_tsgcoretests_lgrid2');
if (exist([sFiles,'_tsgcoretests_lgrid2_FileG'], 'file'))
    error('Mismatch in tsgDeleteGrid: did not delete the file');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                     tsgMakeLocalPolynomial()                     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO: conformal
% test transform
[lGrid, p] = tsgMakeLocalPolynomial('_tsgcoretests_lgrid2', 3, 1, 'localp', 2, 2, [3.0 5.0; -7.0 -6.0; -12.0 17.0]);
if ((abs(max(p(:, 1)) - 5.0) > 1.E-11) || (abs(min(p(:, 1)) - 3.0) > 1.E-11) ...
    || (abs(max(p(:, 2)) + 6.0) > 1.E-11) || (abs(min(p(:, 2)) + 7.0) > 1.E-11) ...
    || (abs(max(p(:, 3)) - 17.0) > 1.E-11) || (abs(min(p(:, 3)) + 12.0) > 1.E-11))
    error('Mismatch in tsgMakeLocalPolynomial: transform');
end
[w, p] = tsgGetQuadrature(lGrid);
if ((abs(norm(sum(w)) - 58.0) > 1.E-11) || (abs(max(p(:, 1)) - 5.0) > 1.E-11) ...
    || (abs(min(p(:, 1)) - 3.0) > 1.E-11) || (abs(max(p(:, 2)) + 6.0) > 1.E-11) ...
    || (abs(min(p(:, 2)) + 7.0) > 1.E-11) || (abs(max(p(:, 3)) - 17.0) > 1.E-11) ...
    || (abs(min(p(:, 3)) + 12.0) > 1.E-11))
    error('Mismatch in tsgMakeLocalPolynomial: getQuadrature');
end
tsgDeleteGrid(lGrid);
# polynomial order is tested in tsgEvaluate()

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                     tsgMakeWavelet()                             %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO: correctness and conformal
% test transform
[lGrid, p] = tsgMakeWavelet('_tsgcoretests_lgrid', 3, 1, 2, 1, [3.0 5.0; -7.0 -6.0; -12.0 17.0]);
if ((abs(max(p(:, 1)) - 5.0) > 1.E-11) || (abs(min(p(:, 1)) - 3.0) > 1.E-11) ...
    || (abs(max(p(:, 2)) + 6.0) > 1.E-11) || (abs(min(p(:, 2)) + 7.0) > 1.E-11) ...
    || (abs(max(p(:, 3)) - 17.0) > 1.E-11) || (abs(min(p(:, 3)) + 12.0) > 1.E-11))
    error('Mismatch in tsgMakeWavelet: transform');
end
[w, p] = tsgGetQuadrature(lGrid);
if ((abs(norm(sum(w)) - 58.0) > 1.E-11) || (abs(max(p(:, 1)) - 5.0) > 1.E-11) ...
    || (abs(min(p(:, 1)) - 3.0) > 1.E-11) || (abs(max(p(:, 2)) + 6.0) > 1.E-11) ...
    || (abs(min(p(:, 2)) + 7.0) > 1.E-11) || (abs(max(p(:, 3)) - 17.0) > 1.E-11) ...
    || (abs(min(p(:, 3)) + 12.0) > 1.E-11))
    error('Mismatch in tsgMakeWavelet: getQuadrature');
end

disp(['tsgMake* functions:       PASS']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                     tsgGetPoints()                               %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[lGrid] = tsgMakeGlobal('_tsgcoretests_lgrid', 2, 1, 'clenshaw-curtis', 'level', 1);
tp = [0.0, 0.0; 0.0, -1.0; 0.0, 1.0; -1.0, 0.0; 1.0, 0.0;];
p = [];
[p] = tsgGetPoints(lGrid);
if (norm(tp - p) > 1.E-11)
    error('Mismatch in tsgGetPoints: core case 1');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                     tsgGetNeededPoints()                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% covered in tsgLoadValues() and tsgRefine*()

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                     tsgGetQuadrature()                           %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% covered in tsgMakeGlobal() and tsgMakeSequence()

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                     tsgLoadValues()                              %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[lGrid, p] = tsgMakeGlobal('_tsgcoretests_lgrid', 2, 2, 'min-delta', 'level', 4);
[pn] = tsgGetNeededPoints(lGrid);
if (norm(p - pn) > 1.E-11)
    error('Mismatch in tsgLoadValues: tsgGetNeededPoints case 1');
end
v = [exp(-p(:,1).^2 -p(:,2).^2), cos(-p(:,1) -2.0 * p(:,2))];
tsgLoadValues(lGrid, v);
[pn] = tsgGetPoints(lGrid);
if (norm(p - pn) > 1.E-11)
    error('Mismatch in tsgLoadValues: tsgGetPoints');
end

[pn] = tsgGetNeededPoints(lGrid);
if (max(size(pn)) ~= 0)
    error('Mismatch in tsgLoadValues: tsgGetNeededPoints case 2');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                     tsgEvaluate()                                %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[lGrid, p] = tsgMakeLocalPolynomial('_tsgcoretests_lp', 2, 4, 'localp', 1, 1);
v = [0.3*ones(size(p,1), 1), p(:,1) + p(:,2), ...
     p(:,1).^2 + p(:,2).^2 + p(:,1).*p(:,2), ...
     p(:,1).^3 + p(:,2).^3 + p(:,1).*(p(:,2).^2) ];
tsgLoadValues(lGrid, v);
p = [1.0/3.0, 1.0/3.0; pi/6.0, -sqrt(2.0)/2.0;];
tv = [0.3*ones(size(p,1), 1), p(:,1) + p(:,2), ...
      p(:,1).^2 + p(:,2).^2 + p(:,1).*p(:,2), ...
      p(:,1).^3 + p(:,2).^3 + p(:,1).*(p(:,2).^2) ];
[res] = tsgEvaluate(lGrid, p);
for i = 1:2
    if (norm(res(:,i) - tv(:,i)) > 1.E-11)
        error(['Mismatch in tsgEvaluate: case 1, output ',num2str(i)]);
    end
end
for i = 3:4
    if (norm(res(:,i) - tv(:,i)) < 1.E-8)
        error(['Mismatch in tsgEvaluate: case 1, output ',num2str(i)]);
    end
end

[lGrid, p] = tsgMakeLocalPolynomial('_tsgcoretests_lp', 2, 4, 'localp', 1, 2);
v = [0.3*ones(size(p,1), 1), p(:,1) + p(:,2), ...
     p(:,1).^2 + p(:,2).^2 + p(:,1).*p(:,2), ...
     p(:,1).^3 + p(:,2).^3 + p(:,1).*(p(:,2).^2) ];
tsgLoadValues(lGrid, v);
p = [1.0/3.0, 1.0/3.0; pi/6.0, -sqrt(2.0)/2.0;];
tv = [0.3*ones(size(p,1), 1), p(:,1) + p(:,2), ...
      p(:,1).^2 + p(:,2).^2 + p(:,1).*p(:,2), ...
      p(:,1).^3 + p(:,2).^3 + p(:,1).*(p(:,2).^2) ];
[res] = tsgEvaluate(lGrid, p);
for i = 1:2
    if (norm(res(:,i) - tv(:,i)) > 1.E-11)
        error(['Mismatch in tsgEvaluate: case 2, output ',num2str(i)]);
    end
end
for i = 3:4
    if (norm(res(:,i) - tv(:,i)) < 1.E-8)
        error(['Mismatch in tsgEvaluate: case 2, output ',num2str(i)]);
    end
end

[lGrid, p] = tsgMakeLocalPolynomial('_tsgcoretests_lp', 2, 4, 'semi-localp', 1, 2);
v = [0.3*ones(size(p,1), 1), p(:,1) + p(:,2), ...
     p(:,1).^2 + p(:,2).^2, ...
     p(:,1).^3 + p(:,2).^3 + p(:,1).*(p(:,2).^2) ];
tsgLoadValues(lGrid, v);
p = [1.0/3.0, 1.0/3.0; pi/6.0, -sqrt(2.0)/2.0;];
tv = [0.3*ones(size(p,1), 1), p(:,1) + p(:,2), ...
      p(:,1).^2 + p(:,2).^2, ...
      p(:,1).^3 + p(:,2).^3 + p(:,1).*(p(:,2).^2) ];
[res] = tsgEvaluate(lGrid, p);
for i = 1:3
    if (norm(res(:,i) - tv(:,i)) > 1.E-11)
        error(['Mismatch in tsgEvaluate: case 3, output ',num2str(i)]);
    end
end
for i = 4:4
    if (norm(res(:,i) - tv(:,i)) < 1.E-8)
        error(['Mismatch in tsgEvaluate: case 3, output ',num2str(i)]);
    end
end

[lGrid, p] = tsgMakeLocalPolynomial('_tsgcoretests_lp', 2, 4, 'localp', 2, 2);
v = [0.3*ones(size(p,1), 1), p(:,1) + p(:,2), ...
     p(:,1).^2 + p(:,2).^2 + p(:,1).*p(:,2), ...
     p(:,1).^3 + p(:,2).^3 + p(:,1).*(p(:,2).^2) ];
tsgLoadValues(lGrid, v);
p = [1.0/3.0, 1.0/3.0; pi/6.0, -sqrt(2.0)/2.0;];
tv = [0.3*ones(size(p,1), 1), p(:,1) + p(:,2), ...
      p(:,1).^2 + p(:,2).^2 + p(:,1).*p(:,2), ...
      p(:,1).^3 + p(:,2).^3 + p(:,1).*(p(:,2).^2) ];
[res] = tsgEvaluate(lGrid, p);
for i = 1:3
    if (norm(res(:,i) - tv(:,i)) > 1.E-11)
        error(['Mismatch in tsgEvaluate: case 4, output ',num2str(i)]);
    end
end
for i = 4:4
    if (norm(res(:,i) - tv(:,i)) < 1.E-8)
        error(['Mismatch in tsgEvaluate: case 4, output ',num2str(i)]);
    end
end

[lGrid, p] = tsgMakeLocalPolynomial('_tsgcoretests_lp', 2, 4, 'localp', 3, 3);
v = [0.3*ones(size(p,1), 1), p(:,1) + p(:,2), ...
     p(:,1).^2 + p(:,2).^2 + p(:,1).*p(:,2), ...
     p(:,1).^3 + p(:,2).^3 + p(:,1).*(p(:,2).^2) ];
tsgLoadValues(lGrid, v);
p = [1.0/3.0, 1.0/3.0; pi/6.0, -sqrt(2.0)/2.0;];
tv = [0.3*ones(size(p,1), 1), p(:,1) + p(:,2), ...
      p(:,1).^2 + p(:,2).^2 + p(:,1).*p(:,2), ...
      p(:,1).^3 + p(:,2).^3 + p(:,1).*(p(:,2).^2) ];
[res] = tsgEvaluate(lGrid, p);
for i = 1:4
    if (norm(res(:,i) - tv(:,i)) > 1.E-11)
        error(['Mismatch in tsgEvaluate: case 5, output ',num2str(i)]);
    end
end
tsgDeleteGrid(lGrid);

[lGrid, p] = tsgMakeGlobal('_tsgcoretests_ch', 2, 1, 'chebyshev', 'iptotal', 22);
v = [exp(-p(:,1).^2 -p(:,2).^2)];
tsgLoadValues(lGrid, v);
p = [-1.0 + 2.0 * rand(1000,2)];
v = [exp(-p(:,1).^2 -p(:,2).^2)];
[res] = tsgEvaluate(lGrid, p);
if (norm(v - res) > 1.E-9)
    error(['Mismatch in tsgEvaluate: global grid with chebyshev points']);
end
tsgDeleteGrid(lGrid);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                     tsgEvaluateHierarchy()                       %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[lGrid, p] = tsgMakeGlobal('_tsgcoretests_ml', 3, 1, 'fejer2', 'level', 4);
[V] = tsgEvaluateHierarchy(lGrid, p);
if (norm(V - eye(size(p,1))) > 1.E-11)
    error(['Mismatch in tsgEvaluateHierarchy: lagrange polynomials do not form identity']);
end

[lGrid, p] = tsgMakeSequence('_tsgcoretests_ml', 2, 1, 'leja', 'level', 2);
pnts = [0.33, 0.25; -0.27, 0.39; 0.97, -0.76; -0.44, 0.21; -0.813, 0.03; -0.666, 0.666];
tres = [ones(size(pnts, 1), 1), pnts(:,2), 0.5 * pnts(:,2) .* (pnts(:,2) - 1.0), pnts(:,1), pnts(:,1) .* pnts(:,2), 0.5 * pnts(:,1) .* (pnts(:,1) - 1.0)];
[res] = tsgEvaluateHierarchy(lGrid, pnts);
if (norm(res - tres) > 1.E-11)
    error(['Mismatch in tsgEvaluateHierarchy: sequence grid test']);
end

[lGrid, p] = tsgMakeLocalPolynomial('_tsgcoretests_ml', 2, 1, 'localp', 2, 1);
v = [exp(-p(:,1).^2 - 2.0 * p(:,2).^2)];
tsgLoadValues(lGrid, v);
pnts = [-1.0 + 2.0 * rand(13, 2)];
[tres] = tsgEvaluate(lGrid, pnts);
[mVan] = tsgEvaluateHierarchy(lGrid, pnts);
[coef] = tsgGetHCoefficients(lGrid);
res = mVan * coef;
if (norm(tres - res) > 1.E-11)
    error(['Mismatch in tsgEvaluateHierarchy: localp grid test']);
end

tsgDeleteGrid(lGrid);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                     tsgIntegrate()                               %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[lGrid, p] = tsgMakeGlobal('_tsgcoretests_int', 1, 1, 'gauss-hermite', 'level', 2, [], [0.0, 0.0]);
v = [p.^2];
tsgLoadValues(lGrid, v)
[I] = tsgIntegrate(lGrid);
if (abs(I - pi^0.5 / 2.0) > 1.E-11)
    error('Mismatch in tsgIntegrate(): case 1');
end

[lGrid, p] = tsgMakeGlobal('_tsgcoretests_int', 1, 1, 'gauss-hermite', 'level', 2, [], [2.0, 0.0]);
v = [sqrt(2.0) * ones(size(v,1), 1)];
tsgLoadValues(lGrid, v)
[I] = tsgIntegrate(lGrid);
if (abs(I - sqrt(2.0) * pi^0.5 / 2.0) > 1.E-11)
    error('Mismatch in tsgIntegrate(): case 2');
end

disp(['Core I/O and evaluate:    PASS']);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                     tsgEstimateAnisotropicCoefficients()         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[lGrid, p] = tsgMakeGlobal('_tsgcoretests_ans', 2, 1, 'rleja', 'level', 9);
v = [exp(p(:,1) + p(:,2).^2)];
tsgLoadValues(lGrid, v);
[c] = tsgEstimateAnisotropicCoefficients(lGrid, 'iptotal');
if (abs(c(1) / c(2) - 2.0) > 0.2)
    error('Mismatch in tsgEstimateAnisotropicCoefficients(): total degree');
end
[c] = tsgEstimateAnisotropicCoefficients(lGrid, 'ipcurved');
if (length(c) ~= 4)
    error('Mismatch in tsgEstimateAnisotropicCoefficients(): curved dimensions');
end
if ((abs(c(1) / c(2) - 2.0) > 0.2) || (c(3) > 0.0) || (c(4) > 0.0))
    error('Mismatch in tsgEstimateAnisotropicCoefficients(): curved');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                     tsgRefineAnisotropic()                       %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                     tsgRefineSurplus()                           %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                     tsgCancelRefine()                            %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                     tsgMergeRefine()                             %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[lGridA, p] = tsgMakeGlobal('_tsgcoretests_refA', 2, 1, 'fejer2', 'level', 4);
[lGridB, p] = tsgMakeGlobal('_tsgcoretests_refB', 2, 1, 'fejer2', 'level', 4);
v = [exp(-p(:,1).^2 -p(:,2).^2)];
tsgLoadValues(lGridA, v);
[c] = tsgGetHCoefficients(lGridA);
if (norm(c - v) > 1.E-11)
    error('Mismatch in tsgMergeRefine(): case 1, tsgGetHCoefficients()');
end
tsgLoadHCoefficients(lGridB, c);
p = [-1.0 + 2.0 * rand(1000,2)];
[vA] = tsgEvaluate(lGridA, p);
[vB] = tsgEvaluate(lGridB, p);
if (norm(vA - vB) > 1.E-11)
    error('Mismatch in tsgMergeRefine(): case 1, tsgLoadHCoefficients()');
end
tsgDeleteGrid(lGridA);
tsgDeleteGrid(lGridB);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                     tsgGetHCoefficients()                        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% covered in tsgMergeRefine()

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                     tsgLoadHCoefficients()                       %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% covered in tsgMergeRefine()

disp(['Refinement functions:     PASS']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                     tsgReloadGrid()                              %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[lGrid, p] = tsgMakeGlobal('_tsgcoretests_ch', 3, 7, 'chebyshev', 'iptotal', 5);
[lGrid2] = tsgReloadGrid('_tsgcoretests_ch');
if (lGrid2.sName ~= '_tsgcoretests_ch')
    error('Mismatch in tsgReloadGrid() could not reload grid: sName');
end
if (lGrid2.sType ~= 'Global')
    error('Mismatch in tsgReloadGrid() could not reload grid: sType');
end
if ((lGrid2.iDim ~= 3) || (lGrid2.iOut ~= 7))
    error('Mismatch in tsgReloadGrid() could not reload grid: iDim and iOut');
end

disp(['Utility functions:        PASS']);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(['']);
disp(['All Tasmanian Tests Completed Successfully']);

end