extends Node

signal give_axe 
signal give_hoe
signal give_farming_kit # Untuk Alat Siram + Bibit
signal unlock_pesticide # Untuk Pestisida

func action_give_axe(): give_axe.emit()
func action_give_hoe(): give_hoe.emit()

func action_give_farming_kit():
	give_farming_kit.emit()

func action_unlock_pesticide():
	unlock_pesticide.emit()
