#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "MATA410.CH"
#include "tbiconn.ch"
#INCLUDE "TOTVS.CH"

#DEFINE __nMAX_THREADS__ 15


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	   ³ UserLibrary ³ Autor ³ WLADIMIR ILLIUSHENKO  ³ Data ³ 04/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ BIBLIOTECA DE FUNCOES E PROCEDIMENTOS         		   	     		 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		   ³ TODOS OS MODULOS                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ OBS.:                                                                    ³
³       Todas as funcoes aqui escritadas devem conter comentario sobre ... ³
³       sua meta, parametros e um exemplo de sua utilizacao.               ³
³                                                                          ³
³       Todas as funcoes aqui escritadas devem possuir no inicio de seu... ³
³       nome "pf" (minusculos) identificando como "Public Function".       ³
³                                                                          ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*/

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡Æo    ³fOpen_Word³ Autor ³ Marinaldo de Jesus    ³ Data ³06/05/2000³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡Æo ³Selecionaro os Arquivos do Word.                            ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
USER Function fOpen_Word()

	Local cSvAlias		:= Alias()
	Local lAchou		:= .F.
	Local cTipo			:= "Modelo de Documentos(*.DOT)  |*.DOT | "														
	Local cNewPathArq	:= cGetFile( cTipo , "Seleccione el archivo *.DOT" )

	IF !Empty( cNewPathArq )
		IF Upper( Subst( AllTrim( cNewPathArq), - 3 ) ) == Upper( AllTrim( "DOT" ) )
			Aviso( "Archivo seleccionado:" , cNewPathArq , { "OK" } )								
		Else
			MsgAlert( "Archivo no valido " )															
			Return
		EndIF
	Else
		Aviso(STR0012 ,{ "OK" } )													
		Return
	EndIF

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Limpa o parametro para a Carga do Novo Arquivo                         ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	dbSelectArea("SX1")
	//IF lAchou := ( SX1->( dbSeek( "WRDARQ02" , .T. ) ) )
	//RecLock("SX1",.F.,.T.)
	//SX1->X1_CNT01 := Space( Len( SX1->X1_CNT01 ) )
	mv_par25 := cNewPathArq
	//MsUnLock()
	//EndIF	
	dbSelectArea( cSvAlias )

Return( .T. )





/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Retorna uma string com a quantidade em paletes+caixas de um determinado..³
³ produto.                                                                 ³
³                                                                          ³
³ EX: U_PALETES("A",170) -> "     2p+(8cx)"                                ³
³     U_PALETES("B",170) -> "    2p+(42cx)"                                ³
³     U_PALETES("C",170) -> "    1p+(74cx)"                                ³
³                                                                          ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*/
user function paletes(cCod,nQuant,NLOTE)
	local Paletes, ndivisor 

	//Posiciona no Cadastro de Produto
	CQUERY1 := "SELECT B1_CONV AS FATOR, B1_YDIVPA, * FROM "+RETSQLNAME("SB1")+" WHERE B1_COD =  '"+ALLTRIM(cCod)+"' AND D_E_L_E_T_ = '' "
	If chkfile("_AAUX")
		dbSelectArea("_AAUX")
		dbCloseArea()
	EndIf
	TCQUERY CQUERY1 ALIAS "_AAUX" NEW

	//Posiciona no Cadastro Lote/Produto
	cSQLL := "SELECT * FROM "+RetSqlName("ZZ9")+" WHERE	ZZ9_PRODUT = '"+cCod+"' AND  ZZ9_LOTE = '"+NLOTE+"' AND 	D_E_L_E_T_ = '' "
	IF chkfile("_ZZ9")
		dbSelectArea("_ZZ9")
		dbCloseArea()
	ENDIF
	TCQuery cSQLL Alias "_ZZ9" New

	IF !_ZZ9->(EOF())
		sPESEMB	:= _ZZ9->ZZ9_PESEMB
		sPESO		:= _ZZ9->ZZ9_PESO
		sDIVPA	:= _ZZ9->ZZ9_DIVPA
	ELSE
		sPESEMB := _AAUX->B1_YPESEMB
		sPESO		:= _AAUX->B1_PESO
		sDIVPA	:= _AAUX->B1_YDIVPA
	END IF

	ndivisor	:= sDIVPA
	nQuant 		:= (nQuant / _AAUX->FATOR)
	nQuant 		:= int(noround(nQuant))

	Paletes		:= iif(int(nQuant / ndivisor)>0,Alltrim(Str(int(nQuant / ndivisor))+iif((nQuant % ndivisor)>=1,"p+","p")),"")+iif((nQuant % ndivisor) >= 1,"("+AllTrim(Str((nQuant % ndivisor),13,0))+"cx)","")
	Paletes		:= padl(Paletes,13)

Return Paletes


/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Retorna uma string com a quantidade em paletes+caixas de um determinado..³
³ produto.                                                                 ³
³                                                                          ³
³ EX: U_PALETES("A",170) -> "     2p+(8cx)"                                ³
³     U_PALETES("B",170) -> "    2p+(42cx)"                                ³
³     U_PALETES("C",170) -> "    1p+(74cx)"                                ³
³                                                                          ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*/
USER FUNCTION NUMPALETES(CTIPO,NQUANT,NLOTE)
	local Paletes, ndivisor 

	CQUERY1 := "SELECT B1_CONV AS FATOR, B1_YDIVPA, * FROM "+RETSQLNAME("SB1")+" "
	CQUERY1 += "WHERE B1_COD =  '"+ALLTRIM(CTIPO)+"' AND D_E_L_E_T_ = '' "
	If chkfile("_AAUX")
		dbSelectArea("_AAUX")
		dbCloseArea()
	EndIf
	TCQUERY CQUERY1 ALIAS "_AAUX" NEW

	aCODPRODUTO := alltrim(cTipo) //(SB1->B1_YFORMAT+SB1->B1_YFATOR+SB1->B1_YLINHA+SB1->B1_YCLASSE)
	cSQLL := ""
	cSQLL := "SELECT * FROM ZZ9010 "
	cSQLL += "WHERE	ZZ9_PRODUT = '" +aCODPRODUTO+ "' AND  "
	cSQLL += "		ZZ9_LOTE = '" +NLOTE+ "' AND "
	cSQLL += "		D_E_L_E_T_ = '' "
	IF chkfile("_ZZ9")
		dbSelectArea("_ZZ9")
		dbCloseArea()
	ENDIF
	TCQuery cSQLL Alias "_ZZ9" New
	IF ! _ZZ9->(EOF())
		sPESEMB := _ZZ9->ZZ9_PESEMB
		sPESO	:= _ZZ9->ZZ9_PESO
		sDIVPA	:= _ZZ9->ZZ9_DIVPA
	ELSE
		sPESEMB := _AAUX->B1_YPESEMB
		sPESO	:= _AAUX->B1_PESO
		sDIVPA	:= _AAUX->B1_YDIVPA
	END IF

	ndivisor := sDIVPA

	IF _AAUX->B1_YDIVPA <> 0
		nQuant := int((nQuant / _AAUX->FATOR) / _AAUX->B1_YDIVPA)
	ELSE
		nQuant := 0
	END IF

Return nQuant


/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Retorna uma data a partir de uma data em formato string.                 ³
³                                                                          ³
³ EX: U_STOD('20010501') -> 01/05/2001                                     ³
³                                                                          ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*/
user function stod(cData)
return ctod(substr(cData,7,2)+"/"+substr(cData,5,2)+"/"+substr(cData,1,4))

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Transforma um valor real em caracter formatadio. Se o valor for igual ...³
³ a zero a funcao retorna "           -  ".                                ³
³                                                                          ³
³ SINTAXE: U_RTOC(<nValor>[,<cMascara>])                                   ³
³                                                                          ³
³ EX:                                                                      ³
³     U_RTOC(0.00)         -> "           -  "                             ³
³     U_RTOC(8235.56)      -> "      8.235,56"                             ³
³     U_RTOC(7,"@E 99,99") -> " 7,00"                                      ³
³                                                                          ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*/
user function rtoc(nValor,cMascara)
	local cContraMasc,a,b
	cMascara    := iif(valtype(cMascara)<>"C","@E 999,999,999.99",cMascara)
	a           := len(substr(cMascara,1,at("9",cMascara)-1)) // Total de digitos que devem ser ignorados
	b           := iif(at(".",cMascara)>0,len(substr(cMascara,at(".",cMascara))),1)   // Total de digitos depois do ponto decimal
	cContraMasc := space(len(cMascara)-a-b)+"-"+space(b-1)
return iif(nValor == 0 .OR. AllTrim(Transform(nValor,cMascara)) == AllTrim(Transform(0,cMascara)),cContraMasc,Transform(nValor,cMascara))

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Retorna o nome completo do mes em funcao da data passada como parametro. ³
³                                                                          ³
³ EX:                                                                      ³
³     U_MES(ctod("01/02/2001")) -> "FEVEREIRO"                             ³
³                                                                          ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*/
User Function mes(dData)
	Local cMeses := "01JANEIRO 02FEVEREIRO 03MARCO 04ABRIL 05MAI 06JUNHO 07JULHO 08AGOSTO 09SETEMBRO 10OUTUBRO 11NOVEMBRO 12DEZEMBRO "
	dData := iif(valtype(dData)<>"D",date(),dData)
	//Return substr(cMeses,at(strzero(month(dData),2),cMeses)+2,9) 
Return substr(cMeses,at(strzero(month(dData),2),cMeses),11)

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Retorna o nome reduzido do mes em funcao da data passada como parametro. ³
³                                                                          ³
³ EX:                                                                      ³
³     U_MESR(ctod("01/02/2001")) -> "FEV"                                  ³
³                                                                          ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*/
user function mesr(dData)
	local cMeses := "01JAN02FEV03MAR04ABR05MAI06JUN07JUL08AGO09SET10OUTT11NOV12DEZ"
	dData := iif(valtype(dData)<>"D",date(),dData)
return substr(cMeses,at(strzero(month(dData),2),cMeses)+2,3)

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Retorna uma data passada como parametro no formato reduzido mm/aa        ³
³                                                                          ³
³ EX:                                                                      ³
³     U_DATAR(ctod("01/02/2001"),4) -> "FEV/2001"                          ³
³     U_DATAR(ctod("01/02/2001"))   -> "FEV/01"                            ³
³                                                                          ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*/
user function datar(dData,nDigAno)
	local cMeses := "01JAN02FEV03MAR04ABR05MAI06JUN07JUL08AGO09SET10OUTT11NOV12DEZ"
	dData   := iif(valtype(dData)<>"D",date(),dData)
	nDigAno := iif(valtype(nDigAno)<>"N",2,iif(!(str(nDigAno,1)$"2,4"),2,nDigAno))
return substr(cMeses,at(strzero(month(dData),2),cMeses)+2,3)+"/"+iif(nDigAno=2,substr(str(year(dData),4),3,2),str(year(dData),4))

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Retorna o nome completo do dia da semana em funcao da data passada ...   ³
³ como parametro.                                                          ³
³                                                                          ³
³ EX:                                                                      ³
³     U_DIA(ctod("21/06/2001")) -> "QUARTA "                               ³
³     U_DIA()                   -> "SEGUNDA"                               ³
³                                                                          ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*/
user function dia(dData)
	local cDias := "1DOMINGO2SEGUNDA3TERCA  4QUARTA 5QUINTA 6SEXTA  7SABADO "
return substr(cDias,at(str(dow(dData),1),cDias)+1,7)

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Retorna o nome reduzido do dia da semana em funcao da data passada ...   ³
³ como parametro.                                                          ³
³                                                                          ³
³ EX:                                                                      ³
³     U_DIAR(ctod("21/06/2001")) -> "Q"                                    ³
³     U_DIAR()                   -> "S"                                    ³
³                                                                          ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*/
user function diar(dData)
	local cDias := "1D2S3T4Q5Q6S7S"
return substr(cDias,at(str(dow(dData),1),cDias)+1,1)

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Retorna uma string com o mes/ano acrecido do contador informado nos ...  ³
³ parametros. A funcao tambem permite informar a quantidade de digitos ... ³
³ para o ano.                                                              ³
³                                                                          ³
³ SINTAXE: U_MESANO([<data>[,[<dano>],[<n>]]])                             ³
³ dano -> digitos para ano (2/4)                                           ³
³ n    -> contator (inteiro positivo/negativo)                             ³
³                                                                          ³
³ EX:                                                                      ³
³     U_MESANO(ctod("21/06/2001"),4,2)  -> "08/2001"                       ³
³     U_MESANO(ctod("21/06/2001"),2,2)  -> "08/01"                         ³
³     U_MESANO(ctod("21/06/2001"),4,-2) -> "04/2001"                       ³
³     U_MESANO(ctod("21/06/2001"),2,-2) -> "04/01"                         ³
³     U_MESANO(ctod("21/06/2001"),4)    -> "06/2001"                       ³
³     U_MESANO(ctod("21/06/2001"),2)    -> "06/01"                         ³
³     U_MESANO(ctod("21/06/2001"))      -> "06/2001"                       ³
³     U_MESANO()                        -> "07/2001"                       ³
³                                                                          ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*/
User function MesAno(dData,nDAno,nCont)
	local nMes, nAno, nX

	dData := iif(valtype(dData)<>"D",date(),dData)
	nDAno := iif(valtype(nDAno)<>"N",4,iif(!str(nDAno,1)$"24",4,nDAno))
	nCont := iif(valtype(nCont)<>"N",0,nCont)
	nMes  := month(dData)
	nAno  := year(dData)

	for nX := 1 to abs(nCont)
		nMes += iif(nCont>0,1,-1)
		if nMes == 0
			nMes := 12
			nAno--
		else
			if nMes == 13
				nMes := 1
				nAno++
			endif
		endif
	next

return(strzero(nMes,02)+"/"+iif(nDAno == 2,substr(strzero(nAno,04),3,2),strzero(nAno,04)))

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Retorna a data do ultimo dia do mes da data passada como parametro.      ³
³                                                                          ³
³ SINTAXE: U_ULTDIAM([<data>])                                             ³
³                                                                          ³
³ EX:                                                                      ³
³     U_ULTDIAM(ctod("21/06/2001"))  -> "30/06/2001"                       ³
³     U_ULTDIAM()                    -> "31/07/2001"                       ³
³                                                                          ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*/
User function UltDiaM(dData)
	local nMesAtual
	dData     := iif(valtype(dData)<>"D",date(),dData)
	nMesAtual := month(dData)
	dData     := ctod("27/"+strzero(nMesAtual,2)+"/"+strzero(year(dData),4))
	do while month(dData + 1) == nMesAtual
		dData := dData + 1
	enddo
return(dData)

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Retorna uma string com o nome do Banco de Dados SQL usado no ...         ³
³ Environment atual.                                                       ³
³                                                                          ³
³ SINTAXE: U_DBNAME()                                                      ³
³                                                                          ³
³ EX:                                                                      ³
³     U_DBNAME() -> "BIANCOGRES"                                           ³
³                                                                          ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*/
User function DBName()
	local cQuery
	cQuery  := "SELECT DB_NAME() AS DBNAME"
	If chkfile("X")
		dbSelectArea("X")
		dbCloseArea()
	EndIf
	TCQuery cQuery Alias "X" New
	cQuery := X->DBNAME
	X->(DbCloseArea())
return(Upper(cQuery))

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Retorna uma string com o tipo do frete.                                  ³
³                                                                          ³
³ SINTAXE: U_TPFRETE(<cDoc>,<cSerie>,<cFornec>)                            ³
³                                                                          ³
³ EX:                                                                      ³
³     U_TPFRETE('000001','S1 ','000006') -> "CIF"                          ³
³     U_TPFRETE('000002','S1 ','000006') -> "FOB"                          ³
³                                                                          ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*/
User function TpFrete(cDoc,cSerie,cFornec)
	local cQuery, nTotRegs
	cQuery  := ""
	cQuery  += "SELECT COUNT(SF8.F8_NFORIG) AS TOTREGS "
	cQuery  += "FROM "+RetSQLName("SF8")+" SF8 "
	cQuery  += "WHERE "
	cQuery  += "     (SF8.F8_NFORIG  = '"+padr(trim(cDoc),6)   +"') AND "
	cQuery  += "     (SF8.F8_SERORIG = '"+padr(trim(cSerie),3) +"') AND "
	cQuery  += "     (SF8.F8_FORNECE = '"+padr(trim(cFornec),6)+"') AND "
	cQuery  += "     (SF8.D_E_L_E_T_ <> '*'          ) "
	If chkfile("X")
		dbSelectArea("X")
		dbCloseArea()
	EndIf
	TCQuery cQuery Alias "X" New
	nTotRegs := X->TOTREGS
	X->(DbCloseArea())
return(iif(nTotRegs>0,"FOB","CIF"))

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Imprime os parametros de um determinado relatorio.                       ³
³                                                                          ³
³ SINTAXE: U_IMPPAR(<cNomeProg>,<cTitulo>,<cTamanho>,<nCrcControl>,        ³
³                   <nCbCont>,<cCbtxt>,<nL>)                               ³
³                                                                          ³
³ EX:                                                                      ³
³     U_IMPPAR(cNomeProg,cTitulo,cTamanho,nCrcControl,nCbCont,cCbtxt,@nL)  ³
³                                                                          ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*/
User function ImpPar(cNomeProg,cTitulo,cTamanho,nCrcControl,nCbCont,cCbtxt,nL)
	local cLinDeImp
	cOldAlias := Alias()
	DBSelectArea("SX1")
	DBSetOrder(1)

	if SX1->(DBSeek(cNomeProg+"01"))
		do while SX1->X1_GRUPO == cNomeProg
			if nL >= 65
				nL := Cabec("Parametros - "+cTitulo,"","",cNomeProg,cTamanho,nCrcControl) + 2
			endif

			cPergunta := ""
			do case
			case SX1->X1_GSC == "C"
				do case
				case SX1->X1_PRESEL == 1; cPergunta := SX1->X1_DEF01
				case SX1->X1_PRESEL == 2; cPergunta := SX1->X1_DEF02
				case SX1->X1_PRESEL == 3; cPergunta := SX1->X1_DEF03
				case SX1->X1_PRESEL == 4; cPergunta := SX1->X1_DEF04
				case SX1->X1_PRESEL == 5; cPergunta := SX1->X1_DEF05
				endcase

			case SX1->X1_GSC == "G"; cPergunta := SX1->X1_CNT01
			endcase

			cLinDeImp := ""
			cLinDeImp += "Pergunta "+SX1->X1_ORDEM+": "+SX1->X1_PERGUNT+"  "+Iif(Alltrim(SX1->X1_TIPO)=="D",dtoc(stod(Alltrim(cPergunta))),cPergunta)
			@ nL,000 PSay cLinDeImp
			nL+=2
			SX1->(DBSkip())
		enddo
		Roda(nCbCont, cCbtxt, cTamanho)
	endif
	DBSelectArea(cOldAlias)
	nL := 99
return

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Envia e-mail                                                             ³
³                                                                          ³
³ SINTAXE: U_SENDMAIL([<lFormTexto>],<cTexto>,<cTitulo>,<cRemetente>,      ³
³                     <aDestinatario>[,<aCC>[,<aCCO>[,<aAnexo>]]])         ³
³                                                                          ³
³ EX:                                                                      ³
³     U_SENDMAIL(.F.,"Teste...","TESTE","from@abc",{"to@abc"})             ³
³     U_SENDMAIL(.T.,"Teste...","TESTE","from@abc",{"to@abc"},{"cc@abc")   ³
³     U_SENDMAIL(,"Teste...","TESTE","from@abc",{"to@abc"},{"cc@abc"},     ³
³                {"cco@abc"})                                              ³
³     U_SENDMAIL(,"Teste...","TESTE","from@abc",{"to@abc"},,{"cco@abc"})   ³
³     U_SENDMAIL(,"Teste...","TESTE","from@abc",{"to@abc"},,,              ³
³                {"C:\CARTA.DOC","S:\MODELO.PDF"})                         ³
³                                                                          ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*/
User Function SendMail(lFormTexto,cTexto,cTitulo,cRemetente,aDestinatario,aCC,aCCO,aAnexo)
	local cServidor, cConta, wSenha, lEnviado
	aDestinatario := iif(valtype(aDestinatario)<>"A",{},aDestinatario)
	aCC           := iif(valtype(aCC)<>"A",{},aCC)
	aCCO          := iif(valtype(aCCO)<>"A",{},aCCO)
	aAnexo        := iif(valtype(aAnexo)<>"A",{},aAnexo)
	lFormTexto    := iif(valtype(lFormTexto)<>"L",.F.,lFormTexto)
	cServidor     := alltrim(GETMV("MV_RELSERV"))
	cConta        := alltrim(GETMV("MV_RELACNT"))
	wSenha        := alltrim(GETMV("MV_RELPSW"))
	CONNECT SMTP SERVER cServidor ACCOUNT cConta PASSWORD wSenha
	lEnviado := MailSend( cRemetente, aDestinatario, aCC, aCCO, cTitulo, cTexto, aAnexo )
	DISCONNECT SMTP SERVER
Return lEnviado

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ PRECO_TABELA     ³ Autor ³ BRUNO MADALENO        ³ Data ³ 14/03/07  	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³VL_IMPOS: busca o preco na tabela de preco                	   		³±±
±±³          ³                                                			            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ SPRODUTO     CODIGO DO PRODUTO                             			³±±
±±³          ³ DATAREF      DATA REFERENCIA NA TABELA DE PRECO             			³±±
±±³          ³ CLIENTE  	PARA BUSCAR O ESTADO                           			³±±
±±³          ³ LOJA         PARA BUSCAR A LOJA DO CLIENTE                			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ O VALOR DO PREÇO CADASTRADO NA TABELA DE PRECO              			³±±
±±³          ³                                                             			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta funcao busca o preco cadastrado previamente no sistema  			³±±
±±³          ³                                                             			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ personalizacao                                              			³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

USER FUNCTION PRECO_TABELA(PRODUTO, DATAREF, CLIENTE, LOJA)
	LOCAL PRECO_TAB := 0

	Local cArq	:= ""
	Local cInd	:= 0
	Local cReg	:= 0

	Local cArqSB1	:= ""
	Local cIndSB1	:= 0
	Local cRegSB1	:= 0

	Local cArqZZ8	:= ""
	Local cIndZZ8	:= 0
	Local cRegZZ8	:= 0

	Local cArqSA1	:= ""
	Local cIndSA1	:= 0
	Local cRegSA1	:= 0

	cArq := Alias()
	cInd := IndexOrd()
	cReg := Recno()

	DbSelectArea("SB1")
	cArqSB1 := Alias()
	cIndSB1 := IndexOrd()
	cRegSB1 := Recno()

	DbSelectArea("ZZ8")
	cArqZZ8 := Alias()
	cIndZZ8 := IndexOrd()
	cRegZZ8 := Recno()

	DbSelectArea("SA1")
	cArqSA1 := Alias()
	cIndSA1 := IndexOrd()
	cRegSA1 := Recno()

	//POSICIONANDO NA TABELA DE PRODUTO
	dbSelectArea("SB1")
	dbSetOrder(1)
	If !dbSeek(xFilial("SB1")+PRODUTO,.F.)
		MsgStop("Produto "+Alltrim(PRODUTO)+", nao esta cadastrado")
		RETURN("")
	Else
		wB1YREFPV  := SB1->B1_YREFPV
	EndIf

	DbSelectArea("ZZ8")
	DbSetOrder(1)
	IF DbSeek(xFilial("ZZ8")+SB1->B1_YCLASSE)
		wClasse := ALLTRIM(ZZ8->ZZ8_DESC)
	ELSE
		MsgStop("Classe: "+SB1->B1_YCLASSE+"-"+SB1->B1_COD+", nao programada para este programa: INC313")
	ENDIF

	//BUSCANDO O ESTADO DO CLIENTE
	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1") + CLIENTE + LOJA))
	wEst := SA1->A1_EST
	If !wEst $ ("ES_EX")
		wEst := "OU"
	EndIf

	cWhere  := ""
	cWhere += "SELECT * "
	IF ALLTRIM(FUNNAME()) == "IMP_CRITE"
		if CCEMP = "02"
			cWhere += "From SZ2010 SZ2, SZ1010 SZ1 "
		else
			cWhere += "From SZ2050 SZ2, SZ1050 SZ1 "
		end if
	ELSE
		cWhere += "From " + RETSQLNAME("SZ2") + " SZ2, " + RETSQLNAME("SZ1") + " SZ1 "
	END IF
	cWhere += "Where 	SZ2.Z2_REFER 	= '" + wB1YREFPV + "' And "
	cWhere += "	'" + DTOS(DATAREF) +"' 	>= SZ2.Z2_DTINIPR    And "
	cWhere += "	'" + DTOS(DATAREF) +"' 	<= SZ2.Z2_DTFIMPR    And "
	cWhere += "	SZ1.Z1_EST	= '" + wEst +"'		     And "
	cWhere += "	SZ1.Z1_CLASSE	= '" + wClasse +"'	 And "
	cWhere += "	SZ1.Z1_REFER 	= SZ2.Z2_REFER       And "
	cWhere += "	SZ1.Z1_DTINIPR 	= SZ2.Z2_DTINIPR     And "
	cWhere += "	SZ1.D_E_L_E_T_	= ''		         And "
	cWhere += "	SZ2.D_E_L_E_T_ 	= '' "
	If chkfile("rPreco_2")
		dbSelectArea("rPreco_2")
		dbCloseArea()
	EndIf
	TCQUERY cWhere ALIAS "rPreco_2" NEW

	If !rPreco_2->(EOF())
		PRECO_TAB := rPreco_2->Z1_VALOR
	else
		PRECO_TAB := 0
	END IF

	If cArqSB1 <> ""
		dbSelectArea(cArqSB1)
		dbSetOrder(cIndSB1)
		dbGoTo(cRegSB1)
		RetIndex("SB1")
	EndIf

	If cArqZZ8 <> ""
		dbSelectArea(cArqZZ8)
		dbSetOrder(cIndZZ8)
		dbGoTo(cRegZZ8)
		RetIndex("ZZ8")
	EndIf

	If cArqSA1 <> ""
		dbSelectArea(cArqSA1)
		dbSetOrder(cIndSA1)
		dbGoTo(cRegSA1)
		RetIndex("SA1")
	EndIf

	DbSelectArea(cArq)
	DbSetOrder(cInd)
	DbGoTo(cReg)

RETURN(PRECO_TAB)


/*/{Protheus.doc} SIT_FIN
@description TELA DE POSICAO DE CLIENTES
@author Fernando Rocha
@since 27/04/2017
@version undefined
@param cCLIENTE, characters, descricao
@param cLoja, characters, descricao
@param lValidCli, logical, descricao
@param lReport, logical, descricao
@param cCodVen, characters, descricao
@param nLimCre, numeric, descricao
@param nPedCar, numeric, descricao
@param nSalDup, numeric, descricao
@type function
/*/
User Function SIT_FIN(cCLIENTE, cLoja, lValidCli, lReport, cCodVen, nLimCre, nPedCar, nSalDup)
	Local Enter		:= CHR(13)+CHR(10)
	Local lRetSt 	:= .T.

	SALDO_DUPLI	:= 0 //SALDO DE DUPLICATAS EM ABERTO
	SALDO_LIB	:= 0 //SALDO DE DUPLICATAS EM ABERTO DE PEDIDOS COM LIBERACAO MANUAL
	TOTPED		:= 0 //SALDO DE PEDIDOS EM ABERTO
	TOTPED_LIB	:= 0 //SALDO DE PEDIDOS EM ABERTO DE PEDIDOS COM LIBERACAO MANUAL

	TOTAL_RA	:= 0 //SALDO DE RA EM ABERTO
	TOTAL_RALM	:= 0 //SALDO DE RA EM ABERTO
	TOTPEDRA	:= 0 //SALDO DE PEDIDOS DE RA EM ABERTO
	TOTTITRA	:= 0 //SALDO TITULOS A SEREM COMPENSADOS
	TOTTITRALM	:= 0 //SALDO TITULOS A SEREM COMPENSADOS

	wsCli		:= cCliente
	wsLoja		:= IIF(Empty(cLoja),'01', cLoja)
	wsFim		:= .T.

	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek(xFilial("SA1")+wsCli+wsLoja,.F.)

	//Traz a Query de Titulos em Aberto.
	cSql := U_QryTitAber(SA1->A1_COD,SA1->A1_LOJA, SA1->A1_YTIPOLC, SA1->A1_GRPVEN, .F. )

	If chkfile("_SE1")
		DbSelectArea("_SE1")
		DbCloseArea()
	EndIf
	TCQUERY cSql NEW ALIAS "_SE1"

	While( !_SE1->(Eof()))
		//Grava o Saldo de Titulos em Aberto
		If _SE1->LIBMAN == 'N'
			SALDO_DUPLI := _SE1->SALDO
		Else
			SALDO_LIB  := _SE1->SALDO
		EndIf
		_SE1->(dbSkip())
	End

	_SE1->(dbCloseArea())

	//Traz a Query de Pedidos Consolidados
	If ValType(lReport) <> "U" .And. lReport
		CSQL := U_QryPedCons(SA1->A1_COD,SA1->A1_LOJA, SA1->A1_YTIPOLC, SA1->A1_GRPVEN, '', .F., lReport, cCodVen)
	Else
		CSQL := U_QryPedCons(SA1->A1_COD,SA1->A1_LOJA, SA1->A1_YTIPOLC, SA1->A1_GRPVEN, '', .F.)
	EndIf

	If chkfile("PEDIDO")
		dbSelectArea("PEDIDO")
		dbCloseArea()
	EndIf
	TCQUERY CSQL ALIAS "PEDIDO" NEW

	While( !PEDIDO->(Eof()))
		//Grava o Saldo de Titulos em Aberto
		If PEDIDO->LIBMAN == 'N'
			TOTPED 	   := PEDIDO->SALDO
		Else
			TOTPED_LIB := PEDIDO->SALDO
		EndIf
		PEDIDO->(dbSkip())
	End

	PEDIDO->(dbCloseArea())

	//(02/02/2015 - Thiago) ->Se está na Inclusão do Pedido, Valida
	If lValidCli
		lRetSt := ValStatFin()
	EndIf

	//RUBENS JUNIOR - PARA ATENDER A NECESSIDADE DE ENXERGAR A RA DA EMPRESA CORRENTE E DA LM
	//E NAO SOMENTE DA EMPRESA CORRENTE COMO ESTAVA SENDO FEITO ANTERIORMENTE
	If cEmpant != '07'
		CSQL := " SELECT SUM(SALDO) AS SALDO FROM  ( "
	Else
		CSQL := " "
	EndIf
	CSQL += "SELECT ISNULL(SUM(ROUND((ROUND(C6_VALOR-(C6_QTDENT*C6_PRCVEN),2)/C6_VALOR*100)*C6_YVLIMP/100,2)),0) SALDO" + Enter
	CSQL += "FROM "+RetSqlName("SC5")+" SC5 WITH (NOLOCK), "+RetSqlName("SC6")+" SC6 WITH (NOLOCK), "+RetSqlName("SF4")+" SF4 WITH (NOLOCK), "+RetSqlName("SE4")+" SE4 WITH (NOLOCK), "+RetSqlName("SA1")+" SA1 " + Enter
	CSQL += "WHERE	1=1 AND
	CSQL += "		SC5.C5_FILIAL	IN (SELECT FILIAL FROM FNC_FILIAL('" + SUBSTR(RetSqlName("SC5"), 4, 2) + "')) AND " + Enter
	CSQL += "		SC6.C6_FILIAL	IN (SELECT FILIAL FROM FNC_FILIAL('" + SUBSTR(RetSqlName("SC6"), 4, 2) + "')) AND " + Enter
	CSQL += "		SF4.F4_FILIAL	IN (SELECT FILIAL FROM FNC_FILIAL('" + SUBSTR(RetSqlName("SF4"), 4, 2) + "')) AND " + Enter
	CSQL += "		SE4.E4_FILIAL	= '"+xFilial("SE4")+"' AND " + Enter
	CSQL += "		SC5.C5_NUM		= SC6.C6_NUM AND  " + Enter
	CSQL += "  		SC5.C5_CLIENTE	= SC6.C6_CLI AND  " + Enter
	CSQL += "		SC5.C5_LOJACLI	= SC6.C6_LOJA AND  " + Enter
	CSQL += "		SC5.C5_CONDPAG  = SE4.E4_CODIGO AND  " + Enter
	CSQL += "		SC6.C6_TES		= SF4.F4_CODIGO AND  " + Enter
	CSQL += "		SC5.C5_TIPO		= 'N'			AND	 " + Enter
	CSQL += "		SC6.C6_QTDVEN-C6_QTDENT > 0 AND  " + Enter
	CSQL += "		SC6.C6_VALOR    > 0         AND  " + Enter
	CSQL += "		SC6.C6_BLQ		<>	'R' AND  " + Enter
	CSQL += "		SF4.F4_DUPLIC	=	'S' AND  " + Enter
	CSQL += "		SE4.E4_DESCRI LIKE '%ANTE%' AND  " + Enter
	CSQL += "		SC5.C5_CLIENTE	= SA1.A1_COD	AND	" + Enter
	CSQL += "		SC5.C5_LOJACLI	= SA1.A1_LOJA	AND	" + Enter
	IF ALLTRIM(SA1->A1_GRPVEN) <> "" .AND. SA1->A1_YTIPOLC == "G"
		CSQL += "		SA1.A1_GRPVEN = '"+SA1->A1_GRPVEN+"' AND SA1.A1_YTIPOLC = 'G' AND 	" + ENTER
	ELSE
		CSQL += "		SA1.A1_COD = '"+wsCli+"' AND SA1.A1_LOJA = '"+wsLoja+"'	AND " + ENTER
	END IF
	CSQL += "		SC5.D_E_L_E_T_  = '' AND  " + Enter
	CSQL += "		SC6.D_E_L_E_T_  = '' AND  " + Enter
	CSQL += "		SF4.D_E_L_E_T_  = '' AND  " + Enter
	CSQL += "		SE4.D_E_L_E_T_  = '' AND 	  " + Enter
	CSQL += "		SA1.D_E_L_E_T_  = ''  " + Enter
	If cEmpant != '07'
		CSQL += " UNION ALL " + Enter
		CSQL += "SELECT ISNULL(SUM(ROUND((ROUND(C6_VALOR-(C6_QTDENT*C6_PRCVEN),2)/C6_VALOR*100)*C6_YVLIMP/100,2)),0) SALDO" + Enter
		CSQL += "FROM SC5070 SC5 WITH (NOLOCK), SC6070 SC6 WITH (NOLOCK), SF4070 SF4 WITH (NOLOCK), SE4010 SE4 WITH (NOLOCK), SA1070 SA1 " + Enter
		CSQL += "WHERE	1=1 AND
		CSQL += "		SC5.C5_FILIAL	IN (SELECT FILIAL FROM FNC_FILIAL('07')) AND " + Enter
		CSQL += "		SC6.C6_FILIAL	IN (SELECT FILIAL FROM FNC_FILIAL('07')) AND " + Enter
		CSQL += "		SF4.F4_FILIAL	IN (SELECT FILIAL FROM FNC_FILIAL('07')) AND " + Enter
		CSQL += "		SE4.E4_FILIAL	= '"+xFilial("SE4")+"' AND " + Enter
		CSQL += "		SC5.C5_NUM		= SC6.C6_NUM AND  " + Enter
		CSQL += "  		SC5.C5_CLIENTE	= SC6.C6_CLI AND  " + Enter
		CSQL += "		SC5.C5_LOJACLI	= SC6.C6_LOJA AND  " + Enter
		CSQL += "		SC5.C5_CONDPAG  = SE4.E4_CODIGO AND  " + Enter
		CSQL += "		SC6.C6_TES		= SF4.F4_CODIGO AND  " + Enter
		CSQL += "		SC5.C5_TIPO		= 'N'			AND	 " + Enter
		CSQL += "		SC6.C6_QTDVEN-C6_QTDENT > 0 AND  " + Enter
		CSQL += "		SC6.C6_VALOR    > 0         AND  " + Enter
		CSQL += "		SC6.C6_BLQ		<>	'R' AND  " + Enter
		CSQL += "		SF4.F4_DUPLIC	=	'S' AND  " + Enter
		CSQL += "		SE4.E4_DESCRI LIKE '%ANTE%' AND  " + Enter
		CSQL += "		SC5.C5_CLIENTE	= SA1.A1_COD	AND	" + Enter
		CSQL += "		SC5.C5_LOJACLI	= SA1.A1_LOJA	AND	" + Enter
		IF ALLTRIM(SA1->A1_GRPVEN) <> "" .AND. SA1->A1_YTIPOLC == "G"
			CSQL += "		SA1.A1_GRPVEN = '"+SA1->A1_GRPVEN+"' AND SA1.A1_YTIPOLC = 'G' AND 	" + ENTER
		ELSE
			CSQL += "		SA1.A1_COD = '"+wsCli+"' AND SA1.A1_LOJA = '"+wsLoja+"'	AND " + ENTER
		END IF
		CSQL += "		SC5.D_E_L_E_T_  = '' AND  " + Enter
		CSQL += "		SC6.D_E_L_E_T_  = '' AND  " + Enter
		CSQL += "		SF4.D_E_L_E_T_  = '' AND  " + Enter
		CSQL += "		SE4.D_E_L_E_T_  = '' AND 	  " + Enter
		CSQL += "		SA1.D_E_L_E_T_  = ''  " + Enter
		CSQL += " ) TEMP"
	EndIf

	If chkfile("PEDIDO")
		dbSelectArea("PEDIDO")
		dbCloseArea()
	EndIf
	TCQUERY CSQL ALIAS "PEDIDO" NEW

	//Armazena o Saldo de Pedidos de RA em Aberto
	TOTPEDRA := PEDIDO->SALDO

	wSalDisp 	:= SA1->A1_LC - (SALDO_DUPLI + TOTPED)
	wsFim		:= .T.
	wTotPed		:= TOTPED

	If wTotPed == 0
		wTotPed := 0.001
	EndIf

	If wSalDisp == 0
		wSalDisp := 0.001
	EndIf

	wA1_LC		:= SA1->A1_LC
	wA1_SALDUP	:= SALDO_DUPLI
	wA1_NOME	:= SA1->A1_NOME

	If Empty(SA1->A1_VENCLC)
		wA1_VENCLC := Ctod("01/01/80")
	Else
		wA1_VENCLC := SA1->A1_VENCLC
	EndIf

	// RA da Empresa
	CSQL := QryTotRAEM()

	If chkfile("_RA")
		dbSelectArea("_RA")
		dbCloseArea()
	EndIf
	TCQUERY CSQL ALIAS "_RA" NEW

	//Grava do Saldo Total Total de RA em Aberto
	TOTAL_RA := _RA->TOTAL
	_RA->(dbCloseArea())

	if cEmpAnt != '07'
		// RA da LM
		CSQL := QryTotRALM()

		If chkfile("_RA")
			dbSelectArea("_RA")
			dbCloseArea()
		EndIf
		TCQUERY CSQL ALIAS "_RA" NEW

		//Grava do Saldo Total Total de RA em Aberto
		TOTAL_RALM := _RA->TOTAL
		_RA->(dbCloseArea())
	EndIf

	//Saldo RA da Empresa Corrente.
	CSQL := QrySldRAEM()

	If chkfile("_PEDFAT")
		dbSelectArea("_PEDFAT")
		dbCloseArea()
	EndIf
	TCQUERY CSQL ALIAS "_PEDFAT" NEW

	//Grava o Saldo Total de Titulos a serem Compensado
	TOTTITRA := _PEDFAT->SALDO

	_PEDFAT->(dbCloseArea())

	//Saldo RA da LM.
	If cEmpAnt != '07'
		CSQL := QrySldRALM()

		If chkfile("_PEDFAT")
			dbSelectArea("_PEDFAT")
			dbCloseArea()
		EndIf

		TCQUERY CSQL ALIAS "_PEDFAT" NEW

		//Grava o Saldo Total de Titulos a serem Compensado
		TOTTITRALM := _PEDFAT->SALDO
		_PEDFAT->(dbCloseArea())
	EndIf

	// Identifica se a função esta sendo chamada pelo relatorio, caso esteja, não exibe a tela
	If ValType(lReport) == "U" .Or. !lReport

		//TELA REESCRITA PARA FORMATO NOVO POR Fernando/Facile em 27/04/2017
		__nPFT := 300
		If cEmpAnt != '07'
			__nPFT := 330
		EndIf

		DEFINE MSDIALOG oEntra TITLE "Posicao do Cliente" FROM 000, 000  TO __nPFT,920 COLORS 0, 16777215 PIXEL

		@ 002, 005 GROUP oGroup1 TO 050, 450 PROMPT "Cliente" OF oEntra COLOR 8421504, 16777215 PIXEL

		If cEmpAnt != '07'
			@ 055, 005 GROUP oGroup1 TO 145, 450 PROMPT "Cálculo do Limite" OF oEntra COLOR 8421504, 16777215 PIXEL
		Else
			@ 055, 005 GROUP oGroup1 TO 125, 450 PROMPT "Cálculo do Limite" OF oEntra COLOR 8421504, 16777215 PIXEL
		EndIf

		nLin := 10

		If Alltrim(SA1->A1_GRPVEN) <> "" .AND. SA1->A1_YTIPOLC == "G"
			@ nLin, 010 SAY oSay PROMPT "Grupo" SIZE 030, 015 OF oEntra PIXEL
			@ nLin,070 SAY oSay PROMPT ": "+ Alltrim(SA1->A1_GRPVEN)+" - "+Alltrim(Posicione("ACY",1,xFilial("ACY")+SA1->A1_GRPVEN,"ACY_DESCRI")) OF oEntra PIXEL
			@ nLin+7,010 SAY oSay PROMPT "Cliente" OF oEntra PIXEL
			@ nLin+7,070 SAY oSay PROMPT ": "+ SA1->A1_COD+" - "+wA1_NOME OF oEntra PIXEL
		Else
			@ nLin, 010 SAY oSay PROMPT "Cliente" SIZE 030, 015 OF oEntra PIXEL
			@ nLin,070 SAY oSay PROMPT ": " +SA1->A1_COD+" - "+ wA1_NOME OF oEntra PIXEL
		End

		nLin += 15
		@ nLin,010 SAY oSay PROMPT "Risco" OF oEntra PIXEL
		@ nLin,070 SAY oSay PROMPT ": "+ SA1->A1_RISCO OF oEntra PIXEL

		nLin += 15
		@ nLin,010 SAY oSay PROMPT "Vencto Limite" OF oEntra PIXEL
		@ nLin,070 SAY oSay PROMPT ": "+ DTOC(wA1_VENCLC) OF oEntra PIXEL

		nLin += 25
		@ nLin,010 SAY oSay PROMPT "Limite: " OF oEntra PIXEL
		@ nLin,105 SAY oSay PROMPT Transform(wA1_LC,"@E 999,999,999.99") OF oEntra PIXEL

		@ nLin,158 SAY oSay PROMPT "Valor Total de RA: " OF oEntra PIXEL
		@ nLin,280 SAY oSay PROMPT Transform(TOTAL_RA,"@E 999,999,999.99") OF oEntra PIXEL

		@ nLin,320 SAY oSay PROMPT "Liberação PV " OF oEntra PIXEL

		If cEmpAnt != '07'
			nLin += 10
			@ nLin,158 SAY oSay PROMPT "Valor Total de RA (LM): " OF oEntra PIXEL
			@ nLin,280 SAY oSay PROMPT Transform(TOTAL_RALM,"@E 999,999,999.99") OF oEntra PIXEL
		EndIf

		nLin += 15
		@ nLin,010 SAY oSay PROMPT "Titulos em Aberto Consolidaddos: " OF oEntra PIXEL
		@ nLin,105 SAY oSay PROMPT Transform(wA1_SALDUP,"@E 999,999,999.99") OF oEntra PIXEL

		@ nLin,158 SAY oSay PROMPT "Titulos em aberto de RA: " OF oEntra PIXEL
		@ nLin,280 SAY oSay PROMPT Transform(TOTTITRA,"@E 999,999,999.99") OF oEntra PIXEL

		@ nLin,320 SAY oSay PROMPT "Titulos em aberto: "  OF oEntra PIXEL
		@ nLin,420 SAY oSay PROMPT Transform(SALDO_LIB,"@E 999,999,999.99") OF oEntra PIXEL

		If cEmpAnt != '07'
			nLin += 010
			@ nLin,158 SAY oSay PROMPT "Titulos em aberto de RA (LM): " OF oEntra PIXEL
			@ nLin,280 SAY oSay PROMPT Transform(TOTTITRALM,"@E 999,999,999.99") OF oEntra PIXEL
		EndIF

		nLin += 015
		@ nLin,010 SAY oSay PROMPT "Pedidos Pendentes Consolidados: " OF oEntra PIXEL
		@ nLin,105 SAY oSay PROMPT Transform(wTotPed,"@E 999,999,999.99") OF oEntra PIXEL

		@ nLin,158 SAY oSay PROMPT "Pedidos Pendentes RA: " OF oEntra PIXEL
		@ nLin,280 SAY oSay PROMPT Transform(TOTPEDRA,"@E 999,999,999.99") OF oEntra PIXEL

		//TOTPED_LIB
		@ nLin,320 SAY oSay PROMPT "Pedidos Pendentes: " OF oEntra PIXEL
		@ nLin,420 SAY oSay PROMPT Transform(TOTPED_LIB,"@E 999,999,999.99") OF oEntra PIXEL

		nLin += 015
		@ nLin,010 SAY oSay PROMPT "Saldo Disponivel: " OF oEntra PIXEL
		@ nLin,105 SAY oSay PROMPT Transform(wSalDisp,"@E 999,999,999.99") OF oEntra PIXEL

		@ nLin,158 SAY oSay PROMPT "Saldo Disponivel de RA: " OF oEntra PIXEL
		@ nLin,280 SAY oSay PROMPT Transform((TOTAL_RA)-(TOTTITRA+TOTPEDRA),"@E 999,999,999.99") OF oEntra PIXEL

		@ nLin,320 SAY oSay PROMPT "Total Liberado: " OF oEntra PIXEL
		@ nLin,420 SAY oSay PROMPT Transform((TOTPED_LIB+SALDO_LIB),"@E 999,999,999.99") OF oEntra PIXEL

		nLin += 020
		@ nLin,420 BmpButton Type 1 Action Close(oEntra)
		Activate MSDIALOG oEntra Centered
		wsFim := .F.

	Else
		nLimCre := wA1_LC
		nPedCar := wTotPed
		nSalDup := wA1_SALDUP
	EndIf

	If cArqSA1 <> ""
		dbSelectArea(cArqSA1)
		dbSetOrder(cIndSA1)
		dbGoTo(cRegSA1)
		RetIndex("SA1")
	EndIf

	DbSelectArea(cArq)
	DbSetOrder(cInd)
	DbGoTo(cReg)

Return lRetSt
//-----------------------------------------------------------------------------------------------------
Static Function ValStatFin()
	Local lRA 		:= U_fValidaRA(wCondPag)
	Local lRet 		:= .T.
	Local cMsgSta 	:= ''
	Local nRsc		:= 0

	If lRA
		cMsgSta +=	"O Cliente deverá efetuar o Pagamento Antecipado para este Pedido!
		MsgBox(cMsgSta,"Atenção","ALERT")
	Else

		If SA1->A1_YBLQDIR == "S"
			//MsgBox("Cliente Bloqueado pela Diretoria - Favor abrir solicitação de Crédito!","Atenção","STOP")
			cMsgSta += "- Cliente Bloqueado pela Diretoria." + Enter
			lRet	:= .F.
		EndIf

		If SA1->A1_RISCO == "E"
			//MsgBox("Cliente Possui Risco E - Favor abrir solicitação de Crédito!","Atenção","STOP")
			cMsgSta += "- Cliente Possui Risco E." + Enter
			lRet 	:= .F.

		Else

			//ALTERAÇÃO CONFORME OS 1910-16 - 10/05/16
			//Executa as verificações abaixo para os RISCOS A,B,C,D

			//**1-Limite Credito Zerado
			If SA1->A1_LC <= 0
				//MsgBox("Cliente Possui Limite Credito Zerado/Negativo - Favor abrir solicitação de Crédito!","Atenção","STOP")
				cMsgSta += "- Cliente Possui Limite Credito Zerado/Negativo." + Enter
				lRet 	:= .F.
			EndIf

			//**2-Data Limite Credito Vencida
			If SA1->A1_VENCLC < DdataBase
				//Msgbox("Cliente com Data do Limite de Crédito Vencida - Favor abrir solicitação de Crédito!","Atenção","STOP")
				cMsgSta += "- Cliente com Data do Limite de Crédito Vencida." + Enter
				lRet 	:= .F.
			EndIf

			//**3-Saldo Limite Credito
			If (SALDO_DUPLI + TOTPED) > SA1->A1_LC
				//MsgBox("Cliente ultrapassou o Limite de Crédito - Favor abrir solicitação de Crédito!","Atenção","STOP")
				cMsgSta += "- Cliente ultrapassou o Limite de Crédito." + Enter
				lRet 	:= .F.
			EndIf

			//**4-Verifica Titulos em Atraso para os Risco B,C,D
			If Alltrim(SA1->A1_RISCO) <> "A"

				//Armazena o Risco do Cliente
				If Alltrim(SA1->A1_RISCO) == "E"
					nRsc := 0
				ElseIf Alltrim(SA1->A1_RISCO) == "A"
					nRsc := 999999
				Else
					nRsc := GetMv("MV_RISCO"+Alltrim(SA1->A1_RISCO))
				EndIf
				//Traz a Query de Títulos Abertos para verificar atraso.
				//CSQL := U_QryTitAtra(SA1->A1_COD,SA1->A1_LOJA, SA1->A1_YTIPOLC, SA1->A1_GRPVEN,cValToChar(nRsc))
				CSQL := U_QryTitAtra(SA1->A1_COD,SA1->A1_LOJA, SA1->A1_YTIPOLC, SA1->A1_GRPVEN, Alltrim(Str(nRsc)) )

				If chkfile("TATR")
					dbSelectArea("TATR")
					dbCloseArea()
				EndIf
				TCQUERY CSQL ALIAS "TATR" NEW
				dbSelectArea("TATR")
				dbGoTop()

				If !TATR->(Eof())
					cMsgSta += "- Cliente Possui Títulos em Atraso." + Enter
					lRet 	:= .F.
				EndIf
				TATR->(dbCloseArea())

			Else
				//**5-Libera pedidos Risco A, com saldo LC e vencimento LC ativo
				lRet 	:= .T.
			EndIf

			If !lRet
				cMsgSta := "O Cliente possui Restrição. Favor abrir solicitação de Crédito!" + Enter + Enter + cMsgSta
				MsgBox(cMsgSta,"Atenção","ALERT")
			EndIf

		EndIf

	EndIf

Return  lRet

//-----------------------------------------------------------------------------------------------------------------------
User Function QryTitAtra(cCliente,cLoja,cTipoCre,cGrupo,cRisco)
	Local cQry 	:= ''
	Local aEmps := {"01","05","07","14"}
	Local nEmp	:= 1
	Local Enter	:= CHR(13)+CHR(10)
	
	//23397 - Pedro/Pablo alinhado com nadine adição do novo TIPO: JP
	
	For nEmp:=1 to Len(aEmps)

		If nEmp != 1
			cQry += " UNION ALL " + Enter
		EndIf
		cQry += " SELECT '"+aEmps[nEmp]+"' EMPRESA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_SALDO, E1_EMISSAO, E1_VENCREA, E1_VENCTO, E1_VALOR, E1_CLIENTE, E1_LOJA  " + Enter
		cQry += " FROM SE1"+aEmps[nEmp]+"0 SE1 WITH (NOLOCK) " + Enter
		cQry += " INNER JOIN SA1"+aEmps[nEmp]+"0 SA1 WITH (NOLOCK) ON SA1.A1_FILIAL = '"+ xFilial('SA1') +"' AND SE1.E1_CLIENTE = SA1.A1_COD AND SE1.E1_LOJA = SA1.A1_LOJA    AND SA1.D_E_L_E_T_ = '' 		" + Enter
		cQry += " WHERE SE1.E1_FILIAL = '"+ xFilial('SE1') +"' 			" + Enter
		cQry += " AND	SE1.E1_TIPO		NOT IN ('NCC','NDC','RA','BOL', 'JP') 		" + Enter
		cQry += " AND   SE1.E1_SALDO 	> 0								" + Enter
		If ALLTRIM(cGrupo) <> "" .AND. AllTrim(cTipoCre) == "G"
			cQry += "	AND	SA1.A1_GRPVEN	= '"+cGrupo+"'	AND SA1.A1_YTIPOLC = 'G'  	" + Enter
		Else
			cQry += "	AND	SA1.A1_COD = '"+cCliente+"' AND SA1.A1_LOJA = '"+cLoja+"'	" + Enter
		EndIf
		If !Empty(cRisco)
			cQry += "	AND DATEDIFF(D,E1_VENCREA,CONVERT(VARCHAR,GETDATE(),112)) > " +cRisco
		EndIf
		cQry += "	AND SE1.D_E_L_E_T_ = '' 		" + Enter

	Next nEmp

Return cQry

//-----------------------------------------------------------------------------------------------------
User Function QryTitAber(cCliente, cLoja, cTpLc, cGrupo, lFilLibMan)
	Local cQry := ""
	Local aEmps := {"01","05","07","14"}
	Local nEmp	:= 1
	Local Enter	:= CHR(13)+CHR(10)

	cQry += " SELECT SUM(SALDO_TIT) AS  SALDO, LIBMAN
	cQry += " FROM (

	For nEmp:=1 to Len(aEmps)

		If nEmp != 1
			cQry += " UNION ALL " + ENTER
		EndIf

		cQry += " SELECT SUM(E1_SALDO) AS  SALDO_TIT,
		cQry += " 	  (CASE WHEN SZN.ZN_TIPO <> '1' AND SZN.ZN_TIPO IS NOT NULL THEN  'S' ELSE 'N'  END) AS LIBMAN
		cQry += " FROM SE1"+aEmps[nEmp]+"0 SE1 WITH (NOLOCK)	" + Enter
		cQry += " INNER JOIN SA1"+aEmps[nEmp]+"0 SA1 WITH (NOLOCK) ON SA1.A1_FILIAL = '"+ xFilial('SA1') +"' AND SE1.E1_CLIENTE = SA1.A1_COD AND SE1.E1_LOJA = SA1.A1_LOJA    AND SA1.D_E_L_E_T_ = '' 		" + Enter
		cQry += " LEFT  JOIN SZN"+aEmps[nEmp]+"0 SZN WITH (NOLOCK) ON SZN.ZN_FILIAL = '"+ xFilial('SZN') +"' AND SZN.ZN_PEDIDO = SE1.E1_PEDIDO AND SZN.D_E_L_E_T_ = ''	" + Enter
		If aEmps[nEmp] == "07" 
			cQry += " WHERE SE1.E1_FILIAL IN ('01','05') " + Enter
		Else
			cQry += " WHERE SE1.E1_FILIAL = '01'         " + Enter		
		EndIf
		cQry += " AND 	SE1.E1_TIPO		NOT IN ('NCC','NDC','RA','BOL') AND		" + Enter
		cQry += "  		SE1.E1_SALDO 	> 0					AND				" + Enter
		
		cQry += "  (															" + Enter
		cQry += "  SE1.E1_TIPO 	NOT IN ('NF','ST')								" + Enter
		cQry += "  OR															" + Enter
		cQry += "  	(															" + Enter
        cQry += " 		SE1.E1_TIPO     IN ('NF','ST')    						" + Enter
        cQry += " 		AND EXISTS (											" + Enter
        cQry += "     	SELECT NULL FROM SF2"+aEmps[nEmp]+"0 F2 WITH (NOLOCK)	" + Enter
        cQry += "             INNER JOIN SE4010 E4 WITH (NOLOCK) ON				" + Enter
        cQry += "             F2_COND                = E4_CODIGO				" + Enter
        cQry += "             AND E4.D_E_L_E_T_    = ''							" + Enter
        cQry += "             WHERE												" + Enter
        If aEmps[nEmp] == "07" 
        	cQry += "             F2_FILIAL IN ('01','05')           	" + Enter
        Else
        	cQry += "             F2_FILIAL = '01' 						" + Enter        
        EndIf
        cQry += "             AND F2.F2_CLIENTE    = SE1.E1_CLIENTE				" + Enter
        cQry += "             AND F2.F2_LOJA       = SE1.E1_LOJA				" + Enter
        cQry += "             AND F2.F2_DOC        = SE1.E1_NUM					" + Enter
        cQry += "             AND F2.F2_SERIE      = SE1.E1_PREFIXO				" + Enter
        cQry += "             AND F2.D_E_L_E_T_    = ''							" + Enter
        cQry += "             AND E4_DESCRI        NOT LIKE '%ANTE%'			" + Enter	
        cQry += "      )														" + Enter
        cQry += "  	)															" + Enter
        cQry += "  )															" + Enter
        
		//cQry += "  		(SE1.E1_TIPO 	IN ('NF','ST') AND RTRIM(SE1.E1_PREFIXO)+RTRIM(SE1.E1_NUM) IN (SELECT RTRIM(F2.F2_SERIE)+RTRIM(F2.F2_DOC) FROM SF2"+aEmps[nEmp]+"0 F2, SE4010 E4 WHERE F2_FILIAL = '01' AND F2_CLIENTE = SE1.E1_CLIENTE AND F2_LOJA = SE1.E1_LOJA AND F2_COND = E4_CODIGO AND E4_DESCRI NOT LIKE '%ANTE%' AND F2.D_E_L_E_T_ = '' AND E4.D_E_L_E_T_ = ''))) " + Enter
		
		cQry += " AND SE1.D_E_L_E_T_ = ''									" + Enter
		If AllTrim(cGrupo) <> "" .AND. AllTrim(cTpLc) == "G"
			cQry += "	AND	SA1.A1_GRPVEN	= '"+SA1->A1_GRPVEN+"'	AND SA1.A1_YTIPOLC = 'G'  	" + Enter
		Else
			cQry += "	AND	SA1.A1_COD = '"+cCliente+"' AND SA1.A1_LOJA = '"+cLoja+"'	 		" + Enter
		EndIf
		cQry += " GROUP BY SZN.ZN_TIPO " + Enter

	Next nEmp

	cQry += " ) TMP

	If lFilLibMan
		cQry += " WHERE LIBMAN = 'N' 	" + Enter
	EndIf
	cQry += " GROUP BY LIBMAN			" + Enter

Return cQry
//-----------------------------------------------------------------------------------------------------
User Function QryPedCons(cCliente, cLoja, cTpLc, cGrupo, cPedido, lFilLibMan, lReport, cCodVen)
	Local cQry 	:= ""
	Local aEmps := {"01","05","07","14"}
	Local nEmp	:= 1
	Local ENTER	:= CHR(13)+CHR(10)

	cQry += " SELECT SUM(SALDO) AS SALDO, LIBMAN " + ENTER
	cQry += " FROM (							 " + ENTER

	For nEmp:=1 to Len(aEmps)

		If nEmp != 1
			cQry += " UNION ALL " + ENTER
		EndIf

		cQry += " SELECT ISNULL(SUM(ROUND((ROUND(C6_VALOR-(C6_QTDENT*C6_PRCVEN),2)/C6_VALOR*100)*C6_YVLIMP/100,2)),0) SALDO, " + ENTER
		cQry += " (CASE WHEN SZN.ZN_TIPO <> '1' AND SZN.ZN_TIPO IS NOT NULL THEN 'S'ELSE 'N' END) AS LIBMAN					 " + ENTER
		cQry += " FROM SC5"+aEmps[nEmp]+"0 SC5		  WITH (NOLOCK) 														 " + ENTER
		cQry += " INNER JOIN SC6"+aEmps[nEmp]+"0 SC6 WITH (NOLOCK)	ON	SC6.C6_FILIAL	= SC5.C5_FILIAL						 " + ENTER
		cQry += " 									AND SC5.C5_NUM		= SC6.C6_NUM 										 " + ENTER
		cQry += " 									AND SC5.C5_CLIENTE	= SC6.C6_CLI										 " + ENTER
		cQry += " 									AND SC5.C5_LOJACLI	= SC6.C6_LOJA 										 " + ENTER
		cQry += " 									AND SC6.D_E_L_E_T_  = ''												 " + ENTER
		cQry += " INNER JOIN SF4"+aEmps[nEmp]+"0 SF4 WITH (NOLOCK) ON	SC6.C6_FILIAL	= SF4.F4_FILIAL						 " + ENTER
		cQry += " 									AND SC6.C6_TES		= SF4.F4_CODIGO										 " + ENTER
		cQry += " 									AND SF4.D_E_L_E_T_	= ''												 " + ENTER
		cQry += " INNER JOIN SE4010 SE4 WITH (NOLOCK) ON	SE4.E4_FILIAL	= '' 						" + ENTER
		cQry += " 									AND SC5.C5_CONDPAG  = SE4.E4_CODIGO 				" + ENTER
		cQry += " 									AND SE4.D_E_L_E_T_	= ''							" + ENTER
		cQry += " INNER JOIN SA1"+aEmps[nEmp]+"0 SA1 WITH (NOLOCK) ON	SA1.A1_FILIAL	= ''			" + ENTER
		cQry += " 									AND SC5.C5_CLIENTE	= SA1.A1_COD					" + ENTER
		cQry += " 									AND	SC5.C5_LOJACLI	= SA1.A1_LOJA					" + ENTER
		cQry += " 									AND	SA1.D_E_L_E_T_  = ''							" + ENTER
		cQry += " LEFT JOIN SZN"+aEmps[nEmp]+"0 SZN WITH (NOLOCK)	ON	SZN.ZN_FILIAL	= SC5.C5_FILIAL " + ENTER
		cQry += " 									AND SZN.ZN_PEDIDO	= SC5.C5_NUM					" + ENTER
		cQry += " 									AND SZN.D_E_L_E_T_ = ''								" + ENTER
		//cQry += " WHERE	SC5.C5_FILIAL	= '01' 			" + ENTER
		cQry += " WHERE	SC5.C5_FILIAL	IN (SELECT FILIAL FROM FNC_FILIAL('"+aEmps[nEmp]+"')) 			" + ENTER
		cQry += " AND 	SC5.C5_TIPO		= 'N'			" + ENTER
		cQry += " AND	SC6.C6_QTDVEN-C6_QTDENT > 0 	" + ENTER
		cQry += " AND  	SC6.C6_VALOR    > 0         	" + ENTER
		cQry += " AND  	SC6.C6_BLQ		<>	'R' 		" + ENTER
		cQry += " AND  	SF4.F4_DUPLIC	=	'S' 		" + ENTER
		cQry += " AND  	SE4.E4_DESCRI NOT LIKE '%ANTE%' " + ENTER
		If AllTrim(cGrupo) <> "" .AND. AllTrim(cTpLc) == "G"
			cQry += " AND	SA1.A1_GRPVEN = '"+SA1->A1_GRPVEN+"' AND SA1.A1_YTIPOLC = 'G'	" + ENTER
		Else
			cQry += " AND	SA1.A1_COD = '"+cCliente+"' AND SA1.A1_LOJA = '"+cLoja+"' 		" + ENTER
		EndIf

		// Identifica se a função esta sendo chamada pelo relatorio, caso esteja, filtra os pedidos por vendedor
		If ValType(lReport) <> "U" .And. lReport
			cQry += " AND	C5_VEND1 = "+ ValToSQL(cCodVen)
		EndIf

		If cempant = aEmps[nEmp] .And. !Empty(cPedido)
			cQry += " AND	    SC5.C5_NUM		<> '"+cPedido+"'	   "	+ Enter //PARA NAO CONSIDERAR O PEDIDO, SE JÁ ESTIVER GRAVADO DEVERA SER INFORMADO
		EndIf
		cQry += " AND 	SC5.D_E_L_E_T_	= '' 	" + ENTER
		cQry += " GROUP BY SZN.ZN_TIPO 			" + ENTER
	Next nEmp
	cQry += " ) TMP								" + ENTER
	If lFilLibMan
		cQry += " WHERE LIBMAN = 'N'			" + ENTER
	EndIf
	cQry += " GROUP BY LIBMAN					" + ENTER

Return cQry
//-----------------------------------------------------------------------------------------------------
Static Function QrySldRALM()
	Local cQry := ""

	cQry += "SELECT ISNULL(SUM(E1_SALDO),0) SALDO	" + Enter
	cQry += "FROM SE1070 SE1 WITH (NOLOCK), SF2070 SF2 WITH (NOLOCK), SE4010 SE4 WITH (NOLOCK), SA1070 SA1  " + Enter
	cQry += " WHERE	SE1.E1_FILIAL	= '"+xFilial("SE1")+"'	AND " + Enter
	cQry += "		SE1.E1_CLIENTE	= SA1.A1_COD			AND	" + Enter
	cQry += " 		SE1.E1_LOJA		= SA1.A1_LOJA			AND	" + Enter
	IF ALLTRIM(SA1->A1_GRPVEN) <> "" .AND. SA1->A1_YTIPOLC == "G"
		cQry += "		SA1.A1_GRPVEN	= '"+SA1->A1_GRPVEN+"'	AND SA1.A1_YTIPOLC = 'G' AND " + ENTER
	ELSE
		cQry += "		SA1.A1_COD = '"+wsCli+"' AND SA1.A1_LOJA = '"+wsLoja+"'	AND " + ENTER
	END IF
	cQry += "		SE1.E1_SALDO	> 0 				AND	" + Enter
	cQry += "		SF2.F2_SERIE    = SE1.E1_PREFIXO	AND	" + Enter
	cQry += "		SF2.F2_DOC		= SE1.E1_NUM		AND " + Enter
	cQry += "		SF2.F2_CLIENTE	= SE1.E1_CLIENTE	AND " + Enter
	cQry += "		SF2.F2_LOJA		= SE1.E1_LOJA		AND " + Enter
	cQry += "		SF2.F2_COND 	= E4_CODIGO 		AND " + Enter
	cQry += "		SF2.F2_TIPO		= 'N'				AND " + Enter
	cQry += "       SE4.E4_DESCRI	LIKE '%ANTE%'		AND " + Enter
	cQry += "		SE1.D_E_L_E_T_	= '' AND	" + Enter
	cQry += "      	SF2.D_E_L_E_T_	= '' AND	" + Enter
	cQry += "      	SE4.D_E_L_E_T_	= '' AND	" + Enter
	cQry += "		SA1.D_E_L_E_T_	= ''		" + Enter

Return cQry

//-----------------------------------------------------------------------------------------------------
Static Function QrySldRAEM()
	Local cQry := ""

	cQry += "SELECT ISNULL(SUM(E1_SALDO),0) SALDO	" + Enter
	cQry += "FROM "+RETSQLNAME("SE1")+" SE1 WITH (NOLOCK), "+RETSQLNAME("SF2")+" SF2, "+RETSQLNAME("SE4")+" SE4 WITH (NOLOCK), "+RETSQLNAME("SA1")+" SA1  " + Enter
	cQry += " WHERE	SE1.E1_FILIAL	= '"+xFilial("SE1")+"'	AND " + Enter
	cQry += "		SE1.E1_CLIENTE	= SA1.A1_COD			AND	" + Enter
	cQry += " 		SE1.E1_LOJA		= SA1.A1_LOJA			AND	" + Enter
	IF ALLTRIM(SA1->A1_GRPVEN) <> "" .AND. SA1->A1_YTIPOLC == "G"
		cQry += "		SA1.A1_GRPVEN	= '"+SA1->A1_GRPVEN+"'	AND SA1.A1_YTIPOLC = 'G' AND " + ENTER
	ELSE
		cQry += "		SA1.A1_COD = '"+wsCli+"' AND SA1.A1_LOJA = '"+wsLoja+"'	AND " + ENTER
	END IF
	cQry += "		SE1.E1_SALDO	> 0 				AND	" + Enter
	cQry += "		SF2.F2_SERIE    = SE1.E1_PREFIXO	AND	" + Enter
	cQry += "		SF2.F2_DOC		= SE1.E1_NUM		AND " + Enter
	cQry += "		SF2.F2_CLIENTE	= SE1.E1_CLIENTE	AND " + Enter
	cQry += "		SF2.F2_LOJA		= SE1.E1_LOJA		AND " + Enter
	cQry += "		SF2.F2_COND 	= E4_CODIGO 		AND " + Enter
	cQry += "		SF2.F2_TIPO		= 'N'				AND " + Enter
	cQry += "       SE4.E4_DESCRI	LIKE '%ANTE%'		AND " + Enter
	cQry += "		SE1.D_E_L_E_T_	= '' AND	" + Enter
	cQry += "      	SF2.D_E_L_E_T_	= '' AND	" + Enter
	cQry += "      	SE4.D_E_L_E_T_	= '' AND	" + Enter
	cQry += "		SA1.D_E_L_E_T_	= ''		" + Enter

Return cQry

//-----------------------------------------------------------------------------------------------------
Static Function QryTotRAEM()
	Local cQry := ""

	cQry += "SELECT ISNULL(SUM(E1_SALDO),0) AS TOTAL " + Enter
	cQry += "FROM "+RETSQLNAME("SE1")+" SE1 WITH (NOLOCK), "+RETSQLNAME("SA1")+" SA1  " + Enter
	cQry += " WHERE	SE1.E1_FILIAL	= '"+xFilial("SE1")+"'	AND " + Enter
	cQry += "		SE1.E1_CLIENTE	= SA1.A1_COD			AND	" + Enter
	cQry += " 		SE1.E1_LOJA		= SA1.A1_LOJA			AND	" + Enter
	IF ALLTRIM(SA1->A1_GRPVEN) <> "" .AND. SA1->A1_YTIPOLC == "G"
		cQry += "		SA1.A1_GRPVEN	= '"+SA1->A1_GRPVEN+"'	AND SA1.A1_YTIPOLC = 'G' AND " + ENTER
	ELSE
		cQry += "		SA1.A1_COD = '"+wsCli+"' AND SA1.A1_LOJA = '"+wsLoja+"'	AND " + ENTER
	END IF
	cQry += "		SE1.E1_TIPO		= 'RA' AND  " + Enter
	cQry += "		SE1.E1_SALDO	> 0 AND  " + Enter
	cQry += "		SE1.D_E_L_E_T_	= '' AND  " + Enter
	cQry += "		SA1.D_E_L_E_T_	= ''  " + Enter

Return cQry

//-----------------------------------------------------------------------------------------------------
Static Function QryTotRALM()
	Local cQry := ""

	cQry += "SELECT ISNULL(SUM(E1_SALDO),0) AS TOTAL " + Enter
	cQry += "FROM SE1070 SE1 WITH (NOLOCK), SA1070 SA1  " + Enter
	cQry += " WHERE	SE1.E1_FILIAL	= '"+xFilial("SE1")+"'	AND " + Enter
	cQry += "		SE1.E1_CLIENTE	= SA1.A1_COD			AND	" + Enter
	cQry += " 		SE1.E1_LOJA		= SA1.A1_LOJA			AND	" + Enter
	IF ALLTRIM(SA1->A1_GRPVEN) <> "" .AND. SA1->A1_YTIPOLC == "G"
		cQry += "		SA1.A1_GRPVEN	= '"+SA1->A1_GRPVEN+"'	AND SA1.A1_YTIPOLC = 'G' AND " + ENTER
	ELSE
		cQry += "		SA1.A1_COD = '"+wsCli+"' AND SA1.A1_LOJA = '"+wsLoja+"'	AND " + ENTER
	END IF
	cQry += "		SE1.E1_TIPO		= 'RA' AND  " + Enter
	cQry += "		SE1.E1_SALDO	> 0 AND  " + Enter
	cQry += "		SE1.D_E_L_E_T_	= '' AND  " + Enter
	cQry += "		SA1.D_E_L_E_T_	= ''  " + Enter

Return cQry
//-----------------------------------------------------------------------------------------------------

/*/
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡„o    ³ACOL45    | Autor ³ BRUNO MADALENO        ³ Data ³ 04/01/07  ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³          ³MONTA O ACOLS45 PARA SER CALCULADO OS VALORES DOS IMPOSTOS   ³±±
	±±³          ³                                                             ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ NUMERO PEDIDO E A EMPRESA EM QUE ESTA O PEDIDO              ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Uso       ³ personalizacao                                              ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
USER FUNCTION ACOL45(CPEDI,EMP)
	Local cArq   := ""
	Local cInd 	 := 0
	Local cReg	 := 0

	Local cArqSC6	:= ""
	Local cIndSC6	:= 0
	Local cRegSC6	:= 0
	Local nCntFor

	PUBLIC ACOLS45	  := {}

	cArq := Alias()
	cInd := IndexOrd()
	cReg := Recno()

	DbSelectArea("SC6")
	cArqSC6 := Alias()
	cIndSC6 := IndexOrd()
	cRegSC6 := Recno()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem do ACOLS45                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ACOLS45	  := {}
	dbSelectArea("SC6")
	dbSetOrder(1)
	#IFDEF TOP
		//If Ascan(aHeader45,{|x| x[8] == "M"}) == 0
		aStruSC6:= SC6->(dbStruct())
		cArqQry := "SC6"
		lQuery  := .T.
		cQuery := "SELECT * "
		If EMP == "01"
			cQuery += "FROM SC6010 SC6 "
		ELSEIF EMP == "05"
			cQuery += "FROM SC6050 SC6 "
		ELSEIF EMP == "07"
			cQuery += "FROM SC6070 SC6 "
		ELSE
			cQuery += "FROM SC6"+EMP+"0 SC6 "
		END IF
		cQuery += "WHERE SC6.C6_NUM='"+CPEDI+"' AND "
		//	cQuery += "SC6.C6_QTDVEN-SC6.C6_QTDENT > 0 AND C6_BLQ <> 'R' AND "
		cQuery += "SC6.D_E_L_E_T_= '' "
		cQuery += "ORDER BY "+SqlOrder(SC6->(IndexKey()))

		cQuery := ChangeQuery(cQuery)

		dbSelectArea("SC6")
		dbCloseArea()
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cArqQry,.T.,.T.)
		For nCntFor := 1 To Len(aStruSC6)
			If ( aStruSC6[nCntFor,2]<>"C" )
				TcSetField(cArqQry,aStruSC6[nCntFor,1],aStruSC6[nCntFor,2],aStruSC6[nCntFor,3],aStruSC6[nCntFor,4])
			EndIf
		Next nCntFor
		//Else
	#ENDIF
	//cArqQry := "SC6"
	//MsSeek(xFilial("SC6")+CPEDI)
	#IFDEF TOP
		//EndIf
	#ENDIF
	While ( !Eof() .And. (cArqQry)->C6_FILIAL == xFilial("SC6") .And.;
			(cArqQry)->C6_NUM 	== CPEDI )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se este item foi digitada atraves de uma    ³
		//³ grade, se for junta todos os itens da grade em uma   ³
		//³ referencia , abrindo os itens so quando teclar enter ³
		//³ na quantidade                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( (cArqQry)->C6_GRADE == "S" .And. lGrade )
			a410Grade(.F.,,cArqQry,.T.)
		Else
			AADD(ACOLS45,Array(Len(aHeader45)))
			For nCntFor:=1 To Len(aHeader45)
				If ( aHeader45[nCntFor,10] <>  "V" .And. AllTrim(aHeader45[nCntFor,2]) <> "C6_QTDLIB" )
					ACOLS45[Len(ACOLS45)][nCntFor] := FieldGet(FieldPos(aHeader45[nCntFor,2]))
				Else
					ACOLS45[Len(ACOLS45)][nCntFor] := CriaVar(aHeader45[nCntFor,2])
				EndIf
			Next nCntFor
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Mesmo nao sendo um item digitado atraves de grade e' necessa-³
			//³ rio criar o Array referente a este item para controle da     ³
			//³ grade                                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//MatGrdMont(Len(ACOLS45))
		EndIf
		dbSelectArea(cArqQry)
		dbSkip()
	EndDo

	SC6->(DBCLOSEAREA())

	If cArqSC6 <> ""
		dbSelectArea(cArqSC6)
		dbSetOrder(cIndSC6)
		dbGoTo(cRegSC6)
		RetIndex("SC6")
	EndIf

	DbSelectArea(cArq)
	DbSetOrder(cInd)
	DbGoTo(cReg)

RETURN

/*/
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡„o    ³CriaHeader³ Autor ³ BRUNO MADALENO        ³ Data ³ 04/01/07  ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³          ³   SERVE PARA MONTAR O AHEADER PARA SER UTILIZADO NA ROTINAS ³±±
	±±³          ³  DE ACOLS                                                   ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ _ALIAS  ----  NOME DA TABELA A SER MONTADO O Header         ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Uso       ³ personalizacao                                              ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
USER Function CriaHeader(_ALIAS)

	PUBLIC aHeader :={}

	dbSelectArea("SX3")
	dbSetOrder(1)
	dbGotop()
	dbSeek(_ALIAS)

	While !Eof() .And. SX3->X3_Arquivo == _ALIAS
		aAdd(aHeader,{Trim(SX3->X3_Titulo),;
			SX3->X3_Campo,;
			SX3->X3_Picture,;
			SX3->X3_Tamanho,;
			SX3->X3_Decimal,;
			SX3->X3_Valid,;
			SX3->X3_Usado,;
			SX3->X3_Tipo,;
			SX3->X3_Arquivo,;
			SX3->X3_Context})
		dbSkip()
	end

Return

/*/
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡„o    ³CriaHeader³ Autor ³ BRUNO MADALENO        ³ Data ³ 04/01/07  ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³          ³   SERVE PARA MONTAR O AHEADER PARA SER UTILIZADO NA ROTINAS ³±±
	±±³          ³  DE ACOLS45                                                 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ _ALIAS  ----  NOME DA TABELA A SER MONTADO O Header         ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Uso       ³ personalizacao                                              ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
USER Function 45CriaHeader(_ALIAS)

	PUBLIC aHeader45 :={}
	//aCpoEnchoise :={}
	//aAltEnchoise :={}

	dbSelectArea("SX3")
	dbSetOrder(1)
	dbGotop()
	dbSeek(_ALIAS)

	While !Eof() .And. SX3->X3_Arquivo == _ALIAS
		aAdd(aHeader45,{Trim(SX3->X3_Titulo),;
			SX3->X3_Campo,;
			SX3->X3_Picture,;
			SX3->X3_Tamanho,;
			SX3->X3_Decimal,;
			SX3->X3_Valid,;
			SX3->X3_Usado,;
			SX3->X3_Tipo,;
			SX3->X3_Arquivo,;
			SX3->X3_Context})
		dbSkip()
	end

Return

USER FUNCTION VALI_RE(cCAMPO,lMENSA)
	DO CASE
	CASE cCAMPO = "EE9_RE"
		If !Empty(M->EE9_RE)
			If Len(AllTrim(M->EE9_RE)) < 12 .or. Val(Right(AllTrim(M->EE9_RE), 3)) = 0
				lRet := .F.
			EndIf
		EndIf
	EndCase

RETURN(lRET)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOG_USO   ºAutor  ³ MADALENO           º Data ³  20/04/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ LOG DE USO DE TODAS AS FUNÇÕES E PONTOS DE ENTRADA DO 	  º±±
±±º          ³ PROJETO BIANCOGRES                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ sFuncao: nome da Funcao                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function LOG_USO(sFuncao)

	Private cEOL    	:= "CHR(13)+CHR(10)"
	Private nARQUIVO 	:= ""
	Private cArqTxt		:= "C:\MPOINT_S\MOVIMENT.TXT"
	Private nLINHA 		:= ""
	PRIVATE nTamFile, nTamLin, cBuffer, nBtLidos, nHdl

	cArqTxt		:= "\P10\LOG_USO\" + sFuncao + ".TXT"
	If Empty(cEOL)
		cEOL := CHR(13)+CHR(10)
	Else
		cEOL := Trim(cEOL)
		cEOL := &cEOL
	Endif

	If FILE(cArqTxt) // relendo o arquivo de ponto.
		nHdl    := fOpen(cArqTxt,68)
		nTamFile := fSeek(nHdl,0,2)
		fSeek(nHdl,0,0)
		nTamLin  := 45+Len(cEOL)
		cBuffer  := Space(nTamLin)

		nBtLidos := fRead(nHdl,@cBuffer,nTamLin)

		While nBtLidos >= nTamLin
			nLINHA += cBuffer
			nBtLidos := fRead(nHdl,@cBuffer,nTamLin) // Leitura da proxima linha do arquivo texto
		EndDo
		FCLOSE(nHdl)

		nARQUIVO    := fCreate(cArqTxt)
		fWrite(nARQUIVO,nLINHA)
	else
		nARQUIVO    := fCreate(cArqTxt)
	end if

	nLINHA := PADR(alltrim(upper(cUserName)),20)
	nLINHA += PADR(DTOC(DDATABASE),15)
	nLINHA += PADR(sFuncao,10)
	fWrite(nARQUIVO,nLINHA+cEOL)

	fClose(nARQUIVO)

RETURN

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³VLTOTPED  ³ Autor ³ Ranisses A. Corona    ³ Data ³ 13/08/08  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³VL_IMPOS: CALCULA O VALOR DA NOTA FISCAL COM OS IMPOSTO      ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nOpc    ----  1                                             ³±±
±±³          ³ PEDI    ----  NUMERO DO PEDIDO                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ VALOR TOTAL DA NOTA FISCAL COM OS IMPOSTOS CALCULADOS       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta funcao efetua os calculos de impostos (ICMS,IPI,ISS,etc)³±±
±±³          ³com base nas funcoes fiscais, a fim de possibilitar ao usua- ³±±
±±³          ³rio obter o valor da nota fiscal sem existir a mesma         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ personalizacao                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function VLTOTPED(PEDI,lSaldo)
	Local aArea		:= GetArea()
	Local aAreaSA1	:= SA1->(GetArea())
	Local aFisGet	:= {}
	Local aFisGetSC5:= {}
	Local aDupl     := {}
	Local aVencto   := {}
*	Local aFlHead   := { STR0046,STR0047,STR0063 } //"Vencimento"###"Valor"
*	Local aEntr     := {}
*	Local aDuplTmp  := {}
	Local aRentab   := {}
	Local nPLocal   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_LOCAL"})
	Local nPTotal   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALOR"})
	Local nPValDesc := aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALDESC"})
	Local nPPrUnit  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRUNIT"})
	Local nPPrcVen  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRCVEN"})
	Local nPQtdVen  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})
	Local nPDtEntr  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_ENTREG"})
	Local nPProduto := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
	Local nPTES     := aScan(aHeader,{|x| AllTrim(x[2])=="C6_TES"})
	Local nPNfOri   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_NFORI"})
	Local nPSerOri  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_SERIORI"})
	Local nPItemOri := aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEMORI"})
	Local nPIdentB6 := aScan(aHeader,{|x| AllTrim(x[2])=="C6_IDENTB6"})
	Local nPItem    := aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEM"})
	Local nPSuframa := 0
	Local nUsado    := Len(aHeader)
	Local nX        := 0
	Local nAcerto   := 0
	Local nPrcLista := 0
	Local nValMerc  := 0
	Local nDesconto := 0
	Local nAcresFin := 0
	Local nQtdPeso  := 0
	Local nRecOri   := 0
	Local nPosEntr  := 0
	Local nItem     := 0
	Local nY        := 0
	Local nPosCpo   := 0
	Local lDtEmi    := SuperGetMv("MV_DPDTEMI",.F.,.T.)
	Local dDataCnd  := M->C5_EMISSAO
	Local oDlg
	Local oDupl
	Local oFolder
	Local oRentab
	Local lCondVenda := .F. // Template GEM
	Local aRentabil := {}
	Local cProduto  := ""
	Local nTotDesc  := 0
	Local lSaldo    := lSaldo .And.  !INCLUI //.F. //MV_PAR04 == 1 .And. !INCLUI
	Local nQtdEnt   := 0
	Local lM410Ipi	:= ExistBlock("M410IPI")
	Local lM410Icm	:= ExistBlock("M410ICM")
	Local lM410Soli	:= ExistBlock("M410SOLI")
	Local aSolid	:= {}

	Public lAtuImp	:= Iif(lSaldo,.F.,.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Busca referencias no SC6                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aFisGet	:= {}
	dbSelectArea("SX3")
	dbSetOrder(1)
	MsSeek("SC6")
	While !Eof().And.X3_ARQUIVO=="SC6"
		cValid := UPPER(X3_VALID+X3_VLDUSER)
		If 'MAFISGET("'$cValid
			nPosIni 	:= AT('MAFISGET("',cValid)+10
			nLen		:= AT('")',Substr(cValid,nPosIni,Len(cValid)-nPosIni))-1
			cReferencia := Substr(cValid,nPosIni,nLen)
			aAdd(aFisGet,{cReferencia,X3_CAMPO,MaFisOrdem(cReferencia)})
		EndIf
		If 'MAFISREF("'$cValid
			nPosIni		:= AT('MAFISREF("',cValid) + 10
			cReferencia	:=Substr(cValid,nPosIni,AT('","MT410",',cValid)-nPosIni)
			aAdd(aFisGet,{cReferencia,X3_CAMPO,MaFisOrdem(cReferencia)})
		EndIf
		dbSkip()
	EndDo
	aSort(aFisGet,,,{|x,y| x[3]<y[3]})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Busca referencias no SC5                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aFisGetSC5	:= {}
	dbSelectArea("SX3")
	dbSetOrder(1)
	MsSeek("SC5")
	While !Eof().And.X3_ARQUIVO=="SC5"
		cValid := UPPER(X3_VALID+X3_VLDUSER)
		If 'MAFISGET("'$cValid
			nPosIni 	:= AT('MAFISGET("',cValid)+10
			nLen		:= AT('")',Substr(cValid,nPosIni,Len(cValid)-nPosIni))-1
			cReferencia := Substr(cValid,nPosIni,nLen)
			aAdd(aFisGetSC5,{cReferencia,X3_CAMPO,MaFisOrdem(cReferencia)})
		EndIf
		If 'MAFISREF("'$cValid
			nPosIni		:= AT('MAFISREF("',cValid) + 10
			cReferencia	:=Substr(cValid,nPosIni,AT('","MT410",',cValid)-nPosIni)
			aAdd(aFisGetSC5,{cReferencia,X3_CAMPO,MaFisOrdem(cReferencia)})
		EndIf
		dbSkip()
	EndDo
	aSort(aFisGetSC5,,,{|x,y| x[3]<y[3]})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicializa a funcao fiscal                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MaFisSave()
	MaFisEnd()
	MaFisIni(Iif(Empty(M->C5_CLIENT),M->C5_CLIENTE,M->C5_CLIENT),;// 1-Codigo Cliente/Fornecedor
	M->C5_LOJAENT,;		// 2-Loja do Cliente/Fornecedor
	IIf(M->C5_TIPO$'DB',"F","C"),;				// 3-C:Cliente , F:Fornecedor
	M->C5_TIPO,;				// 4-Tipo da NF
	M->C5_TIPOCLI,;		// 5-Tipo do Cliente/Fornecedor
	Nil,;
	Nil,;
	Nil,;
	Nil,;
	"MATA461")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Realiza alteracoes de referencias do SC5         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aFisGetSC5) > 0
		dbSelectArea("SC5")
		For nY := 1 to Len(aFisGetSC5)
			If !Empty(&("M->"+Alltrim(aFisGetSC5[ny][2])))
				MaFisAlt(aFisGetSC5[ny][1],&("M->"+Alltrim(aFisGetSC5[ny][2])),,.F.)
			EndIf
		Next nY
	Endif

	//Na argentina o calculo de impostos depende da serie.
	If cPaisLoc == 'ARG'
		SA1->(DbSetOrder(1))
		SA1->(MsSeek(xFilial()+IIf(!Empty(M->C5_CLIENT),M->C5_CLIENT,M->C5_CLIENTE)+M->C5_LOJAENT))
		MaFisAlt('NF_SERIENF',LocXTipSer('SA1',MVNOTAFIS))
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Agrega os itens para a funcao fiscal         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nPTotal > 0 .And. nPValDesc > 0 .And. nPPrUnit > 0 .And. nPProduto > 0 .And. nPQtdVen > 0 .And. nPTes > 0
		For nX := 1 To Len(aCols)
			nQtdPeso := 0
			//If Len(aCols[nX])==nUsado .Or. !aCols[nX][nUsado+1]
			nItem++
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Posiciona Registros                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lSaldo .And. nPItem > 0
				dbSelectArea("SC6")
				dbSetOrder(1)
				MsSeek(xFilial("SC6")+M->C5_NUM+aCols[nX][nPItem]+aCols[nX][nPProduto])
				nQtdEnt := SC6->C6_QTDENT //IIf(!SubStr(SC6->C6_BLQ,1,1)$"RS" .And. Empty(SC6->C6_BLOQUEI),SC6->C6_QTDENT,SC6->C6_QTDVEN)
			Else
				lSaldo := .F.
			EndIf

			cProduto := aCols[nX][nPProduto]
			MatGrdPrRf(@cProduto)
			SB1->(dbSetOrder(1))
			If SB1->(MsSeek(xFilial("SB1")+cProduto))
				sPESEMB := ""
				sPESO	:= ""
				sDIVPA	:= ""
				NPOSLOTE := AScan(aHeader, { |x| Alltrim(x[2]) == 'C6_LOTECTL'})
				IF SM0->M0_CODIGO <> '02'
					aCODPRODUTO := (SB1->B1_YFORMAT+SB1->B1_YFATOR+SB1->B1_YLINHA+SB1->B1_YCLASSE)
				ELSE
					aCODPRODUTO := SB1->B1_COD
				ENDIF
				cSQLL := ""
				cSQLL := "SELECT * FROM ZZ9010 "
				cSQLL += "WHERE	ZZ9_PRODUT = '" +aCODPRODUTO+ "' AND  "
				cSQLL += "		ZZ9_LOTE = '" +ACOLS[n,NPOSLOTE]+ "' AND "
				cSQLL += "		D_E_L_E_T_ = '' "
				IF chkfile("_ZZ9")
					dbSelectArea("_ZZ9")
					dbCloseArea()
				ENDIF
				TCQuery cSQLL Alias "_ZZ9" New
				IF ! _ZZ9->(EOF())
					sPESEMB := _ZZ9->ZZ9_PESEMB
					sPESO	:= _ZZ9->ZZ9_PESO
					sDIVPA	:= _ZZ9->ZZ9_DIVPA
				ELSE
					sPESO	:= SB1->B1_PESO
				END IF
				//nQtdPeso := ACOLS[nX][nPQtdVen]*sPESO
				nQtdPeso := If(lSaldo,aCols[nX][nPQtdVen]-nQtdEnt,aCols[nX][nPQtdVen])*sPESO
			EndIf
			If nPIdentB6 <> 0 .And. !Empty(aCols[nX][nPIdentB6])
				SD1->(dbSetOrder(4))
				If SD1->(MSSeek(xFilial("SD1")+aCols[nX][nPIdentB6]))
					nRecOri := SD1->(Recno())
				EndIf
			ElseIf nPNfOri > 0 .And. nPSerOri > 0 .And. nPItemOri > 0
				If !Empty(aCols[nX][nPNfOri]) .And. !Empty(aCols[nX][nPItemOri])
					SD1->(dbSetOrder(1))
					If SD1->(MSSeek(xFilial("SD1")+aCols[nX][nPNfOri]+aCols[nX][nPSerOri]+M->C5_CLIENTE+M->C5_LOJACLI+aCols[nX][nPProduto]+aCols[nX][nPItemOri]))
						nRecOri := SD1->(Recno())
					EndIf
				EndIf
			EndIf
			SB2->(dbSetOrder(1))
			SB2->(MsSeek(xFilial("SB2")+SB1->B1_COD+aCols[nX][nPLocal]))
			SF4->(dbSetOrder(1))
			SF4->(MsSeek(xFilial("SF4")+aCols[nX][nPTES]))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Calcula o preco de lista                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nValMerc  := If(aCols[nX][nPQtdVen]==0,aCols[nX][nPTotal],If(lSaldo,(aCols[nX][nPQtdVen]-nQtdEnt)*aCols[nX][nPPrcVen],aCols[nX][nPTotal]))
			nPrcLista := aCols[nX][nPPrUnit]
			If ( nPrcLista == 0 )
				nValMerc  := If(aCols[nX][nPQtdVen]==0,aCols[nX][nPTotal],If(lSaldo,(aCols[nX][nPQtdVen]-nQtdEnt)*aCols[nX][nPPrcVen],aCols[nX][nPTotal]))
			EndIf
			nAcresFin := A410Arred(aCols[nX][nPPrcVen]*M->C5_ACRSFIN/100,"D2_PRCVEN")
			nValMerc  += A410Arred(If(lSaldo,aCols[nX][nPQtdVen]-nQtdEnt,aCols[nX][nPQtdVen])*nAcresFin,"D2_TOTAL")
			nDesconto := a410Arred(nPrcLista*If(lSaldo,aCols[nX][nPQtdVen]-nQtdEnt,aCols[nX][nPQtdVen]),"D2_DESCON")-nValMerc
			nDesconto := IIf(nDesconto==0,aCols[nX][nPValDesc],nDesconto)
			nDesconto := Max(0,nDesconto)
			nPrcLista += nAcresFin
			//Para os outros paises, este tratamento e feito no programas que calculam os impostos.
			If cPaisLoc=="BRA"
				nValMerc  += nDesconto
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica a data de entrega para as duplicatas³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ( nPDtEntr > 0 )
				If ( dDataCnd > aCols[nX][nPDtEntr] .And. !Empty(aCols[nX][nPDtEntr]) )
					dDataCnd := aCols[nX][nPDtEntr]
				EndIf
			Else
				dDataCnd  := M->C5_EMISSAO
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Agrega os itens para a funcao fiscal         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MaFisAdd(cProduto,;   	// 1-Codigo do Produto ( Obrigatorio )
			aCols[nX][nPTES],;	   	// 2-Codigo do TES ( Opcional )
			If(lSaldo,aCols[nX][nPQtdVen]-nQtdEnt,aCols[nX][nPQtdVen]),;  	// 3-Quantidade ( Obrigatorio )
			nPrcLista,;		  	// 4-Preco Unitario ( Obrigatorio )
			nDesconto,; 	// 5-Valor do Desconto ( Opcional )
			"",;	   			// 6-Numero da NF Original ( Devolucao/Benef )
			"",;				// 7-Serie da NF Original ( Devolucao/Benef )
			nRecOri,;					// 8-RecNo da NF Original no arq SD1/SD2
			0,;					// 9-Valor do Frete do Item ( Opcional )
			0,;					// 10-Valor da Despesa do item ( Opcional )
			0,;					// 11-Valor do Seguro do item ( Opcional )
			0,;					// 12-Valor do Frete Autonomo ( Opcional )
			nValMerc,;			// 13-Valor da Mercadoria ( Obrigatorio )
			0)					// 14-Valor da Embalagem ( Opiconal )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Calculo do ISS                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SF4->(dbSetOrder(1))
			SF4->(MsSeek(xFilial("SF4")+aCols[nX][nPTES]))
				If ( M->C5_INCISS == "N" .And. M->C5_TIPO == "N")
					If ( SF4->F4_ISS=="S" )
					nPrcLista := a410Arred(nPrcLista/(1-(MaAliqISS(nItem)/100)),"D2_PRCVEN")
					nValMerc  := a410Arred(nValMerc/(1-(MaAliqISS(nItem)/100)),"D2_PRCVEN")
					MaFisAlt("IT_PRCUNI",nPrcLista,nItem)
					MaFisAlt("IT_VALMERC",nValMerc,nItem)
					EndIf
				EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Altera peso para calcular frete              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MaFisAlt("IT_PESO",nQtdPeso,nItem)
			MaFisAlt("IT_PRCUNI",nPrcLista,nItem)
			MaFisAlt("IT_VALMERC",nValMerc,nItem)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Analise da Rentabilidade                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SF4->F4_DUPLIC=="S"
				nTotDesc += MaFisRet(nItem,"IT_DESCONTO")
				nY := aScan(aRentab,{|x| x[1] == aCols[nX][nPProduto]})
					If nY == 0
					aadd(aRenTab,{aCols[nX][nPProduto],0,0,0,0,0})
					nY := Len(aRenTab)
					EndIf
					If cPaisLoc=="BRA"
					aRentab[nY][2] += (nValMerc - nDesconto)
					Else
					aRentab[nY][2] += nValMerc
					Endif
				aRentab[nY][3] += If(lSaldo,aCols[nX][nPQtdVen]-nQtdEnt,aCols[nX][nPQtdVen])*SB2->B2_CM1
				Else
					If GetNewPar("MV_TPDPIND","1")=="1"
					nTotDesc += MaFisRet(nItem,"IT_DESCONTO")
					EndIf
				EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ponto de Entrada M410IPI para alterar os valores do IPI referente a palnilha financeira           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lM410Ipi
				VALORIPI    := MaFisRet(nItem,"IT_VALIPI")
				BASEIPI     := MaFisRet(nItem,"IT_BASEIPI")
				QUANTIDADE  := MaFisRet(nItem,"IT_QUANT")
				ALIQIPI     := MaFisRet(nItem,"IT_ALIQIPI")
				BASEIPIFRETE:= MaFisRet(nItem,"IT_FRETE")
				MaFisAlt("IT_VALIPI",ExecBlock("M410IPI",.F.,.F.,{ nItem }),nItem,.T.)
				MaFisLoad("IT_BASEIPI",BASEIPI ,nItem)
				MaFisLoad("IT_ALIQIPI",ALIQIPI ,nItem)
				MaFisLoad("IT_FRETE"  ,BASEIPIFRETE,nItem,"11")
				MaFisEndLoad(nItem,1)
				EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ponto de Entrada M410ICM para alterar os valores do ICM referente a palnilha financeira           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lM410Icm
				_BASEICM    := MaFisRet(nItem,"IT_BASEICM")
				_ALIQICM    := MaFisRet(nItem,"IT_ALIQICM")
				_QUANTIDADE := MaFisRet(nItem,"IT_QUANT")
				_VALICM     := MaFisRet(nItem,"IT_VALICM")
				_FRETE      := MaFisRet(nItem,"IT_FRETE")
				_VALICMFRETE:= MaFisRet(nItem,"IT_ICMFRETE")
				_DESCONTO   := MaFisRet(nItem,"IT_DESCONTO")
				ExecBlock("M410ICM",.F.,.F., { nItem } )
				MaFisLoad("IT_BASEICM" ,_BASEICM    ,nItem)
				MaFisLoad("IT_ALIQICM" ,_ALIQICM    ,nItem)
				MaFisLoad("IT_VALICM"  ,_VALICM     ,nItem)
				MaFisLoad("IT_FRETE"   ,_FRETE      ,nItem)
				MaFisLoad("IT_ICMFRETE",_VALICMFRETE,nItem)
				MaFisLoad("IT_DESCONTO",_DESCONTO   ,nItem)
				MaFisEndLoad(nItem,1)
				EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ponto de Entrada M410SOLI para alterar os valores do ICM Solidario referente a palnilha financeira³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lM410Soli
				ICMSITEM    := MaFisRet(nItem,"IT_VALICM")		// variavel para ponto de entrada
				QUANTITEM   := MaFisRet(nItem,"IT_QUANT")		// variavel para ponto de entrada
				BASEICMRET  := MaFisRet(nItem,"IT_BASESOL")	    // criado apenas para o ponto de entrada
				MARGEMLUCR  := MaFisRet(nItem,"IT_MARGEM")		// criado apenas para o ponto de entrada
				aSolid := ExecBlock("M410SOLI",.f.,.f.,{nItem})
				aSolid := IIF(ValType(aSolid) == "A" .And. Len(aSolid) > 0, aSolid,{})
					If !Empty(aSolid)
					MaFisLoad("IT_BASESOL",NoRound(aSolid[1],2),nItem)
					MaFisLoad("IT_VALSOL" ,NoRound(aSolid[2],2),nItem)
					MaFisLoad("IT_BSFCPST",NoRound(aSolid[3],2),nItem) //BASE
					MaFisLoad("IT_ALFCST" ,NoRound(aSolid[4],2),nItem) //ALIQ		
					MaFisLoad("IT_VFECPST",NoRound(aSolid[5],2),nItem) //VALOR					
					MaFisEndLoad(nItem,1)
					Endif
				EndIf
			//EndIf
			Next nX
		EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Indica os valores do cabecalho               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MaFisAlt("NF_FRETE",M->C5_FRETE)
		If !Empty(SC5->(FieldPos("C5_VLR_FRT")))
		MaFisAlt("NF_VLR_FRT",M->C5_VLR_FRT)
		EndIf
	MaFisAlt("NF_SEGURO",M->C5_SEGURO)
	MaFisAlt("NF_AUTONOMO",M->C5_FRETAUT)
	MaFisAlt("NF_DESPESA",M->C5_DESPESA)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Indenizacao por valor                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If M->C5_DESCONT > 0
		MaFisAlt("NF_DESCONTO",Min(MaFisRet(,"NF_VALMERC")-0.01,nTotDesc+M->C5_DESCONT),/*nItem*/,/*lNoCabec*/,/*nItemNao*/,GetNewPar("MV_TPDPIND","1")=="2" )
		EndIf

		If M->C5_PDESCAB > 0
		MaFisAlt("NF_DESCONTO",A410Arred(MaFisRet(,"NF_VALMERC")*M->C5_PDESCAB/100,"C6_VALOR")+MaFisRet(,"NF_DESCONTO"))
		EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Realiza alteracoes de referencias do SC6         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//DESATIVADO EM 01/07/2013 POIS ESTAVA ALTERADO O CALCULO DO ICMS ST
	//dbSelectArea("SC6")
	//If Len(aFisGet) > 0
	//	For nX := 1 to Len(aCols)
	//		If Len(aCols[nX])==nUsado .Or. !aCols[nX][Len(aHeader)+1]
	//			For nY := 1 to Len(aFisGet)
	//				nPosCpo := aScan(aHeader,{|x| AllTrim(x[2])==Alltrim(aFisGet[ny][2])})
	//				If nPosCpo > 0
	//					If !Empty(aCols[nX][nPosCpo])
	//						MaFisAlt(aFisGet[ny][1],aCols[nX][nPosCpo],nX,.F.)
	//					Endif
	//				EndIf
	//			Next nX
	//		Endif
	//	Next nY
	//EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Realiza alteracoes de referencias do SC5 Suframa ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPSuframa:=aScan(aFisGetSC5,{|x| x[1] == "NF_SUFRAMA"})
		If !Empty(nPSuframa)
		dbSelectArea("SC5")
			If !Empty(&("M->"+Alltrim(aFisGetSC5[nPSuframa][2])))
			MaFisAlt(aFisGetSC5[nPSuframa][1],Iif(&("M->"+Alltrim(aFisGetSC5[nPSuframa][2])) == "1",.T.,.F.),nItem,.F.)
			EndIf
		Endif
	/*If ExistBlock("M410PLNF")
	ExecBlock("M410PLNF",.F.,.F.)
	EndIf*/
	MaFisWrite(1)
	//
	// Template GEM - Gestao de Empreendimentos Imobiliarios
	//
	// Verifica se a condicao de pagamento tem vinculacao com uma condicao de venda
	//
	If ExistTemplate("GMCondPagto")
		lCondVenda := .F.
		lCondVenda := ExecTemplate("GMCondPagto",.F.,.F.,{M->C5_CONDPAG,} )
	EndIf

	// Template GEM - Gestao de empreendimentos Imobiliarios
	// Gera os vencimentos e valores das parcelas conforme a condicao de venda
	If lCondVenda
		If ExistBlock("GMMA410Dupl")
			aVencto := ExecBlock("GMMA410Dupl",.F.,.F.,{M->C5_NUM ,M->C5_CONDPAG,dDataCnd,,MaFisRet(,"NF_BASEDUP") ,aVencto}, .F., .F.)
		ElseIf ExistTemplate("GMMA410Dupl")
			aVencto := ExecTemplate("GMMA410Dupl",.F.,.F.,{M->C5_NUM ,M->C5_CONDPAG,dDataCnd,,MaFisRet(,"NF_BASEDUP") ,aVencto})
		Endif
		aDupl := {}
		aEval(aVencto ,{|aTitulo| aAdd( aDupl ,{transform(aTitulo[1],x3Picture("E1_VENCTO")) ,transform(aTitulo[2],x3Picture("E1_VALOR"))}) })
	EndIf

	If Len(aDupl) == 0
		aDupl := {{Ctod(""),TransForm(MaFisRet(,"NF_BASEDUP"),PesqPict("SE1","E1_VALOR"))}}
		aVencto := {{dDataBase,MaFisRet(,"NF_BASEDUP")}}
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Analise da Rentabilidade - Valor Presente    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//aRentabil := a410RentPV( aCols ,nUsado ,@aRenTab ,@aVencto ,nPTES,nPProduto,nPLocal,nPQtdVen )

	If MaFisRet(,"NF_VALSOL") > 0 .And. GetMV("MV_YUFSTSD") $ U_fGetUF(FunName())[2]

		//Para empresa LM o sistema está calculando a variavel MaFisRet(,"NF_TOTAL") ja considerando o valor da variavel MaFisRet(,"NF_VALSOL"), por este motivo estamos realizando o acerto abaixo.	
		If SF4->F4_INCSOL == "S"
			nValorTotal	:=	MaFisRet(1,"NF_TOTAL")-MaFisRet(,"NF_VALSOL")
		Else
			nValorTotal	:=	MaFisRet(1,"NF_TOTAL")+MaFisRet(,"NF_VALSOL") 		
		EndIf

	Else
		nValorTotal := MaFisRet(1,"NF_TOTAL")
	EndIf

	MaFisEnd()
	MaFisRestore()

	RestArea(aAreaSA1)
	RestArea(aArea)

Return(nValorTotal)

//*******************************************************************************************
//************* ROTINA PARA A APLICACAO DO CONTROLE DE RA ***********************************
//*******************************************************************************************
//Rotina para verificar se o pedido de venda contem uma forma de pagamento do tipo RA
User Function fValidaRA(cCondPAg)

	Local cSql := ""

	// VERIFICANDO SE A CONDICAO DE PAGAMENTO E ANTECIPADA.
	//CSQL := "SELECT COUNT(E4_CODIGO) AS QUANT "
	//CSQL += "FROM "+RETSQLNAME("SE4")+" "
	//CSQL += "WHERE D_E_L_E_T_ = '' AND "
	//CSQL += "      E4_CODIGO = '"+ALLTRIM(cCondPAg)+"' AND "
	//CSQL += "      E4_CODIGO IN 	(SELECT E4_CODIGO "
	//CSQL += "			FROM "+RETSQLNAME("SE4")+" "
	//CSQL += "			WHERE E4_YATIVO = '1' AND "
	//CSQL += "			      E4_DESCRI LIKE '%ANTE%' AND "
	//CSQL += "			      D_E_L_E_T_ = '') "

	cSql := "SELECT COUNT(E4_CODIGO) AS QUANT				"
	cSql += "FROM "+RETSQLNAME("SE4")+"						"
	cSql += "WHERE	E4_FILIAL = '"+xFilial("SE4")+"'	AND "
	cSql += "		E4_CODIGO = '"+ALLTRIM(cCondPAg)+"'	AND "
	cSql += "		E4_YATIVO = '1' 					AND "
	cSql += "		E4_DESCRI LIKE '%ANTE%' 			AND "
	cSql += "		D_E_L_E_T_ = ''							"
	If chkfile("_AUX")
		dbSelectArea("_AUX")
		dbCloseArea()
	EndIf
	TCQUERY CSQL ALIAS "_AUX" NEW

	IF _AUX->QUANT >= 1
		lRet := .T.
	Else
		lRet := .F.
	EndIf

Return(lRet)	


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fBuscaDesconto  ºAutor  ³Ranisses            º Data ³  15/10/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao utilizada para busca do desconto utilizado no Pedido Venda º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Faturamento                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function fBuscaDesconto(nVend,nSegm,nCli,nGrpCli,nProd,nLote,dtEmis,nLinha)
	Local cSql		:= ""
	Local nDesc1	:= 0
	Local nDesc2	:= 0
	Local nDesconto	:= 0
	Local Enter 	:= CHR(13)+CHR(10)
	Local lProd		:= .F.

	Public cRegraSC6 := ''

	//Busca o Grupo do Segmento, a partir do Segmento do Cliente
	cSql := " SELECT MAX(ZZG_GRUPO) GRUPO FROM ZZG010 WHERE ZZG_SEG = '" + nSegm + "' AND D_E_L_E_T_ = '' "
	If chkfile("R1")
		dbSelectArea("R1")
		dbCloseArea()
	EndIf
	TCQUERY cSql ALIAS "R1" NEW

	nSegm := R1->GRUPO

	If !Empty(nVend)
		//Busca o desconto do Representante.
		cSql := "SELECT ACP_PERDES, ACP_CODREG " + Enter
		If nLinha = "1"	//Biancogres
			cSql += "From ACO010 ACO, ACP010 ACP " + Enter
		Else						//Incesa e BellaCasa
			cSql += "From ACO050 ACO, ACP050 ACP " + Enter
		EndIf
		cSql += "Where 	ACO.ACO_FILIAL 	= '" + xFilial("ACO") + "' AND " + Enter
		cSql += "     	ACP.ACP_FILIAL 	= '" + xFilial("ACP") + "' AND " + Enter
		cSql += "				'" + dtEmis +"' >= ACP.ACP_YDATDE		AND " + Enter
		cSql += "				'" + dtEmis +"' <= ACP.ACP_YDATAT		AND " + Enter
		cSql += "				ACP.ACP_YESTCL 	= ''								AND " + Enter
		cSql += "				ACP.ACP_CODREG	= ACO.ACO_CODREG		AND " + Enter
		cSql += "				ACP.ACP_YVEND		= '" + nVend +"'		AND " + Enter
		cSql += "				ACP.ACP_YSEGME	= ''						   	AND " + Enter 	//TRATAMENTO PARA O SEGMENTO
		If Substr(nVend,1,1) == "0"																		  //PERMITE DESCONTO PARA SUPERVISOR
			cSql += "	SUBSTRING(ACP.ACP_CODPRO,2,5)	= '" + SUBSTR(nVend,2,5) +"' AND " + Enter
		EndIf
		cSql += "				ACO.ACO_YLINHA	= '"+nLinha+"'			AND	" + Enter //Biancogres - Incesa - BellaCasa
		cSql += "				ACO.ACO_YTIPO 	= 'D'								AND " + Enter

		//Inserido por Wanisay em 13/08/12
		cSql += "				(ACO_YEXCLC NOT LIKE '%" + nCli +"%'     Or " + Enter
		cSql += "				ACO_YEXCLG NOT LIKE '%" + nGrpCli+"%' ) AND	" + Enter

		cSql += "				ACP.D_E_L_E_T_	= ''  AND 									" + Enter
		cSql += "				ACO.D_E_L_E_T_ 	= ''  AND ACO_MSBLQL <> '1'	" + Enter
		If chkfile("X2")
			dbSelectArea("X2")
			dbCloseArea()
		EndIf
		TCQUERY cSql ALIAS "X2" NEW

		If X2->ACP_PERDES > 0
			nDesc1    := X2->ACP_PERDES
			cRegraSC6 := X2->ACP_CODREG
		EndIf


		// *************** BRUNO MADALENO *********************
		// SOBREPOR REPRESENTANTE CLIENTE  ESTADO
		// ****************************************************
		nEst	:= Posicione("SA1",1,xFilial("SA1")+nCli,"A1_EST")
		cSql := "SELECT ACP_PERDES, ACP_CODREG " + Enter
		If nLinha = "1"		//Biancogres
			cSql += "From ACO010 ACO, ACP010 ACP " + Enter
		Else							//Incesa e BellaCasa
			cSql += "From ACO050 ACO, ACP050 ACP " + Enter
		EndIf
		cSql += "Where 	ACO.ACO_FILIAL 	= '" + xFilial("ACO") + "' AND " + Enter
		cSql += "     	ACP.ACP_FILIAL 	= '" + xFilial("ACP") + "' AND " + Enter
		cSql += "				'" + dtEmis +"' 	>= ACP.ACP_YDATDE	AND " + Enter
		cSql += "				'" + dtEmis +"' 	<= ACP.ACP_YDATAT	AND " + Enter
		cSql += "				ACP.ACP_YESTCL 	= '"+nEst+"'			AND " + Enter
		cSql += "   			ACP.ACP_CODREG	= ACO.ACO_CODREG  AND " + Enter
		cSql += "				ACP.ACP_YVEND		= '" + nVend +"'	AND " + Enter
		cSql += "				ACP.ACP_YSEGME	= ''						 	AND " + Enter 	//TRATAMENTO PARA O SEGMENTO
		If Substr(nVend,1,1) == "0"												 						//PERMITE DESCONTO PARA SUPERVISOR
			cSql += "	SUBSTRING(ACP.ACP_CODPRO,2,5)	= '" + SUBSTR(nVend,2,5) +"' AND " + Enter
		EndIf
		cSql += "				ACO.ACO_YLINHA	= '"+nLinha+"'	AND	" + Enter //Biancogres - Incesa - BellaCasa
		cSql += "				ACO.ACO_YTIPO 	= 'D'						AND " + Enter

		//Inserido por Wanisay em 13/08/12
		cSql += "	 			(ACO_YEXCLC NOT LIKE '%" + nCli +"%'     Or " + Enter
		cSql += "	  		ACO_YEXCLG NOT LIKE '%" + nGrpCli+"%' ) AND	" + Enter

		cSql += "				ACP.D_E_L_E_T_	= ''		        AND 				" + Enter
		cSql += "				ACO.D_E_L_E_T_ 	= ''  AND ACO_MSBLQL <> '1' " + Enter
		If chkfile("X2")
			dbSelectArea("X2")
			dbCloseArea()
		EndIf
		TCQUERY cSql ALIAS "X2" NEW

		If X2->ACP_PERDES > 0
			nDesc1    := X2->ACP_PERDES
			cRegraSC6 := X2->ACP_CODREG
		EndIf


		//Busca o desconto do Representante / Segmento
		cSql := "SELECT ACP_PERDES, ACP_CODREG " + Enter
		If nLinha = "1"	//Biancogres
			cSql += "From ACO010 ACO, ACP010 ACP " + Enter
		Else						//Incesa e BellaCasa
			cSql += "From ACO050 ACO, ACP050 ACP " + Enter
		EndIf
		cSql += "Where 	ACO.ACO_FILIAL 	= '" + xFilial("ACO") + "' And " + Enter
		cSql += "     	ACP.ACP_FILIAL 	= '" + xFilial("ACP") + "' And " + Enter
		cSql += "	'" + dtEmis +"' 	>= ACP.ACP_YDATDE	And " + Enter
		cSql += "	'" + dtEmis +"' 	<= ACP.ACP_YDATAT	And " + Enter
		cSql += "		ACP.ACP_YESTCL	= ''							And " + Enter
		cSql += "   ACP.ACP_CODREG	= ACO.ACO_CODREG	And " + Enter
		cSql += "		ACP.ACP_YVEND		= '" + nVend +"'	And " + Enter
		cSql += "		ACP.ACP_YSEGME	= '" + nSegm +"'	And " + Enter 	//TRATAMENTO PARA O SEGMENTO
		If Substr(nVend,1,1) == "0"												 									//PERMITE DESCONTO PARA SUPERVISOR
			cSql += "	SUBSTRING(ACP.ACP_CODPRO,2,5)	= '" + SUBSTR(nVend,2,5) +"' And " + Enter
		EndIf
		cSql += "		ACO.ACO_YLINHA	= '"+nLinha+"'		And	" + Enter //Biancogres - Incesa - BellaCasa
		cSql += "		ACO.ACO_YTIPO 	= 'D'							And " + Enter

		//Inserido por Wanisay em 13/08/12
		cSql += "	 (ACO_YEXCLC NOT LIKE '%" + nCli +"%'     Or " + Enter
		cSql += "	  ACO_YEXCLG NOT LIKE '%" + nGrpCli+"%' ) And	" + Enter

		cSql += "		ACP.D_E_L_E_T_	= ''		                   And 	" + Enter
		cSql += "		ACO.D_E_L_E_T_ 	= ''  AND ACO_MSBLQL <> '1' 		" + Enter
		If chkfile("X2")
			dbSelectArea("X2")
			dbCloseArea()
		EndIf
		TCQUERY cSql ALIAS "X2" NEW

		If X2->ACP_PERDES > 0
			nDesc1    := X2->ACP_PERDES
			cRegraSC6 := X2->ACP_CODREG
		EndIf

		//Busca desconto Representante / Produto / Lote
		cSql := "SELECT ACP_PERDES, ACP_YTPDES, ACP_CODREG " + Enter
		If nLinha = "1"	//Biancogres
			cSql += "From ACO010 ACO, ACP010 ACP " + Enter
		Else						//Incesa e BellaCasa
			cSql += "From ACO050 ACO, ACP050 ACP " + Enter
		EndIf
		cSql += "Where 	ACO.ACO_FILIAL 	= '" + xFilial("ACO") + "' AND " + Enter
		cSql += "     	ACP.ACP_FILIAL 	= '" + xFilial("ACP") + "' AND " + Enter
		cSql += "		'" + dtEmis +"' 	>= ACP.ACP_YDATDE	AND " + Enter
		cSql += "		'" + dtEmis +"' 	<= ACP.ACP_YDATAT	AND " + Enter
		cSql += "		ACP.ACP_YESTCL 	= '' 					AND " + Enter
		cSql += "		ACP.ACP_CODREG	= ACO.ACO_CODREG		AND " + Enter
		cSql += "		ACP.ACP_YVEND		= '" + nVend +"'	AND " + Enter
		cSql += "		ACP.ACP_YSEGME	= ''					AND " + Enter //TRATAMENTO PARA O SEGMENTO

		cSql += "		ACP.ACP_CODPRO	= '" + nProd +"' AND " + Enter
		//RETIRADO VALIDAÇÃO DO LOTE EM 25/05/15, POIS A REGRA NÃO ATENDE AO CENÁRIO ATUAL
		//If Empty(Alltrim(nLote))
		//	cSql += "			ACP.ACP_CODPRO	= '" + nProd +"' AND " + Enter
		//Else
		//	cSql += "			ACP.ACP_CODPRO	= '" + nProd +"' AND ACP.ACP_YLOTE = '" + nLote +"' AND " + Enter
		//EndIf

		cSql += "		ACO.ACO_YLINHA	= '"+nLinha+"'	AND " + Enter //Biancogres - Incesa - BellaCasa
		cSql += "		ACO.ACO_YTIPO 	= 'D'			AND " + Enter

		//Inserido por Wanisay em 13/08/12
		cSql += "		(ACO_YEXCLC NOT LIKE '%" + nCli +"%'     Or " + Enter
		cSql += "	 	ACO_YEXCLG NOT LIKE '%" + nGrpCli+"%' ) AND	" + Enter

		cSql += "		ACP.D_E_L_E_T_	= ''		                   AND " + Enter
		cSql += "		ACO.D_E_L_E_T_ 	= ''  AND ACO_MSBLQL <> '1' " + Enter
		If chkfile("X2")
			dbSelectArea("X2")
			dbCloseArea()
		EndIf
		TCQUERY cSql ALIAS "X2" NEW

		If X2->ACP_PERDES > 0
			If X2->ACP_YTPDES == 'S'
				nDesc1    := X2->ACP_PERDES
				cRegraSC6 := X2->ACP_CODREG
				lProd     := .T.
			Else
				nDesc2    := X2->ACP_PERDES
				cRegraSC6 := cRegraSC6 +"/"+ X2->ACP_CODREG
				lProd     := .T.
			EndIf
		EndIf

		//Busca desconto Representante / Segmento / Produto / Lote
		cSql := "SELECT ACP_PERDES, ACP_YTPDES, ACP_CODREG " + Enter
		If nLinha = "1"	//Biancogres
			cSql += "From ACO010 ACO, ACP010 ACP " + Enter
		Else						//Incesa e BellaCasa
			cSql += "From ACO050 ACO, ACP050 ACP " + Enter
		EndIf
		cSql += "Where 	ACO.ACO_FILIAL 	= '" + xFilial("ACO") + "' AND " + Enter
		cSql += "		ACP.ACP_FILIAL 	= '" + xFilial("ACP") + "' AND " + Enter
		cSql += "		'" + dtEmis +"' 	>= ACP.ACP_YDATDE	AND " + Enter
		cSql += "		'" + dtEmis +"' 	<= ACP.ACP_YDATAT	AND " + Enter
		cSql += "		ACP.ACP_YESTCL 	= ''								AND " + Enter
		cSql += "   	ACP.ACP_CODREG	= ACO.ACO_CODREG		AND " + Enter
		cSql += "		ACP.ACP_YVEND		= '" + nVend +"'		AND " + Enter
		cSql += "		ACP.ACP_YSEGME	= '" + nSegm +"'		AND " + Enter //TRATAMENTO PARA O SEGMENTO

		cSql += "		ACP.ACP_CODPRO	= '" + nProd +"' AND " + Enter
		//RETIRADO VALIDAÇÃO DO LOTE EM 25/05/15, POIS A REGRA NÃO ATENDE AO CENÁRIO ATUAL
		//If Empty(Alltrim(nLote))
		//	cSql += "		ACP.ACP_CODPRO	= '" + nProd +"' AND " + Enter
		//Else
		//	cSql += "		ACP.ACP_CODPRO	= '" + nProd +"' AND ACP.ACP_YLOTE = '" + nLote +"' AND " + Enter
		//EndIf

		cSql += "		ACO.ACO_YLINHA	= '"+nLinha+"'	AND	" + Enter //Biancogres - Incesa - BellaCasa
		cSql += "		ACO.ACO_YTIPO 	= 'D'						AND " + Enter

		//Inserido por Wanisay em 13/08/12
		cSql += "		(ACO_YEXCLC NOT LIKE '%" + nCli +"%'     Or " + Enter
		cSql += "	  	ACO_YEXCLG NOT LIKE '%" + nGrpCli+"%' ) AND	" + Enter

		cSql += "		ACP.D_E_L_E_T_	= ''		                   AND " + Enter
		cSql += "		ACO.D_E_L_E_T_ 	= ''  AND ACO_MSBLQL <> '1' " + Enter
		If chkfile("X2")
			dbSelectArea("X2")
			dbCloseArea()
		EndIf
		TCQUERY cSql ALIAS "X2" NEW

		If X2->ACP_PERDES > 0
			If X2->ACP_YTPDES == 'S'
				nDesc1    := X2->ACP_PERDES
				cRegraSC6 := X2->ACP_CODREG
				lProd     := .T.
			Else
				nDesc2    := X2->ACP_PERDES
				cRegraSC6 := cRegraSC6 +"/"+ X2->ACP_CODREG
				lProd     := .T.
			EndIf
		EndIf

	EndIf

	//Nao pode existir Grupo de Cliente Vazio
	If Empty(Alltrim(nGrpCli))
		nGrpCli := "."
	EndIf

	If !Empty(nCli) .OR. !Empty(nGrpCli)
		//Busca o desconto do cliente ou do grupo do cliente.
		cSql := "SELECT ACP_PERDES, ACP_YTPDES, ACP_CODREG  " + Enter
		If nLinha = "1"	//Biancogres
			cSql += "From ACO010 ACO, ACP010 ACP " + Enter
		Else						//Incesa e BellaCasa
			cSql += "From ACO050 ACO, ACP050 ACP " + Enter
		EndIf
		cSql += "Where 	ACO.ACO_FILIAL 	= '" + xFilial("ACO") + "' AND " + Enter
		cSql += "     	ACP.ACP_FILIAL 	= '" + xFilial("ACP") + "' AND " + Enter
		cSql += "				'" + dtEmis +"' 	>= ACP.ACP_YDATDE	AND " + Enter
		cSql += "				'" + dtEmis +"' 	<= ACP.ACP_YDATAT	AND " + Enter
		cSql += "				ACP.ACP_YESTCL 	= ''								AND " + Enter
		cSql += "				ACP.ACP_CODREG	= ACO.ACO_CODREG		AND " + Enter
		cSql += "				(ACO.ACO_CODCLI	= '" + nCli +"'			OR 	" + Enter
		cSql += "				ACO.ACO_GRPVEN	= '" + nGrpCli+"')	AND	" + Enter
		cSql += "				ACO.ACO_YLINHA	= '"+nLinha+"'			AND " + Enter //Biancogres - Incesa - BellaCasa
		cSql += "				ACO.ACO_YTIPO 	= 'D'								AND " + Enter

		//Inserido por Wanisay em 13/08/12
		cSql += "				(ACO_YEXCLC NOT LIKE '%" + nCli +"%'    OR 	" + Enter
		cSql += "	  		ACO_YEXCLG NOT LIKE '%" + nGrpCli+"%' ) AND	" + Enter

		cSql += "				ACP.D_E_L_E_T_	= ''		                AND	" + Enter
		cSql += "				ACO.D_E_L_E_T_ 	= '' AND ACO_MSBLQL <> '1' " + Enter
		If chkfile("X2")
			dbSelectArea("X2")
			dbCloseArea()
		EndIf
		TCQUERY cSql ALIAS "X2" NEW
		If X2->ACP_PERDES > 0
			nDesc1    := X2->ACP_PERDES
			cRegraSC6 := X2->ACP_CODREG
		EndIf

		//Busca o desconto Cliente/Grupo / Produto / Lote
		cSql := "SELECT ACP_PERDES, ACP_YTPDES, ACP_CODREG  " + Enter
		If nLinha = "1"	//Biancogres
			cSql += "From ACO010 ACO, ACP010 ACP " + Enter
		Else						//Incesa e BellaCasa
			cSql += "From ACO050 ACO, ACP050 ACP " + Enter
		EndIf
		cSql += "Where 	ACO.ACO_FILIAL 	= '" + xFilial("ACO") + "' AND " + Enter
		cSql += "     	ACP.ACP_FILIAL 	= '" + xFilial("ACP") + "' AND " + Enter
		cSql += "		'" + dtEmis +"' >= ACP.ACP_YDATDE	AND " + Enter
		cSql += "		'" + dtEmis +"' <= ACP.ACP_YDATAT	AND " + Enter
		cSql += "		ACP.ACP_YESTCL 	= ''							AND " + Enter
		cSql += "		ACP.ACP_CODREG	= ACO.ACO_CODREG	AND " + Enter

		cSql += "		ACP.ACP_CODPRO	= '" + nProd +"' AND " + Enter
		//RETIRADO VALIDAÇÃO DO LOTE EM 25/05/15, POIS A REGRA NÃO ATENDE AO CENÁRIO ATUAL
		//If Empty(Alltrim(nLote))
		//	cSql += "		ACP.ACP_CODPRO	= '" + nProd +"' AND " + Enter
		//Else
		//	cSql += "		ACP.ACP_CODPRO	= '" + nProd +"' AND ACP.ACP_YLOTE = '" + nLote +"' AND " + Enter
		//EndIf

		cSql += "		(ACO.ACO_CODCLI	= '" + nCli +"'		Or	" + Enter
		cSql += "		ACO.ACO_GRPVEN	= '" + nGrpCli+"')	AND " + Enter
		cSql += "		ACO.ACO_YLINHA	= '"+nLinha+"'	 		AND " + Enter //Biancogres - Incesa - BellaCasa
		cSql += "		ACO.ACO_YTIPO 	= 'D'								AND " + Enter

		//Inserido por Wanisay em 13/08/12
		cSql += "		(ACO_YEXCLC NOT LIKE '%" + nCli +"%'     Or " + Enter
		cSql += "		ACO_YEXCLG NOT LIKE '%" + nGrpCli+"%' ) AND	" + Enter

		cSql += "		ACP.D_E_L_E_T_	= ''		                AND " + Enter
		cSql += "		ACO.D_E_L_E_T_ 	= '' AND ACO_MSBLQL <> '1' " + Enter
		If chkfile("X2")
			dbSelectArea("X2")
			dbCloseArea()
		EndIf
		TCQUERY cSql ALIAS "X2" NEW

		If X2->ACP_PERDES > 0
			If X2->ACP_YTPDES == 'S'
				nDesc1    := X2->ACP_PERDES
				cRegraSC6 := X2->ACP_CODREG
				lProd     := .T.
			Else
				nDesc2    := X2->ACP_PERDES
				cRegraSC6 := cRegraSC6 +"/"+ X2->ACP_CODREG
				lProd     := .T.
			EndIf
		EndIf
	EndIf

	//Busca o desconto do produto ou do grupo do produto.
	If !lProd
		cSql := "SELECT ACP_PERDES, ACP_YTPDES, ACP_CODREG  " + Enter
		If nLinha = "1"	//Biancogres
			cSql += "From ACO010 ACO, ACP010 ACP " + Enter
		Else						//Incesa e BellaCasa
			cSql += "From ACO050 ACO, ACP050 ACP " + Enter
		EndIf
		cSql += "Where 	ACO.ACO_FILIAL 	= '" + xFilial("ACO") + "'	AND " + Enter
		cSql += "     	ACP.ACP_FILIAL 	= '" + xFilial("ACP") + "'	AND " + Enter
		cSql += "		'" + dtEmis +"' >= ACP.ACP_YDATDE		AND " + Enter
		cSql += "		'" + dtEmis +"' <= ACP.ACP_YDATAT		AND " + Enter
		cSql += "		ACP.ACP_YESTCL 	= ''								AND " + Enter
		cSql += "		ACP.ACP_CODREG	= ACO.ACO_CODREG		AND " + Enter
		cSql += "		ACP.ACP_YVEND		= ''								AND " + Enter
		cSql += "		ACO.ACO_CODCLI	= '' 								AND " + Enter
		cSql += "		ACO.ACO_GRPVEN	= ''								AND " + Enter
		cSql += "		ACP.ACP_CODPRO  <> '' 						  AND " + Enter

		cSql += "		ACP.ACP_CODPRO	= '" + nProd +"' AND " + Enter
		//RETIRADO VALIDAÇÃO DO LOTE EM 25/05/15, POIS A REGRA NÃO ATENDE AO CENÁRIO ATUAL
		//If Empty(Alltrim(nLote))
		//	cSql += "		ACP.ACP_CODPRO	= '" + nProd +"' AND " + Enter
		//Else
		//	cSql += "		ACP.ACP_CODPRO	= '" + nProd +"' AND ACP.ACP_YLOTE = '" + nLote +"' AND " + Enter
		//EndIf

		cSql += "		ACO.ACO_YLINHA	= '"+nLinha+"'			AND " + Enter //Biancogres - Incesa - BellaCasa
		cSql += "		ACO.ACO_YTIPO 	= 'D'								AND " + Enter

		//Inserido por Wanisay em 13/08/12
		cSql += "		(ACO_YEXCLC NOT LIKE '%" + nCli +"%'     Or " + Enter
		cSql += "	  	ACO_YEXCLG NOT LIKE '%" + nGrpCli+"%' ) AND	" + Enter

		cSql += "		ACP.D_E_L_E_T_	= ''							AND 			" + Enter
		cSql += "		ACO.D_E_L_E_T_ 	= '' AND ACO_MSBLQL <> '1' 	" + Enter
		If chkfile("X2")
			dbSelectArea("X2")
			dbCloseArea()
		EndIf
		TCQUERY cSql ALIAS "X2" NEW
		If X2->ACP_PERDES > 0
			If X2->ACP_YTPDES == 'S'
				nDesc1    := X2->ACP_PERDES
				cRegraSC6 := X2->ACP_CODREG
			Else
				nDesc2    := X2->ACP_PERDES
				cRegraSC6 := cRegraSC6 +"/"+ X2->ACP_CODREG
			EndIf
		EndIf
	EndIf

	nDesconto := Round(100 - ((1 - nDesc1/100) * (1 - nDesc2/100) * 100),2)

Return(nDesconto)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fBuscaPreco     ºAutor  ³Ranisses            º Data ³  18/10/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao utilizada para busca do preco de venda.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Faturamento                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function fBuscaPreco(cLinha,cCodTab,cProd,dEmissao,cCli,cLoja,cSubTp,nIcmsOri,nIcmsDes,nFECP,cTES,nFatMul,cCodTra,cEmpPed)
	Local nPrcTab := 0
	Local nDifIcms:= 0
	Local cSql 	  := ""
	Local cDIFAL  := "2" //Determina se calcula ou não DIFAL (1-Calcula / 2-Nao Calcula)

	Default nFatMul := 0
	Default cCodTra := ""
	Default cEmpPed := ""

	//Posiciona no TES
	SF4->(DbSetOrder(1))
	If SF4->(DbSeek(XFilial("SF4")+cTES))
		cDIFAL := SF4->F4_DIFAL
	EndIf

	//Posiciona no Cliente
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(XFilial("SA1")+cCli+cLoja))

	//Busca Preço
	cSql	:= ""
	cSql	+= "SELECT DA1_PRCVEN, DA0_YPOLIT "
	cSql	+= "FROM " + RetSqlName("DA1") + " DA1, " + RetSqlName("DA0") + " DA0 "
	cSql	+= "WHERE	DA0.DA0_FILIAL 	= '" + xFilial("DA0") + "'	AND "
	cSql	+= "     	DA1.DA1_FILIAL 	= '" + xFilial("DA1") + "'	AND "
	cSql	+= "		'" + dEmissao +"' 	>= DA0.DA0_DATDE		AND "
	cSql	+= "		'" + dEmissao +"' 	<= DA0.DA0_DATATE		AND "
	cSql	+= "		DA0.DA0_CODTAB	= '" + cCodTab +"'			AND "
	cSql	+= "		DA0.DA0_CODTAB	= DA1.DA1_CODTAB			AND "
	cSql	+= "		DA1.DA1_CODPRO	= '" + cProd +"'			AND "
	cSql	+= "	DA0.D_E_L_E_T_	= ''	AND "
	cSql	+= "	DA1.D_E_L_E_T_ 	= ''		"
	If chkfile("X1")
		dbSelectArea("X1")
		dbCloseArea()
	EndIf
	TCQUERY cSql ALIAS "X1" NEW

	If !X1->(EOF())
		nPrcTab := X1->DA1_PRCVEN

		//Fernando/Facile em 18/05/2017 - nova versao da funcao para projeto Filial LM
		If Z65->(FieldPos("Z65_FATIMP")) > 0
			_cMsgRet	:= ""
			nDifIcms  	:= U_fDifICM3(cLinha,cSubTp,cCli,cLoja,cProd,nIcmsOri,nIcmsDes,nFECP,cDIFAL,cCodTab,dEmissao,cCodTra,@_cMsgRet,cEmpPed) //NOVA TABELA DE FATOR - RANISSES EM 08/01/16 - EC 87/2015

			If nDifIcms == 0
				MsgStop(_cMsgRet,"Localizar Fator Multiplicador (fBuscaPreco)")
			EndIf
		Else
			nDifIcms  	:= U_fDifICM2(cLinha,cSubTp,cCli,cLoja,cProd,nIcmsOri,nIcmsDes,nFECP,cDIFAL,cCodTab,dEmissao) //NOVA TABELA DE FATOR - RANISSES EM 08/01/16 - EC 87/2015

			If nDifIcms == 0
				MsgStop("Não foi localizado o Fator Multiplicador da Tabela Base para este Pedido. Favor procurar Gerência Comercial ou TI.")
			EndIf
		EndIf



		nFatMul		:= nDifIcms
		nPrcTab		:= nPrcTab*nDifIcms

	Else
		MsgStop("Nao existe tabela de preco para este produto.")
	EndIf

Return(nPrcTab)


/*/
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³FUN‡„O    ³ CALCULA_DESCONTO ³ AUTOR ³ BRUNO MADALENO        ³ DATA ³ 14/03/07  	³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³          ³VL_IMPOS: CALCULA O VALOR DO DESCONTO PARA O PEDIDO DE VENDA 	   		  ³±±
	±±³          ³                                                                      ³±±
	±±³          ³          ATENCAO PAR O CORRETO FUNCIONAMENTO DA FUNCAO               ³±±
	±±³          ³    E NECESSÁRIO ESTAR POSICIONADO NO PEDIDO DE VENDA        	   		  ³±±
	±±³          ³                                                             	   		  ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³          ³ CPRODUTO         CODIGO DE PRODUTO                                   ³±±
	±±³          ³ CCODTABELA       TABELA DE PRECO QUE ESTA EM VIFOR           	 			³±±
	±±³          ³ CLIENTE          CLIENTE PARA BUSCAR O PERCENTUAL DE DESCONTO				³±±
	±±³          ³ LOJA             LOJA DO CLIENTE                            					³±±
	±±³          ³ PRECO INFORMADO  PRECO INFORMADO PELO USUARIO               					³±±
	±±³          ³ CONDICAO         CONDICAO DE PAGAMENTO PARA BUSCAR O PERCENTUAL      ³±±
	±±³          ³ CEMPRESA         CODIGO DA EMPRESA                                   ³±±
	±±³          ³ V_SEGURO         VALOR DO SEGURO                                     ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³RETORNO   ³ VALOR DO DESCONTO BASEADO NO PRECO INFORMADO                					³±±
	±±³          ³                                                             		 			³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³DESCRI‡„O ³ESTA FUNCAO EFETUA OS CALCULOS DE DESCONTO SE BASEANDO NO    		 			³±±
	±±³          ³PRECO INFORMADO PELO USUARIO                                 					³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³USO       ³ PERSONALIZACAO                                              		 			³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

USER FUNCTION CALCULA_DESCONTO(CPRODUTO, CCODTABELA, CLIENTE, LOJA, _SPRECO_DIG, CONDICAO, CEMPRESA, V_SEGURO)
	LOCAL NDESC := 0
	LOCAL NFATDM := 0

	SA1->(DBSETORDER(1))
	SA1->(DBSEEK(XFILIAL("SA1") + CLIENTE + LOJA))

	CSQL := "SELECT E4_YMAXDES FROM SE4010 "
	CSQL += "WHERE E4_CODIGO = '"+CONDICAO+"' AND D_E_L_E_T_ = '' "
	IF CHKFILE("_COND")
		DBSELECTAREA("_COND")
		DBCLOSEAREA()
	ENDIF
	TCQUERY CSQL ALIAS "_COND" NEW

	CPRECO_TABELA := U_FBUSCAPRECO( CCODTABELA, CPRODUTO, DTOS(DATE()), CLIENTE, LOJA)
	CPOLITICA 	  := nPolit

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ CALCULO DO PRECO E DESCONTO                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	WPRECO := CPRECO_TABELA
	NPRECO := (WPRECO * _COND->E4_YMAXDES)
	NPRECO := NPRECO * ((100 - CPOLITICA) /100)
	NPRECO := NPRECO + V_SEGURO //M->C5_VLRFRET

	AA_YRECR := Posicione("SA1",1,XFILIAL("SA1")+CLIENTE+LOJA,"A1_YRECR")

	// SO EXECUTA O DM NA TELA DE ORCAMENTO.
	IF UPPER(ALLTRIM(FUNNAME())) == "MATA415"
		IF (aa_YRECR = "2" .OR. aa_YRECR = "3") .AND. CEMPANT == "05"
			// abrindo o parametro na empresa atual.
			If chkfile("__SX6")
				DbSelectArea("__SX6")
				DbCloseArea()
			EndIf
			IF CEMPRESA = "01" .OR. CEMPRESA = "02"
				dbUseArea(.T.,, "SX6010","__SX6" , .T., .T.)
			ELSE
				dbUseArea(.T.,, "SX6050","__SX6" , .T., .T.)
			END IF
			dbSetIndex("SX6050")
			dbSetOrder(1)
			DbSelectArea("__SX6")
			DbSeek(xFilial("__SX6")+"MV_YRECR",.F.)
			AA_VAL_YRECR	:= VAL(ALLTRIM(__SX6->X6_CONTEUD))
			NPRECO		:= ROUND(NPRECO * AA_VAL_YRECR,2)
		ELSE
			AA_VAL_YRECR	:= 0
		END IF
	ELSE
		AA_VAL_YRECR	:= 0
	END IF

	NDESC 		:= Round(((ROUND(NPRECO,2) - _SPRECO_DIG)*100)/NPRECO,2) //RANI

RETURN(NDESC)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGeraNossoNumeroºAutor  ³Ranisses            º Data ³  13/03/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao utilizada para gerar NossoNumero		                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Fat/Fin                                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function fGeraNossoNumero(wTipo) // 1->ST / 2->BOL / 3->NF
	Local cSql	 := ""
	Local cWhere := ""
	Local cNumBco	 := ""

	// Gera nosso numero na LM para o banco banestes
	If cEmpAnt == "07" .And. Alltrim(SE1->E1_PORTADO) == "021"

		cNumBco := U_BIAF121()

	Else

		//Define a condição de filtro para busca e atualização da tabela SEE
		//Gera NossoNumero para Titulos de ST
		If wTipo == "1"
			If cEmpAnt == "01"
				cWhere += " AND EE_CODIGO	= '001'		 "
				cWhere += "	AND EE_AGENCIA	= '34312'	 "
				cWhere += " AND EE_CONTA	= '55.099-X' "
				cWhere += " AND	EE_SUBCTA	= '002' 	 "
			ElseIf cEmpAnt == "05"
				cWhere += "	AND EE_CODIGO	= '001'		 "
				cWhere += "	AND	EE_AGENCIA	= '34312'	 "
				cWhere += " AND EE_CONTA	= '5.777-0'	 "
				cWhere += " AND EE_SUBCTA 	= '002' 	 "
			ElseIf cEmpAnt == "07"
				cWhere += "	AND EE_CODIGO	= '001'		 "
				cWhere += "	AND	EE_AGENCIA	= '34312'	 "
				cWhere += " AND	EE_CONTA	= '152862'	 "
				cWhere += " AND	EE_SUBCTA	= '001'		 "
			ElseIf cEmpAnt == "14"
				cWhere += " AND EE_CODIGO	= '001'		 "
				cWhere += "	AND	EE_AGENCIA	= '3431'	 "
				cWhere += " AND	EE_CONTA	= '48755'	 "
				cWhere += " AND	EE_SUBCTA	= '002'		 "
			EndIf

			//Gera NossoNumero para Titulos de Contratos Tipo BOL
		ElseIf wTipo == "2"
			If cempant == "01"
				cWhere += " AND	EE_CODIGO	= '001'		 "
				cWhere += "	AND	EE_AGENCIA	= '34312'	 "
				cWhere += " AND	EE_CONTA	= '55.097-3' "
				cWhere += " AND	EE_SUBCTA	= '005'		 "
			ElseIf cempant == "05"
				cWhere += " AND	EE_CODIGO	= '001'		 "
				cWhere += "	AND	EE_AGENCIA	= '34312'    "
				cWhere += " AND	EE_CONTA 	= '5.666-9'	 "
				cWhere += " AND	EE_SUBCTA 	= '003'		 "
			ElseIf cempant == "07"
				cWhere += " AND	EE_CODIGO	= '001'		 "
				cWhere += "	AND	EE_AGENCIA	= '34312'	 "
				cWhere += " AND	EE_CONTA 	= '52868'	 "
				cWhere += " AND	EE_SUBCTA 	= '004'		 "
			ElseIf cEmpAnt == "14"
				cWhere += " AND EE_CODIGO	= '001'		 "
				cWhere += "	AND	EE_AGENCIA	= '3431'	 "
				cWhere += " AND	EE_CONTA	= '48755'	 "
				cWhere += " AND	EE_SUBCTA	= '002'		 "
			EndIf

			//Gera NossoNumero para Titulos NF
		ElseIf wTipo == "3"
			If cEmpAnt == "01"		//Bianocgres
				cWhere += "	AND EE_CODIGO	= '001'		 "
				cWhere += "	AND	EE_AGENCIA	= '34312'	 "
				cWhere += "	AND	EE_CONTA	= '55.097-3' "
				cWhere += "	AND	EE_SUBCTA	= '007'		 "
			ElseIf cEmpAnt == "05"	//Incesa
				cWhere += " AND EE_CODIGO	= '001'		 "
				cWhere += "	AND	EE_AGENCIA	= '34312'	 "
				cWhere += "	AND	EE_CONTA	= '5.666-9'	 "
				cWhere += "	AND	EE_SUBCTA	= '005'		 "
			ElseIf cEmpAnt == "07"	//LM
				cWhere += "	AND EE_CODIGO	= '001'		 "
				cWhere += "	AND	EE_AGENCIA	= '34312'	 "
				cWhere += "	AND	EE_CONTA	= '52868'	 "
				cWhere += "	AND	EE_SUBCTA	= '001'		 "
			ElseIf cEmpAnt == "14"
				cWhere += "	AND EE_CODIGO	= '001'		 "
				cWhere += "	AND	EE_AGENCIA	= '3431'	 "
				cWhere += " AND	EE_CONTA	= '48755'	 "
				cWhere += " AND	EE_SUBCTA	= '002'		 "
			EndIf
		EndIf

		//Busca o Convenio e Sequencial na tabela SEE
		cSql := ""
		cSql += " SELECT RTRIM(EE_YCOVLID) AS CONVENIO, RTRIM(EE_FAXATU) AS SEQUENCIAL"
		cSql += " FROM " + RETSQLNAME("SEE") + " AS SEE	"
		cSql += " WHERE D_E_L_E_T_ = '' 				"
		cSql += cWhere
		If chkfile("_SEE")
			dbSelectArea("_SEE")
			dbCloseArea()
		EndIf
		TCQUERY cSQL ALIAS "_SEE" NEW

		//Monta o NOSSONUMERO com o Convenio + Sequencial
		cNumBco := Alltrim(_SEE->CONVENIO) + Substr(Soma1(_SEE->SEQUENCIAL),3,10)

		//Atualiza Sequencial NOSSONUMERO
		cSql := ""
		cSql +=	" UPDATE "+RetSqlName("SEE")+" SET EE_FAXATU = '"+Soma1(_SEE->SEQUENCIAL)+"'"
		cSql += " WHERE	D_E_L_E_T_ = '' "
		cSql += cWhere
		TCSQLExec(CSQL)

		If chkfile("_SEE")
			dbSelectArea("_SEE")
			dbCloseArea()
		EndIf

	EndIf

Return(cNumBco)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RetData         ºAutor  ³Tiago Rossini       º Data ³  16/03/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna data no Formato DDMMYYYY      		                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Financeiro                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function RetData(dDate)
	Local cRet := ""
	cRet := SUBSTR(GRAVADATA(dDate,.F.),1,4)+STR(YEAR(dDate),4)
Return(cRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RetHora         ºAutor  ³Tiago Rossini       º Data ³  16/03/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna hora no Formato HHMMSS         		                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Financeiro                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function RetHora(cHora)
	Local cRet := ""
	cRet := SubStr(cHora,1,2) + SubStr(cHora,4,2) + SubStr(cHora,7,2)
Return(cRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RetBanco        ºAutor  ³Tiago Rossini       º Data ³  16/03/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna numero do banco para pagamento   		                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Financeiro                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function RetBanco(cOpe)
	Local cRet := ""
	cRet := If(cOpe $ "01/03/05/07/08/41/43", SA2->A2_BANCO, Space(3))
Return(cRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RetAgen         ºAutor  ³Tiago Rossini       º Data ³  16/03/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna numero da agencia do banco para pagamento   		        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Financeiro                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function RetAgen(cOpe)
	Local cRet := ""
	cRet := If(cOpe $ "01/03/05/07/08/41/43", StrZero(Val(SA2->A2_AGENCIA),5), Space(5))
Return(cRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RetNumCC        ºAutor  ³Tiago Rossini       º Data ³  16/03/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna numero da conta corrente do banco para pagamento   		º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Financeiro                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function RetNumCC(cOpe)
	Local cRet := ""
	Local nTam := If (cOpe $ "41/43", 13, 12)
	cRet := If(cOpe $ "01/03/05/07/08/41/43", StrZero(Val(StrTran(AllTrim(SA2->A2_NUMCON) + SA2->A2_YDVCTA,".","")),nTam), Space(nTam))
Return(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³COD_BAR_LIN     ºAUTOR  ³TIAGO ROSSINI       º DATA ³  16/03/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESC.     ³RETORNA O CODIGO DE BARRA OU A LINHA DIGITADA CNAB BANESTE TED/DOCº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³FINANCEIRO                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
USER FUNCTION COD_BAR_LIN()
	LOCAL CRET := ""
	IF ALLTRIM(SE2->E2_CODBAR) <> ""
		CRET := ALLTRIM(SE2->E2_CODBAR) + SPACE(-(LEN(ALLTRIM(SE2->E2_CODBAR))-49))
	ELSEIF ALLTRIM(SE2->E2_YLINDIG) <> ""
		CRET := ALLTRIM(SE2->E2_YLINDIG) + SPACE(-(LEN(ALLTRIM(SE2->E2_YLINDIG))-49))
	ELSE
		CRET := SPACE(49)
	END IF
RETURN(CRET)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fCalculaParcela ºAutor  ³Ranisses A. Corona  º Data ³  01/10/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao utilizada para calcular o valor das parcelas, acumulando	º±±
±±º          ³os valores do SE1 com o valor a ser Faturado no dia.         		º±±
±±º          ³Retorno := .T. (Parcela Menor que que o parametro MV_YLIMFAT      º±±
±±º          ³           .F. (Parcela Maior que que o parametro MV_YLIMFAT      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Faturamento                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function fCalculaParcela(cCli,cLoja,nVlMerc,cCond,nVlIPI,dData,nVlIcmRet) //Vlr Merc.,Cond. Pagto,Vlr IPI,Data Emissao,Vlr ICMS Retido
	Local 	aParc 	:= {}
	Local	lAlt	:= .F. //Falso Parcela MAIOR que o Parametro / Verdadeiro Parcelo MENOR que o parametro
	Local 	nLimite	:= GETMV("MV_YLIMFAT")
	Local 	cSql	:= ""
	Local 	Enter 	:= CHR(13)+CHR(10)
	Local	nCGC	:= Posicione("SA1",1,xFilial("SA1")+cCli+cLoja,"A1_CGC")
	Local nX

	Public	nQtdTit	:= 0 //Retorna a quantidade de titulos emitidos

	//1.1 - Seleciona os todos os Titulos em aberto, com emissao do dia, que poderao ser utilizados na geracao de Faturas
	If Subs(nCGC,1,8) $ ("27179753_05153562_08086524")
		cSql := "SELECT	A.E1_VENCORI AS VENC, SUM(A.E1_VALOR) E1_VALOR	" + Enter
	Else
		cSql := "SELECT	A.E1_VENCTO AS VENC,  SUM(A.E1_VALOR) E1_VALOR	" + Enter
	EndIf
	cSql += "FROM " + retsqlname("SE1") + " A, "+retsqlname("SA1") + " B	" + Enter
	cSql += "WHERE	A.E1_FILIAL  = '"+xFilial("SE1")+"' 	AND " + Enter
	cSql += " 		B.A1_FILIAL  = '"+xFilial("SA1")+"' 	AND " + Enter
	cSql += " 		A.E1_CLIENTE = '"+cCli+"' 				AND " + Enter
	cSql += " 		A.E1_LOJA    = '"+cLoja+"' 	   			AND " + Enter
	cSql += " 		A.E1_EMISSAO = '"+Dtos(dDataBase)+"'	AND " + Enter //Verifica sempre os titulos emitidos no dia
	cSql += " 		A.E1_NATUREZ NOT IN ('1131','1230')		AND " + Enter
	cSql += " 		A.E1_YFORMA  =  '1'			AND " + Enter
	cSql += " 		A.E1_SITUACA <> '1'			AND " + Enter
	cSql += " 		A.E1_TIPO    = 'NF'			AND " + Enter
	cSql += " 		A.E1_SALDO   > 0			AND " + Enter
	cSql += " 		A.E1_CLIENTE = B.A1_COD		AND " + Enter
	cSql += " 		A.E1_LOJA    = B.A1_LOJA	AND " + Enter
	cSql += " 		B.A1_YGERFAT = 'S'			AND " + Enter
	cSql += " 		A.D_E_L_E_T_ = ''			AND " + Enter
	cSql += " 		B.D_E_L_E_T_ = ''				" + Enter
	If Subs(nCGC,1,8) $ ("27179753_05153562_08086524")
		cSql += "GROUP BY E1_VENCORI					" + Enter
		cSql += "ORDER BY E1_VENCORI					" + Enter
	Else
		cSql += "GROUP BY E1_VENCTO						" + Enter
		cSql += "ORDER BY E1_VENCTO						" + Enter
	EndIf

	If chkfile("TRB")
		dbSelectArea("TRB")
		dbCloseArea()
	EndIf
	TCQUERY cSql ALIAS "TRB" NEW

	//1.0 - Seleciona a quantidade de Titulos emitidos no dia
	cSql := "SELECT	COUNT(*) QUANT " + Enter
	cSql += "FROM " + retsqlname("SE1") + " A, "+retsqlname("SA1") + " B	" + Enter
	cSql += "WHERE	A.E1_FILIAL  = '"+xFilial("SE1")+"' 	AND " + Enter
	cSql += " 		B.A1_FILIAL  = '"+xFilial("SA1")+"' 	AND " + Enter
	cSql += " 		A.E1_CLIENTE = '"+cCli+"' 				AND " + Enter
	cSql += " 		A.E1_LOJA    = '"+cLoja+"' 	   			AND " + Enter
	cSql += " 		A.E1_EMISSAO = '"+Dtos(dDataBase)+"'	AND " + Enter //Verifica sempre os titulos emitidos no dia
	cSql += " 		A.E1_NATUREZ NOT IN ('1131','1230')		AND " + Enter
	cSql += " 		A.E1_YFORMA  =  '1'			AND " + Enter
	cSql += " 		A.E1_SITUACA <> '1'			AND " + Enter
	cSql += " 		A.E1_TIPO    = 'NF'			AND " + Enter
	cSql += " 		A.E1_SALDO   > 0			AND " + Enter
	cSql += " 		A.E1_CLIENTE = B.A1_COD		AND " + Enter
	cSql += " 		A.E1_LOJA    = B.A1_LOJA	AND " + Enter
	cSql += " 		B.A1_YGERFAT = 'S'			AND " + Enter
	cSql += " 		A.D_E_L_E_T_ = ''			AND " + Enter
	cSql += " 		B.D_E_L_E_T_ = ''				" + Enter
	If chkfile("_SE1")
		dbSelectArea("_SE1")
		dbCloseArea()
	EndIf
	TCQUERY cSql ALIAS "_SE1" NEW

	nQtdTit	:= _SE1->QUANT

	//1.2 - Gera os titulos da NF provisoriamente para acumular com os valores acima.
	aParc	:= Condicao(nVlMerc,cCond,nVlIPI,dData,nVlIcmRet)

	//Verifica se o Faturamento tem ICMS ST, pois devera considerar a partir do Segundo Titulo
	If nVlIcmRet > 0
		//Verificar se exite mesmo vencimento, somando os valores
		For nX := 2 To Len(aParc)
			dbSelectArea("TRB")
			dbGotop()
			While !Eof()
				If STOD(TRB->VENC) ==  aParc[nX,1]
					aParc[nX,2]	:= aParc[nX,2] + TRB->E1_VALOR
				EndIf
				DbSkip()
			Enddo
		Next nX

		//Verifica se o valor e menor que o parametro MV_YLIMFAT = R$ 300,00
		For nX := 2	To Len(aParc)
			If aParc[nX,2] <= nLimite
				lAlt := .T.
			EndIf
		Next nX

	Else
		//Verificar se exite mesmo vencimento, somando os valores
		For nX := 1 To Len(aParc)
			dbSelectArea("TRB")
			dbGotop()
			While !Eof()
				If STOD(TRB->VENC) ==  aParc[nX,1]
					aParc[nX,2]	:= aParc[nX,2] + TRB->E1_VALOR
				EndIf
				DbSkip()
			Enddo
		Next nX

		//Verifica se o valor e menor que o parametro MV_YLIMFAT = R$ 300,00
		For nX := 1  To Len(aParc)
			If aParc[nX,2] <= nLimite
				lAlt := .T.
			EndIf
		Next nX
	EndIf

Return(lAlt)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ fGeraFatura    ºAUTOR  ³ BRUNO MADALENO     º DATA ³  05/10/09   º±±
±±º          ³                ºALTER. ³ RANISSES A. CORONA º DATA ³  06/10/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESC.     ³ GERA ARRAY DOS TITULOS COM MESMO VENCIMENTO, PARA GERACAO DE     º±±
±±º          ³ FATURAS.                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ Financeiro                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

USER FUNCTION fGeraFatura(dtIni,dtFim)

	Local oObj := TAFMovimentoRemessaReceber():New()
	Local I
	Local r
	Local n

	PRIVATE cQuery			:= ""
	PRIVATE ENTER			:= CHR(13)+CHR(10)
	PRIVATE NUMERO_TITULO	:= ""
	PRIVATE A_FATURA 		:= {}
	PRIVATE A_VENCIMENTO	:= {}
	PRIVATE SFLAG			:= "NAO"

	// GERANDO OS TUTULOS PARA COMPOR A FATURA
	cQuery := "SELECT	A.E1_FILIAL, C.F2_YSUBTP, A.E1_PREFIXO, A.E1_NUM, A.E1_PARCELA, 	" + Enter
	cQuery += "			A.E1_TIPO, A.E1_NATUREZ, A.E1_CLIENTE, A.E1_LOJA, A.E1_NOMCLI, 		" + Enter
	cQuery += "			A.E1_EMISSAO, A.E1_VENCTO, A.E1_VENCREA, A.E1_VALOR, 				" + Enter
	cQuery += "			A.E1_EMIS1, A.E1_SITUACA, A.E1_SALDO, A.E1_VENCORI, 				" + Enter
	cQuery += "			A.E1_MOEDA, A.E1_FATURA, A.E1_OCORREN, A.E1_YUFCLI, A.E1_YBAIDEL, A.E1_YRECR, 										" + Enter
	cQuery += "			A.E1_VEND1, A.E1_VEND2, A.E1_VEND3, A.E1_VEND4, A.E1_VEND5, A.E1_VLCRUZ, A.E1_PORCJUR, A.E1_STATUS, A.E1_ORIGEM, 	" + Enter
	cQuery += "			A.E1_OK, A.E1_FATPREF, A.E1_DTFATUR, A.E1_YFORMA, A.E1_PORTADO, B.A1_YGERFAT, A.E1_YEMP, A.E1_PEDIDO, A.R_E_C_N_O_,	" + Enter
	cQuery += "			(SELECT COUNT(*) 							" + Enter
	cQuery += "			 FROM "+RetSqlName("SE1")+"	SE1				" + Enter
	cQuery += "			 WHERE	SE1.E1_CLIENTE	= A.E1_CLIENTE	AND " + Enter
	cQuery += "							SE1.E1_LOJA			= A.E1_LOJA		AND " + Enter
	cQuery += "							SE1.E1_PREFIXO	= A.E1_PREFIXO	AND " + Enter
	cQuery += "							SE1.E1_NUM			= A.E1_NUM		AND " + Enter
	cQuery += "							SE1.D_E_L_E_T_	= '') QUANT			" + Enter
	cQuery += "FROM "+RetSqlName("SE1") + " A, "+RetSqlName("SA1") + " B, "+RetSqlName("SF2")+" C	" + Enter
	cQuery += "WHERE	A.E1_FILIAL  = '"+xFilial("SE1")+"'		AND " + Enter
	cQuery += " 		B.A1_FILIAL  = '"+xFilial("SA1")+"'		AND " + Enter
	cQuery += " 		C.F2_FILIAL  = '"+xFilial("SF2")+"'		AND " + Enter
	cQuery += " 		A.E1_EMISSAO >= '" + Dtos(dtIni) + "' 	AND " + Enter
	cQuery += " 		A.E1_EMISSAO <= '" + Dtos(dtFim) + "' 	AND " + Enter
	//cQuery += " 		A.E1_NATUREZ NOT IN ('1131','1230')		AND " + Enter  //DESATIVADO EM 10/05/13
	cQuery += " 		A.E1_NATUREZ <> '1131'			AND " + Enter  //ATIVADO EM 10/05/13
	//cQuery += " 		A.E1_CLIENTE IN ('000153')		AND " + Enter  //UTILIZADO APENAS PARA TESTES
	cQuery += " 		A.E1_YFORMA  =  '1'				AND " + Enter
	cQuery += " 		A.E1_SITUACA <> '1'				AND " + Enter
	cQuery += " 		A.E1_TIPO    = 'NF'				AND " + Enter
	cQuery += " 		A.E1_YCLASSE NOT IN ('1','2')	AND " + Enter  //ATIVADO EM 10/05/13
	cQuery += " 		A.E1_SALDO   > 0				AND " + Enter

	cQuery += " 		A.E1_CLIENTE = B.A1_COD			AND " + Enter
	cQuery += " 		A.E1_LOJA    = B.A1_LOJA		AND " + Enter
	cQuery += " 		B.A1_GRPVEN  <> '000010'		AND " + Enter // 23/05/2016 - OS 1649-16 - Mikaelly Gentil Valadão Viana

	cQuery += " 		A.E1_PREFIXO = C.F2_SERIE		AND " + Enter
	cQuery += " 		A.E1_NUM     = C.F2_DOC 		AND " + Enter
	cQuery += " 		A.E1_CLIENTE = C.F2_CLIENTE		AND " + Enter
	cQuery += " 		A.E1_LOJA    = C.F2_LOJA		AND " + Enter
	
	If Alltrim(cEmpAnt) == '01' //NAO GERA FATURA PARA CLIENTES FIDC
		cQuery += " 		B.A1_YCDGREG <> '000029'		AND " + Enter 
	EndIf
	
	cQuery += " 		B.A1_YGERFAT = 'S'				AND " + Enter
	cQuery += " 		A.D_E_L_E_T_ = ''				AND " + Enter
	cQuery += " 		B.D_E_L_E_T_ = ''				AND	" + Enter
	cQuery += " 		C.D_E_L_E_T_ = ''					" + Enter
	//cQuery += "ORDER BY E1_NUM, E1_PARCELA 				" + Enter
	//cQuery += "ORDER BY E1_CLIENTE, E1_NUM, E1_PARCELA 	" + Enter
	cQuery += "ORDER BY E1_CLIENTE, QUANT DESC, E1_PREFIXO, E1_NUM, E1_PARCELA 	" + Enter
	IF CHKFILE("_TITULOS")
		DBSELECTAREA("_TITULOS")
		DBCLOSEAREA()
	ENDIF
	TCQUERY cQuery ALIAS "_TITULOS" NEW

	A_VENCIMENTO	:= {}
	A_FATURA 		:= ARRAY(1000,0) // MONTANDO O ARRAY
	IF ! _TITULOS->(EOF())
		NUMERO_TITULO := _TITULOS->E1_NUM
	END IF

	ProcRegua(0)

	_QUANT_FATURA := 1
	DO WHILE ! _TITULOS->(EOF())

		IncProc("Selecionando Titulos....")

		//Elimina Títulos FIDC LM
		If Alltrim(cEmpAnt) == '07' .And. U_fVlFIDCLM( _TITULOS->E1_PEDIDO)
			_TITULOS->(DBSKIP())
			Loop
		EndIf

		//Não considera os títulos de ST gerados para NF de Bonificação - ATIVADO EM 21/01/14
		If Alltrim(_TITULOS->F2_YSUBTP) == "B" .And. Alltrim(_TITULOS->E1_NATUREZ) == "1230"
			_TITULOS->(DBSKIP())
			Loop
		EndIf

		If dtFim >= dDataBase

			If !oObj:IsGreater24Hour(_TITULOS->E1_PREFIXO, _TITULOS->E1_NUM, _TITULOS->E1_CLIENTE, _TITULOS->E1_LOJA, _TITULOS->E1_PARCELA)


				_TITULOS->(DBSKIP())

				Loop

			EndIf

		EndIf

		IF NUMERO_TITULO <> _TITULOS->E1_NUM
			// Rodando so a primeiro vez
			IF LEN(A_FATURA[_QUANT_FATURA] ) == 0 // SE FOR A PRIMEIRA TITULO GRAVA SEM PROCURAR
				FOR I := 1 TO LEN(A_VENCIMENTO)
					AADD(A_FATURA[_QUANT_FATURA] , {A_VENCIMENTO[I][1], A_VENCIMENTO[I][2], A_VENCIMENTO[I][3], "", A_VENCIMENTO[I][5], A_VENCIMENTO[I][6], A_VENCIMENTO[I][7], A_VENCIMENTO[I][8], A_VENCIMENTO[I][9], A_VENCIMENTO[I][10] } )
				NEXT

				/*	
				J := 1
				IF LEN(A_FATURA[_QUANT_FATURA] ) == 0 // SE FOR A PRIMEIRA TITULO GRAVA SEM PROCURAR
					FOR I := 1 TO LEN(A_VENCIMENTO)
				SPOS  := ASCAN(A_FATURA[J],{|X| X[1]== A_VENCIMENTO[I][1] } )	// POSICAO 1 E A CHAVE (VENCIMENTO+TITULO+CLIENTE+LOJA					
						IF SPOS == 0
				AADD(A_FATURA[_QUANT_FATURA] , {A_VENCIMENTO[I][1], A_VENCIMENTO[I][2], A_VENCIMENTO[I][3], "", A_VENCIMENTO[I][5], A_VENCIMENTO[I][6], A_VENCIMENTO[I][7], A_VENCIMENTO[I][8], A_VENCIMENTO[I][9], "" } )
						ELSE
				A_FATURA[J][SPOS][3]  := A_FATURA[J][SPOS][3] + ',' +	A_VENCIMENTO[I][3]	//NUMERO 
				A_FATURA[J][SPOS][8]  := A_FATURA[J][SPOS][8] + 		A_VENCIMENTO[I][8]	//VALOR
				A_FATURA[J][SPOS][9]  := A_FATURA[J][SPOS][9] + ',' +	A_VENCIMENTO[I][9]	//R_E_C_N_O_
				A_FATURA[J][SPOS][10] := "SIM"
						ENDIF
					NEXT
				J += 1
				*/

				ELSE

					SFLAG	:= "NAO"
					J		:= 1
					DO WHILE LEN(A_FATURA[J]) <> 0
						FOR I := 1 TO LEN(A_VENCIMENTO)
							SPOS := ASCAN(A_FATURA[J],{|X| X[1]== A_VENCIMENTO[I][1]} )	// POSICAO 1 E A CHAVE (VENCIMENTO+TITULO+CLIENTE+LOJA
							IF SPOS <> 0
								LL := J
								SFLAG := "SIM"
								//EXIT
							END IF
						NEXT
						J += 1
					END DO

					// SE ENCONTROU O VENCIMENTO JA GRAVADO
					IF 	SFLAG = "SIM"
						J := LL
						//DO WHILE LEN(A_FATURA[J]) <> 0
						FOR I := 1 TO LEN(A_VENCIMENTO)
							SPOS  := ASCAN(A_FATURA[J],{|X| X[1]== A_VENCIMENTO[I][1] } )	// POSICAO 1 E A CHAVE (VENCIMENTO+TITULO+CLIENTE+LOJA
							IF SPOS <> 0
								//If Empty(Alltrim(A_FATURA[J][SPOS][4]))
								//	A_FATURA[J][SPOS][4] := A_VENCIMENTO[I][4]
								//EndIf
								A_FATURA[J][SPOS][3]  := A_FATURA[J][SPOS][3] + ',' +	A_VENCIMENTO[I][3]	//NUMERO
								A_FATURA[J][SPOS][8]  := A_FATURA[J][SPOS][8] + 		A_VENCIMENTO[I][8]	//VALOR
								A_FATURA[J][SPOS][9]  := A_FATURA[J][SPOS][9] + ',' +	A_VENCIMENTO[I][9]	//R_E_C_N_O_
								A_FATURA[J][SPOS][10] := "SIM"
							ELSE
								AADD(A_FATURA[J], {A_VENCIMENTO[I][1], A_VENCIMENTO[I][2], A_VENCIMENTO[I][3], "", A_VENCIMENTO[I][5], A_VENCIMENTO[I][6], A_VENCIMENTO[I][7], A_VENCIMENTO[I][8], A_VENCIMENTO[I][9],A_VENCIMENTO[I][10] } )
							END IF
						NEXT
						J += 1
						//END DO
					ELSE // SENÃO GERA UMA NOVA FATURA.
						FOR I := 1 TO LEN(A_VENCIMENTO)
							AADD(A_FATURA[_QUANT_FATURA+1] , {A_VENCIMENTO[I][1], A_VENCIMENTO[I][2], A_VENCIMENTO[I][3], "", A_VENCIMENTO[I][5], A_VENCIMENTO[I][6], A_VENCIMENTO[I][7], A_VENCIMENTO[I][8], A_VENCIMENTO[I][9],A_VENCIMENTO[I][10] } )
						NEXT
						_QUANT_FATURA += 1
					END IF

				END IF
				A_VENCIMENTO	:= {}
				NUMERO_TITULO	:= _TITULOS->E1_NUM
			ELSE

				If Len(A_VENCIMENTO) > 0
					//For I := 1 To Len(A_VENCIMENTO)
					SPOS := ASCAN(A_VENCIMENTO,{|X| X[1]== _TITULOS->E1_VENCTO+_TITULOS->E1_PREFIXO+_TITULOS->E1_CLIENTE+_TITULOS->E1_LOJA } )
					If SPOS == 0
						AADD(A_VENCIMENTO, {_TITULOS->E1_VENCTO+_TITULOS->E1_PREFIXO+_TITULOS->E1_CLIENTE+_TITULOS->E1_LOJA, _TITULOS->E1_PREFIXO, _TITULOS->E1_NUM, _TITULOS->E1_PARCELA, _TITULOS->E1_CLIENTE, _TITULOS->E1_LOJA, _TITULOS->E1_VENCTO, _TITULOS->E1_VALOR, "'"+Alltrim(Str(_TITULOS->R_E_C_N_O_))+"'", " "} )
					Else
						A_VENCIMENTO[SPOS][8]   := A_VENCIMENTO[SPOS][8] + 	  _TITULOS->E1_VALOR						//VALOR
						A_VENCIMENTO[SPOS][9]   := A_VENCIMENTO[SPOS][9] + ',' + "'"+Alltrim(Str(_TITULOS->R_E_C_N_O_))+"'"//R_E_C_N_O_
						A_VENCIMENTO[SPOS][10]  := "SIM"
						//[1]	_TITULOS->E1_VENCTO+_TITULOS->E1_PREFIXO+_TITULOS->E1_CLIENTE+_TITULOS->E1_LOJA,
						//[2]	_TITULOS->E1_PREFIXO,
						//[3]	_TITULOS->E1_NUM,
						//[4]	_TITULOS->E1_PARCELA,
						//[5]	_TITULOS->E1_CLIENTE,
						//[6]	_TITULOS->E1_LOJA,
						//[7]	_TITULOS->E1_VENCTO,
						//[8]	_TITULOS->E1_VALOR,
						//[9]	Alltrim(Str(_TITULOS->R_E_C_N_O_))
					EndIf
					// Next
				Else
					AADD(A_VENCIMENTO, {_TITULOS->E1_VENCTO+_TITULOS->E1_PREFIXO+_TITULOS->E1_CLIENTE+_TITULOS->E1_LOJA, _TITULOS->E1_PREFIXO, _TITULOS->E1_NUM, _TITULOS->E1_PARCELA, _TITULOS->E1_CLIENTE, _TITULOS->E1_LOJA, _TITULOS->E1_VENCTO, _TITULOS->E1_VALOR, "'"+Alltrim(Str(_TITULOS->R_E_C_N_O_))+"'"," "} )
				EndIf

				_TITULOS->(DBSKIP())

			END IF
		END DO

		SFLAG := "NAO"
		J := 1
		DO WHILE LEN(A_FATURA[J]) <> 0
			FOR I := 1 TO LEN(A_VENCIMENTO)
				SPOS := ASCAN(A_FATURA[J],{|X| X[1]==  A_VENCIMENTO[I][1] }) // POSICAO 1 E A CHAVE (VENCIMENTO+PREFIXO+CLIENTE+LOJA
				IF SPOS <> 0
					LL := J
					SFLAG := "SIM"
				END IF
			NEXT
			J += 1
		END DO

		// SE ENCONTROU O VENCIMENTO JA GRAVADO
		IF 	SFLAG = "SIM"
			J := LL
			//DO WHILE LEN(A_FATURA[J]) <> 0
			FOR I := 1 TO LEN(A_VENCIMENTO)
				SPOS := ASCAN(A_FATURA[J],{|X| X[1]==  A_VENCIMENTO[I][1]})	 // POSICAO 1 E A CHAVE (VENCIMENTO+PREFIXO+CLIENTE+LOJA
				IF SPOS <> 0
					//If Empty(Alltrim(A_FATURA[J][SPOS][4]))
					//	A_FATURA[J][SPOS][4] := A_VENCIMENTO[I][4]
					//EndIf
					A_FATURA[J][SPOS][3]  := A_FATURA[J][SPOS][3] + ',' + A_VENCIMENTO[I][3]	//NUMERO
					A_FATURA[J][SPOS][8]  := A_FATURA[J][SPOS][8] + 	  A_VENCIMENTO[I][8]	//VALOR
					A_FATURA[J][SPOS][9]  := A_FATURA[J][SPOS][9] + ',' + A_VENCIMENTO[I][9]	//R_E_C_N_O_
					A_FATURA[J][SPOS][10] := "SIM"
				ELSE
					AADD(A_FATURA[J], {A_VENCIMENTO[I][1], A_VENCIMENTO[I][2], A_VENCIMENTO[I][3], "", A_VENCIMENTO[I][5], A_VENCIMENTO[I][6], A_VENCIMENTO[I][7], A_VENCIMENTO[I][8], A_VENCIMENTO[I][9],A_VENCIMENTO[I][10] } )
				END IF
			NEXT
			J += 1
			//END DO


		ELSE // SENÃO GERA UMA NOVA FATURA.
			FOR I := 1 TO LEN(A_VENCIMENTO)
				AADD(A_FATURA[_QUANT_FATURA+1] , {A_VENCIMENTO[I][1], A_VENCIMENTO[I][2], A_VENCIMENTO[I][3], "", A_VENCIMENTO[I][5], A_VENCIMENTO[I][6], A_VENCIMENTO[I][7], A_VENCIMENTO[I][8], A_VENCIMENTO[I][9],A_VENCIMENTO[I][10] } )
			NEXT
		END IF

		//CORRIGE PARCELA
		For n := 1 To Len(A_FATURA)
			If Len(A_FATURA[n]) > 0
				For r := 1 to Len(A_FATURA[n])
					If r == 1
						nParc := 'A'
					Else
						nParc := Soma1(nParc,1,.T.)
					EndIf
					A_FATURA[n][r][4] := nParc
				Next
			Else
				Exit
			EndIf
		Next

		RETURN(A_FATURA)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ DigitoRR         ³ Ranisses A. Corona º Data ³  29/06/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina para calcular Digito verificador do Modulo11		    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Financeiro                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DigitoRR(nCart,cStr)
	Local i, nMult	:= 2,nModulo := 0, cChar
	Local nResult 	:= ""

	cStr := AllTrim(nCart+cStr) //Monta string para calculo do Digito Verificador
	For i := Len(cStr) to 1 Step -1
		cChar := Substr(cStr,i,1)
		if isAlpha(cChar)
			Help(" ", 1, "ONLYNUM")
			Return .f.
		endif
		nModulo += Val(cChar)*nMult
		nMult:= if(nMult==7,2,nMult+1)
	Next

	nRest := nModulo % 11

	If nRest == 0
		nRest := "0"
	ElseIf nRest == 1
		nRest := "P"
	Else
		nRest := 11-nRest
		nRest := Alltrim(Str(nRest))
	EndIf

	nResult := nRest

Return(nResult)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ EMAI_LIB         ³ MADALENO           º Data ³  11/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ EMAIL DA ROTINA DE LIBERACAO DO CONTAS A PAGAR E RECEBER   º±±
±±º          ³PARAMETRO:                                                  º±±
±±º          ³          C_TITULO                                          º±±
±±º          ³          C_ENVIA                                           º±±
±±º          ³          C_DESTI                                           º±±
±±º          ³          C_COPIA                                           º±±
±±º          ³          C_MENS                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP 8 - R4                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
USER FUNCTION EMAI_LIB(C_TITULO,C_ENVIA,C_DESTI,C_COPIA,C_MENS,C_ANEXO)
	Private lResult
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tenta conexao com o servidor de E-Mail ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CONNECT SMTP                         ;
		SERVER   GetMV("MV_RELSERV");	// Nome do servidor de e-mail = smtp.bra.terra.com.br
	ACCOUNT  GetMV("MV_RELACNT");	// Nome da conta a ser usada no e-mail = fulano
	PASSWORD GetMV("MV_RELPSW") ;	// Senha = senha
	RESULT   lResult				// Resultado da tentativa de conexão

	If !lResult
		MsgAlert(OemToAnsi("Erro de conexao com o servidor"))
	Else

		cEnvia 		:= C_ENVIA
		cRecebe 	:= C_DESTI
		cRecebeCC	:= C_COPIA
		cRecebeCO	:= ""
		cAssunto	:= C_TITULO
		cAnexos		:= C_ANEXO
		cMensagem := C_MENS

		//TEMPORARIO - RETIRAR NA PRODUÇÃO V12
		//cRecebe := "suporte.biancogres@facilesistemas.com.br"

		Send Mail From cEnvia ;        // Email do Emissor
		To cRecebe  ;                   // Email do(s) receptor(es)
		Subject cAssunto ;             // Assunto do Email
		Body cMensagem ;               // Mensagem
		Attachment cAnexos ;           // Anexa arquivos
		RESULT lOk                   // Verdadeiro se enviou,falso se nao

		DISCONNECT SMTP SERVER
	END IF
RETURN


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MontaSQLIN       ³ Fernando Rocha     º Data ³  01/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para montar string para ser utilizada em comandos   º±±
±±º          ³ SQL com IN                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Diversos                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User function MontaSQLIN(cString, cChar, nTam)
	Local aLista := STRTOKARR(Alltrim(cString), cChar)
	Local cLista := ""
	Local nCount := 0

	For nCount := 1 To Len(aLista)

		If cLista <> ""

			cLista +=","

		EndIf

		cLista += "'"+ PadR(aLista[nCount], nTam) +"'"

	Next

return(cLista)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ EstoqueEmpresa   ³ Ranisses A. Corona º Data ³  06/07/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Define a Empresa que o sistema ira busca o estoque         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Estoque                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User function EstoqueEmpresa(cCod,cLocal)
	Local cEmp := ""
	Local cSql := ""
	Local cAliasTmp1 := ""
	Local cAliasTmp2 := ""

	//Define a Empresa Destino
	If Alltrim(cLocal) == "01"
		cEmp := cEmpAnt
	ElseIf Alltrim(cLocal) == "6B"
		cEmp := "01"
	Else
		cAliasTmp1 := GetNextAlias()
		BeginSql Alias cAliasTmp1
			SELECT SUM(B2_QATU-B2_RESERVA) QUANT FROM SB2050 WHERE B2_COD = %Exp:Alltrim(cCod)% AND B2_LOCAL = %Exp:Alltrim(cLocal)% AND B2_QATU-B2_RESERVA > 0 AND %NOTDEL%
		EndSql
		If (cAliasTmp1)->QUANT > 0
			cEmp := "05"
			(cAliasTmp1)->(dbCloseArea())
		Else

			//Adicionado por Fernando/Facile em 01/12/2014 - projeto requisicao comum - incluindo a emrpesa 14 - VITCER
			(cAliasTmp1)->(dbCloseArea())
			BeginSql Alias cAliasTmp1
				SELECT SUM(B2_QATU-B2_RESERVA) QUANT FROM SB2140 WHERE B2_COD = %Exp:Alltrim(cCod)% AND B2_LOCAL = %Exp:Alltrim(cLocal)% AND B2_QATU-B2_RESERVA > 0 AND %NOTDEL%
			EndSql
			If (cAliasTmp1)->QUANT > 0
				cEmp := "14"
				(cAliasTmp1)->(dbCloseArea())
			Else

				cAliasTmp2 := GetNextAlias()
				BeginSql Alias cAliasTmp2
					SELECT SUM(B2_QATU-B2_RESERVA) QUANT FROM SB2010 WHERE B2_COD = %Exp:Alltrim(cCod)% AND B2_LOCAL = %Exp:Alltrim(cLocal)% AND B2_QATU-B2_RESERVA > 0 AND %NOTDEL%
				EndSql
				If (cAliasTmp2)->QUANT > 0
					cEmp := "01"
				Else
					cEmp := ""
				EndIf
				//Fecha area de trabalho
				(cAliasTmp2)->(dbCloseArea())

			EndIf
		EndIf
	EndIf

Return(cEmp)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ReplicaIndicador ³ Ranisses A. Corona º Data ³  01/08/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Replica o cadastro de Indicador nas Empresas               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Estoque                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ReplicaIndicador(__EMPRESA,cTipo,cCod)

	Local cPctProd		:= Posicione("SB1",1,xFilial("SB1")+cCod,"B1_YPCGMR3")
	Local cTipoProd		:= Posicione("SB1",1,xFilial("SB1")+cCod,"B1_TIPO")
	Local x


	cIndex  := ""
	cArq    := ""
	cInd    := ""


	DbSelectArea("SM0")
	If SM0->(DbSeek(__EMPRESA))

		cArq:="SBZ"+__EMPRESA
		DbSelectArea("SIX")
		DbSetOrder(1)
		DbSeek("SBZ")
		Do while .not. eof() .and. INDICE=="SBZ"
			cIndex+=cArq+SIX->ORDEM
			DbSkip()
		EndDo
		If chkfile("_SBZ")
			DbSelectArea("_SBZ")
			DbCloseArea()
		EndIf
		Use &cArq Alias "_SBZ" Shared New Via "TopConn"
		For x:=1 to 4 step 7
			cInd := Subs(cIndex,x,7)
			DbSetIndex(cInd)
		Next

		dbSelectArea("SBZ")
		dbSetOrder(1)
		dbSeek(xFilial("SBZ")+cCod,.F.)

		//Verificando se vai incluir ou alterar
		If cTipo == "I" //Incluir
			dbSelectArea("_SBZ")
			dbSetOrder(1)

			If dbSeek(xFilial("SBZ")+cCod,.F.)
				RecLock("_SBZ",.F.)
				If isInCallStack("MATA010") .or. funname() == "MATA010" .or. funname() == "WFPREPENV"
					_SBZ->BZ_YCOMUM		:= SBZ->BZ_YCOMUM
					_SBZ->BZ_GRTRIB		:= SBZ->BZ_GRTRIB
					_SBZ->BZ_YBLSCPC	:= SBZ->BZ_YBLSCPC

					If(funname() == "WFPREPENV")
						_SBZ->BZ_YMD := SBZ->BZ_YMD
					EndIf
				Else
					_SBZ->BZ_YCOMUM		:= M->BZ_YCOMUM
					_SBZ->BZ_GRTRIB		:= M->BZ_GRTRIB
					_SBZ->BZ_YBLSCPC	:= M->BZ_YBLSCPC
				EndIf

				//vinilico
				If (AllTrim(cPctProd) == 'J' .And. cTipoProd == 'PA')
					_SBZ->BZ_GRTRIB := '003'
					_SBZ->BZ_ORIGEM := '2'

					If (SUBSTR(__EMPRESA, 1, 2) == '13')
						_SBZ->BZ_ORIGEM := '1'
					EndIf
				EndIf

			Else

				CONOUT("ReplicaIndicador-SBZ: Empresa: " + __EMPRESA + " Produto: " + AllTrim(cCod))

				If isInCallStack("MATA010") .Or. FunName() == "MATA010" .Or. FunName() == "WFPREPENV" .Or. FunName() == "RPC" .Or. AllTrim(FunName()) == "PDMLOPRO"
					
					RecLock("_SBZ",.T.)
					//_SBZ->BZ_FILIAL		:= xFilial("SBZ")
					_SBZ->BZ_FILIAL		:= SPACE(2)
					_SBZ->BZ_COD		:= SBZ->BZ_COD

					//Gabriel Mafioletti - 10/07/2018 Ticket - 4054
					If SBZ->BZ_TIPO $ "#PA#PP#"
						Do Case
						Case SUBSTR(cEmpAnt,1,2) == "01"
							_SBZ->BZ_LOCPAD := "02"
						Case SUBSTR(cEmpAnt,1,2) == "05"
							_SBZ->BZ_LOCPAD := "04"
						OtherWise
							_SBZ->BZ_LOCPAD := SBZ->BZ_LOCPAD
						EndCase
					Else
						_SBZ->BZ_LOCPAD := SBZ->BZ_LOCPAD
					EndIf

					_SBZ->BZ_TE			:= SBZ->BZ_TE
					_SBZ->BZ_TS			:= SBZ->BZ_TS
					_SBZ->BZ_QE			:= SBZ->BZ_QE
					_SBZ->BZ_CUSTD		:= SBZ->BZ_CUSTD
					_SBZ->BZ_UCALSTD	:= SBZ->BZ_UCALSTD
					_SBZ->BZ_MCUSTD		:= SBZ->BZ_MCUSTD
					_SBZ->BZ_UCOM		:= SBZ->BZ_UCOM
					_SBZ->BZ_ESTFOR		:= SBZ->BZ_ESTFOR
					_SBZ->BZ_FORPRZ		:= SBZ->BZ_FORPRZ
					_SBZ->BZ_PE			:= SBZ->BZ_PE
					_SBZ->BZ_TIPE		:= SBZ->BZ_TIPE
					_SBZ->BZ_LM			:= SBZ->BZ_LM
					_SBZ->BZ_TOLER		:= SBZ->BZ_TOLER
					_SBZ->BZ_CONINI		:= SBZ->BZ_CONINI
					_SBZ->BZ_DATREF		:= SBZ->BZ_DATREF
					_SBZ->BZ_EMAX		:= SBZ->BZ_EMAX
					_SBZ->BZ_YSOLIC		:= SBZ->BZ_YSOLIC
					_SBZ->BZ_YLOCAL		:= SBZ->BZ_YLOCAL
					_SBZ->BZ_LOCALIZ	:= SBZ->BZ_LOCALIZ
					//Retirado por Wanisay em 28/03/16 conforme OS 1036-16
					//_SBZ->BZ_YATIVO		:= SBZ->BZ_YATIVO

					//Retirado por Wanisay a pedido da Marcela no dia 19/10/12 com o objetivo de não replicar este campo para as demais empresas pois ele é particular de cada uma delas.
					//_SBZ->BZ_YMD		:= SBZ->BZ_YMD
					IF SUBSTR(cEmpAnt,1,2) $  "01_05" .Or. Funname() == "WFPREPENV"
						_SBZ->BZ_EMIN		:= SBZ->BZ_EMIN
						_SBZ->BZ_LE			:= SBZ->BZ_LE
						_SBZ->BZ_ESTSEG		:= SBZ->BZ_ESTSEG
						_SBZ->BZ_YPOLIT		:= SBZ->BZ_YPOLIT
						_SBZ->BZ_YCOMUM		:= SBZ->BZ_YCOMUM
					ENDIF

					_SBZ->BZ_YMD 		:= SBZ->BZ_YMD
					_SBZ->BZ_YEMPENH 	:= SBZ->BZ_YEMPENH
					_SBZ->BZ_YOBS		:= SBZ->BZ_YOBS
					_SBZ->BZ_YAREA		:= SBZ->BZ_YAREA
					_SBZ->BZ_YDESC		:= SBZ->BZ_YDESC
					_SBZ->BZ_UPRC		:= SBZ->BZ_UPRC
					_SBZ->BZ_TIPOCQ		:= SBZ->BZ_TIPOCQ
					_SBZ->BZ_QB			:= SBZ->BZ_QB
					_SBZ->BZ_PICM		:= SBZ->BZ_PICM
					_SBZ->BZ_VLR_ICM	:= SBZ->BZ_VLR_ICM
					_SBZ->BZ_INT_ICM	:= SBZ->BZ_INT_ICM
					_SBZ->BZ_PICMRET	:= SBZ->BZ_PICMRET
					_SBZ->BZ_PICMENT	:= SBZ->BZ_PICMENT
					_SBZ->BZ_IPI		:= SBZ->BZ_IPI
					_SBZ->BZ_VLR_IPI	:= SBZ->BZ_VLR_IPI
					_SBZ->BZ_REDPIS		:= SBZ->BZ_REDPIS
					_SBZ->BZ_REDCOF		:= SBZ->BZ_REDCOF
					_SBZ->BZ_IRRF		:= SBZ->BZ_IRRF
					_SBZ->BZ_ORIGEM		:= SBZ->BZ_ORIGEM
					_SBZ->BZ_GRTRIB		:= SBZ->BZ_GRTRIB
					_SBZ->BZ_YMANUAL	:= SBZ->BZ_YMANUAL
					_SBZ->BZ_YCUSANT	:= SBZ->BZ_YCUSANT
					_SBZ->BZ_YDTANT		:= SBZ->BZ_YDTANT
					_SBZ->BZ_CODISS		:= SBZ->BZ_CODISS
					_SBZ->BZ_MARKUP		:= SBZ->BZ_MARKUP
					_SBZ->BZ_FECP		:= SBZ->BZ_FECP
					_SBZ->BZ_YTMPFAB	:= SBZ->BZ_YTMPFAB
					_SBZ->BZ_YTMPIND	:= SBZ->BZ_YTMPIND

					//vinilico
					If (AllTrim(cPctProd) == 'J' .And. cTipoProd == 'PA')
						_SBZ->BZ_GRTRIB := '003'
						_SBZ->BZ_ORIGEM := '2'

						If (SUBSTR(__EMPRESA, 1, 2) == '13')
							_SBZ->BZ_ORIGEM := '1'
						EndIf
					EndIf

				Else
					RecLock("_SBZ",.T.)
					//_SBZ->BZ_FILIAL		:= xFilial("SBZ")
					_SBZ->BZ_FILIAL		:= SPACE(2)
					_SBZ->BZ_COD		:= M->BZ_COD

					//Gabriel Mafioletti - 10/07/2018 Ticket - 4054
					If M->BZ_TIPO $ "#PA#PP#"
						Do Case
						Case SUBSTR(cEmpAnt,1,2) == "01"
							_SBZ->BZ_LOCPAD := "02"
						Case SUBSTR(cEmpAnt,1,2) == "05"
							_SBZ->BZ_LOCPAD := "04"
						OtherWise
							_SBZ->BZ_LOCPAD := M->BZ_LOCPAD
						EndCase
					Else
						_SBZ->BZ_LOCPAD := SBZ->BZ_LOCPAD
					EndIf

					_SBZ->BZ_TE			:= M->BZ_TE
					_SBZ->BZ_TS			:= M->BZ_TS
					_SBZ->BZ_QE			:= M->BZ_QE
					_SBZ->BZ_CUSTD		:= M->BZ_CUSTD
					_SBZ->BZ_UCALSTD	:= M->BZ_UCALSTD
					_SBZ->BZ_MCUSTD		:= M->BZ_MCUSTD
					_SBZ->BZ_UCOM		:= M->BZ_UCOM
					_SBZ->BZ_ESTFOR		:= M->BZ_ESTFOR
					_SBZ->BZ_FORPRZ		:= M->BZ_FORPRZ
					_SBZ->BZ_PE			:= M->BZ_PE
					_SBZ->BZ_TIPE		:= M->BZ_TIPE
					_SBZ->BZ_LM			:= M->BZ_LM
					_SBZ->BZ_TOLER		:= M->BZ_TOLER
					_SBZ->BZ_CONINI		:= M->BZ_CONINI
					_SBZ->BZ_DATREF		:= M->BZ_DATREF
					_SBZ->BZ_EMAX		:= M->BZ_EMAX
					_SBZ->BZ_YSOLIC		:= M->BZ_YSOLIC
					_SBZ->BZ_YLOCAL		:= M->BZ_YLOCAL
					_SBZ->BZ_LOCALIZ	:= M->BZ_LOCALIZ
					//Retirado por Wanisay em 28/03/16 conforme OS 1036-16
					//_SBZ->BZ_YATIVO		:= M->BZ_YATIVO
					_SBZ->BZ_YBLSCPC	:= M->BZ_YBLSCPC

					//Retirado por Wanisay a pedido da Marcela no dia 19/10/12 com o objetivo de não replicar este campo para as demais empresas pois ele é particular de cada uma delas.
					//_SBZ->BZ_YMD		:= M->BZ_YMD
					IF SUBSTR(cEmpAnt,1,2) $  "01_05"
						_SBZ->BZ_EMIN		:= M->BZ_EMIN
						_SBZ->BZ_LE			:= M->BZ_LE
						_SBZ->BZ_ESTSEG		:= M->BZ_ESTSEG
						_SBZ->BZ_YPOLIT		:= M->BZ_YPOLIT
						_SBZ->BZ_YCOMUM		:= M->BZ_YCOMUM
					ENDIF

					_SBZ->BZ_YMD 		:= SBZ->BZ_YMD
					_SBZ->BZ_YOBS		:= M->BZ_YOBS
					_SBZ->BZ_YAREA		:= M->BZ_YAREA
					_SBZ->BZ_YDESC		:= M->BZ_YDESC
					_SBZ->BZ_UPRC		:= M->BZ_UPRC
					_SBZ->BZ_TIPOCQ		:= M->BZ_TIPOCQ
					_SBZ->BZ_QB			:= M->BZ_QB
					_SBZ->BZ_PICM		:= M->BZ_PICM
					_SBZ->BZ_VLR_ICM	:= M->BZ_VLR_ICM
					_SBZ->BZ_INT_ICM	:= M->BZ_INT_ICM
					_SBZ->BZ_PICMRET	:= M->BZ_PICMRET
					_SBZ->BZ_PICMENT	:= M->BZ_PICMENT
					_SBZ->BZ_IPI		:= M->BZ_IPI
					_SBZ->BZ_VLR_IPI	:= M->BZ_VLR_IPI
					_SBZ->BZ_REDPIS		:= M->BZ_REDPIS
					_SBZ->BZ_REDCOF		:= M->BZ_REDCOF
					_SBZ->BZ_IRRF		:= M->BZ_IRRF
					_SBZ->BZ_ORIGEM		:= M->BZ_ORIGEM
					_SBZ->BZ_GRTRIB		:= M->BZ_GRTRIB
					_SBZ->BZ_YMANUAL	:= M->BZ_YMANUAL
					_SBZ->BZ_YCUSANT	:= M->BZ_YCUSANT
					_SBZ->BZ_YDTANT		:= M->BZ_YDTANT
					_SBZ->BZ_CODISS		:= M->BZ_CODISS
					_SBZ->BZ_MARKUP		:= M->BZ_MARKUP
					_SBZ->BZ_FECP		:= M->BZ_FECP
					_SBZ->BZ_YTMPFAB	:= M->BZ_YTMPFAB
					_SBZ->BZ_YTMPIND	:= M->BZ_YTMPIND

					//vinilico
					If (AllTrim(cPctProd) == 'J' .And. cTipoProd == 'PA')
						_SBZ->BZ_GRTRIB := '003'
						_SBZ->BZ_ORIGEM := '2'

						If (SUBSTR(__EMPRESA, 1, 2) == '13')
							_SBZ->BZ_ORIGEM := '1'
						EndIf
					EndIf

				Endif
			EndIf
		ElseIf cTipo == "A" //Altera
			dbSelectArea("_SBZ")
			dbSetOrder(1)
			//If dbSeek("01"+cCod,.F.)
			If dbSeek(xFilial("SBZ")+cCod,.F.)
				RecLock("_SBZ",.F.)
				If Funname() = "MATA010"
					IF SUBSTR(cEmpAnt,1,2) $  "01_05"
						_SBZ->BZ_YCOMUM	 := SBZ->BZ_YCOMUM
					ENDIF

					If(funname() == "WFPREPENV")
						_SBZ->BZ_YMD := SBZ->BZ_YMD
					EndIf
					_SBZ->BZ_GRTRIB	 := SBZ->BZ_GRTRIB
					_SBZ->BZ_YBLSCPC := SBZ->BZ_YBLSCPC
				Else
					IF SUBSTR(cEmpAnt,1,2) $  "01_05"
						_SBZ->BZ_YCOMUM	 := M->BZ_YCOMUM
					ENDIF
					_SBZ->BZ_GRTRIB	 := M->BZ_GRTRIB
					_SBZ->BZ_YBLSCPC := M->BZ_YBLSCPC
				EndIf

				//vinilico
				If (AllTrim(cPctProd) == 'J' .And. cTipoProd == 'PA')
					_SBZ->BZ_GRTRIB := '003'
					_SBZ->BZ_ORIGEM := '2'

					If (SUBSTR(__EMPRESA, 1, 2) == '13')
						_SBZ->BZ_ORIGEM := '1'
					EndIf
				EndIf

			Else
				RecLock("_SBZ",.T.)
				//_SBZ->BZ_FILIAL		:= SBZ->BZ_FILIAL
				_SBZ->BZ_FILIAL		:= SPACE(2)
				_SBZ->BZ_COD		:= SBZ->BZ_COD

				//Gabriel Mafioletti - 10/07/2018 Ticket - 4054
				If SBZ->BZ_TIPO $ "#PA#PP#"
					Do Case
					Case SUBSTR(cEmpAnt,1,2) == "01"
						_SBZ->BZ_LOCPAD := "02"
					Case SUBSTR(cEmpAnt,1,2) == "05"
						_SBZ->BZ_LOCPAD := "04"
					OtherWise
						_SBZ->BZ_LOCPAD := SBZ->BZ_LOCPAD
					EndCase
				Else
					_SBZ->BZ_LOCPAD := SBZ->BZ_LOCPAD
				EndIf

				_SBZ->BZ_TE			:= SBZ->BZ_TE
				_SBZ->BZ_TS			:= SBZ->BZ_TS
				_SBZ->BZ_QE			:= SBZ->BZ_QE
				_SBZ->BZ_CUSTD		:= SBZ->BZ_CUSTD
				_SBZ->BZ_UCALSTD	:= SBZ->BZ_UCALSTD
				_SBZ->BZ_MCUSTD		:= SBZ->BZ_MCUSTD
				_SBZ->BZ_UCOM		:= SBZ->BZ_UCOM
				_SBZ->BZ_ESTFOR		:= SBZ->BZ_ESTFOR
				_SBZ->BZ_FORPRZ		:= SBZ->BZ_FORPRZ
				_SBZ->BZ_PE			:= SBZ->BZ_PE
				_SBZ->BZ_TIPE		:= SBZ->BZ_TIPE
				_SBZ->BZ_LM			:= SBZ->BZ_LM
				_SBZ->BZ_TOLER		:= SBZ->BZ_TOLER
				_SBZ->BZ_CONINI		:= SBZ->BZ_CONINI
				_SBZ->BZ_DATREF		:= SBZ->BZ_DATREF
				_SBZ->BZ_EMAX		:= SBZ->BZ_EMAX
				_SBZ->BZ_YLOCAL		:= SBZ->BZ_YLOCAL
				_SBZ->BZ_LOCALIZ	:= SBZ->BZ_LOCALIZ
				//Retirado por Wanisay em 28/03/16 conforme OS 1036-16
				//_SBZ->BZ_YATIVO		:= SBZ->BZ_YATIVO
				_SBZ->BZ_YBLSCPC	:= SBZ->BZ_YBLSCPC
				_SBZ->BZ_YMD		:= SBZ->BZ_YMD
				_SBZ->BZ_YOBS		:= SBZ->BZ_YOBS
				_SBZ->BZ_YAREA		:= SBZ->BZ_YAREA
				_SBZ->BZ_YDESC		:= SBZ->BZ_YDESC
				_SBZ->BZ_UPRC		:= SBZ->BZ_UPRC
				_SBZ->BZ_TIPOCQ		:= SBZ->BZ_TIPOCQ
				_SBZ->BZ_QB			:= SBZ->BZ_QB
				_SBZ->BZ_PICM		:= SBZ->BZ_PICM
				_SBZ->BZ_VLR_ICM	:= SBZ->BZ_VLR_ICM
				_SBZ->BZ_INT_ICM	:= SBZ->BZ_INT_ICM
				_SBZ->BZ_PICMRET	:= SBZ->BZ_PICMRET
				_SBZ->BZ_PICMENT	:= SBZ->BZ_PICMENT
				_SBZ->BZ_IPI		:= SBZ->BZ_IPI
				_SBZ->BZ_VLR_IPI	:= SBZ->BZ_VLR_IPI
				_SBZ->BZ_REDPIS		:= SBZ->BZ_REDPIS
				_SBZ->BZ_REDCOF		:= SBZ->BZ_REDCOF
				_SBZ->BZ_IRRF		:= SBZ->BZ_IRRF
				_SBZ->BZ_ORIGEM		:= SBZ->BZ_ORIGEM
				_SBZ->BZ_GRTRIB		:= SBZ->BZ_GRTRIB
				_SBZ->BZ_YMANUAL	:= SBZ->BZ_YMANUAL
				_SBZ->BZ_YCUSANT	:= SBZ->BZ_YCUSANT
				_SBZ->BZ_YDTANT		:= SBZ->BZ_YDTANT
				_SBZ->BZ_CODISS		:= SBZ->BZ_CODISS
				_SBZ->BZ_MARKUP		:= SBZ->BZ_MARKUP
				_SBZ->BZ_FECP		:= SBZ->BZ_FECP
				_SBZ->BZ_YTMPFAB	:= SBZ->BZ_YTMPFAB
				_SBZ->BZ_YTMPIND	:= SBZ->BZ_YTMPIND

				IF SUBSTR(cEmpAnt,1,2) $  "01_05" .Or. Funname() == "WFPREPENV"
					_SBZ->BZ_EMIN		:= SBZ->BZ_EMIN
					_SBZ->BZ_LE			:= SBZ->BZ_LE
					_SBZ->BZ_ESTSEG		:= SBZ->BZ_ESTSEG
					_SBZ->BZ_YPOLIT		:= SBZ->BZ_YPOLIT
					_SBZ->BZ_YCOMUM		:= SBZ->BZ_YCOMUM
				ENDIF

				//vinilico
				If (AllTrim(cPctProd) == 'J' .And. cTipoProd == 'PA')
					_SBZ->BZ_GRTRIB := '003'
					_SBZ->BZ_ORIGEM := '2'

					If (SUBSTR(__EMPRESA, 1, 2) == '13')
						_SBZ->BZ_ORIGEM := '1'
					EndIf
				EndIf

			EndIf
		Else
			//Delete Biancogres
			CSQL := "UPDATE SBZ010 SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_  WHERE	BZ_COD = '"+cCod+"' AND D_E_L_E_T_ = '' "
			TCSQLEXEC(CSQL)

			//Delete Incesa
			CSQL := "UPDATE SBZ050 SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_  WHERE	BZ_COD = '"+cCod+"' AND D_E_L_E_T_ = '' "
			TCSQLEXEC(CSQL)

			//Delete LM
			CSQL := "UPDATE SBZ070 SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_  WHERE	BZ_COD = '"+cCod+"' AND D_E_L_E_T_ = '' "
			TCSQLEXEC(CSQL)

			//Delete ST Gestao
			CSQL := "UPDATE SBZ120 SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_  WHERE	BZ_COD = '"+cCod+"' AND D_E_L_E_T_ = '' "
			TCSQLEXEC(CSQL)

			//Delete Mundi
			CSQL := "UPDATE SBZ130 SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_  WHERE	BZ_COD = '"+cCod+"' AND D_E_L_E_T_ = '' "
			TCSQLEXEC(CSQL)

		EndIf

		MsUnlock()
		dbcommitAll()
		dbSelectArea("_SBZ")
		dbCloseArea()

	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ UPDSX3			      ³ Ranisses A. Corona º Data ³  15/08/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se existe algum campo no SX3 que nao existe na    º±±
±±º          ³ base de dados (SQL).                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Geral                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User function UPDSX3(Emp)

	RPCSetType(3)
	//RpcSetEnv( '01' , '01',,,"EST")
	RpcSetEnv( Emp , '01')

	//lRet := MsgBox("Deseja replicar o SX3 para as tabelas do Banco de Dados? ","Atencao","YesNo")

	If .T.

		__SetX31Mode(.F.)

		If Select("SZU") > 0
			SZU->(dbCloseArea())
		EndIf
		X31UpdTable("SZU")


	EndIf

	RpcClearEnv()

Return

	#DEFINE __nMAX_THREADS__ 15

User Function UpSxTHR()
	Local nCont 		:= 0
	Local nNumRan 		:= 0
	Local cEmp			:= '00'

	#IFDEF TOP
		SetTopType( "A" )
	#ENDIF
	RPCSetType(3)
	RpcSetEnv( '01' , '01' )

	//threads

	For nCont := 0 to 14

		cEmp := soma1(cEmp)
		cProcess := "U_UPDSX3"
		StartJob( cProcess , GetEnvServer()  , .T. , cEmp )

		While ( !FreeThreads( .F. ) )
			Sleep(5000)
		End While

	Next nCont

	While ( !ProcWaiting( { || FreeThreads( .T., cProcess ) } , "Verificando Threads Pendentes" , "Aguarde..." , 100000 , .F. , .T. ) )
	End While

	MsgInfo("Processamento Finalizado!", "Criação de MODs")

Return


Static Function FreeThreads( lFreeAll, cpProcess )

	Local aUserInfoArray	:= GetUserInfoArray()

	Local cEnvServer		:= GetEnvServer()
	Local cComputerName		:= GetComputerName()

	Local nThreads			:= 0

	lFreeAll	:= .F.
	//carloDEFAULT lFreeAll	:= .F.
	aEval( aUserInfoArray , { |aThread| IF(;
		( aThread[2] == cComputerName );
		.and.;
		( aThread[5] == cpProcess );
		.and.;
		( aThread[6] == cEnvServer ),;
		++nThreads,;
		NIL;
		);
		};
		)


	/*
	aEval( aUserInfoArray , { |aThread| IF(;
	( aThread[2] == cComputerName );
	.and.;
	( aThread[5] == cpProcess );
	.and.;
	( aThread[6] == cEnvServer ),;
	++nThreads,;
	NIL;
	);
	};
	)
	lFreeAll	:= .F.
	*/

	IF ( lFreeAll )
		lFreeThreads	:= ( nThreads == 0 )
	Else
		lFreeThreads	:= ( nThreads <= Int( __nMAX_THREADS__ / 2 ) )
	EndIF



Return( lFreeThreads )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fCalcFreteAut    ³ Ranisses A. Corona º Data ³  15/08/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina para Calcular o Icms Frete Autonomo                 º±±
±±º          ³ Retorno com array Posicao 1 - Base / Posicao 2 - Valor Fre º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Faturamento                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User function fCalcFreteAut(cEst,cMunic,nProduto,nLote,nQuant)
	Local nPesoPr	:= 0 //Peso do Produto
	Local nPesoPEmb	:= 0 //Peso Embalagem do Produto
	Local nPesoLiq	:= 0 //Peso Liquido
	Local nPesoEmb	:= 0 //Peso da Embalagem
	Local nPesoBr	:= 0 //Peso Bruto
	Local wBaseCalc := 0
	Local wIcms		:= 0
	Local aVlr		:= {} //Base e Valor do Frete Autonomo

	//Posiciona ZZ9 - Cad. Produto/Lote
	cSql := ""
	cSql += "SELECT * FROM ZZ9010 WHERE	ZZ9_PRODUT = '" +nProduto+ "' AND ZZ9_LOTE = '" +nLote+ "' AND D_E_L_E_T_ = '' "
	If chkfile("_ZZ9")
		dbSelectArea("_ZZ9")
		dbCloseArea()
	EndIf
	TCQuery cSql Alias "_ZZ9" New

	cSql := ""
	cSql += "SELECT B1_COD, B1_PESO, B1_YPESEMB, B1_TIPCONV, B1_CONV FROM SB1010 WHERE	B1_COD = '" +nProduto+ "' AND D_E_L_E_T_ = '' "
	If chkfile("_SB1")
		dbSelectArea("_SB1")
		dbCloseArea()
	EndIf
	TCQuery cSql Alias "_SB1" New

	If !_ZZ9->(EOF())
		nPeso		:= _ZZ9->ZZ9_PESO
		nPesoPEmb 	:= _ZZ9->ZZ9_PESEMB
	Else
		nPeso		:= _SB1->B1_PESO
		nPesoPEmb 	:= _SB1->B1_YPESEMB
	EndIf

	//Grava Peso Liquido
	nPesoLiq := (nQuant*nPeso)

	//Grava Peso Embalagem - 2 Unidade Medida
	If _SB1->B1_TIPCONV == "M"
		nPesoEmb  := (( nQuant * _SB1->B1_CONV ) * nPesoPEmb )
	Else
		nPesoEmb  := (( nQuant / _SB1->B1_CONV ) * nPesoPEmb )
	EndIf

	//Grava Peso Bruto
	nPesoBr := nPesoEmb + nPesoLiq

	If nPesoBr == 0
		MsgBox("O produto "+nProduto+" não possui PESO cadastrado no sistema. O cálculo do ICMS de Frete NÃO SERÁ REALIZADO para este produto!","Frete Autonomo","STOP")
	EndIf

	//Busca tarifa do frete
	/*DbSelectArea("SZ3")
	DbSetOrder(1)
	If !DbSeek(xFilial("SZ3")+cMunic,.T.)
	MsgBox("O Municipio "+cMunic+" não está cadastrado na tabela de Frete Autonomo!","Frete Autonomo","ALERT")	
	wVt := 1	
	Else
	DbSelectArea("SZ4")
	DbSetOrder(1)
	DbSeek(xFilial("SZ4")+SZ3->Z3_TARIFA,.T.)
	wVt := SZ4->Z4_PRECO
	EndIf*/

	//Busca tarifa do frete
	DbSelectArea("CC2")
	DbSetOrder(1)

	If !DbSeek(xFilial("CC2")+cEst+cMunic,.T.) .Or. Empty(Alltrim(CC2->CC2_YTARIF))
		MsgBox("O Municipio "+cMunic+" não está cadastrado na tabela de Municipios - CC2 ou não está vinculado a tabela de Tarifa de Frete!","Frete Autonomo","ALERT")	
		wVt := 1	
	Else
		DbSelectArea("SZ4")
		DbSetOrder(1)
		DbSeek(xFilial("SZ4")+CC2->CC2_YTARIF,.T.)
		wVt := SZ4->Z4_PRECO
	EndIf

	wBaseCalc	:= (wVt * (nPesoBr))
	wIcms			:= ((wBaseCalc * 12) / 100)

	aadd(aVlr,wBaseCalc)
	aadd(aVlr,wIcms)

Return(aVlr)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fCalcVlrST       ³ Ranisses A. Corona º Data ³  15/08/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para Calcular o Valor de ICMS ST                    º±±
±±º          ³ Retorno com array Posicao 1 - Base / Posicao 2 - Valor ST  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Faturamento                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User function fCalcVlrST(xGrpPd,xNCM,xRegEsp,xCliEsp,xUF,xVlMerc,xVlIcms,xVlIpi,xVlAut,xVlTran,xCli,xPIcms,xBaseIcms)
	Local nGrpPd	:= xGrpPd	//Grupo de Tributacao do Produto
	Local nNCM		:= xNCM		//NCM / Posição IPI
	Local nRegEsp	:= xRegEsp	//
	Local nCliEsp	:= xCliEsp	//Identifica se o Cliente tera tratamento epecial com relacao ao MVA // APENAS PARA UM UNICO CLIENTE 015966
	Local nUF		:= xUF		//Estado do Cliente/Fornecedor
	Local nVlMerc	:= xVlMerc	//Valor Mercadorias
	Local nVlIcms	:= xVlIcms	//Valor ICMS
	Local nPIcms	:= xPIcms
	Local nBaseIcms := xBaseIcms
	Local nVlIpi	:= xVlIpi	//Valor IPI
	Local nVlAut	:= xVlAut	//Valor Frete Autonomo
	Local nVlTran	:= xVlTran	//Valor Frete Transportadora
	Local aMVA		:= U_fBuscaMVA(nNCM,nUF,nGrpPd,dDataBase) //Retorna o MVA, % ICMS e o % Red. Base ST
	Local nICMS		:= 0
	Local nBaseSt	:= 0		//Valor Base ST
	Local nVlrSt	:= 0		//Valor ST
	Local aVlrSt	:= {}		//Array com a Base e Valor da ST
	Local cCodCli	:= xCli

	//Default xCli := "000000"
	//If xCli == "017849"
	//	xVlAut := 0
	//	nVlAut := 0
	//EndIf

	If Empty(Alltrim(nRegEsp)) //PARA CLIENTES COM REGIME ESPECIAL, O SISTEMA NÃO CACULA A GNRE

		If nCliEsp == "S" //EXCESSAO PARA CLIENTE 015966

			nBaseSt	:= (nVlMerc+nVlIpi+nVlAut+nVlTran) + ((nVlMerc+nVlIpi+nVlAut+nVlTran) * Iif(nGrpPd<>"003",53.00,53.00)/ 100)
			nVlrSt	:= Round((((nVlMerc+nVlIpi+nVlAut+nVlTran) + ((nVlMerc+nVlIpi+nVlAut+nVlTran) * Iif(nGrpPd<>"003",53.00,53.00)/ 100)) * 20 / 100 ) - nVlIcms, 2)
			aadd(aVlrSt,nBaseSt)
			aadd(aVlrSt,nVlrSt)
			aadd(aVlrSt,53.00)  //MVA
			aadd(aVlrSt,20)     //ALIQ ST

		Else

			//desativado conforme ticket 21314
			/*If ( AllTrim(nUF) == 'MT' .And. AllTrim(cCodCli) == '008960' )
			nBaseSt	:= (nVlMerc+nVlIpi)
			nVlrSt	:=  Round(nBaseSt * (10.15 / 100), 2)
			aadd(aVlrSt, nBaseSt)
			aadd(aVlrSt, nVlrSt)
			aadd(aVlrSt, 0)  //MVA
			aadd(aVlrSt, 0)  //ALIQ ST	
		Else
			nBaseSt	:= (nVlMerc+nVlIpi+nVlAut+nVlTran) + ((nVlMerc+nVlIpi+nVlAut+nVlTran) * aMVA[2] / 100  )
			If aMVA[4] > 0 //Aplica % de reducao da Base ICMS ST
			nBaseSt = nBaseSt - (nBaseSt * aMVA[4] /100)
			EndIf
			If nUF == "MG" .And. GetMV("MV_YSOLMG") > 0 //Aplica reducao do ICMS somente para a UF de MG e empresa 01 e 05
			nVlIcms := (GetMV("MV_YSOLMG")/100 * nVlIcms) 
			EndIf
			nVlrSt	:=  Round((nBaseSt * aMVA[3] / 100 ) - nVlIcms,2)
			aadd(aVlrSt,nBaseSt)
			aadd(aVlrSt,nVlrSt)
			aadd(aVlrSt,aMVA[2])  //MVA
			aadd(aVlrSt,aMVA[3])  //ALIQ ST
		EndIf
			*/

		nBaseSt	:= (nVlMerc+nVlIpi+nVlAut+nVlTran) + ((nVlMerc+nVlIpi+nVlAut+nVlTran) * aMVA[2] / 100  )
		If aMVA[4] > 0 //Aplica % de reducao da Base ICMS ST
			nBaseSt = nBaseSt - (nBaseSt * aMVA[4] /100)
		EndIf
		If nUF == "MG" .And. GetMV("MV_YSOLMG") > 0 //Aplica reducao do ICMS somente para a UF de MG e empresa 01 e 05
			nVlIcms := (GetMV("MV_YSOLMG")/100 * nVlIcms)
		EndIf

		//Ticket 21807
		//Com a alteração do regulamento de ICMS do MT este cliente passou a ser optante pelo crédito outorgado e com isso o crédito de ICMS deles é limitado a 7%
		If ( AllTrim(nUF) == 'MT' .And. AllTrim(cCodCli) == '008960' .And. nPIcms > 7.00 )

			nVlIcms := nBaseIcms * (7.00/100)

		EndIf

		nVlrSt	:=  Round((nBaseSt * aMVA[3] / 100 ) - nVlIcms,2)

		aadd(aVlrSt,nBaseSt)
		aadd(aVlrSt,nVlrSt)
		aadd(aVlrSt,aMVA[2])  //MVA
		aadd(aVlrSt,aMVA[3])  //ALIQ ST

	EndIf

Else

	aadd(aVlrSt,0)
	aadd(aVlrSt,0)
	aadd(aVlrSt,0)
	aadd(aVlrSt,0)

EndIf

Return(aVlrSt)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fValItemCta      ³ Ranisses A. Corona º Data ³  18/10/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para validar a digitacao do Item Contabil           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function fValItemCta(xTp, xConta, xClVl, xItemCta, cSubItem)
Local	lRet	:= .T.			//Retorno da Funcao
	
	Default cSubItem := ""

	If cEmpAnt $ ("01_05_06_07_12_13_14") //Executa apenas para as empresas Biancogres, Incesa, LM e MUNDI

		//Tratamento para Faturamento
		If Alltrim(xTp) $ GetMv("MV_YTPMK") .Or. (Alltrim(xTp) == "O" .And. xConta)
			xConta := .T.
		EndIf

		If xConta //Se for Conta do Grupo 31401
			//Obriga a digitacao do Item Contabil para as Classes do Comercial
			If (Alltrim(xClVl) $ GetMv("MV_YCLVL") .Or. SUBSTR(xClVl,1,1) == "8") .And. Empty(xItemCta)
				msgBox("Favor informar Item Contábil para esta Classe de Valor!", "UserLibrary(6)")
				AutoGrLog("Favor informar Item Contábil para esta Classe de Valor!")
				lRet := .F.
			EndIf
		Else
			//Obriga a digitacao do Item Contabil para a Classe de Valor = 8
			If SUBSTR(xClVl,1,1) == "8" .AND. EMPTY(xItemCta) .And. Empty(cSubItem)
				msgBox("Favor informar Item Contábil e o Subitem para esta Classe de Valor!", "UserLibrary(5)")
				AutoGrLog("Favor informar Item Contábil para esta Classe de Valor!")
				lRet := .F.
			ElseIf Alltrim(FunName()) == "MATA103" // Implementado Tratamento por Marcos Alberto Soprani para atender ao Projeto de Provisionamento de Comissão. Em 09/01/13
				If Alltrim(SB1->B1_COD) == "3060238" .and. Substr(xItemCta,1,3) <> "COM"
					msgBox("Favor informar Item Contábil para esta Classe de Valor!", "UserLibrary(4)")
					AutoGrLog("Favor informar Item Contábil para esta Classe de Valor!")
					lRet := .F.
				EndIf
			End
		EndIf

		If xConta //Se for Conta do Grupo 31401
			//O Item Contabil deve ser preenchido apenas para a Classe de Valor do Comercial e Investimento
			If ( !Alltrim(xClVl) $ GetMv("MV_YCLVL") .AND. SUBSTR(xClVl,1,1) <> "8") .AND. Alltrim(xClVl) <> '2130' .AND. Alltrim(xClVl) <> '1045' .AND. Alltrim(xClVl) <> '3145' .AND. Alltrim(xClVl) <> '3184' .AND. Alltrim(xClVl) <> '3185' .AND. Alltrim(xClVl) <> '4011' .AND. !Empty(xItemCta)
				Msgbox("Item Contábil não poderá ser informado para esta Classe de Valor!", "UserLibrary(1)")
				AutoGrLog("Item Contábil não poderá ser informado para esta Classe de Valor!")
				lRet := .F.
			EndIf
		Else
			//O Item Contabil deve ser preenchido apenas para a Classe de Valor do Investimento
			//If SUBSTR(xClVl,1,1) <> "8" .AND. Alltrim(xClVl) <> '2130' .AND. Alltrim(xClVl) <> '2100' .AND. !EMPTY(xItemCta)
			If SUBSTR(xClVl,1,1) <> "8" .AND. SUBSTR(xClVl,1,1) <> "2" .AND. !EMPTY(xItemCta) .AND. Alltrim(xClVl) <> '1045' .AND. Alltrim(xClVl) <> '3145' .AND. Alltrim(xClVl) <> '3184' .AND. Alltrim(xClVl) <> '3185' .AND. Alltrim(xClVl) <> '4011' .AND. Alltrim(xClVl) <> '6106'
				// Implementado Tratamento por Marcos Alberto Soprani para atender ao Projeto de Provisionamento de Comissão. Em 09/01/13
				If Alltrim(FunName()) == "MATA103"
					If Alltrim(SB1->B1_COD) <> "3060238" .and. Substr(xItemCta,1,3) <> "COM"
						msgBox("Conta contábil no cadastro do produto nao pode ter Item Contábil para esta Classe de Valor!", "UserLibrary(2)")
						AutoGrLog("Conta contábil no cadastro do produto nao pode ter Item Contábil para esta Classe de Valor!")
						lRet := .F.
					EndIf
				Else
					msgBox("Conta contábil no cadastro do produto nao pode ter Item Contábil para esta Classe de Valor!", "UserLibrary(3)")
					AutoGrLog("Conta contábil no cadastro do produto nao pode ter Item Contábil para esta Classe de Valor!")
					lRet := .F.
				EndIf
			EndIf
		EndIf

	EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fValProdComum    ³ Ranisses A. Corona º Data ³  25/10/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para validar a transferencia e entrada de           º±±
±±º          ³ Produtos Comuns.                                           º±±
±±º          ³ Parametros da Funcao Produto/Almoxarifado/NomeProgroma     º±±
±±º					 ³ TipoMovimento(C=Compra/T=Transferencia)			              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function fValProdComum(xProd,xLocal,xPrograma,xTpMov)
	Local	lRet	:= .T.			//Retorno da Funcao

	//Bloqueia transferencia para almoxaridado/empresa para os produtos do codigo 201 a 400
	If cEmpAnt $ ("01_05") //Executa apenas para as empresas Biancogres e Incesa
		If Substr(xProd,1,3) >= "201" .And. Substr(xProd,1,3) <= "400"
			DbSelectArea("SBZ")
			DbSetOrder(1)
			If DbSeek(xFilial()+xProd,.T.)
				If SBZ->BZ_YCOMUM == "S"
					If cEmpAnt == "01" .And. xLocal == "6I"
						cAliasTmp := GetNextAlias()
						BeginSql Alias cAliasTmp
							SELECT SUM(B2_QATU) QATU FROM SB2050 WHERE B2_COD = %Exp:xProd% AND %NOTDEL%
						EndSql
						If (cAliasTmp)->QATU > 0
							MsgBox("Produto possui saldo na Empresa Incesa. Favor utilizar o saldo deste produto antes de realizar novas "+IIf(xTpMov=="T","Transferência","Compras")+"!",xPrograma,"STOP")
							AutoGrLog("Produto possui saldo na Empresa Incesa. Favor utilizar o saldo deste produto antes de realizar novas "+IIf(xTpMov=="T","Transferência","Compras")+"!")
							lRet := .F.
							Return(lRet)
						EndIf
					ElseIf cEmpAnt == "05" .And. xLocal == "6B"
						MsgBox("Não é permitida a "+IIf(xTpMov=="T","Transferência","Compra")+" para o Almoxarifado 6B na Empresa Incesa!",xPrograma,"STOP")
						AutoGrLog("Não é permitida a "+IIf(xTpMov=="T","Transferência","Compra")+" para o Almoxarifado 6B na Empresa Incesa!")
						lRet := .F.
						Return(lRet)
					EndIf
				ElseIf SBZ->BZ_YCOMUM <> "S" .And. Substr(xLocal,1,1) == "6"
					MsgBox("Somente é permitido "+IIf(xTpMov=="T","Transferência","Compra")+" para o Almoxarido 6 para Produtos Comuns!",xPrograma,"STOP")
					AutoGrLog("Somente é permitido "+IIf(xTpMov=="T","Transferência","Compra")+" para o Almoxarido 6 para Produtos Comuns!")
					lRet := .F.
					Return(lRet)
				EndIf
			Else
				MsgBox("Não existe Cadastro de Indicador para este Produto "+ALLTRIM(xProd)+". Favor realizar o cadastro!",xPrograma,"STOP")
				AutoGrLog("Não existe Cadastro de Indicador para este Produto "+ALLTRIM(xProd)+". Favor realizar o cadastro!")
				lRet := .F.
				Return(lRet)
			EndIf
		EndIf
	EndIf

	DbSelectArea("SB1")
	cArqSB1 := Alias()
	cIndSB1 := IndexOrd()
	cRegSB1 := Recno()
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+xProd,.F.)

	If !(SB1->B1_TIPO $ "PA#PP") .And. xLocal $ "02#04"
		MsgBox("Almoxarifado informado incorreto: " + xLocal,xPrograma,"STOP")
		AutoGrLog("Almoxarifado informado incorreto: " + xLocal)
		lRet := .F.
		Return(lRet)
	EndIf

	If cArqSB1 <> ""
		dbSelectArea(cArqSB1)
		dbSetOrder(cIndSB1)
		dbGoTo(cRegSB1)
		RetIndex("SB1")
	EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fBuscaMargem    ºAutor  ³Ranisses A. Corona  º Data ³  29/08/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Busca a Margem para utilizar no Pedido de Venda.                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Faturamento                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function fBuscaMargem(nVend,nSegm,nCli,nGrpCli,nFormat,nClasse,nProd,nLote,dtEmis,nLinha)
	Local cSql		:= ""
	Local Enter 	:= CHR(13)+CHR(10)
	Local nMargem	:= 0
	Local nRegra	:= ""
	Local aRet		:= {}
	Local lProd		:= .F.

	//Busca o Grupo do Segmento, a partir do Segmento do Cliente
	cSql := " SELECT MAX(ZZG_GRUPO) GRUPO FROM ZZG010 WHERE ZZG_SEG = '"+nSegm+"' AND D_E_L_E_T_ = '' "
	If chkfile("R1")
		dbSelectArea("R1")
		dbCloseArea()
	EndIf
	TCQUERY cSql ALIAS "R1" NEW
	nSegm := R1->GRUPO


	//±±±±±±±±±±±±±
	//FORMATO
	//±±±±±±±±±±±±±
	If !Empty(nFormat)
		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		//Busca MARGEM por FORMATO
		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		cSql := "SELECT ACP_YPERMR, ACP_YTPDES, ACP_CODREG  " + Enter
		If nLinha = "1"	//Biancogres
			cSql += "From ACO010 ACO, ACP010 ACP " + Enter
		Else						//Incesa e BellaCasa
			cSql += "From ACO050 ACO, ACP050 ACP " + Enter
		EndIf
		cSql += "Where 	ACO.ACO_FILIAL 	= '" + xFilial("ACO") + "'	AND " + Enter
		cSql += "     	ACP.ACP_FILIAL 	= '" + xFilial("ACP") + "'	AND " + Enter
		cSql += "				'" + dtEmis +"' >= ACP.ACP_YDATDE		AND " + Enter
		cSql += "				'" + dtEmis +"' <= ACP.ACP_YDATAT		AND " + Enter
		cSql += "				ACP.ACP_CODREG	= ACO.ACO_CODREG		AND " + Enter
		cSql += "				ACO.ACO_CODCLI	= '' 								AND " + Enter
		cSql += "				ACP.ACP_YESTCL 	= ''								AND " + Enter
		cSql += "				ACP.ACP_YVEND		= ''								AND " + Enter
		cSql += "				ACO.ACO_GRPVEN	= ''								AND " + Enter
		cSql += "				ACP.ACP_CODPRO  = '' 						  	AND " + Enter
		cSql += "				ACP.ACP_YCLASS	= '1'								AND " + Enter
		cSql += "				ACP.ACP_YFORMA	= '"+nFormat+"'			AND " + Enter
		cSql += "				ACO.ACO_YLINHA	= '"+nLinha+"'			AND " + Enter //Biancogres - Incesa - BellaCasa
		cSql += "				ACO.ACO_YTIPO 	= 'M'								AND " + Enter

		//Inserido por Wanisay em 13/08/12
		cSql += "			 (ACO_YEXCLC NOT LIKE '%" + nCli +"%'     Or " + Enter
		cSql += "	  		ACO_YEXCLG NOT LIKE '%" + nGrpCli+"%' ) AND	" + Enter

		cSql += "				ACP.D_E_L_E_T_	= ''							AND 			" + Enter
		cSql += "				ACO.D_E_L_E_T_ 	= '' AND ACO_MSBLQL <> '1' 	" + Enter
		If chkfile("X2")
			dbSelectArea("X2")
			dbCloseArea()
		EndIf
		TCQUERY cSql ALIAS "X2" NEW
		If X2->ACP_YPERMR <> 0
			nMargem	:= X2->ACP_YPERMR
			nRegra	:= X2->ACP_CODREG
		EndIf
	EndIf


	//±±±±±±±±±±±±±
	//REPRESENTANTE
	//±±±±±±±±±±±±±
	If !Empty(nVend)

		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		//Busca MARGEM por REPRESENTANTE
		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		cSql := "SELECT ACP_YPERMR, ACP_CODREG " + Enter
		If nLinha = "1"	//Biancogres
			cSql += "From ACO010 ACO, ACP010 ACP " + Enter
		Else						//Incesa e BellaCasa
			cSql += "From ACO050 ACO, ACP050 ACP " + Enter
		EndIf
		cSql += "Where 	ACO.ACO_FILIAL 	= '" + xFilial("ACO") + "' AND " + Enter
		cSql += "     	ACP.ACP_FILIAL 	= '" + xFilial("ACP") + "' AND " + Enter
		cSql += "				'" + dtEmis +"' >= ACP.ACP_YDATDE		AND " + Enter
		cSql += "				'" + dtEmis +"' <= ACP.ACP_YDATAT		AND " + Enter
		cSql += "				ACP.ACP_YESTCL 	= ''								AND " + Enter
		cSql += "				ACP.ACP_CODREG	= ACO.ACO_CODREG		AND " + Enter
		cSql += "				ACP.ACP_YVEND		= '" + nVend +"'		AND " + Enter
		cSql += "				ACP.ACP_YFORMA	= '"+nFormat+"'			AND " + Enter
		cSql += "				ACP.ACP_YSEGME	= ''						   	AND " + Enter 	//TRATAMENTO PARA O SEGMENTO
		cSql += "				ACP.ACP_YCLASS	= '1'								AND " + Enter

		If Substr(nVend,1,1) == "0"																		  		//PERMITE DESCONTO PARA SUPERVISOR
			cSql += "	SUBSTRING(ACP.ACP_CODPRO,2,5)	= '" + SUBSTR(nVend,2,5) +"' AND " + Enter
		EndIf
		cSql += "				ACO.ACO_YLINHA	= '"+nLinha+"'			AND	" + Enter 	//Biancogres - Incesa - BellaCasa
		cSql += "				ACO.ACO_YTIPO 	= 'M'								AND " + Enter

		//Inserido por Wanisay em 13/08/12
		cSql += "				(ACO_YEXCLC NOT LIKE '%" + nCli +"%'     Or " + Enter
		cSql += "				ACO_YEXCLG NOT LIKE '%" + nGrpCli+"%' ) AND	" + Enter

		cSql += "				ACP.D_E_L_E_T_	= ''  AND 									" + Enter
		cSql += "				ACO.D_E_L_E_T_ 	= ''  AND ACO_MSBLQL <> '1'	" + Enter
		If chkfile("X2")
			dbSelectArea("X2")
			dbCloseArea()
		EndIf
		TCQUERY cSql ALIAS "X2" NEW

		If X2->ACP_YPERMR <> 0
			nMargem	:= X2->ACP_YPERMR
			nRegra	:= X2->ACP_CODREG
		EndIf


		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		//Busca MARGEM por REPRESENTANTE / ESTADO
		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		nEst	:= Posicione("SA1",1,xFilial("SA1")+nCli,"A1_EST")
		cSql := "SELECT ACP_YPERMR, ACP_CODREG " + Enter
		If nLinha = "1"		//Biancogres
			cSql += "From ACO010 ACO, ACP010 ACP " + Enter
		Else							//Incesa e BellaCasa
			cSql += "From ACO050 ACO, ACP050 ACP " + Enter
		EndIf
		cSql += "Where 	ACO.ACO_FILIAL 	= '" + xFilial("ACO") + "' AND " + Enter
		cSql += "     	ACP.ACP_FILIAL 	= '" + xFilial("ACP") + "' AND " + Enter
		cSql += "				'" + dtEmis +"' 	>= ACP.ACP_YDATDE	AND " + Enter
		cSql += "				'" + dtEmis +"' 	<= ACP.ACP_YDATAT	AND " + Enter
		cSql += "   		ACP.ACP_CODREG	= ACO.ACO_CODREG  AND " + Enter
		cSql += "				ACP.ACP_YVEND		= '"+nVend+"'			AND " + Enter
		cSql += "				ACP.ACP_YESTCL 	= '"+nEst+"'			AND " + Enter
		cSql += "				ACP.ACP_YFORMA	= '"+nFormat+"'		AND " + Enter
		cSql += "				ACP.ACP_YSEGME	= ''						 	AND " + Enter 	//TRATAMENTO PARA O SEGMENTO
		cSql += "				ACP.ACP_YCLASS	= '1'								AND " + Enter
		If Substr(nVend,1,1) == "0"												 						//PERMITE DESCONTO PARA SUPERVISOR
			cSql += "	SUBSTRING(ACP.ACP_CODPRO,2,5)	= '" + SUBSTR(nVend,2,5) +"' AND " + Enter
		EndIf
		cSql += "				ACO.ACO_YLINHA	= '"+nLinha+"'	AND	" + Enter //Biancogres - Incesa - BellaCasa
		cSql += "				ACO.ACO_YTIPO 	= 'M'						AND " + Enter

		//Inserido por Wanisay em 13/08/12
		cSql += "	 			(ACO_YEXCLC NOT LIKE '%" + nCli +"%'     Or " + Enter
		cSql += "	  		ACO_YEXCLG NOT LIKE '%" + nGrpCli+"%' ) AND	" + Enter

		cSql += "				ACP.D_E_L_E_T_	= ''		        AND 				" + Enter
		cSql += "				ACO.D_E_L_E_T_ 	= ''  AND ACO_MSBLQL <> '1' " + Enter
		If chkfile("X2")
			dbSelectArea("X2")
			dbCloseArea()
		EndIf
		TCQUERY cSql ALIAS "X2" NEW

		If X2->ACP_YPERMR <> 0
			nMargem	:= X2->ACP_YPERMR
			nRegra	:= X2->ACP_CODREG
		EndIf


		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		//Busca MARGEM por REPRESENTANTE / SEGMENTO
		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		cSql := "SELECT ACP_YPERMR, ACP_CODREG " + Enter
		If nLinha = "1"	//Biancogres
			cSql += "From ACO010 ACO, ACP010 ACP " + Enter
		Else						//Incesa e BellaCasa
			cSql += "From ACO050 ACO, ACP050 ACP " + Enter
		EndIf
		cSql += "Where 	ACO.ACO_FILIAL 	= '" + xFilial("ACO") + "' And " + Enter
		cSql += "     	ACP.ACP_FILIAL 	= '" + xFilial("ACP") + "' And " + Enter
		cSql += "	'" + dtEmis +"' 	>= ACP.ACP_YDATDE	And " + Enter
		cSql += "	'" + dtEmis +"' 	<= ACP.ACP_YDATAT	And " + Enter
		cSql += "		ACP.ACP_YESTCL	= ''							And " + Enter
		cSql += "   ACP.ACP_CODREG	= ACO.ACO_CODREG	And " + Enter
		cSql += "		ACP.ACP_YVEND		= '" + nVend +"'	And " + Enter
		cSql += "		ACP.ACP_YSEGME	= '" + nSegm +"'	And " + Enter 	//TRATAMENTO PARA O SEGMENTO
		cSql += "		ACP.ACP_YFORMA	= '"+nFormat+"'			AND " + Enter
		cSql += "		ACP.ACP_YCLASS	= '1'							AND " + Enter
		If Substr(nVend,1,1) == "0"												 						//PERMITE DESCONTO PARA SUPERVISOR
			cSql += "	SUBSTRING(ACP.ACP_CODPRO,2,5)	= '" + SUBSTR(nVend,2,5) +"' And " + Enter
		EndIf
		cSql += "		ACO.ACO_YLINHA	= '"+nLinha+"'		And	" + Enter		//Biancogres - Incesa - BellaCasa
		cSql += "		ACO.ACO_YTIPO 	= 'M'							And " + Enter

		//Inserido por Wanisay em 13/08/12
		cSql += "	 (ACO_YEXCLC NOT LIKE '%" + nCli +"%'     Or " + Enter
		cSql += "	  ACO_YEXCLG NOT LIKE '%" + nGrpCli+"%' ) And	" + Enter

		cSql += "		ACP.D_E_L_E_T_	= ''		                   And 	" + Enter
		cSql += "		ACO.D_E_L_E_T_ 	= ''  AND ACO_MSBLQL <> '1' 		" + Enter
		If chkfile("X2")
			dbSelectArea("X2")
			dbCloseArea()
		EndIf
		TCQUERY cSql ALIAS "X2" NEW

		If X2->ACP_YPERMR <> 0
			nMargem	:= X2->ACP_YPERMR
			nRegra	:= X2->ACP_CODREG
		EndIf


		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		//Busca MARGEM por REPRESENTANTE / PRODUTO / LOTE
		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		cSql := "SELECT ACP_YPERMR, ACP_YTPDES, ACP_CODREG " + Enter
		If nLinha = "1"	//Biancogres
			cSql += "From ACO010 ACO, ACP010 ACP " + Enter
		Else						//Incesa e BellaCasa
			cSql += "From ACO050 ACO, ACP050 ACP " + Enter
		EndIf
		cSql += "Where 	ACO.ACO_FILIAL 	= '" + xFilial("ACO") + "' AND " + Enter
		cSql += "     	ACP.ACP_FILIAL 	= '" + xFilial("ACP") + "' AND " + Enter
		cSql += "		'" + dtEmis +"' 	>= ACP.ACP_YDATDE	AND " + Enter
		cSql += "		'" + dtEmis +"' 	<= ACP.ACP_YDATAT	AND " + Enter
		cSql += "		ACP.ACP_YESTCL 	= '' 					AND " + Enter
		cSql += "		ACP.ACP_CODREG	= ACO.ACO_CODREG		AND " + Enter
		cSql += "		ACP.ACP_YVEND		= '" + nVend +"'	AND " + Enter
		cSql += "		ACP.ACP_YSEGME	= ''					AND " + Enter //TRATAMENTO PARA O SEGMENTO
		cSql += "		ACP.ACP_YCLASS	= '1'					AND " + Enter

		cSql += "		ACP.ACP_CODPRO	= '" + nProd +"' 		AND " + Enter
		//RETIRADO VALIDAÇÃO DO LOTE EM 25/05/15, POIS A REGRA NÃO ATENDE AO CENÁRIO ATUAL
		//If Empty(Alltrim(nLote))
		//	cSql += "		ACP.ACP_CODPRO	= '" + nProd +"' AND " + Enter
		//Else
		//	cSql += "		ACP.ACP_CODPRO	= '" + nProd +"' AND ACP.ACP_YLOTE = '" + nLote +"'	AND " + Enter
		//EndIf

		cSql += "		ACO.ACO_YLINHA	= '"+nLinha+"'	 		AND " + Enter //Biancogres - Incesa - BellaCasa
		cSql += "		ACO.ACO_YTIPO 	= 'M'					AND " + Enter

		//Inserido por Wanisay em 13/08/12
		cSql += "		(ACO_YEXCLC NOT LIKE '%" + nCli +"%'     Or " + Enter
		cSql += "	 	ACO_YEXCLG NOT LIKE '%" + nGrpCli+"%' ) AND	" + Enter

		cSql += "		ACP.D_E_L_E_T_	= ''		                   AND " + Enter
		cSql += "		ACO.D_E_L_E_T_ 	= ''  AND ACO_MSBLQL <> '1' " + Enter
		If chkfile("X2")
			dbSelectArea("X2")
			dbCloseArea()
		EndIf
		TCQUERY cSql ALIAS "X2" NEW

		If X2->ACP_YPERMR <> 0
			nMargem	:= X2->ACP_YPERMR
			nRegra	:= X2->ACP_CODREG
			//lProd   := .T.
		EndIf

		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		//Busca MARGEM por REPRESENTANTE / SEGMENTO / PRODUTO / LOTE
		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		cSql := "SELECT ACP_YPERMR, ACP_YTPDES, ACP_CODREG " + Enter
		If nLinha = "1"	//Biancogres
			cSql += "From ACO010 ACO, ACP010 ACP " + Enter
		Else						//Incesa e BellaCasa
			cSql += "From ACO050 ACO, ACP050 ACP " + Enter
		EndIf
		cSql += "Where 		ACO.ACO_FILIAL 	= '" + xFilial("ACO") + "' AND " + Enter
		cSql += "			ACP.ACP_FILIAL 	= '" + xFilial("ACP") + "' AND " + Enter
		cSql += "			'" + dtEmis +"' 	>= ACP.ACP_YDATDE	AND " + Enter
		cSql += "			'" + dtEmis +"' 	<= ACP.ACP_YDATAT	AND " + Enter
		cSql += "			ACP.ACP_YESTCL 	= ''								AND " + Enter
		cSql += "   		ACP.ACP_CODREG	= ACO.ACO_CODREG		AND " + Enter
		cSql += "			ACP.ACP_YVEND		= '" + nVend +"'		AND " + Enter
		cSql += "			ACP.ACP_YSEGME	= '" + nSegm +"'		AND " + Enter //TRATAMENTO PARA O SEGMENTO
		cSql += "			ACP.ACP_YCLASS	= '1'								AND " + Enter

		cSql += "			ACP.ACP_CODPRO	= '" + nProd +"' AND " + Enter
		//RETIRADO VALIDAÇÃO DO LOTE EM 25/05/15, POIS A REGRA NÃO ATENDE AO CENÁRIO ATUAL
		//If Empty(Alltrim(nLote))
		//	cSql += "			ACP.ACP_CODPRO	= '" + nProd +"' AND " + Enter
		//Else
		//	cSql += "			ACP.ACP_CODPRO	= '" + nProd +"' AND ACP.ACP_YLOTE = '" + nLote +"'	AND " + Enter
		//EndIf
		cSql += "			ACO.ACO_YLINHA	= '"+nLinha+"'	AND	" + Enter //Biancogres - Incesa - BellaCasa
		cSql += "			ACO.ACO_YTIPO 	= 'M'						AND " + Enter

		//Inserido por Wanisay em 13/08/12
		cSql += "			(ACO_YEXCLC NOT LIKE '%" + nCli +"%'     Or " + Enter
		cSql += "	  		ACO_YEXCLG NOT LIKE '%" + nGrpCli+"%' ) AND	" + Enter

		cSql += "			ACP.D_E_L_E_T_	= ''		                   AND " + Enter
		cSql += "			ACO.D_E_L_E_T_ 	= ''  AND ACO_MSBLQL <> '1' " + Enter
		If chkfile("X2")
			dbSelectArea("X2")
			dbCloseArea()
		EndIf
		TCQUERY cSql ALIAS "X2" NEW

		If X2->ACP_YPERMR <> 0
			nMargem	:= X2->ACP_YPERMR
			nRegra	:= X2->ACP_CODREG
			//lProd   := .T.
		EndIf
	EndIf

	//±±±±±±±±±±±±±
	//CLIENTE
	//±±±±±±±±±±±±±
	//Nao pode existir Grupo de Cliente Vazio
	If Empty(Alltrim(nGrpCli))
		nGrpCli := "."
	EndIf

	If !Empty(nCli) .OR. !Empty(nGrpCli)
		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		//Busca MARGEM por CLIENTE / GRUPO
		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		cSql := "SELECT ACP_YPERMR, ACP_YTPDES, ACP_CODREG  " + Enter
		If nLinha = "1"	//Biancogres
			cSql += "From ACO010 ACO, ACP010 ACP " + Enter
		Else						//Incesa e BellaCasa
			cSql += "From ACO050 ACO, ACP050 ACP " + Enter
		EndIf
		cSql += "Where 	ACO.ACO_FILIAL 	= '" + xFilial("ACO") + "' AND " + Enter
		cSql += "     	ACP.ACP_FILIAL 	= '" + xFilial("ACP") + "' AND " + Enter
		cSql += "		'" + dtEmis +"' 	>= ACP.ACP_YDATDE	AND " + Enter
		cSql += "		'" + dtEmis +"' 	<= ACP.ACP_YDATAT	AND " + Enter
		cSql += "		ACP.ACP_YESTCL 	= ''								AND " + Enter
		cSql += "		ACP.ACP_CODREG	= ACO.ACO_CODREG		AND " + Enter
		cSql += "		ACP.ACP_YCLASS	= '1'								AND " + Enter
		cSql += "		(ACO.ACO_CODCLI	= '" + nCli +"'			OR 	" + Enter
		cSql += "		ACO.ACO_GRPVEN	= '" + nGrpCli+"')	AND	" + Enter
		cSql += "		ACP.ACP_YFORMA	= '"+nFormat+"'			AND " + Enter
		cSql += "		ACO.ACO_YLINHA	= '"+nLinha+"'			AND " + Enter //Biancogres - Incesa - BellaCasa
		cSql += "		ACO.ACO_YTIPO 	= 'M'								AND " + Enter

		//Inserido por Wanisay em 13/08/12
		cSql += "		(ACO_YEXCLC NOT LIKE '%" + nCli +"%'    OR 	" + Enter
		cSql += "  		ACO_YEXCLG NOT LIKE '%" + nGrpCli+"%' ) AND	" + Enter

		cSql += "		ACP.D_E_L_E_T_	= ''		                AND	" + Enter
		cSql += "		ACO.D_E_L_E_T_ 	= '' AND ACO_MSBLQL <> '1' " + Enter
		If chkfile("X2")
			dbSelectArea("X2")
			dbCloseArea()
		EndIf
		TCQUERY cSql ALIAS "X2" NEW
		If X2->ACP_YPERMR <> 0
			nMargem	:= X2->ACP_YPERMR
			nRegra	:= X2->ACP_CODREG
		EndIf

		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		//Busca MARGEM por CLIENTE / GRUPO / PRODUTO / LOTE
		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		cSql := "SELECT ACP_YPERMR, ACP_YTPDES, ACP_CODREG  " + Enter
		If nLinha = "1"	//Biancogres
			cSql += "From ACO010 ACO, ACP010 ACP " + Enter
		Else						//Incesa e BellaCasa
			cSql += "From ACO050 ACO, ACP050 ACP " + Enter
		EndIf
		cSql += "Where 	ACO.ACO_FILIAL 	= '" + xFilial("ACO") + "' AND " + Enter
		cSql += "     	ACP.ACP_FILIAL 	= '" + xFilial("ACP") + "' AND " + Enter
		cSql += "		'" + dtEmis +"' >= ACP.ACP_YDATDE	AND " + Enter
		cSql += "		'" + dtEmis +"' <= ACP.ACP_YDATAT	AND " + Enter
		cSql += "		ACP.ACP_YESTCL 	= ''							AND " + Enter
		cSql += "		ACP.ACP_CODREG	= ACO.ACO_CODREG	AND " + Enter
		cSql += "		ACP.ACP_YCLASS	= '1'								AND " + Enter

		cSql += "		ACP.ACP_CODPRO	= '" + nProd +"' AND " + Enter
		//RETIRADO VALIDAÇÃO DO LOTE EM 25/05/15, POIS A REGRA NÃO ATENDE AO CENÁRIO ATUAL
		//If Empty(Alltrim(nLote))
		//	cSql += "			ACP.ACP_CODPRO	= '" + nProd +"' AND " + Enter
		//Else
		//	cSql += "			ACP.ACP_CODPRO	= '" + nProd +"' AND ACP.ACP_YLOTE = '" + nLote +"'	AND " + Enter
		//EndIf

		cSql += "		(ACO.ACO_CODCLI	= '" + nCli +"'		Or	" + Enter
		cSql += "		ACO.ACO_GRPVEN	= '" + nGrpCli+"')	AND " + Enter
		cSql += "		ACO.ACO_YLINHA	= '"+nLinha+"'	 		AND " + Enter //Biancogres - Incesa - BellaCasa
		cSql += "		ACO.ACO_YTIPO 	= 'M'								AND " + Enter

		//Inserido por Wanisay em 13/08/12
		cSql += "		(ACO_YEXCLC NOT LIKE '%" + nCli +"%'     Or " + Enter
		cSql += "		ACO_YEXCLG NOT LIKE '%" + nGrpCli+"%' ) AND	" + Enter

		cSql += "		ACP.D_E_L_E_T_	= ''		                AND " + Enter
		cSql += "		ACO.D_E_L_E_T_ 	= '' AND ACO_MSBLQL <> '1' " + Enter
		If chkfile("X2")
			dbSelectArea("X2")
			dbCloseArea()
		EndIf
		TCQUERY cSql ALIAS "X2" NEW

		If X2->ACP_YPERMR <> 0
			nMargem	:= X2->ACP_YPERMR
			nRegra	:= X2->ACP_CODREG
			//lProd   := .T.
		EndIf
	EndIf

	//±±±±±±±±±±±±±
	//PRODUTO
	//±±±±±±±±±±±±±
	//If !lProd
	If !Empty(nProd)

		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		//Busca MARGEM por PRODUTO / LOTE
		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		cSql := "SELECT ACP_YPERMR, ACP_YTPDES, ACP_CODREG  " + Enter
		If nLinha = "1"	//Biancogres
			cSql += "From ACO010 ACO, ACP010 ACP " + Enter
		Else						//Incesa e BellaCasa
			cSql += "From ACO050 ACO, ACP050 ACP " + Enter
		EndIf
		cSql += "Where 	ACO.ACO_FILIAL 	= '" + xFilial("ACO") + "'	AND " + Enter
		cSql += "     	ACP.ACP_FILIAL 	= '" + xFilial("ACP") + "'	AND " + Enter
		cSql += "		'" + dtEmis +"' >= ACP.ACP_YDATDE		AND " + Enter
		cSql += "		'" + dtEmis +"' <= ACP.ACP_YDATAT		AND " + Enter
		cSql += "		ACP.ACP_YESTCL 	= ''								AND " + Enter
		cSql += "		ACP.ACP_CODREG	= ACO.ACO_CODREG		AND " + Enter
		cSql += "		ACP.ACP_YVEND		= ''								AND " + Enter
		cSql += "		ACO.ACO_CODCLI	= '' 								AND " + Enter
		cSql += "		ACO.ACO_GRPVEN	= ''								AND " + Enter
		cSql += "		ACP.ACP_CODPRO  <> '' 						  AND " + Enter
		cSql += "		ACP.ACP_YCLASS	= '1'								AND " + Enter

		cSql += "		ACP.ACP_CODPRO	= '" + nProd +"' AND " + Enter
		//RETIRADO VALIDAÇÃO DO LOTE EM 25/05/15, POIS A REGRA NÃO ATENDE AO CENÁRIO ATUAL
		//If Empty(Alltrim(nLote))
		//	cSql += "		ACP.ACP_CODPRO	= '" + nProd +"' AND " + Enter
		//Else
		//	cSql += "		ACP.ACP_CODPRO	= '" + nProd +"' AND ACP.ACP_YLOTE = '" + nLote +"'	AND " + Enter
		//EndIf

		cSql += "		ACO.ACO_YLINHA	= '"+nLinha+"'			AND " + Enter //Biancogres - Incesa - BellaCasa
		cSql += "		ACO.ACO_YTIPO 	= 'M'								AND " + Enter

		//Inserido por Wanisay em 13/08/12
		cSql += "		(ACO_YEXCLC NOT LIKE '%" + nCli +"%'     Or " + Enter
		cSql += "	    ACO_YEXCLG NOT LIKE '%" + nGrpCli+"%' ) AND	" + Enter

		cSql += "		ACP.D_E_L_E_T_	= ''							AND 			" + Enter
		cSql += "		ACO.D_E_L_E_T_ 	= '' AND ACO_MSBLQL <> '1' 	" + Enter
		If chkfile("X2")
			dbSelectArea("X2")
			dbCloseArea()
		EndIf
		TCQUERY cSql ALIAS "X2" NEW
		If X2->ACP_YPERMR <> 0
			nMargem	:= X2->ACP_YPERMR
			nRegra	:= X2->ACP_CODREG
		EndIf
	EndIf

	//Grava as variaveis finais para retorno da Funcao
	aadd(aRet,nMargem)
	aadd(aRet,nRegra)

Return(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fCalcComiss     ºAutor  ³Ranisses A. Corona  º Data ³  29/08/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Busca a Margem para utilizar no Pedido de Venda.                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Faturamento                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function fCalcComiss(cFil,cPref,cNum,cParc,cTipo,cPos)
	Local aComis 	:= {}
	Local aBase		:= {}
	Local nBase		:= 0
	Local nComis	:= 0
	Local aArea 	:= GetArea()
	Local n

	//A variavel cPos define e posicao do vendedor do titulo (1, 2, 3, 4, 5 ou 0 para todos)

	If Alltrim(cTipo) == "FT"
		//Posiciona nos Titulos Originais
		cAliasTmp := GetNextAlias()
		BeginSql Alias cAliasTmp
			SELECT *
			FROM  %Table:SE1%
			WHERE E1_FILIAL = %Exp:cFil% AND E1_FATPREF = %Exp:cPref% AND E1_FATURA = %Exp:cNum% AND E1_YPARCFT = %Exp:cParc% AND E1_TIPO <> %Exp:cTipo% AND %NOTDEL%
		EndSql

		While !(cAliasTmp)->(EOF())
			aComis	:= Fa440Comis((cAliasTmp)->R_E_C_N_O_,.F.,.F.,,,)
			If cPos <> 0
				nBase	:= nBase  + aComis[cPos][2]	//Base Comissão
				nComis	:= nComis + aComis[cPos][6]	//Valor Comissão
			Else
				If Len(aBase) == 0
					aBase	:= aComis				//Comissão
				Else
					For n := 1 to Len(aBase)
						aBase[n][2]  := aBase[n][2] + aComis[n][2]
						aBase[n][6]  := aBase[n][6] + aComis[n][6]
					Next
				EndIf
			EndIf
			(cAliasTmp)->(dbSkip())
		End
	Else
		//Posiciona no Titulo
		cAliasTmp := GetNextAlias()
		BeginSql Alias cAliasTmp
			SELECT *
			FROM  %Table:SE1%
			WHERE E1_FILIAL = %Exp:cFil% AND E1_PREFIXO = %Exp:cPref% AND E1_NUM = %Exp:cNum% AND E1_PARCELA = %Exp:cParc% AND E1_TIPO = %Exp:cTipo% AND %NOTDEL%
		EndSql

		While !(cAliasTmp)->(EOF())
			aComis	:= Fa440Comis((cAliasTmp)->R_E_C_N_O_,.F.,.F.,,,)
			If Len(aComis) > 0
				If cPos <> 0
					nBase	:= nBase  + aComis[cPos][2]	//Base Comissão
					nComis	:= nComis + aComis[cPos][6]	//Valor Comissão
				Else
					aBase	:= aComis				//Comissão
				EndIf
			EndIf
			(cAliasTmp)->(dbSkip())
		End
	EndIf

	If cPos <> 0
		aadd(aBase,nBase)
		aadd(aBase,nComis)
	EndIf

	RestArea(aArea)
	(cAliasTmp)->(dbCloseArea())

Return(aBase)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fPreencheBanco  ºAutor  ³Ranisses A. Corona  º Data ³  29/08/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Busca a Margem para utilizar no Pedido de Venda.                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Faturamento                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function fPreencheBanco()

	MV_PAR02 := SA6->A6_COD
	MV_PAR03 := SA6->A6_AGENCIA
	MV_PAR04 := SA6->A6_AGENCIA
	MV_PAR05 := SA6->A6_NUMCON
	MV_PAR06 := SA6->A6_NUMCON

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fBuscaPedido    ºAutor  ³Ranisses A. Corona  º Data ³  29/08/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Busca a Margem para utilizar no Pedido de Venda.                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Faturamento                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function fBuscaPedido(cFil,cSer,cNum,cCli,cLj)
	Local cSql		:= ""
	Local Enter 	:= CHR(13)+CHR(10)
	Local aRet		:= {}

	//Consulta NF
	cSql := "SELECT D2_PEDIDO							" + Enter
	cSql += "FROM "+RetSqlName("SD2")+" WITH (NOLOCK)	" + Enter
	cSql += "WHERE	D2_FILIAL   = '"+cFil+"' AND		" + Enter
	cSql += "		D2_SERIE	= '"+cSer+"' AND		" + Enter
	cSql += "		D2_DOC		= '"+cNum+"' AND 		" + Enter
	cSql += "		D2_CLIENTE	= '"+cCli+"' AND 		" + Enter
	cSql += "		D2_LOJA 	= '"+cLj+"'  AND 		" + Enter
	cSql += "		D_E_L_E_T_	= ''		 			" + Enter
	cSql += "GROUP BY D2_PEDIDO				 			" + Enter
	If chkfile("TMP")
		dbSelectArea("TMP")
		dbCloseArea()
	EndIf
	TCQUERY cSql ALIAS "TMP" NEW

	While  !TMP->(EOF())

		aadd( aRet, TMP->(D2_PEDIDO) )
		TMP->(DBSKIP())

	End

	//Fecha arquivo de trabalho
	If chkfile("TMP")
		dbSelectArea("TMP")
		dbCloseArea()
	EndIf

Return(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fSitFin  		  ºAutor  ³Ranisses A. Corona  º Data ³  16/12/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Financeiro                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function fSitFin(cCli,cLj,lLM,nPed)
	Local TOTAL_RA	:= 0
	Local TOTTITRA	:= 0
	Local TOTPEDRA	:= 0
	Local cSql		:= ""
	Local Enter 	:= CHR(13)+CHR(10)
	Local SALDO		:= 0

	//Posiciona no Cliente, para tratamento de Grupo de Cliente
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek(xFilial("SA1")+cCli+cLj,.T.)

	//SELECIONANDO O RA PARA O PEDIDO
	CSQL := "SELECT ISNULL(SUM(E1_SALDO),0) AS TOTAL " + Enter
	If lLM
		CSQL += "FROM SE1070 SE1, SA1010 SA1 " + Enter
	Else
		CSQL += "FROM "+RETSQLNAME("SE1")+" SE1, "+RETSQLNAME("SA1")+" SA1  " + Enter
	EndIf
	cSql += " WHERE	SE1.E1_FILIAL	= '"+xFilial("SE1")+"'	AND " + Enter
	cSql += "		SE1.E1_CLIENTE	= SA1.A1_COD			AND	" + Enter
	cSql += " 		SE1.E1_LOJA		= SA1.A1_LOJA			AND	" + Enter
	IF ALLTRIM(SA1->A1_GRPVEN) <> "" .AND. SA1->A1_YTIPOLC == "G"
		CSQL += "		SA1.A1_GRPVEN	= '"+SA1->A1_GRPVEN+"'	AND SA1.A1_YTIPOLC = 'G' AND 	" + ENTER
	ELSE
		CSQL += "		SA1.A1_COD = '"+cCli+"' AND SA1.A1_LOJA = '"+cLj+"'	AND " + ENTER
	END IF
	//Tratamento para nova modalidade de RA
	If Empty(Alltrim(nPed))
		CSQL += "		SE1.E1_PEDIDO	= '' AND  " + Enter
	Else
		CSQL += "		SE1.E1_PEDIDO	= '"+nPed+"' AND  " + Enter
	EndIf
	CSQL += "		SE1.E1_TIPO		= 'RA' AND  " + Enter
	CSQL += "		SE1.E1_SALDO	> 0 AND  " + Enter
	CSQL += "		SE1.D_E_L_E_T_	= '' AND  " + Enter
	CSQL += "		SA1.D_E_L_E_T_	= ''  " + Enter
	If chkfile("_RANEW")
		dbSelectArea("_RANEW")
		dbCloseArea()
	EndIf
	TCQUERY CSQL ALIAS "_RANEW" NEW

	//Grava do Saldo Total Total de RA em Aberto
	TOTAL_RA := _RANEW->TOTAL

	//Fecha Arquivo Temporario
	_RANEW->(DbCloseArea())

	If Empty(Alltrim(nPed))

		//SELECIONANDO TODOS OS PEDIDO DE RA JA FATURADOS MAS QUE NAO FORAM DADO BAIXA AINDA
		CSQL := "SELECT ISNULL(SUM(E1_SALDO),0) SALDO	" + Enter
		If lLM
			CSQL += "FROM SE1070 SE1, SF2070 SF2, SE4010 SE4, SA1010 SA1  " + Enter
		Else
			CSQL += "FROM "+RETSQLNAME("SE1")+" SE1, "+RETSQLNAME("SF2")+" SF2, "+RETSQLNAME("SE4")+" SE4, "+RETSQLNAME("SA1")+" SA1  " + Enter
		EndIf
		cSql += " WHERE	SE1.E1_FILIAL	= '"+xFilial("SE1")+"'	AND " + Enter
		cSql += "		SE1.E1_CLIENTE	= SA1.A1_COD			AND	" + Enter
		cSql += " 		SE1.E1_LOJA		= SA1.A1_LOJA			AND	" + Enter
		IF ALLTRIM(SA1->A1_GRPVEN) <> "" .AND. SA1->A1_YTIPOLC == "G"
			CSQL += "		SA1.A1_GRPVEN	= '"+SA1->A1_GRPVEN+"'	AND SA1.A1_YTIPOLC = 'G' AND 	" + ENTER
		ELSE
			CSQL += "		SA1.A1_COD = '"+cCli+"' AND SA1.A1_LOJA = '"+cLj+"'	AND " + ENTER
		END IF
		CSQL += "		SE1.E1_SALDO	> 0 				AND	" + Enter
		CSQL += "		SE1.E1_PEDIDO	= '' 				AND " + Enter
		CSQL += "		SF2.F2_SERIE    = SE1.E1_PREFIXO	AND	" + Enter
		CSQL += "		SF2.F2_DOC		= SE1.E1_NUM		AND " + Enter
		CSQL += "		SF2.F2_CLIENTE	= SE1.E1_CLIENTE	AND " + Enter
		CSQL += "		SF2.F2_LOJA		= SE1.E1_LOJA		AND " + Enter
		CSQL += "		SF2.F2_COND 	= E4_CODIGO 		AND " + Enter
		CSQL += "		SF2.F2_TIPO		= 'N'				AND " + Enter
		CSQL += "       (SE4.E4_DESCRI	LIKE '%ANTE%' OR SE4.E4_CODIGO IN ('145','975')	) AND " + Enter
		CSQL += "		SE1.D_E_L_E_T_	= '' AND	" + Enter
		CSQL += "      	SF2.D_E_L_E_T_	= '' AND	" + Enter
		CSQL += "      	SE4.D_E_L_E_T_	= '' AND	" + Enter
		CSQL += "		SA1.D_E_L_E_T_	= ''		" + Enter
		If chkfile("_PEDFAT")
			dbSelectArea("_PEDFAT")
			dbCloseArea()
		EndIf
		TCQUERY CSQL ALIAS "_PEDFAT" NEW

		//Grava o Saldo Total de Titulos a serem Compensado
		TOTTITRA := _PEDFAT->SALDO

		//SELECIONANDO OS PEDIDO DE VENDA DE RA DA EMPRESA CORRENTE COM CARGA JÁ CADASTRADA (C9_AGREG <> '')
		CSQL := "SELECT  SALDO = CASE 																					" + Enter
		CSQL += "					WHEN SUM(VLRIMP_LM) = 0 THEN ROUND(ISNULL(SUM(C9_QTDLIB/C6_QTDVEN*VLRIMP_ORI),0),2)	" + Enter
		CSQL += "					ELSE ROUND(ISNULL(SUM(C9_QTDLIB/C6_QTDVEN*VLRIMP_LM),0),2)							" + Enter
		CSQL += "				END														" + Enter
		CSQL += "FROM																	" + Enter
		CSQL += "(SELECT C6_YVLIMP AS VLRIMP_ORI,										" + Enter
		CSQL += "	   ISNULL((SELECT C6_YVLIMP FROM SC6070 WHERE C6_FILIAL = '"+xFilial("SC6")+"' AND C6_NUM IN (SELECT C5_NUM FROM SC5070 WHERE C5_FILIAL = '"+xFilial("SC5")+"' AND C5_YPEDORI = SC5.C5_NUM AND D_E_L_E_T_ = '' ) AND C6_PRODUTO = SC6.C6_PRODUTO AND C6_ITEM = SC6.C6_ITEM AND D_E_L_E_T_ = ''),0) VLRIMP_LM, " + Enter
		CSQL += "	   C9_QTDLIB,														" + Enter
		CSQL += "	   C6_QTDVEN														" + Enter
		CSQL += "FROM "+RetSqlName("SC9")+" SC9 INNER JOIN "+RetSqlName("SC6")+" SC6 ON	" + Enter
		CSQL += "		C9_PEDIDO	= C6_NUM	AND	" + Enter
		CSQL += "		C9_CLIENTE	= C6_CLI	AND	" + Enter
		CSQL += "		C9_LOJA		= C6_LOJA	AND	" + Enter
		CSQL += "		C9_ITEM		= C6_ITEM		" + Enter
		CSQL += "		INNER JOIN "+RetSqlName("SC5")+" SC5 ON	" + Enter
		CSQL += "		C9_PEDIDO	= C5_NUM		AND			" + Enter
		CSQL += "		C9_CLIENTE	= C5_CLIENTE	AND 		" + Enter
		CSQL += "		C9_LOJA		= C5_LOJACLI				" + Enter
		CSQL += "		INNER JOIN "+RetSqlName("SE4")+" SE4 ON	" + Enter
		CSQL += "		C5_CONDPAG  = E4_CODIGO					" + Enter
		CSQL += "		INNER JOIN "+RetSqlName("SF4")+" SF4 ON	" + Enter
		CSQL += "		C6_TES      = F4_CODIGO					" + Enter
		CSQL += "		INNER JOIN "+RetSqlName("SA1")+" SA1 ON	" + Enter
		CSQL += "		C5_CLIENTE	= A1_COD		AND			" + Enter
		CSQL += "		C5_LOJACLI	= A1_LOJA			 		" + Enter
		CSQL += "WHERE	C9_FILIAL	= '"+xFilial("SC9")+"'	AND	" + Enter
		CSQL += "		C6_FILIAL	= '"+xFilial("SC6")+"'  AND " + Enter
		CSQL += "		E4_FILIAL	= '"+xFilial("SE4")+"'  AND	" + Enter
		CSQL += "		A1_FILIAL	= '"+xFilial("SA1")+"'  AND	" + Enter
		CSQL += "		C9_AGREG	<> ''	AND 		" + Enter
		CSQL += "		C9_NFISCAL	= ''	AND 		" + Enter
		CSQL += "		C9_BLCRED	= ''	AND			" + Enter
		CSQL += "		C9_BLEST	= ''	AND 		" + Enter
		CSQL += "		(E4_DESCRI LIKE '%ANTE%' OR E4_CODIGO IN ('145','975') ) AND	" + Enter
		CSQL += "		F4_DUPLIC   = 'S'		AND 	" + Enter
		IF ALLTRIM(SA1->A1_GRPVEN) <> "" .AND. SA1->A1_YTIPOLC == "G"
			CSQL += "		A1_GRPVEN = '"+SA1->A1_GRPVEN+"' AND A1_YTIPOLC = 'G' AND 	" + ENTER
		ELSE
			CSQL += "		A1_COD = '"+cCli+"' AND A1_LOJA = '"+cLj+"'	AND " + ENTER
		END IF
		CSQL += "		SC9.D_E_L_E_T_	= ''  	AND 	" + Enter
		CSQL += "		SC6.D_E_L_E_T_	= ''	AND 	" + Enter
		CSQL += "		SC5.D_E_L_E_T_	= ''	AND  	" + Enter
		CSQL += "		SE4.D_E_L_E_T_  = ''	AND		" + Enter
		CSQL += "		SF4.D_E_L_E_T_  = ''	AND		" + Enter
		CSQL += "		SA1.D_E_L_E_T_  = '') AS TMP	" + Enter
		If chkfile("PEDIDO")
			dbSelectArea("PEDIDO")
			dbCloseArea()
		EndIf
		TCQUERY CSQL ALIAS "PEDIDO" NEW

		//Armazena o Saldo de Pedidos de RA em Aberto
		TOTPEDRA := PEDIDO->SALDO

		SALDO 	:= TOTAL_RA - (TOTTITRA + TOTPEDRA)

		//Fecha Arquivo Temporario
		PEDIDO->(DbCloseArea())
		_PEDFAT->(DbCloseArea())

	Else

		SALDO 	:= TOTAL_RA

	EndIf

Return(SALDO)

/*
##############################################################################################################
# PROGRAMA...: MailAtendente
# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 28/02/2014   
# DESCRICAO..: RETORNAR QUAL E O ATENDENTE DE ACORDO COM A LINHA DE PRODUTO/VENDEDOR NO PEDIDO DE VENDA
##############################################################################################################     
*/
User Function MailAtendente(cEmpresa, cPedido, cVendedor, cCliente, cLoja)

	Local cAtendente	:= ''
	Local cQuery		:= ""
	Local aArea			:= GetArea()
	
	If Empty(cPedido) .Or. Empty(cVendedor) .Or. Empty(cCliente) .Or. Empty(cCliente) .Or. Empty(cLoja)
		Return ''
	EndIf
	
	If !(Empty(cEmpresa))
	
		cQuery := " SELECT C5_YEMP FROM SC5"+cEmpresa+"0  						"
		cQuery += " WHERE C5_FILIAL = '"+xFilial("SC5")+"'						"
		cQuery += " AND	C5_NUM 		= '"+cPedido+"' 							"
		cQuery += " AND	D_E_L_E_T_  = ''			 							"
		
		TCQUERY cQuery ALIAS "QRY_SC5" NEW
	
		If (!QRY_SC5->(Eof()))
		
			
			oGerenteAtendente	:= TGerenteAtendente():New()
			oResult 			:= oGerenteAtendente:GetCliente(QRY_SC5->C5_YEMP, cCliente, cLoja, cVendedor)
			
			cAtendente			:= 	oResult:cEmailAten
			
		EndIf
		
		QRY_SC5->(DbCloseArea())
	
	EndIf
	
	RestArea(aArea)
	
	
	/*
	Local cAtendente	:= ''
	Local cTpSeg 		:= ''
	Local lAchou 		:= .F.
	Local cLinha 		:= ''
	
	cTpSeg := (Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja,"A1_YTPSEG"))

	//SE FOR EMPRESA LM, TRATATIVA DIFERENTE PARA BUSCAR DADOS NA TABELA ZZI
	If cEmpresa =='01' .Or. cEmpresa =='05'
		//BUSCAR ATENDENTE DE ACORDO COM O VENDEDOR
		//cQuery := " SELECT * FROM ZZI050 ZZI "
		cQuery := "SELECT * FROM ZZI"+cEmpresa+"0 ZZI "
		cQuery += " WHERE ZZI.ZZI_VEND =  '" +cVendedor+ "' AND "
		cQuery += " ZZI.D_E_L_E_T_= '' "

		TCQUERY cQuery ALIAS "QRY_ATEND" NEW

		WHILE !QRY_ATEND->(EOF())

			If(QRY_ATEND->ZZI_TPSEG == cTpSeg)
				cAtendente := QRY_ATEND->ZZI_ATENDE
				lAchou := .T.
			EndIf

			If lAchou
				exit
			EndIf

			QRY_ATEND->(DBSKIP())
		ENDDO
		QRY_ATEND->(DbCloseArea())

	Else
		//	CSQL := "SELECT C5_YLINHA FROM "+RETSQLNAME("SC5")+" AS SC5_TMP "
		CSQL := "SELECT C5_YLINHA FROM SC5"+cEmpresa+"0 AS SC5_TMP "
		CSQL += "WHERE SC5_TMP.C5_FILIAL = '"+xFilial("SC5")+"'  "
		CSQL += "AND SC5_TMP.C5_NUM = '"+cPedido+"' "

		TCQUERY CSQL ALIAS "QRY_SC5" NEW

		cLinha := QRY_SC5->C5_YLINHA
		QRY_SC5->(DbCloseArea())

		cQuery := ""
		cQuery += " SELECT * FROM "

		//EMAIL CONFIGURADO DE ACORDO COM A EMPRESA
		Do Case
		Case Alltrim(cLinha) == '1'
			cQuery += " ZZI010 ZZI"

		Case Alltrim(cLinha) == '2'
			cQuery += " ZZI050 ZZI"

		Case Alltrim(cLinha) == '3'
			cQuery += " ZZI050 ZZI"

		OTHERWISE
			cQuery += " ZZI050 ZZI"
		EndCase

		cQuery += " WHERE ZZI.ZZI_VEND =  '" +cVendedor+ "' AND "
		cQuery += " ZZI.D_E_L_E_T_= '' "

		TCQUERY cQuery ALIAS "QRY_ATEND" NEW

		WHILE !QRY_ATEND->(EOF())

			If(QRY_ATEND->ZZI_TPSEG == cTpSeg)
				cAtendente := QRY_ATEND->ZZI_ATENDE
				lAchou := .T.
			EndIf

			If lAchou
				exit
			EndIf

			QRY_ATEND->(DBSKIP())
		ENDDO
		QRY_ATEND->(DbCloseArea())
	EndIf

	//DbCloseArea("ZZI")

	If !Empty(cAtendente)
		cAtendente := UsrRetMail(cAtendente)
	EndIf

	If !('@' $ cAtendente)
		cAtendente := ''
	EndIf
	*/
	
Return cAtendente

/*
##############################################################################################################
# PROGRAMA...: EmailWF
# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 14/03/2014   
# DESCRICAO..: RETORNAR PARA QUAL EMAIL SERA ENVIADO O WORKFLOW DE ACORDO COM A TABELA Z28
##############################################################################################################     
*/
User Function EmailWF(pRotina, pEmp, pClasse, pTpDest)

	Local cRet := ""

	If Empty(pClasse)
		pClasse := ""
	EndIf
	
	If Empty(pTpDest)
		pTpDest := ""
	EndIf

	dbSelectArea("Z28")
	dbSetOrder(1)
	If dbSeek(XFilial("Z28")+ pRotina)
		//If dbSeek( pRotina)

		While !Eof() //.And. Alltrim(Z28->Z28_ROTINA) == Alltrim(pRotina) .AND. (Z28->Z28_EMPRES == pEmp .OR. Z28_REPLIC == 'S') .And. (Empty(Z28->Z28_CLASSE) .OR. Alltrim(Z28->Z28_CLASSE) == Alltrim(pClasse))
			If Alltrim(Z28->Z28_ROTINA) == Alltrim(pRotina) .AND. (Z28->Z28_EMPRES == pEmp .OR. Z28_REPLIC == 'S' .Or. Alltrim(Z28->Z28_EMPRES)=='*' .Or. Alltrim(Z28->Z28_EMPRES)=='') .And. (Empty(Z28->Z28_CLASSE) .OR. Alltrim(Z28->Z28_CLASSE) == Alltrim(pClasse)) .And. (Empty(Alltrim(pTpDest)) .OR. Alltrim(Z28->Z28_TP_ENV) == Alltrim(pTpDest))
				cRet+= Alltrim(Z28->Z28_EMAIL) +";"
			EndIf
			dbSelectArea("Z28")
			dbSkip()
		EndDo
	EndIf

	dbCloseArea("Z28")
Return cRet


/*
##############################################################################################################
# PROGRAMA...: fBuscaMVA
# AUTOR......: Ranisses A. Corona
# DATA.......: 05/05/2014   
# DESCRICAO..: RETORNAR O MVA, DE ACORDO COM PRODUTO/UF - TRATAMENTO PARA MUNDIALI
##############################################################################################################     
*/
User Function fBuscaMVA(pNCM,pEST,pGRTRIB,pData)

	Local 	cSql := ""
	Local 	aRet := {} //Array com os retornos (.T. ou .F. // MVA // % do ICMS / % Base ICMS ST)

	cSql := ""
	cSql += "SELECT ROW_NUMBER() OVER(ORDER BY Z30_EST) AS ROW_ID,	"
	cSql += "		Z30_MVA, Z30_ALICMS, Z30_RDBCST					"
	cSql += "FROM "+RetSqlName("Z30")+"								"
	cSql += "WHERE Z30_FILIAL = '"+xFilial("Z30")+"'	AND 		"
	cSql += "      Z30_POSIPI = '"+Alltrim(pNCM)+"'		AND 		"
	cSql += "      Z30_EST    = '"+Alltrim(pEST)+"'		AND			"
	cSql += "      Z30_GRTRIB = '"+Alltrim(pGRTRIB)+"'	AND			"
	cSql += "      Z30_VALIDE <= '"+Dtos(pData)+"' AND 				"
	cSql += "      Z30_VALIAT >= '"+Dtos(pData)+"' AND 				"
	cSql += "      D_E_L_E_T_ = ''									"

	If chkfile("_RAC")
		dbSelectArea("_RAC")
		dbCloseArea()
	EndIf
	TCQUERY cSql ALIAS "_RAC" NEW

	If !_RAC->(EOF())
		If _RAC->ROW_ID == 1
			aadd(aRet,.T.)
			aadd(aRet,_RAC->Z30_MVA)
			aadd(aRet,_RAC->Z30_ALICMS)
			aadd(aRet,_RAC->Z30_RDBCST)	//Novo
		Else
			aadd(aRet,.F.)
			aadd(aRet,0)
			aadd(aRet,0)
			aadd(aRet,0) //Novo
			MsgBox("Existe mais de uma tabela cadastrada para este NCM/UF/GRP.TRIBUTAÇÃO. Favor procurar o Setor Contábil/Fiscal!","fBuscaMVA","STOP")
		EndIf
	Else
		aadd(aRet,.F.)
		aadd(aRet,0)
		aadd(aRet,0)
		aadd(aRet,0) //Novo
		MsgBox("Não existe tabela de MVA para este NCM/UF/GRP.TRIBUTAÇÃO. Favor procurar o Setor Contábil/Fiscal!","fBuscaMVA","STOP")
	EndIf

	_RAC->(DbCloseArea())

Return(aRet)



//ATUALIZA SX3 X BANCO DE DADOS
User Function RACSX3()

		//Inicializa o ambiente
	RPCSetType(3)

	WfPrepEnv("14", "01")

	__SetX31Mode(.F.)
	If Select("SD1") > 0
		SD1->(dbCloseArea())
	EndIf
	X31UpdTable("SD1")
	
	

Return

/*
##############################################################################################################
# PROGRAMA...: A1FastFilter
# AUTOR......: Ranisses A. Corona
# DATA.......: 08/01/2015   
# DESCRICAO..: Demonstrar a otimização de Filtro nas consultas SXB
##############################################################################################################     
*/
User Function A1FastFilter()
	Local cA1Filter	:= ""

	If !Empty(Alltrim(cRepAtu))
		cA1Filter	+= "@#"
		cA1Filter	+= "SA1->("
		cA1Filter	+= "A1_FILIAL=='"+xFilial("SA1")+"'"
		cA1Filter	+= " .AND. 	"
		cA1Filter	+= " (		"
		cA1Filter	+= "A1_VEND    == '"+cRepAtu+"' .OR. A1_YVENDB2 == '"+cRepAtu+"' .OR. A1_YVENDB3 == '"+cRepAtu+"' .OR. 	"
		cA1Filter	+= "A1_YVENDI  == '"+cRepAtu+"' .OR. A1_YVENDI2 == '"+cRepAtu+"' .OR. A1_YVENDI3 == '"+cRepAtu+"' .OR. 	"
		cA1Filter	+= "A1_YVENBE1 == '"+cRepAtu+"' .OR. A1_YVENBE2 == '"+cRepAtu+"' .OR. A1_YVENBE3 == '"+cRepAtu+"' .OR. 	"
		cA1Filter	+= "A1_YVENVT1 == '"+cRepAtu+"' .OR. A1_YVENVT2 == '"+cRepAtu+"' .OR. A1_YVENVT3 == '"+cRepAtu+"' .OR. 	"
		cA1Filter	+= "A1_YVENML1 == '"+cRepAtu+"' .OR. A1_YVENML2 == '"+cRepAtu+"' .OR. A1_YVENML3 == '"+cRepAtu+"' .OR. 	"
		cA1Filter	+= "A1_YVENPEG == '"+cRepAtu+"' .OR.  "
		cA1Filter	+= "A1_YVENVI1 == '"+cRepAtu+"' ) 	  "
		cA1Filter	+= " )		"
		cA1Filter	+= "@#"
	EndIf

Return( cA1Filter )

/*
##############################################################################################################
# PROGRAMA...: fBuscaTxBI
# AUTOR......: Ranisses A. Corona
# DATA.......: 24/06/2015  
# DESCRICAO..: Busca as Taxas utilizadas no Cálculo da MARGEM
##############################################################################################################     
*/
User Function fBuscaTxBI(nMarca,nTipo,nData)
	Local 	cSql := ""
	Local 	nRet := 0

	cSql := ""
	cSql += "SELECT Z40_PERC						"
	cSql += "FROM "+RetSqlName("Z40")+"				"
	If Len(nMarca) == 4
		cSql += "WHERE Z40_MARCA  = '"+nMarca+"'	AND "  //MARCA
	Else
		cSql += "WHERE SUBSTRING(Z40_MARCA,1,2) = '"+nMarca+"'	AND " //EMPRESA
	EndIf
	cSql += "      Z40_TIPO   = '"+nTipo+"' 	AND "
	cSql += "      Z40_DATDE  <= '"+(nData)+"' 	AND	"
	cSql += "      Z40_DATATE >= '"+(nData)+"' 	AND "
	cSql += "      D_E_L_E_T_ = ''					"
	If chkfile("_Z40")
		dbSelectArea("_Z40")
		dbCloseArea()
	EndIf
	TCQUERY cSql ALIAS "_Z40" NEW

	nRet := _Z40->Z40_PERC
	_Z40->(DbCloseArea())

Return( nRet )


/*
##############################################################################################################
# PROGRAMA...: fVlLbDes
# AUTOR......: Ranisses A. Corona
# DATA.......: 17/07/2015  
# DESCRICAO..: Valida se o Pedido está aprovado ou não, pode Desconto
##############################################################################################################     
*/
User Function fVlLbDes(nPed,nCliOri)
	Local cSql	:= ""
	Local lRet	:= .F.

	If Empty(Alltrim(nCliOri))
		cSql := ""
		cSql += "SELECT COUNT(*) COUNT					"
		cSql += "FROM "+RetSqlName("SC5")+"				"
		cSql += "WHERE C5_NUM	  =  '"+nPed+"' AND 	"
		cSql += "      C5_YAPROV  <> '' AND			    "
		cSql += "      D_E_L_E_T_ =  ''					"
	Else
		cSql := ""
		cSql += "SELECT COUNT(*) COUNT							"
		cSql += "FROM SC5070									"
		cSql += "WHERE C5_YPEDORI =  '"+nPed+"' AND 			"
		cSql += "      C5_YEMPPED = '"+AllTrim(CEMPANT)+"' AND	"   //Fernando em 31/08/17 - OS: 2013-17 - Estava confudindo pedidos Bianco e Incesa na LM
		cSql += "      C5_YAPROV  <> '' AND			   			"
		cSql += "      D_E_L_E_T_ =  ''							"
	EndIf
	If chkfile("_SC5")
		dbSelectArea("_SC5")
		dbCloseArea()
	EndIf
	TCQUERY cSql ALIAS "_SC5" NEW

	lRet := _SC5->COUNT > 0

	_SC5->(DbCloseArea())

Return(lRet)


/*
##############################################################################################################
# PROGRAMA...: fDifICMS
# AUTOR......: Ranisses A. Corona
# DATA.......: 28/09/2015  
# DESCRICAO..: 
##############################################################################################################     
*/
User Function fDifICMS(nSubTp,nCli,nLj,nProd,nICMS)
	Local nDifICMS	:= 0
	Local nUF   	:= Posicione("SA1",1,xFilial("SA1")+nCli+nLj,"A1_EST")
	Local nSufr 	:= Alltrim(SA1->A1_SUFRAMA)
	Local nPct		:= Posicione("SB1",1,xFilial("SB1")+nProd,"B1_YPCGMR3")

	//Produtos importados
	If Alltrim(nPct) $ "9_B_C_"
		If Alltrim(nSubTp) == "FE"
			If nUF == "EX"
				If nICMS == 0
					nDifICMS := 0.96
				Else
					nDifICMS := 0
				EndIf
			ElseIf nUF == "ES"
				If nICMS == 0
					nDifICMS := 0.83
				Else
					nDifICMS := 0
				EndIf
			Else
				nDifICMS := 0
			EndIf
		ElseIf Alltrim(nSubTp) == "A" //Amostra
			If nICMS == 0
				nDifICMS := 1
			Else
				nDifICMS := 0
			EndIf
		Else
			//Para o estado do ES
			If nUF == "ES"
				If nICMS == 17
					nDifICMS := 1
				Else
					nDifICMS := 0
				EndIf
				//Para os clientes do SUFRAMA
			ElseIf !Empty(nSufr)
				If nICMS == 0
					nDifICMS := 1
				ElseIf nICMS == 17
					nDifICMS := 1.19
				Else
					nDifICMS := 0
				EndIf
				//Para outros estados
			Else
				If nICMS == 4
					nDifICMS := 1
				ElseIf nICMS == 17
					nDifICMS := 1.19
				Else
					nDifICMS := 0
				EndIf
			EndIf
		EndIf
		//Produtos com produção Biancogres/Incesa
	Else
		If Alltrim(nSubTp) == "FE"
			If nUF == "EX"
				If nICMS == 0
					nDifICMS := 0.88
				Else
					nDifICMS := 0
				EndIf
			ElseIf nUF == "ES"
				If nICMS == 0
					nDifICMS := 0.83
				Else
					nDifICMS := 0
				EndIf
			Else
				nDifICMS := 0
			EndIf
		ElseIf Alltrim(nSubTp) == "A" //Amostra
			If nICMS == 0
				nDifICMS := 1
			Else
				nDifICMS := 0
			EndIf
		Else
			//Para o estado do ES
			If nUF == "ES"
				If nICMS == 17
					nDifICMS := 1
				Else
					nDifICMS := 0
				EndIf
				//Para os clientes do SUFRAMA
			ElseIf !Empty(nSufr)
				If nICMS == 0
					nDifICMS := 1
				ElseIf nICMS == 17
					nDifICMS := 1.05
				Else
					nDifICMS := 0
				EndIf
				//Para outros estados
			Else
				If nICMS == 12
					nDifICMS := 1
				ElseIf nICMS == 17
					nDifICMS := 1.05
				Else
					nDifICMS := 0
				EndIf
			EndIf
		EndIf
	EndIf

Return(nDifICMS)


/*/{Protheus.doc} fGetPrcLM
@description Buscar o Preco de Tabela para pedidos da origem para cliente LM - usado quando alterando pedido para LM
@author Ranisses A. Corona
@since 05/10/2015
@version undefined
@param wPed, , descricao
@param wEmpPed, , descricao
@param wProduto, , descricao
@param wItem, , descricao
@param wCli, , descricao
@param wLoja, , descricao
@param cFilOri, characters, descricao
@type function
/*/
User Function fGetPrcLM(wPed,wEmpPed,wProduto,wItem,wCli,wLoja,_nFator)
	Local nPrcTab 	:= 0
	Local cSql 	  	:= ""
	Local _cTabPar	:= ""
	Local _cTabLM	:= ""

	Default _nFator := 0

	//Posiciona no Cliente
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(XFilial("SA1")+wCli+wLoja))

	_nFator		:= U_LMFatRed(SA1->A1_EST)

	//Verifica se Produto possui Tabela de Preço Especifica (Mundi e OutSourcing)
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(XFilial("SB1")+wProduto))
	_cTabPar := "FA_TABPCT"+AllTrim(SB1->B1_YPCGMR3)
	_cTabLM := AllTrim(GetNewPar(_cTabPar,""))

	//Busca Tabela de Preço
	If !Empty(_cTabLM)
		cSql	:= ""
		cSql	+= "SELECT DA1_PRCVEN AS TABPRECO "
		cSql	+= "FROM " + RetSqlName("DA1") + " DA1, " + RetSqlName("DA0") + " DA0 "
		cSql	+= "WHERE	DA0.DA0_FILIAL 	= '" + xFilial("DA0") + "'	AND "
		cSql	+= "     	DA1.DA1_FILIAL 	= '" + xFilial("DA1") + "'	AND "
		cSql	+= "		DA0.DA0_CODTAB	= '" + _cTabLM +"'			AND "
		cSql	+= "		DA0.DA0_CODTAB	= DA1.DA1_CODTAB			AND "
		cSql	+= "		DA1.DA1_CODPRO	= '" + wProduto +"'			AND "
		cSql	+= "	DA0.D_E_L_E_T_	= ''	AND "
		cSql	+= "	DA1.D_E_L_E_T_ 	= ''		"
	Else
		If wEmpPed == "01"
			cSql	:= "SELECT ROUND(C6_YPRCTAB*"+AllTrim(Str(_nFator))+",4)/C5_YMAXCND AS TABPRECO "
		Else
			cSql	:= "SELECT ROUND(C6_YPRCTAB*"+AllTrim(Str(_nFator))+",4)/C5_YMAXCND AS TABPRECO "
		EndIf
		cSql	+= "FROM SC5070 SC5 INNER JOIN SC6070 SC6 ON "
		cSql	+= "      C5_NUM = C6_NUM "
		cSql	+= "WHERE SC5.C5_YPEDORI = '"+wPed+"' AND  "
		cSql	+= "      SC5.C5_YEMPPED = '"+wEmpPed+"' AND "
		cSql	+= "      SC6.C6_PRODUTO = '"+wProduto+"' AND  "
		cSql	+= "      SC6.C6_ITEM    = '"+wItem+"' AND  "
		cSql	+= "      SC5.D_E_L_E_T_ = '' AND  "
		cSql	+= "      SC6.D_E_L_E_T_ = '' "
	EndIf
	If chkfile("X2")
		dbSelectArea("X2")
		dbCloseArea()
	EndIf
	TCQUERY cSql ALIAS "X2" NEW

	If !X2->(EOF())
		If cEmpAnt <> "07" .And. M->C5_CLIENTE == "010064"
			nPrcTab := X2->TABPRECO
		EndIf
	Else
		MsgStop("Não foi encontrado referência do Pedido/Produto/Item na empresa LM para buscar o Preço!")
	EndIf


Return(nPrcTab)


/*
##############################################################################################################
# PROGRAMA...: fVldConf
# AUTOR......: Ranisses A. Corona
# DATA.......: 16/10/2015  
# DESCRICAO..: Valida se o pedido de Engenharia bloqueado, está sendo alterado para Conferido = S
##############################################################################################################     
*/
User Function fVldConf()
	Local lRet := .T.

	//Validação de Pedidos de Engenharia
	If Alltrim(M->C5_YTPCRED) == "5" .And. Alltrim(M->C5_YCRDENG) == "03" .And. M->C5_YCONF == "S"
		lRet 		:= .F.
		MsgStop("Este Pedido de Engenharia está aguardando liberação do Setor de Crédito e Cobrança. Só será possivel alterar o campo Conferido, após aprovação do pedido!")
	EndIf

	//Validação de Pedidos de Contrato
	If Alltrim(M->C5_YTPCRED) == "2" .And. U_fVlApCT(M->C5_NUM) .And. M->C5_YCONF == "S"
		lRet 		:= .F.
		MsgStop("Este Pedido de Contrato está aguardando liberação do Setor de Crédito e Cobrança. Só será possivel alterar o campo Conferido, após aprovação do pedido!")
	EndIf

Return(lRet)



/*
##############################################################################################################
# PROGRAMA...: fVlApCT
# AUTOR......: Ranisses A. Corona
# DATA.......: 26/10/2015  
# DESCRICAO..: Valida se o Pedido de Contrato está aprovado pelo Crédito
##############################################################################################################     
*/
User Function fVlApCT(nPed)
	Local cSql	:= ""
	Local lRet	:= .T.

	cSql := ""
	cSql += "SELECT COUNT(*) COUNT "
	cSql += "FROM "+RetSqlName("SC5")+" SC5 INNER JOIN "+RetSqlName("SC6")+" SC6 ON "
	cSql += "     C5_NUM = C6_NUM "
	cSql += "WHERE C5_FILIAL = '"+xFilial("SC5")+"'	AND "
	cSql += "      C6_FILIAL = '"+xFilial("SC6")+"'	AND "
	cSql += "	   C5_NUM	  =  '"+nPed+"' AND 	"
	cSql += "      C5_YTPCRED = '2'	AND "
	cSql += "	   C6_YVALOR <> 0	AND "
	cSql += "      SC5.D_E_L_E_T_ = '' AND "
	cSql += "      SC6.D_E_L_E_T_ = '' "
	If chkfile("_SC6")
		dbSelectArea("_SC6")
		dbCloseArea()
	EndIf
	TCQUERY cSql ALIAS "_SC6" NEW

	lRet := _SC6->COUNT == 0

	_SC6->(DbCloseArea())

Return(lRet)


/*
##############################################################################################################
# PROGRAMA...: fSegCliente
# AUTOR......: Fernando - Facile
# DATA.......: 29/10/2015  
# DESCRICAO..: 
##############################################################################################################     
*/
User Function fSegCliente(_nLinha, _cCliente, _cLoja)
Local nTpSeg	:= ""
Local aArea		:= GetArea()

SA1->(DbSetOrder(1))
If SA1->(DbSeek(xFilial("SA1")+_cCliente+_cLoja))
	nTpSeg := SA1->A1_YTPSEG
EndIf

RestArea(aArea)	

Return(nTpSeg)

/*
##############################################################################################################
# PROGRAMA...: fInfCliente
# AUTOR......: Fernando - Facile
# DATA.......: 29/10/2015  
# DESCRICAO..: Funcao para retornar campos do cliente conforme empresa da Linha
# OBS........: Retirado de uso por Ranisses em 10/08/2021
##############################################################################################################     
*/
User Function fInfCliente(_nLinha, _cCliente, _cLoja)
	Local nTable
	Local cAliasTmp
	Local aRet

	//RETORNO aRet ARRAY(?)
	//aRet[1] =>  A1_YTRTESP
	//aRet[2] =>  A1_YCAT
	//aRet[3] =>  A1_YTPSEG
	//aRet[4] =>  A1_YLOTRES


	//Define o Tipo de Segmento do Cliente de acordo com a Linha do Pedido
	If cEmpAnt  == "07"
		If _nLinha == "1"						//BIANCOGRES
			nTable	:= "%SA1010%"
		ElseIf _nLinha $ "2_3" 			//INCESA E BELLACASA
			nTable	:= "%SA1050%"
		Else												//OUTRAS EMPRESAS
			//nTable	:= "%A1"+cEmpAnt+"0%"
			nTable	:= "%"+RetSqlName("SA1")+"%"
		EndIf
	Else
		//nTable	:= "%SA1"+cEmpAnt+"0%"
		nTable	:= "%"+RetSqlName("SA1")+"%"
	EndIf

	cAliasTmp := GetNextAlias()
	BeginSql Alias cAliasTmp
		SELECT A1_YTRTESP, A1_YCAT, A1_YTPSEG, A1_YLOTRES FROM %EXP:nTable% WHERE A1_COD = %EXP:_cCliente% AND A1_LOJA = %EXP:_cLoja% AND %NotDel%
	EndSql

	If !(cAliasTmp)->(Eof())

		aRet := {}
		AAdd(aRet, (cAliasTmp)->A1_YTRTESP)   	//01 = A1_YTRTESP
		AAdd(aRet, (cAliasTmp)->A1_YCAT)   		//02 = A1_YCAT
		AAdd(aRet, (cAliasTmp)->A1_YTPSEG)   	//03 = A1_YTPSEG
		AAdd(aRet, (cAliasTmp)->A1_YLOTRES)   	//04 = A1_YLOTRES
		//Pode ser usado para outros campos

	Else

		aRet := {}
		AAdd(aRet, "") //01 = A1_YTRTESP
		AAdd(aRet, "") //02 = A1_YCAT
		AAdd(aRet, "") //03 = A1_YTPSEG
		AAdd(aRet, "") //04 = A1_YLOTRES

	EndIf

	(cAliasTmp)->(dbCloseArea())

Return( aRet )


/*
##############################################################################################################
# PROGRAMA...: fDifICM2
# AUTOR......: Ranisses A. Corona
# DATA.......: 28/09/2015  
# DESCRICAO..: 
##############################################################################################################     
*/
User Function fDifICM2(cLinha,cSubTp,nCli,nLj,nProd,nIcmsOri,nIcmsDes,nFECP,cDIFAL,cTabPrc,dtEmis)
	Local nFator	:= 0
	Local cUF   	:= Posicione("SA1",1,xFilial("SA1")+nCli+nLj,"A1_EST")
	Local cSufr 	:= Iif(Alltrim(SA1->A1_CALCSUF)=="S","1","2") //Iif(Empty(Alltrim(SA1->A1_SUFRAMA)),"2","1")
	Local cContr	:= Alltrim(SA1->A1_CONTRIB)
	Local cTipo		:= Alltrim(SA1->A1_TIPO)
	Local cGrpTrib  := Posicione("SB1",1,xFilial("SB1")+nProd,"B1_GRTRIB")
	Local cMarca	:= ""
	Local cNum		:= ""
	Local cExpSql	:= "% 1 = 1 %"

	//Define a Marca de acordo com a "Empresa x Linha"
	If cEmpAnt == "01"
		cMarca := "0101"
	ElseIf cEmpAnt == "05"
		If cLinha == "2"
			cMarca := "0501"
		ElseIf cLinha == "3"
			cMarca := "0599"
		EndIf
	ElseIf cEmpAnt == "07"
		If cLinha == "1"
			cMarca := "0101"
		ElseIf cLinha == "2"
			cMarca := "0501"
		ElseIf cLinha == "3"
			cMarca := "0599"
		ElseIf cLinha == "4"
			cMarca := "1399"
		ElseIf cLinha == "5"
			cMarca := "0199"
		ElseIf cLinha == "6"
			cMarca := "1302"
		EndIf

		cExpSql := "% Z65_MARCA = '"+cMarca+"' %"

	ElseIf cEmpAnt == "13"
		cMarca := "1301"
	ElseIf cEmpAnt == "14"
		cMarca := "1401"
	EndIf

	//Retorna qual tabela está ativa
	cAliasTmp := GetNextAlias()
	BeginSql Alias cAliasTmpFACILE
		SELECT MAX(Z65_NUM) Z65_NUM 
		FROM %Table:Z65% 
		WHERE Z65_FILIAL = %xFilial:Z65% 
		AND	Z65_VALINI <= %Exp:dtEmis% 
		AND Z65_VALFIM >= %Exp:dtEmis% 		 
		AND Z65_GRTRIB = %Exp:cGrpTrib%
		AND %Exp:cExpSql% 
		AND %NOTDEL%		
	EndSql
	If !(cAliasTmp)->(EOF())
		cNum := (cAliasTmp)->Z65_NUM
	Else
		MsgAlert("Não existe tabela ativa para este período. Favor procurar Gerencia Comercial!")
		Return(nFator)
	EndIf
	(cAliasTmp)->(dbCloseArea())

	//Corrige o %nFECP, caso esteja errado.
	//Alterado por Wanisay 26/02/16 - OS 0812-16
	//If Alltrim(cUF) $ "RJ_AL" .And. cTipo == "F" .And. cContr == "2" .And. SB1->B1_FECP > 0 .And. Alltrim(SA1->A1_GRPTRIB) $ "005_006_010" .And. cDIFAL == "1" .And. nFECP == 0
	//Alterado Fernando em 29/06 - problema com a funcao de proposta de engenharia colocado execao para estas funcoes nesta condicao de empresa 01 e MG
	If ((Alltrim(cUF) $ "RJ_AL") .Or. (Alltrim(cUF) $ "MG" .And. cEmpAnt == "01" .And. !(AllTrim(FunName()) $ "BIA229#BFATTE01"))) .And. cTipo == "F" .And. cContr == "2" .And. SB1->B1_FECP > 0 .And. Alltrim(SA1->A1_GRPTRIB) $ "005_006_010" .And. cDIFAL == "1" .And. nFECP == 0
		U_LOG_USO("U_fDifICM2")
		nFECP := 2
	EndIf

	//Essa linha será mantida conforme texto descrito na solução da OS 0516-16.
	//Caso seja necessáro, poderá ser configurado para mais clientes.
	If cSubTp == "R2" .And. nIcmsOri == 0 .And. nCli == "021212"
		nFator	:= 1
		Return(nFator)
	EndIf

	//Para atender as vendas de industrialização da Victer para Biancogres - OS: 0754-16
	If cEmpAnt == "14" .And. nCli == "000481" .And. Alltrim(cSubTp) == "N" .And. cTabPrc == "001"
		nFator	:= 1
		Return(nFator)
	EndIf

	//Para atender as vendas do Cliente 025727 com INVEST - OS 1529-17
	If cEmpAnt == "07" .And. nCli == "025727"
		nFator	:= 0.9097
		Return(nFator)
	EndIf

	//Posiciona tabela no indice 2 //Z65_TIPVEN, Z65_UF, Z65_ZONAFR, Z65_TIPO, Z65_CONTRI, Z65_GRTRIB, Z65_ICMSOR, Z65_ICMSDE
	//Z65->(DbSetOrder(2))

	//ALTERADO EM 03/02/16
	//Posiciona tabela no indice 3 //Z65_MARCA, Z65_TIPVEN, Z65_UF, Z65_ZONAFR, Z65_TIPO, Z65_CONTRI, Z65_GRTRIB, Z65_ICMSOR, Z65_ICMSDE

	//ALTERADO EM 06/02/17
	//Posiciona tabela no indice 4 //Z65_NUM, Z65_MARCA, Z65_TIPVEN, Z65_UF, Z65_ZONAFR, Z65_TIPO, Z65_CONTRI, Z65_GRTRIB, Z65_ICMSOR, Z65_ICMSDE
	Z65->(DbSetOrder(4))

	If Z65->(DbSeek(xFilial("Z65")+cNum))
		nChave	:= cNum
	Else
		nChave	:= Space(TamSX3("Z65_NUM")[1])
	EndIf
	If Z65->(DbSeek(xFilial("Z65")+nChave+cMarca))
		nChave	+= cMarca
	Else
		nChave	+= Space(TamSX3("Z65_MARCA")[1])
	EndIf
	If Z65->(DbSeek(xFilial("Z65")+nChave+cSubTp))
		nChave	+= cSubTp
	Else
		nChave	+= Space(TamSX3("Z65_TIPVEN")[1])
	EndIf
	If Z65->(DbSeek(xFilial("Z65")+nChave+cUF))
		nChave 	+= cUF
	Else
		nChave	+= Space(TamSX3("Z65_UF")[1])
	EndIf
	If Z65->(DbSeek(xFilial("Z65")+nChave+cSufr))
		nChave	+= cSufr
	Else
		nChave	+= Space(TamSX3("Z65_ZONAFR")[1])
	EndIf
	If Z65->(DbSeek(xFilial("Z65")+nChave+cTipo))
		nChave	+= cTipo
	Else
		nChave	+= Space(TamSX3("Z65_TIPO")[1])
	EndIf
	If Z65->(DbSeek(xFilial("Z65")+nChave+cContr))
		nChave	+= cContr
	Else
		nChave	+= Space(TamSX3("Z65_CONTRI")[1])
	EndIf
	If Z65->(DbSeek(xFilial("Z65")+nChave+cGrpTrib))
		nChave	+= cGrpTrib
	Else
		nChave	+= Space(TamSX3("Z65_GRTRIB")[1])
	EndIf
	If Z65->(DbSeek(xFilial("Z65")+nChave+ Transform(nIcmsOri,"@E 99.99") ))
		nChave	+= Transform(nIcmsOri,"@E 99.99")
	Else
		nChave	+= Transform(0,"@E 99.99")
	EndIf

	//Pesquisa pela chave completa
	If Z65->(DbSeek(xFilial("Z65")+nChave))
		nFator	:= Z65->Z65_FATMUL
	Else
		nFator	:= 0
	EndIf

	//Se for Consumidor Final Não Contribuinte com cálculo de ICMS, pesquisa ultima chave novamente.
	If cTipo == "F" .And. cContr == "2" .And. cUF <> "ES" .And. nIcmsOri <> 0
		If Z65->(DbSeek(xFilial("Z65")+nChave+Transform((nIcmsDes+nFECP),"@E 99.99") ))
			nChave += Transform((nIcmsDes+nFECP),"@E 99.99")
		Else
			nChave += Transform(0,"@E 99.99")
		EndIf

		//Pesquisa pela chave completa
		If Z65->(DbSeek(xFilial("Z65")+nChave))
			nFator	:= Z65->Z65_FATMUL
		Else
			nFator	:= 0
		EndIf
	EndIf

Return(nFator)


/*/{Protheus.doc} fDifICM3
@description Nova versao da funcao fDifICM2 para usar a nova estrutura da tabela Z65 - projeto Filial LM
@author Fernando Rocha
@since 18/05/2017
@version 1.0
@param cLinha, characters, descricao
@param cSubTp, characters, descricao
@param nCli, numeric, descricao
@param nLj, numeric, descricao
@param nProd, numeric, descricao
@param nIcmsOri, numeric, descricao
@param nIcmsDes, numeric, descricao
@param nFECP, numeric, descricao
@param cDIFAL, characters, descricao
@param cTabPrc, characters, descricao
@param dtEmis, date, descricao
@type function
/*/


User Function fDifICM3(cLinha,cSubTp,nCli,nLj,nProd,nIcmsOri,nIcmsDes,nFECP,cDIFAL,cTabPrc,dtEmis,cCodTra,cMsgRet,cEmpPed)

	Local nFator	:= 0
	Local cUF   	:= Posicione("SA1",1,xFilial("SA1")+nCli+nLj,"A1_EST")
	Local cSufr 	:= Iif(Alltrim(SA1->A1_CALCSUF) $ "S/I","1","2") //Iif(Empty(Alltrim(SA1->A1_SUFRAMA)),"2","1")
	Local cContr	:= Alltrim(SA1->A1_CONTRIB)
	Local cTipo		:= Alltrim(SA1->A1_TIPO)
	Local cGrpTrib  := Posicione("SB1",1,xFilial("SB1")+nProd,"B1_GRTRIB")
	Local cMarca	:= ""
	Local cSpName	:= "SP_POL_GETFATMULT_"+AllTrim(CEMPANT)
	Local cTpTrans, cFrtAut
	Local _cOutSourc

	Default cEmpPed := ""
	//mesagem de retorno do erro
	cMsgRet := ""

	//Define a Marca de acordo com a "Empresa x Linha"
	If cEmpAnt == "01"
		cMarca := "0101"
	ElseIf cEmpAnt == "05"
		If cLinha == "2"
			cMarca := "0501"
		ElseIf cLinha == "3"
			cMarca := "0599"
		EndIf
	ElseIf cEmpAnt == "07"
		If cLinha == "1"
			cMarca := "0101"
		ElseIf cLinha == "2"
			cMarca := "0501"
		ElseIf cLinha == "3"
			cMarca := "0599"
		ElseIf cLinha == "4"
			cMarca := "1399"
		ElseIf cLinha == "5"
			cMarca := "0199"
		ElseIf cLinha == "6"
			cMarca := "1302"
		EndIf

	ElseIf cEmpAnt == "13"
		cMarca := "1301"
	ElseIf cEmpAnt == "14"
		cMarca := "1302"
	EndIf

	//Definicao de Produto Outsourcing para o Ticket 15088 - Fernando em 20/05/2019
	// conceito de Produto Outsourcing = Produto da Marca Biancogres com Estoque/OP no CNPJ da Incesa
	_cOutSourc := "N"
	If ( cMarca $ "0101_0199" .And. !Empty(cEmpPed) .And. AllTrim(cEmpPed) == "05" .And. cEmpAnt == '07')
		_cOutSourc := "S"
	EndIf

	//Tipo de Frete
	cFrtAut := "N"
	If !Empty(cCodTra)
		SA4->(DbSetOrder(1))
		If SA4->(DbSeek(xFilial("SA4")+cCodTra))

			cTpTrans	:= SA4->A4_YTIPO

			If (cTpTrans == "1") .Or. (cTpTrans == "2" .And. !(SA4->A4_EST == "ES"))

				cFrtAut := "S"

			EndIf

		EndIf
	EndIf

	//Essa linha será mantida conforme texto descrito na solução da OS 0516-16.
	//Caso seja necessáro, poderá ser configurado para mais clientes.
	If cSubTp == "R2" .And. nIcmsOri == 0 .And. nCli == "021212"
		nFator	:= 1
		Return(nFator)
	EndIf

	//Para atender Pedido do Tipo "O" para o Cliente CCB (001201)
	If Alltrim(cSubTp) == "O" .And. nCli == "001201"
		nFator	:= 1.0111
		Return(nFator)
	EndIf

	//Para atender as vendas de industrialização da Victer para Biancogres - OS: 0754-16
	If cEmpAnt == "14" .And. nCli == "000481" .And. Alltrim(cSubTp) == "N" .And. cTabPrc == "001"
		nFator	:= 1
		Return(nFator)
	EndIf

	//DESATIVADO EM 31/03/2020 - TICKET 23280
	//Para atender as vendas do Cliente 025727 com INVEST - OS 1529-17
	//If cEmpAnt == "07" .And. nCli == "025727"
	//	nFator	:= 0.9097
	//	Return(nFator)
	//EndIf

	//DESATIVADO EM 28/07/2020 - 25392
	//ATIVADO EM 31/03/2020 - TICKET 23277 - Para atender as vendas do Cliente 030405 com INVEST 
	//If cEmpAnt == "07" .And. nCli == "030405"
	//	nFator	:= 1.25
	//	Return(nFator)
	//EndIf


	If cLinha == "6" //Vinilico

		nFator	:= 1
		Return(nFator)

	EndIf

	//Corrige o %nFECP, caso esteja errado.
	//Alterado Fernando em 29/06 - problema com a funcao de proposta de engenharia colocado execao para estas funcoes nesta condicao de empresa 01 e MG
	/*Funco de pobreza para "MG"  comentado em 29/05 - projeto filial LM*/ 
	If ((Alltrim(cUF) $ "RJ_AL") /*.Or. (Alltrim(cUF) $ "MG" .And. cEmpAnt == "01" .And. !(AllTrim(FunName()) $ "BIA229#BFATTE01"))*/) .And. cTipo == "F" .And. cContr == "2" .And. SB1->B1_FECP > 0 .And. Alltrim(SA1->A1_GRPTRIB) $ "005_006_010" .And. cDIFAL == "1" .And. nFECP == 0
		nFECP := 2
	EndIf

	//Se for Consumidor Final Não Contribuinte com cálculo de ICMS, pesquisa ultima chave novamente.
	If cTipo == "F" .And. cContr == "2" .And. cUF <> "ES" .And. nIcmsOri <> 0
		nIcmsDes := nIcmsDes+nFECP
	Else
		nIcmsDes := 0
	EndIf

	//Ajuste do fator de multiplicacao conforme diferentes Grupos de Tributacao do Suframa
	If (cSufr == "1")

		__cGRCLI	:= Posicione("SA1",1,xFilial("SA1")+nCli+nLj,"A1_GRPTRIB")

		If __cGRCLI == "040" .Or. __cGRCLI == "021"	  //Ticket 16353 - Grupo 021 de clientes Solidarios - UF AM
			cSufr := "1"
		ElseIf __cGRCLI == "041"
			cSufr := "3"
		ElseIf __cGRCLI == "042"
			cSufr := "2"
		ElseIf __cGRCLI == "043"
			cSufr := "2"
		ElseIf __cGRCLI == "044"
			cSufr := "4"
		ElseIf __cGRCLI == "045"
			cSufr := "3"
		Else
			cSufr := "9"
		EndIf

	Else

		cSufr := "9"  //Nao tem suframa

	EndIf

	IF TCSPEXIST(cSpName)

		_cAliasDet := GetNextAlias()
		_cSQL := "EXEC "+cSpName+" '"+XFilial("Z65")+"', '"+cMarca+"', '"+cSubTp+"', '"+cUF+"', '"+cSufr+"', '"+cContr+"', '"+cTipo+"', '"+cGrpTrib+"', '"+cFrtAut+"', "+AllTrim(Str(nIcmsOri))+", "+AllTrim(Str(nIcmsDes))+", '"+_cOutSourc+"' "
		TCQuery _cSQL Alias (_cAliasDet) New

		_nFator := 0
		If !(_cAliasDet)->(Eof())
			_nFator := (_cAliasDet)->FATOR
			cMsgRet := (_cAliasDet)->MSGRET
		EndIf

		(_cAliasDet)->(DbCloseArea())
		Return(_nFator)

	ELSE
		Return 0
	ENDIF

Return

/*
##############################################################################################################
# PROGRAMA...: fVMT461A
# AUTOR......: Ranisses A. Corona
# DATA.......: 18/07/2016  
# DESCRICAO..: Valida parametro Agreg De/Ate quando na LM.
##############################################################################################################     
*/
User Function fVMT461A()
	Local lRet := .T.

	If Len(aPedOri) > 1
		If !Empty(Alltrim(&(READVAR()))) //MV_PAR09 ou MV_PAR10
			lRet	:= .F.
			MsgAlert("Quando é utilizado a busca da Carga na empresa Origem, os parâmetros 'Agreg. liberac. De/Ate' deverão estar em branco.")
		Else
			lRet	:= .T.
		EndIf
	EndIf

Return(lRet)


/*
##############################################################################################################
# PROGRAMA...: fUpdSC6
# AUTOR......: Ranisses A. Corona
# DATA.......: 20/08/2016  
# DESCRICAO..: Atualiza o status de cada registro em uma tabela temporaria do SC6
##############################################################################################################     
*/
User Function fUpdSC6(nTmpSC6)
	Local aRet		:= {}
	Local cSql		:= ""
	Local nNomeSE1	:= ""

	//Gera Base de Clientes com Titulos em Atraso e Contrato - OBRIGATORIO PARA USO NA FUNCAO FN_STATUS_PV_??
	aRet := TCSPEXEC("SP_GETSE1")
	If Type("aRet") == "A" .And. Len(aRet) > 0
		If aRet[1] == 0
			MsgStop("Ocorreu problema na geração da Base de Titulos em Atraso. Tente novamente.","fUpdSC6")
			Return
		EndIf
	EndIf
	nNomeSE1 := aRet[2]

	//Atualizando o status de cada item do Pedido
	cSql := " UPDATE "+nTmpSC6+" SET OBS = CASE 																									"
	cSql += " 									WHEN EMPRESA = '01' THEN dbo.FN_STATUS_PV_01(C6_NUM,C6_PRODUTO,C6_ITEM,C6_QTDVEN,C6_QTDENT,C6_BLQ,'"+nNomeSE1+"') 	"
	cSql += " 									WHEN EMPRESA = '05' THEN dbo.FN_STATUS_PV_05(C6_NUM,C6_PRODUTO,C6_ITEM,C6_QTDVEN,C6_QTDENT,C6_BLQ,'"+nNomeSE1+"') 	"
	cSql += " 									WHEN EMPRESA = '13' THEN dbo.FN_STATUS_PV_13(C6_NUM,C6_PRODUTO,C6_ITEM,C6_QTDVEN,C6_QTDENT,C6_BLQ,'"+nNomeSE1+"') 	"
	cSql += " 									WHEN EMPRESA = '14' THEN dbo.FN_STATUS_PV_14(C6_NUM,C6_PRODUTO,C6_ITEM,C6_QTDVEN,C6_QTDENT,C6_BLQ,'"+nNomeSE1+"')	"
	cSql += " 									ELSE 'ERRO' 																						"
	cSql += " 								END																										"
	TcSQLExec(cSql)

	//DELETA DADOS DA TABELA TEMPORARIA - OBRIGATORIO PARA USO NA FUNCAO FN_STATUS_PV_??
	cSql += " DELETE FROM TBLRACSE1 WHERE TABLENAME = '"+nNomeSE1+"' "
	TcSQLExec(cSql)

Return()


/*/{Protheus.doc} fUpdSC62
@description Funcao para atualizar o campo C6_YSTAST com o status o Item do Pedido 
@author Ranisses A. Corona
@since 29/11/2017
@version undefined
@history 29/11/2017, Ranisses A. Corona, A função fUpdSC62 irá substituir a função fUpdSC6.
@type function
/*/
User Function fUpdSC62()
	Local Enter 	:= CHR(13)+CHR(10)
	Local aEmp		:= {"01","05","13","14"}
	Local x			:= 0
	Local aRet		:= {}
	Local cSql		:= ""
	Local nNomeSE1	:= ""
	Local nTmpGer	:= "#TMPGERAL"+cEmpAnt+__cUserID+strzero(seconds()*3500,10)
	Local nTmpStat	:= "#TMPSTATUS"+cEmpAnt+__cUserID+strzero(seconds()*3500,10)

	//Gera Base de Clientes com Titulos em Atraso e Contrato - OBRIGATORIO PARA USO NA FUNCAO FN_STATUS_PV_??
	aRet := TCSPEXEC("SP_GETSE1")
	If Type("aRet") == "A" .And. Len(aRet) > 0
		If aRet[1] == 0
			MsgStop("Ocorreu problema na geração da Base de Titulos em Atraso. Tente novamente.","fUpdSC62")
			Return
		EndIf
	EndIf
	nNomeSE1 := aRet[2]

	//Monta base com os pedidos alterados na LM. Serve de base para recalcular o status nas demais nas empresa
	cSql := ""
	cSql += "SELECT C5_YPEDORI, C5_YEMPPED, C6_PRODUTO, C6_ITEM, C6_MSEXP, SC6.R_E_C_N_O_ AS RECNO_SC6	" + Enter
	cSql += "INTO #TEMP_SC6070_GERAL																	" + Enter
	cSql += "FROM SC5070 SC5 INNER JOIN SC6070 SC6 ON C5_NUM = C6_NUM									" + Enter
	cSql += "WHERE C6_FILIAL = '01' AND C6_MSEXP = '' AND C6_QTDVEN - C6_QTDENT > 0 AND C6_BLQ <> 'R' AND SC5.D_E_L_E_T_ = '' AND SC6.D_E_L_E_T_ = '' " + Enter
	TcSQLExec(cSql)

	//Ticket 5373
	//Monta base dos Clientes Geral (todas as empresas) que tiveram alteração desde a ultima execução da rotina (Trata questões relacionadas a Credito no Cliente)
	cSql := ""
	cSql += "SELECT A1_COD, A1_LOJA			" + Enter
	cSql += "INTO #CLIENTE					" + Enter
	cSql += "FROM							" + Enter
	cSql += "(								" + Enter
	For x := 1 to Len(aEmp)
		cSql += "SELECT A1_COD, A1_LOJA		" + Enter
		cSql += "FROM SA1"+aEmp[x]+"0 WITH (NOLOCK)								" + Enter
		cSql += "WHERE A1_FILIAL = '  ' AND A1_MSEXP = '' AND D_E_L_E_T_ = ''	" + Enter
		cSql += "UNION						" + Enter
	Next
	cSql += "SELECT A1_COD, A1_LOJA			" + Enter
	cSql += "FROM SA1070 WITH (NOLOCK)		" + Enter
	cSql += "WHERE A1_FILIAL = '  ' AND A1_MSEXP = '' AND D_E_L_E_T_ = ''	" + Enter
	cSql += ") TMP							" + Enter
	cSql += "WHERE A1_COD <> '010064'		" + Enter
	TcSQLExec(cSql)

	For x := 1 to Len(aEmp)

		// 01 - Monta base com os pedidos na empresa corrente, que tiveram alteração na LM
		cSql := ""
		cSql += "SELECT SC6.R_E_C_N_O_  AS RECNO_SC6070						" + Enter
		cSql += "INTO #TEMP_SC6070_"+aEmp[x]+"								" + Enter
		cSql += "FROM SC6"+aEmp[x]+"0 SC6 INNER JOIN #TEMP_SC6070_GERAL SC6_07 ON	" + Enter
		cSql += "		SC6.C6_NUM 		= SC6_07.C5_YPEDORI AND				" + Enter
		cSql += "		SC6.C6_PRODUTO 	= SC6_07.C6_PRODUTO AND				" + Enter
		cSql += "		SC6.C6_ITEM 	= SC6_07.C6_ITEM					" + Enter
		cSql += "WHERE 	SC6.C6_FILIAL 		= '01' 			AND				" + Enter
		cSql += "		SC6_07.C5_YEMPPED 	= '"+aEmp[x]+"'	AND				" + Enter
		cSql += "		SC6.C6_MSEXP 		<> '' 			AND				" + Enter
		cSql += "		C6_QTDVEN - C6_QTDENT > 0 			AND				" + Enter
		cSql += "		C6_BLQ 				<> 'R'			AND				" + Enter
		cSql += "		SC6.D_E_L_E_T_ = ''									" + Enter
		TcSQLExec(cSql)

		// 01 - Limpa campo para realizar a atualização do Status
		cSql := ""
		cSql += "UPDATE SC6"+aEmp[x]+"0 SET C6_MSEXP = '' FROM SC6"+aEmp[x]+"0 SC6 INNER JOIN #TEMP_SC6070_"+aEmp[x]+" TMP ON SC6.R_E_C_N_O_ = TMP.RECNO_SC6070 "
		TcSQLExec(cSql)

		// 02 - Monta base dos Pedidos com clientes que tiveram alteração desde a ultima execução da rotina
		cSql := ""
		cSql += "SELECT SC6.R_E_C_N_O_  AS RECNO_SC6	" + Enter
		cSql += "INTO #BASESC6LM"+aEmp[x]+"				" + Enter
		cSql += "FROM SC5"+aEmp[x]+"0 SC5				" + Enter
		cSql += "		INNER JOIN SC6"+aEmp[x]+"0 SC6 WITH (NOLOCK) ON C5_NUM = C6_NUM AND C5_CLIENTE = C6_CLI AND C5_LOJACLI = C6_LOJA	" + Enter
		cSql += "		INNER JOIN #CLIENTE ON C5_YCLIORI = A1_COD  AND C5_YLOJORI = A1_LOJA												" + Enter
		cSql += "WHERE C6_FILIAL		= '01'		AND	" + Enter
		cSql += "		C6_MSEXP		<> ''   	AND	" + Enter
		cSql += "		C6_QTDVEN - C6_QTDENT > 0	AND	" + Enter
		cSql += "		C6_BLQ			<> 'R'		AND	" + Enter
		cSql += "		SUBSTRING(C6_YSTAT,1,1) NOT IN ('9','1','6','7') AND " + Enter
		cSql += "		SC5.D_E_L_E_T_ 	= '' 		AND " + Enter
		cSql += "		SC6.D_E_L_E_T_ 	= ''			" + Enter
		TcSQLExec(cSql)

		// 02 - Limpa campo para realizar a atualização do Status
		cSql := ""
		cSql += "UPDATE SC6"+aEmp[x]+"0 SET C6_MSEXP = '' FROM SC6"+aEmp[x]+"0 SC6 INNER JOIN #BASESC6LM"+aEmp[x]+" TMP ON SC6.R_E_C_N_O_ = TMP.RECNO_SC6 "
		TcSQLExec(cSql)

		// 03 - Monta base dos Pedidos com clientes que tiveram alteração desde a ultima execução da rotina
		cSql := ""
		cSql += "SELECT SC6.R_E_C_N_O_  AS RECNO_SC6	" + Enter
		cSql += "INTO #BASESC6CLI"+aEmp[x]+"			" + Enter
		cSql += "FROM SC6"+aEmp[x]+"0 SC6 WITH (NOLOCK) INNER JOIN #CLIENTE ON C6_CLI = A1_COD  AND C6_LOJA = A1_LOJA " + Enter
		cSql += "WHERE C6_FILIAL		= '01'		AND	" + Enter
		cSql += "		C6_MSEXP		<> ''   	AND	" + Enter
		cSql += "		C6_QTDVEN - C6_QTDENT > 0	AND	" + Enter
		cSql += "		C6_BLQ			<> 'R'		AND	" + Enter
		cSql += "		SUBSTRING(C6_YSTAT,1,1) NOT IN ('9','1','6','7') AND " + Enter
		cSql += "		SC6.D_E_L_E_T_ 	= ''			" + Enter
		TcSQLExec(cSql)

		// 03 - Limpa campo para realizar a atualização do Status
		cSql := ""
		cSql += "UPDATE SC6"+aEmp[x]+"0 SET C6_MSEXP = '' FROM SC6"+aEmp[x]+"0 SC6 INNER JOIN #BASESC6CLI"+aEmp[x]+" TMP ON SC6.R_E_C_N_O_ = TMP.RECNO_SC6 "
		TcSQLExec(cSql)

		//Base geral com os Registros Alterados
		cSql := ""
		cSql += "SELECT *			" + Enter
		cSql += "INTO "+nTmpGer+"	" + Enter
		cSql += "FROM				" + Enter
		cSql += "(					" + Enter
		cSql += "SELECT SC6.R_E_C_N_O_ RECNO_SC6, 0 AS RECNO_SC9, 0 AS RECNO_SZN			" + Enter
		cSql += "FROM  SC6"+aEmp[x]+"0 SC6 WITH (NOLOCK)									" + Enter
		cSql += "WHERE C6_FILIAL = '01' AND C6_MSEXP = '' AND SC6.D_E_L_E_T_ = ''			" + Enter
		cSql += "UNION																		" + Enter
		cSql += "SELECT SC6.R_E_C_N_O_ RECNO_SC6, SC9.R_E_C_N_O_ RECNO_SC9, 0 AS RECNO_SZN	" + Enter
		cSql += "FROM SC6"+aEmp[x]+"0 SC6 WITH (NOLOCK)										" + Enter
		cSql += "INNER JOIN SC9"+aEmp[x]+"0 SC9 WITH (NOLOCK) ON C9_FILIAL = '01' AND C9_PRODUTO = C6_PRODUTO AND C9_PEDIDO = C6_NUM AND C9_ITEM = C6_ITEM	" + Enter
		cSql += "WHERE C6_FILIAL = '01' AND C9_FILIAL = '01' AND C9_MSEXP = '' AND SC6.D_E_L_E_T_ = '' AND SC9.D_E_L_E_T_ = ''	" + Enter
		cSql += "UNION																											" + Enter
		cSql += "SELECT SC6.R_E_C_N_O_ RECNO_SC6, 0 AS RECNO_SC9, SZN.R_E_C_N_O_ RECNO_SZN										" + Enter
		cSql += "from SC6"+aEmp[x]+"0 SC6 WITH (NOLOCK)																			" + Enter
		cSql += "INNER JOIN SZN"+aEmp[x]+"0 SZN WITH (NOLOCK) ON ZN_FILIAL = '01' AND C6_NUM     = ZN_PEDIDO 					" + Enter
		cSql += "WHERE C6_FILIAL = '01' AND ZN_FILIAL = '01' AND ZN_MSEXP = '' AND SC6.D_E_L_E_T_ = '' AND SZN.D_E_L_E_T_ = ''	" + Enter
		cSql += ") TMP							" + Enter
		TcSQLExec(cSql)

		//Monta base com os Status
		cSql := ""
		cSql += "SELECT *			" + Enter
		cSql += "INTO "+nTmpStat+"	" + Enter
		cSql += "FROM				" + Enter
		cSql += "(SELECT RECNO_SC6, SC6.C6_YSTAT STATUS, dbo.FN_STATUS_PV_"+aEmp[x]+"(C6_NUM,C6_PRODUTO,C6_ITEM,C6_QTDVEN,C6_QTDENT,C6_BLQ,'"+nNomeSE1+"') AS NEW_STATUS	" + Enter
		cSql += " FROM "+nTmpGer+" TMP INNER JOIN SC6"+aEmp[x]+"0 SC6 WITH (NOLOCK) ON																				" + Enter
		cSql += "       TMP.RECNO_SC6 = SC6.R_E_C_N_O_ ) TMP																										" + Enter
		cSql += "WHERE STATUS <> NEW_STATUS																															" + Enter
		TcSQLExec(cSql)

		//Atualiza Status
		cSql := ""
		cSql += "UPDATE SC6"+aEmp[x]+"0 SET C6_YSTAT = TMP.NEW_STATUS FROM SC6"+aEmp[x]+"0 SC6 INNER JOIN "+nTmpStat+" TMP ON SC6.R_E_C_N_O_ = TMP.RECNO_SC6 "
		TcSQLExec(cSql)

		//Atualiza o campo de Marcação de alteração XX_MSEXP
		cSql := ""
		cSql += "UPDATE SC6"+aEmp[x]+"0 SET C6_MSEXP = CONVERT(VARCHAR,GETDATE(),112) FROM SC6"+aEmp[x]+"0 SC6 INNER JOIN "+nTmpGer+" TMP ON SC6.R_E_C_N_O_ = TMP.RECNO_SC6 "
		TcSQLExec(cSql)

		cSql := ""
		cSql += "UPDATE SC9"+aEmp[x]+"0 SET C9_MSEXP = CONVERT(VARCHAR,GETDATE(),112) FROM SC9"+aEmp[x]+"0 SC9 INNER JOIN "+nTmpGer+" TMP ON SC9.R_E_C_N_O_ = TMP.RECNO_SC9 "
		TcSQLExec(cSql)

		cSql := ""
		cSql += "UPDATE SZN"+aEmp[x]+"0 SET ZN_MSEXP = CONVERT(VARCHAR,GETDATE(),112) FROM SZN"+aEmp[x]+"0 SZN INNER JOIN "+nTmpGer+" TMP ON SZN.R_E_C_N_O_ = TMP.RECNO_SZN "
		TcSQLExec(cSql)

		cSql := ""
		cSql += "UPDATE SA1"+aEmp[x]+"0 SET A1_MSEXP = CONVERT(VARCHAR,GETDATE(),112) FROM SA1"+aEmp[x]+"0 SA1 INNER JOIN  #CLIENTE TMP ON SA1.A1_COD = TMP.A1_COD AND SA1.A1_LOJA = TMP.A1_LOJA  "
		TcSQLExec(cSql)

		cSql := ""
		cSql += "DROP TABLE "+nTmpGer
		TcSQLExec(cSql)

		cSql := ""
		cSql += "DROP TABLE "+nTmpStat
		TcSQLExec(cSql)

		cSql := ""
		cSql += "DROP TABLE #TEMP_SC6070_"+aEmp[x]
		TcSQLExec(cSql)

		cSql := ""
		cSql += "DROP TABLE #BASESC6CLI"+aEmp[x]
		TcSQLExec(cSql)

		cSql := ""
		cSql += "DROP TABLE #BASESC6LM"+aEmp[x]
		TcSQLExec(cSql)

	Next


	//Fernando/Facile em 04/07/2018 - Atualizar status de Pedidos de Manta na LM
	IF AllTrim(CEMPANT) == "07"

		//Base geral com os Registros Alterados
		cSql := ""
		cSql += "SELECT *			" + Enter
		cSql += "INTO "+nTmpGer+"	" + Enter
		cSql += "FROM				" + Enter
		cSql += "(					" + Enter
		cSql += "SELECT SC6.R_E_C_N_O_ RECNO_SC6, 0 AS RECNO_SC9, 0 AS RECNO_SZN			" + Enter
		cSql += "FROM  SC6070 SC6 WITH (NOLOCK)									" + Enter
		cSql += "WHERE C6_FILIAL = '01' AND C6_MSEXP = '' AND SUBSTRING(C6_PRODUTO,1,2) = 'PR' AND SC6.D_E_L_E_T_ = '' 			" + Enter
		cSql += "UNION																		" + Enter
		cSql += "SELECT SC6.R_E_C_N_O_ RECNO_SC6, SC9.R_E_C_N_O_ RECNO_SC9, 0 AS RECNO_SZN	" + Enter
		cSql += "FROM SC6070 SC6 WITH (NOLOCK)										" + Enter
		cSql += "INNER JOIN SC9070 SC9 WITH (NOLOCK) ON C9_FILIAL = '01' AND C9_PRODUTO = C6_PRODUTO AND C9_PEDIDO = C6_NUM AND C9_ITEM = C6_ITEM	" + Enter
		cSql += "WHERE C6_FILIAL = '01' AND C9_FILIAL = '01' AND C9_MSEXP = '' AND SUBSTRING(C6_PRODUTO,1,2) = 'PR' AND SC6.D_E_L_E_T_ = '' AND SC9.D_E_L_E_T_ = ''	" + Enter
		cSql += "UNION																											" + Enter
		cSql += "SELECT SC6.R_E_C_N_O_ RECNO_SC6, 0 AS RECNO_SC9, SZN.R_E_C_N_O_ RECNO_SZN										" + Enter
		cSql += "from SC6070 SC6 WITH (NOLOCK)																			" + Enter
		cSql += "INNER JOIN SZN070 SZN WITH (NOLOCK) ON ZN_FILIAL = '01' AND C6_NUM     = ZN_PEDIDO 					" + Enter
		cSql += "WHERE C6_FILIAL = '01' AND ZN_FILIAL = '01' AND ZN_MSEXP = '' AND SUBSTRING(C6_PRODUTO,1,2) = 'PR' AND SC6.D_E_L_E_T_ = '' AND SZN.D_E_L_E_T_ = ''	" + Enter
		cSql += ") TMP							" + Enter
		TcSQLExec(cSql)

		//Monta base com os Status
		cSql := ""
		cSql += "SELECT *			" + Enter
		cSql += "INTO "+nTmpStat+"	" + Enter
		cSql += "FROM				" + Enter
		cSql += "(SELECT RECNO_SC6, SC6.C6_YSTAT STATUS, dbo.FN_STATUS_PV_07(C6_NUM,C6_PRODUTO,C6_ITEM,C6_QTDVEN,C6_QTDENT,C6_BLQ,'"+nNomeSE1+"') AS NEW_STATUS	" + Enter
		cSql += " FROM "+nTmpGer+" TMP INNER JOIN SC6070 SC6 WITH (NOLOCK) ON																				" + Enter
		cSql += "       TMP.RECNO_SC6 = SC6.R_E_C_N_O_ ) TMP																										" + Enter
		cSql += "WHERE STATUS <> NEW_STATUS																															" + Enter
		TcSQLExec(cSql)

		//Atualiza Status
		cSql := ""
		cSql += "UPDATE SC6070 SET C6_YSTAT = TMP.NEW_STATUS FROM SC6070 SC6 INNER JOIN "+nTmpStat+" TMP ON SC6.R_E_C_N_O_ = TMP.RECNO_SC6 "
		TcSQLExec(cSql)

		//Atualiza o campo de Marcação de alteração XX_MSEXP
		cSql := ""
		cSql += "UPDATE SC6070 SET C6_MSEXP = CONVERT(VARCHAR,GETDATE(),112) FROM SC6070 SC6 INNER JOIN "+nTmpGer+" TMP ON SC6.R_E_C_N_O_ = TMP.RECNO_SC6 "
		TcSQLExec(cSql)

		cSql := ""
		cSql += "UPDATE SC9070 SET C9_MSEXP = CONVERT(VARCHAR,GETDATE(),112) FROM SC9070 SC9 INNER JOIN "+nTmpGer+" TMP ON SC9.R_E_C_N_O_ = TMP.RECNO_SC9 "
		TcSQLExec(cSql)

		cSql := ""
		cSql += "UPDATE SZN070 SET ZN_MSEXP = CONVERT(VARCHAR,GETDATE(),112) FROM SZN070 SZN INNER JOIN "+nTmpGer+" TMP ON SZN.R_E_C_N_O_ = TMP.RECNO_SZN "
		TcSQLExec(cSql)

		cSql := ""
		cSql += "UPDATE SA1070 SET A1_MSEXP = CONVERT(VARCHAR,GETDATE(),112) FROM SA1070 SA1 INNER JOIN  #CLIENTE TMP ON SA1.A1_COD = TMP.A1_COD AND SA1.A1_LOJA = TMP.A1_LOJA  "
		TcSQLExec(cSql)

		cSql := ""
		cSql += "DROP TABLE "+nTmpGer
		TcSQLExec(cSql)

		cSql := ""
		cSql += "DROP TABLE "+nTmpStat
		TcSQLExec(cSql)

	ENDIF

	//Atualiza o campo de Marcação de alteração C6_MSEXP na empresa LM
	cSql := ""
	cSql += "UPDATE SC6070 SET C6_MSEXP = CONVERT(VARCHAR,GETDATE(),112) FROM SC6070 SC6 INNER JOIN #TEMP_SC6070_GERAL TMP ON SC6.R_E_C_N_O_ = TMP.RECNO_SC6 "
	TcSQLExec(cSql)

	//Apaga tabela temporaria geral
	cSql := ""
	cSql += "DROP TABLE #TEMP_SC6070_GERAL"
	TcSQLExec(cSql)

	//UPDATE NOS CLIENTES QUE TIVERAM ALTERAÇÃO NA EMPRESA LM
	cSql := ""
	cSql += "UPDATE SA1070 SET A1_MSEXP = CONVERT(VARCHAR,GETDATE(),112) FROM SA1070 SA1 INNER JOIN #CLIENTE TMP ON SA1.A1_COD = TMP.A1_COD AND SA1.A1_LOJA = TMP.A1_LOJA "
	TcSQLExec(cSql)

	//DELETA BASE GERAL DE CLIENTES
	cSql := ""
	cSql += "DROP TABLE #CLIENTE "
	TcSQLExec(cSql)

	//DELETA DADOS DA TABELA TEMPORARIA - OBRIGATORIO PARA USO NA FUNCAO FN_STATUS_PV_??
	cSql := ""
	cSql += " DELETE FROM TBLRACSE1 WHERE TABLENAME = '"+nNomeSE1+"' "
	TcSQLExec(cSql)

Return()



/*/{Protheus.doc} LMFatRed
@description Funcao para Retornar o Fator Redutor de Pedidos Originados na LM por UF da Filial
@author Fernando Rocha
@since 25/04/2017
@version undefined
@param _CUF, , descricao
@type function
/*/
User Function LMFatRed(_CUF, _cPacote)

	Local _cPar 		:= AllTrim(GetNewPar("MV_YLMFRD","ES=0.88")) //Ticket 10368
	Local _nFator 		:= 1
	Local _aFats 		:= StrToKarr(_cPar,"#")
	Local _nPos 		:= AScan( _aFats, {|x| Left(x,2 )== _CUF} )
	Default _cPacote 	:= ""

	If (!Empty(_cPacote) .And. AllTrim(_cPacote) == 'J') //utilizado projeto vinilico  J=Vinilico
		_nFator := 0.80
	Else

		If (_nPos > 0)

			_cFat := SubStr(_aFats[_nPos],4)
			_nFator := Val(_cFat)

		EndIf

	EndIf

Return _nFator


/*/{Protheus.doc} GetInfO2
@description Funcao para Retornar informações da NF de Origem das Vendas Intragrupo
@author Ranisses A. Corona
@since 10/05/2017
@version undefined
@param cDoc,cSer,cFor,cLoja,cCod,cIt
@type function
/*/
User Function GetInfO2(cDoc,cSer,cFor,cLoja,cCod,cIt,cEmpresa)

	Local cSql	:= ""
	Local aRet	:= {}
	Local cEmp	:= ""
	Local cFil	:= ""
	Local cCli 	:= ""
	Local cLjCl	:= ""
	Local nDB	:= AllTrim(U_DBNAME()) //Retorna a Database utilizada no ambiente.

	Local aArea		:= GetArea()
	Local aAreaSM0	:= SM0->(GetArea())

	Local cIndSA1
	Local cIndSD2

	//Preenche Array vazio
	aadd(aRet, "")	//01 EMPRESA ORIGEM
	aadd(aRet, "")	//02 FILIAL ORIGEM
	aadd(aRet, "")	//03 CLIENTE
	aadd(aRet, "")	//04 LOJA ORIGEM
	aadd(aRet, "")	//05 SERIE
	aadd(aRet, "")	//06 NF
	aadd(aRet, "")	//07 ITEM
	aadd(aRet, "")	//08 CODIGO PROD
	aadd(aRet, 0)	//09 QUANT
	aadd(aRet, 0)	//10 TOTAL
	aadd(aRet, 0)	//11 BASE ICMS RET
	aadd(aRet, 0)	//12 VL. ICMS RET
	aadd(aRet, "")	//13 LOTE
	aadd(aRet, "")	//14 DT. VL. LOTE
	aadd(aRet, "")	//15 SUBTP.(TIPO)
	aadd(aRet, "")	//16 COND.PAGMENTO
	aadd(aRet, 0)	//17 PESO LIQUIDO
	aadd(aRet, "")		//18 LOCAL/ALMOXARIFADO

	If cFor $ "000534/002912/007602/004695/003721"

		DbSelectArea("SM0")
		SM0->(DbGoTop())
		DbSeek(cEmpresa)

		//Busca Cliente Origem atraves da Empresa de Entrada
		cSql 	:= " SELECT A1_COD, A1_LOJA FROM VW_INTRAGRUPO WHERE CGC = '"+SM0->M0_CGC+"' AND A1_COD <> '' "
		cSql 	:= ChangeQuery(cSql)
		cIndSA1	:= CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),'KR03',.T.,.T.)
		dbSelectArea("KR03")

		cCli 	:= KR03->A1_COD
		cLjCl	:= KR03->A1_LOJA

		//Defina a Empresa Origem e Cliente de Origem
		If cFor == "000534"
			cEmp 	:= "01"
			cFil 	:= "01"
		ElseIf cFor == "002912"
			cEmp 	:= "05"
			cFil 	:= "01"
		ElseIf cFor == "007602"
			cEmp 	:= "07"
			cFil 	:= "01"
		ElseIf cFor == "004695"
			cEmp 	:= "13"
			cFil 	:= "01"
		ElseIf cFor == "003721"
			cEmp 	:= "14"
			cFil 	:= "01"
		EndIf

		cSql := " SELECT TOP 1 F2_YSUBTP, F2_COND, F2_PLIQUI, D2_SERIE, D2_DOC, D2_ITEM, D2_COD, D2_QUANT, D2_TOTAL, D2_BRICMS, D2_ICMSRET, D2_LOTECTL, D2_DTVALID, D2_LOCAL
		cSql += "   FROM SF2"+cEmp+"0 SF2
		cSql += "   		INNER JOIN SD2"+cEmp+"0 SD2 ON F2_FILIAL = D2_FILIAL AND F2_SERIE = D2_SERIE AND F2_DOC = D2_DOC
		cSql += "  WHERE D2_FILIAL	= '"+cFil+"'
		cSql += "    AND D2_CLIENTE	= '"+cCli+"'
		cSql += "    AND D2_LOJA   	= '"+cLjCl+"'
		cSql += "    AND D2_DOC		= '"+cDoc+"'
		cSql += "    AND D2_SERIE	= '"+cSer+"'
		If !Empty(Alltrim(cCod))
			cSql += "    AND D2_COD		= '"+cCod+"'
			cSql += "    AND D2_ITEM	= '"+RIGHT(cIt,2)+"'
		EndIf
		cSql += "    AND SF2.D_E_L_E_T_ = ' ' AND SD2.D_E_L_E_T_ = ' '
		cSql 	:= ChangeQuery(cSql)
		cIndSD2	:= CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),'KR02',.T.,.T.)
		dbSelectArea("KR02")

		If !KR02->(EOF())
			aRet	:= {}
			aadd(aRet, cEmp)				//01 EMPRESA ORIGEM
			aadd(aRet, cFil)				//02 FILIAL ORIGEM
			aadd(aRet, cCli)				//03 CLIENTE ORIGEM
			aadd(aRet, cLjCl)				//04 LOJA ORIGEM
			aadd(aRet, KR02->D2_SERIE)		//05 SERIE
			aadd(aRet, KR02->D2_DOC)		//06 NF
			aadd(aRet, KR02->D2_ITEM)		//07 ITEM
			aadd(aRet, KR02->D2_COD)		//08 CODIGO PROD
			aadd(aRet, KR02->D2_QUANT)		//09 QUANT
			aadd(aRet, KR02->D2_TOTAL)		//10 TOTAL
			aadd(aRet, KR02->D2_BRICMS)		//11 BASE ICMS RET
			aadd(aRet, KR02->D2_ICMSRET)	//12 VL. ICMS RET
			aadd(aRet, KR02->D2_LOTECTL)	//13 LOTE
			aadd(aRet, KR02->D2_DTVALID)	//14 DT. VL. LOTE
			aadd(aRet, KR02->F2_YSUBTP)		//15 SUBTP.(TIPO)
			aadd(aRet, KR02->F2_COND)		//16 COND.PAGMENTO
			aadd(aRet, KR02->F2_PLIQUI)		//17 PESO LIQUIDO
			aadd(aRet, KR02->D2_LOCAL)		//18 LOCAL/ALMOXARIFADO

		EndIf

		//Apaga area de trabalho
		KR03->(dbCloseArea())
		Ferase(cIndSA1+GetDBExtension())	//arquivo de trabalho
		Ferase(cIndSA1+OrdBagExt())			//indice gerado

		KR02->(dbCloseArea())
		Ferase(cIndSD2+GetDBExtension())	//arquivo de trabalho
		Ferase(cIndSD2+OrdBagExt())			//indice gerado

	EndIf

	RestArea(aAreaSM0)
	RestArea(aArea)

Return(aRet)

/*/{Protheus.doc} fGrvPdFr
@description Função para gravar o cadastro de Amarração de Produto x Fornecedor
@author Ranisses A. Corona
@since 17/05/2017
@version undefined
@param cCodFor, cLojFor, cCodPrd, cPrdFor
@type function
/*/
User Function fGrvPdFr(cCodFor, cLojFor, cCodPrd, cPrdFor)
	Local aArea := GetArea()

	If !Empty(cPrdFor) .And. Posicione("SB1", 1, xFilial("SB1") + cCodPrd, "B1_TIPO") <> "PP"

		DbSelectArea("SA5")
		DbSetOrder(1)
		If !SA5->(DbSeek(xFilial("SA5") + cCodFor + cLojFor + cCodPrd))

			RecLock("SA5", .T.)

			SA5->A5_FILIAL	:= xFilial("SA5")
			SA5->A5_FORNECE	:= cCodFor
			SA5->A5_LOJA 	:= cLojFor
			SA5->A5_NOMEFOR	:= Posicione("SA2", 1, xFilial("SA2") + cCodFor + cLojFor, "A2_NOME")
			SA5->A5_PRODUTO	:= cCodPrd
			SA5->A5_NOMPROD	:= Posicione("SB1", 1, xFilial("SB1") + cCodPrd, "B1_DESC")
			SA5->A5_CODPRF	:= cPrdFor

			SA5->(MsUnlock())

		ElseIf SA5->A5_CODPRF <> cPrdFor

			RecLock("SA5", .F.)
			SA5->A5_CODPRF	:= cPrdFor
			SA5->(MsUnlock())

		EndIf

	EndIf

	RestArea(aArea)

Return()


/*/{Protheus.doc} fExcVenc
@description Função para tratamento de Exceções de Vencimento
@author Ranisses A. Corona
@since 07/06/2017
@version undefined
@history 26/11/2019, Ranisses A. Corona, Tratamento para buscar o vencimento original da NF já modificado - Ticket 20131
@param cRegra, cMarca, cCli, cLoja, dEmis, dVenc, nVlBr, nCond, nValIPI, nVlST, cOrigem (CALC_ST/MATA460)
@type function
/*/
User Function fExcVenc(cRegra,cMarca,cCli,cLoja,dEmis,dVenc,nVlBr,nCond,nValIPI,nVlST,cOrigem,cSerie,cNF)

	//Variaveis
	Local lTpVenc	:= "" //Tipo de Vencimento (1=Incremento/2=Fixo/3=Original NF)--SOMENTE ST
	Local nSomaMes	:= 0  //Mes Vencimento N=Normal / F=Forma Mes (Soma 0 ou 1 )  --PARA ST E NF
	Local nDias		:= "" //Quantidade de Dias para Incremento ou Vencimento Fixo --PARA ST E NF
	Local dData		      //Define se sera utilizado a Emissão ou Vencimento como base da analise
	Local cIndZ01

	Local aArea		:= GetArea()
	Local aAreaSA1	:= SA1->(GetArea())
	Local aAreaSE1	:= SE1->(GetArea())
	
	//Local cArq		:= ""
	//Local cInd		:= 0
	//Local cReg		:= 0

	//Variaveis de Retorno
	Local dtVencto			//Nova Data Vencimento
	Local nForma	:= ""	//Forma de Pagmento
	Local aRet		:= {}	//Array de Retorno

	Default cOrigem	:= "MATA460"
	Default cSerie	:= ""
	Default cNF		:= ""

	//cArq := Alias()
	//cInd := IndexOrd()
	//cReg := Recno()

	//Posiciona no Cliente
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1")+cCli+cLoja))

	//Busca Regra de Vencimento
	cQuery  := "SELECT TOP 1 *		"
	cQuery  += "FROM Z01010 		"
	cQuery  += "WHERE	((Z01_CLIENT+Z01_LOJA = '"+SA1->A1_COD+SA1->A1_LOJA+"' AND Z01_GRUPO = '' AND Z01_CNPJGR = '') 		OR	"
	cQuery  += "		(Z01_CLIENT+Z01_LOJA  = '' AND Z01_GRUPO = '"+SA1->A1_GRPVEN+"' AND Z01_CNPJGR = '') 	OR	"
	cQuery  += "		(Z01_CLIENT+Z01_LOJA  = '' AND Z01_GRUPO = '' AND Z01_CNPJGR = '"+Subs(SA1->A1_CGC,1,8)+"')) AND "
	cQuery  += "		(Z01_MARCA	 = '"+cMarca+"' OR Z01_MARCA = '9999') AND "
	cQuery  += "		Z01_REGRA	 = '"+cRegra+"' 		AND 	"
	If cRegra == "NF"
		cQuery  += "		Z01_DVCINI <= '"+Subst(Dtos(dVenc),7,2)+"' AND Z01_DVCFIM >= '"+Subst(Dtos(dVenc),7,2)+"' AND  "
	EndIf
	cQuery  += "		Z01_VALDDE	<= '"+Dtos(dEmis)+"' 	AND 	"
	cQuery  += "		Z01_VALDAT	>= '"+Dtos(dEmis)+"' 	AND 	"
	cQuery  += "		D_E_L_E_T_	= '' "
	cQuery  += "ORDER BY Z01_MARCA, Z01_REGRA "
	cQuery 	:= ChangeQuery(cQuery)
	cIndZ01	:= CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),'R002',.T.,.T.)
	dbSelectArea('R002')

	//Caso encontre excecao alimenta variaveis e acerta o vencimento conforme a regra.
	If !R002->(EOF())
		nDias		:=	Iif(R002->Z01_TIPO=="1",Val(R002->Z01_DIAS),R002->Z01_DIAS)
		lTpVenc		:=	R002->Z01_TIPO				//Tipo de Vencimento (1=Incremento/2=Fixo/3=Original NF)
		nSomaMes	:=	Iif(R002->Z01_DDD=="N",0,1) //Tratamento para Dentro Mes / Fora Mes
		nForma		:=	R002->Z01_FORMA				//Forma de Pagamento
		dData		:=  Iif(cRegra=="NF",dVenc,dEmis)

		//Para Titulos de ST
		If cRegra == "ST"
			//Incremento de Vencimento
			If lTpVenc == "1"
				dtVencto	:= MonthSum(dData,nSomaMes) + nDias

				//Vencimento Fixo
			ElseIf lTpVenc == "2"
				//Se for Fevereiro e o dia de vencimento maior que 29
				If Month(MonthSum(dData,nSomaMes))==2 .And. nDias >= "29"
					dtVencto	:= Ultimodia(Stod(Subs(Dtos(MonthSum(dData,nSomaMes)),1,6)+"01"))
				Else
					dtVencto	:= Stod(Subs(Dtos(MonthSum(dData,nSomaMes)),1,6)+nDias)
				EndIf

				//Original NF
			ElseIf lTpVenc == "3"
				If Alltrim(cOrigem) == "MATA460" 	//Busca os vencimentos utilizando a Condicao de Pagamento do Pedido durante a Geracao da NF
					aVenc		:= Condicao(nVlBr,nCond,nValIPI,dData,nVlST)
					If Alltrim(SE4->E4_SOLID) == "S"
						dtVencto	:= aVenc[2][1] //Grava o Vencimento da Primeira Parcela do valor Principal
					Else
						dtVencto	:= aVenc[1][1]
					EndIf
				Else								//Busca os vencimentos utilizando os títulos ja gerados na NF
					//Posiciona nos Titulos da NF
					SE1->(DbSetOrder(1))
					SE1->(DbSeek(xFilial("SE1")+cSerie+cNF))
					If SE1->E1_NATUREZ == "1230"
						SE1->(dbSkip())
						If SE1->E1_PREFIXO == cSerie .And. SE1->E1_NUM == cNF .And. SE1->E1_PARCELA == "B"
							dtVencto	:= SE1->E1_VENCTO
						EndIf
					Else
						dtVencto	:= SE1->E1_VENCTO
					EndIf

				EndIf
			EndIf

			//Para Titulos de NF
		ElseIf cRegra == "NF"
			//Se for Fevereiro e o dia de vencimento maior que 29
			If Month(MonthSum(dData,nSomaMes))==2 .And. nDias >= "29"
				dtVencto	:= Ultimodia(Stod(Subs(Dtos(MonthSum(dData,nSomaMes)),1,6)+"01"))
			Else
				dtVencto	:= Stod(Subs(Dtos(MonthSum(dData,nSomaMes)),1,6)+nDias)
			EndIf

		EndIf

		aRet	:= {}
		aadd(aRet, dtVencto)			//01 Vencimento
		aadd(aRet, nForma)				//02 Forma Pagto

	EndIf

	//Apaga area de trabalho
	R002->(dbCloseArea())
	Ferase(cIndZ01+GetDBExtension())	//arquivo de trabalho
	Ferase(cIndZ01+OrdBagExt())			//indice gerado

	//Volta area de Trabalho
	RestArea(aAreaSA1)
	RestArea(aAreaSE1)
	RestArea(aArea)

	//DbSelectArea(cArq)
	//DbSetOrder(cInd)
	//DbGoTo(cReg)

Return(aRet)

/*/{Protheus.doc} fGetGrTr
@description Função que define o Grupo de Tributação
@author Ranisses A. Corona
@since 14/07/2017
@version undefined
@param cSuframa,lCalcSuf,cTipoCli,cContrib,cInscr,cAtivid
@type function
/*/
User Function fGetGrTr(cSuframa,lCalcSuf,cTipoCli,cContrib,cInscr,cAtivid,cTPJ)
	Local cGrTri := ""

	DO CASE
	CASE cTipoCli == 'X'
		cGrTri := '030'
	CASE !Empty(AllTrim(cSuframa)) .AND. lCalcSuf == 'S' .AND. cTipoCli == "R" .AND. cContrib == "1"
		cGrTri := '040'
	CASE !Empty(AllTrim(cSuframa)) .AND. lCalcSuf == 'I' .AND. cTipoCli $ ("R/S") //.And. A1_YTPCLFI == "1" momentaneamente desnecessario devido a todo IPI ser 0,00
		cGrTri := '044'
	CASE !Empty(AllTrim(cSuframa)) .AND. lCalcSuf == 'S' .AND. cTipoCli == "F" .AND. cContrib == "2"
		cGrTri := '043'
	CASE !Empty(AllTrim(cSuframa)) .AND. lCalcSuf == 'S' .AND. cTipoCli == "F" .AND. cContrib == "1"
		cGrTri := '042'
	CASE !Empty(AllTrim(cSuframa)) .AND. lCalcSuf == 'N' .AND. cTipoCli == "F" .AND. cContrib == "1"
		cGrTri := '041'
	CASE !Empty(AllTrim(cSuframa)) .AND. lCalcSuf == 'N' .AND. cTipoCli == "F" .AND. cContrib == "2"
		cGrTri := '045'
	CASE (ALLTRIM(cInscr) <> "." .AND. ALLTRIM(cInscr) <> "ISENTO" .AND. ALLTRIM(cInscr) <> "") .AND. cAtivid $ "000099/000103/000104" .AND. cContrib == "2"
		cGrTri := '005'
	CASE (ALLTRIM(cInscr) == "."  .OR. ALLTRIM(cInscr) == "ISENTO"  .OR. ALLTRIM(cInscr) == "") .AND. cAtivid $ "000099/000103/000104" .AND. cContrib == "2"
		cGrTri := '006'
	CASE (ALLTRIM(cInscr) <> "." .AND. ALLTRIM(cInscr) <> "ISENTO" .AND. ALLTRIM(cInscr) <> "") .AND. cAtivid $ "000099/000103/000104" .AND. cContrib == "1"
		cGrTri := '007'
	CASE (ALLTRIM(cInscr) <> "." .AND. ALLTRIM(cInscr) <> "ISENTO" .AND. ALLTRIM(cInscr) <> "") .AND. cTipoCli == "L" .AND. cContrib == "1"
		cGrTri := '012'
	CASE (ALLTRIM(cInscr) <> "." .AND. ALLTRIM(cInscr) <> "ISENTO" .AND. ALLTRIM(cInscr) <> "") .AND. cTipoCli == "F" .AND. cContrib == "1"
		cGrTri := '020'
	CASE cContrib == "2" .AND. cTipoCli == "F"
		cGrTri := '010'
	CASE (ALLTRIM(cInscr) <> "." .AND. ALLTRIM(cInscr) <> "ISENTO" .AND. ALLTRIM(cInscr) <> "") .AND. cTipoCli $ ("R/S")
		cGrTri := '021'
	CASE (ALLTRIM(cInscr) == "."  .OR. ALLTRIM(cInscr) == "ISENTO"  .OR. ALLTRIM(cInscr) == "") .AND. cTipoCli $ ("R/S")
		cGrTri := '011'
	CASE (ALLTRIM(cInscr) == "."  .OR. ALLTRIM(cInscr) == "ISENTO"  .OR. ALLTRIM(cInscr) == "") .AND. cContrib == "1" .AND. cTipoCli == "F" .AND. cTPJ == "3"
		cGrTri := '022'
	CASE !Empty(AllTrim(cSuframa))
		MsgBox("Favor procurar o departamento fiscal para corrigir cadastro do SUFRAMA. O Grupo de Tributação não foi gravado corretamente","STOP")
	OTHERWISE
		MsgBox("Favor procurar o departamento fiscal pois nenhuma regra foi encontrada para gravar o campo Grupo de Tributação","STOP")
	ENDCASE

	If cEmpAnt == "02"
		cGrTri := ""
	EndIf

Return(cGrTri)


/*/{Protheus.doc} fDelMSEXP
@description Funcao para limpar o campo C6_MSEXP, e forcar o calculo do Status para todos os pedidos em aberto 
@author Ranisses A. Corona
@since 03/02/2018
@history 02/05/2019, Ranisses A. Corona, Rotina foi desativado do Schedule do Protheus e transferida para um job no SQL Server.
@version undefined
@type function
/*/
User Function fDelMSEXP()
	Local Enter 	:= CHR(13)+CHR(10)
	Local aEmp		:= {"01","05","07","13","14"}
	Local x			:= 0
	Local cSql		:= ""

	//Inicializa o ambiente
	RPCSetType(3)
	WfPrepEnv("01","01")

	ConOut("HORA: "+TIME()+" - INICIO DA ROTINA fDelMSEXP")

	For x := 1 to Len(aEmp)

		ConOut("HORA: "+TIME()+" - Apagando o campo C6_MSEXP da Empresa " + aEmp[x])

		// 01 - Monta Base
		cSql := ""
		cSql += "SELECT SC6.R_E_C_N_O_  AS RECNO		" + Enter
		cSql += "INTO #TEMP_"+aEmp[x]+"					" + Enter
		cSql += "FROM SC6"+aEmp[x]+"0 SC6 				" + Enter
		cSql += "WHERE 	C6_FILIAL 			= '01'	AND	" + Enter
		cSql += "		C6_MSEXP 			<> '' 	AND	" + Enter
		cSql += "		C6_QTDVEN - C6_QTDENT > 0 	AND	" + Enter
		cSql += "		C6_BLQ 				<> 'R'	AND	" + Enter
		cSql += "		D_E_L_E_T_ 			= ''		" + Enter
		TcSQLExec(cSql)

		// 01 - Limpa campo para realizar a atualização do Status
		cSql := ""
		cSql += "UPDATE SC6"+aEmp[x]+"0 SET C6_MSEXP = '' FROM SC6"+aEmp[x]+"0 SC6 INNER JOIN #TEMP_"+aEmp[x]+"	 TMP ON SC6.R_E_C_N_O_ = TMP.RECNO "
		TcSQLExec(cSql)

	Next

	//DELETA TODOS OS DADOS DA TABELA TEMPORARIA - OBRIGATORIO PARA USO NA FUNCAO FN_STATUS_PV_??
	cSql := ""
	cSql += " DELETE FROM TBLRACSE1 "
	TcSQLExec(cSql)

	ConOut("HORA: "+TIME()+" - Calculando Status dos Pedidos")
	//Atualiza o Status
	//U_fUpdSC62()

	ConOut("HORA: "+TIME()+" - FINAL DA ROTINA fDelMSEXP")

	//Finaliza o ambiente criado
	RpcClearEnv()

Return()

/*/{Protheus.doc} zAtuPerg
@description Função que atualiza o conteúdo de uma pergunta no X1_CNT01 / SXK / Profile
@author Fernando Rocha
@since 07/04/2018
@version 1.0
@type function
@param cPergAux, characters, Código do grupo de Pergunta
@param cParAux, characters, Código do parâmetro
@param xConteud, variavel, Conteúdo do parâmetro
@example u_zAtuPerg("LIBAT2", "MV_PAR01", "000001")
/*/

User Function zAtuPerg(cPergAux, cParAux, xConteud)
	Local aArea      := GetArea()
	Local nPosCont   := 8
	Local nPosPar    := 14
	Local nLinEncont := 0
	Local aPergAux   := {}
	Default xConteud := ''

	//Se não tiver pergunta, ou não tiver ordem
	If Empty(cPergAux) .Or. Empty(cParAux)
		Return
	EndIf

	//Chama a pergunta em memória
	Pergunte(cPergAux, .F., /*cTitle*/, /*lOnlyView*/, /*oDlg*/, /*lUseProf*/, @aPergAux)

	//Procura a posição do MV_PAR
	nLinEncont := aScan(aPergAux, {|x| Upper(Alltrim(x[nPosPar])) == Upper(cParAux) })

	//Se encontrou o parâmetro
	If nLinEncont > 0
		//Caracter
		If ValType(xConteud) == 'C'
			&(cParAux+" := '"+xConteud+"'")

			//Data
		ElseIf ValType(xConteud) == 'D'
			&(cParAux+" := sToD('"+dToS(xConteud)+")'")

			//Numérico ou Lógico
		ElseIf ValType(xConteud) == 'N' .Or. ValType(xConteud) == 'L'
			&(cParAux+" := "+cValToChar(xConteud)+"")

		EndIf

		//Chama a rotina para salvar os parâmetros
		__SaveParam(cPergAux, aPergAux)
	EndIf

	RestArea(aArea)
Return

/*/{Protheus.doc} fDelTab
@description Função para retirar caracteres especiais
@author Ranisses A. Corona
@since 03/08/2018
@version 1.0
@type function
@param nCampo
@example u_fDelTab(SA1->A1_NOME)
/*/
User Function fDelTab(nCampo)
	Local nRet := ""

	nRet := StrTran(nCampo,CHR(9),"")	//Retira Tab
	nRet := StrTran(nRet,CHR(13),"") 	//Retira Enter
	nRet := StrTran(nRet,CHR(39),"") 	//Retira Aspas Simples
	nRet := StrTran(nRet,CHR(34),"") 	//Retira Aspas Duplas
	nRet := StrTran(nRet,CHR(148),"")   //Retirar aspas duplas
	nRet := StrTran(nRet,CHR(150),"-")	//Substitui caractere CHAR(150)-, pelo caractere CHAR(45)
	nRet := StrTran(nRet,CHR(146),"")	//Substitui caractere CHAR(146)’, pelo caractere ''
	nRet := FwCutOff(nRet, .F.)			//Funcao de apoio para retirar CR/LF/TAB de strings e eventualmente acentos

Return(nRet)


/*/{Protheus.doc} fUpdSC63
@description Funcao para atualizar o campo C6_YSTAST com o status o Item do Pedido 
@author Ranisses A. Corona
@since 02/05/2019
@version undefined
@history 02/05/2019, Ranisses A. Corona, A função fUpdSC63 irá substituir a função fUpdSC62.
@type function
/*/
User Function fUpdSC63()
	Local cSql		:= ""
	Local nQtdFull	:= 0
	Local nQtdDiff	:= 0

	//WfPrepEnv("01","01")
	//aResult := TCSPEXEC("SP_UPDATE_STATUS_SC6")

	cSql := " EXEC HADES.msdb.dbo.sp_help_job @job_name = N'Protheus->Atualiza Status SC6 - Full', @job_aspect = N'JOB', @execution_status = 1 "
	MScIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),'MS99',.F.,.T.)
	dbSelectArea("MS99")
	If !Eof()
		nQtdFull := 1
	EndIf
	MS99->(dbCloseArea())
	Ferase(MScIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(MScIndex+OrdBagExt())          //indice gerado


	MS099 := " EXEC HADES.msdb.dbo.sp_help_job @job_name = N'Protheus->Atualiza Status SC6 - Diff', @job_aspect = N'JOB', @execution_status = 1 "
	MScIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),'MS99',.F.,.T.)
	dbSelectArea("MS99")
	If !Eof()
		nQtdDiff := 1
	EndIf
	MS99->(dbCloseArea())
	Ferase(MScIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(MScIndex+OrdBagExt())          //indice gerado

	If nQtdFull == 0 .And. nQtdDiff == 0
		cSQL := " EXEC HADES.msdb.dbo.sp_start_job N'Protheus->Atualiza Status SC6 - Diff' "
		TcSQLExec(cSQL)
		nQtdFull := 1
		nQtdDiff := 1
	End


	While nQtdFull == 1 .Or. nQtdDiff == 1

		cSql := " EXEC HADES.msdb.dbo.sp_help_job @job_name = N'Protheus->Atualiza Status SC6 - Full', @job_aspect = N'JOB', @execution_status = 1 "
		MScIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),'MS99',.F.,.T.)
		dbSelectArea("MS99")
		If Eof()
			nQtdFull := 0
		EndIf
		MS99->(dbCloseArea())
		Ferase(MScIndex+GetDBExtension())     //arquivo de trabalho
		Ferase(MScIndex+OrdBagExt())          //indice gerado

		MS099 := " EXEC HADES.msdb.dbo.sp_help_job @job_name = N'Protheus->Atualiza Status SC6 - Diff', @job_aspect = N'JOB', @execution_status = 1 "
		MScIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),'MS99',.F.,.T.)
		dbSelectArea("MS99")
		If Eof()
			nQtdDiff := 0
		EndIf
		MS99->(dbCloseArea())
		Ferase(MScIndex+GetDBExtension())     //arquivo de trabalho
		Ferase(MScIndex+OrdBagExt())

	End


Return()


/*/{Protheus.doc} fValDEV
@description Funcao para validar se a rotina esta em ambiente de DESENVOVIMENTO
@author Ranisses A. Corona
@since 09/12/2020
@version undefined
@history 02/05/2019, Ranisses A. Corona, Criacao da funcao de validaçao
@type function
/*/
User Function fValDEV()
Local lDev		 := .F.
Local cServerIP	 := getServerIP()
Local cEnvServer := upper(getEnvServer())
 
lDev:=((cServerIP=="192.168.20.18") .or. ("DEV"$cEnvServer))

Return(lDev)


/*/{Protheus.doc} fGetBase
@description Funcao para retonar a database de acordo com o ambiente
@author Ranisses A. Corona
@since 09/12/2020
@version undefined
@history 02/05/2019, Ranisses A. Corona, Criacao da funcao de validaçao
@type function
/*/
User Function fGetBase(xSistema)
Local cBase		 := ""
Local cSistema	 := xSistema //1-Protheus 2-Bizagi
Local cServerIP	 := getServerIP()
Local cEnvServer := upper(getEnvServer())
 
If ((cServerIP=="192.168.20.18") .Or. ("DEV"$cEnvServer))
	cBase := Iif(cSistema=="1","DADOSADV","BIZAGIHOM")
ElseIf ((cServerIP=="192.168.20.18") .Or. ("HOM"$cEnvServer))
	cBase := Iif(cSistema=="1","DADOSADV","BIZAGIHOM")
Else
	cBase := Iif(cSistema=="1","DADOSADV","BIZAGIPRD")
EndI

Return(cBase)


/*/{Protheus.doc} fRegCobr
@description Funcao para retonar o codigo da Regra de Cobranca
@author Ranisses A. Corona
@since 18/02/2021
@version undefined
@history 18/02/2021, Ranisses A. Corona, Criacao da funcao de validaçao
@type function
/*/
User Function fRegCobr(xUF,xCPF,xGRPCLI,xCODCLI)
Local cCodReg	:= ''

DO CASE
	CASE U_fValFunc(xCPF) //Funcionario
		cCodReg := '000023'	
	CASE xGRPCLI $ ('001500_000252_001486_000010_000938_000380_000026_000036_001435') //Clientes Especiais
		cCodReg := '000023'
	CASE xCODCLI $ ('010083_004536_007871_026308_026423_018410_014395_018714_008615_028071') //Clientes Intragrupo
		cCodReg := '000023'
	CASE xUF == 'MG'
		cCodReg := '000028'  //BANESTES
	OTHERWISE
		cCodReg := '000029'  //FIDC
ENDCASE

Return(cCodReg)


/*/{Protheus.doc} fValFunc
@description Funcao para validar se o CPF pertence a um Funcionario
@author Ranisses A. Corona
@since 23/06/2021
@version undefined
@history 18/02/2021, Ranisses A. Corona, Criacao da funcao de validaçao
@type function
/*/
User Function fValFunc(xCPF)
Local cSQL		:= ''
Local cQry		:= GetNextAlias()
Local lRet		:= .F.

If U_fValDEV()
	cSQL :="SELECT LEN(REPLICATE('0',11-LEN(numcpf))+CONVERT(nvarchar,numcpf)) CPF FROM VETORH_DEV.dbo.r034fun WITH (NOLOCK) WHERE REPLICATE('0',11-LEN(numcpf))+CONVERT(nvarchar,numcpf) = '"+xCPF+"' "
Else
	cSQL :="SELECT LEN(REPLICATE('0',11-LEN(numcpf))+CONVERT(nvarchar,numcpf)) CPF FROM VETORH.dbo.r034fun WITH (NOLOCK) WHERE REPLICATE('0',11-LEN(numcpf))+CONVERT(nvarchar,numcpf) = '"+xCPF+"' "
EndIF 
TcQuery cSQL New Alias (cQry)

If (cQry)->CPF == 11 
	lRet := .T.
EndIf

(cQry)->(DbCloseArea())  

Return(lRet)


/*/{Protheus.doc} fVlFIDCLM
@description Funcao PROVISÓRIA para validar se o titulo deverá ser enviado para FIDC na LM
@author Ranisses A. Corona
@since 19/07/2021
@version undefined
@history 19/07/2021, Ranisses A. Corona, Criacao da funcao de validaçao
@type function
/*/
User Function fVlFIDCLM(xNUMPED)
Local cSQL		:= ''
Local aArea		:= GetArea()
Local cQryLM	:= GetNextAlias()
Local cQryOri	:= GetNextAlias()
Local lRet		:= .F.

If cEmpAnt == "07"

	//Consulta Pedido LM
	cSQL :="SELECT C5_YPEDORI, C5_YEMPPED FROM "+RetSqlName("SC5")+" WHERE C5_NUM = '"+xNUMPED+"' AND C5_EMISSAO >= '20210720' AND D_E_L_E_T_ = '' "
	TcQuery cSQL New Alias (cQryLM)

	If !(cQryLM)->(Eof()) .And. !Empty(Alltrim((cQryLM)->C5_YPEDORI)) .And. !Empty(Alltrim((cQryLM)->C5_YEMPPED))

		cSQL :="SELECT COUNT(*) QUANT FROM SC5"+(cQryLM)->C5_YEMPPED+"0 WHERE C5_NUM = '"+(cQryLM)->C5_YPEDORI+"' AND C5_EMISSAO >= '20210720' AND C5_CONDPAG = '505' AND D_E_L_E_T_ = '' "
		TcQuery cSQL New Alias (cQryOri)

		If (cQryOri)->QUANT >= 1 
			lRet := .T.
		EndIf
	
		(cQryOri)->(DbCloseArea())  
	
	EndIf

	(cQryLM)->(DbCloseArea())  


else
		
	cSQL :="SELECT COUNT(*) QUANT FROM "+RetSqlName("SC5")+" WHERE C5_NUM = '"+xNUMPED+"' AND C5_EMISSAO >= '20210720' AND C5_CONDPAG = '505' AND D_E_L_E_T_ = '' "
	TcQuery cSQL New Alias (cQryOri)

	If (cQryOri)->QUANT >= 1 
		lRet := .T.
	EndIf

	(cQryOri)->(DbCloseArea())  

EndIf

RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} fGetDbSr
@description Funcao para retornar o Alias da Database do sistema Senior
@author Gabriel Rossi Mafioletti
@since 16/07/2021
@version undefined
@history 
@type function
/*/

User Function fGetDbSr()

	Local _cRet		:=	""
	If U_fValDEV()
		_cRet	:=	"VETORH_DEV"
	Else
		_cRet	:=	"VETORH"
	EndIf
Return _cRet


/*/{Protheus.doc} fGetDbSr
@description Funcao utilizada para criacao de indices em todas as empresas
@author RANISSES A CORONA
@since 22/07/2021
@version undefined
@history 
@type function
/*/

User Function fCriaInd()
Local xv_Emps	:= U_BAGtEmpr("01_02_03_04_05_06_07_08_09_10_11_12_13_14_15_16_17_90_91")
Local xt		:= 0

	For xt := 1 To Len(xv_Emps)

		RPCSetEnv(xv_Emps[xt,1], xv_Emps[xt,2])

		RpcClearEnv()
	
	Next

Return
