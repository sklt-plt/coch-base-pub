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
class_name Effects

enum AVAILABLE_SURFACE_EFFECTS {
	DUST,
	BLOOD,
	GREEN_BLOOD,
	FOLIAGE
}

const SURFACE_EFFECTS = {
	AVAILABLE_SURFACE_EFFECTS.DUST : Globals.content_pack_path + "/Effects/HitParticlesDust.tscn",
	AVAILABLE_SURFACE_EFFECTS.BLOOD : Globals.content_pack_path + "/Effects/HitParticlesBlood.tscn",
	AVAILABLE_SURFACE_EFFECTS.GREEN_BLOOD: Globals.content_pack_path + "/Effects/HitParticlesGreenBlood.tscn",
	AVAILABLE_SURFACE_EFFECTS.FOLIAGE: Globals.content_pack_path + "/Effects/HitParticlesFoliage.tscn"
}

