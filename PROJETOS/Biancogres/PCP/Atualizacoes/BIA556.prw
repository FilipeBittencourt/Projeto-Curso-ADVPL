#Include "Protheus.ch"
#include "topconn.ch"
#include "rwmake.ch"
#include "tbiconn.ch"

/*/{Protheus.doc} BIA556
@author Marcos Alberto Soprani
@since 14/08/15
@version 1.0
@description Rotina para Ajuste pontual de empenho
@obs Ajuste pontual de empenho
@type function
/*/

/*/{Protheus.doc} BIA556
@author Artur Antunes
@since 23/02/17
@version 1.1
@description Rotina para Ajuste pontual de empenho
@obs Inclusão de Backup - OS 0871-16
@type function
/*/

/*/{Protheus.doc} BIA556
@author Artur Antunes
@since 12/04/17
@version 1.2
@description Inclusão de opção - Inclusão de um novo insumo na ordem de produção
@obs OS 0939-17
@type function
/*/

User Function BIA556()

	Private oDlgAltEmp
	Private oButton1
	Private oRadMenu1
	Private nRadMenu1 := 0
	Private fhEsc     := .F.
	Private fhContin  := .F.
	Private msVetEst  := {}

	Private _oMrk	:=	Nil

	DbSelectArea("SX6")
	If !ExisteSX6("MV_YBLQRCM")
		CriarSX6("MV_YBLQRCM", 'L', 'Controle de Bloqueio de Rotinas do RCM', ".F." )
	EndIf

	If GetMv("MV_YBLQRCM")
		MsgInfo("Rotina bloqueada para execução pois o parâmetro do bloqueio para RCM está ativado!", "BIA556")
		Return
	EndIF

	kNumOP  := ""
	kCodCmp := ""
	kCamada := 0
	kDatIni := ""
	kDatFin := ""
	kFormat := ""
	kNewCmp := ""
	kRefPrd := ""
	kTpProd	:= ""
	kEspess := ""

	DEFINE MSDIALOG oDlgAltEmp TITLE "Escolha uma das opções abaixo:" FROM 000, 000  TO 450, 600 COLORS 0, 16777215 PIXEL

	//	"Troca de Insumo - UM POR OUTRO NA BAIXA",;

	@ 008, 006 RADIO oRadMenu1 VAR nRadMenu1 ITEMS;
	"Ajuste de camada por OP - SEM Apontamento",;
	"Ajuste de camada por OP - COM Apontamento",;
	"Acertando baixas para um DETERMINADO insumo - POR OP",;
	"Acertando baixas do insumo - AJUSTE DE CAMADA DIRETA - POR FORMATO",;
	"Troca de insumo para uma DETERMINADA OP" ,;
	"Troca de insumo para uma DETERMINADA REFERENCIA",;
	"Troca de insumo para um DETERMINADO FORMATO",;
	"Troca de insumo - UM POR OUTRO DIRETO",;
	"Ajuste de camada POR FORMATO - COM Apontamento",;
	"Excluir insumo dos itens empenhados",;
	"Inclusão de um novo insumo na ordem de produção",;
	"Excluir Insumo do Apontamento",;
	"Incluir Insumo no Apontamento",;
	"Troca de Insumo - UM POR OUTRO NA BAIXA",;
	"Vazio..." SIZE 286, 063 OF oDlgAltEmp COLOR 0, 16777215 PIXEL
	@ 205, 213 BUTTON oButton1 PROMPT "Confirmar" SIZE 037, 012 OF oDlgAltEmp ACTION yuActEmp() PIXEL
	@ 205, 255 BUTTON oButton2 PROMPT "Cancelar"  SIZE 037, 012 OF oDlgAltEmp ACTION (fhContin := .F., fh_Esc := .T., oDlgAltEmp:End()) PIXEL

	ACTIVATE MSDIALOG oDlgAltEmp CENTERED VALID fh_Esc

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦ Função   ¦ yuActEmp ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 17/08/15 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦ Ação     ¦ Atualiza Empenhos                                          ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function yuActEmp()

	local UP001 := ''
	local BK001 := ''
	Local QR001	:= ''
	Local _cAlias
	Local _cLocal	:=	""
	Local _aRecnos	:=	{}
	Local _nI
	Local _aVet

	If nRadMenu1 == 0 .or. nRadMenu1 == 15
		MsgSTOP("Favor selecionar uma das opções.", "Atenção!!!")
		Return
	EndIf

	cHInicio := Time()
	fPerg := "BIA556"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)

	If !ValidPerg()
		Return
	EndIf

	kNumOP  := MV_PAR01
	kCodCmp := MV_PAR02
	kCamada := MV_PAR03
	kDatIni := dtos(MV_PAR04)
	kDatFin := dtos(MV_PAR05)
	kFormat := MV_PAR06
	kNewCmp := MV_PAR07
	kRefPrd := Substr(MV_PAR08,1,7)
	kTpProd	:= MV_PAR09
	kEspess := MV_PAR12

	If nRadMenu1 == 3 .or. nRadMenu1 == 4 .or. nRadMenu1 == 12 .or. nRadMenu1 == 13 

		If MV_PAR04 <= GetMV("MV_ULMES") .or. MV_PAR05 <= GetMV("MV_ULMES") .or. MV_PAR04 <= GetMV("MV_YULMES") .or. MV_PAR05 <= GetMV("MV_YULMES")
			MsgSTOP("Favor verificar o intervalo de datas informado pois está fora do período de fechamento de estoque.","Data de Fechamento!!!")
			Return
		EndIf

	EndIf

	DbSelectArea("Z05")

	//-- AJUSTE DE CAMADA POR OP - SEM APONTAMENTO ------------------------------------------------
	If nRadMenu1 == 1

		_cAlias	:=	GetNExtAlias()

		QR001 := "  SELECT " + CRLF
		QR001 += "  SD4.D4_FILIAL 					Z05_FILIAL, " + CRLF  
		QR001 += "  SD4.D4_COD    					Z05_PRODUT, " + CRLF  
		QR001 += "  SD4.D4_LOTECTL  				Z05_LOTCTL, " + CRLF  
		QR001 += "  SD4.D4_NUMLOTE 					Z05_NUMLOT, " + CRLF  
		QR001 += "  '' 								Z05_LOCALZ, " + CRLF  
		QR001 += "  SD4.D4_DTVALID  				Z05_DTVALI, " + CRLF  
		QR001 += "  SD4.D4_LOCAL    				Z05_LOCAL, " + CRLF  
		QR001 += "  SD4.D4_OP 						Z05_OP, " + CRLF  
		QR001 += "  SD4.D4_DATA						Z05_EMISSA, " + CRLF  
		QR001 += "  SD4.D4_TRT 						Z05_TMTRT, " + CRLF  
		QR001 += "  SD4.D4_QTDEORI  				Z05_QTDORI, " + CRLF  
		QR001 += "  SD4.D4_QUANT    				Z05_QUANT, " + CRLF  
		QR001 += "	'SD4' 							Z05_TABELA, " + CRLF  
		QR001 += "	SD4.R_E_C_N_O_  				Z05_RECORI, " + CRLF  
		QR001 += "	'001'  							Z05_ORIBKP, " + CRLF  
		QR001 += "	'Ajuste de camada por OP - SEM Apontamento' 	Z05_ORBKDE, " + CRLF  
		QR001 += "	'"+UsrRetName(RetCodUsr())+"'	Z05_USRALT, " + CRLF
		QR001 += "	'"+DTOS(DATE())+"'				Z05_DTALT, " + CRLF
		QR001 += "	'"+TIME()+"'					Z05_HRALT, " + CRLF
		QR001 += "	"+ValtoSql(MV_PAR11)+"  		Z05_JUSTIF, " + CRLF
		QR001 += "	SB1.B1_DESC   					DESCRI, " + CRLF
		QR001 += "	C2_QUANT * "+Alltrim(Str(kCamada))+"	NEWVAL  "+ CRLF
		QR001 += "   FROM "+RetSqlName("SD4")+" SD4 (NOLOCK) " + CRLF 
		QR001 += "  INNER JOIN "+RetSqlName("SC2")+" SC2 (NOLOCK) ON C2_FILIAL = '"+xFilial("SC2")+"' " + CRLF
		QR001 += "                       AND C2_NUM = SUBSTRING(D4_OP,1,6) " + CRLF
		QR001 += "                       AND C2_ITEM = SUBSTRING(D4_OP,7,2) " + CRLF
		QR001 += "                       AND C2_SEQUEN = SUBSTRING(D4_OP,9,3) " + CRLF
		QR001 += "                       AND C2_DATRF = '        ' " + CRLF
		QR001 += "                       AND SC2.D_E_L_E_T_ = ' ' " + CRLF
		QR001 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 (NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
		QR001 += "                       AND B1_COD = SD4.D4_COD " + CRLF
		QR001 += "                       AND SB1.D_E_L_E_T_ = ' ' " + CRLF		
		QR001 += "  WHERE D4_FILIAL = '"+xFilial("SD4")+"' " + CRLF
		QR001 += "    AND SUBSTRING(D4_OP,1,6) IN('"+kNumOP+"') " + CRLF
		QR001 += "    AND D4_QUANT > 0 " + CRLF
		QR001 += "    AND D4_COD = '"+kCodCmp+"' " + CRLF
		QR001 += "    AND NOT EXISTS (SELECT * " + CRLF
		QR001 += "                      FROM "+RetSqlName("SD3")+" XD3 (NOLOCK) " + CRLF
		QR001 += "                     WHERE D3_FILIAL = '"+xFilial("SD3")+"' " + CRLF
		QR001 += "                       AND D3_OP = D4_OP " + CRLF
		QR001 += "                       AND D3_TM = '010' " + CRLF
		QR001 += "                       AND XD3.D_E_L_E_T_ = ' ') " + CRLF
		QR001 += "    AND SD4.D_E_L_E_T_ = ' ' " + CRLF

		QrIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,QR001),_cAlias,.T.,.F.)
		dbSelectArea(_cAlias)
		dbGoTop()

		_aRecnos	:=	fMrkBrw(_cAlias)

		(_cAlias)->(DbGoTop())

		If Len(_aRecnos) > 0
			While (_cAlias)->(!EOF())
				If aScan(_aRecnos,{|x| x == (_cAlias)->Z05_RECORI}) > 0
					SD4->(DbGoTo((_cAlias)->Z05_RECORI))
					If SD4->(!EOF())
						//Backup
						Reclock("Z05",.T.)
						For _nI	:= 1 to (_cAlias)->(fCount())
							If AllTrim((_cAlias)->(FieldName(_nI))) $ "Z05_DTVALI/Z05_EMISSA/Z05_DTALT"
								&("Z05->"+(_cAlias)->(FieldName(_nI)))	:=	Stod((_cAlias)->(FieldGet(_nI)))
							ElseIf "Z05" $ (_cAlias)->(FieldName(_nI))
								&("Z05->"+(_cAlias)->(FieldName(_nI)))	:=	(_cAlias)->(FieldGet(_nI))
							EndIF
						Next
						Z05->(MsUnlock())
						Reclock("SD4",.F.)
						SD4->D4_QUANT	:=	(_cAlias)->NEWVAL
						SD4->D4_QTDEORI	:=	(_cAlias)->NEWVAL
						SD4->(MsUnlock())
					EndIf
				EndIF
				(_cALias)->(DbSkip())
			EndDo
		EndIf

		(_cAlias)->(DbCloseArea())


	EndIf

	//-- AJUSTE DE CAMADA POR OP - COM APONTAMENTO ------------------------------------------------
	If nRadMenu1 == 2

		_cAlias	:=	GetNExtAlias()

		//BACKUP
		QR001 := "  SELECT " + CRLF
		QR001 += "  SD4.D4_FILIAL 					 Z05_FILIAL, " + CRLF  
		QR001 += "  SD4.D4_COD 						 Z05_PRODUT, " + CRLF  
		QR001 += "  SD4.D4_LOTECTL 					 Z05_LOTCTL, " + CRLF  
		QR001 += "  SD4.D4_NUMLOTE 					Z05_NUMLOT, " + CRLF  
		QR001 += "  '' 								Z05_LOCALZ, " + CRLF  
		QR001 += "  SD4.D4_DTVALID  				Z05_DTVALI, " + CRLF  
		QR001 += "  SD4.D4_LOCAL    				Z05_LOCAL, " + CRLF  
		QR001 += "  SD4.D4_OP 						Z05_OP, " + CRLF  
		QR001 += "  SD4.D4_DATA						Z05_EMISSA, " + CRLF  
		QR001 += "  SD4.D4_TRT 						Z05_TMTRT, " + CRLF  
		QR001 += "  SD4.D4_QTDEORI  				Z05_QTDORI, " + CRLF  
		QR001 += "  SD4.D4_QUANT    				Z05_QUANT, " + CRLF  
		QR001 += "	'SD4' 							Z05_TABELA, " + CRLF  
		QR001 += "	SD4.R_E_C_N_O_  				Z05_RECORI, " + CRLF  
		QR001 += "	'002'  							Z05_ORIBKP, " + CRLF  
		QR001 += "	'Ajuste de camada por OP - COM Apontamento' 	Z05_ORBKDE, " + CRLF  
		QR001 += "	'"+UsrRetName(RetCodUsr())+"'	Z05_USRALT, " + CRLF
		QR001 += "	'"+DTOS(DATE())+"'				Z05_DTALT, " + CRLF
		QR001 += "	'"+TIME()+"'					Z05_HRALT, " + CRLF
		QR001 += "	"+ValtoSql(MV_PAR11)+"  		Z05_JUSTIF, " + CRLF
		QR001 += "	'' 								D_E_L_E_T_, " + CRLF
		QR001 += "	B1_DESC 						DESCRI	," + CRLF  
		QR001 += "	C2_QUANT * "+Alltrim(Str(kCamada)) + "	NEWVAL1,	" + CRLF
		QR001 += "	(C2_QUANT-C2_QUJE) * "+Alltrim(Str(kCamada))+"	NEWVAL2	" + CRLF

		QR001 += "   FROM "+RetSqlName("SD4")+" SD4 (NOLOCK) " + CRLF
		QR001 += "  INNER JOIN "+RetSqlName("SC2")+" SC2 (NOLOCK)  ON C2_FILIAL = '"+xFilial("SC2")+"' " + CRLF
		QR001 += "                       AND C2_NUM = SUBSTRING(D4_OP,1,6) " + CRLF
		QR001 += "                       AND C2_ITEM = SUBSTRING(D4_OP,7,2) " + CRLF
		QR001 += "                       AND C2_SEQUEN = SUBSTRING(D4_OP,9,3) " + CRLF
		QR001 += "                       AND C2_DATRF = '        ' " + CRLF
		QR001 += "                       AND SC2.D_E_L_E_T_ = ' ' " + CRLF
		QR001 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 (NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
		QR001 += "                       AND B1_COD = SD4.D4_COD " + CRLF
		QR001 += "                       AND SB1.D_E_L_E_T_ = ' ' " + CRLF			
		QR001 += "  WHERE D4_FILIAL = '"+xFilial("SD4")+"' " + CRLF
		QR001 += "    AND SUBSTRING(D4_OP,1,6) IN('"+kNumOP+"') " + CRLF
		QR001 += "    AND D4_COD = '"+kCodCmp+"' " + CRLF
		QR001 += "    AND EXISTS (SELECT * " + CRLF
		QR001 += "                  FROM "+RetSqlName("SD3")+" XD3 (NOLOCK) " + CRLF
		QR001 += "                 WHERE D3_FILIAL = '"+xFilial("SD3")+"' " + CRLF
		QR001 += "                   AND D3_OP = D4_OP " + CRLF
		QR001 += "                   AND D3_TM = '010' " + CRLF
		QR001 += "                   AND XD3.D_E_L_E_T_ = ' ') " + CRLF
		QR001 += "    AND SD4.D_E_L_E_T_ = ' ' " + CRLF

		QrIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,QR001),_cAlias,.T.,.F.)
		dbSelectArea(_cAlias)
		dbGoTop()

		_aRecnos	:=	fMrkBrw(_cAlias)

		(_cAlias)->(DbGoTop())

		If Len(_aRecnos) > 0
			While (_cAlias)->(!EOF())
				If aScan(_aRecnos,{|x| x == (_cAlias)->Z05_RECORI}) > 0
					SD4->(DbGoTo((_cAlias)->Z05_RECORI))
					If SD4->(!EOF())
						//Backup
						Reclock("Z05",.T.)
						For _nI	:= 1 to (_cAlias)->(fCount())
							If AllTrim((_cAlias)->(FieldName(_nI))) $ "Z05_DTVALI/Z05_EMISSA/Z05_DTALT"
								&("Z05->"+(_cAlias)->(FieldName(_nI)))	:=	Stod((_cAlias)->(FieldGet(_nI)))
							ElseIf "Z05" $ (_cAlias)->(FieldName(_nI))
								&("Z05->"+(_cAlias)->(FieldName(_nI)))	:=	(_cAlias)->(FieldGet(_nI))
							EndIF
						Next
						Z05->(MsUnlock())
						Reclock("SD4",.F.)
						SD4->D4_QTDEORI	:=	(_cAlias)->NEWVAL1
						SD4->D4_QUANT	:=	(_cAlias)->NEWVAL2
						SD4->(MsUnlock())
					EndIf
				EndIF
				(_cALias)->(DbSkip())
			EndDo
		EndIf

		(_cAlias)->(DbCloseArea())

	EndIf

	//-- ACERTANDO BAIXAS PARA UM DETERMINADO INSUMO POR OP ---------------------------------------
	If nRadMenu1 == 3

		_cAlias	:=	GetNExtAlias()

		QR001 := "  SELECT " + CRLF
		QR001 += "  SD3.D3_FILIAL 					Z05_FILIAL, " + CRLF  
		QR001 += "  SD3.D3_COD 						Z05_PRODUT, " + CRLF  
		QR001 += "  SD3.D3_LOTECTL 					Z05_LOTCTL, " + CRLF  
		QR001 += "  SD3.D3_NUMLOTE 					Z05_NUMLOT, " + CRLF  
		QR001 += "  SD3.D3_LOCALIZ					Z05_LOCALZ, " + CRLF  
		QR001 += "  SD3.D3_DTVALID  				Z05_DTVALI, " + CRLF  
		QR001 += "  SD3.D3_LOCAL    				Z05_LOCAL, " + CRLF  
		QR001 += "  SD3.D3_OP 						Z05_OP, " + CRLF  
		QR001 += "  SD3.D3_EMISSAO					Z05_EMISSA, " + CRLF  
		QR001 += "  SD3.D3_TM 						Z05_TMTRT, " + CRLF  
		QR001 += "  0				 				Z05_QTDORI, " + CRLF  
		QR001 += "  SD3.D3_QUANT    				Z05_QUANT, " + CRLF  
		QR001 += "	'SD3' 							Z05_TABELA, " + CRLF  
		QR001 += "	SD3.R_E_C_N_O_  				Z05_RECORI, " + CRLF  
		QR001 += "	'003'  							Z05_ORIBKP, " + CRLF  
		QR001 += "	'Acertando baixas para um DETERMINADO insumo - POR OP' 	Z05_ORBKDE, " + CRLF  
		QR001 += "	'"+UsrRetName(RetCodUsr())+"'	Z05_USRALT, " + CRLF
		QR001 += "	'"+DTOS(DATE())+"'				Z05_DTALT, " + CRLF
		QR001 += "	'"+TIME()+"'					Z05_HRALT, " + CRLF
		QR001 += "	"+ValtoSql(MV_PAR11)+"  		Z05_JUSTIF, " + CRLF
		QR001 += "	'' 								D_E_L_E_T_, " + CRLF  
		QR001 += "	B1_DESC 						DESCRI	," + CRLF

		QR001 += "        ISNULL(ROUND((SELECT D3_QUANT " + CRLF
		QR001 += "                 		FROM "+RetSqlName("SD3")+" XD3 (NOLOCK) " + CRLF
		QR001 += "                		WHERE D3_FILIAL = '"+xFilial("SD3")+"' " + CRLF
		QR001 += "                  	AND D3_EMISSAO = SD3.D3_EMISSAO " + CRLF
		QR001 += "                  	AND D3_NUMSEQ = SD3.D3_NUMSEQ " + CRLF
		QR001 += "                  	AND D3_TM = '010' " + CRLF
		QR001 += "                  	AND D_E_L_E_T_ = ' ') * "+Alltrim(Str(kCamada))+",8) ,0) NEWVAL1 " + CRLF

		QR001 += "   FROM "+RetSqlName("SD3")+" SD3 (NOLOCK) " + CRLF
		QR001 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 (NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
		QR001 += "                       AND B1_COD = SD3.D3_COD " + CRLF
		QR001 += "                       AND SB1.D_E_L_E_T_ = ' ' " + CRLF			
		QR001 += "  WHERE D3_FILIAL = '"+xFilial("SD3")+"' " + CRLF
		QR001 += "    AND D3_EMISSAO BETWEEN '"+kDatIni+"' AND '"+kDatFin+"' " + CRLF
		QR001 += "    AND SUBSTRING(D3_OP,1,6) IN('"+kNumOP+"') " + CRLF
		QR001 += "    AND D3_COD = '"+kCodCmp+"' " + CRLF
		QR001 += "    AND D3_TM <> '010' " + CRLF
		QR001 += "    AND SD3.D_E_L_E_T_ = ' ' " + CRLF


		QrIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,QR001),_cAlias,.T.,.F.)
		dbSelectArea(_cAlias)
		dbGoTop()

		_aRecnos	:=	fMrkBrw(_cAlias)

		(_cAlias)->(DbGoTop())

		If Len(_aRecnos) > 0
			While (_cAlias)->(!EOF())
				If aScan(_aRecnos,{|x| x == (_cAlias)->Z05_RECORI}) > 0
					SD3->(DbGoTo((_cAlias)->Z05_RECORI))
					If SD3->(!EOF())
						//Backup
						Reclock("Z05",.T.)
						For _nI	:= 1 to (_cAlias)->(fCount())
							If AllTrim((_cAlias)->(FieldName(_nI))) $ "Z05_DTVALI/Z05_EMISSA/Z05_DTALT"
								&("Z05->"+(_cAlias)->(FieldName(_nI)))	:=	Stod((_cAlias)->(FieldGet(_nI)))
							ElseIf "Z05" $ (_cAlias)->(FieldName(_nI))
								&("Z05->"+(_cAlias)->(FieldName(_nI)))	:=	(_cAlias)->(FieldGet(_nI))
							EndIF
						Next
						Z05->(MsUnlock())
						Reclock("SD3",.F.)
						SD3->D3_QTSEGUM	:=	(_cAlias)->NEWVAL1
						SD3->D3_QUANT	:=	(_cAlias)->NEWVAL1
						SD3->(MsUnlock())
						fAtuVetEst()
					EndIf
				EndIF
				(_cALias)->(DbSkip())
			EndDo
		EndIf

		(_cAlias)->(DbCloseArea())


	EndIf

	//-- ACERTANDO BAIXAS AJUSTE DE CAMADA DIRETA DO INSUMO - POR FORMATO -------------------------
	If nRadMenu1 == 4

		_cAlias	:=	GetNExtAlias()

		//BACKUP

		QR001 := "  SELECT " + CRLF
		QR001 += "  SD3.D3_FILIAL 					Z05_FILIAL, " + CRLF  
		QR001 += "  SD3.D3_COD 						Z05_PRODUT, " + CRLF  
		QR001 += "  SD3.D3_LOTECTL 					Z05_LOTCTL, " + CRLF  
		QR001 += "  SD3.D3_NUMLOTE 					Z05_NUMLOT, " + CRLF  
		QR001 += "  SD3.D3_LOCALIZ					Z05_LOCALZ, " + CRLF  
		QR001 += "  SD3.D3_DTVALID  				Z05_DTVALI, " + CRLF  
		QR001 += "  SD3.D3_LOCAL    				Z05_LOCAL, " + CRLF  
		QR001 += "  SD3.D3_OP 						Z05_OP, " + CRLF  
		QR001 += "  SD3.D3_EMISSAO					Z05_EMISSA, " + CRLF  
		QR001 += "  SD3.D3_TM 						Z05_TMTRT, " + CRLF  
		QR001 += "  0				 				Z05_QTDORI, " + CRLF  
		QR001 += "  SD3.D3_QUANT    				Z05_QUANT, " + CRLF  
		QR001 += "	'SD3' 							Z05_TABELA, " + CRLF  
		QR001 += "	SD3.R_E_C_N_O_  				Z05_RECORI, " + CRLF  
		QR001 += "	'004'  							Z05_ORIBKP, " + CRLF  
		QR001 += "	'Acertando baixas do insumo - AJUSTE DE CAMADA DIRETA - POR FORMATO' 	Z05_ORBKDE, " + CRLF  
		QR001 += "	'"+UsrRetName(RetCodUsr())+"'	Z05_USRALT, " + CRLF
		QR001 += "	'"+DTOS(DATE())+"'				Z05_DTALT, " + CRLF
		QR001 += "	'"+TIME()+"'					Z05_HRALT, " + CRLF
		QR001 += "	"+ValtoSql(MV_PAR11)+"  		Z05_JUSTIF, " + CRLF
		QR001 += "	'' 								D_E_L_E_T_, " + CRLF  
		QR001 += "	B1_DESC 						DESCRI	" + CRLF
		QR001 += "   FROM "+RetSqlName("SD3")+" SD3 (NOLOCK) " + CRLF
		QR001 += "  INNER JOIN "+RetSqlName("SC2")+" SC2 (NOLOCK) ON C2_FILIAL = '"+xFilial("SC2")+"' " + CRLF
		QR001 += "                       AND C2_NUM = SUBSTRING(D3_OP,1,6) " + CRLF
		QR001 += "                       AND C2_ITEM = SUBSTRING(D3_OP,7,2) " + CRLF
		QR001 += "                       AND C2_SEQUEN = SUBSTRING(D3_OP,9,3) " + CRLF
		QR001 += "                       AND SC2.D_E_L_E_T_ = ' ' " + CRLF
		QR001 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 (NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
		QR001 += "                       AND B1_COD = C2_PRODUTO " + CRLF
		QR001 += "                       AND B1_YFORMAT = '"+kFormat+"' " + CRLF
		If !Empty(kEspess)
			QR001 += "                       AND B1_YESPESS = '" + kEspess + "' " + CRLF
		EndIf
		QR001 += "                       AND SB1.D_E_L_E_T_ = ' ' " + CRLF
		QR001 += "  WHERE D3_FILIAL = '"+xFilial("SD3")+"' " + CRLF
		QR001 += "    AND D3_EMISSAO BETWEEN '"+kDatIni+"' AND '"+kDatFin+"' " + CRLF
		QR001 += "    AND D3_COD = '"+kCodCmp+"' " + CRLF
		QR001 += "    AND D3_TM <> '010' " + CRLF
		QR001 += "    AND D3_OP <> ' ' " + CRLF
		QR001 += "    AND SD3.D_E_L_E_T_ = ' ' " + CRLF

		QrIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,QR001),_cAlias,.T.,.F.)
		dbSelectArea(_cAlias)
		dbGoTop()

		_aRecnos	:=	fMrkBrw(_cAlias)

		(_cAlias)->(DbGoTop())

		If Len(_aRecnos) > 0
			While (_cAlias)->(!EOF())
				If aScan(_aRecnos,{|x| x == (_cAlias)->Z05_RECORI}) > 0
					SD3->(DbGoTo((_cAlias)->Z05_RECORI))
					If SD3->(!EOF())
						//Backup
						Reclock("Z05",.T.)
						For _nI	:= 1 to (_cAlias)->(fCount())
							If AllTrim((_cAlias)->(FieldName(_nI))) $ "Z05_DTVALI/Z05_EMISSA/Z05_DTALT"
								&("Z05->"+(_cAlias)->(FieldName(_nI)))	:=	Stod((_cAlias)->(FieldGet(_nI)))
							ElseIf "Z05" $ (_cAlias)->(FieldName(_nI))
								&("Z05->"+(_cAlias)->(FieldName(_nI)))	:=	(_cAlias)->(FieldGet(_nI))
							EndIF
						Next
						Z05->(MsUnlock())
						Reclock("SD3",.F.)
						SD3->D3_QTSEGUM	:=	SD3->D3_QTSEGUM * kCamada
						SD3->D3_QUANT	:=	SD3->D3_QUANT * kCamada
						SD3->(MsUnlock())
						fAtuVetEst()
					EndIf
				EndIF
				(_cALias)->(DbSkip())
			EndDo
		EndIf

		(_cAlias)->(DbCloseArea())

	EndIf

	//-- TROCA DE INSUMO PARA UMA DETERMINADA OP --------------------------------------------------
	If nRadMenu1 == 5

		_cAlias	:=	GetNExtAlias()

		QR001 := "  SELECT " + CRLF
		QR001 += "  SD4.D4_FILIAL 					Z05_FILIAL, " + CRLF  
		QR001 += "  SD4.D4_COD 						Z05_PRODUT, " + CRLF  
		QR001 += "  SD4.D4_LOTECTL 					Z05_LOTCTL, " + CRLF  
		QR001 += "  SD4.D4_NUMLOTE 					Z05_NUMLOT, " + CRLF  
		QR001 += "  '' 								Z05_LOCALZ, " + CRLF  
		QR001 += "  SD4.D4_DTVALID  				Z05_DTVALI, " + CRLF  
		QR001 += "  SD4.D4_LOCAL    				Z05_LOCAL, " + CRLF  
		QR001 += "  SD4.D4_OP 						Z05_OP, " + CRLF  
		QR001 += "  SD4.D4_DATA						Z05_EMISSA, " + CRLF  
		QR001 += "  SD4.D4_TRT 						Z05_TMTRT, " + CRLF  
		QR001 += "  SD4.D4_QTDEORI  				Z05_QTDORI, " + CRLF  
		QR001 += "  SD4.D4_QUANT    				Z05_QUANT, " + CRLF  
		QR001 += "	'SD4' 							Z05_TABELA, " + CRLF  
		QR001 += "	SD4.R_E_C_N_O_  				Z05_RECORI, " + CRLF  
		QR001 += "	'005'  							Z05_ORIBKP, " + CRLF  
		QR001 += "	'Troca de insumo para uma DETERMINADA OP' 	Z05_ORBKDE, " + CRLF  
		QR001 += "	'"+UsrRetName(RetCodUsr())+"'	Z05_USRALT, " + CRLF
		QR001 += "	'"+DTOS(DATE())+"'				Z05_DTALT, " + CRLF
		QR001 += "	'"+TIME()+"'					Z05_HRALT, " + CRLF
		QR001 += "	"+ValtoSql(MV_PAR11)+"  		Z05_JUSTIF, " + CRLF
		QR001 += "	'' 								D_E_L_E_T_, " + CRLF 
		QR001 += "	B1_DESC 						DESCRI	" + CRLF
		QR001 += "   FROM "+RetSqlName("SD4")+" SD4 (NOLOCK) " + CRLF
		QR001 += "  INNER JOIN "+RetSqlName("SC2")+" SC2 (NOLOCK) ON C2_FILIAL = '"+xFilial("SC2")+"' " + CRLF
		QR001 += "                       AND C2_NUM = SUBSTRING(D4_OP,1,6) " + CRLF
		QR001 += "                       AND C2_ITEM = SUBSTRING(D4_OP,7,2) " + CRLF
		QR001 += "                       AND C2_SEQUEN = SUBSTRING(D4_OP,9,3) " + CRLF
		QR001 += "                       AND C2_DATRF = '        ' " + CRLF
		QR001 += "                       AND SC2.D_E_L_E_T_ = ' ' " + CRLF
		QR001 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 (NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
		QR001 += "                       AND B1_COD = SD4.D4_COD " + CRLF
		QR001 += "                       AND SB1.D_E_L_E_T_ = ' ' " + CRLF	
		QR001 += "  WHERE D4_FILIAL = '"+xFilial("SD4")+"' " + CRLF
		QR001 += "    AND D4_OP LIKE '%"+kNumOP+"%' " + CRLF
		QR001 += "    AND D4_COD = '"+kCodCmp+"' " + CRLF
		QR001 += "    AND D4_QUANT <> 0 " + CRLF
		QR001 += "    AND NOT EXISTS( " + CRLF
		QR001 += "    					SELECT 1 FROM "+RETSQLNAME("SD4")+" XD4 " + CRLF
		QR001 += "    WHERE SD4.D4_FILIAL = XD4.D4_FILIAL " + CRLF
		QR001 += "    				AND SD4.D4_OP = XD4.D4_OP " + CRLF
		QR001 += "    				AND XD4.D4_COD = "+ValtoSql(kNewCmp) + CRLF
		QR001 += "    				AND XD4.D_E_L_E_T_ = '' ) " + CRLF
		QR001 += "    AND SD4.D_E_L_E_T_ = ' ' " + CRLF

		QrIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,QR001),_cAlias,.T.,.F.)
		dbSelectArea(_cAlias)
		dbGoTop()

		_aRecnos	:=	fMrkBrw(_cAlias)

		(_cAlias)->(DbGoTop())

		If Len(_aRecnos) > 0
			While (_cAlias)->(!EOF())
				If aScan(_aRecnos,{|x| x == (_cAlias)->Z05_RECORI}) > 0
					SD4->(DbGoTo((_cAlias)->Z05_RECORI))
					If SD4->(!EOF())
						//Backup
						Reclock("Z05",.T.)
						For _nI	:= 1 to (_cAlias)->(fCount())
							If AllTrim((_cAlias)->(FieldName(_nI))) $ "Z05_DTVALI/Z05_EMISSA/Z05_DTALT"
								&("Z05->"+(_cAlias)->(FieldName(_nI)))	:=	Stod((_cAlias)->(FieldGet(_nI)))
							ElseIf "Z05" $ (_cAlias)->(FieldName(_nI))
								&("Z05->"+(_cAlias)->(FieldName(_nI)))	:=	(_cAlias)->(FieldGet(_nI))
							EndIF
						Next
						Z05->(MsUnlock())
						Reclock("SD4",.F.)
						SD4->D4_TRT	:=	"ZZZ"
						SD4->D4_COD	:=	kNewCmp
						SD4->(MsUnlock())
					EndIf

				EndIF
				(_cALias)->(DbSkip())
			EndDo
		EndIf

		(_cAlias)->(DbCloseArea())



	EndIf

	//-- TROCA DE INSUMO PARA UMA DETERMINADA REFERENCIA ------------------------------------------
	If nRadMenu1 == 6

		_cAlias	:=	GetNExtAlias()

		//BACKUP
		QR001 := "  SELECT " + CRLF
		QR001 += "  SD4.D4_FILIAL 					Z05_FILIAL, " + CRLF  
		QR001 += "  SD4.D4_COD 						Z05_PRODUT, " + CRLF  
		QR001 += "  SD4.D4_LOTECTL 					Z05_LOTCTL, " + CRLF  
		QR001 += "  SD4.D4_NUMLOTE 					Z05_NUMLOT, " + CRLF  
		QR001 += "  '' 								Z05_LOCALZ, " + CRLF  
		QR001 += "  SD4.D4_DTVALID  				Z05_DTVALI, " + CRLF  
		QR001 += "  SD4.D4_LOCAL    				Z05_LOCAL, " + CRLF  
		QR001 += "  SD4.D4_OP 						Z05_OP, " + CRLF  
		QR001 += "  SD4.D4_DATA						Z05_EMISSA, " + CRLF  
		QR001 += "  SD4.D4_TRT 						Z05_TMTRT, " + CRLF  
		QR001 += "  SD4.D4_QTDEORI  				Z05_QTDORI, " + CRLF  
		QR001 += "  SD4.D4_QUANT    				Z05_QUANT, " + CRLF  
		QR001 += "	'SD4' 							Z05_TABELA, " + CRLF  
		QR001 += "	SD4.R_E_C_N_O_  				Z05_RECORI, " + CRLF  
		QR001 += "	'006'  							Z05_ORIBKP, " + CRLF  
		QR001 += "	'Troca de insumo para uma DETERMINADA REFERENCIA' 	Z05_ORBKDE, " + CRLF  
		QR001 += "	'"+UsrRetName(RetCodUsr())+"'	Z05_USRALT, " + CRLF
		QR001 += "	'"+DTOS(DATE())+"'				Z05_DTALT, " + CRLF
		QR001 += "	'"+TIME()+"'					Z05_HRALT, " + CRLF
		QR001 += "	"+ValtoSql(MV_PAR11)+"  		Z05_JUSTIF, " + CRLF
		QR001 += "	'' 								D_E_L_E_T_, " + CRLF  
		QR001 += "	B1_DESC 						DESCRI	" + CRLF
		QR001 += "   FROM "+RetSqlName("SD4")+" SD4 (NOLOCK) " + CRLF
		QR001 += "  INNER JOIN "+RetSqlName("SC2")+" SC2 (NOLOCK) ON C2_FILIAL = '"+xFilial("SC2")+"' " + CRLF
		QR001 += "                       AND C2_NUM = SUBSTRING(D4_OP,1,6) " + CRLF
		QR001 += "                       AND C2_ITEM = SUBSTRING(D4_OP,7,2) " + CRLF
		QR001 += "                       AND C2_SEQUEN = SUBSTRING(D4_OP,9,3) " + CRLF
		QR001 += "                       AND SUBSTRING(C2_PRODUTO,1,7) = '"+kRefPrd+"' " + CRLF
		QR001 += "                       AND C2_DATRF = '        ' " + CRLF
		QR001 += "                       AND SC2.D_E_L_E_T_ = ' ' " + CRLF
		QR001 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 (NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
		QR001 += "                       AND B1_COD = C2_PRODUTO " + CRLF
		QR001 += "                       AND SB1.D_E_L_E_T_ = ' ' " + CRLF
		QR001 += "  WHERE D4_FILIAL = '"+xFilial("SD4")+"' " + CRLF
		QR001 += "    AND D4_COD = '"+kCodCmp+"' " + CRLF
		QR001 += "    AND D4_QUANT <> 0 " + CRLF
		QR001 += "    AND NOT EXISTS( " + CRLF
		QR001 += "    					SELECT 1 FROM "+RETSQLNAME("SD4")+" XD4 " + CRLF
		QR001 += "    WHERE SD4.D4_FILIAL = XD4.D4_FILIAL " + CRLF
		QR001 += "    				AND SD4.D4_OP = XD4.D4_OP " + CRLF
		QR001 += "    				AND XD4.D4_COD = "+ValtoSql(kNewCmp) + CRLF
		QR001 += "    				AND XD4.D_E_L_E_T_ = '' ) " + CRLF		
		QR001 += "    AND SD4.D_E_L_E_T_ = ' ' " + CRLF

		QrIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,QR001),_cAlias,.T.,.F.)
		dbSelectArea(_cAlias)
		dbGoTop()

		_aRecnos	:=	fMrkBrw(_cAlias)

		(_cAlias)->(DbGoTop())

		If Len(_aRecnos) > 0
			While (_cAlias)->(!EOF())
				If aScan(_aRecnos,{|x| x == (_cAlias)->Z05_RECORI}) > 0
					SD4->(DbGoTo((_cAlias)->Z05_RECORI))
					If SD4->(!EOF())
						//Backup
						Reclock("Z05",.T.)
						For _nI	:= 1 to (_cAlias)->(fCount())
							If AllTrim((_cAlias)->(FieldName(_nI))) $ "Z05_DTVALI/Z05_EMISSA/Z05_DTALT"
								&("Z05->"+(_cAlias)->(FieldName(_nI)))	:=	Stod((_cAlias)->(FieldGet(_nI)))
							ElseIf "Z05" $ (_cAlias)->(FieldName(_nI))
								&("Z05->"+(_cAlias)->(FieldName(_nI)))	:=	(_cAlias)->(FieldGet(_nI))
							EndIF
						Next
						Z05->(MsUnlock())
						Reclock("SD4",.F.)
						SD4->D4_TRT	:=	"ZZZ"
						SD4->D4_COD	:=	kNewCmp
						SD4->(MsUnlock())

					EndIf
				EndIF
				(_cALias)->(DbSkip())
			EndDo
		EndIf

		(_cAlias)->(DbCloseArea())

	EndIf

	//-- TROCA DE INSUMO PARA UM DETERMINADO FORMATO ----------------------------------------------
	If nRadMenu1 == 7

		_cAlias	:=	GetNExtAlias()

		QR001 := "  SELECT " + CRLF
		QR001 += "  SD4.D4_FILIAL 					Z05_FILIAL, " + CRLF  
		QR001 += "  SD4.D4_COD 						Z05_PRODUT, " + CRLF  
		QR001 += "  SD4.D4_LOTECTL 					Z05_LOTCTL, " + CRLF  
		QR001 += "  SD4.D4_NUMLOTE 					Z05_NUMLOT, " + CRLF  
		QR001 += "  '' 								Z05_LOCALZ, " + CRLF  
		QR001 += "  SD4.D4_DTVALID  				Z05_DTVALI, " + CRLF  
		QR001 += "  SD4.D4_LOCAL    				Z05_LOCAL, " + CRLF  
		QR001 += "  SD4.D4_OP 						Z05_OP, " + CRLF  
		QR001 += "  SD4.D4_DATA						Z05_EMISSA, " + CRLF  
		QR001 += "  SD4.D4_TRT 						Z05_TMTRT, " + CRLF  
		QR001 += "  SD4.D4_QTDEORI  				Z05_QTDORI, " + CRLF  
		QR001 += "  SD4.D4_QUANT    				Z05_QUANT, " + CRLF  
		QR001 += "	'SD4' 							Z05_TABELA, " + CRLF  
		QR001 += "	SD4.R_E_C_N_O_  				Z05_RECORI, " + CRLF  
		QR001 += "	'007'  							Z05_ORIBKP, " + CRLF  
		QR001 += "	'Troca de insumo para um DETERMINADO FORMATO' 	Z05_ORBKDE, " + CRLF  
		QR001 += "	'"+UsrRetName(RetCodUsr())+"'	Z05_USRALT, " + CRLF
		QR001 += "	'"+DTOS(DATE())+"'				Z05_DTALT, " + CRLF
		QR001 += "	'"+TIME()+"'					Z05_HRALT, " + CRLF
		QR001 += "	"+ValtoSql(MV_PAR11)+"  		Z05_JUSTIF, " + CRLF
		QR001 += "	'' 								D_E_L_E_T_, " + CRLF
		QR001 += "	B1_DESC 						DESCRI	" + CRLF
		QR001 += "   FROM "+RetSqlName("SD4")+" SD4 (NOLOCK) " + CRLF
		QR001 += "  INNER JOIN "+RetSqlName("SC2")+" SC2 (NOLOCK) ON C2_FILIAL = '"+xFilial("SC2")+"' " + CRLF
		QR001 += "                       AND C2_NUM = SUBSTRING(D4_OP,1,6) " + CRLF
		QR001 += "                       AND C2_ITEM = SUBSTRING(D4_OP,7,2) " + CRLF
		QR001 += "                       AND C2_SEQUEN = SUBSTRING(D4_OP,9,3) " + CRLF
		QR001 += "                       AND C2_DATRF = '        ' " + CRLF
		QR001 += "                       AND SC2.D_E_L_E_T_ = ' ' " + CRLF
		QR001 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 (NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
		QR001 += "                       AND B1_COD = C2_PRODUTO " + CRLF
		QR001 += "                       AND B1_YFORMAT = '"+kFormat+"' " + CRLF
		QR001 += "                       AND SB1.D_E_L_E_T_ = ' ' " + CRLF
		QR001 += "  WHERE D4_FILIAL = '"+xFilial("SD4")+"' " + CRLF
		QR001 += "    AND D4_COD = '"+kCodCmp+"' " + CRLF
		QR001 += "    AND D4_QUANT <> 0 " + CRLF
		QR001 += "    AND NOT EXISTS( " + CRLF
		QR001 += "    					SELECT 1 FROM "+RETSQLNAME("SD4")+" XD4 " + CRLF
		QR001 += "    WHERE SD4.D4_FILIAL = XD4.D4_FILIAL " + CRLF
		QR001 += "    				AND SD4.D4_OP = XD4.D4_OP " + CRLF
		QR001 += "    				AND XD4.D4_COD = "+ValtoSql(kNewCmp) + CRLF
		QR001 += "    				AND XD4.D_E_L_E_T_ = '' ) " + CRLF		
		QR001 += "    AND SD4.D_E_L_E_T_ = ' ' " + CRLF

		QrIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,QR001),_cAlias,.T.,.F.)
		dbSelectArea(_cAlias)
		dbGoTop()

		_aRecnos	:=	fMrkBrw(_cAlias)

		(_cAlias)->(DbGoTop())

		If Len(_aRecnos) > 0
			While (_cAlias)->(!EOF())
				If aScan(_aRecnos,{|x| x == (_cAlias)->Z05_RECORI}) > 0
					SD4->(DbGoTo((_cAlias)->Z05_RECORI))
					If SD4->(!EOF())
						//Backup
						Reclock("Z05",.T.)
						For _nI	:= 1 to (_cAlias)->(fCount())
							If AllTrim((_cAlias)->(FieldName(_nI))) $ "Z05_DTVALI/Z05_EMISSA/Z05_DTALT"
								&("Z05->"+(_cAlias)->(FieldName(_nI)))	:=	Stod((_cAlias)->(FieldGet(_nI)))
							ElseIf "Z05" $ (_cAlias)->(FieldName(_nI))
								&("Z05->"+(_cAlias)->(FieldName(_nI)))	:=	(_cAlias)->(FieldGet(_nI))
							EndIF
						Next
						Z05->(MsUnlock())
						Reclock("SD4",.F.)
						SD4->D4_TRT	:=	"ZZZ"
						SD4->D4_COD	:=	kNewCmp
						SD4->(MsUnlock())
					EndIf
				EndIF
				(_cALias)->(DbSkip())
			EndDo
		EndIf

		(_cAlias)->(DbCloseArea())

	EndIf

	//-- TROCA DE INSUMO - UM POR OUTRO DIRETO ----------------------------------------------------
	If nRadMenu1 == 8

		_cAlias	:=	GetNExtAlias()

		QR001 := "  SELECT " + CRLF
		QR001 += "  SD4.D4_FILIAL 					Z05_FILIAL, " + CRLF  
		QR001 += "  SD4.D4_COD 						Z05_PRODUT, " + CRLF  
		QR001 += "  SD4.D4_LOTECTL 					Z05_LOTCTL, " + CRLF  
		QR001 += "  SD4.D4_NUMLOTE 					Z05_NUMLOT, " + CRLF  
		QR001 += "  '' 								Z05_LOCALZ, " + CRLF  
		QR001 += "  SD4.D4_DTVALID  				Z05_DTVALI, " + CRLF  
		QR001 += "  SD4.D4_LOCAL    				Z05_LOCAL, " + CRLF  
		QR001 += "  SD4.D4_OP 						Z05_OP, " + CRLF  
		QR001 += "  SD4.D4_DATA						Z05_EMISSA, " + CRLF  
		QR001 += "  SD4.D4_TRT 						Z05_TMTRT, " + CRLF  
		QR001 += "  SD4.D4_QTDEORI  				Z05_QTDORI, " + CRLF  
		QR001 += "  SD4.D4_QUANT    				Z05_QUANT, " + CRLF  
		QR001 += "	'SD4' 							Z05_TABELA, " + CRLF  
		QR001 += "	SD4.R_E_C_N_O_  				Z05_RECORI, " + CRLF  
		QR001 += "	'008'  							Z05_ORIBKP, " + CRLF  
		QR001 += "	'Troca de insumo - UM POR OUTRO DIRETO' 	Z05_ORBKDE, " + CRLF  
		QR001 += "	'"+UsrRetName(RetCodUsr())+"'	Z05_USRALT, " + CRLF
		QR001 += "	'"+DTOS(DATE())+"'				Z05_DTALT, " + CRLF
		QR001 += "	'"+TIME()+"'					Z05_HRALT, " + CRLF
		QR001 += "	"+ValtoSql(MV_PAR11)+"  		Z05_JUSTIF, " + CRLF
		QR001 += "	'' 								D_E_L_E_T_, " + CRLF  
		QR001 += "	B1_DESC 						DESCRI	" + CRLF		
		QR001 += "   FROM "+RetSqlName("SD4")+" SD4 (NOLOCK) " + CRLF
		QR001 += "  INNER JOIN "+RetSqlName("SC2")+" SC2 (NOLOCK) ON C2_FILIAL = '"+xFilial("SC2")+"' " + CRLF
		QR001 += "                       AND C2_NUM = SUBSTRING(D4_OP,1,6) " + CRLF
		QR001 += "                       AND C2_ITEM = SUBSTRING(D4_OP,7,2) " + CRLF
		QR001 += "                       AND C2_SEQUEN = SUBSTRING(D4_OP,9,3) " + CRLF
		QR001 += "                       AND C2_DATRF = '        ' " + CRLF
		QR001 += "                       AND SC2.D_E_L_E_T_ = ' ' " + CRLF
		QR001 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 (NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
		QR001 += "                       AND B1_COD = C2_PRODUTO " + CRLF
		QR001 += "                       AND SB1.D_E_L_E_T_ = ' ' " + CRLF
		QR001 += "  WHERE D4_FILIAL = '"+xFilial("SD4")+"' " + CRLF
		QR001 += "    AND D4_COD = '"+kCodCmp+"' " + CRLF
		QR001 += "    AND D4_QUANT <> 0 " + CRLF
		If !Empty(MV_PAR10)
			QR001 += "    AND D4_LOCAL =  " + ValtoSql(MV_PAR10) + CRLF
		EndIf

		QR001 += "    AND NOT EXISTS( " + CRLF
		QR001 += "    					SELECT 1 FROM "+RETSQLNAME("SD4")+" XD4 " + CRLF
		QR001 += "    WHERE SD4.D4_FILIAL = XD4.D4_FILIAL " + CRLF
		QR001 += "    				AND SD4.D4_OP = XD4.D4_OP " + CRLF
		QR001 += "    				AND XD4.D4_COD = "+ValtoSql(kNewCmp) + CRLF
		QR001 += "    				AND XD4.D_E_L_E_T_ = '' ) " + CRLF	

		QR001 += "    AND SD4.D_E_L_E_T_ = ' ' " + CRLF


		QrIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,QR001),_cAlias,.T.,.F.)
		dbSelectArea(_cAlias)
		dbGoTop()

		_aRecnos	:=	fMrkBrw(_cAlias)

		(_cAlias)->(DbGoTop())

		If Len(_aRecnos) > 0
			While (_cAlias)->(!EOF())
				If aScan(_aRecnos,{|x| x == (_cAlias)->Z05_RECORI}) > 0
					SD4->(DbGoTo((_cAlias)->Z05_RECORI))
					If SD4->(!EOF())
						//Backup
						Reclock("Z05",.T.)
						For _nI	:= 1 to (_cAlias)->(fCount())
							If AllTrim((_cAlias)->(FieldName(_nI))) $ "Z05_DTVALI/Z05_EMISSA/Z05_DTALT"
								&("Z05->"+(_cAlias)->(FieldName(_nI)))	:=	Stod((_cAlias)->(FieldGet(_nI)))
							ElseIf "Z05" $ (_cAlias)->(FieldName(_nI))
								&("Z05->"+(_cAlias)->(FieldName(_nI)))	:=	(_cAlias)->(FieldGet(_nI))
							EndIF
						Next
						Z05->(MsUnlock())
						Reclock("SD4",.F.)
						SD4->D4_TRT	:=	"ZZZ"
						SD4->D4_COD	:=	kNewCmp
						SD4->(MsUnlock())
					EndIf
				EndIF
				(_cALias)->(DbSkip())
			EndDo
		EndIf

		(_cAlias)->(DbCloseArea())

	EndIf

	//-- AJUSTE DE CAMADA POR FORMATO - COM APONTAMENTO -------------------------------------------
	If nRadMenu1 == 9

		_cAlias	:=	GetNExtAlias()	

		QR001 := "  SELECT " + CRLF
		QR001 += "  SD4.D4_FILIAL 					Z05_FILIAL, " + CRLF  
		QR001 += "  SD4.D4_COD 						Z05_PRODUT, " + CRLF  
		QR001 += "  SD4.D4_LOTECTL 					Z05_LOTCTL, " + CRLF  
		QR001 += "  SD4.D4_NUMLOTE 					Z05_NUMLOT, " + CRLF  
		QR001 += "  '' 								Z05_LOCALZ, " + CRLF  
		QR001 += "  SD4.D4_DTVALID  				Z05_DTVALI, " + CRLF  
		QR001 += "  SD4.D4_LOCAL    				Z05_LOCAL, " + CRLF  
		QR001 += "  SD4.D4_OP 						Z05_OP, " + CRLF  
		QR001 += "  SD4.D4_DATA						Z05_EMISSA, " + CRLF  
		QR001 += "  SD4.D4_TRT 						Z05_TMTRT, " + CRLF  
		QR001 += "  SD4.D4_QTDEORI  				Z05_QTDORI, " + CRLF  
		QR001 += "  SD4.D4_QUANT    				Z05_QUANT, " + CRLF  
		QR001 += "	'SD4' 							Z05_TABELA, " + CRLF  
		QR001 += "	SD4.R_E_C_N_O_  				Z05_RECORI, " + CRLF  
		QR001 += "	'009'  							Z05_ORIBKP, " + CRLF  
		QR001 += "	'Ajuste de camada POR FORMATO - COM Apontamento' 	Z05_ORBKDE, " + CRLF  
		QR001 += "	'"+UsrRetName(RetCodUsr())+"'	Z05_USRALT, " + CRLF
		QR001 += "	'"+DTOS(DATE())+"'				Z05_DTALT, " + CRLF
		QR001 += "	'"+TIME()+"'					Z05_HRALT, " + CRLF
		QR001 += "	"+ValtoSql(MV_PAR11)+"  		Z05_JUSTIF, " + CRLF
		QR001 += "	'' 								D_E_L_E_T_, " + CRLF  
		QR001 += "	SB1.B1_DESC   					DESCRI, " + CRLF
		QR001 += "	C2_QUANT * "+Alltrim(Str(kCamada)) + "	NEWVAL1,	" + CRLF
		QR001 += "	(C2_QUANT-C2_QUJE) * "+Alltrim(Str(kCamada))+"	NEWVAL2	" + CRLF
		QR001 += "   FROM "+RetSqlName("SD4")+" SD4 (NOLOCK) " + CRLF 
		QR001 += "  INNER JOIN "+RetSqlName("SC2")+" SC2 (NOLOCK) ON C2_FILIAL = '"+xFilial("SC2")+"' " + CRLF 
		QR001 += "                       AND C2_NUM = SUBSTRING(D4_OP,1,6) " + CRLF 
		QR001 += "                       AND C2_ITEM = SUBSTRING(D4_OP,7,2) " + CRLF 
		QR001 += "                       AND C2_SEQUEN = SUBSTRING(D4_OP,9,3) " + CRLF 
		QR001 += "                       AND C2_DATRF = '        ' " + CRLF 
		QR001 += "                       AND SC2.D_E_L_E_T_ = ' ' " + CRLF 
		QR001 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 (NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF 
		QR001 += "                       AND B1_COD = C2_PRODUTO " + CRLF 
		QR001 += "                       AND B1_YFORMAT = '"+kFormat+"' " + CRLF 
		QR001 += "                       AND SB1.D_E_L_E_T_ = ' ' " + CRLF 
		QR001 += "  WHERE D4_FILIAL = '"+xFilial("SD4")+"' " + CRLF 
		QR001 += "    AND D4_COD = '"+kCodCmp+"' " + CRLF 
		QR001 += "    AND EXISTS (SELECT * " + CRLF 
		QR001 += "                  FROM "+RetSqlName("SD3")+" XD3 (NOLOCK) " + CRLF 
		QR001 += "                 WHERE D3_FILIAL = '"+xFilial("SD3")+"' " + CRLF 
		QR001 += "                   AND D3_OP = D4_OP " + CRLF 
		QR001 += "                   AND D3_TM = '010' " + CRLF 
		QR001 += "                   AND XD3.D_E_L_E_T_ = ' ') " + CRLF 
		QR001 += "    AND SD4.D_E_L_E_T_ = ' ' " + CRLF 

		QrIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,QR001),_cAlias,.T.,.F.)
		dbSelectArea(_cAlias)
		dbGoTop()

		_aRecnos	:=	fMrkBrw(_cAlias)

		(_cAlias)->(DbGoTop())

		If Len(_aRecnos) > 0
			While (_cAlias)->(!EOF())
				If aScan(_aRecnos,{|x| x == (_cAlias)->Z05_RECORI}) > 0
					SD4->(DbGoTo((_cAlias)->Z05_RECORI))
					If SD4->(!EOF())
						//Backup
						Reclock("Z05",.T.)
						For _nI	:= 1 to (_cAlias)->(fCount())
							If AllTrim((_cAlias)->(FieldName(_nI))) $ "Z05_DTVALI/Z05_EMISSA/Z05_DTALT"
								&("Z05->"+(_cAlias)->(FieldName(_nI)))	:=	Stod((_cAlias)->(FieldGet(_nI)))
							ElseIf "Z05" $ (_cAlias)->(FieldName(_nI))
								&("Z05->"+(_cAlias)->(FieldName(_nI)))	:=	(_cAlias)->(FieldGet(_nI))
							EndIF
						Next
						Z05->(MsUnlock())
						Reclock("SD4",.F.)
						SD4->D4_QTDEORI	:=	(_cAlias)->NEWVAL1
						SD4->D4_QUANT	:=	(_cAlias)->NEWVAL2
						SD4->(MsUnlock())
					EndIf
				EndIF
				(_cALias)->(DbSkip())
			EndDo
		EndIf

		(_cAlias)->(DbCloseArea())

	EndIf

	//-- EXCLUIR INSUMO DOS ITENS EMPENHADOS ------------------------------------------------------
	If nRadMenu1 == 10

		_cAlias	:=	GetNExtAlias()	

		QR001 := "  SELECT " + CRLF
		QR001 += "  SD4.D4_FILIAL 					Z05_FILIAL, " + CRLF  
		QR001 += "  SD4.D4_COD 						Z05_PRODUT, " + CRLF  
		QR001 += "  SD4.D4_LOTECTL 					Z05_LOTCTL, " + CRLF  
		QR001 += "  SD4.D4_NUMLOTE 					Z05_NUMLOT, " + CRLF  
		QR001 += "  '' 								Z05_LOCALZ, " + CRLF  
		QR001 += "  SD4.D4_DTVALID  				Z05_DTVALI, " + CRLF  
		QR001 += "  SD4.D4_LOCAL    				Z05_LOCAL, " + CRLF  
		QR001 += "  SD4.D4_OP 						Z05_OP, " + CRLF  
		QR001 += "  SD4.D4_DATA						Z05_EMISSA, " + CRLF  
		QR001 += "  SD4.D4_TRT 						Z05_TMTRT, " + CRLF  
		QR001 += "  SD4.D4_QTDEORI  				Z05_QTDORI, " + CRLF  
		QR001 += "  SD4.D4_QUANT    				Z05_QUANT, " + CRLF  
		QR001 += "	'SD4' 							Z05_TABELA, " + CRLF  
		QR001 += "	SD4.R_E_C_N_O_  				Z05_RECORI, " + CRLF  
		QR001 += "	'010'  							Z05_ORIBKP, " + CRLF  
		QR001 += "	'Excluir insumo dos itens empenhados' 	Z05_ORBKDE, " + CRLF  
		QR001 += "	'"+UsrRetName(RetCodUsr())+"'	Z05_USRALT, " + CRLF
		QR001 += "	'"+DTOS(DATE())+"'				Z05_DTALT, " + CRLF
		QR001 += "	'"+TIME()+"'					Z05_HRALT, " + CRLF
		QR001 += "	"+ValtoSql(MV_PAR11)+"  		Z05_JUSTIF, " + CRLF
		QR001 += "	'' 								D_E_L_E_T_, " + CRLF
		QR001 += "	SB1.B1_DESC   					DESCRI " + CRLF
		QR001 += "   FROM "+RetSqlName("SD4")+" SD4 (NOLOCK) " + CRLF 
		QR001 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 (NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
		QR001 += "                       AND B1_COD = D4_COD " + CRLF
		QR001 += "                       AND SB1.D_E_L_E_T_ = ' ' " + CRLF
		QR001 += "  WHERE D4_FILIAL = '"+xFilial("SD4")+"' " + CRLF 
		QR001 += "    AND D4_DATA BETWEEN '"+kDatIni+"' AND '"+kDatFin+"' " + CRLF 
		QR001 += "    AND SUBSTRING(D4_OP,1,6) = '"+kNumOP+"' " + CRLF 
		QR001 += "    AND D4_COD = '"+kCodCmp+"' " + CRLF 
		QR001 += "    AND SD4.D_E_L_E_T_ = ' ' " + CRLF 

		QrIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,QR001),_cAlias,.T.,.F.)
		dbSelectArea(_cAlias)
		dbGoTop()

		_aRecnos	:=	fMrkBrw(_cAlias)

		(_cAlias)->(DbGoTop())

		If Len(_aRecnos) > 0
			While (_cAlias)->(!EOF())
				If aScan(_aRecnos,{|x| x == (_cAlias)->Z05_RECORI}) > 0
					SD4->(DbGoTo((_cAlias)->Z05_RECORI))
					If SD4->(!EOF())
						//Backup
						Reclock("Z05",.T.)
						For _nI	:= 1 to (_cAlias)->(fCount())
							If AllTrim((_cAlias)->(FieldName(_nI))) $ "Z05_DTVALI/Z05_EMISSA/Z05_DTALT"
								&("Z05->"+(_cAlias)->(FieldName(_nI)))	:=	Stod((_cAlias)->(FieldGet(_nI)))
							ElseIf "Z05" $ (_cAlias)->(FieldName(_nI))
								&("Z05->"+(_cAlias)->(FieldName(_nI)))	:=	(_cAlias)->(FieldGet(_nI))
							EndIF
						Next
						Z05->(MsUnlock())
						Reclock("SD4",.F.)
						SD4->(DbDelete())
						SD4->(MsUnlock())
					EndIf
				EndIF
				(_cALias)->(DbSkip())
			EndDo
		EndIf

		(_cAlias)->(DbCloseArea())

	EndIf

	//-- INCLUIR INSUMO NA OP ------------------------------------------------------
	If nRadMenu1 == 11

		//BACKUP
		BK001 := "	INSERT INTO "+RetSqlName("Z05")+" " + CRLF
		BK001 += "    ( Z05_FILIAL , " + CRLF
		BK001 += "      Z05_PRODUT , " + CRLF
		BK001 += "      Z05_LOTCTL , " + CRLF
		BK001 += "      Z05_NUMLOT , " + CRLF
		BK001 += "      Z05_LOCALZ , " + CRLF
		BK001 += "      Z05_DTVALI , " + CRLF
		BK001 += "      Z05_LOCAL  , " + CRLF
		BK001 += "      Z05_OP 	   , " + CRLF
		BK001 += "      Z05_EMISSA , " + CRLF
		BK001 += "      Z05_TMTRT  , " + CRLF
		BK001 += "      Z05_QTDORI , " + CRLF
		BK001 += "      Z05_QUANT  , " + CRLF
		BK001 += "      Z05_TABELA , " + CRLF
		BK001 += "      Z05_RECORI , " + CRLF
		BK001 += "      Z05_ORIBKP , " + CRLF
		BK001 += "      Z05_ORBKDE , " + CRLF
		BK001 += "	  	Z05_USRALT , " + CRLF
		BK001 += "	  	Z05_DTALT  , " + CRLF
		BK001 += "	  	Z05_HRALT  , " + CRLF
		BK001 += "	  	Z05_JUSTIF  , " + CRLF
		BK001 += "      D_E_L_E_T_ , " + CRLF
		BK001 += "      R_E_C_N_O_   " + CRLF
		BK001 += "  ) " + CRLF
		BK001 += "  SELECT " + CRLF
		BK001 += "  SD4.D4_FILIAL 										,	-- Z05_FILIAL " + CRLF  
		BK001 += "  '"+kNewCmp+"' D4_COD								,	-- Z05_PRODUT " + CRLF  
		BK001 += "  SD4.D4_LOTECTL 										,	-- Z05_LOTCTL " + CRLF  
		BK001 += "  SD4.D4_NUMLOTE 										,	-- Z05_NUMLOT " + CRLF  
		BK001 += "  '' 													,	-- Z05_LOCALZ " + CRLF  
		BK001 += "  SD4.D4_DTVALID  									,	-- Z05_DTVALI " + CRLF  
		BK001 += "  CASE " + CRLF 
		BK001 += "    WHEN ZB1.B1_APROPRI = 'I'  THEN '99' " + CRLF 
		BK001 += "    ELSE SD4.D4_LOCAL " + CRLF 
		BK001 += "  END D4_LOCAL										,	-- Z05_LOCAL " + CRLF    
		BK001 += "  C2_NUM+C2_ITEM+C2_SEQUEN+'  ' D4_OP					,	-- Z05_OP " + CRLF  
		BK001 += "  SD4.D4_DATA											,	-- Z05_EMISSA " + CRLF  
		BK001 += "  'ZZZ' D4_TRT										,	-- Z05_TMTRT " + CRLF  
		BK001 += "  "+Alltrim(Str(kCamada))+" * C2_QUANT D4_QTDEORI		,	-- Z05_QTDORI " + CRLF  
		BK001 += "  "+Alltrim(Str(kCamada))+" * C2_QUANT D4_QUANT		,	-- Z05_QUANT " + CRLF  
		BK001 += "	'SD4' 												,	-- Z05_TABELA " + CRLF  
		BK001 += "	(SELECT ISNULL(MAX(R_E_C_N_O_),0) FROM "+RetSqlName("SD4")+ " (NOLOCK))  + ROW_NUMBER() OVER(ORDER BY SD4.R_E_C_N_O_) RECORI,	-- Z05_RECORI " + CRLF  
		BK001 += "	'011'  												,	-- Z05_ORIBKP " + CRLF  
		BK001 += "	'Inclusão de um novo insumo na ordem de produção' 	,	-- Z05_ORBKDE " + CRLF  
		BK001 += "	'"+UsrRetName(RetCodUsr())+"'						,	-- Z05_USRALT " + CRLF
		BK001 += "	'"+DTOS(DATE())+"'									,	-- Z05_DTALT " + CRLF
		BK001 += "	'"+TIME()+"'										,	-- Z05_HRALT " + CRLF
		BK001 += "	"+ValtoSql(MV_PAR11)+"  		,	-- Z05_JUSTIF " + CRLF
		BK001 += "	'' 													,	-- D_E_L_E_T_ " + CRLF  
		BK001 += "  (SELECT ISNULL(MAX(R_E_C_N_O_),0) FROM "+RetSqlName("Z05")+" (NOLOCK)) + ROW_NUMBER() OVER(ORDER BY SD4.R_E_C_N_O_) AS NOVOREC --R_E_C_N_O_ " + CRLF
		BK001 += " FROM "+RetSqlName("SD4")+" (NOLOCK) SD4 " + CRLF 
		BK001 += " INNER JOIN "+RetSqlName("SC2")+" (NOLOCK) SC2 " + CRLF  
		BK001 += "  ON C2_FILIAL = '01' " + CRLF 
		BK001 += "  AND SUBSTRING(D4_OP,1,6) = C2_NUM " + CRLF 
		BK001 += "  AND SUBSTRING(D4_OP,7,2) = C2_ITEM " + CRLF 
		BK001 += "  AND SUBSTRING(D4_OP,9,3) = C2_SEQUEN " + CRLF 
		BK001 += "  AND SC2.D_E_L_E_T_ = ' ' " + CRLF 
		BK001 += " INNER JOIN "+RetSqlName("SB1")+" (NOLOCK) ZB1 " + CRLF  
		BK001 += "  ON ZB1.B1_FILIAL = '" + xFilial('SB1') + " ' " + CRLF 
		BK001 += "  AND ZB1.B1_COD  = '"+kNewCmp+"' " + CRLF 
		BK001 += "  AND ZB1.D_E_L_E_T_ = ' ' " + CRLF 
		BK001 += " WHERE D4_FILIAL = '01' " + CRLF 
		BK001 += "  AND SUBSTRING(D4_OP,1,6) = '"+kNumOP+"' " + CRLF 
		BK001 += "  AND D4_COD = '"+kCodCmp+"' " + CRLF 

		BK001 += "    AND NOT EXISTS( " + CRLF
		BK001 += "    					SELECT 1 FROM "+RETSQLNAME("SD4")+" XD4 " + CRLF
		BK001 += "    WHERE SD4.D4_FILIAL = XD4.D4_FILIAL " + CRLF
		BK001 += "    				AND SD4.D4_OP = XD4.D4_OP " + CRLF
		BK001 += "    				AND XD4.D4_COD = "+ValtoSql(kNewCmp) + CRLF
		BK001 += "    				AND XD4.D_E_L_E_T_ = '' ) " + CRLF	

		BK001 += "  AND SD4.D_E_L_E_T_ = ' ' " + CRLF 

		UP001 := " INSERT INTO "+RetSqlName("SD4")+" " + CRLF  
		UP001 += " ( " + CRLF 
		UP001 += " D4_FILIAL, " + CRLF 
		UP001 += " D4_COD, " + CRLF 
		UP001 += " D4_LOCAL, " + CRLF 
		UP001 += " D4_OP, " + CRLF 
		UP001 += " D4_DATA, " + CRLF 
		UP001 += " D4_QSUSP, " + CRLF 
		UP001 += " D4_SITUACA, " + CRLF 
		UP001 += " D4_QTDEORI, " + CRLF 
		UP001 += " D4_QUANT, " + CRLF 
		UP001 += " D4_TRT, " + CRLF 
		UP001 += " D4_LOTECTL, " + CRLF 
		UP001 += " D4_NUMLOTE, " + CRLF 
		UP001 += " D4_DTVALID, " + CRLF 
		UP001 += " D4_OPORIG, " + CRLF 
		UP001 += " D4_QTSEGUM, " + CRLF 
		UP001 += " D4_ORDEM, " + CRLF 
		UP001 += " D4_POTENCI, " + CRLF 
		UP001 += " D_E_L_E_T_, " + CRLF 
		UP001 += " R_E_C_N_O_, " + CRLF 
		UP001 += " R_E_C_D_E_L_, " + CRLF 
		UP001 += " D4_SEQ, " + CRLF 
		UP001 += " D4_NUMPVBN, " + CRLF 
		UP001 += " D4_ITEPVBN, " + CRLF 
		UP001 += " D4_SLDEMP, " + CRLF 
		UP001 += " D4_SLDEMP2, " + CRLF 
		UP001 += " D4_CODLAN, " + CRLF 
		UP001 += " D4_EMPROC, " + CRLF 
		UP001 += " D4_CBTM, " + CRLF 
		UP001 += " D4_YQTDFLX " + CRLF 
		UP001 += " ) " + CRLF 
		UP001 += " SELECT D4_FILIAL, " + CRLF 
		UP001 += "        '"+kNewCmp+"' D4_COD, " + CRLF 
		UP001 += "        CASE " + CRLF 
		UP001 += "          WHEN ZB1.B1_APROPRI = 'I'  THEN '99' " + CRLF 
		UP001 += "          ELSE SD4.D4_LOCAL " + CRLF 
		UP001 += "        END D4_LOCAL, " + CRLF   
		UP001 += "        C2_NUM+C2_ITEM+C2_SEQUEN+'  ' D4_OP, " + CRLF 
		UP001 += "        D4_DATA, " + CRLF 
		UP001 += "        D4_QSUSP, " + CRLF 
		UP001 += "        D4_SITUACA, " + CRLF 
		UP001 += "        "+Alltrim(Str(kCamada))+" * C2_QUANT D4_QTDEORI, " + CRLF 
		UP001 += "        "+Alltrim(Str(kCamada))+" * C2_QUANT D4_QUANT, " + CRLF 
		UP001 += "        'ZZZ' D4_TRT, " + CRLF 
		UP001 += "        D4_LOTECTL, " + CRLF 
		UP001 += "        D4_NUMLOTE, " + CRLF 
		UP001 += "        D4_DTVALID, " + CRLF 
		UP001 += "        D4_OPORIG, " + CRLF 
		UP001 += "        "+Alltrim(Str(kCamada))+" * C2_QUANT D4_QTSEGUM, " + CRLF 
		UP001 += "        D4_ORDEM, " + CRLF 
		UP001 += "        D4_POTENCI, " + CRLF 
		UP001 += "        ' ' D_E_L_E_T_, " + CRLF 
		UP001 += "        (SELECT ISNULL(MAX(R_E_C_N_O_),0) FROM "+RetSqlName("SD4")+ " (NOLOCK))  + ROW_NUMBER() OVER(ORDER BY SD4.R_E_C_N_O_) AS R_E_C_N_O_, " + CRLF 
		UP001 += "        0 R_E_C_D_E_L_, " + CRLF 
		UP001 += "        D4_SEQ, " + CRLF 
		UP001 += "        D4_NUMPVBN, " + CRLF 
		UP001 += "        D4_ITEPVBN, " + CRLF 
		UP001 += "        D4_SLDEMP, " + CRLF 
		UP001 += "        D4_SLDEMP2, " + CRLF 
		UP001 += "        D4_CODLAN, " + CRLF 
		UP001 += "        D4_EMPROC, " + CRLF 
		UP001 += "        D4_CBTM, " + CRLF 
		UP001 += "        D4_YQTDFLX " + CRLF 
		UP001 += " FROM "+RetSqlName("SD4")+" (NOLOCK) SD4 " + CRLF 
		UP001 += " INNER JOIN "+RetSqlName("SC2")+" (NOLOCK) SC2 " + CRLF  
		UP001 += "  ON C2_FILIAL = '01' " + CRLF 
		UP001 += "  AND SUBSTRING(D4_OP,1,6) = C2_NUM " + CRLF 
		UP001 += "  AND SUBSTRING(D4_OP,7,2) = C2_ITEM " + CRLF 
		UP001 += "  AND SUBSTRING(D4_OP,9,3) = C2_SEQUEN " + CRLF 
		UP001 += "  AND SC2.D_E_L_E_T_ = ' ' " + CRLF 
		UP001 += " INNER JOIN "+RetSqlName("SB1")+" (NOLOCK) ZB1 " + CRLF  
		UP001 += "  ON ZB1.B1_FILIAL = '" + xFilial('SB1') + " ' " + CRLF 
		UP001 += "  AND ZB1.B1_COD  = '"+kNewCmp+"' " + CRLF 
		UP001 += "  AND ZB1.D_E_L_E_T_ = ' ' " + CRLF 
		UP001 += " WHERE D4_FILIAL = '01' " + CRLF 
		UP001 += "  AND SUBSTRING(D4_OP,1,6) = '"+kNumOP+"' " + CRLF 
		UP001 += "  AND D4_COD = '"+kCodCmp+"' " + CRLF 

		UP001 += "    AND NOT EXISTS( " + CRLF
		UP001 += "    					SELECT 1 FROM "+RETSQLNAME("SD4")+" XD4 " + CRLF
		UP001 += "    WHERE SD4.D4_FILIAL = XD4.D4_FILIAL " + CRLF
		UP001 += "    				AND SD4.D4_OP = XD4.D4_OP " + CRLF
		UP001 += "    				AND XD4.D4_COD = "+ValtoSql(kNewCmp) + CRLF
		UP001 += "    				AND XD4.D_E_L_E_T_ = '' ) " + CRLF	

		UP001 += "  AND SD4.D_E_L_E_T_ = ' ' " + CRLF 

	endif

	//-- EXCLUIR INSUMO NO APONTAMENTO ------------------------------------------------------
	If nRadMenu1 == 12

		_cAlias	:=	GetNExtAlias()

		QR001 := "  SELECT " + CRLF
		QR001 += "  SD3.D3_FILIAL 					Z05_FILIAL, " + CRLF  
		QR001 += "  SD3.D3_COD 						Z05_PRODUT, " + CRLF  
		QR001 += "  SD3.D3_LOTECTL 					Z05_LOTCTL, " + CRLF  
		QR001 += "  SD3.D3_NUMLOTE 					Z05_NUMLOT, " + CRLF  
		QR001 += "  SD3.D3_LOCALIZ					Z05_LOCALZ, " + CRLF  
		QR001 += "  SD3.D3_DTVALID  				Z05_DTVALI, " + CRLF  
		QR001 += "  SD3.D3_LOCAL    				Z05_LOCAL, " + CRLF  
		QR001 += "  SD3.D3_OP 						Z05_OP, " + CRLF  
		QR001 += "  SD3.D3_EMISSAO					Z05_EMISSA, " + CRLF  
		QR001 += "  SD3.D3_TM 						Z05_TMTRT, " + CRLF  
		QR001 += "  0				 				Z05_QTDORI, " + CRLF  
		QR001 += "  SD3.D3_QUANT    				Z05_QUANT, " + CRLF  
		QR001 += "	'SD3' 							Z05_TABELA, " + CRLF  
		QR001 += "	SD3.R_E_C_N_O_  				Z05_RECORI, " + CRLF  
		QR001 += "	'012'  							Z05_ORIBKP, " + CRLF  
		QR001 += "	'Excluindo Insumo do Apontamento' 	Z05_ORBKDE, " + CRLF  
		QR001 += "	'"+UsrRetName(RetCodUsr())+"'	Z05_USRALT, " + CRLF
		QR001 += "	'"+DTOS(DATE())+"'				Z05_DTALT, " + CRLF
		QR001 += "	'"+TIME()+"'					Z05_HRALT, " + CRLF
		QR001 += "	"+ValtoSql(MV_PAR11)+"  		Z05_JUSTIF, " + CRLF
		QR001 += "	'' 								D_E_L_E_T_, " + CRLF  
		QR001 += "	SB1.B1_DESC   					DESCRI " + CRLF
		QR001 += "   FROM "+RetSqlName("SD3")+" SD3 (NOLOCK) " + CRLF
		QR001 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 (NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
		QR001 += "                       AND B1_COD = D3_COD " + CRLF
		QR001 += "                       AND SB1.D_E_L_E_T_ = ' ' " + CRLF	
		QR001 += "  WHERE D3_FILIAL = '"+xFilial("SD3")+"' " + CRLF
		QR001 += "    AND D3_EMISSAO BETWEEN '"+kDatIni+"' AND '"+kDatFin+"' " + CRLF
		QR001 += "    AND SUBSTRING(D3_OP,1,6) IN('"+kNumOP+"') " + CRLF
		QR001 += "    AND D3_COD = '"+kCodCmp+"' " + CRLF
		QR001 += "    AND D3_TM <> '010' " + CRLF
		QR001 += "    AND SD3.D_E_L_E_T_ = ' ' " + CRLF

		QrIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,QR001),_cAlias,.T.,.F.)
		dbSelectArea(_cAlias)
		dbGoTop()

		_aRecnos	:=	fMrkBrw(_cAlias)

		(_cAlias)->(DbGoTop())

		If Len(_aRecnos) > 0
			While (_cAlias)->(!EOF())
				If aScan(_aRecnos,{|x| x == (_cAlias)->Z05_RECORI}) > 0
					SD3->(DbGoTo((_cAlias)->Z05_RECORI))
					If SD3->(!EOF())
						//Backup
						Reclock("Z05",.T.)
						For _nI	:= 1 to (_cAlias)->(fCount())
							If AllTrim((_cAlias)->(FieldName(_nI))) $ "Z05_DTVALI/Z05_EMISSA/Z05_DTALT"
								&("Z05->"+(_cAlias)->(FieldName(_nI)))	:=	Stod((_cAlias)->(FieldGet(_nI)))
							ElseIf "Z05" $ (_cAlias)->(FieldName(_nI))
								&("Z05->"+(_cAlias)->(FieldName(_nI)))	:=	(_cAlias)->(FieldGet(_nI))
							EndIF
						Next
						Z05->(MsUnlock())
						Reclock("SD3",.F.)
						fAtuVetEst()
						SD3->(DbDelete())
						SD3->(MsUnlock())
					EndIf
				EndIF
				(_cALias)->(DbSkip())
			EndDo
		EndIf

		(_cAlias)->(DbCloseArea())

	EndIf

	//-- INCLUIR INSUMO NO APONTAMENTO ------------------------------------------------------
	If nRadMenu1 == 13

		_cAlias	:=	GetNextAlias()

		BeginSql Alias _cAlias

			SELECT *
			FROM %TABLE:SD3% SD3
			WHERE D3_FILIAL = %XFILIAL:SD3%
			AND D3_EMISSAO BETWEEN %EXP:kDatIni% AND %EXP:kDatFin%
			AND SUBSTRING (D3_OP,1,6) = %EXP:kNumOP% 
			AND D3_TM = '010'
			AND D3_TIPO = %Exp:kTpProd%
			AND NOT EXISTS(
			SELECT 1
			FROM %TABLE:SD3% XD3
			WHERE XD3.D3_FILIAL = SD3.D3_FILIAL
			AND XD3.D3_DOC = SD3.D3_DOC
			AND XD3.D3_OP = %EXP:kNumOP%
			AND XD3.D3_COD = %Exp:kCodCmp%
			AND XD3.%NotDel%
			)
			AND SD3.%NotDel%
		EndSql

		SB1->(dbSetOrder(1))
		If SB1->(dbSeek(xFilial("SB1") + PADR(kCodCmp,TAMSX3("B1_COD")[1]) ))

			While (_cAlias)->(!EOF())

				If SB1->B1_APROPRI == 'I'
					_cLocal	:=	GETMV("MV_LOCPROC")
				Else
					_cLocal	:=	fGetLocIns((_cAlias)->D3_COD, (_cAlias)->D3_LOCAL, kCodCmp)
				EndIf

				RecLock("SD3",.T.)
				SD3->D3_FILIAL   :=  xFilial("SD3")
				SD3->D3_TM       :=  "999"
				SD3->D3_CF       :=  "RE1"
				SD3->D3_OP       :=  (_cAlias)->D3_OP
				SD3->D3_COD      :=  kCodCmp
				SD3->D3_QUANT    :=  Iif(Alltrim(SB1->B1_UM) $ "UN/PC",Round((_cAlias)->D3_QUANT * kCamada,0),(_cAlias)->D3_QUANT * kCamada)
				SD3->D3_QTSEGUM  :=  Iif(Alltrim(SB1->B1_UM) $ "UN/PC",Round(ConvUm(SD3->D3_COD, SD3->D3_QUANT, 0, 2),0),ConvUm(SD3->D3_COD, SD3->D3_QUANT, 0, 2))
				SD3->D3_UM       :=  SB1->B1_UM
				SD3->D3_SEGUM    :=  SB1->B1_SEGUM
				SD3->D3_LOCAL    :=  _cLocal
				SD3->D3_GRUPO    :=  SB1->B1_GRUPO
				SD3->D3_USUARIO  :=  cUserName
				SD3->D3_CHAVE    :=  "E0"
				SD3->D3_TRT      :=  ""
				SD3->D3_CC       :=  (_cAlias)->D3_CC
				SD3->D3_CLVL     :=  (_cAlias)->D3_CLVL
				SD3->D3_CONTA    :=  SB1->B1_YCTRIND
				SD3->D3_TIPO     :=  SB1->B1_TIPO
				SD3->D3_EMISSAO  :=  StoD((_cAlias)->D3_EMISSAO)
				SD3->D3_DOC      :=  (_cAlias)->D3_DOC
				SD3->D3_NIVEL    :=  ""
				SD3->D3_NUMSEQ   :=  (_cAlias)->D3_NUMSEQ
				SD3->D3_YOBS	 :=  "BIA556"
				SD3->D3_IDENT	 :=	(_cAlias)->D3_IDENT
				SD3->D3_YAPLIC   := "1"
				SD3->D3_YDRIVER  := U_BFG81DPD()
				SD3->(MsUnlock())
				fAtuVetEst()

				Reclock("Z05",.T.)
				Z05->Z05_FILIAL	:=	SD3->D3_FILIAL		
				Z05->Z05_PRODUT	:=	SD3->D3_COD		
				Z05->Z05_LOTCTL	:=	SD3->D3_LOTECTL		
				Z05->Z05_NUMLOT	:=	SD3->D3_NUMLOTE			
				Z05->Z05_LOCALZ	:=	SD3->D3_LOCALIZ		
				Z05->Z05_DTVALI	:=	SD3->D3_DTVALID		
				Z05->Z05_LOCAL	:=	_cLocal	
				Z05->Z05_OP		:=	SD3->D3_OP			
				Z05->Z05_EMISSA	:=	SD3->D3_EMISSAO		
				Z05->Z05_TMTRT	:=	SD3->D3_TM		
				Z05->Z05_QTDORI	:=	0
				Z05->Z05_QUANT	:=	SD3->D3_QUANT		
				Z05->Z05_TABELA	:=	'SD3'		
				Z05->Z05_RECORI	:=	SD3->(RECNO())		
				Z05->Z05_ORIBKP	:=	'013'		
				Z05->Z05_ORBKDE	:=	'Incluindo Insumo no Apontamento'		
				Z05->Z05_USRALT	:=	UsrRetName(RetCodUsr())		
				Z05->Z05_DTALT	:=	Date()		
				Z05->Z05_HRALT	:=	Time()					
				Z05->Z05_JUSTIF	:=	MV_PAR11
				Z05->(MsUnlock())

				(_cAlias)->(DbSkip())
			EndDo
			(_cALias)->(DbCloseArea())
		Else
			MsgStop("Erro durante a inclusão: Produto não encontrado " , "Erro!!!")
			(_cALias)->(DbCloseArea())
			Return
		EndIf

	EndIf

	If nRadMenu1 == 14

		_cAliasEx	:=	GetNExtAlias()

		QR001 := "  SELECT " + CRLF
		QR001 += "  SD3.D3_FILIAL 					Z05_FILIAL, " + CRLF  
		QR001 += "  SD3.D3_COD 						Z05_PRODUT, " + CRLF  
		QR001 += "  SD3.D3_LOTECTL 					Z05_LOTCTL, " + CRLF  
		QR001 += "  SD3.D3_NUMLOTE 					Z05_NUMLOT, " + CRLF  
		QR001 += "  SD3.D3_LOCALIZ					Z05_LOCALZ, " + CRLF  
		QR001 += "  SD3.D3_DTVALID  				Z05_DTVALI, " + CRLF  
		QR001 += "  SD3.D3_LOCAL    				Z05_LOCAL, " + CRLF  
		QR001 += "  SD3.D3_OP 						Z05_OP, " + CRLF  
		QR001 += "  SD3.D3_EMISSAO					Z05_EMISSA, " + CRLF  
		QR001 += "  SD3.D3_TM 						Z05_TMTRT, " + CRLF  
		QR001 += "  0				 				Z05_QTDORI, " + CRLF  
		QR001 += "  SD3.D3_QUANT    				Z05_QUANT, " + CRLF  
		QR001 += "  SD3.D3_QTSEGUM   				D3_QTSEGUM, " + CRLF
		QR001 += "	'SD3' 							Z05_TABELA, " + CRLF  
		QR001 += "	SD3.R_E_C_N_O_  				Z05_RECORI, " + CRLF  
		QR001 += "	'014'  							Z05_ORIBKP, " + CRLF  
		QR001 += "	'Alteração de Insumo no Apontament - EXCLUSÃO' 	Z05_ORBKDE, " + CRLF  
		QR001 += "	'"+UsrRetName(RetCodUsr())+"'	Z05_USRALT, " + CRLF
		QR001 += "	'"+DTOS(DATE())+"'				Z05_DTALT, " + CRLF
		QR001 += "	'"+TIME()+"'					Z05_HRALT, " + CRLF
		QR001 += "	"+ValtoSql(MV_PAR11)+"  		Z05_JUSTIF, " + CRLF
		QR001 += "	'' 								D_E_L_E_T_, " + CRLF  
		QR001 += "	SB1.B1_DESC   					DESCRI " + CRLF
		QR001 += "   FROM "+RetSqlName("SD3")+" SD3 (NOLOCK) " + CRLF
		QR001 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 (NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
		QR001 += "                       AND B1_COD = D3_COD " + CRLF
		QR001 += "                       AND SB1.D_E_L_E_T_ = ' ' " + CRLF	
		QR001 += "  WHERE D3_FILIAL = '"+xFilial("SD3")+"' " + CRLF
		QR001 += "    AND D3_EMISSAO BETWEEN '"+kDatIni+"' AND '"+kDatFin+"' " + CRLF
		QR001 += "    AND SUBSTRING(D3_OP,1,6) IN('"+kNumOP+"') " + CRLF
		QR001 += "    AND D3_COD = '"+kCodCmp+"' " + CRLF
		QR001 += "    AND D3_TM <> '010' " + CRLF
		QR001 += "    AND SD3.D_E_L_E_T_ = ' ' " + CRLF
		QR001 += "	  AND NOT EXISTS(	" + CRLF
		QR001 += "					SELECT 1	" + CRLF
		QR001 += "					FROM "+RetSqlName("SD3")+" XD3	" + CRLF
		QR001 += "					WHERE XD3.D3_FILIAL = SD3.D3_FILIAL	" + CRLF
		QR001 += "							AND XD3.D3_DOC = SD3.D3_DOC	" + CRLF
		QR001 += "							AND XD3.D3_OP = "+ValtoSql(kNumOp) + CRLF
		QR001 += "							AND XD3.D3_COD = "+ValtoSql(kNewCmp) + CRLF
		QR001 += "							AND XD3.D_E_L_E_T_ = ''	" + CRLF
		QR001 += "					)	"

		QrIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,QR001),_cAliasEx,.T.,.F.)
		dbSelectArea(_cAliasEx)
		dbGoTop()

		(_cAliasEx)->(DbGoTop())

		Begin Transaction

			While (_cAliasEx)->(!EOF())
				SD3->(DbGoTo((_cAliasEx)->Z05_RECORI))

				If SD3->(!EOF())
					//Backup Exclusão
					Reclock("Z05",.T.)
					For _nI	:= 1 to (_cAliasEx)->(fCount())
						If AllTrim((_cAliasEx)->(FieldName(_nI))) $ "Z05_DTVALI/Z05_EMISSA/Z05_DTALT"
							&("Z05->"+(_cAliasEx)->(FieldName(_nI)))	:=	Stod((_cAliasEx)->(FieldGet(_nI)))
						ElseIf "Z05" $ (_cAliasEx)->(FieldName(_nI))
							&("Z05->"+(_cAliasEx)->(FieldName(_nI)))	:=	(_cAliasEx)->(FieldGet(_nI))
						EndIF
					Next
					Z05->(MsUnlock())
					Reclock("SD3",.F.)
					fAtuVetEst()
					SD3->(DbDelete())
					SD3->(MsUnlock())
				EndIf

				_cAliasIn	:=	GetNextAlias()

				BeginSql Alias _cAliasIn

					SELECT *
					FROM %TABLE:SD3% SD3
					WHERE D3_FILIAL = %XFILIAL:SD3%
					AND D3_EMISSAO BETWEEN %EXP:kDatIni% AND %EXP:kDatFin%
					AND D3_OP = %EXP:(_cAliasEx)->Z05_OP% 
					AND D3_TM = '010'
					AND NOT EXISTS(
					SELECT 1
					FROM %TABLE:SD3% XD3
					WHERE XD3.D3_FILIAL = SD3.D3_FILIAL
					AND XD3.D3_DOC = SD3.D3_DOC
					AND XD3.D3_OP = %EXP:(_cAliasEx)->Z05_OP% 
					AND XD3.D3_COD = %Exp:kNewCmp%
					AND XD3.%NotDel%
					)
					AND SD3.%NotDel%
				EndSql

				SB1->(dbSetOrder(1))
				If SB1->(dbSeek(xFilial("SB1") + PADR(kNewCmp,TAMSX3("B1_COD")[1]) ))

					If SB1->B1_APROPRI == 'I'
						_cLocal	:=	GETMV("MV_LOCPROC")
					Else
						_cLocal	:=	fGetLocIns((_cAliasIn)->D3_COD, (_cAliasIn)->D3_LOCAL, kNewCmp)
					EndIf

					RecLock("SD3",.T.)
					SD3->D3_FILIAL   :=  xFilial("SD3")
					SD3->D3_TM       :=  "999"
					SD3->D3_CF       :=  "RE1"
					SD3->D3_OP       :=  (_cAliasIn)->D3_OP
					SD3->D3_COD      :=  kNewCmp
					SD3->D3_QUANT    :=  (_cAliasEx)->Z05_QUANT

					SD3->D3_QTSEGUM  :=  Iif(Alltrim(SB1->B1_UM) $ "UN/PC",Round(ConvUm(SD3->D3_COD, SD3->D3_QUANT, 0, 2),0),ConvUm(SD3->D3_COD, SD3->D3_QUANT, 0, 2))
					SD3->D3_UM       :=  SB1->B1_UM
					SD3->D3_SEGUM    :=  SB1->B1_SEGUM
					SD3->D3_LOCAL    :=  _cLocal
					SD3->D3_GRUPO    :=  SB1->B1_GRUPO
					SD3->D3_USUARIO  :=  cUserName
					SD3->D3_CHAVE    :=  "E0"
					SD3->D3_TRT      :=  ""
					SD3->D3_CC       :=  (_cAliasIn)->D3_CC
					SD3->D3_CLVL     :=  (_cAliasIn)->D3_CLVL
					SD3->D3_CONTA    :=  SB1->B1_YCTRIND
					SD3->D3_TIPO     :=  SB1->B1_TIPO
					SD3->D3_EMISSAO  :=  StoD((_cAliasIn)->D3_EMISSAO)
					SD3->D3_DOC      :=  (_cAliasIn)->D3_DOC
					SD3->D3_NIVEL    :=  ""
					SD3->D3_NUMSEQ   :=  (_cAliasIn)->D3_NUMSEQ
					SD3->D3_YOBS	 :=  "BIA556"
					SD3->D3_IDENT	 :=	(_cAliasIn)->D3_IDENT
					SD3->D3_YAPLIC   := "1"
					SD3->D3_YDRIVER  := U_BFG81DPD()
					SD3->(MsUnlock())
					fAtuVetEst()

					Reclock("Z05",.T.)
					Z05->Z05_FILIAL	:=	SD3->D3_FILIAL		
					Z05->Z05_PRODUT	:=	SD3->D3_COD		
					Z05->Z05_LOTCTL	:=	SD3->D3_LOTECTL		
					Z05->Z05_NUMLOT	:=	SD3->D3_NUMLOTE			
					Z05->Z05_LOCALZ	:=	SD3->D3_LOCALIZ		
					Z05->Z05_DTVALI	:=	SD3->D3_DTVALID		
					Z05->Z05_LOCAL	:=	_cLocal	
					Z05->Z05_OP		:=	SD3->D3_OP			
					Z05->Z05_EMISSA	:=	SD3->D3_EMISSAO		
					Z05->Z05_TMTRT	:=	SD3->D3_TM		
					Z05->Z05_QTDORI	:=	0
					Z05->Z05_QUANT	:=	SD3->D3_QUANT		
					Z05->Z05_TABELA	:=	'SD3'		
					Z05->Z05_RECORI	:=	SD3->(RECNO())		
					Z05->Z05_ORIBKP	:=	'014'		
					Z05->Z05_ORBKDE	:=	'Alteração de Insumo no Apontament - INCLUSAO'		
					Z05->Z05_USRALT	:=	UsrRetName(RetCodUsr())		
					Z05->Z05_DTALT	:=	Date()		
					Z05->Z05_HRALT	:=	Time()					
					Z05->Z05_JUSTIF	:=	MV_PAR11
					Z05->(MsUnlock())

					(_cAliasIn)->(DbCloseArea())
				Else
					MsgStop("Erro durante a inclusão: Produto não encontrado " , "Erro!!!")
					(_cAliasIn)->(DbCloseArea())
					DisarmTransaction()
					Return
				EndIf

				(_cAliasEx)->(DbSkip())

			EndDo

			(_cAliasEx)->(DbCloseArea())	

		END TRANSACTION

	EndIf

	If nRadMenu1 == 11
		zlReslt := TCSQLEXEC(BK001)
	Else
		zlReslt	:=	0
	EndIF

	If zlReslt < 0

		MsgStop("Erro durante a copia de segurança: " + TCSQLError(), "Erro!!!")

	Else

		If nRadMenu1 == 11
			zlReslt := TCSQLEXEC(UP001)
		Else
			zlReslt	:=	0
		EndIF

		If zlReslt < 0

			MsgStop("Erro durante a exclusao: " + TCSQLError(), "Erro!!!")

		Else

			MsgINFO("Processamento efetuado com sucesso. Favor verificar.", "Proc. Ok!!!")

			If Len(msVetEst) > 0

				For _aVet := 1 to Len(msVetEst)

					U_BIAMsgRun("Aguarde... Atualizando Saldo Estoque... ",,{|| U_BiaSalAtu(msVetEst[_aVet][2], msVetEst[_aVet][2], msVetEst[_aVet][1], msVetEst[_aVet][1]) })

				Next msVetEst

			EndIf

			nRadMenu1 := 15
			oRadMenu1:NOPTION := 15
			oDlgAltEmp:ACONTROLS[1]:NOPTION := 15
			ObjectMethod(oDlgAltEmp,"Refresh()")
			dlgRefresh(oDlgAltEmp)
			oRadMenu1:Refresh()

		EndIf

	Endif

Return

Static Function fGetLocIns(_cCodPai, _cLocPai, _cInsumo)

	Local _cLocal	:=	_cLocPai
	Local _cAlias	:=	GetNextAlias()

	BeginSql Alias _cAlias

		SELECT TOP 1 ISNULL(ZCNINS.ZCN_LOCAL,%Exp:_cLocPai%) LOC
		FROM %TABLE:ZCN% ZCNPAI
		JOIN %TABLE:ZCN% ZCNINS ON ZCNPAI.ZCN_FILIAL = ZCNINS.ZCN_FILIAL
		AND ZCNPAI.ZCN_SEQUEN = ZCNINS.ZCN_SEQUEN
		AND ZCNINS.ZCN_COD = %Exp:_cInsumo%
		AND ZCNINS.%NotDel%
		WHERE ZCNPAI.ZCN_FILIAL = %XFILIAL:ZCN%
		AND ZCNPAI.ZCN_COD = %Exp:_cCodPai%
		AND ZCNPAI.ZCN_LOCAL = %Exp:_cLocPai%
		AND ZCNPAI.%NotDel%

	EndSql

	_cLocal := (_cAlias)->LOC

	(_cAlias)->(DbCloseArea())

Return _cLocal

User Function B556VJus()

	Local _lRet	:=	.T.

	If Empty(MV_PAR11)
		MsgInfo("O campo Justificativa é obrigatório!")
		_lRet	:=	.F.
	EndIf

Return _lRet

Static Function ValidPerg()

	local cLoad	    := "BIA556" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local aPergs	:=	{}

	MV_PAR01	:=	Space(6)
	MV_PAR02	:=	Space(15)
	MV_PAR03	:=	0
	MV_PAR04	:=	Stod("")
	MV_PAR05	:=	Stod("")
	MV_PAR06	:=	Space(2)
	MV_PAR07	:=	Space(15)
	MV_PAR08	:=	Space(15)
	MV_PAR09	:=	Space(02)
	MV_PAR10	:=	Space(02)
	MV_PAR11	:=	SPACE(170)
	MV_PAR12	:=	SPACE(03)

	aAdd( aPergs ,{1,"Número da OP? "		,MV_PAR01 ,""  ,"",''  ,'.T.',50,.F.})	
	aAdd( aPergs ,{1,"Componente?     "		,MV_PAR02 ,"@!"  ,"",'SB1'  ,'.T.',100,.F.})
	aAdd( aPergs ,{1,"Camada?     "			,MV_PAR03 ,"@E 999,999,999.99999999"  ,"",''  ,'.T.',100,.F.})
	aAdd( aPergs ,{1,"Data De?     "		,MV_PAR04 ,""  ,"",''  ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Data Até?     "		,MV_PAR05 ,""  ,"",''  ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Formato?     "		,MV_PAR06 ,""  ,"",'ZZ6'  ,'.T.',30,.F.})
	aAdd( aPergs ,{1,"Novo Componente?"		,MV_PAR07 ,""  ,"",'SB1'  ,'.T.',100,.F.})
	aAdd( aPergs ,{1,"Referência(PA)? "		,MV_PAR08 ,""  ,"",'SB1'  ,'.T.',100,.F.})
	aAdd( aPergs ,{1,"Tp. Prod. Apontado?"	,MV_PAR09 ,""  ,"",'02'  ,'.T.',30,.F.})
	aAdd( aPergs ,{1,"Almoxarifado?     "	,MV_PAR10 ,""  ,"",''  ,'.T.',30,.F.})
	aAdd( aPergs ,{1,"Justificativa?     "	,MV_PAR11 ,""  ,"",''  ,'.T.',100,.F.})
	aAdd( aPergs ,{1,"Espessura?     "		,MV_PAR12 ,""  ,"",'Z34'  ,'.T.',30,.F.})

	If ParamBox(aPergs ,"Ajuste pontual de empenho",,{|| U_B556VJus()},,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 	:= ParamLoad(cFileName,,1,MV_PAR01) 
		MV_PAR02 	:= ParamLoad(cFileName,,2,MV_PAR02)
		MV_PAR03 	:= ParamLoad(cFileName,,3,MV_PAR03)
		MV_PAR04 	:= ParamLoad(cFileName,,4,MV_PAR04)
		MV_PAR05 	:= ParamLoad(cFileName,,5,MV_PAR05)
		MV_PAR06 	:= ParamLoad(cFileName,,6,MV_PAR06)
		MV_PAR07 	:= ParamLoad(cFileName,,7,MV_PAR07)
		MV_PAR08 	:= ParamLoad(cFileName,,8,MV_PAR08)
		MV_PAR09 	:= ParamLoad(cFileName,,9,MV_PAR09)
		MV_PAR10 	:= ParamLoad(cFileName,,10,MV_PAR10)
		MV_PAR11 	:= ParamLoad(cFileName,,11,MV_PAR11)
		MV_PAR12 	:= ParamLoad(cFileName,,12,MV_PAR12)

	EndIf

Return lRet

Static Function fMrkBrw(_cAlias)

	Local _oDlg	:=	Nil

	Local _aSize	
	Local _aObjects := {}
	Local _aInfo
	Local _aPosObj
	Local _aHeader	:=	{}
	Local _aCols	:=	{}
	Local _aRecnos	:=	{}

	Local _nI

	Private _nOk	:=	0
	Private _lMarked	:=	.T.

	_aSize := MsAdvSize(.T.) //Sem Enchoice

	_aInfo   := {_aSize[1], _aSize[2], _aSize[3], _aSize[4], 0, 0}	

	AAdd(_aObjects, {100, 100, .T. , .T. })

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	Aadd(_aHeader,{" "			 ,"CSTATUS","@BMP", 2, 0, ".F." ,""    , "C", "", "V" ,"" , "","","V"})
	aAdd(_aHeader,{"Filial"         ,"FILIAL" ,"@!"               , 2   , 0,,, "C",, })      	// 1
	aAdd(_aHeader,{"Produto"         ,"PRODUTO" ,"@!"               , 15   , 0,,, "C",, })      	// 1
	aAdd(_aHeader,{"Desc."         ,"DESCRI" ,"@!"               , 40   , 0,,, "C",, })      	// 1
	aAdd(_aHeader,{"OP"         ,"OP" ,"@!"               , 6   , 0,,, "C",, })      	// 1
	aAdd(_aHeader,{"Qtd"         ,"QTD" ,"@999.999,99999"               , 12   , 5,,, "N",, })      	// 1
	aAdd(_aHeader,{"Qtd. Ori."         ,"QTDORI" ,"@999.999,99999"               , 12   , 5,,, "N",, })      	// 1
	aAdd(_aHeader,{"Rec."         ,"REC" ,"@!"               , 16   , 0,,, "N",, })      	// 1

	While (_cAlias)->(!EOF())
		aAdd(_aCols,{;
		"LBOK",;
		(_cAlias)->Z05_FILIAL,;
		(_cAlias)->Z05_PRODUT,;
		(_cAlias)->DESCRI,;
		(_cAlias)->Z05_OP,;
		(_cAlias)->Z05_QUANT,;
		(_cAlias)->Z05_QTDORI,;
		(_cAlias)->Z05_RECORI,;
		.F.})
		(_cAlias)->(DbSkip())
	EndDo

	DEFINE MSDIALOG _oDlg TITLE "Ajustes Pontuais de Empenho" FROM _aSize[7], _aSize[7] TO _aSize[6], _aSize[5] COLORS 0, 16777215 PIXEL

	_oGetDados := MsNewGetDados():New(_aPosObj[1,1], _aPosObj[1,2], _aPosObj[1,3], _aPosObj[1,4], 0, /*[ cLinhaOk]*/, /*[ cTudoOk]*/, /*"+++ZZ2_COD"/*[ cIniCpos]*/, /*Acpos*/, /*[ nFreeze]*/, /*[ nMax]*/, /*cFieldOK*/, /*[ cSuperDel]*/,/*[ cDelOk]*/, _oDlg, _aHeader, _aCols)

	_oGetDados:oBrowse:bHeaderClick	:=	{|| fMarkAll()}

	_oGetDados:oBrowse:blDblClick	:=	{|| _oGetDados:aCols[_oGetDados:nAt,1] := Iif(_oGetDados:aCols[_oGetDados:nAt,1] == "LBOK","LBNO","LBOK")}
	ACTIVATE DIALOG _oDlg CENTERED	on Init EnchoiceBar(_oDlg, {||_nOk := 1, _oDlg:End()}, {||_nOk := 0, _oDlg:End()})	

	If _nOk	==	1
		For _nI	:=	1 to Len(_oGetDados:aCols)
			If _oGetDados:aCols[_nI,1] == "LBOK"
				aAdd(_aRecnos,_oGetDados:aCols[_nI,Len(_oGetDados:aHeader)])
			EndIf
		Next
	EndIf

	Ferase(QrIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(QrIndex+OrdBagExt())          //indice gerado

Return _aRecnos

Static Function fMarkAll()

	Local _nI

	If _oGetDados:oBrowse:colpos == 1

		For _nI	:=	1 To Len(_oGetDados:aCols)
			If _lMarked
				_oGetdados:aCols[_nI,1]	:=	"LBNO"
			Else
				_oGetdados:aCols[_nI,1]	:=	"LBOK"
			EndIf
		Next
		_lMarked	:=	!_lMarked

	EndIf

	_oGetDados:Refresh()

Return

Static Function fAtuVetEst()

	_nPos	:=	aScan(msVetEst,{|x| Alltrim(x[1]) + Alltrim(x[2]) == Alltrim(SD3->D3_COD) + Alltrim(SD3->D3_LOCAL) })
	If _nPos == 0
		aAdd(msVetEst,{SD3->D3_COD, SD3->D3_LOCAL})
	EndIf

Return
