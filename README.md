# PenAndPaper

Use "Pen and Paper.bat" to start the application.
If you want to individually start either server or client, you can use "start_server.bat" and "start_client.bat".
If one or more file's integrity is violated, you can use "verify_integrity.bat" for more detail.

NOTE:   For performance reasons, the file "verify_integrity.bat" only verifies the integrity of files that might cause harm to your system if tampered with.

Examples include but are not limited to:

- ".bat" files inside server root or executing other files with elevated privileges
- ".ps1" files, which are essentially interpreted versions of C# binaries
- ".js" files, which are used by PowerShell scripts and as such are not strictly executed in a sandboxed environment

ALWAYS start the application using ONLY the following files:

- Pen and Paper.bat
- Dice Server.bat
- start_client.bat
- start_server.bat
- verify_integrity.bat

as these files are designed to ensure integrity of the project files.