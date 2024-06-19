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
class_name FileHelper

static func save_file(var file_name: String, var contents: Dictionary):
	var file = File.new()
	file.open(file_name, File.WRITE)
	file.store_line(to_json(contents))
	file.close()

static func load_file(var file_name: String, var contents_holder: Dictionary):
	var file = File.new()
	if file.open(file_name, File.READ) == OK:
		var new_contents = parse_json(file.get_line())
		if not new_contents:
			print("File ", file_name, " not ok")
			file.close()
			return false

		# is file ok?
		for c in contents_holder:
			if not new_contents.keys().has(c):
				print("Contents of ", file_name, " not ok")
				file.close()
				return false

			contents_holder[c] = new_contents[c]

		file.close()
		return true
	else:
		print("Cannot load ", file_name, " Creating default")
		return false
