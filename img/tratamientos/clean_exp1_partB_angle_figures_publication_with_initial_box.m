%% clean_exp1_partB_angle_figures_publication.m
% Publication-style cleaner for Experiment 1 Part B angle figures.
% MATLAB Online / R2024b compatible.
%
% The script DOES NOT change the plotted numerical data.
%
% Design choices for the paper:
%   1) Keep a compact initial-reorientation annotation box showing
%      completion time and ArUco-measured angle.
%      Remove only the separate "final: ..." box because final values are
%      already reported in the Part B table.
%   2) Remove the repeated plot title because the LaTeX subfigure caption
%      identifies the object/axis.
%   3) Keep the useful visual events:
%        - target rotation trajectory
%        - ArUco-measured rotation
%        - ArUco value at the end of the initial stage
%        - correction reference, when present
%        - vertical line marking the end of the initial stage
%   4) Use concise publication-style legend wording.
%   5) Export vector PDF + 300-dpi PNG + editable FIG.
%
% Put this script in the same MATLAB Drive folder as the 8 input .fig files.

clear; clc;

files = {
    'grasp_log_20260717_220226_aruco_measured_vs_target_ramp(1).fig'
    'grasp_log_20260717_215701_aruco_measured_vs_target_ramp(5).fig'
    'grasp_log_20260717_220912_aruco_measured_vs_target_ramp.fig'
    'grasp_log_20260717_221100_aruco_measured_vs_target_ramp.fig'
    'grasp_log_20260717_200232_aruco_measured_vs_target_ramp.fig'
    'grasp_log_20260717_200823_aruco_measured_vs_target_ramp.fig'
    'grasp_log_20260717_201137_aruco_measured_vs_target_ramp.fig'
    'grasp_log_20260717_200451_aruco_measured_vs_target_ramp(1).fig'
    };

for k = 1:numel(files)

    inFile = files{k};

    if ~isfile(inFile)
        warning('File not found: %s', inFile);
        continue
    end

    fprintf('Processing: %s\n', inFile);

    fig = openfig(inFile, 'invisible');
    set(fig, 'Color', 'w', 'Units', 'pixels');

    % A wide format works well when each PDF is later used as a LaTeX subfigure.
    pos = get(fig, 'Position');
    set(fig, 'Position', [pos(1) pos(2) 1000 650]);

    %% ---------------------------------------------------------------
    % Keep the initial-reorientation annotation box, but clean its text.
    % Remove only the separate "final: ..." annotation box.
    %% ---------------------------------------------------------------
    txt = findall(fig, '-property', 'String');
    for j = 1:numel(txt)
        h = txt(j);

        try
            raw = get(h, 'String');

            if iscell(raw)
                s = char(strjoin(string(raw), newline));
            else
                s = char(string(raw));
            end

            low = lower(s);

            % Remove the separate final-value box because the final values
            % are already reported in the Part B results table.
            if contains(low, 'final:')
                delete(h);
                continue
            end

            % Clean and retain the initial-stage annotation box.
            if contains(low, 'first done') || ...
               (contains(low, 'initial reorientation completed') && ...
                (contains(low, 't =') || contains(low, 'gamma') || ...
                 contains(low, '\gamma')))

                tTok = regexp(s, ...
                    't\s*=\s*([-+]?\d*\.?\d+)\s*s', ...
                    'tokens', 'once', 'ignorecase');

                gTok = regexp(s, ...
                    '(?:gamma|\\gamma_\{?meas\}?)\s*=\s*([-+]?\d*\.?\d+)', ...
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

                if isprop(h, 'Interpreter')
                    set(h, 'Interpreter', 'tex');
                end
                if isprop(h, 'FontName')
                    set(h, 'FontName', 'Times New Roman');
                end
                if isprop(h, 'FontSize')
                    set(h, 'FontSize', 9);
                end

                % Keep a subtle border/background if this is an annotation box.
                if isprop(h, 'EdgeColor')
                    set(h, 'EdgeColor', [0.55 0.55 0.55]);
                end
                if isprop(h, 'BackgroundColor')
                    set(h, 'BackgroundColor', 'white');
                end
                continue
            end
        catch
        end
    end

    %% ---------------------------------------------------------------
    % Axes and plotted data
    %% ---------------------------------------------------------------
    ax = findall(fig, 'Type', 'axes');

    for ia = 1:numel(ax)
        a = ax(ia);

        % Remove repeated internal title.
        % The final paper will use the LaTeX subcaption for axis/object identity.
        try
            title(a, '');
        catch
        end

        try
            set(a, ...
                'FontName', 'Times New Roman', ...
                'FontSize', 11, ...
                'LineWidth', 0.8, ...
                'Box', 'on');
        catch
        end

        try
            xlabel(a, 'Time [s]', ...
                'FontName', 'Times New Roman', ...
                'FontSize', 12);
            ylabel(a, 'Rotation angle [deg]', ...
                'FontName', 'Times New Roman', ...
                'FontSize', 12);
        catch
        end

        % Keep grid subtle.
        try
            grid(a, 'on');
            a.GridAlpha = 0.18;
            a.MinorGridAlpha = 0.10;
        catch
        end

        % Standardize legend/display names without altering data.
        objs = findall(a, '-property', 'DisplayName');

        for j = 1:numel(objs)
            try
                old = strtrim(char(string(get(objs(j), 'DisplayName'))));
                low = lower(old);

                if contains(low, 'target first procedure ramp')
                    set(objs(j), 'DisplayName', 'Target rotation');

                elseif contains(low, 'measured aruco')
                    set(objs(j), 'DisplayName', 'ArUco-measured rotation');

                elseif contains(low, 'gamma at first finish')
                    set(objs(j), 'DisplayName', 'ArUco at end of initial stage');

                elseif contains(low, 'target correction ramp')
                    set(objs(j), 'DisplayName', 'Correction reference');

                elseif contains(low, 'first procedure finished')
                    set(objs(j), 'DisplayName', 'End of initial stage');
                end

                % Improve line visibility in the final PDF.
                if isprop(objs(j), 'LineWidth')
                    lw = get(objs(j), 'LineWidth');
                    if isnumeric(lw) && isscalar(lw) && lw < 1.5
                        set(objs(j), 'LineWidth', 1.5);
                    end
                end

                if isprop(objs(j), 'MarkerSize')
                    ms = get(objs(j), 'MarkerSize');
                    if isnumeric(ms) && isscalar(ms) && ms < 7
                        set(objs(j), 'MarkerSize', 7);
                    end
                end

            catch
            end
        end
    end

    %% ---------------------------------------------------------------
    % Legend: compact, consistent, outside the data region
    %% ---------------------------------------------------------------
    lgd = findall(fig, 'Type', 'legend');

    for j = 1:numel(lgd)
        try
            set(lgd(j), ...
                'FontName', 'Times New Roman', ...
                'FontSize', 8.5, ...
                'Box', 'off', ...
                'Orientation', 'horizontal', ...
                'Location', 'northoutside');

            % Use two columns where supported.
            if isprop(lgd(j), 'NumColumns')
                lgd(j).NumColumns = 2;
            end
        catch
        end
    end

    %% ---------------------------------------------------------------
    % Export
    %% ---------------------------------------------------------------
    [folder, base, ~] = fileparts(inFile);
    if isempty(folder)
        folder = pwd;
    end

    outFig = fullfile(folder, [base '_paper.fig']);
    outPdf = fullfile(folder, [base '_paper.pdf']);
    outPng = fullfile(folder, [base '_paper.png']);

    savefig(fig, outFig);
    exportgraphics(fig, outPdf, 'ContentType', 'vector');
    exportgraphics(fig, outPng, 'Resolution', 300);

    close(fig);

    fprintf('  -> %s\n', outPdf);
end

disp('Finished. Use the *_paper.pdf files in LaTeX.');
