#include "rwmake.ch"
#include "topconn.ch"

/*/{Protheus.doc} MSD2520
//TODO Descrição auto-gerada.
@author Ranisses A. Corona  / Revisado por Fernando Rocha
@since 17/08/99
@version 1.0
@type function
/*/
User Function MSD2520()

	Local cSQL
	Local cAliasTmp
	Local _oMd	:=	TBiaControleMD():New()

	SetPrvt("CQUERY, NTOTREGS")

	if !empty(SF2->F2_YAGREG)

		cQuery := ""
		cQuery += "SELECT COUNT(SZ9.Z9_NUMERO) AS TOTREGS "
		cQuery += "FROM "+RetSQLName("SZ9")+" SZ9 "
		cQuery += "WHERE "
		cQuery += "SZ9.Z9_FILIAL  = '"+xFilial("SZ9")+"'  AND "
		cQuery += "SZ9.Z9_NUMERO  = '"+SF2->F2_YAGREG+"'  AND "
		cQuery += "SZ9.Z9_ITEM    = '"+SD2->D2_ITEMPV+"'  AND "
		cQuery += "SZ9.D_E_L_E_T_ = '' "
		TcQuery cQuery Alias "X" New
		nTotRegs := X->TOTREGS
		X->(DbCloseArea())

		if nTotRegs > 0

			cQuery := ""
			cQuery += "UPDATE "+RetSQLName("SZ9")+" "
			cQuery += "SET D_E_L_E_T_ = '*' "
			cQuery += "WHERE "
			cQuery += "Z9_FILIAL  = '"+xFilial("SZ9")+"'  AND "
			cQuery += "Z9_NUMERO  = '"+SF2->F2_YAGREG+"'  AND "
			cQuery += "D_E_L_E_T_ = '' "
			TCSQLExec(cQuery)

			cQuery := ""
			cQuery += "UPDATE "+RetSQLName("SZ7")+" "
			cQuery += "SET D_E_L_E_T_ = '*' "
			cQuery += "WHERE "
			cQuery += "Z7_FILIAL  = '"+xFilial("SZ7")+"' AND "
			cQuery += "Z7_ROMAN   = '"+SF2->F2_YAGREG+"' AND "
			cQuery += "D_E_L_E_T_ = '' "
			TCSQLExec(cQuery)
		endif


		If (  AllTrim(CEMPANT) <> "07" )

			//Ao Cancelar uma NF - Limpar o campo de AUTOMATICO - O processo desta carga tera que ser refeito ou finalizado de forma manual
			ZZV->(DbSetOrder(1))
			If ZZV->(DbSeek(xFilial("ZZV") + SUBSTR(SF2->F2_YAGREG, 5, 4))) .And. !Empty(ZZV->ZZV_FIMP)

				RecLock("ZZV", .F.)
				ZZV->ZZV_FIMP := ""
				ZZV->(MSUnLock())

				lRet := .T.

			EndIf

		Else

			SC5->(DBSetOrder(1))

			If SC5->(DBSeek(xFilial("SC5") + SD2->D2_PEDIDO))
			
			    If (!Empty(SC5->C5_YEMPPED))
			    
			    	cAliasTmp := GetNextAlias()

					cSQL := " SELECT REC = ZZV.R_E_C_N_O_, ZZV_FIMP "
					cSQL += " FROM " + RetFullName("ZZV", SC5->C5_YEMPPED) + " ZZV (NOLOCK) "
					cSQL += " WHERE ZZV_FILIAL	 = '01' "
					cSQL += " AND ZZV_CARGA	 = " + ValToSql(SUBSTR(Alltrim(SF2->F2_YAGREG),5,4))
					cSQL += " AND ZZV.D_E_L_E_T_ = '' "
	
					ConOut("MSD2520 ==> NF:"+SF2->(F2_SERIE + F2_DOC)+" SQL CARGA LM: "+cSQL)
	
					TcQuery cSQL New Alias (cAliasTmp)
	
					(cAliasTmp)->(DbGoTop())
					If (cAliasTmp)->(!EOF()) .And. !Empty((cAliasTmp)->ZZV_FIMP)					
	
						cSQL := "UPDATE "+RetFullName("ZZV", SC5->C5_YEMPPED)+" SET ZZV_FIMP = '' WHERE R_E_C_N_O_ = "+AllTrim(Str((cAliasTmp)->REC))+""
						TCSQLExec(cSQL)
	
					EndIf
					(cAliasTmp)->(DbCloseArea())
			    
			    EndIf
				
			EndIf

		EndIf

	endif 
/*
	If SF2->F2_TIPO == 'D' .And. Alltrim(SF4->F4_ESTOQUE) == 'S' .And. _oMd:CheckMD(SD2->D2_COD,SD2->D2_LOCAL)
		_oMd:EstornoNfs(SD2->D2_NFORI,SD2->D2_SERIORI,SD2->D2_CLIENTE,SD2->D2_LOJA,SD2->D2_ITEMORI,SD2->D2_DOC,SD2->D2_SERIE,;
		SD2->D2_CLIENTE,SD2->D2_LOJA,SD2->D2_ITEM,SD2->D2_COD,SD2->D2_LOCAL,SD2->D2_QUANT,cUserName,FunName(),;
	    							SD2->D2_EMISSAO,"SD2",SD2->(Recno()))
	EndIf
*/

Return