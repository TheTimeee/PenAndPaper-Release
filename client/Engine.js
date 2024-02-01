Include("./script/api/IniParser.js");
Include("./script/api/Player.js");

function Include(sScript)
{
    if (!document.currentScript)
    {
        throw new Error("document.currentScript is not supported in this Browser, can't perform Include.");
    }

    if (typeof sScript != "string") return null;
    
    const oUrl = new URL(document.currentScript.src);
    const sOrigin = oUrl.origin;
    const sPath = oUrl.pathname;
    const sDir = sPath.substring(0, sPath.lastIndexOf('/') + 1);
    let oScript = document.querySelector('script[src="' + sOrigin + sDir + sScript + '"]');

    if (oScript === null)
    {
        oScript = document.createElement('script');
        oScript.src = sOrigin + sDir + sScript;
        document.head.appendChild(oScript);
    }

    return oScript;
}

class TypeCheck
{
    constructor()
    {
        
    }

    static Null(value)
    {
        if (value != null)
        {
            return false;
        }

        return true;
    }

    static Bool(bool)
    {
        if (typeof bool != "boolean")
        {
            return false;
        }

        return true;
    }

    static Char(char)
    {
        if (typeof char != "string" || char.length != 1)
        {
            return false;
        }

        return true;
    }

    static Float(float)
    {
        if (typeof float != 'number' || !Number.isFinite(float))
        {
            return false;
        }

        return true;
    }

    static Int(int)
    {
        if (typeof int !== 'number' || !Number.isInteger(int))
        {
            return false;
        }

        return true;
    }

    static String(string)
    {
        if (typeof string != "string")
        {
            return false;
        }

        return true;
    }

    static Instance(obj)
    {
        if ((obj instanceof Object) != true)
        {
            return false;
        }

        return true;
    }
}

class Engine
{
    static #_bInit = false;
    static #_bSucceed = false;

    static async Localize()
    {
        let fullURL = window.location.href;
        let sOriginName = fullURL.substring(fullURL.lastIndexOf('/') + 1);
        sOriginName = sOriginName.split('.')[0];
        sOriginName = sOriginName.charAt(0).toUpperCase() + sOriginName.slice(1);

        let aFields = new Map();
        let oIniParser = new IniParser();
        let sLanguageFile = await Engine.ReadFile("./localization/" + ((localStorage.getItem("engine_language") != null) ? localStorage.getItem("engine_language") : "english.ini"));
        
        if (sLanguageFile == null) sLanguageFile = await Engine.ReadFile("./localization/english.ini");
        if (!oIniParser.ReadFromBytes(sLanguageFile)) return aFields;
        if (!oIniParser.JumpToHeader(sOriginName)) return aFields;

        while(oIniParser.GetNextLine())
        {
            aFields.set(oIniParser.GetKeyValue(), oIniParser.GetValueString(0));

            let oElement = document.getElementById(oIniParser.GetKeyValue());
            if (oElement != null)
            {
                oElement.innerText = oIniParser.GetValueString(0);
            }
        }

        return aFields;
    }

    static async Initialize()
    {
        if (Engine.#_bInit === true) return Promise.resolve(false);
        Engine.#_bInit = true;

        try
        {
            await Player.Initialize();

            let aEngineContainers = document.getElementsByTagName("engine-container");
            for (let i = 0; i < aEngineContainers.length; i++) 
            {
                aEngineContainers[i].style.display = 'block';
            }

            Engine.#_bSucceed = true;
            return Promise.resolve(true);
        }
        catch (error)
        {
            let oError = document.createTextNode("Failed to initialize Engine: " + error);
            document.body.appendChild(oError);

            Engine.#_bSucceed = false;
            return Promise.reject(false);
        }
    }

    static IsInitialized()
    {
        return Engine.#_bSucceed;
    }

    static async ReadFile(sFile)
    {
        if (TypeCheck.String(sFile) === false) return null;

        let oFile = await fetch("http://localhost:8080/" + sFile);
        if (oFile.status != 200) return null;

        return await oFile.text();
    }

    static async WriteFile(sPath, sName, sExtension, sContent)
    {
        if (TypeCheck.String(sPath) === false) return false;
        if (TypeCheck.String(sName) === false) return false;
        if (TypeCheck.String(sExtension) === false) return false;
        if (TypeCheck.String(sContent) === false) return false;

        const oHeaders = new Headers
        ({
            'File-Path': sPath,
            'File-Name': sName,
            'File-Extension': sExtension,
        });

        fetch('http://localhost:8080', { method: 'POST', headers: oHeaders, body: sContent }).then(response =>
        {
            return true;
        }).catch(error => {
            console.error('Error:', error);
            return false;
        });
    }
}