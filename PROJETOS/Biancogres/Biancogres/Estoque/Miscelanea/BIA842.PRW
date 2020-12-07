#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BIA842 ºAutor  ³ Ranisses A. Corona º Data ³  24/02/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescr.    ³ Transfere todos as Localizacoes para Localizacao Padrao  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigaest - Sera utilizado na migracao Ecosis              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
USER FUNCTION BIA842()

//Pergunte("BIA842", .F.)

@ 96,42 TO 323,505 DIALOG oDlg5 TITLE "Transfere Localizacao"
@ 8,10 TO 84,222

@ 16,12 SAY "Esta rotina tem por finalidade: "
@ 24,12 SAY "Transferir todo o estoque para uma unica localizacao."

@ 91,166 BMPBUTTON TYPE 1 ACTION OkProc()
@ 91,195 BMPBUTTON TYPE 2 ACTION Close(oDlg5)
//@ 91,137 BMPBUTTON TYPE 5 ACTION Pergunte("BIA842", .T.) //ABRE PERGUNTAS

ACTIVATE DIALOG oDlg5 CENTERED

RETURN()


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chama rotina que realiza a transferencia³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function OkProc()
Processa( {|| RunProc() } )
Close(oDlg5)
Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Rotina que realiza a transferencia      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function RunProc()
Private cSql				:= ""
Private Enter				:= CHR(13)
Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.
Private	aTransf			:= {}

//Seleciona os produtos a serem transferidos
cSql := "SELECT * " + ENTER
cSql += "FROM SB1010 SB1, "+RetSqlName("SBF")+" SBF " + ENTER
cSql += "WHERE B1_FILIAL 			= '  ' 				AND " + ENTER
cSql += "			BF_FILIAL 			= '01' 				AND " + ENTER
cSql += "			B1_COD    			= BF_PRODUTO 	AND " + ENTER
cSql += "			B1_COD    			>= 'A'			 	AND " + ENTER
cSql += "			BF_LOCALIZ 	NOT IN ('ZZZZ') AND " + ENTER
cSql += "			SB1.D_E_L_E_T_ 	= '' 					AND " + ENTER
cSql += "			SBF.D_E_L_E_T_ 	= ''					AND " + ENTER 
cSql += "ORDER BY BF_PRODUTO, BF_LOTECTL, BF_LOCALIZ	" + ENTER
If CHKFILE("_SBF")
	dbSelectArea("_SBF")
	dbCloseArea()
ENDIF
TcQuery cSql ALIAS "_SBF" NEW

// Adiciona cabecalho com numero do documento e data da transferencia modelo II
aadd (aTransf,{ UPPER( nextnumero("SD3",2,"D3_DOC",.t.) ), ddatabase})

// sequencia
// produto, descricao, unidade de medida, local/localizacao origem
// produto, descricao, unidade de medida, local/localizacao destino
// numero de serie, lote origem, sublote, data de validade, potencia
// qunatidade, quantidade na 2 unidade, estorno, numero de sequencia, lote destino,

ProcRegua(2110)

Do While !_SBF->(EOF())
	
	IncProc("Selecionando os Produtos..."+ALLTRIM(_SBF->BF_PRODUTO))
	
	cSql := "SELECT B8_PRODUTO, MAX(B8_DTVALID) DTVALID 	  " + ENTER
	cSql += "FROM "+RetSqlName("SB8")+"										  " + ENTER
	cSql += "WHERE B8_PRODUTO = '"+_SBF->BF_PRODUTO+"' AND 	" + ENTER
	cSql += "      B8_LOTECTL = '"+_SBF->BF_LOTECTL+"'	AND " + ENTER
	cSql += "      D_E_L_E_T_ = ''												  " + ENTER
	cSql += "GROUP BY B8_PRODUTO													  " + ENTER
	If CHKFILE("_SB8")
		dbSelectArea("_SB8")
		dbCloseArea()
	ENDIF
	TcQuery cSql ALIAS "_SB8" NEW
	
	aadd ( aTransf,	{ 	_SBF->BF_PRODUTO, _SBF->B1_DESC, SB1->B1_UM, _SBF->BF_LOCAL , _SBF->BF_LOCALIZ,;
	_SBF->BF_PRODUTO, _SBF->B1_DESC, SB1->B1_UM, _SBF->BF_LOCAL , "ZZZZ"	, ;
	_SBF->BF_NUMSERI, _SBF->BF_LOTECTL , _SBF->BF_NUMLOTE, STOD(_SB8->DTVALID) , 0.00, ;
	_SBF->BF_QUANT, _SBF->BF_QTSEGUM, criavar("D3_ESTORNO"), criavar("D3_NUMSEQ"), _SBF->BF_LOTECTL, ddatabase, criavar("D3_ITEMGRD")} )
	
	_SBF->(DBSKIP())
EndDo

//U_BIAMsgRun("Aguarde... Realizando a Tranferencia...",,MSExecAuto({|x| MATA261(x)},aTransf))
MSExecAuto({|x| MATA261(x)},aTransf)

If lMsErroAuto
	MostraError()
	MsgAlert("Erro!!!!!")
	DisarmTransaction()
	Break
Else
	MsgAlert("Sucesso!!!!!")
EndIf

Return
