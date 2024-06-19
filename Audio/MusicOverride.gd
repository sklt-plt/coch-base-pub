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
class_name MusicOverride

enum TRANSITION_TYPE {
	CROSSFADE,
	QUEUE,
	INSTANT
}

export (TRANSITION_TYPE) var transition_type

export (Array, AudioStream) var new_tracks

func _ready():
	match transition_type:
		TRANSITION_TYPE.QUEUE:
			$"/root/Player/MusicController".queue_next_list(new_tracks)
		TRANSITION_TYPE.CROSSFADE:
			$"/root/Player/MusicController".crossfade_next_list(new_tracks)
		TRANSITION_TYPE.INSTANT:
			$"/root/Player/MusicController".force_next_list(new_tracks)
