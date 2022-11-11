extends StaticBody
class_name Hurtbox

signal deal_damage(damage, push_force, from_direction, from_ent)

func deal_damage(var damage, var push_force, var from_direction, var from_ent):
	emit_signal("deal_damage", damage, push_force, from_direction, from_ent)
