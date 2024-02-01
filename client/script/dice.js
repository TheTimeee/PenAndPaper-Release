class Dice
{
    static #_bDiceLocked = false;
    static #_bConnected = false;
    static #_sIP = "";
    static #_sPort = "";
    static #_iConsoleLimit = 32767;

    static GetConnected()
    {
        return Dice.#_bConnected;
    }

    static GetIP()
    {
        return Dice.#_sIP;
    }

    static GetPort()
    {
        return Dice.#_sPort;
    }

    static ReadConfig()
    {
        let aRect = [(screen.width / 2) - (656 / 2), (screen.height / 2) - (833 / 2), 656, 833];

        //Pos
        let sPos = null;
        if ((sPos = localStorage.getItem("dice_pos")) != null)
        {
            let aPos = JSON.parse(sPos);

            if (aPos[0] != null) aRect[0] = aPos[0];
            if (aPos[1] != null) aRect[1] = aPos[1];
        }

        //Size
        let sSize = null;
        if ((sSize = localStorage.getItem("dice_size")) != null)
        {
            let aSize = JSON.parse(sSize);

            if (aSize[0] != null) aRect[2] = aSize[0];
            if (aSize[1] != null) aRect[3] = aSize[1];
        }

        //IP
        let sTargetIp = null;
        if ((sTargetIp = localStorage.getItem("dice_ip")) != null)
        {
            document.getElementById("IDC_TEXTBOX_TARGET").value = sTargetIp;
        }

        //Name
        let sName = null;
        if ((sName = localStorage.getItem("dice_name")) != null)
        {
            document.getElementById("IDC_TEXTBOX_NAME").value = sName;
        }
        
        window.moveTo(aRect[0], aRect[1]);
        window.resizeTo(aRect[2], aRect[3]);
    }

    static WriteConfig()
    {
        localStorage.setItem('dice_pos', JSON.stringify([window.screenX, window.screenY]));
        localStorage.setItem('dice_size', JSON.stringify([window.outerWidth, window.outerHeight]));
        localStorage.setItem('dice_ip', document.getElementById("IDC_TEXTBOX_TARGET").value);
        localStorage.setItem('dice_name', document.getElementById("IDC_TEXTBOX_NAME").value);
    }

    static async #Connect()
    {
        let sPort = "9090";
        let oButtonConnect = document.getElementById("IDC_BUTTON_CONNECT");
        let oButtonRoll = document.getElementById("IDC_BUTTON_ROLL");
        let oTextConnect = document.getElementById("IDC_TEXT_CONNECT");
        let oTextConsole = document.getElementById("IDC_TEXTAREA_CONSOLE");
        let oTextTarget = document.getElementById("IDC_TEXTBOX_TARGET");

        const oHeaders = new Headers
        ({
            'Dice-Connect': 1,
        });

        try
        {
            oTextTarget.disabled = true;
            oButtonConnect.disabled = true;
            oButtonRoll.disabled = true;

            oTextConnect.innerText = LOCALIZED_MAP.get("IDD_TEXT_CONNECTING") + " " + oTextTarget.value;
            oTextConnect.style.color = "blue";

            await fetch("http://" + oTextTarget.value + ":" + sPort + "/", { method: 'GET', headers: oHeaders, body: null });

            Dice.#_bConnected = true;
            Dice.#_sIP = oTextTarget.value;
            Dice.#_sPort = sPort;
            
            oButtonConnect.innerText = LOCALIZED_MAP.get("IDD_BUTTON_DISCONNECT");
            oTextConnect.innerText = LOCALIZED_MAP.get("IDD_TEXT_CONNECTED") + " " + Dice.#_sIP;
            oTextConnect.style.color = "green";
            oTextConsole.value += ((oTextConsole.value.length > 0) ? "\n\n" : "") + LOCALIZED_MAP.get("IDD_CONSOLE_CONNECTED") + " " + Dice.#_sIP;
            oTextConsole.scrollTop = oTextConsole.scrollHeight;
        }
        catch (error)
        {
            Dice.#_bConnected = false;
            Dice.#_sIP = "";
            Dice.#_sPort = "";

            oButtonConnect.innerText = LOCALIZED_MAP.get("IDD_BUTTON_CONNECT");
            oTextConnect.innerText = LOCALIZED_MAP.get("IDD_TEXT_DISCONNECTED");
            oTextConnect.style.color = "red";
            oTextConsole.value += ((oTextConsole.value.length > 0) ? "\n\n" : "") + LOCALIZED_MAP.get("IDD_CONSOLE_FAILURE") + " " + oTextTarget.value;
            oTextConsole.scrollTop = oTextConsole.scrollHeight;
        }
        finally
        {
            oTextTarget.disabled = false;
            oButtonConnect.disabled = false;
            oButtonRoll.disabled = false;
        }
    }

    static #Disconnect()
    {
        let oButtonConnect = document.getElementById("IDC_BUTTON_CONNECT");
        let oTextConnect = document.getElementById("IDC_TEXT_CONNECT");
        let oTextConsole = document.getElementById("IDC_TEXTAREA_CONSOLE");

        oButtonConnect.innerText = LOCALIZED_MAP.get("IDD_BUTTON_CONNECT");
        oTextConnect.innerText = LOCALIZED_MAP.get("IDD_TEXT_DISCONNECTED");
        oTextConnect.style.color = "red";
        oTextConsole.value += ((oTextConsole.value.length > 0) ? "\n\n" : "") + LOCALIZED_MAP.get("IDD_CONSOLE_DISCONNECTED") + " " + Dice.#_sIP;
        oTextConsole.scrollTop = oTextConsole.scrollHeight;

        Dice.#_bConnected = false;
        Dice.#_sIP = "";
        Dice.#_sPort = "";
    }

    static #RollLocal()
    {
        let oConsole = document.getElementById("IDC_TEXTAREA_CONSOLE");
        let sName = document.getElementById("IDC_TEXTBOX_NAME").value;
        let sIntention = document.getElementById("IDC_TEXTBOX_INTENTION").value;
        let iAmount = document.getElementById("IDC_TEXTBOX_AMOUNT").value;
        let iRolls = document.getElementById("IDC_TEXTBOX_ROLLS").value;
        let iSignet = document.getElementById("IDC_TEXTBOX_SIGNET").value;
        let bEwHaja = document.getElementById("IDC_CHECKBOX_EWHAJA").checked;

        let oDate = new Date();

        let oContainer = DiceBot.Roll(sName, sIntention, iAmount, iRolls, iSignet, "", 0, 0, 0, 0, bEwHaja);

        let sResult = "";
        sResult += ((oConsole.value.length > 0) ? "\n\n\n" : "");
        sResult += LOCALIZED_MAP.get("IDD_ROLL_LOCAL") + "\n";
        sResult += "-----------------------------\n";
        sResult += LOCALIZED_MAP.get("IDD_ROLL_TIME") + ": " + oDate.getHours();
        sResult += ":" + oDate.getMinutes();
        sResult += ":" + oDate.getSeconds();
        sResult += " " + oDate.getDay();
        sResult += "/" + (oDate.getMonth() + 1).toString().padStart(2, '0');
        sResult += "/" + oDate.getFullYear() + "\n";
        sResult += LOCALIZED_MAP.get("IDD_ROLL_INTENTION") + ": " + oContainer[1] + "\n";
        sResult += "-----------------------------\n";
        sResult += LOCALIZED_MAP.get("IDD_ROLL_DICE") + ": " + oContainer[2] + "\n";
        sResult += LOCALIZED_MAP.get("IDD_ROLL_CYCLES") + ": " + oContainer[3] + "\n";
        sResult += LOCALIZED_MAP.get("IDD_ROLL_SIGNET") + ": " + oContainer[4] + "\n";
        sResult +=  ((bEwHaja) ? LOCALIZED_MAP.get("IDD_ROLL_EWHAJA") + "\n" : "");
        sResult += "-----------------------------\n";
        sResult += LOCALIZED_MAP.get("IDD_ROLL_RESULT") + ": " + oContainer[5] + "\n";
        sResult += LOCALIZED_MAP.get("IDD_ROLL_SUCCESS") + ": " + oContainer[6] + "\n";
        sResult += LOCALIZED_MAP.get("IDD_ROLL_FAILURE") + ": " + oContainer[7] + "\n";
        sResult += LOCALIZED_MAP.get("IDD_ROLL_SUM") + ": " + oContainer[8] + "\n";
        sResult += LOCALIZED_MAP.get("IDD_ROLL_CRIT") + ": " + oContainer[9];

        oConsole.value += sResult;
        oConsole.scrollTop = oConsole.scrollHeight;
    }

    static async #RollServer()
    {
        let oConnect = document.getElementById("IDC_BUTTON_CONNECT");
        //let oRoll = document.getElementById("IDC_BUTTON_ROLL");
        let oTarget = document.getElementById("IDC_TEXTBOX_TARGET");
        let oConsole = document.getElementById("IDC_TEXTAREA_CONSOLE");
        let sName = document.getElementById("IDC_TEXTBOX_NAME").value;
        let sIntention = document.getElementById("IDC_TEXTBOX_INTENTION").value;
        let iAmount = document.getElementById("IDC_TEXTBOX_AMOUNT").value;
        let iRolls = document.getElementById("IDC_TEXTBOX_ROLLS").value;
        let iSignet = document.getElementById("IDC_TEXTBOX_SIGNET").value;
        let bEwHaja = document.getElementById("IDC_CHECKBOX_EWHAJA").checked;

        let oDate = new Date();

        const oHeaders = new Headers
        ({
            'Dice-Skill': 1,
        });

        let sParams = "Dice-Name=" + sName + "&";
        sParams += "Dice-Intention=" + sIntention + "&";
        sParams += "Dice-Amount=" + iAmount + "&";
        sParams += "Dice-Rolls=" + iRolls + "&";
        sParams += "Dice-Signet=" + iSignet + "&";
        sParams += "Signet-EwHaja=" + ((bEwHaja === true) ? 1 : 0);

        try
        {
            oTarget.disabled = true;
            oConnect.disabled = true;

            let oResponse = await fetch("http://" + Dice.#_sIP + ":" + Dice.#_sPort + "/" + "?" + sParams, { method: 'GET', headers: oHeaders, body: null });
            
            if (oResponse.status === 200)
            {
                let sResult = await oResponse.text();

                sResult = sResult.replace(new RegExp("IDD_ROLL_DICE*"), LOCALIZED_MAP.get("IDD_ROLL_DICE"));
                sResult = sResult.replace(new RegExp("IDD_ROLL_CYCLES*"), LOCALIZED_MAP.get("IDD_ROLL_CYCLES"));
                sResult = sResult.replace(new RegExp("IDD_ROLL_SIGNET*"), LOCALIZED_MAP.get("IDD_ROLL_SIGNET"));
                sResult = sResult.replace(new RegExp("IDD_ROLL_EWHAJA*"), LOCALIZED_MAP.get("IDD_ROLL_EWHAJA"));
                sResult = sResult.replace(new RegExp("IDD_ROLL_RESULT*"), LOCALIZED_MAP.get("IDD_ROLL_RESULT"));
                sResult = sResult.replace(new RegExp("IDD_ROLL_SUCCESS*"), LOCALIZED_MAP.get("IDD_ROLL_SUCCESS"));
                sResult = sResult.replace(new RegExp("IDD_ROLL_FAILURE*"), LOCALIZED_MAP.get("IDD_ROLL_FAILURE"));
                sResult = sResult.replace(new RegExp("IDD_ROLL_SUM*"), LOCALIZED_MAP.get("IDD_ROLL_SUM"));
                sResult = sResult.replace(new RegExp("IDD_ROLL_CRIT*"), LOCALIZED_MAP.get("IDD_ROLL_CRIT"));

                oConsole.value += ((oConsole.value.length > 0) ? "\n\n\n" : "");
                oConsole.value += LOCALIZED_MAP.get("IDD_ROLL_SERVER") + "\n";
                oConsole.value += "-----------------------------\n";
                oConsole.value += LOCALIZED_MAP.get("IDD_ROLL_TIME") + ": " + oDate.getHours();
                oConsole.value += ":" + oDate.getMinutes();
                oConsole.value += ":" + oDate.getSeconds();
                oConsole.value += " " + oDate.getDay();
                oConsole.value += "/" + (oDate.getMonth() + 1).toString().padStart(2, '0');
                oConsole.value += "/" + oDate.getFullYear() + "\n";
                oConsole.value += LOCALIZED_MAP.get("IDD_ROLL_INTENTION") + ": " + sIntention + "\n";
                oConsole.value += "-----------------------------\n";
                oConsole.value += sResult;
            }
            else
            {
                oConsole.value += ((oConsole.value.length > 0) ? "\n\n" : "") + "Malformed Request or GM's server not found.";
            }

            oConsole.scrollTop = oConsole.scrollHeight;
        }
        catch (error)
        {
            oConsole.value += ((oConsole.value.length > 0) ? "\n\n" : "") + "Malformed Request or GM's server not found.";

            oConsole.scrollTop = oConsole.scrollHeight;
        }
        finally
        {
            oTarget.disabled = false;
            oConnect.disabled = false;
        }
    }

    static async Connect()
    {
        if (Dice.#_bConnected === false)
        {
            await Dice.#Connect();
        }
        else
        {
            Dice.#Disconnect();
        }

        const oConsole = document.getElementById('IDC_TEXTAREA_CONSOLE');
        if (oConsole.value.length > Dice.#_iConsoleLimit)
        {
            oConsole.value = oConsole.value.slice(oConsole.value.length - Dice.#_iConsoleLimit);
        }
    }

    static async Roll()
    {
        if (Dice.#_bDiceLocked === true) return;
        Dice.#_bDiceLocked = true;

        if (Dice.#_bConnected === false)
        {
            Dice.#RollLocal();
        }
        else
        {
            await Dice.#RollServer();
        }

        Dice.#_bDiceLocked = false;

        const oConsole = document.getElementById('IDC_TEXTAREA_CONSOLE');
        if (oConsole.value.length > Dice.#_iConsoleLimit)
        {
            oConsole.value = oConsole.value.slice(oConsole.value.length - Dice.#_iConsoleLimit);
        }
    }
}