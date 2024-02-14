const fileName = "IniFile.ini";
const content = 
`
[Person]

iName = Max Mustermann
iAge = 99
iMoney = 0.0


[Spell]

iName = Flamestrike
iDamage = 5
iMana = 4
`;

const blob = new Blob([content], { type: 'text/plain' });
const iniFile = new File([blob], fileName, { type: blob.type });

QUnit.module('IniParser', hooks =>
{
    QUnit.test('Line Seperator', assert =>
    {
        var parser = new IniParser();
        
        assert.strictEqual(parser.GetLineSeperator(), ',', "Line Seperator should be: ,");
        assert.true(parser.SetLineSeperator(':'), "Parser should return true");
        assert.strictEqual(parser.GetLineSeperator(), ':', "Line Seperator should be: :");
    });

    QUnit.test('File Extension', assert =>
    {
        var parser = new IniParser();
        
        assert.strictEqual(parser.GetFileExtension(), "ini", "File Extension should be: ini");
        assert.true(parser.SetFileExtension("test"), "Parser should return true");
        assert.strictEqual(parser.GetFileExtension(), "test", "File Extension should be: test");
    });

    QUnit.test('Header Mode', assert =>
    {
        var parser = new IniParser();
        
        assert.true(parser.GetHeaderMode(), "Parser should return true");
        assert.true(parser.SetHeaderMode(false), "Parser should return true");
        assert.false(parser.GetHeaderMode(), "Parser should return false");
    });

    QUnit.test('Comment Declarator', assert =>
    {
        var parser = new IniParser();
        
        assert.strictEqual(parser.GetCommentDeclarator(), ';', "Comment Declarator should be: ;");
        assert.true(parser.SetCommentDeclarator('*'), "Parser should return true");
        assert.strictEqual(parser.GetCommentDeclarator(), '*', "Comment Declarator should be: *");
    });

    QUnit.test('Error Value String', assert =>
    {
        var parser = new IniParser();
        
        assert.strictEqual(parser.GetErrorValueString(), "", "Error Value String should be: ");
        assert.true(parser.SetErrorValueString("null"), "Parser should return true");
        assert.strictEqual(parser.GetErrorValueString(), "null", "Error Value String should be: null");
    });

    QUnit.test('Error Value Int', assert =>
    {
        var parser = new IniParser();
        
        assert.strictEqual(parser.GetErrorValueInt(), 0, "Error Value Int should be: 0");
        assert.true(parser.SetErrorValueInt(-1), "Parser should return true");
        assert.strictEqual(parser.GetErrorValueInt(), -1, "Error Value Int should be: -1");
    });

    QUnit.test('Error Value Float', assert =>
    {
        var parser = new IniParser();
        
        assert.strictEqual(parser.GetErrorValueFloat(), 0.0, "Error Value Float should be: 0.0");
        assert.true(parser.SetErrorValueFloat(-1.1), "Parser should return true");
        assert.strictEqual(parser.GetErrorValueFloat(), -1.1, "Error Value Float should be: -1.1");
    });

    QUnit.test('Error Value Char', assert =>
    {
        var parser = new IniParser();
        
        assert.strictEqual(parser.GetErrorValueChar(), '\0', "Error Value Char should be: \0(null terminator)");
        assert.true(parser.SetErrorValueChar('c'), "Parser should return true");
        assert.strictEqual(parser.GetErrorValueChar(), 'c', "Error Value Char should be: c");
    });

    QUnit.test('Error Value Bool', assert =>
    {
        var parser = new IniParser();
        
        assert.false(parser.GetErrorValueBool(), "Parser should return false");
        assert.true(parser.SetErrorValueBool(true), "Parser should return true");
        assert.true(parser.GetErrorValueBool(), "Parser should return true");
    });

    QUnit.test('Read File', async assert =>
    {
        var parser = new IniParser();
        
        var result = await parser.ReadFromFile(iniFile);

        assert.true(result, "If IniParser was able to Read");
    });

    QUnit.test('Jump To Headers', async assert =>
    {
        var parser = new IniParser();
        
        assert.true(await parser.ReadFromFile(iniFile), "If IniParser was able to Read");
        assert.true(parser.JumpToHeader("Spell"), "Parser should find Header: Spell");
        assert.false(parser.JumpToHeader("INVALID"), "Parser should find Header: INVALID");
    });

    /*
    GetNextHeader
    GetPreviousHeader
    GetHeaderIndex
    GetHeaderValue
    insertHeaderAt
    pushBackHeader
    deleteHeaderAt
    deleteCurrentHeader
    JumpToLine  
    */
});