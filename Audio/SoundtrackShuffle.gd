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

export (Array, AudioStream) var tracks

func _ready():
	if tracks.empty():
		print("Warning: No tracks provided")
		return

	var controller = $"/root/Player/MusicController"
	if not controller.current_music_player.playing:
		# pass random track to controller to loop a song
		var index = randi()%tracks.size()
		controller.force_next_list([tracks[index]])
	elif controller.looped:
		# find out what song was playing
		var allowed_indexes = []
		for i in range(0, tracks.size()):
			if not controller.current_track_list.empty() and tracks[i] != controller.current_track_list[0]:
				allowed_indexes.push_back(i)

		# pick an index
		var index = allowed_indexes[randi()%allowed_indexes.size()]

		controller.crossfade_next_list([tracks[index]])
