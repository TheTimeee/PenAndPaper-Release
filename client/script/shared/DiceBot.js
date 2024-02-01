//This is a shared file between Browser and Dice Server.
//Under Server: Every static will have function appended.
//Under Server: Every instance of "let" followed by ' ' will be replaced by "var".

class DiceBot
{
    static Random(iMin, iMax)
    {
        return Math.floor(Math.random() * (iMax - iMin + 1)) + iMin;
    }

    static Roll(sName, sIntention, iDice, iCycles, iSignet, sResults, iSuccess, iFailure, iSum, iCritFailure, bEwHaja)
    {
        let iMaxDice = 40;
        let iMaxCycles = 50;

        if (iDice < 1) iDice = 0;
        if (iCycles < 1) iCycles = 1;

        for (let iCycle = 0; iCycle < ((iCycles <= iMaxCycles) ? iCycles : iMaxCycles); iCycle++)
        {
            //Roll primary die
            let iPrimary = DiceBot.Random(1, 6);
            sResults += iPrimary;
            iSum += iPrimary;

            //Determine primary die
            if (iPrimary >= ((iDice > 0) ? 4 : 6))
            {
                sResults += "[✓]";
                iSuccess++;
            }
            else
            {
                sResults += "[X]";
                iFailure++;
            }

            //Respect Signet 1, EwHajas Signet and overflowing dice into iRerolls
            let iRerolls = ((iSignet >= 1) ? ((bEwHaja == true) ? ((iDice >= 5) ? 1 : 0) : Math.floor(iDice / 5)) : 0);
            iRerolls += ((iDice > iMaxDice) ? iDice - iMaxDice : 0);

            //Roll secondary dice
            for (let iDie = 1; iDie < ((iDice <= iMaxDice) ? iDice : iMaxDice); iDie++)
            {
                let iSecondary = DiceBot.Random(1, 6);
                sResults += ", " + iSecondary;

                if (iSecondary >= ((iSignet >= 3) ? 5 : 6)) //Respect Signet 3
                {
                    sResults += "[✓]";
                    iSuccess++;
                }
                else
                {
                    if (iRerolls > 0)
                    {
                        iRerolls--;

                        iSecondary = DiceBot.Random(1, 6);
                        sResults += "(" + iSecondary + ")";

                        if (iSecondary >= ((iSignet >= 3) ? 5 : 6)) //Respect Signet 3 
                        {
                            sResults += "[✓]";
                            iSuccess++;
                        }
                        else
                        {
                            sResults += "[X]";
                            iFailure++;
                        }
                    }
                    else
                    {
                        sResults += "[X]";
                        iFailure++;
                    }
                }

                iSum += iSecondary;
            }

            //Set if it is a critical failure
            if (iSuccess <= 0)
            {
                if (iPrimary <= ((iDice > 0) ? 1 : 2))
                {
                    iCritFailure++;
                }
            }
        }

        return [sName, sIntention, iDice, iCycles, iSignet, ((iCycles <= 1) ? sResults : "Multi Roll"), iSuccess, iFailure, iSum, iCritFailure, (bEwHaja == true)];
    }
}