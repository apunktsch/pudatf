function getHelp(func)

% Specify the JSON file path
jsonFile = strcat('_help_data/',func,'.json');

% Read the file content as a string
jsonText = fileread(jsonFile);

% Decode the JSON string into a MATLAB struct
data = jsondecode(jsonText);

displayImportantData(data);

end

function displayImportantData(data)
    % DISPLAYIMPORTANTDATA Extracts and prints relevant information from the input data struct.
    
    % Display the function name
    fprintf('Function Name: %s\n', data.funcName);
    
    % Display descriptions
    if isfield(data, 'descriptions') && ~isempty(data.descriptions)
        fprintf('Descriptions:\n');
        for i = 1:length(data.descriptions)
            fprintf('  Variable: %s\n', data.descriptions{i}.var);
            for j = 1:length(data.descriptions{i}.description)
                fprintf('    %s\n', data.descriptions{i}.description{j});
            end
        end
    end
    
    % Display parameters with values or constraints
    if isfield(data, 'parameters') && ~isempty(data.parameters)
        fprintf('\nParameters with Values or Constraints:\n');
        for i = 1:length(data.parameters)
            param = data.parameters{i};
            fprintf('  Name: %s\n', param.name);
            fprintf('    Type: %s\n', param.type);
            if ~isempty(param.constraints)
                fprintf('    Constraints:\n');
                for j = 1:length(param.constraints)
                    fprintf('      %s\n', strjoin(param.constraints{j}, ', '));
                end
            end
        end
    end
    
    % Display calls
    if isfield(data, 'calls') && ~isempty(data.calls)
        fprintf('\nFunction Calls:\n');
        for i = 1:length(data.calls)
            call = data.calls(i);
            inputs = cellfun(@(input) strjoin(input, ', '), call.inputs, 'UniformOutput', false);
            outputs = cellfun(@(output) strjoin(output, ', '), call.outputs, 'UniformOutput', false);
            
            % Format as [OUTPUTS] = functionname([INPUTS])
            fprintf('  [%s] = %s(%s)\n', ...
                strjoin(outputs, ', '), ...
                data.funcName, ...
                strjoin(inputs, ', '));
        end
    end
    
end


