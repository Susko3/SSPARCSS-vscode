#Requires AutoHotkey v2.0-beta
SetDefaultMouseSpeed(0)


#HotIf WinActive(SSPARCSS.Simulator.WindowName)
e:: SSPARCSS.Simulator.Reload()
^e:: SSPARCSS.Simulator.EditAndAssemble()
^r:: SSPARCSS.Simulator.Reload()
r:: SSPARCSS.Simulator.RunOrReload()
space:: SSPARCSS.Simulator.Pause()
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
        static PauseTimeout := 100    ; in MS
        ;
        static RunButtonEnabled()
        {
            if (A_ComputerName == "THINKPAD-E15")
            {
                x := 305
                y := 100
                color := 0x6C6C6C
            }
            else
            {
                x := 304
                y := 102
                color := 0x696969
            }

            return PixelGetColor(x, y) != color
        }

        static PauseButtonEnabled()
        {
            if (A_ComputerName == "THINKPAD-E15")
            {
                x := 360
                y := 101
                color := 0x171717
            }
            else
            {
                x := 336
                y := 99
                color := 0x171717
            }

            pixClr := PixelGetColor(x, y)

            val := (pixClr == color)
            ; ToolTip "PauseButtonEnabled: " val " pix:" pixClr " color:" color

            return val
        }

        static Ready => this.State == 0
        static Running => this.State == 1
        static Stopped => this.State == 2

        ; 0 = Ready, Paused
        ; 1 = Running
        ; 2 = Stopped
        static State
        {
            get
            {
                running := this.RunButtonEnabled()
                paused := this.PauseButtonEnabled()

                if running and not paused
                    return 0

                if ( not running) and paused
                    return 1

                return 2
            }
        }

        static ClickElement(x, y)
        {
            previous_x := 0
            previous_y := 0
            MouseGetPos(&previous_x, &previous_y)
            Click(x " " y)
            MouseMove(previous_x, previous_y)
        }

        static Open()
        {
            this.Pause()
            this.ClickElement(79, 102)
        }

        static Edit()
        {
            this.Pause()
            this.ClickElement(127, 100)
        }

        static Reload()
        {
            this.Pause()
            this.ClickElement(233, 109)
        }

        static Run() => this.ClickElement(286, 96)
        static Pause()
        {
            this.ClickElement(337, 108)
        }
        ;
        static RunOrReload()
        {
            switch this.State
            {
                case 0: ; ready
                    this.Run()
                case 1: ; running
                    this.Pause()
                case 2: ; stopped
                    this.Reload()
            }
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
