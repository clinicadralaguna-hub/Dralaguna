%% fix_exp1_partB_angle_labels_only.m
% Fix ONLY the wording/typography of Experiment 1 Part B angle figures.
% Numerical data, curves, marker positions, limits, and annotation positions
% are not changed.
%
% Put this script in the same MATLAB Drive folder as the original .fig files,
% then run:
%     fix_exp1_partB_angle_labels_only
%
% Outputs:
%     *_labels_fixed.fig
%     *_labels_fixed.pdf
%     *_labels_fixed.png

clear; clc;

D = dir('*aruco_measured_vs_target_ramp*.fig');

% Do not reprocess files produced by earlier cleaning scripts.
badSuffixes = {'_cleaned.fig','_paper.fig','_labels_fixed.fig'};

keep = true(size(D));
for i = 1:numel(D)
    nm = lower(D(i).name);
    for j = 1:numel(badSuffixes)
        if endsWith(nm, lower(badSuffixes{j}))
            keep(i) = false;
        end
    end
end
D = D(keep);

if isempty(D)
    error('No original aruco_measured_vs_target_ramp .fig files found in the current folder.');
end

for i = 1:numel(D)
    inFile = D(i).name;
    fprintf('Fixing labels: %s\n', inFile);

    fig = openfig(inFile, 'invisible');
    set(fig, 'Color', 'w');

    %% 1. Axes title and labels
    ax = findall(fig, 'Type', 'axes');
    for ia = 1:numel(ax)
        a = ax(ia);

        % Skip legend/colorbar-like axes if encountered.
        try
            title(a, 'Target and ArUco-measured rotation', ...
                'FontWeight', 'bold');
            xlabel(a, 'Time [s]');
            ylabel(a, 'Rotation angle [deg]');
        catch
        end

        % Update DisplayName on plotted objects.
        objs = findall(a, '-property', 'DisplayName');
        for j = 1:numel(objs)
            try
                old = char(string(get(objs(j), 'DisplayName')));
                new = publicationLabel(old);
                if ~strcmp(old,new)
                    set(objs(j), 'DisplayName', new);
                end
            catch
            end
        end
    end

    %% 2. Update legend strings directly
    % This is important because some saved .fig files preserve legend text
    % independently of the plotted object's DisplayName.
    lgds = findall(fig, 'Type', 'legend');
    for j = 1:numel(lgds)
        try
            S = lgds(j).String;
            if ischar(S) || isstring(S)
                S = cellstr(S);
            end

            for q = 1:numel(S)
                S{q} = publicationLabel(char(string(S{q})));
            end

            lgds(j).String = S;
        catch
        end
    end

    %% 3. Clean the text inside annotation boxes
    % Keep the boxes; only replace informal wording.

    % Textbox annotations and ordinary text objects can both carry String.
    H = findall(fig, '-property', 'String');

    for j = 1:numel(H)
        h = H(j);

        try
            raw = get(h, 'String');

            if iscell(raw)
                s = strjoin(string(raw), newline);
            else
                s = string(raw);
            end

            sChar = char(s);
            low = lower(sChar);

            % A) "first done / t=... / gamma=..."
            if contains(low, 'first done')
                tTok = regexp(sChar, ...
                    't\s*=\s*([-+]?\d*\.?\d+)\s*s', ...
                    'tokens', 'once', 'ignorecase');

                gTok = regexp(sChar, ...
                    'gamma\s*=\s*([-+]?\d*\.?\d+)', ...
                    'tokens', 'once', 'ignorecase');

                newText = {'Initial reorientation completed'};

                if ~isempty(tTok)
                    newText{end+1} = sprintf('t = %.2f s', str2double(tTok{1}));
                end

                if ~isempty(gTok)
                    newText{end+1} = sprintf( ...
                        '\\gamma_{meas} = %.2f^{\\circ}', ...
                        str2double(gTok{1}));
                end

                set(h, 'String', newText);
                if isprop(h,'Interpreter')
                    set(h,'Interpreter','tex');
                end
                continue
            end

            % B) "final: measured / commanded deg"
            tok = regexp(sChar, ...
                'final:\s*([-+]?\d*\.?\d+)\s*/\s*([-+]?\d*\.?\d+)\s*deg', ...
                'tokens', 'once', 'ignorecase');

            if ~isempty(tok)
                meas = str2double(tok{1});
                cmd  = str2double(tok{2});

                newText = {
                    sprintf('\\gamma_{meas} = %.2f^{\\circ}', meas)
                    sprintf('\\gamma_{cmd} = %.2f^{\\circ}', cmd)
                    };

                set(h, 'String', newText);
                if isprop(h,'Interpreter')
                    set(h,'Interpreter','tex');
                end
                continue
            end

        catch
        end
    end

    %% 4. Export without changing the data
    [folder, base, ~] = fileparts(inFile);
    if isempty(folder)
        folder = pwd;
    end

    outFig = fullfile(folder, [base '_labels_fixed.fig']);
    outPdf = fullfile(folder, [base '_labels_fixed.pdf']);
    outPng = fullfile(folder, [base '_labels_fixed.png']);

    savefig(fig, outFig);
    exportgraphics(fig, outPdf, 'ContentType', 'vector');
    exportgraphics(fig, outPng, 'Resolution', 300);

    close(fig);

    fprintf('  created: %s\n', outPdf);
end

disp('Finished. Use the *_labels_fixed.pdf files in the paper.');

%% ------------------------------------------------------------------------
function out = publicationLabel(in)
    s = strtrim(char(string(in)));
    low = lower(s);

    if contains(low, 'target first procedure ramp')
        out = 'Target trajectory';

    elseif contains(low, 'measured aruco')
        out = 'ArUco-measured rotation';

    elseif contains(low, 'gamma at first finish')
        out = 'ArUco rotation at first termination';

    elseif contains(low, 'target correction ramp')
        out = 'Correction target trajectory';

    elseif contains(low, 'first procedure finished')
        out = 'Initial reorientation completed';

    else
        out = s;
    end
end
