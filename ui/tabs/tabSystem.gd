extends Control

## Represents a controlling brain for tabs.
class_name TabSystem

## Iternal struct for convinient storing tab info.
class UiTabStruct:
	
	## Main tab.
	var tab: BasicTab
	
	## Ui item icon in top bar icons.
	var handle: TabHandle
	
	func _init(tab: BasicTab, handle: TabHandle) -> void:
		self.tab = tab
		self.handle = handle
		
## Array of tabs.
var _tabs: Array[UiTabStruct] = []

## Ui container for tabs.
@onready var _ui_tabs: Control = $"MarginContainer/PanelContainer/TabsIconsContainer/MarginContainer"

## Currently opened tab, may be null if we dont have any tabs in array.
var _selected_tab: UiTabStruct

## Label which displays current tab name.
@onready var _label: Label = $"MarginContainer/PanelContainer/label"

## Main tab ui, which displays currently opened tab.
@onready var _main_ui: Control = $"MarginContainer/PanelContainer/MainTabUi"

## Constructor
func _ready() -> void:
	pass

## Inserts a new tab and switches focus to it, if reuqired.
func insert_tab(tab: BasicTab, focused: bool = false) -> void:
	var struct := UiTabStruct.new(
		tab,
		_create_handle(tab)
	)
	_tabs.append(struct)
	struct.handle.clicked.connect(func x() -> void:
		_set_selected_tab(struct)	
	)
	if focused:
		_set_selected_tab(struct)

## Removes a tab from tabs.
func remove_tab(tab: BasicTab) -> void:
	var struct: UiTabStruct = null
	for i: int in range(len(tab)):
		struct = _tabs.pop_at(i)
		break
	_ui_tabs.remove_child(struct.handle)
	
	if _selected_tab == tab:
		if _tabs.size() != 0:
			_set_selected_tab(_tabs[0])
		else:
			_set_selected_tab(null)
			
	struct.handle.queue_free()

## Selects current tab while hiding previous one.		
func _set_selected_tab(tab: UiTabStruct = null) -> void:
	if _selected_tab != null:
		_main_ui.remove_child(_selected_tab.tab.get_ui())
		_label.hide()
		_selected_tab.handle.set_higlighted(false)
	if tab != null:
		_main_ui.add_child(tab.tab.get_ui())
		_label.text = tab.tab.get_tab_name()
		_label.show()
		tab.handle.set_higlighted(true)
	_selected_tab = tab

## Creates handle for given tab.
func _create_handle(tab: BasicTab) -> TabHandle:
	var node: TabHandle = preload("res://ui/tabs/tabHandle.tscn").instantiate()
	_ui_tabs.add_child(node)
	node.set_icon(tab.get_icon())
	return node
