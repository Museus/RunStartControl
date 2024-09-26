
RunStartControl.PrePactConfigMenuToggle = nil
RunStartControl.HammerPreference = nil
RunStartControl.GodPreference = nil
RunStartControl.SlotPreference = nil

function CreatePrePactConfigMenu()
  local components = {};

  local screen = {
      Components = components,
      MenuComponents = {},
      CloseAnimation  = "QuestLogBackground_Out"
    }
  OnScreenOpened({ Flag = screen.Name, PersistCombatUI = true})
  FreezePlayerUnit()
  EnableShopGamepadCursor()
  SetConfigOption({ Name = "FreeFormSelectWrapY", Value = false })
  SetConfigOption({ Name = "FreeFormSelectStepDistance", Value = 8 })

  components.ShopBackgroundDim = CreateScreenComponent({ Name = "rectangle01", Group = "Combat_Menu"})
  components.ShopBackgroundSplatter = CreateScreenComponent({ Name = "LevelUpBackground", Group = "Combat_Menu"})
  components.ShopBackground = CreateScreenComponent({ Name = "rectangle01", Group = "Combat_Menu"})

  SetAnimation({ DestinationId = components.ShopBackground.Id, Name = "QuestLogBackgroun_In", OffsetY = 30 })

  SetScale({ Id = components.ShopBackgroundDim.Id, Fraction = 4})
  SetColor({ Id = components.ShopBackgroundDim.Id, Color = { 0.090, 0.055, 0.157, 0.8 } })

  PlaySound({ Name = "/SFX/Menu Sounds/FatedListOpen" })

  wait(0.2)

  -- Title
  CreateTextBox({ Id = components.ShopBackground.Id, Text = "SELECT YOUR FIRST REWARD", FontSize = 37, OffsetX = 0, OffsetY = -460,
  Color = Color.White, Font = "SpectralSCLightTitling", ShadowBlur = 0, ShadowColor = { 0, 0, 0, 1 }, ShadowOffset = { 0, 2 },
  Justification = "Center" })

  -- Hammer / Boon toggle buttons
  screen.Components["HammerButton"] = CreateScreenComponent({
    Name = "ButtonDefault",
    Scale = 1.1,
    Group = "Combat_Menu",
    X = 770,
    Y = 200})   
  screen.Components["HammerButton"].OnPressedFunctionName = "ToggleSelectionScreen"
  screen.Components["HammerButton"].args = {
    SwitchTo = "hammer"
  }
  CreateTextBox({ Id = screen.Components["HammerButton"].Id,
      Text = "Hammer",
      OffsetX = 0, OffsetY = 0,
      FontSize = 25,
      Color = Color.White,
      Font = "AlegreyaSansSCRegular",
      ShadowBlur = 0, ShadowColor = {0,0,0,1}, ShadowOffset={0, 2},
      Justification = "Center",
      DataProperties =
      {
      OpacityWithOwner = true,
      },
  })
  Attach({ Id = screen.Components["HammerButton"].Id, DestinationId = screen.Components["HammerButton"], OffsetX = 500, OffsetY = 500 })

  screen.Components["BoonButton"] = CreateScreenComponent({
    Name = "ButtonDefault",
    Scale = 1.1,
    Group = "Combat_Menu",
    X = 1150,
    Y = 200})
  screen.Components["BoonButton"].OnPressedFunctionName = "ToggleSelectionScreen"
  screen.Components["BoonButton"].args = {
    SwitchTo = "boon"
  }
  CreateTextBox({ Id = screen.Components["BoonButton"].Id,
      Text = "Olympian Boon",
      OffsetX = 0, OffsetY = 0,
      FontSize = 25,
      Color = Color.White,
      Font = "AlegreyaSansSCRegular",
      ShadowBlur = 0, ShadowColor = {0,0,0,1}, ShadowOffset={0, 2},
      Justification = "Center",
      DataProperties =
      {
      OpacityWithOwner = true,
      },
  })
  Attach({ Id = screen.Components["BoonButton"].Id, DestinationId = screen.Components["BoonButton"], OffsetX = 500, OffsetY = 500 })

  -- Aspect Image
  local weaponAspectData = RunStartControl.GetEquippedWeaponAspect()
  local aspectX = 500
  local aspectY = 500
  screen.Components["AspectIcon"] = CreateScreenComponent({ Name = "BlankObstacle", Scale = 2.0, Group = "Combat_Menu", X = aspectX, Y = aspectY })
  local aspectIcon = TraitData[weaponAspectData.Aspect].Icon .. "_Large"
  SetAnimation({ DestinationId = screen.Components["AspectIcon"].Id, Name = aspectIcon})

  -- Aspect Text Box
  screen.Components["AspectName"] = CreateScreenComponent({ Name = "BlankObstacle", Scale = 0.5, Group = "Combat_Menu", X = aspectX, Y = aspectY + 200})
  CreateTextBox({ Id = screen.Components["AspectName"].Id,
      Text = weaponAspectData.Aspect,
      OffsetX = 0,
      OffsetY = 0,
      FontSize = 36,
      Color = Color.White,
      Font = "AlegreyaSansSCRegular",
      ShadowBlur = 0,
      ShadowColor = {0,0,0,1},
      ShadowOffset={0, 2},
      Justification = "Center",
      DataProperties = {
        OpacityWithOwner = true,
      },
    })

  -- Confirm button
  screen.Components["ConfirmButton"] = CreateScreenComponent({
      Name = "ButtonDefault",
      Scale = 1.1,
      Group = "Combat_Menu",
      X = 1050,
      Y = 1000})   
  screen.Components["ConfirmButton"].OnPressedFunctionName = "ConfirmSelection"
  CreateTextBox({ Id = screen.Components["ConfirmButton"].Id,
      Text = "Confirm",
      OffsetX = 0, OffsetY = 0,
      FontSize = 26,
      Color = Color.White,
      Font = "AlegreyaSansSCRegular",
      ShadowBlur = 0, ShadowColor = {0,0,0,1}, ShadowOffset={0, 2},
      Justification = "Center",
      DataProperties =
      {
        OpacityWithOwner = true,
      },
    })
  Attach({ Id = screen.Components["ConfirmButton"].Id, DestinationId = screen.Components["ConfirmButton"], OffsetX = 500, OffsetY = 500 })

  -- Close Button
  screen.Components["CloseButton"] = CreateScreenComponent({ Name = "ButtonClose", Scale = 1.0, Group = "Combat_Menu", X=800, Y=1000})
  Attach({ Id = screen.Components["CloseButton"], DestinationId = screen.Components["ShopBackground"].Id, OffsetX = 500, OffsetY = 500 })
  screen.Components["CloseButton"].OnPressedFunctionName = "ExitPrePactConfigMenu"
  screen.Components["CloseButton"].ControlHotkey = "Cancel"
  screen.Components["CloseButton"].args = {
    MoveOn = false
  }

  screen.KeepOpen = true
  thread( HandleWASDInput, screen )
  HandleScreenInput( screen )
end

function CreateHammerSelectionScreen( screen )
    -- Hammer Picker
    local weaponAspectData = RunStartControl.GetEquippedWeaponAspect()

    local xpos = 1300
    local ypos = 720

    screen.Components["HammerLeft"] = CreateScreenComponent({ Name = "ButtonCodexDown", X = xpos - 250, Y = ypos, Scale = 1.0, Group = "Combat_Menu"})
    SetAngle({ Id = screen.Components["HammerLeft"].Id, Angle = -90})
    SetScale({ Id = screen.Components["HammerLeft"].Id, Fraction = 1.0})
    screen.Components["HammerLeft"].OnPressedFunctionName = "HammerLeft"

    screen.Components["HammerRight"] = CreateScreenComponent({ Name = "ButtonCodexDown", X = xpos + 250, Y = ypos, Scale = 1.0, Group = "Combat_Menu"})
    SetAngle({ Id = screen.Components["HammerRight"].Id, Angle = 90})
    SetScale({ Id = screen.Components["HammerRight"].Id, Fraction = 1.0})
    screen.Components["HammerRight"].OnPressedFunctionName = "HammerRight"

    screen.Components["CurrentHammer"] = CreateScreenComponent({ Name = "BlankObstacle", Scale = 1.0, Group = "Combat_Menu", X = xpos, Y = ypos})

    -- hammer text box
    local aspectHammers = RunStartControl.HammerOptions[weaponAspectData.Aspect]
    local hammerSetting = RunStartControl.DefaultHammerSettings[weaponAspectData.Aspect]

    for i, hammer in ipairs(aspectHammers) do
        if hammer == RunStartControl.HammerPreference then
            hammerSetting = hammer
            break
        end
    end

    RunStartControl.HammerPreference = hammerSetting


    CreateTextBox({ Id = screen.Components["CurrentHammer"].Id,
      Text = RunStartControl.HammerPreference,
      OffsetX = 0,
      OffsetY = 0,
      FontSize = 32,
      Color = Color.White,
      Font = "AlegreyaSansSCRegular",
      ShadowBlur = 0,
      ShadowColor = {0,0,0,1},
      ShadowOffset={0, 2},
      Justification = "Center",
      DataProperties = {
        OpacityWithOwner = true,
      },
    })

    screen.Components["HammerIcon"] = CreateScreenComponent({ Name = "BlankObstacle", Scale = 1.9, Group = "Combat_Menu", X = xpos, Y = ypos - 250 })
    local hammerIcon = TraitData[RunStartControl.HammerPreference].Icon .. "_Large"
    SetAnimation({ DestinationId = screen.Components["HammerIcon"].Id, Name = hammerIcon})


end

function HideHammerSelectionScreen( screen )
  local ids = {}
  local hammerComponentNames = {
    "HammerLeft", "HammerRight", "CurrentHammer","HammerIcon"
  }
  for i, hammerComponentName in ipairs(hammerComponentNames) do
    if screen.Components[hammerComponentName] then
      table.insert(ids, screen.Components[hammerComponentName].Id)
      screen.Components[hammerComponentName] = nil
    end
  end
  CloseScreen(ids)
end

function CreateBoonSelectionScreen( screen )
  RunStartControl.GodPreference = RunStartControl.HeroForcingGod() or RunStartControl.GodPreference or "Zeus"
  RunStartControl.SlotPreference = RunStartControl.SlotPreference or "Attack"

  -- God Icon
  screen.Components["GodIcon"] = CreateScreenComponent({ Name = "BlankObstacle", Scale = 2.5, Group = "Combat_Menu", X = 1320, Y = 250 })
  Attach({ Id = screen.Components["GodIcon"].Id, DestinationId = screen.Components.ShopBackground.Id, OffsetX = 450, OffsetY = -220})
  SetAnimation({ Name = "BoonSymbol" .. RunStartControl.GodPreference .. "Isometric", DestinationId = screen.Components.GodIcon.Id, Scale = 1.0})

  screen.Components["FailedGodSwitch"] = CreateScreenComponent({ Name = "BlankObstacle", Scale = 1.0, Group = "Combat_Menu", X = 1390, Y = 435})
  CreateTextBox({ Id = screen.Components["FailedGodSwitch"].Id,
  Text = "",
  OffsetX = 0, OffsetY = 0,
  FontSize = 24,
  Color = Color.BoonPatchCommon,
  Font = "AlegreyaSansSCRegular",
  ShadowBlur = 0, ShadowColor = {0,0,0,1}, ShadowOffset={0, 2},
  Justification = "Center",
  DataProperties =
  {
    OpacityWithOwner = true,
  },
  })
  -- God buttons
  local x = -375
  local y = 45
  for _, god in pairs(RunStartControl.BoonGods) do
    screen.Components[god .. "Filter"] = CreateScreenComponent({ Name = "ButtonDefault", Scale = 0.75, Group = "Combat_Menu", X = 1440 + x, Y = 450 + y })
    screen.Components[god .. "Filter"].OnPressedFunctionName = "SelectGod"
    screen.Components[god .. "Filter"].args = {God = god}
    CreateTextBox({ Id = screen.Components[god .. "Filter"].Id,
        Text = god,
        OffsetX = 0, OffsetY = 0,
        FontSize = 24,
        Color = Color.BoonPatchCommon,
        Font = "AlegreyaSansSCRegular",
        ShadowBlur = 0, ShadowColor = {0,0,0,1}, ShadowOffset={0, 2},
        Justification = "Center",
        DataProperties =
        {
          OpacityWithOwner = true,
        },
      })

    x = x + 225
    if x > 375 then
      x = -375
      y = y + 75
    end
  end

  ModifyTextBox({ Id = screen.Components[RunStartControl.GodPreference .. "Filter"].Id, Color = Color.Gray})
  local weaponAspectData = RunStartControl.GetEquippedWeaponAspect()
  -- boon icon
  local boon = RunStartControl.CoreBoonReference(RunStartControl.GodPreference, RunStartControl.SlotPreference, weaponAspectData.Aspect)
  screen.Components["BoonIcon"] = CreateScreenComponent({ Name = "BlankObstacle", Scale = 1.3, Group = "Combat_Menu", X = 1400, Y = 715 })
  local boonIcon = TraitData[boon].Icon .. "_Large"
  SetAnimation({ DestinationId = screen.Components["BoonIcon"].Id, Name = boonIcon})


  -- Slot buttons
  x = -375
  y = 225
  for _, priorityBoon in pairs({"Attack", "Special", "Cast", "Dash"}) do
    screen.Components[priorityBoon .. "Filter"] = CreateScreenComponent({ Name = "ButtonDefault", Scale = .75, Group = "Combat_Menu", X = 1440 + x, Y = 645 + y })
    screen.Components[priorityBoon .. "Filter"].OnPressedFunctionName = "SelectBoon"
    screen.Components[priorityBoon .. "Filter"].args = {Boon = priorityBoon}
    CreateTextBox({ Id = screen.Components[priorityBoon .. "Filter"].Id,
        Text = priorityBoon,
        OffsetX = 0, OffsetY = 0,
        FontSize = 24,
        Color = Color.White,
        Font = "AlegreyaSansSCRegular",
        ShadowBlur = 0, ShadowColor = {0,0,0,1}, ShadowOffset={0, 2},
        Justification = "Center",
        DataProperties =
        {
          OpacityWithOwner = true,
        },
      })
    x = x + 225
    if x > 375 then
      x = -375
      y = y + 90
    end
  end
  ModifyTextBox({ Id = screen.Components[RunStartControl.SlotPreference .. "Filter"].Id, Color = Color.Gray})

end

function HideBoonSelectionScreen( screen )
  local ids = {}
  local boonComponentNames = {
    "GodIcon", "ZeusFilter", "AphroditeFilter", "PoseidonFilter", "AresFilter", "AthenaFilter",
    "ArtemisFilter", "DionysusFilter", "DemeterFilter", "AttackFilter", "SpecialFilter",
    "DashFilter", "CastFilter", "FailedGodSwitch", "BoonIcon",
  }
  for i, boonComponentName in ipairs(boonComponentNames) do
    if screen.Components[boonComponentName] then
      table.insert(ids, screen.Components[boonComponentName].Id)
      screen.Components[boonComponentName] = nil
    end
  end
  CloseScreen(ids)
end

function ToggleSelectionScreen( screen, button )
    local switchTo = button.args.SwitchTo
    if switchTo ~= RunStartControl.PrePactConfigMenuToggle then
        if RunStartControl.PrePactConfigMenuToggle == "boon" then
            HideBoonSelectionScreen(screen)
        elseif RunStartControl.PrePactConfigMenuToggle == "hammer" then
            HideHammerSelectionScreen(screen)
        end

        if switchTo == "boon" then
            CreateBoonSelectionScreen(screen)
            RunStartControl.PrePactConfigMenuToggle = "boon"
        elseif switchTo == "hammer" then
            CreateHammerSelectionScreen(screen)
            RunStartControl.PrePactConfigMenuToggle = "hammer"
        end
    end
end

function HammerMove( screen, button, offset )
    local weaponAspectData = RunStartControl.GetEquippedWeaponAspect()
    local aspect = weaponAspectData.Aspect
    local currentHammer = RunStartControl.HammerPreference
    local aspectHammers = RunStartControl.HammerOptions[aspect]

    local hammerIndex = nil
    for i, hammer in ipairs(aspectHammers) do
        if hammer == currentHammer then
            hammerIndex = i
            break
        end
    end
    hammerIndex = hammerIndex + offset

    if hammerIndex <= 0 then
        hammerIndex = TableLength(RunStartControl.HammerOptions[aspect]) + hammerIndex
    elseif hammerIndex > TableLength(RunStartControl.HammerOptions[aspect]) then
        hammerIndex = hammerIndex - TableLength(RunStartControl.HammerOptions[aspect])
    end

    RunStartControl.HammerPreference = RunStartControl.HammerOptions[aspect][hammerIndex]

    ModifyTextBox({ Id = screen.Components["CurrentHammer"].Id, Text = RunStartControl.HammerPreference})
    local hammerIcon = TraitData[RunStartControl.HammerPreference].Icon .. "_Large"
    SetAnimation({ DestinationId = screen.Components["HammerIcon"].Id, Name = hammerIcon})
end

function HammerLeft( screen, button )
    HammerMove(screen, button, -1)
end

function HammerRight( screen, button )
    HammerMove(screen, button, 1)
end

function SelectGod( screen, button )
  local god = button.args.God
  if god ~= RunStartControl.GodPreference then

    if not RunStartControl.HeroForcingGod() then
      ModifyTextBox({ Id = screen.Components[RunStartControl.GodPreference .. "Filter"].Id, Color = Color.BoonPatchCommon})

      RunStartControl.GodPreference = god
      SetAnimation({ Name = "BoonSymbol" .. RunStartControl.GodPreference .. "Isometric", DestinationId = screen.Components.GodIcon.Id})
      ModifyTextBox({ Id = screen.Components[god .. "Filter"].Id, Color = Color.Gray})

      -- boon icon adjustment
      local weaponAspectData = RunStartControl.GetEquippedWeaponAspect()
      local boon = RunStartControl.CoreBoonReference(RunStartControl.GodPreference, RunStartControl.SlotPreference, weaponAspectData.Aspect)
      local boonIcon = TraitData[boon].Icon .. "_Large"
      SetAnimation({ DestinationId = screen.Components["BoonIcon"].Id, Name = boonIcon})
    else
      ModifyTextBox({ Id = screen.Components["FailedGodSwitch"].Id,
      Text = "Cannot seed God when holding God Keepsake!"})
      ModifyTextBox({ Id = screen.Components[RunStartControl.GodPreference .. "Filter"].Id, Color = Color.Red})
    end
  end
end

function SelectBoon( screen, button )
  local boon = button.args.Boon
  if boon ~= RunStartControl.SlotPreference then
    ModifyTextBox({ Id = screen.Components[RunStartControl.SlotPreference .. "Filter"].Id, Color = Color.BoonPatchCommon})

    RunStartControl.SlotPreference = boon
    ModifyTextBox({ Id = screen.Components[boon .. "Filter"].Id, Color = Color.Gray})

    -- boon icon adjustment
    local weaponAspectData = RunStartControl.GetEquippedWeaponAspect()
    local boon = RunStartControl.CoreBoonReference(RunStartControl.GodPreference, RunStartControl.SlotPreference, weaponAspectData.Aspect)
    local boonIcon = TraitData[boon].Icon .. "_Large"
    SetAnimation({ DestinationId = screen.Components["BoonIcon"].Id, Name = boonIcon})
  end
end

function ConfirmSelection( screen, button )
  local weaponAspectData = RunStartControl.GetEquippedWeaponAspect()
  if RunStartControl.PrePactConfigMenuToggle == "boon" then
    RunStartControl.SetStartingRewards(
      nil, nil, nil,
      RunStartControl.GodPreference,
      RunStartControl.CoreBoonReference(RunStartControl.GodPreference, RunStartControl.SlotPreference, weaponAspectData.Aspect),
      "Epic",
      "Boon"
    )
  elseif RunStartControl.PrePactConfigMenuToggle == "hammer" then
    RunStartControl.SetStartingRewards(
      weaponAspectData.Weapon,
      weaponAspectData.Aspect,
      RunStartControl.HammerPreference,
      nil, nil, nil,
      "WeaponUpgrade"
    )
  end
  button.args = {MoveOn = true}
  ExitPrePactConfigMenu(screen, button)
end

function ExitPrePactConfigMenu( screen, button )
  RunStartControl.PrePactConfigMenuToggle = nil
  RunStartControl.HammerPreference = nil
  RunStartControl.GodPreference = nil
  RunStartControl.SlotPreference = nil
  if RunStartControl.PrePactConfigMenuToggle == "hammer" then
    HideHammerSelectionScreen(screen)
  elseif RunStartControl.PrePactConfigMenuToggle == "boon" then
    HideBoonSelectionScreen(screen)
  end
  RunStartControl.PrePactConfigMenuToggle = nil
  DisableShopGamepadCursor()
  SetConfigOption({ Name = "FreeFormSelectWrapY", Value = false })
  SetConfigOption({ Name = "FreeFormSelectStepDistance", Value = 16 })
  SetConfigOption({ Name = "FreeFormSelectSuccessDistanceStep", Value = 8})
  SetAnimation({ DestinationId = screen.Components.ShopBackground.Id, Name = screen.CloseAnimation })
  PlaySound({ Name = "/SFX/Menu Sounds/FatedListClose" })
  CloseScreen( GetAllIds( screen.Components ), 0.1)
  UnfreezePlayerUnit()
  screen.KeepOpen = false
  OnScreenClosed({ Flag = screen.Name })

  RunStartControl.MoveOn = button.args.MoveOn
end

ModUtil.Path.Wrap('UseEscapeDoor', function( baseFunc, ... )
    if RunStartControl.config.Enabled and RunStartControl.config.Menu == "prerun" then
      RunStartControl.ResetStartingRewards()
      CreatePrePactConfigMenu()
    else
      baseFunc( ... )
    end
    if RunStartControl.MoveOn then
        baseFunc( ... )
    end
    RunStartControl.MoveOn = nil
end, RunStartControl)