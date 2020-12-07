#include "rwMake.ch"
#include "Topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ REL_OBRAS      บAutor  ณ BRUNO MADALENO     บ Data ณ  08/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRELATORIO EM CRYSTAL PARA GERAR DAS OBRAS CADASTRADAS             บฑฑ
ฑฑบ          ณ																	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP 7                                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function REL_OBRAS()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local cFiltro 	:= ""
Local _nomeuser := cUserName
Local _daduser := ""

Private cSQL
Private ENTER := CHR(13)+CHR(10) 
lEnd       := .F.
cString    := ""
cDesc1     := "Este programa tem como objetivo imprimir relatorio "
cDesc2     := "de acordo com os parametros informados pelo usuario."
cDesc3     := "Informa็oes das obras"
cTamanho   := ""
limite     := 80		
aReturn    := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
cNomeprog  := "REL_OBRAS"
cPerg      := "REL_OBRAS"
aLinha     := {}
nLastKey   := 0
cTitulo	   := "Informa็oes das obras"
Cabec1     := ""
Cabec2     := ""
nBegin     := 0
cDescri    := ""
cCancel    := "***** CANCELADO PELO OPERADOR *****"
m_pag      := 1                                    
wnrel      := "REL_OBRAS"
lprim      := .t.
li         := 80
nTipo      := 0
wFlag      := .t. 

   
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Envia controle para a funcao SETPRINT.								     ณ
//ณ Verifica Posicao do Formulario na Impressora.				             ณ
//ณ Solicita os parametros para a emissao do relatorio			             |
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
pergunte(cPerg,.F.)
wnrel := SetPrint(cString,cNomeProg,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,    ,.T.,cTamanho,,.F.)
If nLastKey == 27
	Return
Endif

psworder(2)                          // Pesquisa por Nome

If  pswseek(_nomeuser,.t.)           // Nome do usuario, Pesquisa usuarios
	_daduser  := pswret(1)           // Numero do registro
	_UsuarAt  := _daduser[1,1]
EndIf

cSQL := "ALTER VIEW VW_REL_OBRAS AS  " + ENTER
IF MV_PAR01 = 1			// DATA EMISSAO
	cSQL += "SELECT ZZO_VEND, A3_NOME, SUBSTRING(ZZO_EMIS,1,6) AS DATA, SUM(ZZO_QTDTOT) AS M2, COUNT(ZZO_VEND) AS NUMERO  " + ENTER
ELSE 					// DATA PREVISAO
	cSQL += "SELECT ZZO_VEND, A3_NOME, SUBSTRING(ZZO_DTPREV,1,6) AS DATA, SUM(ZZO_QTDTOT) AS M2, COUNT(ZZO_VEND) AS NUMERO " + ENTER
END IF
cSQL += "FROM ZZO010 ZZO, SA3010 SA3  " + ENTER               	
cSQL += "WHERE	ZZO_VEND = A3_COD " + ENTER

If !Empty(AllTrim(cRepAtu))
		cSQL += "		AND ZZO_VEND = '"+cRepAtu+"' " + ENTER
Else
	If Alltrim(Upper(_daduser[1,12])) == "ESPECIFICADORES" .And. Substr(Alltrim(_daduser[1,2]),1,1) = "A" //testar pra ver de qual้!
		cSQL += "		AND ZZO_VEND IN ('" + Replace(Alltrim(Upper(_daduser[1,13])),"/","','") + "') "
	Else
		cSQL += "		AND ZZO_VEND   BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR03+"' " + ENTER
	EndIf
EndIf

//cSQL += "		AND ZZO_VEND   BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR03+"' " + ENTER
cSQL += "		AND ZZO_DTPREV BETWEEN '"+DTOS(MV_PAR04)+"' AND '"+DTOS(MV_PAR05)+"' " + ENTER
cSQL += "		AND ZZO_EMIS   BETWEEN '"+DTOS(MV_PAR06)+"' AND '"+DTOS(MV_PAR07)+"' " + ENTER
cSQL += "		AND ZZO_STATUS BETWEEN '"+MV_PAR08+"' AND '"+MV_PAR09+"' " + ENTER
cSQL += "		AND ZZO_FASE   BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' " + ENTER
cSQL += "		AND ZZO_TPEMP  BETWEEN '"+MV_PAR12+"' AND '"+MV_PAR13+"' " + ENTER
cSQL += "		AND ZZO_PADRAO BETWEEN '"+MV_PAR14+"' AND '"+MV_PAR15+"' " + ENTER
cSQL += "		AND ZZO.D_E_L_E_T_ = '' " + ENTER
cSQL += "		AND SA3.D_E_L_E_T_ = '' " + ENTER
IF MV_PAR01 = 1	// DATA EMISSAO
	cSQL += "GROUP BY ZZO_VEND, A3_NOME, SUBSTRING(ZZO_EMIS,1,6) " + ENTER
ELSE 				// DATA PREVISAO
	cSQL += "GROUP BY ZZO_VEND, A3_NOME, SUBSTRING(ZZO_DTPREV,1,6) " + ENTER
END IF
TcSQLExec(cSQL)


cSQL := "ALTER VIEW VW_REL_OBRAS_RESUMO AS  " + ENTER
IF MV_PAR01 = 1			// DATA EMISSAO
	cSQL += "SELECT SUBSTRING(ZZO_EMIS,1,6) AS DATA, SUM(ZZO_QTDTOT) AS M2, COUNT(ZZO_VEND) AS NUMERO  " + ENTER
ELSE 					// DATA PREVISAO
	cSQL += "SELECT SUBSTRING(ZZO_DTPREV,1,6) AS DATA, SUM(ZZO_QTDTOT) AS M2, COUNT(ZZO_VEND) AS NUMERO " + ENTER
END IF
cSQL += "FROM ZZO010 ZZO, SA3010 SA3  " + ENTER
cSQL += "WHERE	ZZO_VEND = A3_COD " + ENTER


If !Empty(AllTrim(cRepAtu))
		cSQL += "		AND ZZO_VEND = '"+cRepAtu+"' " + ENTER
Else
	If Alltrim(Upper(_daduser[1,12])) == "ESPECIFICADORES" .And. Substr(Alltrim(_daduser[1,2]),1,1) = "A" //testar pra ver de qual้!
		cSQL += "		AND ZZO_VEND IN ('" + Replace(Alltrim(Upper(_daduser[1,13])),"/","','") + "') "
	Else
		cSQL += "		AND ZZO_VEND   BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR03+"' " + ENTER
	EndIf
EndIf

cSQL += "		AND ZZO_DTPREV BETWEEN '"+DTOS(MV_PAR04)+"' AND '"+DTOS(MV_PAR05)+"' " + ENTER
cSQL += "		AND ZZO_EMIS   BETWEEN '"+DTOS(MV_PAR06)+"' AND '"+DTOS(MV_PAR07)+"' " + ENTER
cSQL += "		AND ZZO_STATUS BETWEEN '"+MV_PAR08+"' AND '"+MV_PAR09+"' " + ENTER
cSQL += "		AND ZZO_FASE   BETWEEN '"+MV_PAR10+"' AND '"+MV_PAR11+"' " + ENTER
cSQL += "		AND ZZO_TPEMP  BETWEEN '"+MV_PAR12+"' AND '"+MV_PAR13+"' " + ENTER
cSQL += "		AND ZZO_PADRAO BETWEEN '"+MV_PAR14+"' AND '"+MV_PAR15+"' " + ENTER
cSQL += "		AND ZZO.D_E_L_E_T_ = '' " + ENTER
cSQL += "		AND SA3.D_E_L_E_T_ = '' " + ENTER
IF MV_PAR01 = 1	// DATA EMISSAO
	cSQL += "GROUP BY SUBSTRING(ZZO_EMIS,1,6) " + ENTER
ELSE 				// DATA PREVISAO
	cSQL += "GROUP BY SUBSTRING(ZZO_DTPREV,1,6) " + ENTER
END IF
TcSQLExec(cSQL)

IF MV_PAR01 = 1
	CPARAMETROS := "Data Exibida ้ DATA EMISSAO "
ELSE
	CPARAMETROS := "Data Exibida ้ DATA PREVISAO "
END IF
CPARAMETROS +=  "  /  Vendedor de " + MV_PAR02 + " Ate " + MV_PAR03
CPARAMETROS +=  "  /  Data Previsใo de " + DTOC(MV_PAR04) + " Ate " + DTOC(MV_PAR05)
CPARAMETROS +=  "  /  Data Emissใo de " +  DTOC(MV_PAR06) + " Ate " +  DTOC(MV_PAR07)
CPARAMETROS +=  "  /  Status De " + MV_PAR08 + " Ate " + MV_PAR09
CPARAMETROS +=  "  /  Fase de " + MV_PAR10 + " Ate " + MV_PAR11
CPARAMETROS +=  "  /  Tipo Empreend. de " + MV_PAR12 + " Ate " + MV_PAR13
CPARAMETROS +=  "  /  Padrใo de " + MV_PAR14 + " Ate " + MV_PAR15
CPARAMETROS +=  "  /  Pre็o Medio " + ALLTRIM(STR(MV_PAR16))

//If aReturn[5]==1
	//Parametros Crystal Em Disco
//	Private cOpcao:="1;0;1;Apuracao"
//Else
	//Direto Impressora
//	Private cOpcao:="3;0;1;Apuracao"
//Endif
//callcrys("REL_OBRAS",   cEmpant + ";" + ALLTRIM(STR(MV_PAR16)) + ";" + CPARAMETROS  ,cOpcao)


//alterado para ser gerado diretamente do servidor
cOpcao	:=	"6;0;1;Apuracao"

CallCrys("REL_OBRAS", cEmpant + ";" + ALLTRIM(STR(MV_PAR16)) + ";" + CPARAMETROS, cOpcao, .T., .T., .T., .F. )

Return