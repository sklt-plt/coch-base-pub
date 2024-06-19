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
class_name TimeHelper

static func float_to_min_sec_msec_str(var input : float):
	var minutes = floor(input/60)
	var seconds = input-minutes*60
	return "%d:%02.2f" % [minutes, seconds]

static func float_to_min_sec_str(var input : float):
	var minutes = floor(input/60)
	var seconds = floor(input-minutes*60)
	return "%d:%02.f" % [minutes, seconds]
