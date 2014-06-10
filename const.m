% CONST              Structure with constant fields 
%
% USAGE: 
%
%   C = CONST;
%   C = CONST('fieldname', value, ...)
%   C = CONST(S); 
%
% The CONST structure behaves the same as a regular MATLAB structure, 
% except that all of its fields are rendered read-only after the first 
% assignment.
%
% Example: 
%
%     C = const;
%     C.myField = 5;    % ok
%     C.myField = pi;   % ERROR: Attempt to change CONST value
%
% Removing fields can be done via RMFIELD or the CLEAR method. A warning
% will be issued. 
%
% C = CONST initializes an empty CONST structure. 
%
% C = CONST('fieldname', value, ...) initializes a new, CONST structure. 
%
% C = CONST(S) for scalar structure S converts the structure into a CONST
% structure. 
%
% Only scalar structures are supported. 
%
% See also struct, enumeration. 


% Please report bugs and inquiries to: 
%
% Name       : Rody P.S. Oldenhuis
% E-mail     : oldenhuis@gmail.com    (personal)
%              oldenhuis@luxspace.lu  (professional)
% Affiliation: LuxSpace sàrl
% Licence    : GPL + anything implied by placing it on the FEX


% If you find this work useful and want to show your appreciation:
% https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=6G3S5UYM7HJ3N


% Authors
%{
    Rody Oldenhuis   (oldenhuis@gmail.com)
%}


% Changelog
%{
2014/February/20 (Rody Oldenhuis)
    - Initial version
%}
classdef const < dynamicprops
      
    % If you find this work useful, please consider a donation:
    % https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=6G3S5UYM7HJ3N
    
    methods
        
        %% Basics
        
        % Constructor
        function obj = const(varargin)
            
            % Empty const
            if nargin == 0
                return; end
            
            % Scalar structure
            if nargin == 1
                structIn = varargin{1};
                if ~isstruct(structIn) || ~isscalar(structIn)
                    throwAsCaller(MException('const:not_a_struct',...
                        'The input to CONST must be a scalar structure.'));
                end
                
                % Do the assignment
                F = fieldnames(structIn);
                for ii = 1:numel(F)
                    obj.subsasgn(struct('type','.', 'subs',F{ii}), structIn.(F{ii})); end
                            
            % fieldname-value pairs
            else
                fields = varargin(1:2:end);
                values = varargin(2:2:end);
                
                if ~all(cellfun('isclass', fields, 'char'))
                    throwAsCaller(MException(...
                        'const:invalid_fieldnames',...
                        'All fieldnames should be strings.'));
                end
                
                newFields = genvarname(fields);
                if ~isequal(fields, newFields)
                    warning('const:converting_fieldname',...
                        'Invalid fieldnames found; these have been converted by GENVARNAME().');
                end
                
                % Do the assignment                
                for ii = 1:numel(newFields)
                    obj.subsasgn(struct('type','.', 'subs',newFields{ii}), values{ii}); end            
            end
            
        end
                
        % Assign consts
        function obj = subsasgn(obj,S,B)
            
            if ~isequal(S.type, '.')
                throwAsCaller(MException('const:multiD_not_supported',...
                    'Multi-dimensional CONST is not yet supported.'));
            end
            
            newConst = S.subs;
            if ~isempty(findprop(obj, newConst))
                throwAsCaller(MException('const:permission_denied',...
                    'Attempt to change CONST value.'));
            end
            
            obj.addprop(newConst);
            obj.(newConst) = B;
                        
        end
        
        % Clear consts 
        function obj = clear(obj, name) 
            if ~ischar(name)
                throwAsCaller(MException('const:invalid_propertyname',...
                    'Const names should be passed as ''char''.'));                
            end
            props = properties(obj);            
            if isempty(props) || ~any(strcmp(props,name))
                throwAsCaller(MException('const:property_not_found',...
                    'Reference to non-existent field ''%s''.', name));
            end
            
            % allow it, but WARN about it!
            warning('const:clearing_const',...
                'Clearing const ''%s''.', name);
            delete(findprop(obj,name));
            
        end
        
        function obj = rmfield(obj, name)
            obj.clear(name);
        end
        
        
        %% Some overloads
        
        % type cast back to non-const struct
        function S = struct(obj)
            
            % DO warn about this
            warning('const:constness_lost',...
                'Casting CONST to regular structure.');
            
            % Get list of currently defined properties
            fields = fieldnames(obj);
            
            % Create temporary structure            
            S = struct;
            for ii = 1:numel(fields)
                S.(fields{ii}) = obj.(fields{ii}); end
            
        end
        
        % Display CONST structure
        function disp(obj)
            
            % Create temporary struct
            [msg,id] = lastwarn;   warnState = warning('off', 'const:constness_lost');
            S = struct(obj);
            lastwarn(msg, id);     warning(warnState);
            
            % Handle empties
            if isempty(S) || isempty(fieldnames(S))
                disp('CONST with no fields.');
                return
            end
            
            % use regular disp() for the initial string                        
            str = evalc('disp(S)');
            str = regexp(str, char(10), 'split');
            
            % Add const label to all properties
            fields = regexp(str, '^\s*\w*:');
            for ii  = 1:numel(str)
                if ~isempty(fields{ii})
                    str{ii} = ['<CONST>' str{ii}];
                else
                    str{ii} = ['       ' str{ii}];
                end
            end
            
            % And disp it
            disp(char(str));
                        
        end
                       
        % Pretend we're a regular struct
        function C = class(obj) %#ok<MANU>
            C = 'struct';
        end
        
        % structfun refuses to accept CONSTS, hence we need a warpper: 
        % - create a temporary regular structure
        % - pass it on to the regular structfun
        function varargout = structfun(funFcn, obj, varargin)
              
            % Create temporary struct
            [msg,id] = lastwarn;   warnState = warning('off', 'const:constness_lost');
            S = struct(obj);
            lastwarn(msg, id);     warning(warnState);
                        
            % Throw it in builtin structfun()
            [varargout{1:nargout}] = builtin('structfun', funFcn, S, varargin{:});            
            
        end
        
        
    end
    
end % classdef


