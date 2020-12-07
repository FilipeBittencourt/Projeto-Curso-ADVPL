#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} MBRWBTN
@author Marcos Alberto Soprani
@since 23/11/16
@version 1.0
@description Este ponto de entrada tem por finalidade, validar se a rotina selecionada na MBrowse
.            será executada ou não a partir do retorno lógico do ponto de entrada.
.            Inicialmente usado para criar uma validação para a rotina MATA018
@type function
/*/

User Function MBRWBTN()

	Local gbiRet		:= .T.
	Local gbiArea		:= GetArea()  
	Local gbiFunc		:= Upper(Alltrim(FunName()))
	Local gbiMenu		:= Upper(AllTrim(PARAMIXB[4]))
	Local gbiOpc		:= AllTrim(cValtoChar(PARAMIXB[3]))

	If gbiFunc == "MATA018"               // Por Marcos Alberto Soprani em 23/11/16
		//*************************************************************************

		If gbiMenu $ "A018ALTERA/AXVISUAL"
			U_BIAATUSBZ()
		Else
			MsgINFO("Não é permitido utilizar esta rotina de MENU... " + gbiMenu)
			gbiRet := .F.
		EndIf

	EndIf

	RestArea(gbiArea)

Return ( gbiRet )
