// Feather disable all
/// .__Destroy()
/// 
/// .__FromBuffer(buffer)
/// 
/// .__CopyFromBuffer(buffer)
/// 
/// .__FromString(string, ...)
/// 
/// .__Delete(position, count)
/// 
/// .__Insert(position, string, ...)
/// 
/// .__Overwrite(position, string, ...)
/// 
/// .__Prefix(string, ...)
/// 
/// .__Suffix(string, ...)
/// 
/// .__GetString()
/// 
/// .__GetBuffer()

function __ChatterboxBufferBatch() constructor
{
    __destroyed  = false;
    __inBuffer   = undefined;
    __workBuffer = undefined;
    __outBuffer  = undefined;
    __commands   = [];
    
    
    
    static __Destroy = function()
    {
        if (__destroyed) return;
        __destroyed = true;
        
        if (__inBuffer != undefined)
        {
            buffer_delete(__inBuffer);
            __inBuffer = undefined;
        }
        
        if (__workBuffer != undefined)
        {
            buffer_delete(__workBuffer);
            __workBuffer = undefined;
        }
        
        if (__outBuffer != undefined)
        {
            buffer_delete(__outBuffer);
            __outBuffer = undefined;
        }
        
        __commands = undefined;
    }
    
    
    
    #region Return
    
    static __GetString = function()
    {
        if (__destroyed) __Error("Worker has been destroyed");
        
        GetBuffer();
        
        buffer_seek(__outBuffer, buffer_seek_start, 0);
        return buffer_read(__outBuffer, buffer_text);
    }
    
    static __GetBuffer = function()
    {
        if (__destroyed) __Error("Worker has been destroyed");
        
        //Early-out if we have no commands set up
        if (array_length(__commands) <= 0)
        {
            if (__outBuffer == undefined)
            {
                __outBuffer = buffer_create(buffer_get_size(__inBuffer), buffer_grow, 1);
                buffer_copy(__inBuffer, 0, buffer_get_size(__inBuffer), __outBuffer, 0);
            }
            
            return __outBuffer;
        }
        
        //Order commands such that we're travelling from the start of the input buffer to the end
        array_sort(__commands, function(_a, _b)
        {
            var _a_pos = _a.__position;
            var _b_pos = _b.__position;
            
            if (_a_pos != _b_pos)
            {
                return (_a_pos < _b_pos)? -1 : 1;
            }
            
            return (_a.__nth < _b.__nth)? -1 : 1;
        });
        
        //Figure out the final size of the output buffer
        //TODO - Do this as we're adding commands
        var _inputSize  = buffer_get_size(__inBuffer);
        var _inputPos   = 0;
        var _outputSize = _inputSize;
        
        var _i = 0;
        repeat(array_length(__commands))
        {
            var _command = __commands[_i];
            var _count   = _command.__count;
            
            switch(_command.__type)
            {
                case "delete":
                    if (_inputPos + _count > _inputSize)
                    {
                        _count = _inputSize - _inputPos;
                        _command.__count = _count;
                    }
                    
                    _outputSize -= _count;
                    _inputPos   += _count;
                break;
                
                case "insert":
                case "prefix":
                case "suffix":
                    _outputSize += _count;
                break;
                
                case "overwrite":
                    _outputSize += max(0, _count - (_inputSize - _inputPos));
                    _inputPos   += _count;
                break;
            }
            
            ++_i;
        }
        
        if (_outputSize < 0)
        {
            __outBuffer = buffer_create(0, buffer_grow, 1);
            return __outBuffer;
        }
        
        __outBuffer = buffer_create(_outputSize, buffer_grow, 1);
        
        var _inputPos  = 0;
        var _outputPos = 0;
        
        var _i = 0;
        repeat(array_length(__commands))
        {
            var _command = __commands[_i];
            var _commandPos = _command.__position;
            
            _commandPos = clamp(_commandPos, 0, _inputSize);
            
            if ((_commandPos > _inputPos) && (_inputPos < _inputSize))
            {
                var _count = _commandPos - _inputPos;
                
                buffer_copy(__inBuffer, _inputPos, _count, __outBuffer, _outputPos);
                buffer_seek(__outBuffer, buffer_seek_relative, _count);
                
                _inputPos  += _count;
                _outputPos += _count;
            }
            
            var _count = _command.__count;
            
            switch(_command.__type)
            {
                case "insert":
                case "prefix":
                case "suffix":
                case "overwrite":
                    var _content = _command.__content;
                    var _j = 0;
                    repeat(array_length(_content))
                    {
                        buffer_write(__outBuffer, buffer_text, _content[_j]);
                        ++_j;
                    }
                    
                    _outputPos += _count;
                break;
            }
            
            switch(_command.__type)
            {
                case "delete":
                case "overwrite":
                    _inputPos += _count;
                break;
            }
            
            ++_i;
        }
        
        if (_outputPos < _outputSize)
        {
            buffer_copy(__inBuffer, _inputPos, _outputSize - _outputPos, __outBuffer, _outputPos);
        }
        
        buffer_seek(__outBuffer, buffer_seek_start, 0);
        
        return __outBuffer;
    }
    
    #endregion
    
    
    
    #region Commands
    
    static __CommandClass = function(_type, _nth, _position, _content, _count = undefined) constructor
    {
        if (_count == undefined)
        {
            _count = 0;
            
            var _j = 0;
            repeat(array_length(_content))
            {
                _count += string_byte_length(_content[_j]);
                ++_j;
            }
        }
        
        __type         = _type;
        __nth          = _nth;
        __position     = _position;
        __count        = _count;
        __content      = _content;
    }
    
    static __Delete = function(_position, _count)
    {
        if (__destroyed) __Error("Worker has been destroyed");
        array_push(__commands, new __CommandClass("delete", array_length(__commands), _position, undefined, _count));
    }
    
    static __Insert = function()
    {
        if (__destroyed) __Error("Worker has been destroyed");
        
        var _position = argument[0];
        
        var _content = array_create(argument_count-1);
        var _i = 1;
        repeat(argument_count-1)
        {
            _content[@ _i-1] = string(argument[_i]);
            ++_i;
        }
        
        array_push(__commands, new __CommandClass("insert", array_length(__commands), _position, _content));
    }
    
    static __Overwrite = function()
    {
        if (__destroyed) __Error("Worker has been destroyed");
        
        var _position = argument[0];
        
        var _content = array_create(argument_count-1);
        var _i = 1;
        repeat(argument_count-1)
        {
            _content[@ _i-1] = string(argument[_i]);
            ++_i;
        }
        
        array_push(__commands, new __CommandClass("overwrite", array_length(__commands), _position, _content));
    }
    
    static __Prefix = function()
    {
        if (__destroyed) __Error("Worker has been destroyed");
        
        var _content = array_create(argument_count);
        var _i = 0;
        repeat(argument_count)
        {
            _content[@ _i] = string(argument[_i]);
            ++_i;
        }
        
        array_push(__commands, new __CommandClass("prefix", array_length(__commands), -infinity, _content));
    }
    
    static __Suffix = function()
    {
        if (__destroyed) __Error("Worker has been destroyed");
        
        var _content = array_create(argument_count);
        var _i = 0;
        repeat(argument_count)
        {
            _content[@ _i] = string(argument[_i]);
            ++_i;
        }
        
        array_push(__commands, new __CommandClass("suffix", array_length(__commands), infinity, _content));
    }
    
    #endregion
    
    
    
    #region Ingest
    
    static __FromBuffer = function(_buffer)
    {
        if (__destroyed) __Error("Worker has been destroyed");
        if (__inBuffer != undefined) __Error("Input buffer already loaded");
        
        __inBuffer = _buffer;
        buffer_seek(__inBuffer, buffer_seek_start, 0);
        
        return __inBuffer;
    }
    
    static __CopyFromBuffer = function(_buffer, _start = 0, _count = (buffer_get_size(_buffer) - _start))
    {
        if (__destroyed) __Error("Worker has been destroyed");
        if (__inBuffer != undefined) __Error("Input buffer already loaded");
        
        __inBuffer = buffer_create(_count, buffer_grow, 1);
        buffer_copy(__inBuffer, _start, _count, _buffer, 0);
        
        return __inBuffer;
    }
    
    static __FromString = function(_string)
    {
        if (__destroyed) __Error("Worker has been destroyed");
        if (__inBuffer != undefined) __Error("Input buffer already loaded");
        
        __inBuffer = buffer_create(string_byte_length(_string), buffer_grow, 1);
        buffer_write(__inBuffer, buffer_text, _string);
        
        return __inBuffer;
    }
    
    #endregion
    
    
    
    static __Error = function()
    {
        var _string = "";
        
        var _i = 0;
        repeat(argument_count)
        {
            _string += string(argument[_i]);
            ++_i;
        }
        
        show_error(_string + "\n ", true);
    }
}
