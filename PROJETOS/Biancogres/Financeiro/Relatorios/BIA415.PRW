#include "rwMake.ch"
#include "Topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BIA415         ºAutor  ³WANISAY WILLIAM     º Data ³  31/03/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Relatorio em Crystal para gerar relacao de titulos c/pis/cofins   º±±
±±º          ³OBS: FUNCAO UTLIZADA PARA GERAR A VIEW DO RELATORIO               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7                                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BIA415()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cSQL
lEnd       := .F.
cString    := ""
cDesc1     := "Este programa tem como objetivo imprimir relatorio "
cDesc2     := "de acordo com os parametros informados pelo usuario."
cDesc3     := "Titulos com Pis/Cofins/Csll"
cTitulo    := "Relacao de Titulos com Pis/Cofins/Csll."
cTamanho   := ""
limite     := 80
aReturn    := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
cNomeprog  := "BIA415"
cPerg      := "BIA415"
aLinha     := {}
nLastKey   := 0
Cabec1     := ""
Cabec2     := ""
nBegin     := 0
cDescri    := ""
cCancel    := "***** CANCELADO PELO OPERADOR *****"
m_pag      := 1
wnrel      := "BIA415"
lprim      := .t.
li         := 80
nTipo      := 0
wFlag      := .t.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT.								     ³
//³ Verifica Posicao do Formulario na Impressora.				             ³
//³ Solicita os parametros para a emissao do relatorio			             |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
fPerg := cPerg
fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
ValidPerg()
pergunte(cPerg,.F.)
wnrel := SetPrint(cString,cNomeProg,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,    ,.T.,cTamanho,,.F.)

//Cancela a impressao
If nLastKey == 27
	Return
Endif

dDataIni := MV_PAR01
dDataFim := MV_PAR02
cTitulo := "Relacao de Titulos com Pis/Cofins/Csll."

//*************************************************************************
//View para trazer as informacoes do processo e os produtos que o pertence
//*************************************************************************
cSQL := ""
cSQL := "ALTER VIEW VW_BIA415 AS "
cSQL += "SELECT "
cSQL += "    SE2.E2_NUM, SE2.E2_PREFIXO, SE2.E2_PARCELA, SE2.E2_TIPO, SE2.E2_VALOR, SE22.E2_EMISSAO, SE22.E2_VENCTO, SE2.E2_VENCREA AS VENCREA_NOTA, SE22.E2_VENCREA AS VENCREA_IMP, "
cSQL += "           SE2.E2_VRETPIS, SE2.E2_VRETCOF, SE2.E2_VRETCSL, SA2.A2_CGC, SA2.A2_NOME "
cSQL += "FROM "
cSQL += RetSqlName("SA2") + " SA2, "
cSQL += RetSqlName("SE2") + " SE2, "
cSQL += RetSqlName("SE2") + " SE22 "
cSQL += "WHERE "
cSQL += "	SE2.E2_FILIAL  = '" + xFilial("SE2") + "' "

IF MV_PAR05 == 1
	cSQL += "	AND SE2.E2_VENCREA BETWEEN '" + DTOS(dDataIni) + "' AND '" + DTOS(dDataFim) + "' "
	//cSQL += "	AND SE2.E2_BAIXA   BETWEEN '" + DTOS(dDataIni) + "' AND '" + DTOS(dDataFim) + "' "
ELSE
	cSQL += "	AND SE22.E2_VENCREA BETWEEN '" + DTOS(dDataIni) + "' AND '" + DTOS(dDataFim) + "' "
	//cSQL += "	AND SE22.E2_BAIXA   BETWEEN '" + DTOS(dDataIni) + "' AND '" + DTOS(dDataFim) + "' "
ENDIF
cSQL += "	AND SE2.E2_FORNECE BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "

cSQL += "	AND SE2.E2_FORNECE = SA2.A2_COD "
cSQL += "	AND SE2.E2_LOJA    = SA2.A2_LOJA "
cSQL += "	AND SE2.E2_VRETPIS > 0 "
cSQL += "	AND SE22.E2_PREFIXO = SE2.E2_PREFIXO "
cSQL += "	AND SE22.E2_NUM     = SE2.E2_NUM "
cSQL += "	AND SE22.E2_PARCELA = SE2.E2_PARCPIS "
cSQL += "	AND SE22.E2_TIPO    = 'TX ' "
cSQL += "	AND SE22.E2_VALOR   = SE2.E2_VRETPIS "
cSQL += "	AND SA2.D_E_L_E_T_  = ' ' "
cSQL += "	AND SE2.D_E_L_E_T_  = ' ' "
cSQL += "	AND SE22.D_E_L_E_T_ = ' ' "

TcSQLExec(cSQL)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se impressao em disco, chama o gerenciador de impressao...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5]==1
	//Parametros Crystal Em Disco
	Private cOpcao:="1;0;1;Apuracao"
Else
	//Direto Impressora
	Private cOpcao:="3;0;1;Apuracao"
Endif
callcrys("BIA415",cEmpant,cOpcao)
Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ ValidPerg¦ Autor ¦ Wanisay William       ¦ Data ¦ 13.02.08 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function ValidPerg()
local j,i
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(fPerg,fTamX1)
aRegs:={}

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
aAdd(aRegs,{cPerg,"01","Da Data                ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Ate Data               ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Do Fornecedor          ?","","","mv_ch3","C",06,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","Ate Fornecedor         ?","","","mv_ch4","C",06,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"05","Vencimento             ?","","","mv_ch5","N",01,0,0,"C","","mv_par05","Nota Fiscal","","","Imposto","","","","","","","","","","","","","","","","","","","","",""})

For i := 1 to Len(aRegs)
	if !dbSeek(cPerg + aRegs[i,2])
		RecLock("SX1",.t.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next
dbSelectArea(_sAlias)

Return
