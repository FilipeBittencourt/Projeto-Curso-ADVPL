#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

User Function BIA478()

/*北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    � BIA478     � Autor � WANISAY               � Data � 08/09/10 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Atualiza Centro de Custo automaticamente                     潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � BIANCOGRES                                                   潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�*/

//VARIAVEL CRIADA PARA TESTAR SE ESTA EXECUTANDO VIA EXECAUTO - MATA240
	IF Type("_IViaEAuto") <> "U"
		cCC := M->D3_CC
		RETURN(cCC)
	ENDIF

//VARIAVEL CRIADA PARA TESTAR SE ESTA EXECUTANDO VIA EXECAUTO - MATA241
	IF Type("_ExecAutoII") <> "U"
		cCLVL := Gdfieldget("D3_CLVL",n)
	// Tratamento implementado por Marcos Alberto Soprani em 08/04/16, conforme detalhado
		cCC   := U_B478RTCC(cCLVL)[1]
	//DO CASE
	//	CASE SUBSTRING(cCLVL,1,1) $ "1/4/9"
	//		cCC := "1000"
	//	CASE SUBSTRING(cCLVL,1,1) $ "2"
	//		cCC := "2000"
	//	CASE SUBSTRING(cCLVL,1,1) $ "3/8"
	//		cCC := "3000"
	//	CASE SUBSTRING(cCLVL,1,1) $ "5" .And. AllTrim(cCLVL) != "5500"
	//		cCC := "5000"
	//	OTHERWISE
	//		cCC := "1000"
	//ENDCASE
		RETURN(cCC)
	ENDIF

//Por Marcos Alberto Soprani em 25/05/12 para atender a integra玢o com o programa BIA292 quando executado via Schedule
	If Type("_ExcAut292") <> "U"
		cCLVL := M->D3_CLVL
		cCC   := "3000"
	EndIf

//Por Marcos Alberto Soprani em 25/11/14 para atender a integra玢o com o o m骴ulo EIC. N鉶 muito clara a defini玢o de qual ser� a clvl
	If Alltrim(FunName()) == "EICDI154"
		Return ( "3000" )
	EndIf
	
	If Alltrim(FunName()) == "EICPO400"
		Return ( "3000" )
	EndIf
	
	

	DO CASE
	CASE ALLTRIM(__READVAR) = 'M->C1_CLVL'
		cCLVL := Gdfieldget("C1_CLVL",n)
	CASE ALLTRIM(__READVAR) = 'M->C3_YCLVL'
		cCLVL := Gdfieldget("C3_YCLVL",n)
	CASE ALLTRIM(__READVAR) = 'M->C5_YCLVL'
		cCLVL := M->C5_YCLVL
	CASE ALLTRIM(__READVAR) = 'M->C7_CLVL'
		cCLVL := Gdfieldget("C7_CLVL",n)
	CASE ALLTRIM(__READVAR) = 'M->D1_CLVL'
		cCLVL := Gdfieldget("D1_CLVL",n)
	CASE ALLTRIM(__READVAR) = 'M->D3_CLVL'
		IF ALLTRIM(FUNNAME()) $ ("MATA241")		//Movimentos Internos Mod(2)
			cCLVL := Gdfieldget("D3_CLVL",n)
		ENDIF
		IF ALLTRIM(FUNNAME()) == "MATA240" .OR. ALLTRIM(FUNNAME())=="MATA250" .or. UPPER(ALLTRIM(FUNNAME())) == "BIA294"    //Movimentos Internos Mod(1) ou Producao.
			cCLVL := M->D3_CLVL
		ENDIF
		IF Upper(Alltrim(FunName())) $ "BIA271/BIA292/BIA294/BIA701/BIA742/BIA785/BIA570" .Or. IsInCallsTack("U_BIAFG120") // Inclu韉o por Marcos Alberto em 02/01/12
			cCLVL := M->D3_CLVL
		ENDIF
		IF ALLTRIM(FUNNAME()) =="MATA261"     //Transferencia de Estoque Mod(2).
			cCLVL := Gdfieldget("D3_CLVL",n)
		ENDIF
	CASE ALLTRIM(__READVAR) = 'M->ZI_CLVL'
		cCLVL := M->ZI_CLVL
	CASE ALLTRIM(__READVAR) = 'M->E1_CLVLDB'
		cCLVL := M->E1_CLVLDB
	CASE ALLTRIM(__READVAR) = 'M->E1_CLVLCR'
		cCLVL := M->E1_CLVLCR
	CASE ALLTRIM(__READVAR) = 'M->E2_CLVLDB'
		cCLVL := M->E2_CLVLDB
	CASE ALLTRIM(__READVAR) = 'M->E2_CLVLCR'
		cCLVL := M->E2_CLVLCR

	CASE ALLTRIM(__READVAR) = 'M->E2_CLVL'
		cCLVL := M->E2_CLVL	
		
	CASE ALLTRIM(__READVAR) = 'M->E5_CLVLDB'
		cCLVL := M->E5_CLVLDB
	CASE ALLTRIM(__READVAR) = 'M->E5_CLVLCR'
		cCLVL := M->E5_CLVLCR
	CASE ALLTRIM(__READVAR) = 'M->ED_YCLVL'
		cCLVL := M->ED_YCCUSTO
	CASE ALLTRIM(__READVAR) = 'M->ED_YCLVLI'
		cCLVL := M->ED_YCCI
	CASE ALLTRIM(__READVAR) = 'M->CT2_CLVLDB'
		cCLVL := M->CT2_CLVLDB
	CASE ALLTRIM(__READVAR) = 'M->CT2_CLVLCR'
		cCLVL := M->CT2_CLVLCR
	CASE ALLTRIM(__READVAR) = 'M->ZL0_CLVLDB'
		cCLVL := M->ZL0_CLVLDB
	ENDCASE

// Tratamento implementado por Marcos Alberto Soprani em 08/04/16, conforme detalhado
	cCC   := U_B478RTCC(cCLVL)[1]
//DO CASE
//	CASE SUBSTRING(cCLVL,1,1) $ "1/4/9"
//		cCC := "1000"
//	CASE SUBSTRING(cCLVL,1,1) $ "2"
//		cCC := "2000"
//	CASE SUBSTRING(cCLVL,1,1) $ "3/8"
//		cCC := "3000"
//	CASE SUBSTRING(cCLVL,1,1) $ "5" .And. AllTrim(cCLVL) != "5500"
//		cCC := "5000"
//	OTHERWISE
//		cCC := "1000"
//ENDCASE

RETURN(cCC)

/*___________________________________________________________________________
ΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖ�
Ζ+-----------------------------------------------------------------------+Ζ
Ζun鏰o    � B478RTCC  � Autor � Marcos Alberto S    � Data � 08.04.16 Ζ�
Ζ+----------+------------------------------------------------------------Ζ�
Ζescri玎o � Rotina desenvolvida para retornar o Centro de Custo que es-Ζ�
Ζ�          � ta associado a determinada Classe de Valor                 Ζ�
Ζ�          � Retorna um Vetor com duas posi珲es sendo:                  Ζ�
Ζ�          �    1) Centro de Custo                                      Ζ�
Ζ�          �    2) Atribui玢o de Custo / Despesa permitido              Ζ�
Ζ�          �                                                            Ζ�
Ζ�          � Tratamento implementado por Marcos Alberto Soprani em      Ζ�
Ζ�          � 08/04/16 para atender a Solicita玢o da contabilidade no    Ζ�
Ζ�          � tocante do novo grupo de Classe de Valor 6000              Ζ�
Ζ+-----------------------------------------------------------------------+Ζ
ΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖ�
�*/
User Function B478RTCC(xtCVusad)

	Local kRetCC  := {"",""}
	Local kAreaAt := GetArea()

	CTH->( dbSetOrder(1) )
	If CTH->( dbSeek(xFilial("CTH") + xtCVusad) )
		kRetCC := {CTH->CTH_YCC, CTH->CTH_YATRIB}
	EndIf

	RestArea(kAreaAt)

Return ( kRetCC )

/*/{Protheus.doc} BIA478G
Fun玢o utilizada no Gatilho do campo E5_NATUREZ do  movimento bancario
para preenchimento dos campos E5_CLVLDB  e E5_CLVLCR
@author TOTVS Protheus
@since  25/02/2019
@version 1.0
/*/
User Function BIA478G(cCampoRet, cNatureza, cRecPag_)
	
	Local cRet := Space(TamSx3("ZJ0_CLVLDB")[1])
	Local lRet := .F.
	
	//Default cCampoRet := ""
	Default cCampoRet := ""
	Default cNatureza := ""
	
	If Empty(cRecPag_)
	
		 cRecPag_ := M->E5_RECPAG
		 
	EndIf
	
	If ! Empty(cCampoRet)
		
		DBSelectArea("ZJ0")
		ZJ0->(DBSetOrder(1)) // ZJ0_FILIAL + ZJ0_NATURE + ZJ0_EMPFIL + ZJ0_RECPAG
		
		lRet := ZJ0->(DBSeek(xFilial("ZJ0") + PADR(cNatureza, TAMSX3("E5_NATUREZ")[1]) + cEmpant + cFilAnt + cRecPag_))
		
		If !lRet
			
			lRet := ZJ0->(DBSeek(xFilial("ZJ0") + PADR(cNatureza, TAMSX3("E5_NATUREZ")[1]) + cEmpant + "  " + cRecPag_))
			
		EndIf
		
		If !lRet
			
			lRet := ZJ0->(DBSeek(xFilial("ZJ0") + PADR(cNatureza, TAMSX3("E5_NATUREZ")[1]) + "    " + cRecPag_))
			
		EndIf
		
		If lRet
		
			cRet := &(cCampoRet)
		
		EndIf
	
	EndIf

Return(cRet)