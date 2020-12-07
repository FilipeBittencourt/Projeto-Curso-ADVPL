User Function MT100AG()
//TESTE CONEXAO INICIO
	conout(" ["+ Time() +"] Mensagem ConexãoNF-e")
	conout(" > MT100AG:")

	If Type("cEspecie") <> "U"
		conout("    cEspecie: '" + cEspecie + "'")
	else
		conout("    cEspecie não declarada")
	EndIf

	If Empty(SF1->F1_ESPECIE)
		conout("    SF1->F1_ESPECIE = ''")
	else
		conout("    SF1->F1_ESPECIE = '" + SF1->F1_ESPECIE + "'")
	EndIf
//TESTE CONEXAO FIM
Return Nil
