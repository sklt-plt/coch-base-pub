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

extends BasePowerup

func activate():
	.activate()
	$"/root/Player".upgrade_resource("ammo_bonus_cap", 5)

	$"/root/Player".give("r_pistol_ammo", 5)
	$"/root/Player".give("r_shotgun_ammo", 5)
	$"/root/Player".give("r_crossbow_ammo", 5)

	.playSfx()

	self.queue_free()
