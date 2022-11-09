#Requires AutoHotkey v2.0-beta
SetDefaultMouseSpeed(0)


#HotIf WinActive(SSPARCSS.Simulator.WindowName)
e:: SSPARCSS.Simulator.Edit()
^e:: SSPARCSS.Simulator.EditAndAssemble()
^r:: SSPARCSS.Simulator.Reload()
r:: SSPARCSS.Simulator.RunOrReload()
#HotIf


#HotIf WinActive(SSPARCSS.Assembler.WindowName)
F1::
F5::
^e::
{
    SSPARCSS.Assembler.TryAssembleAndExit()
}
#HotIf


class SSPARCSS
{
    ; Default timout for `WinWaitActive` (in seconds)
    static DefaultTimeout := 3

    class Simulator
    {
        static WindowName := "ahk_exe simulator.exe ahk_class Qt5QWindowIcon"


        static ClickElement(x, y)
        {
            previous_x := 0
            previous_y := 0
            MouseGetPos(&previous_x, &previous_y)
            Click(x " " y)
            MouseMove(previous_x, previous_y)
        }

        static Open() => this.ClickElement(79, 102)
        static Edit() => this.ClickElement(127, 100)
        static Reload() => this.ClickElement(233, 109)
        static Run() => this.ClickElement(286, 96)
        ;
        static RunOrReload()
        {
            if (false)
            {
                x := 304
                y := 102
                color := 0x696969
            }
            else
            {
                x := 287
                y := 98
                color := 0x6C6C6C
            }

            if PixelGetColor(x, y) == color    ; if run button disabled
            {
                this.Reload()
            }
            else
                this.Run()
        }

        static EditAndAssemble()
        {
            this.Edit()

            if !SSPARCSS.Assembler.TryAssembleAndExit()
                ; assmebly failed
                return false

            if !WinWaitActive(this.WindowName, , SSPARCSS.DefaultTimeout)
            {
                MsgBox("SSPARCSS.Simulator.EditAndAssemble: Timed out while waiting for simulator to be active.")
                return false
            }

            return true
        }

        static OpenFileAndAssemble(file)
        {
            this.Open()

            if !WinWaitActive("ahk_class #32770 ahk_exe simulator.exe", , SSPARCSS.DefaultTimeout)
            {
                MsgBox("SSPARCSS.Simulator.OpenFileAndAssemble: Timed out while waiting for simulator file picker to be active.")
                return false
            }

            Send(file)
            Send("{Enter}")
            return SSPARCSS.Assembler.TryAssembleAndExit()
        }
    }

    class Assembler
    {
        static WindowName := "ahk_exe assembler.exe ahk_class Qt5QWindowIcon"

        /**
         * Waits for the assembler to open and then assembles.
         * 
         * @returns `true` if the assembly was successful.
         */
        static TryAssembleAndExit()
        {
            if !WinWaitActive(this.WindowName, , SSPARCSS.DefaultTimeout)
            {
                MsgBox("SSPARCSS.Assembler.TryAssembleAndExit: Timed out while waiting for assembler to get focus.")
                return false
            }

            Send("^+r")

            if (WinWaitClose(this.WindowName, , SSPARCSS.DefaultTimeout))
                return true
            else
                ; assembling failed (due to an error in the user's code)
                return false
        }

        /**
         * Ensures that the assembler.exe window is closed.
         * 
         * @returns `true` if the window was/is closed
         */
        static TryClose()
        {
            if !WinExist(this.WindowName)
                return true

            WinClose(SSPARCSS.Assembler.WindowName)

            if WinWaitClose(SSPARCSS.Assembler.WindowName, , SSPARCSS.DefaultTimeout)
                return true

            WinActivate(this.WindowName)
            return false
        }
    }
}
