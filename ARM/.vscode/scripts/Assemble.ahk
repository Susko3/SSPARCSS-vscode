#Requires AutoHotkey v2.0-beta
#SingleInstance Force
#Warn All, MsgBox

#Include SSPARCSS.ahk


Assemble.Main(A_Args)


class Assemble
{
    static CurrentAssemblyFile_Filename := EnvGet("temp") "\CurrentAssemblyFile.txt"

    static Main(args)
    {
        if (!this.TryAssemble(args[1], args[2]))
        {
            this.CurrentAssemblyFile := ""
        }

        this.WaitForClose()
        ExitApp()
    }

    static WaitForClose()
    {
        while true
        {
            WinWaitClose(SSPARCSS.Simulator.WindowName, , 60 * 10)
            Sleep(1000)
            if (!WinExist(SSPARCSS.Simulator.WindowName))
                return
        }
    }

    /**
     * The last `.a` file that was opened in the Simulator.
     */
    static CurrentAssemblyFile
    {
        get
        {
            if FileExist(this.CurrentAssemblyFile_Filename)
                return FileRead(this.CurrentAssemblyFile_Filename)

            this.CurrentAssemblyFile := ""
            return ""

        }

        set
        {
            if (FileExist(this.CurrentAssemblyFile_Filename))
                FileDelete(this.CurrentAssemblyFile_Filename)
            FileAppend(value, this.CurrentAssemblyFile_Filename)
        }
    }


    static TryAssemble(dotSystemSearchDirectory, assemblyFile)
    {
        SplitPath assemblyFile, , , &extension

        if (extension != "a")
        {
            MsgBox("Proveded file is not '.a' assembly file.`nSelect an assembly file and try again.`n`nProveded file:`n  " assemblyFile, "Error!")
            return false
        }

        if !WinExist(SSPARCSS.Simulator.WindowName)
        {
            loop files dotSystemSearchDirectory "\*.system"    ; find all system files
            {
                Run(A_LoopFileFullPath, , "Max")
                WinWaitActive(SSPARCSS.Simulator.WindowName)
                this.CurrentAssemblyFile := ""
                break
            }
            else
            {
                MsgBox "SSPARCSS simulator window is not open, and can't find a '.system' file in `"" dotSystemSearchDirectory '"'
                return false
            }
        }

        ; close any stale assmebler windows
        if !SSPARCSS.Assembler.TryClose()
            return false

        ; activate main window
        WinActivate(SSPARCSS.Simulator.WindowName)

        if this.CurrentAssemblyFile != assemblyFile
        {
            ; the file open in the SSPARCSS assembler has changed, need to open it
            if !SSPARCSS.Simulator.OpenFileAndAssemble(assemblyFile)
                return false

            this.CurrentAssemblyFile := assemblyFile
        }
        else
        {
            ; just open and close the active file to asssemble and reload it.
            SSPARCSS.Simulator.EditAndAssemble()
        }

        return true
    }
}
