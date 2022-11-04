#Requires AutoHotkey v2.0-beta

global games := ["default", "Last Epoch"]
global filename := "buttons.ini"
global hot1 := ""
global section := 1
global inputValues := []
global win := gui()

onBtnLoad()

~RButton::autoHotkeys()
~LButton::autoHotkeys()

return

autoHotkeys()
{
	title := games[section]
	winId := WinActive(title)
	if (!winId)
		return
	
	Loop inputValues.Length {
		value := inputValues[A_Index]
		try {
			Send "{" . value . "}"
			Sleep 50
		}
	}
}

renderWindow()
{		

	win.Destroy()
	
	global win := gui()
	
	win.add("Text", "section y10", "Hotkeys")	
	inputs := []
	Loop inputValues.Length
	{
		idx := A_Index
		win.add("Text",, "Hotkey Button #" . idx)
		ctrl := win.add("Hotkey", "", inputValues[idx])
		inputs.push(ctrl)
		ctrl.OnEvent("Change", (obj, info) => onInputChange(inputs))
	}
	btnAdd := win.add("Button",, "Add Hotkey")
	btnRm := win.add("Button",, "Remove Hotkey")
	
	win.add("Text", "y10 section", "General")
	win.add("Text",, "Game")
	ctrlSection := win.add("ComboBox",, games)
	ctrlSection.Value := section
	ctrlSection.OnEvent("Change", (obj, info) => onChangeSection(obj))
	
	win.add("Text", "x300 y200 section", "")
	btnSave := win.add("Button", "", "Save")
	
	btnAdd.OnEvent("Click", (*) => onBtnAdd())
	btnRm.OnEvent("Click", (*) => onBtnRemove())
	btnSave.OnEvent("Click", (*) => onBtnSave())
	
	win.show()
}

onChangeSection(obj)
{
	global section := obj.Value
	onBtnLoad()
}

onInputChange(inputs)
{
	Loop inputs.Length
	{
		inputValues[A_Index] := inputs[A_Index].Value
	}
}

onBtnRemove()
{
	removeKey("input_" . inputValues.Length)
	inputValues.pop()
	renderWindow()
}

onBtnAdd() 
{
	inputValues.Push("None")
	renderWindow()
}

saveKeyValue(key, value)
{
	IniWrite(value, filename, section, key)
}

removeKey(key)
{
	IniDelete(filename, section, key)
}

loadKeyValue(key)
{
	ovl := IniRead(filename, section, key)
	return ovl
}

onBtnSave()
{
	Loop inputValues.Length
	{
		saveKeyValue("input_" . A_Index, inputValues[A_Index])
	}
}

onBtnLoad()
{	
	global inputValues := []
	Loop {
		try {
			value := loadKeyValue("input_" . A_Index)
			has := inputValues.has(A_Index)
			if (!has) {
				inputValues.push(value)
			}
			inputValues[A_Index] := value
		} catch {
			break
		}
	}
	 
	renderWindow()
}
