Include("sqlite3.js");

class Player
{
    static #g_init = false;
    static #g_SQLite3Module = null;
    static #g_SQLite3ApiLow = null;
    static #g_SQLite3ApiHigh = null;

    #m_db = null;

    static async Initialize()
    {
        if (Player.#g_init === true) return Promise.resolve(null);
        Player.#g_init = true;

        return sqlite3InitModule().then((sqlite3) =>
        {
            Player.#g_SQLite3Module = sqlite3;
            Player.#g_SQLite3ApiLow = Player.#g_SQLite3Module.capi;
            Player.#g_SQLite3ApiHigh = Player.#g_SQLite3Module.oo1;
        });
    }

    constructor(sFileName)
    {
        this.#m_db = new Player.#g_SQLite3ApiHigh.DB(((TypeCheck.String(sFileName) === true) ? sFileName : "Database.sqlite3"), 'ct');
    }
}