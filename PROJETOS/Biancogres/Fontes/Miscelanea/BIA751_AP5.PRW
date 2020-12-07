#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/05/01

User Function Bia751()        // incluido pelo assistente de conversao do AP5 IDE em 29/05/01

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("CARQ,TITULO,NOMEPROG,NLASTKEY,LEND,WERROR")
SetPrvt("WARQ,WQUALIT,WDADO,WPOSCOD,WCODPRO,WDESPRO")
SetPrvt("BTIPO54,BTIPO75,BNFISCAL,BCODPRO,BCODPRO75,BDESPRO")
SetPrvt("BCFOP,CTRB,CTRB2,WREGFIM,WREGINI,WTOTREG,WNEWCOD")
SetPrvt("WNEWDES,WPOSDES,CDATAINIC,CDATAFINA,NQTDREG")

*------------------------------------------------------------------------------------------------------------------------------------------------------
// Programa : BIA751
// Autor    : AUGUSTO CESAR DE OLIVEIRA
// Data     : 18/02/2001
// Objetivo : Alterar, no registro 54, o código dos produtos onde
//            o conteudo do campo D2_YIMPNF seja "D"  e no regis-
//            tro 75 remover da descrição dos produto a letra "D"
//            ou conforme parâmetro definidos pelo usuário.
// Uso      : SIGAFIS
*-------------------------------------------------------------------------------------------------------------------------------------------------------

//Inicializa variaveis

cArq     := "SD2"
Titulo   := "Corrige codigo/descrição p/ O SINTEGRA"
NomeProg := "BIA751"
nLastKey := 0
nQtdReg  := 0
lEnd     := wError := .F.
If Alltrim(funname()) == "#BIA900" 
    Pergunte("MTA940",.F.)                
    If !File(MV_PAR04)
       MsgBox("Atencao, o arquivo "+Alltrim(mv_par04)+" nao foi encontrado! Favor verificar.","Atencao","ALERT")
       Return
    EndIf   
	wArq    := MV_PAR04 // Nome do arquivo SINTEGRA gerado pelo MICROSIGA - Trazer do Sintegra
	wQualit := "D" // Classes a serem alteradas (A,C,D) - Fixo D - Ranisses
	wDado   := "3" // Dado que subtituira a posição indicada pela variável wPosCod  - Fixo 3 - Ranisses
	wPosCod := 6 // Posição no código do produto a ser alterada - Fixo 6 - Ranisses
	wCodPro := 1 // 1-Habilita  2-Desabilita a alteração do código do produto - Fixo 1 - Ranisses
	wDesPro := 1 // 1-Habilita  2-Desabilita a alteração da descrição do produto - Fixo 1 - Ranisses
Else
	WHILE .T.
		PERGUNTE( NomeProg, .T. )
		IF ( nLastKey == 27 ) .OR. lEnd; RETURN; ENDIF
		wArq    := MV_PAR01 // Nome do arquivo SINTEGRA gerado pelo MICROSIGA
		wQualit := MV_PAR02 // Classes a serem alteradas (A,C,D)
		wDado   := MV_PAR03 // Dado que subtituira a posição indicada pela variável wPosCod
		wPosCod := MV_PAR04 // Posição no código do produto a ser alterada
		wCodPro := MV_PAR05 // 1-Habilita  2-Desabilita a alteração do código do produto
		wDesPro := MV_PAR06 // 1-Habilita  2-Desabilita a alteração da descrição do produto
		
		IF nLastKey == 27 .OR. lEnd; RETURN(NIL); ENDIF
		IF EMPTY(wArq) .OR. !FILE(wArq)
			MSGALERT("Informe um nome de arquivo válido")
			LOOP
		ENDIF
		IF EMPTY(wQualit)
			MSGALERT("Informe a clase a ser alterada")
			LOOP
		ENDIF
		EXIT
	ENDDO
EndIf
//Inicializa variáveis de trabalho
bTipo54   := {||LEFT(CTRB->REGISTRO,02) == "54"}
bTipo75   := {||LEFT(CTRB->REGISTRO,02) == "75"}
bNfiscal  := {||SUBS(CTRB->REGISTRO,22,06)}
bCodPro   := {||SUBS(CTRB->REGISTRO,38,14)}
bCodPro75 := {||SUBS(CTRB->REGISTRO,19,14)}
bDesPro   := {||SUBS(CTRB->REGISTRO,41,53)}
bCfop     := {||SUBS(CTRB->REGISTRO,28,04)}
bXCodPro  := {||SUBS(CTRB2->REGISTRO,38,14)}
bXNfiscal := {||SUBS(CTRB2->REGISTRO,22,06)}
bXSerie   := {||SUBS(CTRB2->REGISTRO,19,03)}

//bXDescPro := {||PADR(IIF(SD2->D2_YIMPNF == 'D',SUBSTR(Alltrim(SB1->B1_DESC),1,LEN(Alltrim(SB1->B1_DESC))-2),SB1->B1_DESC),53)}
bXDescPro := {||PADR(IIF(SD2->D2_YIMPNF == 'D',SUBSTR(Alltrim(SB1->B1_DESC),1,LEN(Alltrim(SB1->B1_DESC))-2),IF(SB1->B1_TIPO#"PA".AND.'"'$SB1->B1_DESC,STUFF(SB1->B1_DESC,AT('"',SB1->B1_DESC),1," "),SB1->B1_DESC)),53)}

//bXCodNCM  := {||SUBSTR(SB1->B1_POSIPI,1,4)+SUBSTR(SB1->B1_POSIPI,6,2)+SUBSTR(SB1->B1_POSIPI,9,2)} //RANISSES
bXCodNCM  := {||PADR(SB1->B1_POSIPI,8)}

bXTipProd := {||PADR(SB1->B1_TIPO,2)}
bXUm      := {||PADR(SB1->B1_UM,6)}
//bXOrig    := {||PADR(SB1->B1_ORIGEM,3)} 
bXOrig    := {||PADR(SD2->D2_CLASFIS,3)}
bXIPI     := {||STRZERO(SB1->B1_IPI*100,5)}
bXICM     := {||STRZERO(SB1->B1_PICM*100,4)}

//Cria arquivo temporário para receber arquivo do SINTEGRA
fCriaArq()

IF wError
	// Apaga arquivos temporário
	fDelTmp()
	RETURN(NIL)
ENDIF

//Recebe arquivo SINTEGRA gerado pelo MICROSIGA
fRec_Sintegra()

//Seleciona itens da nota fiscal e seleciona índice
DBSELECTAREA("SD2")
DBSETORDER(3)

//Altera o código do registro 54
If wCodPro == 1
	PROCESSA({|| fAltReg54() })// Substituido pelo assistente de conversao do AP5 IDE em 29/05/01 ==>       PROCESSA({|| EXECUTE(fAltReg54) })
EndIf

//Seleciona produtos e seleciona índice
DBSELECTAREA("SB1")
DBSETORDER(1)

//Seleciona itens da nota fiscal e seleciona índice
DBSELECTAREA("SD2")
DBSETORDER(3)

//Altera descrição do produto registro 75
If wDesPro == 1
	PROCESSA({|| fAltReg75() } )// Substituido pelo assistente de conversao do AP5 IDE em 29/05/01 ==>       PROCESSA({|| EXECUTE(fAltReg75) } )
	PROCESSA({|| fAltReg90() } )
EndIf

//Recria arquivo SINTEGRA
PROCESSA({|| fRecriaArq() } )

// Apaga arquivos temporário
fDelTmp()

RETURN( NIL )
*-------------------------------------------------------------------------------------------------------------------------------------------------------
//Cria arquivo temporário.
// Substituido pelo assistente de conversao do AP5 IDE em 29/05/01 ==> FUNCTION fCriaArq
Static FUNCTION fCriaArq()

CTRB := CRIATRAB({{"REGISTRO","C",126,0}})
DBUSEAREA(.T.,,CTRB,"CTRB")

IF ALIAS() #"CTRB"
	MSGALERT("Não foi possível abri o arquivo TEMPORÁRIO. Saia do Sistema e entre novamente")
	wError := .T.
	RETURN(NIL)
ENDIF

//INDEX ON Subs(REGISTRO,1,31)+Subs(REGISTRO,35,3) TO &CTRB 
INDEX ON REGISTRO TO &CTRB

RETURN( NIL )
*-------------------------------------------------------------------------------------------------------------------------------------------------------
// Recebe arquivo SINTEGRA gerado pelo MICROSIGA.
// Substituido pelo assistente de conversao do AP5 IDE em 29/05/01 ==> FUNCTION fRec_Sintegra
Static FUNCTION fRec_Sintegra()

DBSELECTAREA("CTRB")
APPEND FROM &wArq SDF

RETURN(NIL)
*-------------------------------------------------------------------------------------------------------------------------------------------------------
// Apaga arquivos temporário utilizados pelo programa.
// Substituido pelo assistente de conversao do AP5 IDE em 29/05/01 ==> FUNCTION fDelTmp
Static FUNCTION fDelTmp()

DBSELECTAREA("CTRB")
DBCLOSEAREA("CTRB")
FERASE(CTRB+".DBF")
FERASE(CTRB+".NTX")
FERASE(CTRB+".MEM")
DBSELECTAREA("CTRB2")
DBCLOSEAREA("CTRB2")
FERASE(CTRB+".DBF")
FERASE(CTRB+".NTX")
FERASE(CTRB+".MEM")
DBSELECTAREA("CTRB3")
DBCLOSEAREA("CTRB3")
FERASE(CTRB+".DBF")
FERASE(CTRB+".NTX")
FERASE(CTRB+".MEM")

RETURN(NIL)
*-------------------------------------------------------------------------------------------------------------------------------------------------------
// Substituido pelo assistente de conversao do AP5 IDE em 29/05/01 ==> FUNCTION fAltReg54
Static FUNCTION fAltReg54()

DBSELECTAREA("CTRB")

DBSEEK("55",.T.)
DBSKIP(-1)
wRegFim := RECNO()

DBSEEK("54")
wRegIni := RECNO()

wTotReg := (wRegFim - wRegIni)

PROCREGUA(wTotReg)

WHILE !(CTRB->(EOF())) .AND. EVAL(bTipo54)
	
	INCPROC('Alterando Registros 54.....')
	
	IF EVAL(bCfop) < "5000"
	//IF SUBS(EVAL(bCfop),2,3) < "500"
		fByPassa()
		LOOP
	ENDIF
	
	IF ! SD2->(DBSEEK(xFILIAL("SD2")+EVAL(bNfiscal),.F.))
		MSGALERT('Nota fiscal ' + EVAL(bNfiscal) + ' Nao encontrada.')
		fByPassa()
		LOOP
	ELSE
		fLeSD2()
	ENDIF
	
	DBSELECTAREA("CTRB")
	
	fByPassa()
	
ENDDO

RETURN(NIL)
*-------------------------------------------------------------------------------------------------------------------------------------------------------
// Acessa próximo registro
// Substituido pelo assistente de conversao do AP5 IDE em 29/05/01 ==> FUNCTION fByPassa
Static FUNCTION fByPassa()

DBSELECTAREA("CTRB")
DBSKIP()

RETURN(NIL)
*-------------------------------------------------------------------------------------------------------------------------------------------------------
// Substituido pelo assistente de conversao do AP5 IDE em 29/05/01 ==> FUNCTION fLeSD2
Static FUNCTION fLeSD2()

WHILE !SD2->(EOF()) .AND. (EVAL(bNfiscal) == ALLTRIM(SD2->D2_DOC)) .AND.;
	xFILIAL("SD2") == SD2->D2_FILIAL
	
	IF EVAL(bCodPro) == LEFT(SD2->D2_COD,14)
		IF SD2->D2_YIMPNF $ wQualit .And. !Empty(SD2->D2_YIMPNF)
			fGravacod()
			EXIT
		ENDIF
	ENDIF
	
	SD2->(DBSKIP())
	
ENDDO

RETURN(NIL)
*-------------------------------------------------------------------------------------------------------------------------------------------------------
// Substituido pelo assistente de conversao do AP5 IDE em 29/05/01 ==> FUNCTION fGravaCod
Static FUNCTION fGravaCod()

wNewCod := EVAL(bCodPro)        

wTipoProd := Posicione("SB1",1,xFilial("SB1")+wNewCod,"B1_RASTRO")

If Alltrim(wTipoProd) == "L" 
	wPosCod := 8
Else
	wPosCod := 6
EndIf 

//wNewCod := LEFT(wNewCod,wPosCod-1)+wDado+SUBS(wNewCod,wPosCod+1)
If Alltrim(wTipoProd) == "L" 
	wNewCod := LEFT(wNewCod,wPosCod-1)+wDado+IIF(SUBS(wNewCod,1,5) == "0000C","00      ","      ")
Else
	wNewCod := LEFT(wNewCod,wPosCod-1)+wDado+IIF(SUBS(wNewCod,1,5) == "0000C","00      ","        ")
EndIf

RECLOCK("CTRB",.F.)
CTRB->REGISTRO := LEFT(CTRB->REGISTRO,37)+wNewCod+SUBS(CTRB->REGISTRO,52)
MSUNLOCK()

RETURN(NIL)
*-------------------------------------------------------------------------------------------------------------------------------------------------------
// Substituido pelo assistente de conversao do AP5 IDE em 29/05/01 ==> FUNCTION fRecriaArq
Static FUNCTION fRecriaArq()

DBSELECTAREA("CTRB")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta serie das notas fiscais                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcRegua(Reccount()+1)
DbGotop()
Do while .not. eof()
	IncProc("Ajustando serie das notas fiscais")
	If left(CTRB->REGISTRO,2) == "50"
		If Subs(CTRB->REGISTRO,43,1)=="S"
			If Reclock("CTRB",.f.)
				CTRB->REGISTRO := Left(CTRB->REGISTRO,42)+"0"+Subs(CTRB->REGISTRO,44,83)
			EndIf
		EndIf
	ElseIf left(CTRB->REGISTRO,2) == "51"
		If Subs(CTRB->REGISTRO,41,1)=="S"
			If Reclock("CTRB",.f.)
				CTRB->REGISTRO := Left(CTRB->REGISTRO,40)+"0"+Subs(CTRB->REGISTRO,42,85)
			EndIf
		Endif
	ElseIf left(CTRB->REGISTRO,2) == "54"
		If Subs(CTRB->REGISTRO,19,1)=="S"
			If Reclock("CTRB",.f.)
				CTRB->REGISTRO := Left(CTRB->REGISTRO,18)+"0"+Subs(CTRB->REGISTRO,20,107)
			EndIf
		EndIf
	EndIf
	MsUnlock()
	DbSkip()
EndDo



DbSelectArea("CTRB")
COPY TO &wArq SDF

RETURN(NIL)
*-------------------------------------------------------------------------------------------------------------------------------------------------------
// Substituido pelo assistente de conversao do AP5 IDE em 29/05/01 ==> FUNCTION fAltReg75
Static FUNCTION fAltReg75()

// Cria uma nova tabela temporaria
CTRB2 := CRIATRAB({{"REGISTRO","C",126,0}})
DBUSEAREA(.T.,,CTRB2,"CTRB2")

IF ALIAS() # "CTRB2"
	MSGALERT("Não foi possível abri o 2o arquivo TEMPORÁRIO. Saia do Sistema e entre novamente")
	wError := .T.
	RETURN(NIL)
ENDIF

INDEX ON SUBS(CTRB2->REGISTRO,36,14) TO &CTRB2

// Copia para a nova tabela temporaria todos os registros tipo 54 com codigo de produto distintos
DBSELECTAREA("CTRB")
DBGOTOP()
PROCREGUA(CTRB->(LASTREC()))
DO WHILE !EOF()
	
	INCPROC('Copiando registros tipo 75...')
	
	// Captura a Data Inicial e a Data Final do periodo de validade de um registro tipo 75
	IF EVAL(bTipo75) .AND. Empty(cDataInic) .AND. Empty(cDataFina)
		cDataInic := SUBS(CTRB->REGISTRO,03,08)
		cDataFina := SUBS(CTRB->REGISTRO,11,08)
	ENDIF
	
	// Deleta da tabela temporaria todos os registros 75
	If SUBS(CTRB->REGISTRO,1,2) == "75"
		RECLOCK("CTRB",.F.)
		CTRB->(DBDELETE())
	ENDIF
	
	IF EVAL(bTipo54) .AND. !CTRB2->(DBSEEK(EVAL(bCodPro)))
		RECLOCK("CTRB2",.T.)
		CTRB2->REGISTRO := CTRB->REGISTRO
		CTRB2->(DBUNLOCK())
	ENDIF
	CTRB->(DBSKIP())
ENDDO

// Gera na tabela temporaria principal os novos registros tipo 75.
DBSELECTAREA("CTRB2")
DBGOTOP()
PROCREGUA(CTRB2->(LASTREC()))
DO WHILE !CTRB2->(EOF())
	
	INCPROC('Gerando registros tipo 75...'+EVAL(bXCodPro))
	
	//	IF !SB1->(DBSEEK(XFILIAL("SB1")+IIF(SUBS(EVAL(bXCodPro),6,1) == "3" .AND. EVAL(bXTipProd) == "PA",ALLTRIM(SUBSTR(EVAL(bXCodPro),1,6))+"00",EVAL(bXCodPro))))
	IF !SB1->(DBSEEK(XFILIAL("SB1")+IIF(SUBS(EVAL(bXCodPro),6,1) == "3" ,ALLTRIM(SUBSTR(EVAL(bXCodPro),1,6))+"00",EVAL(bXCodPro))))
		SB1->(DBSEEK(XFILIAL("SB1")+EVAL(bXCodPro)))
	ENDIF
	
	SD2->(DBSEEK(XFILIAL("SD2")+EVAL(bXNfiscal)+EVAL(bXSerie)))
	bXOrig := {||PADR(SD2->D2_CLASFIS,3)}							

	If CTRB->(!DbSeek("75"+cDataInic+cDataFina+EVAL(bXCodPro)))
		RECLOCK("CTRB",.T.)
		If Alltrim(EVAL(bXCodPro)) <> ""
			//CTRB->REGISTRO := "75"+cDataInic+cDataFina+EVAL(bXCodPro)+EVAL(bxCodNcm)+EVAL(bXDescPro)+EVAL(bXUm)+EVAL(bXOrig)+EVAL(bXIPI)+EVAL(bXICM)+REPLICATE("0",16)			
			CTRB->REGISTRO := "75"+cDataInic+cDataFina+EVAL(bXCodPro)+EVAL(bxCodNcm)+EVAL(bXDescPro)+EVAL(bXUm)+EVAL(bXIPI)+"1700"+REPLICATE("0",18)			
			CTRB->(DBUNLOCK())
		EndIF
		If SUBS(CTRB->REGISTRO,1,2) == "75"
			nQtdReg := nQtdReg + 1
		EndIf
	EndIf
	CTRB2->(DBSKIP())
ENDDO
RETURN(NIL)
*-------------------------------------------------------------------------------------------------------------------------------------------------------
// Substituido pelo assistente de conversao do AP5 IDE em 29/05/01 ==> FUNCTION fGravaDes
Static FUNCTION fGravaDes()

wNewDes := EVAL(bDesPro)
wPosDes := LEN(RTRIM(wNewDes))
wNewDes := LEFT(wNewDes,wPosDes-1)+" "+SUBS(wNewDes,wPosDes+1)
RECLOCK("CTRB",.F.)
CTRB->REGISTRO := LEFT(CTRB->REGISTRO,40)+wNewDes+SUBS(CTRB->REGISTRO,94)
MSUNLOCK()
ALERT(CTRB->REGISTRO)

RETURN(NIL)
*-------------------------------------------------------------------------------------------------------------------------------------------------------
Static FUNCTION fAltReg90()

// Cria uma nova tabela temporaria
CTRB3 := CRIATRAB({{"REGISTRO","C",126,0}})
DBUSEAREA(.T.,,CTRB3,"CTRB3")

DBSELECTAREA("CTRB")
If dbseek("90",.T.)
	ntot90 := Val(Subs(CTRB->REGISTRO,83,8))
	ntotal := Val(Subs(CTRB->REGISTRO,93,8))
	ntotal := ntotal - ntot90 + nQtdReg
	If Reclock("CTRB",.f.)
		CTRB->REGISTRO := Left(CTRB->REGISTRO,82)+Strzero(nQtdReg,8)+"99"+Strzero(ntotal,8)+Subs(CTRB->REGISTRO,101,28)
		MsUnlock()
	EndIf
EndIf

RETURN(NIL)
