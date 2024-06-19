#    Copyright (C) 2024 Jakub Miksa
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Lesser General Public License as published by
#    the Free Software Foundation, version 3 of the License.
#
#    This prograsm is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Lesser General Public License for more details.
#
#    You should have received a copy of the GNU Lesser General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.

extends Control

var guns = []
export (Array, Texture) var gun_icons = []
export (Array, Texture) var gun_icons_inactive = []

func _ready():
	for c in get_children():
		if c is Control:
			guns.push_back(c)

	gun_icons.resize(guns.size())
	gun_icons_inactive.resize(guns.size())
	hide_guns()

func show_guns(var active_gun_idx: int):
	$Timer.start()
	self.visible = true

	# check if we should enable icon
	$DoubleBarrel.visible = $"/root/Player".has("e_double_barrel_level", 1)
	$Gun3.visible = $"/root/Player".has("e_crossbow_level", 1)

	# set all to inactive
	for i in range (0, guns.size()):
		guns[i].get_node("Icon").texture = gun_icons_inactive[i]

	# set just selected to active
	guns[active_gun_idx].get_node("Icon").texture = gun_icons[active_gun_idx]

func hide_guns():
	self.visible = false
