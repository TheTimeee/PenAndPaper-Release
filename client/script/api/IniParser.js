class IniParserSettings
{
    _cSeperator = null;
    _sExtension = null;
    _bHeaderMode = null;
    _cCommentDeclarator = null;
    _sErrorValueString = null;
    _iErrorValueInt = null;
    _fErrorValueFloat = null;
    _cErrorValueChar = null;
    _bErrorValueBool = null;

    constructor()
    {
        this._cSeperator = ',';
        this._sExtension = "ini";
        this._bHeaderMode = true;
        this._cCommentDeclarator = ';';
        this._sErrorValueString = "";
        this._iErrorValueInt = 0;
        this._fErrorValueFloat = 0.0;
        this._cErrorValueChar = '\0';
        this._bErrorValueBool = false;
    }
}

class IniParserLine
{
    _sKey = null;
    _aValues = null;

    constructor()
    {
        this._sKey = "";
        this._aValues = new Array();
    }
}

class IniParserObject
{
    _sHeader = null;
    _aLines = null;

    constructor()
    {
        this._sHeader = "";
        this._aLines = new Array();
    }
}

class IniParser
{
    #_oSettings = null;
	#_aObjects = null;
	#_iObjectIndex = null;
	#_iLineIndex = null;

    constructor()
    {
        this.#_oSettings = new IniParserSettings();
        this.#_aObjects = new Array();
        this.#_iObjectIndex = -1;
        this.#_iLineIndex = -1;
    }

    #Clear()
    {
        this.#_aObjects.splice(0);
	    this.#_iObjectIndex = -1;
	    this.#_iLineIndex = -1;
    }

    #ReadFile(oFile)
    {
        return new Promise((resolve, reject) =>
        {
            const oReader = new FileReader();

            oReader.onload = (event) =>
            {
                const sResult = event.target.result;
                resolve(sResult);
            };

            oReader.onerror = (error) =>
            {
                reject(error);
            };

            oReader.readAsText(oFile);
        });
    }

    GetLineSeperator()
    {
        return this.#_oSettings._cSeperator;
    }

	SetLineSeperator(cSeperator)
    {
        if (TypeCheck.Char(cSeperator) == false) return false;
        
        this.#_oSettings._cSeperator = cSeperator;

        return true;
    }
    
	GetFileExtension()
    {
        return this.#_oSettings._sExtension;
    }
    
	SetFileExtension(sExtension)
    {
        if (TypeCheck.String(sExtension) == false) return false;

        this.#_oSettings._sExtension = sExtension;

        return true;
    }
    
	GetHeaderMode()
    {
        return this.#_oSettings._bHeaderMode;
    }
    
	SetHeaderMode(bMode)
    {
        if (TypeCheck.Bool(bMode) == false) return false;

        this.#_oSettings._bHeaderMode = bMode;

        return true;
    }
    
	GetCommentDeclarator()
    {
        return this.#_oSettings._cCommentDeclarator;
    }
    
	SetCommentDeclarator(cDeclarator)
    {
        if (TypeCheck.Char(cDeclarator) == false) return false;

        this.#_oSettings._cCommentDeclarator = cDeclarator;

        return true;
    }
    
	GetErrorValueString()
    {
        return this.#_oSettings._sErrorValueString;
    }
    
	SetErrorValueString(sValue)
    {
        if (TypeCheck.String(sValue) == false) return false;

        this.#_oSettings._sErrorValueString = sValue;

        return true;
    }
    
	GetErrorValueInt()
    {
        return this.#_oSettings._iErrorValueInt;
    }
    
	SetErrorValueInt(iValue)
    {
        if (TypeCheck.Int(iValue) == false) return false;

        this.#_oSettings._iErrorValueInt = iValue;

        return true;
    }
    
	GetErrorValueFloat()
    {
        return this.#_oSettings._fErrorValueFloat;
    }
    
	SetErrorValueFloat(fValue)
    {
        if (TypeCheck.Float(fValue) == false) return false;

        this.#_oSettings._fErrorValueFloat = fValue;

        return true;
    }
    
	GetErrorValueChar()
    {
        return this.#_oSettings._cErrorValueChar;
    }
    
	SetErrorValueChar(cValue)
    {
        if (TypeCheck.Char(cValue) == false) return false;

        this.#_oSettings._cErrorValueChar = cValue;

        return true;
    }
    
	GetErrorValueBool()
    {
        return this.#_oSettings._bErrorValueBool;
    }
    
	SetErrorValueBool(bValue)
    {
        if (TypeCheck.Bool(bValue) == false) return false;

        this.#_oSettings._bErrorValueBool = bValue;

        return true;
    }

    async ReadFromFile(oFile)
    {
        this.#Clear();

        //Check if the file is of the set extension
        const fileDelimited = oFile.name.split('.');
        if (fileDelimited.length <= 1) return false;
        if (fileDelimited[fileDelimited.length - 1] != this.#_oSettings._sExtension) return false;

        //Read the files contents
        let text = "";
        try
        {
            text = await this.#ReadFile(oFile);
        }
        catch (error)
        {
            console.error(error);
            return false;
        }

        //Parse the files contents
        const lines = text.split('\n');
        const regexHeader = new RegExp(`\\[(.*?)\\]`);
        const regexKeyValue = new RegExp(`(\\w+)\\s*=\\s*([^${this.#_oSettings._cSeperator}]+(?:${this.#_oSettings._cSeperator}\\s*[^${this.#_oSettings._cSeperator}]+)*)`);
        let index = -1;
        for (const line of lines)
        {
            if (line.length <= 0) continue;

            const matchHeader = line.match(regexHeader);
            const matchKeyValue = line.match(regexKeyValue);

            if (line.at(0) == this.#_oSettings._cCommentDeclarator)
		    {
			    continue;
		    }
            else if (matchHeader)
            {
                if (this.#_oSettings._bHeaderMode == false) continue;

                index++;

                let parserObject = new IniParserObject();
                parserObject._sHeader = matchHeader[1];
                this.#_aObjects.push(parserObject);
            }
            else if (matchKeyValue)
            {
                //Switch implicative to headerless mode if in header mode
                if (index < 0)
                {
                    if (this.#_oSettings._bHeaderMode == true)
                    {
                        this.#_oSettings._bHeaderMode = false;
                    }

                    index++;
                    
                    let object = new IniParserObject();
                    object._sHeader = "";
                    this.#_aObjects.push(object);
                }

                let parserLine = new IniParserLine();
                parserLine._sKey = matchKeyValue[1];
                parserLine._aValues = matchKeyValue[2].split(',').map(item => item.trim());
                this.#_aObjects.at(index)._aLines.push(parserLine);
            }
        }
        
        return true;
    }

    ReadFromBytes(sBytes)
    {
        if (TypeCheck.String(sBytes) == false) return false;

        this.#Clear();

        //Parse the files contents
        const lines = sBytes.split('\n');
        const regexHeader = new RegExp(`\\[(.*?)\\]`);
        const regexKeyValue = new RegExp(`(\\w+)\\s*=\\s*([^${this.#_oSettings._cSeperator}]+(?:${this.#_oSettings._cSeperator}\\s*[^${this.#_oSettings._cSeperator}]+)*)`);
        let index = -1;
        for (const line of lines)
        {
            if (line.length <= 0) continue;

            const matchHeader = line.match(regexHeader);
            const matchKeyValue = line.match(regexKeyValue);

            if (line.at(0) == this.#_oSettings._cCommentDeclarator)
		    {
			    continue;
		    }
            else if (matchHeader)
            {
                if (this.#_oSettings._bHeaderMode == false) continue;

                index++;

                let parserObject = new IniParserObject();
                parserObject._sHeader = matchHeader[1];
                this.#_aObjects.push(parserObject);
            }
            else if (matchKeyValue)
            {
                //Switch implicative to headerless mode if in header mode
                if (index < 0)
                {
                    if (this.#_oSettings._bHeaderMode == true)
                    {
                        this.#_oSettings._bHeaderMode = false;
                    }

                    index++;
                    
                    let object = new IniParserObject();
                    object._sHeader = "";
                    this.#_aObjects.push(object);
                }

                let parserLine = new IniParserLine();
                parserLine._sKey = matchKeyValue[1];
                parserLine._aValues = matchKeyValue[2].split(',').map(item => item.trim());
                this.#_aObjects.at(index)._aLines.push(parserLine);
            }
        }
        
        return true;
    }

    async WriteToFile(sFile)
    {
        if (TypeCheck.String(sFile) == false) return false;

        let text = "";
        
        for (let iObject = 0; iObject < this.#_aObjects.length; iObject++)
        {
            if (this.#_oSettings._bHeaderMode == true)
            {
                text += '[' + this.#_aObjects.at(iObject)._sHeader + ']' + "\r\n\r\n";
            }

            for (let iLine = 0; iLine < this.#_aObjects.at(iObject)._aLines.length; iLine++)
            {
                text += this.#_aObjects.at(iObject)._aLines.at(iLine)._sKey + " =";

                for (let iValue = 0; iValue < this.#_aObjects.at(iObject)._aLines.at(iLine)._aValues.length; iValue++)
                {
                    text += " " + this.#_aObjects.at(iObject)._aLines.at(iLine)._aValues.at(iValue) + ((iValue + 1 < this.#_aObjects.at(iObject)._aLines.at(iLine)._aValues.length) ? this.#_oSettings._cSeperator : "");
                }

                text += ((iLine + 1 < this.#_aObjects.at(iObject)._aLines.length) ? "\r\n" : "");
            }

            text += ((iObject + 1 < this.#_aObjects.length) ? "\r\n\r\n\r\n" : "");
        }

        const url = window.URL.createObjectURL(new Blob([text], { type: 'text/plain' }));
        const a = document.createElement('a');
        a.href = url;
        a.download = sFile + "." + this.#_oSettings._sExtension;
        a.click();
        window.URL.revokeObjectURL(url);

        return true;
    }

    WriteToBytes()
    {
        let text = "";
        
        for (let iObject = 0; iObject < this.#_aObjects.length; iObject++)
        {
            if (this.#_oSettings._bHeaderMode == true)
            {
                text += '[' + this.#_aObjects.at(iObject)._sHeader + ']' + "\r\n\r\n";
            }

            for (let iLine = 0; iLine < this.#_aObjects.at(iObject)._aLines.length; iLine++)
            {
                text += this.#_aObjects.at(iObject)._aLines.at(iLine)._sKey + " =";

                for (let iValue = 0; iValue < this.#_aObjects.at(iObject)._aLines.at(iLine)._aValues.length; iValue++)
                {
                    text += " " + this.#_aObjects.at(iObject)._aLines.at(iLine)._aValues.at(iValue) + ((iValue + 1 < this.#_aObjects.at(iObject)._aLines.at(iLine)._aValues.length) ? this.#_oSettings._cSeperator : "");
                }

                text += ((iLine + 1 < this.#_aObjects.at(iObject)._aLines.length) ? "\r\n" : "");
            }

            text += ((iObject + 1 < this.#_aObjects.length) ? "\r\n\r\n\r\n" : "");
        }

        return ((text.length > 0) ? text : null);
    }
    
    JumpToHeader(sHeader)
    {
        if (TypeCheck.String(sHeader) == false) return false;

        if (this.#_oSettings._bHeaderMode == false) return false;

        this.#_iObjectIndex = -1;
        this.#_iLineIndex = -1;

        for (let i = 0; i < this.#_aObjects.length; i++)
        {
            if (this.#_aObjects.at(i)._sHeader == sHeader)
            {
                this.#_iObjectIndex = i;
                return true;
            }
        }

        return false;
    }
    
	GetNextHeader()
    {
        if (this.#_oSettings._bHeaderMode == false) return false;
        if (this.#_iObjectIndex + 1 >= this.#_aObjects.length) return false;

        this.#_iObjectIndex++;
        this.#_iLineIndex = -1;

        return true;
    }
    
	GetPreviousHeader()
    {
        if (this.#_oSettings._bHeaderMode == false) return false;
        if (this.#_iObjectIndex < 1) return false;
    
        this.#_iObjectIndex--;
        this.#_iLineIndex = -1;
    
        return true;
    }
    
	GetHeaderIndex()
    {
        if (this.#_oSettings._bHeaderMode == false) return 0;

        return this.#_iObjectIndex;
    }
    
	GetHeaderValue()
    {
        if (this.#_oSettings._bHeaderMode == false) return "";
        if (this.#_iObjectIndex < 0) return "";

        return this.#_aObjects.at(this.#_iObjectIndex)._sHeader;
    }
    
	InsertHeaderAt(sHeader, iIndex)
    {
        if (TypeCheck.String(sHeader) == false) return false;
        if (TypeCheck.Int(iIndex) == false) return false;

        if (this.#_oSettings._bHeaderMode == false) return false;
        if (sHeader == "") return false;
        if (iIndex < 0) return false;

	    let obj = new IniParserObject();
        obj._sHeader = sHeader;

        if (this.#_aObjects.length >= iIndex)
        {
            this.#_aObjects.splice(iIndex, 0, obj);
            this.#_iObjectIndex = iIndex;
        }
	    else
	    {
            this.#_aObjects.push(obj);
            this.#_iObjectIndex = this.#_aObjects.length - 1;
        }

        this.#_iLineIndex = -1;

        return true;
    }
    
	PushBackHeader(sHeader)
    {
        if (TypeCheck.String(sHeader) == false) return false;

        if (this.#_oSettings._bHeaderMode == false) return false;
        if (sHeader == "") return false;

	    let obj = new IniParserObject();
        obj._sHeader = sHeader;

        this.#_aObjects.push(obj);
        this.#_iObjectIndex = this.#_aObjects.length - 1;

        this.#_iLineIndex = -1;

        return true;
    }
    
	DeleteHeaderAt(iIndex)
    {
        if (TypeCheck.Int(iIndex) == false) return false;

        if (this.#_oSettings._bHeaderMode == false) return false;
        if (iIndex < 0) return false;

        if (this.#_aObjects.length <= iIndex) return false;

        this.#_aObjects.splice(iIndex, 1);

        if (this.#_iObjectIndex == iIndex)
        {
            this.#_iObjectIndex = -1;
            this.#_iLineIndex = -1;
        }
	    else if (this.#_iObjectIndex > iIndex)
        {
            this.#_iObjectIndex--;
            this.#_iLineIndex = -1;
        }

        return true;
    }
    
	DeleteCurrentHeader()
    {
        if (this.#_oSettings._bHeaderMode == false) return false;
        if (this.#_aObjects.length < 1) return false;
        if (this.#_iObjectIndex < 0) return false;

        this.#_aObjects.splice(this.#_iObjectIndex, 1);
        
        this.#_iObjectIndex = -1;
        this.#_iLineIndex = -1;

        return true;
    }
    
	JumpToLine(iLine)
    {
        if (TypeCheck.Int(iLine) == false) return false;

        if (this.#_iObjectIndex < 0) return false;
	    if (iLine < 0) return false;
	    if (this.#_aObjects.at(this.#_iObjectIndex)._aLines.length - 1 < iLine) return false;

	    this.#_iLineIndex = iLine;

	    return true;
    }
    
	GetNextLine()
    {
        if (this.#_iObjectIndex < 0) return false;
        if (this.#_iLineIndex + 1 >= this.#_aObjects.at(this.#_iObjectIndex)._aLines.length) return false;
        
        this.#_iLineIndex++;
        
        return true;
    }
    
	GetPreviousLine()
    {
        if (this.#_iObjectIndex < 0) return false;
        if (this.#_iLineIndex < 1) return false;
        
        this.#_iLineIndex--;
    
        return true;
    }
    
	GetLineIndex()
    {
        return this.#_iLineIndex;
    }
    
	InsertLineAt(sKey, aValues, iIndex)
    {
        if (TypeCheck.String(sKey) == false) return false;
        if (TypeCheck.Null(aValues) == true) return false;
        if (TypeCheck.Int(iIndex) == false) return false;

        if (sKey.length <= 0) return false;
	    if (aValues.length < 1) return false;
	    if (iIndex < 0) return false;

        if (this.#_iObjectIndex < 0) return false;

	    let oLine = new IniParserLine();
	    oLine._sKey = sKey;
	    oLine._aValues = aValues;

        if (this.#_aObjects.at(this.#_iObjectIndex)._aLines.length >= iIndex)
        {
            this.#_aObjects.at(this.#_iObjectIndex)._aLines.splice(iIndex, 0, oLine);
		    this.#_iLineIndex = iIndex;
        }
        else
        {
            this.#_aObjects.at(this.#_iObjectIndex)._aLines.push(oLine);
            this.#_iLineIndex = this.#_aObjects.at(this.#_iObjectIndex)._aLines.length - 1;
        }

	    return true;
    }
    
	PushBackLine(sKey, aValues)
    {
        if (TypeCheck.String(sKey) == false) return false;
        if (TypeCheck.Null(aValues) == true) return false;

        if (sKey.length <= 0) return false;
	    if (aValues.length < 1) return false;

        if (this.#_iObjectIndex < 0) return false;

	    let oLine = new IniParserLine();
	    oLine._sKey = sKey;
	    oLine._aValues = aValues;

        this.#_aObjects.at(this.#_iObjectIndex)._aLines.push(oLine);
        this.#_iLineIndex = this.#_aObjects.at(this.#_iObjectIndex)._aLines.length - 1;

	    return true;
    }
    
	DeleteLineAt(iIndex)
    {
        if (TypeCheck.Int(iIndex) == false) return false;

	    if (iIndex < 0) return false;

	    if (this.#_iObjectIndex < 0) return false;
        if (this.#_aObjects.at(this.#_iObjectIndex)._aLines.length <= iIndex) return false;

        this.#_aObjects.at(this.#_iObjectIndex)._aLines.splice(iIndex, 1);

        if (this.#_iLineIndex == iIndex)
        {
            this.#_iLineIndex = -1;
        }
	    else if (this.#_iLineIndex > iIndex)
        {
            this.#_iLineIndex--;
        }

	    return true;
    }
    
	DeleteCurrentLine()
    {
	    if (this.#_iObjectIndex < 0) return false;
        if (this.#_aObjects.at(this.#_iObjectIndex)._aLines.length < 1) return false;

        this.#_aObjects.at(this.#_iObjectIndex)._aLines.splice(this.#_iLineIndex, 1);

        this.#_iLineIndex = -1;

	    return true;
    }
    
	IsKeyValue(sKey)
    {
        if (TypeCheck.String(sKey) == false) return false;

        if (this.#_iObjectIndex < 0) return false;
        if (this.#_iLineIndex < 0) return false;
    
        return (this.#_aObjects.at(this.#_iObjectIndex)._aLines.at(this.#_iLineIndex)._sKey === sKey);
    }
    
	GetKeyValue()
    {
        if (this.#_iObjectIndex < 0) return "";
        if (this.#_iLineIndex < 0) return "";

	    return this.#_aObjects.at(this.#_iObjectIndex)._aLines.at(this.#_iLineIndex)._sKey;
    }
    
	IsValueString(iIndex)
    {
        if (TypeCheck.Int(iIndex) == false) return false;

        if (this.#_iObjectIndex < 0) return false;
        if (this.#_iLineIndex < 0) return false;
	    if (iIndex < 0) return false;

        if (this.#_aObjects.at(this.#_iObjectIndex)._aLines.at(this.#_iLineIndex)._aValues.length <= iIndex) return false;

	    return true;
    }
    
	GetValueString(iIndex)
    {
        if (TypeCheck.Int(iIndex) == false) return false;

        if (this.IsValueString(iIndex) === false) return this.#_oSettings._sErrorValueString;

        return this.#_aObjects.at(this.#_iObjectIndex)._aLines.at(this.#_iLineIndex)._aValues.at(iIndex);
    }
    
	IsValueInt(iIndex)
    {
        if (TypeCheck.Int(iIndex) == false) return false;

        if (this.#_iObjectIndex < 0) return false;
        if (this.#_iLineIndex < 0) return false;
	    if (iIndex < 0) return false;

        if (this.#_aObjects.at(this.#_iObjectIndex)._aLines.at(this.#_iLineIndex)._aValues.length <= iIndex) return false;

        let pInt = Number.parseInt(this.#_aObjects.at(this.#_iObjectIndex)._aLines.at(this.#_iLineIndex)._aValues.at(iIndex));

        return !(Number.isNaN(pInt));
    }
    
	GetValueInt(iIndex)
    {
        if (TypeCheck.Int(iIndex) == false) return false;

        if (this.IsValueInt(iIndex) === false) return this.#_oSettings._iErrorValueInt;

        return Number.parseInt(this.#_aObjects.at(this.#_iObjectIndex)._aLines.at(this.#_iLineIndex)._aValues.at(iIndex));
    }
    
	IsValueFloat(iIndex)
    {
        if (TypeCheck.Int(iIndex) == false) return false;

        if (this.#_iObjectIndex < 0) return false;
        if (this.#_iLineIndex < 0) return false;
	    if (iIndex < 0) return false;

        if (this.#_aObjects.at(this.#_iObjectIndex)._aLines.at(this.#_iLineIndex)._aValues.length <= iIndex) return false;

        let pFloat = Number.parseFloat(this.#_aObjects.at(this.#_iObjectIndex)._aLines.at(this.#_iLineIndex)._aValues.at(iIndex));

        return !(Number.isNaN(pFloat));
    }
    
	GetValueFloat(iIndex)
    {
        if (TypeCheck.Int(iIndex) == false) return false;

        if (this.IsValueFloat(iIndex) === false) return this.#_oSettings._fErrorValueFloat;

        return Number.parseFloat(this.#_aObjects.at(this.#_iObjectIndex)._aLines.at(this.#_iLineIndex)._aValues.at(iIndex));
    }
    
	IsValueChar(iIndex)
    {
        if (TypeCheck.Int(iIndex) == false) return false;

        if (this.#_iObjectIndex < 0) return false;
        if (this.#_iLineIndex < 0) return false;
	    if (iIndex < 0) return false;

        if (this.#_aObjects.at(this.#_iObjectIndex)._aLines.at(this.#_iLineIndex)._aValues.length <= iIndex) return false;

        let pChar = this.#_aObjects.at(this.#_iObjectIndex)._aLines.at(this.#_iLineIndex)._aValues.at(iIndex);

        return (pChar.length === 1);
    }
    
	GetValueChar(iIndex)
    {
        if (TypeCheck.Int(iIndex) == false) return false;

        if (this.IsValueChar(iIndex) === false) return this.#_oSettings._cErrorValueChar;

        return (this.#_aObjects.at(this.#_iObjectIndex)._aLines.at(this.#_iLineIndex)._aValues.at(iIndex))[0];
    }
    
	IsValueBool(iIndex)
    {
        if (TypeCheck.Int(iIndex) == false) return false;

        if (this.#_iObjectIndex < 0) return false;
        if (this.#_iLineIndex < 0) return false;
	    if (iIndex < 0) return false;

        if (this.#_aObjects.at(this.#_iObjectIndex)._aLines.at(this.#_iLineIndex)._aValues.length <= iIndex) return false;

        let pBool = this.#_aObjects.at(this.#_iObjectIndex)._aLines.at(this.#_iLineIndex)._aValues.at(iIndex);

        switch(pBool.toLowerCase())
        {
            case "1":
            case "true":
            case "0":
            case "false":
            {
                return true;
            }
            default:
            {
                return false;
            }
        }
    }
    
	GetValueBool(iIndex)
    {
        if (TypeCheck.Int(iIndex) == false) return false;

        if (this.IsValueBool(iIndex) === false) return this.#_oSettings._bErrorValueBool;

        switch(this.#_aObjects.at(this.#_iObjectIndex)._aLines.at(this.#_iLineIndex)._aValues.at(iIndex).toLowerCase())
        {
            case "1":
            case "true":
            {
                return true;
            }
            case "0":
            case "false":
            {
                return false;
            }
            default:
            {
                return false;
            }
        }
    }
    
	InsertValueAt(sValue, iIndex)
    {
        if (TypeCheck.String(sValue) == false) return false;
        if (TypeCheck.Int(iIndex) == false) return false;

        if (sValue.length <= 0) return false;
	    if (iIndex < 0) return false;

	    if (this.#_iObjectIndex < 0) return false;
        if (this.#_iLineIndex < 0) return false;

        if (this.#_aObjects.at(this.#_iObjectIndex)._aLines.at(this.#_iLineIndex)._aValues.length >= iIndex)
        {
            this.#_aObjects.at(this.#_iObjectIndex)._aLines.at(this.#_iLineIndex)._aValues.splice(iIndex, 0, sValue);
        }
        else
        {
            this.#_aObjects.at(this.#_iObjectIndex)._aLines.at(this.#_iLineIndex)._aValues.push(sValue);
        }

	    return true;
    }
    
	PushBackValue(sValue)
    {
        if (TypeCheck.String(sValue) == false) return false;

        if (sValue.length <= 0) return false;

	    if (this.#_iObjectIndex < 0) return false;
        if (this.#_iLineIndex < 0) return false;

        this.#_aObjects.at(this.#_iObjectIndex)._aLines.at(this.#_iLineIndex)._aValues.push(sValue);

	    return true;
    }
    
	DeleteValueAt(iIndex)
    {
        if (TypeCheck.Int(iIndex) == false) return false;

        if (iIndex < 0) return false;

	    if (this.#_iObjectIndex < 0) return false;
        if (this.#_iLineIndex < 0) return false;

        if (this.#_aObjects.at(this.#_iObjectIndex)._aLines.at(this.#_iLineIndex)._aValues.length <= 1) return false;
        if (this.#_aObjects.at(this.#_iObjectIndex)._aLines.at(this.#_iLineIndex)._aValues.length <= iIndex) return false;

	    this.#_aObjects.at(this.#_iObjectIndex)._aLines.at(this.#_iLineIndex)._aValues.splice(iIndex, 1);

	    return true;
    }
    
	OverrideValueAt(sValue, iIndex)
    {
        if (TypeCheck.String(sValue) == false) return false;
        if (TypeCheck.Int(iIndex) == false) return false;

        if (sValue.length <= 0) return false;
	    if (iIndex < 0) return false;

	    if (this.#_iObjectIndex < 0) return false;
        if (this.#_iLineIndex < 0) return false;

	    if (this.#_aObjects.at(this.#_iObjectIndex)._aLines.at(this.#_iLineIndex)._aValues.length <= iIndex) return false;

        this.#_aObjects.at(this.#_iObjectIndex)._aLines.at(this.#_iLineIndex)._aValues[iIndex] = sValue;

	    return true;
    }
}