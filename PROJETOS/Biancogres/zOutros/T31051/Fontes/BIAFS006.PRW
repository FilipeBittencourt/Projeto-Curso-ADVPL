#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"


/*/ {Protheus.doc} BIAFS006
Relatório de Apuração Seguro Fábrica
@author  Emerson Salvador
@since   04/08/2021
@version 1.0
@type Function
/*/

User Function BIAFS006()

	Local dPerIni     := Ctod("//")
	Local dPerFim     := Ctod("//")
	Local cMarcaIni   := Space(11)
	Local cMarcaFim   := Space(11)
	Local aTamSX3C    := TamSx3("A1_COD")
	Local cCliIni     := Space(aTamSx3C[1])
	Local cCliFim     := Space(aTamSx3C[1])
	Local oEmp        := NIL
	Private aMarca    :={Space(11), 'Biancogres', 'Incesa', 'Bellacasa', 'Mundi', 'Pegasus', 'Vinilico', 'ZZZZZZZZZZZ'}
	Private aCodMarca :={Space(4) , '0101'      , '0501'  , '0599'     , '1399' , '0199'   , '1302'    , 'ZZZZ'}
	Private aParamBox := {}
	
	aAdd(aParamBox, {1, "Data Emissão de",  dPerIni,  "", ".T.", "", ".T.", 80,  .F.})
	aAdd(aParamBox, {1, "Data Emissão até", dPerFim,  "", ".T.", "", ".T.", 80,  .F.})

	aAdd(aParamBox, {2, "Marca de", 	  	cMarcaIni, aMarca, 100, ".T.",.F.})
	aAdd(aParamBox, {2, "Marca até", 	  	cMarcaFim, aMarca, 100, ".T.",.F.})
	
	aAdd(aParamBox, {1, "Cliente de", 	  	cCliIni,   "", ".T.", "SA1", ".T.", 80,  .F.})
	aAdd(aParamBox, {1, "Cliente até", 	  	cCliFim,   "", ".T.", "SA1", ".T.", 80,  .F.})

	If !ParamBox(aParamBox,'Relatório Apuração Seguro Fábrica')
		Return
	EndIf
	
	dPerIni 	:= MV_PAR01
	dPerFim 	:= MV_PAR02
	cMarcaIni	:= aCodMarca[aScan(aMarca, {|x| AllTrim(x) == Alltrim(MV_PAR03) })]
	cMarcaFim	:= aCodMarca[aScan(aMarca, {|x| AllTrim(x) == Alltrim(MV_PAR04) })]
	cCliIni 	:= MV_PAR05		
	cCliFim		:= MV_PAR06		

	// Seleciona as Empresas
	oEmp := TLoadEmpresa():New()
	oEmp:GetSelEmp()
	
	If Len(oEmp:aEmpSel) > 0
		FWMsgRun(, {|| ProcRel(dPerIni, dPerFim, cMarcaIni, cMarcaFim, cCliIni, cCliFim, oEmp:aEmpSel) }, "Processando", "Relatório Apuração Segura Fábrica","Processando dados...")
	Else
		ApMsgInfo("Nenhuma empresa foi selecionada!!")	
	Endif	
	
Return

/*/
{Protheus.doc} ProcRel
Processa relatório
@author Emerson Salvador
@since 04/08/2021
@version undefined
@type function
/*/

Static Function ProcRel(dPerIni, dPerFim, cMarcaIni, cMarcaFim, cCliIni, cCliFim, aEmp)

	Local oExcel 	
	Local _AbaPlan 	:= ""
	Local _TitPlan 	:= ""
	Local cArqTemp	:= GetTempPath()+'biafs006.xml'	
	Local Qry 	 
	Local cCrLf 	:= Chr(13) + Chr(10)
	Local nW		:= 0

	oExcel := FWMSEXCEL():New()
		
	/* ---- Monta Aba 1 - NF'S ----- */		
	_AbaPlan := "NF'S"
	_TitPlan := "Apuração Seguro Fábrica - NF´s de " + cValToChar(dPerIni) + " até " + cValToChar(dPerFim)
		
	oExcel:AddworkSheet(_AbaPlan)
	oExcel:AddTable(_AbaPlan, _TitPlan)

	oExcel:AddColumn(_AbaPlan, _TitPlan, "Empresa"			,1,1)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Data NF"			,1,4)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Num.NF / Série"	,1,1)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Cod.Cliente"		,1,1)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Nome Cliente"		,1,1)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Cod.Produto"		,1,1)	
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Desc.Produto"		,1,1)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Lote"				,1,1)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Quantidade"		,3,2,.F.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Valor Mercadoria"	,3,2,.F.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "%Seguro Fabr."	,3,2,.F.)
	oExcel:AddColumn(_AbaPlan, _TitPlan, "Vlr.Seguro Fabr."	,3,2,.F.)
	
	// Processa consulta	
	For nW := 1 To Len(aEmp)

		Qry := GetNextAlias()	
		fConsultaSQL(aEmp[nW][1], aEmp[nW][4], dPerIni, dPerFim, cMarcaIni, cMarcaFim, cCliIni, cCliFim, Qry)

		If !(Qry)->(Eof())
			While !(Qry)->(Eof())

				oExcel:AddRow(_AbaPlan, _TitPlan, { (Qry)->EMPRESA,;
													STOD((Qry)->D2_EMISSAO),; 
													(Qry)->D2_DOC+"/"+(Qry)->D2_SERIE,;
													(Qry)->D2_CLIENTE,;
													(Qry)->A1_NOME,;
													(Qry)->D2_COD,;
													RTRIM((Qry)->B1_DESC),;
													(Qry)->D2_LOTECTL,;
													(Qry)->D2_QUANT,;
													(Qry)->D2_TOTAL,;
													(Qry)->C5_PSEGFAB,;
													(Qry)->VLR_SEGFAB } )

				(Qry)->(DbSkip())
			Enddo
		Endif						
		(Qry)->(dbCloseArea())
	Next	

	// Gera o Arquivo em Excel
	If File(cArqTemp)
		If fErase(cArqTemp) == -1
			Aviso('Arquivo em uso', 'Favor fechar o arquivo: ' + cArqTemp + ' antes de prosseguir!!!',{'Ok'})
		EndIf
	EndIf
		
	oExcel:Activate()
	oExcel:GetXMLFile(cArqTemp)
			
	If ! ApOleClient( 'MsExcel' )
		MsgAlert( "MsExcel nao instalado!"+cCrLf+cCrLf+"Você poderá recuperar este arquivo em: "+cArqTemp )
	Else
		oExcel:= MsExcel():New()
		oExcel:WorkBooks:Open( cArqTemp ) // Abre uma planilha
		oExcel:SetVisible(.T.)
		oExcel:Destroy()
	EndIf
Return


/*/
{Protheus.doc} fConsultaSQL
Gera string da Query para consulta 
@author Emerson Salvador
@since 04/08/2021
@version undefined
@type function
/*/
Static Function fConsultaSQL(cEmp, cNomeEmp, dPerIni, dPerFim, cMarcaIni, cMarcaFim, cCliIni, cCliFim, Qry)
		
	Local cTabSD2 	:= "%"+RetFullName("SD2", cEmp)+"%"			
	Local cTabSC5 	:= "%"+RetFullName("SC5", cEmp)+"%"			
	Local cTabSA1 	:= "%"+RetFullName("SA1", cEmp)+"%"			
	Local cTabSB1 	:= "%"+RetFullName("SB1", cEmp)+"%"			

	BeginSql Alias Qry   

		%NOPARSER%

		SELECT
				EMPRESA = %EXP:cNomeEmp%,
				D2_EMISSAO, 
				D2_DOC,
				D2_SERIE,
				D2_CLIENTE,
				A1_NOME,
				D2_COD,
				B1_DESC,
				D2_LOTECTL,
				D2_QUANT,
				D2_TOTAL,
				C5_PSEGFAB = 0.03, //C5_PSEGFAB,  AQUI
				VLR_SEGFAB = D2_TOTAL * (0.03 / 100)  //VLR_SEGFAB = D2_TOTAL * (C5_PSEGFAB / 100) AQUI

		FROM %EXP:cTabSD2% D2 (NOLOCK)

			INNER JOIN %EXP:cTabSC5% C5 (NOLOCK) ON C5_FILIAL = D2_FILIAL AND C5_NUM = D2_PEDIDO AND C5_YRESUL2 = 'S' AND C5.%notDel%  //  AQUI AND C5_YSEGFAB = 'S' 
			INNER JOIN %EXP:cTabSA1% A1 (NOLOCK) ON A1_COD = D2_CLIENTE  AND A1_LOJA = D2_LOJA AND A1.%notDel%
			INNER JOIN %EXP:cTabSB1% B1 (NOLOCK) ON B1_COD = D2_COD  AND B1.%notDel%

			WHERE D2_EMISSAO BETWEEN %Exp:DTOS(dPerIni)% AND %Exp:DTOS(dPerFim)%
					AND D2_CLIENTE >= %Exp:cCliIni% AND D2_CLIENTE <= %Exp:cCliFim%
					AND D2_YEMP >= %Exp:cMarcaIni% AND D2_YEMP <= %Exp:cMarcaFim%
				  	AND D2.%notDel% 					

			ORDER BY D2_DOC, D2_SERIE, D2_EMISSAO
	EndSql

Return
