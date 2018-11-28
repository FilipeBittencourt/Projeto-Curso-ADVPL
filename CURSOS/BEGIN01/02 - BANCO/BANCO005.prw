#Include 'Protheus.ch'
#Include 'Parmtype.ch'
#Include 'TopConn.ch' //permite executar codigos no fonte

User Function BANCO005()

	
	Local aArea := GetArea()	
	Local aDados := {}
	Private lMSErroAuto := .F.
	
	aDados :={;
		{"B1_COD","000001", Nil},;
		{"B1_DESC","PRODUTO TESTE", Nil},;
		{"B1_TIPO","GG", Nil},;
		{"B1_UM","PC", Nil},;
		{"B1_LOCPAD","01", Nil},;
		{"B1_PICM",0, Nil},;
		{"B1_IPI",0, Nil},;
		{"B1_CONTRAT","N", Nil},;
		{"B1_LOCALIZ","N", Nil};		
	}
	
	
	
	// Iniciar transação.	
	Begin Transaction
	   //3 - INCLUSÃO , 4 - ALTERAÇÃO, 5 - DELETA
		MSExecAuto({|x,y|MATA010(x,y)},aDados,3)
		
		//lMSErroAuto o valor padrão é definido, mas caso de algum erro na hora de gravar o MSExecAuto irá escrever .T. na lMSErroAuto
		If(lMSErroAuto)
			Alert("Ocorreu erros durante o processo")
			MostraErro()
			DisarmTransaction() // Disfaz toda alteração no banco de dados
		Else
			MsgInfo("Operação realizada com sucesso!","Aviso")
		EndIf 		
 	End Transaction
 	
 	RestArea(aArea)	
Return

