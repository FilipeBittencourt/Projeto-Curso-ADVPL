#Include 'Protheus.ch'
#Include 'Parmtype.ch'
 

User Function BLOCO()

	//Local bBloco := {||nValor := 2, MsgAlert("O número é: "+ cValToChar(nValor))}	 
	//EVAL(bBloco)
	
	Local bBloco := {|cMsg| Alert(cMsg)}
	EVAL(bBloco,"Que troço doido")
	
Return

