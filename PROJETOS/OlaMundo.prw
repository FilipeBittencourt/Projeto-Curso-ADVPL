#Include 'Protheus.ch'
#Include 'Parmtype.ch'
#Include "TBICONN.ch"
#INCLUDE "TOPCONN.CH"


User Function OlaMundo()
	
	Local cSQL  := "Filipe"
	RpcSetType(3)
	RpcSetEnv("99","01",,,"COM")

	cSQL :=  SUBSTR( cSQL, 1,  2 )
 
 

	/*
	RPCSetEnv("99", "01", NIL, NIL, "COM", NIL, {"SB1", "SB5"})
	//Alert("Olá mundo!")
	DbSelectArea("SB1")
	DbSetOrder(5) //B1_FILIAL, B1_CODBAR, R_E_C_N_O_, D_E_L_E_T_
	SB1->(DbGoTop())

	If SB1->(MsSeek("01178983574100430"))
		dbSeek("01178983574100430")  
		ConOut(AllTrim(SB1->B1_COD))
		// VERIFICA SE O PRODUTO INFORMADO TEM IMAGEM CADASTRADA
	If (MsSeek("01"+PadR(AllTrim(SB1->B1_COD), TamSX3("B1_COD")[1])))
			ConOut("VERIFICA SE O PRODUTO INFORMADO TEM IMAGEM CADASTRADA")
			// CASO O PRODUTO TENHA IMAGEM, EFETUA E EXTRAÇÃO PARA O ROOTHPATH
			If (RepExtract(AllTrim(SB1->B1_BITMAP), "C:\Repositories\Fibrasa\ProjetoWebRest\images\" + AllTrim(SB1->B1_COD) + ".jpg" , .T.))
				oFile := FwFileReader():New("C:/Repositories/Fibrasa/ProjetoWebRest/images/" + AllTrim(SB1->B1_COD) + ".jpg")
				// EFETUA A MANIPULAÇÃO DO ARQUIVO
				If (oFile:Open())
					// APAGA O ARQUIVO GERADO
					// FErase("C:/Repositories/Fibrasa/ProjetoWebRest/images/" + AllTrim(SB1->B1_COD) + ".jpg")
				Else
					alert("can't load file") // GERA MENSAGEM DE ERRO CUSTOMIZADA
				EndIf
			Else
				alert("can't load images")
			EndIf
		Else // SE NÃO ACHA A IMAGEM
			alert("product images not found")
		EndIf 
	EndIf 
	*/

Return
 