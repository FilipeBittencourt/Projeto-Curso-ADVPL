#include "rwMake.ch"
#include "Topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FAXDP          ºAutor  ³ HARLEY DIAS KOEHLERº Data ³  23/01/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ IMPRESSAO DE FAX A SER ENVIADO AO BANCO                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP 7                                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function FAXDP()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private cSQL
	Private Enter := CHR(13)+CHR(10) 
	lEnd       := .F.
	cString    := ""
	cDesc1     := "Este programa tem como objetivo imprimir relatorio "
	cDesc2     := "de acordo com os parametros informados pelo usuario."
	cDesc3     := "Envio de Fax ao Banco"
	cTamanho   := ""
	limite     := 80		
	aReturn    := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	cNomeprog  := "FAXDP"
	cPerg      := "FAXDP"
	aLinha     := {}
	nLastKey   := 0
	cTitulo	   := "Folha de Rosto para Fax                  "
	Cabec1     := ""
	Cabec2     := ""
	nBegin     := 0
	cDescri    := ""
	cCancel    := "***** CANCELADO PELO OPERADOR *****"
	m_pag      := 1                                    
	wnrel      := "FAXDP"
	lprim      := .t.
	li         := 80
	nTipo      := 0
	wFlag      := .t. 


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria parametros se nao existir e chama os parametros na tela           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ValidPerg()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT.								     ³
	//³ Verifica Posicao do Formulario na Impressora.				             ³
	//³ Solicita os parametros para a emissao do relatorio			             |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	pergunte(cPerg,.F.)
	wnrel := SetPrint(cString,cNomeProg,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,    ,.T.,cTamanho,,.F.)
	//Cancela a impressao
	If nLastKey == 27
		Return
	Endif

	cSQL := ""
	cSQL += "SELECT RA_NOME, RA_CIC , '"+SUBSTRING(RetSqlName("SRA"),4,2)+"' AS EMP " + Enter
	cSQL += "FROM " + RetSqlName("SRA") + " " + Enter
	cSQL += "WHERE  RA_MAT IN ('"+MV_PAR15+"','"+MV_PAR17+"','"+MV_PAR19+"','"+MV_PAR21+"') AND " + Enter
	cSQL += "       D_E_L_E_T_ = '' " + Enter
	If chkfile("_cTrab")
		dbSelectArea("_cTrab")
		dbCloseArea()
	EndIf
	TCQUERY cSQL ALIAS "_cTrab" NEW

	If !_cTrab->(EOF()) 
		MV_PAR15 = _cTrab->RA_NOME
		MV_PAR24 = _cTrab->RA_CIC
	Endif

	If !_cTrab->(EOF()) 
		_cTrab->(DBSKIP())
		MV_PAR17 = _cTrab->RA_NOME
		MV_PAR25 = _cTrab->RA_CIC
	Endif

	If !_cTrab->(EOF()) 
		_cTrab->(DBSKIP())
		MV_PAR19 = _cTrab->RA_NOME
		MV_PAR26 = _cTrab->RA_CIC
	Endif

	If !_cTrab->(EOF()) 
		_cTrab->(DBSKIP())
		MV_PAR21 = _cTrab->RA_NOME
		MV_PAR27 = _cTrab->RA_CIC
		_cTrab->(DBSKIP())
	Endif



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
	//AtivaRel()
	callcrys("FAXDP",MV_PAR01+";"+MV_PAR02+";"+MV_PAR03+";"+dtos(MV_PAR04)+";"+MV_PAR05+";"+MV_PAR06+";"+MV_PAR07+";"+MV_PAR08+";"+MV_PAR09+";"+dtos(MV_PAR10)+";"+MV_PAR11+";"+MV_PAR12+";"+alltrim(str(MV_PAR13))+";"+dtos(MV_PAR14)+";"+MV_PAR15+";"+alltrim(str(MV_PAR16))+";"+MV_PAR17+";"+alltrim(str(MV_PAR18))+";"+MV_PAR19+";"+alltrim(str(MV_PAR20))+";"+MV_PAR21+";"+alltrim(str(MV_PAR22))+";"+cempant+";"+MV_PAR24+";"+MV_PAR25+";"+MV_PAR26+";"+MV_PAR27,cOpcao)
Return

//+
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ValidPerg    ³ Autor ³ MAGNAGO                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria as perguntas no SX1                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ValidPerg()
	Local _j, _i
	Private _aPerguntas := {}

	AAdd(_aPerguntas,{cPerg,"01","Para:"			,"","","mv_ch01","C",15,0,0,"G","","mv_par01",""		,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AAdd(_aPerguntas,{cPerg,"01","De:"				,"","","mv_ch02","C",20,0,0,"G","","mv_par02",""		,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AAdd(_aPerguntas,{cPerg,"01","Att:"				,"","","mv_ch03","C",20,0,0,"G","","mv_par03",""		,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AAdd(_aPerguntas,{cPerg,"01","Data FAX:"		,"","","mv_ch04","D",08,0,0,"G","","mv_par04",""		,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AAdd(_aPerguntas,{cPerg,"01","Tel:"				,"","","mv_ch05","C",14,0,0,"G","","mv_par05",""		,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AAdd(_aPerguntas,{cPerg,"01","Pags:"			,"","","mv_ch06","C",03,0,0,"G","","mv_par06",""		,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AAdd(_aPerguntas,{cPerg,"01","Ref:"				,"","","mv_ch07","C",30,0,0,"G","","mv_par07",""		,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AAdd(_aPerguntas,{cPerg,"01","C/C:"				,"","","mv_ch08","C",15,0,0,"G","","mv_par08",""		,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AAdd(_aPerguntas,{cPerg,"01","Empresa:"			,"","","mv_ch09","C",30,0,0,"G","","mv_par09",""		,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AAdd(_aPerguntas,{cPerg,"01","Data Deb:"		,"","","mv_ch10","D",08,0,0,"G","","mv_par10",""		,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AAdd(_aPerguntas,{cPerg,"01","Agencia:"			,"","","mv_ch11","C",05,0,0,"G","","mv_par11",""		,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AAdd(_aPerguntas,{cPerg,"01","C/C:"				,"","","mv_ch12","C",10,0,0,"G","","mv_par12",""		,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AAdd(_aPerguntas,{cPerg,"01","Valor::"			,"","","mv_ch13","N",14,2,0,"G","","mv_par13",""		,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AAdd(_aPerguntas,{cPerg,"01","Data Cred:"		,"","","mv_ch14","D",08,0,0,"G","","mv_par14",""		,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AAdd(_aPerguntas,{cPerg,"01","Func 1:"			,"","","mv_ch15","C",50,0,0,"G","","mv_par15","SRA"	,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AAdd(_aPerguntas,{cPerg,"01","Valor::"			,"","","mv_ch16","N",14,2,0,"G","","mv_par16",""		,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AAdd(_aPerguntas,{cPerg,"01","Func 2:"			,"","","mv_ch17","C",50,0,0,"G","","mv_par17","SRA"	,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AAdd(_aPerguntas,{cPerg,"01","Valor::"			,"","","mv_ch18","N",14,2,0,"G","","mv_par18",""		,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AAdd(_aPerguntas,{cPerg,"01","Func 3:"			,"","","mv_ch19","C",50,0,0,"G","","mv_par19","SRA"	,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AAdd(_aPerguntas,{cPerg,"01","Valor::"			,"","","mv_ch20","N",14,2,0,"G","","mv_par20",""		,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AAdd(_aPerguntas,{cPerg,"01","Func 4:"			,"","","mv_ch21","C",50,0,0,"G","","mv_par21","SRA"	,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AAdd(_aPerguntas,{cPerg,"01","Valor::"			,"","","mv_ch22","N",14,2,0,"G","","mv_par22",""		,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

	DbSelectArea("SX1")
	For _i:= 1 to Len(_aPerguntas)
		If !DbSeek( cPerg + StrZero(_i,2) )
			RecLock("SX1",.T.)
			For _j:= 1 to FCount()
				FieldPut(_j,_aPerguntas[_i,_j])
			Next _j
			MsUnLock()
		Endif
	Next _i
Return