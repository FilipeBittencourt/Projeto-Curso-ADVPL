#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} F3_SA1REP
@author Ranisses A. Corona
@since 20/10/2017
@version 1.0
@description Filtro personalizado para exibir os Clientes de cada Representante.
@obs Utilizado na Consulta Padrão de Cliente SA1REP  
@type function
/*/

User Function F3_SA1REP()
	Local cSQL 		:= ""
	Local oAceTela 	:= TAcessoTelemarketing():New()
	
		   
	
	If(!Empty(cRepAtu))	
		If AllTrim(FunName()) == "MATA410"
			If Alltrim(M->C5_YLINHA) == "1" 	//BIANCOGRES
				cSQL := "@(A1_VEND    = "+ValToSQL(cRepAtu)+" OR A1_YVENDB2 = "+ValToSQL(cRepAtu)+" OR A1_YVENDB3 = "+ValToSQL(cRepAtu)+")"
			ElseIf Alltrim(M->C5_YLINHA) == "2" //INCESA
				cSQL := "@(A1_YVENDI  = "+ValToSQL(cRepAtu)+" OR A1_YVENDI2 = "+ValToSQL(cRepAtu)+" OR A1_YVENDI3 = "+ValToSQL(cRepAtu)+")"
			ElseIf Alltrim(M->C5_YLINHA) == "3" //BELLACASA
				cSQL := "@(A1_YVENBE1 = "+ValToSQL(cRepAtu)+" OR A1_YVENBE2 = "+ValToSQL(cRepAtu)+" OR A1_YVENBE3 = "+ValToSQL(cRepAtu)+")"
			ElseIf Alltrim(M->C5_YLINHA) == "4" //MUNDIALLI
				cSQL := "@(A1_YVENML1 = "+ValToSQL(cRepAtu)+" OR A1_YVENML2 = "+ValToSQL(cRepAtu)+" OR A1_YVENML3 = "+ValToSQL(cRepAtu)+")"
			ElseIf Alltrim(M->C5_YLINHA) == "5" //PEGASUS
				cSQL := "@(A1_YVENPEG = "+ValToSQL(cRepAtu)+" )"
			ElseIf Alltrim(M->C5_YLINHA) == "6" //VINILICO
				cSQL := "@(A1_YVENVI1 = "+ValToSQL(cRepAtu)+" )"
			Else
				cQUERY += " AND (A1_VEND    = '"+cRepAtu+"' OR A1_YVENDB2 = '"+cRepAtu+"' OR A1_YVENDB3 = '"+cRepAtu+"' OR  "
				cQUERY += "      A1_YVENDI  = '"+cRepAtu+"' OR A1_YVENDI2 = '"+cRepAtu+"' OR A1_YVENDI3 = '"+cRepAtu+"' OR  "
				cQUERY += "      A1_YVENBE1 = '"+cRepAtu+"' OR A1_YVENBE2 = '"+cRepAtu+"' OR A1_YVENBE3 = '"+cRepAtu+"' OR  "
				cQUERY += "      A1_YVENVT1 = '"+cRepAtu+"' OR A1_YVENVT2 = '"+cRepAtu+"' OR A1_YVENVT3 = '"+cRepAtu+"' OR  "
				cQUERY += "      A1_YVENML1 = '"+cRepAtu+"' OR A1_YVENML2 = '"+cRepAtu+"' OR A1_YVENML3 = '"+cRepAtu+"' OR  "
				cQUERY += "      A1_YVENPEG = '"+cRepAtu+"' OR A1_YVENVI1 = '"+cRepAtu+"' )    "
			EndIf
		Else
			cSQL := "@(A1_VEND   = "+ValToSQL(cRepAtu)+" OR A1_YVENDB2 = "+ValToSQL(cRepAtu)+" OR A1_YVENDB3 = "+ValToSQL(cRepAtu)+" OR  "
			cSQL += " A1_YVENDI  = "+ValToSQL(cRepAtu)+" OR A1_YVENDI2 = "+ValToSQL(cRepAtu)+" OR A1_YVENDI3 = "+ValToSQL(cRepAtu)+" OR  "
			cSQL += " A1_YVENBE1 = "+ValToSQL(cRepAtu)+" OR A1_YVENBE2 = "+ValToSQL(cRepAtu)+" OR A1_YVENBE3 = "+ValToSQL(cRepAtu)+" OR  "
			cSQL += " A1_YVENVT1 = "+ValToSQL(cRepAtu)+" OR A1_YVENVT2 = "+ValToSQL(cRepAtu)+" OR A1_YVENVT3 = "+ValToSQL(cRepAtu)+" OR  "
			cSQL += " A1_YVENML1 = "+ValToSQL(cRepAtu)+" OR A1_YVENML2 = "+ValToSQL(cRepAtu)+" OR A1_YVENML3 = "+ValToSQL(cRepAtu)+" OR	 "
			cSQL += " A1_YVENPEG = "+ValToSQL(cRepAtu)+" OR  A1_YVENVI1 = "+ValToSQL(cRepAtu)+")	 "
			
		EndIf
	Else
		cSQL := "@1 = 1 "
	EndIf 
	
	
	If AllTrim(FunName()) == "MATA410"
		If (oAceTela:UserTelemaketing())
			cSQL := oAceTela:FiltroSA1()	
		EndIf	
	EndIf
	
	If (cEmpAnt == '07' .And. cFilAnt == '05')
		cSQL += " AND A1_EST = 'SP' "
	EndIf
 
Return cSQL
