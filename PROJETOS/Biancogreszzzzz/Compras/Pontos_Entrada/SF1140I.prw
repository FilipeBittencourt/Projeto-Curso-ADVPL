#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} SF1140I
@description Ponto de Entrada - Lançamento de Pré-Nota
@author Rodrigo Ribeiro Agostini
@since 29/04/19
@version 1.0
@type function
/*/

User Function SF1140I()

	Local lServico := .F.
	Local lLancMan := .F.
	Local lEnvProc := .F.
	Local cEntrega := ""
	Local cChvNF := ""
	Local oIntegraBZ := TIntegraBizagi():New()
	Local cChvF1 := SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)

	Local aAreaD1 := SD1->(GetArea())
	Local aMVBkp := {MV_PAR01, MV_PAR02, MV_PAR03}

	Private aSelOpc  := {"1=Sim", "2=Não"}
	Private aPergs   := {}
	Private aRet     := {"","",""}

	/* Identifica se é NF de Serviços*/
	SD1->(DbSetOrder(1))
	If SD1->(DbSeek(cChvF1)) .And. SubStr(SD1->D1_COD,1,3) == "306"
		lServico := .T.
	EndIf

	If Alltrim(FunName()) $ "EICDI554/EICDI154"
		Return
	Endif
	
	If IsInCallStack("U_PNFM0005")
		UpdateQuant()
		Return
	EndIf

	If Alltrim(FunName()) $ "MATA140"
		lLancMan := .T.
	EndIf

	If lServico
		aAdd( aPergs ,{2, "Enviar para Aprovacao"   , "1"         , aSelOpc, 50,".T.",.F.})
	else
		aAdd( aPergs ,{2, "Enviar para Conferencia" , "1"         , aSelOpc, 50,".T.",.F.})
	EndIf

	aAdd( aPergs ,{1, "Entregador" , space(100) ,"@!" ,".T.",,".T.",100,.F.})

	If lServico
		aAdd( aPergs ,{1, "Codigo NFS" ,space(44)   ,"@!" ,".T.",,".T.", 80,.F.})
	else
		If lLancMan
			aAdd( aPergs ,{1, "Chave NFE",space(44),"@!","U_VLDCHVNFE(mv_par02)",,".T.", 120,.F.})
		EndIf
	EndIf

	While !ParamBox(aPergs, "BIZAGI", aRet, , , , , , , , .F., .F.)

	EndDo	

	lEnvProc := aRet[1] == "1"
	cEntrega := aRet[2]		

	If (lServico .Or. lLancMan)
		cChvNF := aRet[3]
	Else
		cChvNF := ZAA_CHAVE
	EndIf

	If lEnvProc
		If lServico		
			/* Integração Aprovação Serviço */		
			oIntegraBZ:AprvNFS(cChvF1, cEntrega, cChvNF)
		Else
			/* Integração Conferencia */
			oIntegraBZ:ConfNFE(cChvF1, cEntrega, cChvNF)
		EndIf
	EndIf

	MV_PAR01 := aMVBkp[1]
	MV_PAR02 := aMVBkp[2]
	MV_PAR03 := aMVBkp[3]

	RestArea(aAreaD1)

Return

Static Function UpdateQuant()
	
	Local aArea	:= GetArea()
	Local cSeek	:= SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
	
	DbSelectArea("SD1")
	SD1->(DbSetOrder(1))
	If (SD1->(DbSeek(cSeek)))
		While !SD1->(Eof()) .And. AllTrim(SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)) == AllTrim(cSeek)
			
			RecLock("SD1",.F.)
				SD1->D1_QUANT 	:= 0
				SD1->D1_QTSEGUM := 0
				SD1->D1_TOTAL 	:= SD1->D1_VUNIT 
			SD1->(MsUnlock())
			
			SD1->(DbSkip())
		EndDo
	EndIf
	RestArea(aArea)

Return

