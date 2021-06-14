#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} CTBA020
@author Luana Marin Ribeiro
@since 16/07/2019
@version 1.0
@description O ponto de entrada CTBA020 é executado na validação do plano de contas
@obs Criado inicialmente para controlar a inclusão/alteração de Contas Contábeis de Custo e Despesa sem Pacote GMCD
@type function
/*/

User Function CTBA020()
	Local oModel := FWModelActive()
	Local aParam := PARAMIXB
	Local xRet := .T.
	Local oObj := ""
	Local cIdPonto := ""
	Local cIdModel := ""
	Local iQtdProd:= 0	

	if oModel <> NIL
		nOperation 	:= oModel:GetOperation() //1 - View //3 - Insert //4 - Update //5 - Delete //6 - only Update
	EndIf

	If aParam <> NIL		
		oObj := aParam[1]
		cIdPonto := aParam[2]
		cIdModel := aParam[3]

		If cIdPonto $ ("MODELPOS") .And. (nOperation == 3 .Or. nOperation == 4)
			If M->CT1_CLASSE == "2" .and. Substr(M->CT1_CONTA,1,1) $ "3/6"
				If Empty(M->CT1_YPACOT)
					If xRet := ApMsgYesNo("Contas de Custo de despesas necessitam do pacote GMCD informado!!! Confirma a manutenção da conta sem esta informação?","CTBA020")		
						If !(xRet := ApMsgYesNo("Observei que você confirmou a manutenção desta conta sem informar o pacote GMCD mesmo tendo sido alertado do problema. Confirma prosseguir?","CTBA020"))			
							Help( NIL, NIL, "CTBA020", NIL, "Favor informar o pacote GMCD", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Informar o pacote GMCD"})
							xRet := .F.		
						EndIf
					Else
						Help( NIL, NIL, "CTBA020", NIL, "Favor informar o pacote GMCD", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Informar o pacote GMCD"})
						xRet := .F.
					EndIf		
				EndIf

				If M->CT1_NORMAL == "1" .And. (Empty(M->CT1_YCTAAG) .Or. Empty(M->CT1_YPCT20) .Or. Empty(M->CT1_YSBPCT))
					Help( NIL, NIL, "CTBA020", NIL, "Contas de Custo de despesas necessitam do [Cto Agr BO], [Pct GMCD 2.0], [Sub Pct BO] informado!!!", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Informar o pacote GMCD"})
					xRet := .F.					
				EndIf				
			EndIf	
		Endif		
		
		/*If cIdPonto $ ("MODELPRE")// FORMCOMMITTTSPRE  FORMPRE
			If M->CT1_BLOQ == "1"
			   iQtdProd:= U_BIABC028(M->CT1_CONTA)  
			   if iQtdProd > 0   
			     xRet	:=	.F.          
                 MsgInfo("Impossível bloquear esta Conta Contábil pois existem " + ltrim( rtrim(str(iQtdProd))) + " produtos a utilizando." , "CTBA020")
               endif
			Endif
		EndIf*/		
	EndIf

Return(xRet)