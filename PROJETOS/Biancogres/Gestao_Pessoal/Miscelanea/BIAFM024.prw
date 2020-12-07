#INCLUDE 'RWMAKE.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'

/*/{Protheus.doc} BIAFM024
@author Marcelo Sousa Correa
@since 10/08/2019
@version 1.0
@description Relatório de Contabilização da Folha - Rotina GPEM110  
@obs Ticket 8067/19 - Criação de rotina que integra rotina de contabilização, bem como relatório final.
/*/

User Function BIAFM024()

	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±± Definicao das variáveis de funcionamento.                               ±±
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
	SetPrvt("oDlg1","oSay1","oGet1","oBtn1","oBtn2","oFont1")
	
	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±± Definicao do Dialog e todos os seus componentes.                        ±±
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
	oFont1     := TFont():New( "MS Sans Serif",0,-24,,.T.,0,,400,.F.,.F.,,,,,, )
	oFont2     := TFont():New( "MS Sans Serif",0,-12,,.T.,0,,400,.F.,.F.,,,,,, )
	oDlg1      := MSDialog():New(092,232,150,600," CONTABILIZAÇÃO DE FOLHA ",,,.F.,,,,,,.T.,,,.T.)
	
	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±± Execucao das tarefas                                                    ±±
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
	oBtn1 := TButton():New( 05, 095, "Contabilizar",oDlg1,  {||GPEM110(),gerarel(1),oDlg1:end()}, 088,020,,oFont1,.F.,.T.,.F.,,.F.,,,.F. )
	oBtn2 := TButton():New( 05, 005, "Relatório",oDlg1,{||gerarel(2),oDlg1:end()},088,020,,oFont1,,.T.,,"",,,,.F. )
	
	oDlg1:Activate(,,,.T.)

Return

Static Function gerarel(cRel) 

	Local oReport
	Local cLoad				:= "BIAFM024" + cEmpAnt
	Local cFileName			:= RetCodUsr() +"_"+ cLoad
	Private cPergunta := "BIAFM024"

	MV_PAR01 := SPACE(10)
	
	If cRel == 2
	
		aPergs := {}
		aAdd( aPergs ,{1,"Data da Contabilização: "       , dDataBase, PesqPict("CT2", "CT2_DATA"),'.T.',"" ,'.T.', TamSX3("CT2_DATA")[1], .T.}) 
	
		If !ParamBox(aPergs ,"Filtro",,,,,,,,cLoad,.T.,.T.)
			Return
		EndIf
	
	Else
	
		MV_PAR01 := dDatabase
	
	Endif
	
	oReport:= ReportDef()
	oReport:PrintDialog()

Return

Static Function ReportDef()

	Local cQry := GetNextAlias()
	Local dHoje := SubStr(dtos(MV_PAR01),7,2)+"/"+SubStr(dtos(MV_PAR01),5,2)+"/"+SubStr(dtos(MV_PAR01),1,4)
	Local dDia := "Contabilizacao da Folha - " + dHoje
	
	oReport:= TReport():New("Contabilizacao", dDia,, {|oReport| PrintReport(oReport, cQry)}, dDia)

	// Altera tipo de impressao para paisagem
	oReport:SetLandScape(.T.)

	oReport:SetTotalInLine(.F.)

	oSection1 := TRSection():New(oReport,"Produtos", {cQry})    
	oSection1:SetTotalInLine(.F.)
	
	TRCell():New(oSection1,"HISTORICO",, "HISTORICO",,70)

	TRCell():New(oSection1,"VALOR",, "VALOR",,60)

Return oReport

Static Function PrintReport(oReport, cQry)
	Local cEmpMar	:= ""
	Local Enter		:= CHR(13)+CHR(10)
	Local cSQL		:= ""		
	Local cAliasOP	:= GetNextAlias()
	Local cQueryOP	:= ""
	Local dHoje := DtoS(MV_PAR01)
	
	cSQL := ""
	cSQL += " SELECT CT2_HIST AS HISTORICO,ROUND(SUM(CT2_VALOR),2) AS VALOR FROM " + RETSQLNAME("CT2")
	cSQL += " CT2 WHERE CT2.D_E_L_E_T_ = '' "
	cSQL += " AND CT2.CT2_ROTINA = 'GPEM110' "
	cSQL += " AND CT2.CT2_LOTE = '008890' "
	cSQL += " AND CT2.CT2_YDELTA = '"+dHoje+"'
	cSQL += " AND CT2.CT2_VALOR <> '0' "
	cSQL += " GROUP BY CT2.CT2_HIST "
	cSQL += " ORDER BY CT2.CT2_HIST "

	TcQuery cSQL New Alias (cQry)

	(cQry)->(DbGoTop())

	oReport:SetMeter(300)

	oSection1 := oReport:Section(1)
	
	While (cQry)->(!Eof()) .And. !oReport:Cancel()

		oReport:IncMeter()

		oSection1:Init()

		
		oSection1:Cell("HISTORICO"):SetValue((cQry)->HISTORICO)
		oSection1:Cell("HISTORICO"):SetAlign("LEFT")

		oSection1:Cell("VALOR"):SetValue("R$" + TRANSFORM((cQry)->VALOR,"@E 999,999,999.99"))
		oSection1:Cell("VALOR"):SetAlign("LEFT")			

		oSection1:PrintLine()	
		
		(cQry)->(DbSkip())

	EndDo()

	oSection1:Finish()

	(cQry)->(DbCloseArea())

Return