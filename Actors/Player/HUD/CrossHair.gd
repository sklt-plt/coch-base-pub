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

extends Node

var top_piece : Spatial
var bottom_piece : Spatial
var left_piece : Spatial
var right_piece : Spatial
var gun_parent

func _ready():
	top_piece = get_node("TopPiece")
	bottom_piece = get_node("BottomPiece")
	left_piece = get_node("LeftPiece")
	right_piece = get_node("RightPiece")
	gun_parent = $"/root/Player/BodyCollision/LookHeight/LookDirection/GunController"

func _physics_process(_delta):
	top_piece.translation.y = gun_parent.current_gun.current_inaccuracy*7

	bottom_piece.translation.y = -gun_parent.current_gun.current_inaccuracy*7

	left_piece.translation.x = -gun_parent.current_gun.current_inaccuracy*7

	right_piece.translation.x = gun_parent.current_gun.current_inaccuracy*7
