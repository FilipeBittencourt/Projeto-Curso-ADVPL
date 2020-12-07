#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01
#include "TOPCONN.ch"
#IFNDEF WINDOWS
	#DEFINE PSAY SAY
#ENDIF

User Function Bia084()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("CDESC1,CDESC2,CDESC3,TAMANHO,LIMITE,CSTRING")
SetPrvt("TITULO,ARETURN,NOMEPROG,NLASTKEY,WNUMBER,CBCONT")
SetPrvt("CPERG,WNREL,CABEC1,CABEC2,C15,CBTXT")
SetPrvt("LI,M_PAG,WDATADE,WDATAATE,WPRODDE,WPRODATE")
SetPrvt("WUNIMED,WMASCPRO,WAGLGRAD,WSERIE,WFORMA,WVENDDE")
SetPrvt("WVENDATE,_ACAMPOS,_CTRAB,_cTrb,,_cTrb2,_cTrb3,WOLDCLAS,WOLDVEND")
SetPrvt("WOLDCOR,WOLDLINE,WOLDNOME,WOLDPROD,ACLASSE,ACORES")
SetPrvt("ALINHA,ACLASSEA,ACLASSEC,ACLASSED,ATOTGER,ATOTGERG,AFORMATO")
SetPrvt("WPRIMVEZ,WNOMEVEND,OLDDATA,WINCREMEN,WPEDIDO,WC6VALDESC")
SetPrvt("WNOTA,WPRCUNIT,WICLASSE,WITGERAL,OLDAREA,CHA_PESQ1")
SetPrvt("CHA_PESQ2,CHA_PESQ3,CHA_PESQ4,OLDFORMATO,WIDETALHE,GeraDuplicata")

//Inicializa variaveis
cDesc1	  := "Este programa tem como objetivo emitir um relatorio do "
cDesc2	  := "Resumo de Vendas por Vendedor"
cDesc3	  := ""
tamanho	  := "M"
limite	  := 132
cString	  := "SC5"
titulo	  := "RESUMO DE VENDAS POR VENDEDOR (EM METROS QUADRADOS)"
aReturn	  := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
nomeprog   := "BIA084"
nLastKey   := wNumber := cbcont := 0
cPerg 	  := "BIA084"
wnrel 	  := "BIA084"
Cabec1	  := "CODIGO     DESCRICAO DO PRODUTO              PRECO      QTD TOTAL      VLR TOTAL   UNIT.     QUANTIDADE          VALOR      DESCONTO"
Cabec2	  := "                                          UNITARIO    DOS PEDIDOS    DOS PEDIDOS  FATUR.       FATURADA       FATURADA     CONCEDIDO"
C15		  := 15
cbtxt 	  := space(10)
li 		  := 80
m_pag 	  := 1

If !GetRemoteType() == 5 .And. !__cUserID="000996"
	wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,tamanho,,.F.)
	
	PERGUNTE( cPerg, .F. )
	
	If ( nLastKey == 27 ) .OR. ( LastKey() == 27 )
		Return
	Endif
Else
	If !Pergunte(cPerg,.T.)
		Return
	EndIf
EndIf 


IF !EMPTY(CREPATU) //SE REPRESENTANTE (VARIAVEL PRG BIA125)
	wDataDe	  := IF(DTOS(MV_PAR01)<DTOS(ddatabase - 90),(ddatabase - 90),MV_PAR01) // emissao da NF 90 DIAS ANTES DA DATABASE
	wDataAte  := mv_par02
ELSE
	wDataDe	  := mv_par01
	wDataAte  := mv_par02
ENDIF
wProdDe	 := mv_par03
wProdAte := mv_par04
wUniMed	 := mv_par05
wMascPro := mv_par06
wAglGrad := mv_par07
wSerie	 := mv_par08
wForma	 := mv_par09
wVendDe	 := IF(!EMPTY(CREPATU),CREPATU,MV_PAR10)
wVendAte := IF(!EMPTY(CREPATU),CREPATU,MV_PAR11)
wEstDe	 := mv_par12
wEstAte  := mv_par13
If MV_PAR14 = 1
	GeraDuplicata := "S"
elseIf MV_PAR14 = 2
	GeraDuplicata := "N"
else
	GeraDuplicata := "A"
end if

If MV_PAR15 = 1
	AtualizaEstoque := "S"
elseIf MV_PAR15 = 2
	AtualizaEstoque := "N"
else
	AtualizaEstoque := "A"
end if

////caso seja representante entrado pelo browser
//If GetRemoteType() == 5
//	RptStatus({|| BIA086TR() })
//	Return
//EndIf

If ( nLastKey == 27 ) .OR. ( LastKey() == 27 )
	Return
Endif

// Monta arquivo de trabalho
Processa( {|| fMonta_Arq() } )// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> 	Processa( {|| Execute(fMonta_Arq) } )

// LE PEDIDOS
Processa( {|| fLe_SC6() } )// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> 	Processa( {|| Execute(fLe_SC6) } )

// LE FATURAS
Processa( {|| fLe_SD2() } )// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> 	Processa( {|| Execute(fLe_SD2) } )


If GetRemoteType() == 5 .Or. __cUserID="000996"
	RptStatus({|| U_BIA084TR() })
	
Else
	//Verifica Posicao do Formulario na Impressora
	SetDefault(aReturn,cString)
	
	// IMPRIME RELATORIO
	Processa( {|| fImpressao() } )// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> 	Processa( {|| Execute(fImpressao) } )
	
	//RODAPE
	Roda(cbcont,cbtxt,tamanho)
EndIf

//APAGA ARQUIVO DE TRABALHO
DbSelectArea("_cTrab")
DBCLOSEAREA()

If File(_cTrab+".DBF")
	Ferase(_cTrab+".DBF")
	Ferase(_cTrab+".cdx")
Endif

If chkfile("_cTrab")
	dbSelectArea("_cTrab")
	dbCloseArea()
EndIf

//APAGA ARQUIVO DE TRABALHO
DbSelectArea("_cTrb")
DBCLOSEAREA()

If File(_cTrb+".DBF")
	Ferase(_cTrb+".DBF")
	Ferase(_cTrb+".cdx")
Endif

If chkfile("_cTrb")
	dbSelectArea("_cTrb")
	dbCloseArea()
EndIf

//APAGA ARQUIVO DE TRABALHO
DbSelectArea("_cTrb2")
DBCLOSEAREA()

If File(_cTrb2+".DBF")
	Ferase(_cTrb2+".DBF")
	Ferase(_cTrb2+".cdx")
Endif

If chkfile("_cTrb2")
	dbSelectArea("_cTrb2")
	dbCloseArea()
EndIf

//APAGA ARQUIVO DE TRABALHO
DbSelectArea("_cTrb3")
DBCLOSEAREA()

If File(_cTrb3+".DBF")
	Ferase(_cTrb3+".DBF")
	Ferase(_cTrb3+".cdx")
Endif

If chkfile("_cTrb3")
	dbSelectArea("_cTrb3")
	dbCloseArea()
EndIf

//LIBERA IMPRESSAO
If aReturn[5] == 1
	Set Printer To
	Ourspool(wnrel)
Endif

MS_FLUSH()

//FIM DO PROGRAMA

RETURN( NIL )

Static FUNCTION fMonta_Arq()

_aCampos := { {"PRODUTO ","C",21, 0},;
{"NOMEPROD","C",30, 0},;
{"VENDEDOR","C",06, 0},;
{"PRUNIT  ","N",12, 2},;
{"QTDEVEND","N",12, 2},;
{"VLRVEND ","N",12, 2},;
{"QTDEFAT ","N",12, 2},;
{"PRUNIFAT","N",12, 2},;
{"VLRFAT  ","N",12, 2},;
{"UM      ","C",02, 2},;
{"DESCONTO","N",12, 2} }
If chkfile("_cTrab")
	dbSelectArea("_cTrab")
	dbCloseArea()
EndIf
_cTrab := CriaTrab(_aCampos, .T.)

DbUseArea(.T.,,_cTrab,"_cTrab")
DbCreateInd(_cTrab,"VENDEDOR+PRODUTO+STR(PRUNIT,10,2)",{||VENDEDOR+PRODUTO+STR(PRUNIT,10,2)})

_aCampos := { {"PRODUTO ","C",15, 0},;
{"NOMEPROD","C",30, 0},;
{"VENDEDOR","C",06, 0},;
{"PRUNIT  ","N",12, 2},;
{"QTDEVEND","N",12, 2},;
{"VLRVEND ","N",12, 2},;
{"QTDEFAT ","N",12, 2},;
{"PRUNIFAT","N",12, 2},;
{"VLRFAT  ","N",12, 2},;
{"UM      ","C",02, 2},;
{"DESCONTO","N",12, 2} }
If chkfile("_cTrb")
	dbSelectArea("_cTrb")
	dbCloseArea()
EndIf
_cTrb := CriaTrab(_aCampos, .T.)

DbUseArea(.T.,,_cTrb,"_cTrb")
DbCreateInd(_cTrb,"VENDEDOR+PRODUTO",{||VENDEDOR+PRODUTO})

_aCampos := { {"PRODUTO ","C",20, 0},;
{"CLASSE  ","C",01, 0},;
{"NOMEPROD","C",30, 0},;
{"PRUNIT  ","N",12, 2},;
{"QTDEVEND","N",12, 2},;
{"VLRVEND ","N",12, 2},;
{"QTDEFAT ","N",12, 2},;
{"PRUNIFAT","N",12, 2},;
{"VLRFAT  ","N",12, 2},;
{"UM      ","C",02, 2},;
{"DESCONTO","N",12, 2} }
If chkfile("_cTrb2")
	dbSelectArea("_cTrb2")
	dbCloseArea()
EndIf
_cTrb2 := CriaTrab(_aCampos, .T.)

DbUseArea(.T.,,_cTrb2,"_cTrb2")
DbCreateInd(_cTrb2,"PRODUTO+CLASSE",{||PRODUTO+CLASSE})

_aCampos := { {"PRODUTO ","C",20, 0},;
{"NOMEPROD","C",30, 0},;
{"PRUNIT  ","N",12, 2},;
{"QTDEVEND","N",12, 2},;
{"VLRVEND ","N",12, 2},;
{"QTDEFAT ","N",12, 2},;
{"PRUNIFAT","N",12, 2},;
{"VLRFAT  ","N",12, 2},;
{"UM      ","C",02, 2},;
{"DESCONTO","N",12, 2} }
If chkfile("_cTrb3")
	dbSelectArea("_cTrb3")
	dbCloseArea()
EndIf
_cTrb3 := CriaTrab(_aCampos, .T.)

DbUseArea(.T.,,_cTrb3,"_cTrb3")
DbCreateInd(_cTrb3,"PRODUTO",{||PRODUTO})

RETURN( NIL )

// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fImpressao
Static FUNCTION fImpressao()

dbSelectArea("_cTrab")
dbGoTop()

//Monta regua
IncProc( _cTrab->( LastRec() ) )

DbSelectArea("SB1")
DbSetOrder(1)
DbSeek(xFilial("SB1")+_cTrab->PRODUTO)
//Inicializa variaveis normais e de quebra

wOldClas  := SB1->B1_YCLASSE
wOldVend  := _cTrab->VENDEDOR
wOldCor	  := SUBSTR(SB1->B1_YLINHA,4,1)
wOldLine  := SUBSTR(SB1->B1_YLINHA,1,3)
wOldNome  := _cTrab->NOMEPROD
wOldProd  := _cTrab->PRODUTO
aClasse	  := {0,0,0,0,0,0,0}
aCores	  := {0,0,0,0,0,0,0}
aLinha	  := {0,0,0,0,0,0,0}
aClasseA  := {0,0,0,0,0,0,0}
aClasseC  := {0,0,0,0,0,0,0}
aClasseD  := {0,0,0,0,0,0,0}
aTotGer	  := {0,0,0,0,0,0,0}
aTotGerG  := {0,0,0,0,0,0,0}
aFormato  := {0,0,0,0,0,0,0}
wPrimVez  := .T.

//Processa arquivo de trabalho

While ! EOF()
	
	//Incrementa regua
	IncProc()
	
	If Empty(_cTrab->VENDEDOR)
		DbSkip()
		Loop
	EndIf
	
	If li >= 62
		Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
	Endif
	
	// IMPRIME O NOME DA LINHA SE E A PRIMEIRA VEZ QUE PASSA POR AQUI
	If wPrimVez
		
		DbSelectArea("SA3")
		DbSeek(xFilial("SA3")+wOldVend,.T.)
		wNomeVend := SA3->A3_NOME
		@ li, 000 PSAY SA3->A3_COD+" - "+wNomeVend
		li := li + 2
		
		dbSelectArea("_cTrab")
		
		wPrimVez   := .F.
		
	EndIf
	
	//Quebra de Vendedor 
	//# é a mesma coisa de diferente. Pode ser usado != ou <> também
	If _cTrab->VENDEDOR #wOldVend
		
		fImpRes()
		
		If li+3 >= 62
			Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
		EndIf
		
		li := li + 1
		@ li,000 PSAY Replicate( "-", Limite )
		li := li + 2
		
		If li+3 >= 62
			Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
		EndIf
		
		wOldVend := _cTrab->VENDEDOR
		DbSelectArea("SA3")
		DbSeek(xFilial("SA3")+wOldVend,.T.)
		wNomeVend := SA3->A3_NOME
		@ li, 000 PSAY SA3->A3_COD+" - "+wNomeVend
		li := li + 2
		
		dbSelectArea("_cTrab")
	EndIf
	
	fAcumula()
	
	fGravaRes()
	
	dbSelectArea("_cTrab")
	dbSkip()
	
EndDo

fImpRes()
fImpProd()
fImpGer()

Return( NIL )

// REGRAVA PRODUTOS DA CARTEIRA DE PEDIDOS EM ARQUIVO TEMPORARIO

// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fLe_SC6
Static FUNCTION fLe_SC6()

ProcRegua( IIF( ( wDataDe	- wDataAte) == 0, 1, (wDataAte  - wDataDe) ) )

Csql := ""
Csql += "SELECT	* "
Csql += "FROM "+RetSqlName("SC5")+" SC5, "+RetSqlName("SA1")+" SA1 "
Csql += "WHERE	C5_FILIAL	= '"+xFilial("SC5")+"'	AND "
Csql += "		A1_FILIAL	= '"+xFilial("SA1")+"'	AND "
Csql += "		C5_CLIENTE	= A1_COD				AND "
Csql += "		C5_LOJACLI	= A1_LOJA				AND "
Csql += "		C5_VEND1	>= '"+wVendDe+"'		AND "
Csql += "		C5_VEND1	<= '"+wVendAte+"'		AND "
Csql += "		A1_EST		>= '"+wEstDe+"'			AND "
Csql += "		A1_EST		<= '"+wEstAte+"'		AND "
Csql += "		C5_EMISSAO 	>= '"+Dtos(wDataDe)+"'  AND "
Csql += "		C5_EMISSAO 	<= '"+Dtos(wDataAte)+"' AND "
Csql += "		SC5.D_E_L_E_T_	= '' 				AND "
Csql += "		SA1.D_E_L_E_T_	= '' 					"
If chkfile("_SC5")
	dbSelectArea("_SC5")
	dbCloseArea()
EndIf
TCQUERY Csql ALIAS "_SC5" NEW

dbSelectArea("_SC5")
dbGotop("_SC5")

//DbSelectArea("SC5")
//DbSetOrder(2)
//DbSeek(xFilial("SC5")+Dtos(wDataDe),.T.)

OldData :=	wDataDe

While !Eof() //.and. SC5->C5_EMISSAO <= wDataAte
	
	//wIncremen	:= CTOD(_SC5->C5_EMISSAO) - OldData
	wPedido	 	:= _SC5->C5_NUM
	
	/*IF ( wIncremen > 0 )
		IncProc( wIncremen )
	ENDIF*/
	
	/*IF Empty(_SC5->C5_VEND1)
		DbSkip()
		Loop
	ENDIF*/
	
	// VERIFICANDO SE E O GERENTE // BRUNO MADALENO
	IF ! EMPTY(CREPATU) .AND. SUBSTRING(CREPATU,1,1) = "1"
		
		DBSELECTAREA("SA1")
		DBSETORDER(1)
		DBSEEK( xFilial("SA1")+_SC5->C5_CLIENTE+_SC5->C5_LOJACLI)
		
		IF CEMPANT == "01"
			IF (SA1->A1_YVENDB2 <> CREPATU .AND. SA1->A1_YVENDB3 <> CREPATU)
				_SC5->(DBSKIP())
				LOOP
			END IF
		ELSE
			IF (SA1->A1_YVENDI2 <> CREPATU .AND. SA1->A1_YVENDI3 <> CREPATU)
				_SC5->(DBSKIP())
				LOOP
			END IF
		END IF
		
		/*IF ( SC5->C5_VEND1 < MV_PAR10 ) .OR. ( SC5->C5_VEND1 > MV_PAR11 )
			SC5->(DBSKIP())
			LOOP
		ENDIF*/

	/*ELSE

		IF SC5->C5_VEND1 < wVendDe
			DbSkip()
			Loop
		ENDIF
		
		IF SC5->C5_VEND1 > wVendAte
			DbSkip()
			Loop
		ENDIF*/

	END IF

	IF ALLTRIM(wSerie) == "S2" .AND. ALLTRIM(_SC5->C5_YSUBTP) <> "I"
		DbSkip()
		Loop
	ENDIF
	
	DbSelectArea("SC6")
	DbSetOrder(1)
	DbSeek( xFilial("SC6")+_SC5->C5_NUM, .T. )
	wC6VALDESC := 0
	
	While SC6->C6_NUM == wPedido
		
		If (SC6->C6_PRODUTO < wProdDe) .or. (SC6->C6_PRODUTO > wProdAte)
			DbSelectArea("SC6")
			DbSkip()
			Loop
		Endif
		
		//Para nao considerar venda de argila
		If Subst(SC6->C6_PRODUTO,1,1) < "A"
			DbSelectArea("SC6")
			DbSkip()
			Loop
		Endif
		
		If SC6->C6_QTDVEN == 0
			DbSelectArea("SC6")
			DbSkip()
			Loop
		Endif
		
		DBSELECTAREA("SB1")
		DBSETORDER(1)
		
		DBSEEK( xFILIAL("SB1")+SC6->C6_PRODUTO, .T. )
		
		If SB1->B1_TIPO <> "PA"
			DbSelectArea("SC6")
			DbSkip()
			Loop
		Endif
		
		DbSelectArea("SF4")
		DbSetOrder(1)
		
		If DbSeek(xFilial("SF4")+SC6->C6_TES,.T.)
			If SF4->F4_DUPLIC == "S" .and. SF4->F4_ESTOQUE == "S"
				//if (GeraDuplicata = SF4->F4_DUPLIC .OR. GeraDuplicata = "A") .AND. ;  // Bruno
				//	(AtualizaEstoque = SF4->F4_DUPLIC .OR. GeraDuplicata = "A")
				
				DbSelectArea("_cTrab")
				RecLock("_cTrab", ! DbSeek( _SC5->C5_VEND1 + SC6->C6_PRODUTO + IIF( wForma == 1, STR(SC6->C6_PRCVEN,10,2), "" ), .F. ) )
				
				If wUniMed == 1
					_cTrab->QTDEVEND := _cTrab->QTDEVEND + SC6->C6_QTDVEN
					_cTrab->PRUNIT   := SC6->C6_PRCVEN
					_cTrab->UM   	 := SC6->C6_UM
				Else
					_cTrab->QTDEVEND := _cTrab->QTDEVEND + SC6->C6_UNSVEN
					_cTrab->PRUNIT   := SC6->C6_VALOR/SC6->C6_UNSVEN
					_cTrab->UM		 := SC6->C6_SEGUM
				Endif
				
				_cTrab->VENDEDOR := _SC5->C5_VEND1
				_cTrab->PRODUTO  := SC6->C6_PRODUTO
				_cTrab->NOMEPROD := SB1->B1_DESC
				_cTrab->VLRVEND  := _cTrab->VLRVEND + SC6->C6_VALOR
				wC6VALDESC	     := ((SC6->C6_VALOR * SC6->C6_YDESC) / 100)
				_cTrab->DESCONTO := _cTrab->DESCONTO + wC6VALDESC
				
				msUnLock()
				dbcommit()
				
			Endif
		Endif
		
		DbSelectArea("SC6")
		DbSkip()
		
	EndDo
	
	OldData := _SC5->C5_EMISSAO
	
	DbSelectArea("_SC5")
	DbSkip()
	
EndDo

IncProc()

RETURN( NIL )

// LE GRAVA PRODUTOS FATURADOS EM ARQUIVO TEMPORARIO

// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fLe_SD2
Static FUNCTION fLe_SD2()

ProcRegua( IIF( ( wDataDe	- wDataAte) == 0, 1, (wDataAte  - wDataDe) ) )

Csql := ""
Csql += "SELECT	*	"
Csql += "FROM "+ RETSQLNAME("SF2")+" "
Csql += "WHERE	F2_FILIAL	= '"+xFilial("SF2")+"'	AND "
Csql += "		F2_SERIE	= '"+wSerie+"'			AND "
Csql += "		F2_VEND1	>= '"+wVendDe+"'		AND "
Csql += "		F2_VEND1	<= '"+wVendAte+"'		AND "
Csql += "		F2_EST		>= '"+wEstDe+"'			AND "
Csql += "		F2_EST		<= '"+wEstAte+"'		AND "
Csql += "		F2_EMISSAO 	>= '"+Dtos(wDataDe)+"'  AND "
Csql += "		F2_EMISSAO 	<= '"+Dtos(wDataAte)+"' AND "
Csql += "		D_E_L_E_T_	= '' "
If chkfile("_SF2")
	dbSelectArea("_SF2")
	dbCloseArea()
EndIf
TCQUERY Csql ALIAS "_SF2" NEW

dbSelectArea("_SF2")
dbGotop("_SF2")
While !_SF2->(Eof())
	
	//wIncremen 	:= _SC5->C5_EMISSAO - OldData
	wNota 	 	:= _SF2->F2_DOC
	
	/*IF ( wIncremen > 0 )
		IncProc( wIncremen )
	ENDIF*/
	
	/*IF _SF2->F2_VEND1 < wVendDe
		DbSkip()
		Loop
	ENDIF
	
	IF _SF2->F2_VEND1 > wVendAte
		DbSkip()
		Loop
	ENDIF*/
	
	IF Empty(_SF2->F2_VEND1)
		MsgAlert("Nota Fiscal "+_SF2->F2_DOC+" Sem Vendedor")
		DbSkip()
		Loop
	ENDIF
	
	/*IF _SF2->F2_EST <= wEstDe
		DbSkip()
		Loop
	ENDIF
	
	IF _SF2->F2_EST >= wEstAte
		DbSkip()
		Loop
	ENDIF*/
	

	/*If ( _SF2->F2_SERIE # wSerie ) .AND. ( wSerie # "***" )
		DbSelectArea("_SF2")
		DbSkip()
		Loop
	Endif*/
	
	DbSelectArea("SD2")
	DbSetOrder(3)
	DbSeek(xFilial("SD2")+wNota+_SF2->F2_SERIE,.F.)
	
	While ( SD2->D2_DOC == wNota )
		
		If SUBST(SD2->D2_GRUPO,1,2) <> "PA"
			DbSelectArea("SD2")
			DbSkip()
			Loop
		Endif
		
		If SD2->D2_QUANT == 0
			DbSelectArea("SD2")
			DbSkip()
			Loop
		Endif
		
		If ( SD2->D2_COD < wProdDe ) .or. ( SD2->D2_COD > wProdAte )
			DbSelectArea("SD2")
			DbSkip()
			Loop
		Endif
		
		//Para nao considerar venda de argila
		If Subst(SD2->D2_COD,1,1) < "A"
			DbSelectArea("SD2")
			DbSkip()
			Loop
		Endif
		
		DbSelectArea("SF4")
		DbSetOrder(1)
		
		If DbSeek( xFilial("SF4")+SD2->D2_TES, .T. )
			if (GeraDuplicata = SF4->F4_DUPLIC .OR. GeraDuplicata = "A") .AND. ;  // Bruno
				(AtualizaEstoque = SF4->F4_DUPLIC .OR. GeraDuplicata = "A")
				
				DbSelectArea("SB1")
				DbSetOrder(1)
				DbSeek(xFilial("SB1")+SD2->D2_COD )
				
				DbSelectArea("_cTrab")
				
				wPrcUnit := IIF( wUniMed == 1, SD2->D2_PRCVEN, SD2->D2_TOTAL/SD2->D2_QTSEGUM )
				
				If ! DbSeek( _SF2->F2_VEND1 + SD2->D2_COD+IIF( wForma == 1, Str(wPrcUnit,10,2), "" ), .F. )
					
					RecLock("_cTrab",.T.)
					
					_cTrab->VENDEDOR := _SF2->F2_VEND1
					_cTrab->PRODUTO  := SD2->D2_COD
					_cTrab->NOMEPROD := SB1->B1_DESC
					
					If wUniMed == 1
						_cTrab->UM		 := SD2->D2_UM
						_cTrab->QTDEFAT  := _cTrab->QTDEFAT + SD2->D2_QUANT
						_cTrab->PRUNIFAT := SD2->D2_PRCVEN
					Else
						_cTrab->UM		 := SD2->D2_SEGUM
						_cTrab->QTDEFAT  := _cTrab->QTDEFAT + SD2->D2_QTSEGUM
						_cTrab->PRUNIFAT := SD2->D2_TOTAL/SD2->D2_QTSEGUM
					Endif
					
					_cTrab->VLRFAT := _cTrab->VLRFAT + SD2->D2_TOTAL
					
					msUnLock()
					
				Else
					
					RecLock("_cTrab",.F.)
					
					If wUniMed == 1
						_cTrab->QTDEFAT  := _cTrab->QTDEFAT + SD2->D2_QUANT
						_cTrab->PRUNIFAT := SD2->D2_PRCVEN
					Else
						_cTrab->QTDEFAT  := _cTrab->QTDEFAT + SD2->D2_QTSEGUM
						_cTrab->PRUNIFAT := SD2->D2_TOTAL/SD2->D2_QTSEGUM
					Endif
					
					_cTrab->VLRFAT := _cTrab->VLRFAT + SD2->D2_TOTAL
					
					msUnLock()
					
				Endif
			end if
		Endif
		
		DbSelectArea("SD2")
		DbSkip()
		
	EndDo
	
	DbSelectArea("_SF2")
	DbSkip()
	
EndDo

IncProc()

RETURN( NIL )

Static FUNCTION fAcumula()

DbSelectArea("SB1")
DbSetOrder(1)
DbSeek(xFilial("SB1")+_cTrab->PRODUTO)

//Acumula TOTAL DA CLASSE por quebra
aClasse[3] := aClasse[3] + _cTrab->VLRVEND
aClasse[2] := aClasse[2] + _cTrab->QTDEVEND
aClasse[1] := aClasse[3] / aClasse[2]
aClasse[6] := aClasse[6] + _cTrab->VLRFAT
aClasse[5] := aClasse[5] + _cTrab->QTDEFAT
aClasse[4] := aClasse[6] / aClasse[5]
aClasse[7] := aClasse[7] + _cTrab->DESCONTO

//Acumula TOTAL DO PRODUTO (cores) por quebra
aCores[3] := aCores[3] + _cTrab->VLRVEND
aCores[2] := aCores[2] + _cTrab->QTDEVEND
aCores[1] := aCores[3] / aCores[2]
aCores[6] := aCores[6] + _cTrab->VLRFAT
aCores[5] := aCores[5] + _cTrab->QTDEFAT
aCores[4] := aCores[6] / aCores[5]
aCores[7] := aCores[7] + _cTrab->DESCONTO

//Acumula TOTAL DA LINHA por quebra
aLinha[3] := aLinha[3] + _cTrab->VLRVEND
aLinha[2] := aLinha[2] + _cTrab->QTDEVEND
aLinha[1] := aLinha[3] / aLinha[2]
aLinha[6] := aLinha[6] + _cTrab->VLRFAT
aLinha[5] := aLinha[5] + _cTrab->QTDEFAT
aLinha[4] := aLinha[6] / aLinha[5]
aLinha[7] := aLinha[7] + _cTrab->DESCONTO

//Acumula TOTAL GERAL DA CLASSE A
IF SB1->B1_YCLASSE == "1"
	aClasseA[3] := aClasseA[3] + _cTrab->VLRVEND
	aClasseA[2] := aClasseA[2] + _cTrab->QTDEVEND
	aClasseA[1] := aClasseA[3] / aClasseA[2]
	aClasseA[6] := aClasseA[6] + _cTrab->VLRFAT
	aClasseA[5] := aClasseA[5] + _cTrab->QTDEFAT
	aClasseA[4] := aClasseA[6] / aClasseA[5]
	aClasseA[7] := aClasseA[7] + _cTrab->DESCONTO
ENDIF

//Acumula TOTAL GERAL DA CLASSE C
IF SB1->B1_YCLASSE == "2"
	aClasseC[3] := aClasseC[3] + _cTrab->VLRVEND
	aClasseC[2] := aClasseC[2] + _cTrab->QTDEVEND
	aClasseC[1] := aClasseC[3] / aClasseC[2]
	aClasseC[6] := aClasseC[6] + _cTrab->VLRFAT
	aClasseC[5] := aClasseC[5] + _cTrab->QTDEFAT
	aClasseC[4] := aClasseC[6] / aClasseC[5]
	aClasseC[7] := aClasseC[7] + _cTrab->DESCONTO
ENDIF

//Acumula TOTAL GERAL DA CLASSE D
IF SB1->B1_YCLASSE >= "3"
	aClasseD[3] := aClasseD[3] + _cTrab->VLRVEND
	aClasseD[2] := aClasseD[2] + _cTrab->QTDEVEND
	aClasseD[1] := aClasseD[3] / aClasseD[2]
	aClasseD[6] := aClasseD[6] + _cTrab->VLRFAT
	aClasseD[5] := aClasseD[5] + _cTrab->QTDEFAT
	aClasseD[4] := aClasseD[6] / aClasseD[5]
	aClasseD[7] := aClasseD[7] + _cTrab->DESCONTO
ENDIF

//Acumula TOTAL GERAL FORMATO
aFormato[3] := aFormato[3] + _cTrab->VLRVEND
aFormato[2] := aFormato[2] + _cTrab->QTDEVEND
aFormato[1] := aFormato[3] / aFormato[2]
aFormato[6] := aFormato[6] + _cTrab->VLRFAT
aFormato[5] := aFormato[5] + _cTrab->QTDEFAT
aFormato[4] := aFormato[6] / aFormato[5]
aFormato[7] := aFormato[7] + _cTrab->DESCONTO

//Acumula TOTAL GERAL VENDEDOR
aTotGer[3] := aTotGer[3] + _cTrab->VLRVEND
aTotGer[2] := aTotGer[2] + _cTrab->QTDEVEND
aTotGer[1] := aTotGer[3] / aTotGer[2]
aTotGer[6] := aTotGer[6] + _cTrab->VLRFAT
aTotGer[5] := aTotGer[5] + _cTrab->QTDEFAT
aTotGer[4] := aTotGer[6] / aTotGer[5]
aTotGer[7] := aTotGer[7] + _cTrab->DESCONTO

//Acumula TOTAL GERAL GERAL
aTotGerG[3] := aTotGerG[3] + _cTrab->VLRVEND
aTotGerG[2] := aTotGerG[2] + _cTrab->QTDEVEND
aTotGerG[1] := aTotGerG[3] / aTotGer[2]
aTotGerG[6] := aTotGerG[6] + _cTrab->VLRFAT
aTotGerG[5] := aTotGerG[5] + _cTrab->QTDEFAT
aTotGerG[4] := aTotGerG[6] / aTotGer[5]
aTotGerG[7] := aTotGerG[7] + _cTrab->DESCONTO

RETURN( NIL )

Static FUNCTION fImpRes()

fImpFormat()

If li+3 >= 62
	Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
EndIf

li := li + 1

@ li,000 PSAY Replicate( "-", Limite )

//Quebra de Classe A
wIClasse := 'TOTAL CLASSE  "A"'                                 + Space(27)
wIClasse := wIClasse + Tran( aClasseA[1], "@E 999.99"         ) + Space(02)
wIClasse := wIClasse + Tran( aClasseA[2], "@E 99,999,999.99"  ) + Space(02)
wIClasse := wIClasse + Tran( aClasseA[3], "@E 99,999,999.99"  ) + Space(02)
wIClasse := wIClasse + Tran( aClasseA[4], "@E 999.99"         ) + Space(02)
wIClasse := wIClasse + Tran( aClasseA[5], "@E 99,999,999.99"  ) + Space(02)
wIClasse := wIClasse + Tran( aClasseA[6], "@E 99,999,999.99"  ) + Space(02)
wIClasse := wIClasse + Tran( aClasseA[7], "@E 9,999,999.99"   )

If li+3 >= 62
	Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
EndIf

li := li + 1

@ li,000 PSAY wIClasse

//Quebra de Classe C
wIClasse := 'TOTAL CLASSE  "C"'                                 + Space(27)
wIClasse := wIClasse + Tran( aClasseC[1], "@E 999.99"         ) + Space(02)
wIClasse := wIClasse + Tran( aClasseC[2], "@E 99,999,999.99"  ) + Space(02)
wIClasse := wIClasse + Tran( aClasseC[3], "@E 99,999,999.99"  ) + Space(02)
wIClasse := wIClasse + Tran( aClasseC[4], "@E 999.99"         ) + Space(02)
wIClasse := wIClasse + Tran( aClasseC[5], "@E 99,999,999.99"  ) + Space(02)
wIClasse := wIClasse + Tran( aClasseC[6], "@E 99,999,999.99"  ) + Space(02)
wIClasse := wIClasse + Tran( aClasseC[7], "@E 9,999,999.99"   )

If li+3 >= 62
	Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
EndIf

li := li + 1

@ li,000 PSAY wIClasse

//Quebra de Classe D
wIClasse := 'TOTAL CLASSE  "D"'                                 + SPACE(27)
wIClasse := wIClasse + Tran( aClasseD[1], "@E 999.99"         ) + Space(02)
wIClasse := wIClasse + Tran( aClasseD[2], "@E 99,999,999.99"  ) + Space(02)
wIClasse := wIClasse + Tran( aClasseD[3], "@E 99,999,999.99"  ) + Space(02)
wIClasse := wIClasse + Tran( aClasseD[4], "@E 999.99"         ) + Space(02)
wIClasse := wIClasse + Tran( aClasseD[5], "@E 99,999,999.99"  ) + Space(02)
wIClasse := wIClasse + Tran( aClasseD[6], "@E 99,999,999.99"  ) + Space(02)
wIClasse := wIClasse + Tran( aClasseD[7], "@E 9,999,999.99"   )

If li+3 >= 62
	Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
EndIf

li := li + 1

@ li,000 PSAY wIClasse

//TOTAL GERAL VENDEDOR
wITGeral := "TOT.GERAL VENDEDOR"                               + SPACE(26)
wITGeral := wITGeral + Tran( aTotGer[1], "@E 999.99"         ) + Space(02)
wITGeral := wITGeral + Tran( aTotGer[2], "@E 99,999,999.99"  ) + Space(02)
wITGeral := wITGeral + Tran( aTotGer[3], "@E 99,999,999.99"  ) + Space(02)
wITGeral := wITGeral + Tran( aTotGer[4], "@E 999.99"         ) + Space(02)
wITGeral := wITGeral + Tran( aTotGer[5], "@E 99,999,999.99"  ) + Space(02)
wITGeral := wITGeral + Tran( aTotGer[6], "@E 99,999,999.99"  ) + Space(02)
wITGeral := wITGeral + Tran( aTotGer[7], "@E 9,999,999.99"   )

If li+3 >= 62
	Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
EndIf

li := li + 1

@ li,000 PSAY wITGeral

li := li + 1

aClasse	 := {0,0,0,0,0,0,0}
aCores	 := {0,0,0,0,0,0,0}
aLinha	 := {0,0,0,0,0,0,0}
aClasseA := {0,0,0,0,0,0,0}
aClasseC := {0,0,0,0,0,0,0}
aClasseD := {0,0,0,0,0,0,0}
aTotGer	 := {0,0,0,0,0,0,0}

RETURN( NIL )

Static FUNCTION fImpGer()

If li+3 >= 62
	Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
EndIf

li := li + 1

@ li,000 PSAY Replicate( "-", Limite )

// CORRIGE TOTAL DO PRECO UNITARIO E TOTAL UNIT. FATUR.
aTotGerG[1] := aTotGerG[3] / aTotGerG[2]
aTotGerG[4] := aTotGerG[6] / aTotGerG[5]

//IMPRIME TOTAL GERAL GERAL
wITGeral := 'TOTAL GERAL      '                                 + Space(27)
wITGeral := wITGeral + Tran( aTotGerG[1], "@E 999.99"         ) + Space(02)
wITGeral := wITGeral + Tran( aTotGerG[2], "@E 99,999,999.99"  ) + Space(02)
wITGeral := wITGeral + Tran( aTotGerG[3], "@E 99,999,999.99"  ) + Space(02)
wITGeral := wITGeral + Tran( aTotGerG[4], "@E 999.99"         ) + Space(02)
wITGeral := wITGeral + Tran( aTotGerG[5], "@E 99,999,999.99"  ) + Space(02)
wITGeral := wITGeral + Tran( aTotGerG[6], "@E 99,999,999.99"  ) + Space(02)
wITGeral := wITGeral + Tran( aTotGerG[7], "@E 9,999,999.99"   )

If li+3 >= 62
	Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
EndIf

li := li + 1

@ li,000 PSAY wITGeral

RETURN ( NIL )

Static FUNCTION fImpProd()
            
//li := li + 1
//@ li,000 PSAY Replicate( "-", Limite )
//li := li + 1

Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
cPrdAnt := " "

DbSelectArea("_cTrb2")
While !Eof()

	If li >= 62
		Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
	EndIf
	
	IF _cTrb2->PRODUTO <> cPrdAnt
		DbSelectArea("_cTrb3")
		DbSeek(_cTrb2->PRODUTO)
		li := li + 1
		@ li,000 PSAY Replicate( "-", Limite )                    
		li := li + 1		
		wIForm := "FORMATO "+ _cTrb3->PRODUTO + SPACE(16)
		wIForm := wIForm + Tran( _cTrb3->PRUNIT	  , "@E 999.99"         ) + Space(02)
		wIForm := wIForm + Tran( _cTrb3->QTDEVEND , "@E 99,999,999.99"  ) + Space(02)
		wIForm := wIForm + Tran( _cTrb3->VLRVEND  , "@E 99,999,999.99"  ) + Space(02)
		wIForm := wIForm + Tran( _cTrb3->PRUNIFAT , "@E 999.99"         ) + Space(02)
		wIForm := wIForm + Tran( _cTrb3->QTDEFAT  , "@E 99,999,999.99"  ) + Space(02)
		wIForm := wIForm + Tran( _cTrb3->VLRFAT	  , "@E 99,999,999.99"  ) + Space(02)
		wIForm := wIForm + Tran( _cTrb3->DESCONTO , "@E 9,999,999.99"   )
		li := li + 1
		@ li,000 PSAY wIForm
	ENDIF
	
	DbSelectArea("ZZ8")
	DbSetOrder(1)
	DbSeek(xFilial("ZZ8")+_cTrb2->CLASSE)
	
	wIForm := "CLASSE "+ ZZ8->ZZ8_DESC + SPACE(27)
	wIForm := wIForm + Tran( _cTrb2->PRUNIT	  , "@E 999.99"         ) + Space(02)
	wIForm := wIForm + Tran( _cTrb2->QTDEVEND , "@E 99,999,999.99"  ) + Space(02)
	wIForm := wIForm + Tran( _cTrb2->VLRVEND  , "@E 99,999,999.99"  ) + Space(02)
	wIForm := wIForm + Tran( _cTrb2->PRUNIFAT , "@E 999.99"         ) + Space(02)
	wIForm := wIForm + Tran( _cTrb2->QTDEFAT  , "@E 99,999,999.99"  ) + Space(02)
	wIForm := wIForm + Tran( _cTrb2->VLRFAT	  , "@E 99,999,999.99"  ) + Space(02)
	wIForm := wIForm + Tran( _cTrb2->DESCONTO , "@E 9,999,999.99"   )
	li := li + 1
	@ li,000 PSAY wIForm

	cPrdAnt := _cTrb2->PRODUTO
	
	DbSelectArea("_cTrb2")
	DbSkip()
END

If li+3 >= 62
	Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
EndIf

li := li + 1

@ li,000 PSAY Replicate( "-", Limite )

// CORRIGE TOTAL DO PRECO UNITARIO E TOTAL UNIT. FATUR.
//aTotGerG[1] := aTotGerG[3] / aTotGerG[2]
//aTotGerG[4] := aTotGerG[6] / aTotGerG[5]

//IMPRIME TOTAL GERAL GERAL
wITForm  := 'TOTAL FORMATOS   '                                + Space(27)
wITForm  := wITForm + Tran( aFormato[1], "@E 999.99"         ) + Space(02)
wITForm  := wITForm + Tran( aFormato[2], "@E 99,999,999.99"  ) + Space(02)
wITForm  := wITForm + Tran( aFormato[3], "@E 99,999,999.99"  ) + Space(02)
wITForm  := wITForm + Tran( aFormato[4], "@E 999.99"         ) + Space(02)
wITForm  := wITForm + Tran( aFormato[5], "@E 99,999,999.99"  ) + Space(02)
wITForm  := wITForm + Tran( aFormato[6], "@E 99,999,999.99"  ) + Space(02)
wITForm  := wITForm + Tran( aFormato[7], "@E 9,999,999.99"   )

If li+3 >= 62
	Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
EndIf

li := li + 1

@ li,000 PSAY wITForm

RETURN ( NIL )

Static FUNCTION fGravaRes()

OLDAREA	 := ALIAS()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica Tabela U1                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("ZZ6")
DbSetOrder(1)
IF DbSeek(xFilial("ZZ6")+SB1->B1_YFORMAT)
	Cha_Pesq2 := ZZ6->ZZ6_DESC
ELSE
	Cha_Pesq2 := "OUTROS              "
ENDIF

DBSELECTAREA("_cTrb")
DBSETORDER(1)

Cha_Pesq1 := _cTrab->VENDEDOR

DbSelectArea("ZZ8")
DbSetOrder(1)
DbSeek(xFilial("ZZ8")+SB1->B1_YCLASSE)
Cha_Pesq3 := Cha_Pesq1 + ALLTRIM(Cha_Pesq2) + ALLTRIM(ZZ8->ZZ8_DESC)
Cha_Pesq4 := ALLTRIM(Cha_Pesq2) + ALLTRIM(ZZ8->ZZ8_DESC) 
Cha_Pesq5 := ALLTRIM(Cha_Pesq2) + SB1->B1_YCLASSE

RECLOCK( "_cTrb", ! DBSEEK( Cha_Pesq3, .F. ) )

_cTrb->PRODUTO	:= Cha_Pesq4
_cTrb->NOMEPROD	:= _ctrab->NOMEPROD
_cTrb->VENDEDOR	:= Cha_Pesq1
_cTrb->QTDEVEND	:= _cTrb->QTDEVEND + _cTrab->QTDEVEND
_cTrb->VLRVEND	:= _cTrb->VLRVEND  + _cTrab->VLRVEND
_cTrb->PRUNIT 	:= _cTrb->VLRVEND / _cTrb->QTDEVEND
_cTrb->QTDEFAT	:= _cTrb->QTDEFAT  + _cTrab->QTDEFAT
_cTrb->VLRFAT 	:= _cTrb->VLRFAT   + _cTrab->VLRFAT
_cTrb->PRUNIFAT	:= _cTrb->VLRFAT / _cTrb->QTDEFAT
_cTrb->UM		:= _ctrab->UM
_cTrb->DESCONTO	:= _cTrb->DESCONTO + _cTrab->DESCONTO

MSUNLOCK()

DbSelectArea("_cTrb2")
IF !DbSeek(Cha_Pesq2+SB1->B1_YCLASSE,.F.)
	RECLOCK("_cTrb2",.T.)
	_cTrb2->PRODUTO	 := Cha_Pesq2
	_cTrb2->CLASSE	 := SB1->B1_YCLASSE	
	_cTrb2->NOMEPROD := _ctrab->NOMEPROD
	_cTrb2->QTDEVEND := _cTrab->QTDEVEND
	_cTrb2->VLRVEND	 := _cTrab->VLRVEND
	_cTrb2->PRUNIT 	 := _cTrb2->VLRVEND/_cTrb2->QTDEVEND
	_cTrb2->QTDEFAT	 := _cTrb2->QTDEFAT + _cTrab->QTDEFAT
	_cTrb2->VLRFAT 	 := _cTrb2->VLRFAT  + _cTrab->VLRFAT
	_cTrb2->PRUNIFAT := _cTrb2->VLRFAT/_cTrb2->QTDEFAT
	_cTrb2->UM		 := _ctrab->UM
	_cTrb2->DESCONTO := _cTrb2->DESCONTO + _cTrab->DESCONTO
ELSE                     
	RECLOCK("_cTrb2",.F.)
	_cTrb2->QTDEVEND := _cTrb2->QTDEVEND + _cTrab->QTDEVEND
	_cTrb2->VLRVEND	 := _cTrb2->VLRVEND  + _cTrab->VLRVEND
	_cTrb2->PRUNIT 	 := _cTrb2->VLRVEND/_cTrb2->QTDEVEND
	_cTrb2->QTDEFAT	 := _cTrb2->QTDEFAT  + _cTrab->QTDEFAT
	_cTrb2->VLRFAT 	 := _cTrb2->VLRFAT   + _cTrab->VLRFAT
	_cTrb2->PRUNIFAT := _cTrb2->VLRFAT/_cTrb2->QTDEFAT
	_cTrb2->UM		 := _ctrab->UM
	_cTrb2->DESCONTO := _cTrb2->DESCONTO + _cTrab->DESCONTO
ENDIF

MSUNLOCK()

DbSelectArea("_cTrb3")
IF !DbSeek(Cha_Pesq2,.F.)
	RECLOCK("_cTrb3",.T.)
	_cTrb3->PRODUTO	 := Cha_Pesq2
	_cTrb3->NOMEPROD := _ctrab->NOMEPROD
	_cTrb3->QTDEVEND := _cTrab->QTDEVEND
	_cTrb3->VLRVEND	 := _cTrab->VLRVEND
	_cTrb3->PRUNIT 	 := _cTrb3->VLRVEND/_cTrb3->QTDEVEND
	_cTrb3->QTDEFAT	 := _cTrb3->QTDEFAT + _cTrab->QTDEFAT
	_cTrb3->VLRFAT 	 := _cTrb3->VLRFAT  + _cTrab->VLRFAT
	_cTrb3->PRUNIFAT := _cTrb3->VLRFAT/_cTrb3->QTDEFAT
	_cTrb3->UM		 := _ctrab->UM
	_cTrb3->DESCONTO := _cTrb3->DESCONTO + _cTrab->DESCONTO
ELSE                     
	RECLOCK("_cTrb3",.F.)
	_cTrb3->QTDEVEND := _cTrb3->QTDEVEND + _cTrab->QTDEVEND
	_cTrb3->VLRVEND	 := _cTrb3->VLRVEND  + _cTrab->VLRVEND
	_cTrb3->PRUNIT 	 := _cTrb3->VLRVEND/_cTrb3->QTDEVEND
	_cTrb3->QTDEFAT	 := _cTrb3->QTDEFAT  + _cTrab->QTDEFAT
	_cTrb3->VLRFAT 	 := _cTrb3->VLRFAT   + _cTrab->VLRFAT
	_cTrb3->PRUNIFAT := _cTrb3->VLRFAT/_cTrb3->QTDEFAT
	_cTrb3->UM		 := _ctrab->UM
	_cTrb3->DESCONTO := _cTrb3->DESCONTO + _cTrab->DESCONTO
ENDIF

MSUNLOCK()

DBSELECTAREA(OLDAREA)

RETURN( NIL )

Static FUNCTION fImpFormat()

DBSELECTAREA("_cTrb")
DBSEEK(wOldVend,.T.)

OLDFORMATO := ""
OLDCLASSE  := RIGHT(RTRIM(_cTrb->PRODUTO),1)
OLDPRODUTO := _cTrb->PRODUTO
nTCQTDV    := 0
nTCVLRV    := 0
nTCQTDF    := 0
nTCVLRF    := 0
nTCDESC    := 0

//MONTA REGUA
IncProc( _cTrab->( LastRec() ) )

@ li,000 PSAY "R E S U M O"

While !EOF() .AND. wOldVend == _cTrb->VENDEDOR
	
	IncProc()
	
	If li >= 62
		Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
	Endif
	
	IF RIGHT(RTRIM(_cTrb->PRODUTO),1) <> OLDCLASSE .OR. (( OLDFORMATO #LEFT(_cTrb->PRODUTO,7) ) .AND. OLDFORMATO <> "")
		/*
		wIDetalhe := "CLASSE " +RIGHT(RTRIM(_cTrb->PRODUTO),1) + SPACE(36)
		wIDetalhe := wIDetalhe + Tran( _cTrb->PRUNIT	, "@E 999.99"         ) + Space(02)
		wIDetalhe := wIDetalhe + Tran( _cTrb->QTDEVEND , "@E 99,999,999.99"  ) + Space(02)
		wIDetalhe := wIDetalhe + Tran( _cTrb->VLRVEND	, "@E 99,999,999.99"  ) + Space(02)
		wIDetalhe := wIDetalhe + Tran( _cTrb->PRUNIFAT , "@E 999.99"         ) + Space(02)
		wIDetalhe := wIDetalhe + Tran( _cTrb->QTDEFAT	, "@E 99,999,999.99"  ) + Space(02)
		wIDetalhe := wIDetalhe + Tran( _cTrb->VLRFAT	, "@E 99,999,999.99"  ) + Space(02)
		wIDetalhe := wIDetalhe + Tran( _cTrb->DESCONTO , "@E 9,999,999.99"   )
		li := li + 1
		@ li,000 PSAY wIDetalhe
		*/
		
		wIDetalhe := "CLASSE " +RIGHT(RTRIM(OLDPRODUTO),1) + SPACE(36)
		wIDetalhe := wIDetalhe + Tran( nTCVLRV / nTCQTDV, "@E 999.99") + Space(02)
		wIDetalhe := wIDetalhe + Tran( nTCQTDV, "@E 99,999,999.99"  )  + Space(02)
		wIDetalhe := wIDetalhe + Tran( nTCVLRV, "@E 99,999,999.99"  )  + Space(02)
		wIDetalhe := wIDetalhe + Tran( nTCVLRF / nTCQTDF, "@E 999.99") + Space(02)
		wIDetalhe := wIDetalhe + Tran( nTCQTDF, "@E 99,999,999.99"  )  + Space(02)
		wIDetalhe := wIDetalhe + Tran( nTCVLRF, "@E 99,999,999.99"  )  + Space(02)
		wIDetalhe := wIDetalhe + Tran( nTCDESC, "@E 9,999,999.99"   )
		li := li + 1
		@ li,000 PSAY wIDetalhe
		
		nTCQTDV  := 0
		nTCVLRV  := 0
		nTCQTDF  := 0
		nTCVLRF  := 0
		nTCDESC  := 0
	ENDIF
	
	IF ( OLDFORMATO #LEFT(_cTrb->PRODUTO,7) )
		li := li + 2
		@ li,000 PSAY "FORMATO " + LEFT(_cTrb->PRODUTO,7)
	ENDIF
	
	OLDFORMATO := LEFT(_cTrb->PRODUTO,7)
	OLDCLASSE  := RIGHT(RTRIM(_cTrb->PRODUTO),1)
	OLDPRODUTO := _cTrb->PRODUTO
	
	nTCQTDV  := nTCQTDV + _cTrb->QTDEVEND
	nTCVLRV  := nTCVLRV + _cTrb->VLRVEND
	nTCQTDF  := nTCQTDF + _cTrb->QTDEFAT
	nTCVLRF  := nTCVLRF + _cTrb->VLRFAT
	nTCDESC  := nTCDESC + _cTrb->DESCONTO
	
	DBSELECTAREA("_cTrb")
	DBSKIP()
	
EndDo

wIDetalhe := "CLASSE " +RIGHT(RTRIM(OLDPRODUTO),1) + SPACE(36)
wIDetalhe := wIDetalhe + Tran( nTCVLRV / nTCQTDV, "@E 999.99" ) + Space(02)
wIDetalhe := wIDetalhe + Tran( nTCQTDV, "@E 99,999,999.99"  )   + Space(02)
wIDetalhe := wIDetalhe + Tran( nTCVLRV, "@E 99,999,999.99"  )   + Space(02)
wIDetalhe := wIDetalhe + Tran( nTCVLRF / nTCQTDF, "@E 999.99" ) + Space(02)
wIDetalhe := wIDetalhe + Tran( nTCQTDF, "@E 99,999,999.99"  )   + Space(02)
wIDetalhe := wIDetalhe + Tran( nTCVLRF, "@E 99,999,999.99"  )   + Space(02)
wIDetalhe := wIDetalhe + Tran( nTCDESC, "@E 9,999,999.99"   )
li := li + 1
@ li,000 PSAY wIDetalhe

Return( NIL )

//----------------------------------------------------------------------------------
// Versão do relatório em TReport.
//----------------------------------------------------------------------------------
User Function BIA084TR()
Local oReport

oReport:= ReportDef()
oReport:PrintDialog()

Return
//----------------------------------------------------------------------------------
Static Function ReportDef()
Local cNomeRep		:= "BIA084TR" 
Local cTituloRep 	:= "RESUMO DE VENDAS POR VENDEDOR (EM METROS QUADRADOS)"
Local cDescRep		:= "Este programa tem como objetivo emitir um relatorio do Resumo de Vendas por Vendedor"
Local oBrNF
Local oBrCli 
Local oBrVend
Local Enter := chr(13) + Chr(10)

oReport:= TReport():New(cNomeRep,cTituloRep,cNomeRep, {|oReport| PrintReport(oReport)},cDescRep)
oReport:SetLandscape()
Pergunte(oReport:GetParam(),.F.)

oReport:SetTotalInLine(.F.)
oReport:lParamPage 		:=.F.
oReport:lPrtParamPage   :=.F.
oReport:lXlsParam		:=.F.

oSecCla := TRSection():New(oReport,OemToAnsi("Classe"),)
oSecCla:SetHeaderPage()

oSecFor := TRSection():New(oReport,OemToAnsi("Formato"),)    
oSecFor:SetTotalInLine(.F.)
oSecFor:SetLineStyle(.T.)

oSecRep := TRSection():New(oReport,OemToAnsi("Repres"),)    
oSecRep:SetTotalInLine(.F.)
oSecRep:SetLineStyle(.T.)

oSecTot := TRSection():New(oReport,OemToAnsi("Totais"),)

//cria as células do relatório...

TRCell():New(oSecRep,"A3_COD",,"REPRES.",,10,,,"LEFT",,"LEFT")
TRCell():New(oSecRep,"A3_NOME",,"NOME",,50,,,"LEFT",,"LEFT")

TRCell():New(oSecFor,"PRODUTO",,"FORMTATO",, 50,,,"LEFT",,"LEFT")

TRCell():New(oSecCla,"CLASSE",,Enter + "CÓDIGO",,10,,,"LEFT",,"LEFT")
TRCell():New(oSecCla,"CODCLAS",,Enter + "DESCRIÇÃO DO PRODUTO",,50,,,"LEFT",,"LEFT")
TRCell():New(oSecCla,"PRCUNIT",,"PREÇO" + Enter + "UNITÁRIO","@E 999,999,999.99",16,,,"RIGHT",,"RIGHT")
TRCell():New(oSecCla,"QTDPED",,"QTD. TOTAL" + Enter + "DOS PEDIDOS","@E 999,999,999.99",16,,,"RIGHT",,"RIGHT")
TRCell():New(oSecCla,"VLRPED",,"VLR. TOTAL" + Enter + "DOS PEDIDOS","@E 999,999,999.99",16,,,"RIGHT",,"RIGHT")
TRCell():New(oSecCla,"UNIFAT",,"UNIT." + Enter + "FATUR.","@E 999,999,999.99",16,,,"RIGHT",,"RIGHT")
TRCell():New(oSecCla,"QTDFAT",,"QUANTIDADE" + Enter + "FATURADA","@E 999,999,999.99",16,,,"RIGHT",,"RIGHT")
TRCell():New(oSecCla,"VLRFAT",,"VALOR" + Enter + "FATURADA","@E 999,999,999.99",16,,,"RIGHT",,"RIGHT")
TRCell():New(oSecCla,"DESCON",,"DESCONTO" + Enter + "CONCEDIDO","@E 999,999,999.99",16,,,"RIGHT",,"RIGHT")

TRCell():New(oSecTot,"CLASSE",,"",,10,,,"LEFT",,"LEFT")
TRCell():New(oSecTot,"CODCLAS",,"",,50,,,"LEFT",,"LEFT")
TRCell():New(oSecTot,"PRCUNIT",,"","@E 999,999,999.99",16,,,"RIGHT",,"RIGHT")
TRCell():New(oSecTot,"QTDPED",,"","@E 999,999,999.99",16,,,"RIGHT",,"RIGHT")
TRCell():New(oSecTot,"VLRPED",,"","@E 999,999,999.99",16,,,"RIGHT",,"RIGHT")
TRCell():New(oSecTot,"UNIFAT",,"","@E 999,999,999.99",16,,,"RIGHT",,"RIGHT")
TRCell():New(oSecTot,"QTDFAT",,"","@E 999,999,999.99",16,,,"RIGHT",,"RIGHT")
TRCell():New(oSecTot,"VLRFAT",,"","@E 999,999,999.99",16,,,"RIGHT",,"RIGHT")
TRCell():New(oSecTot,"DESCON",,"","@E 999,999,999.99",16,,,"RIGHT",,"RIGHT")

Return oReport


//----------------------------------------------------------------------------------
Static Function PrintReport(oReport)

Local oSecCla := oReport:Section(1) //Classe
Local oSecFor := oReport:Section(2) //Formato
Local oSecRep := oReport:Section(3) //Representante
Local cCliRep	:= ''
Local cVendRep  := ''
Local cNf 		:= ''
Local cPedido 	:= ''
Local wTransp 	:= ''
	

dbSelectArea("_cTrab")
dbGoTop()

//Monta regua
IncProc( _cTrab->( LastRec() ) )

DbSelectArea("SB1")
DbSetOrder(1)
DbSeek(xFilial("SB1")+_cTrab->PRODUTO)
//Inicializa variaveis normais e de quebra

wOldClas  := SB1->B1_YCLASSE
wOldVend  := _cTrab->VENDEDOR
wOldCor	  := SUBSTR(SB1->B1_YLINHA,4,1)
wOldLine  := SUBSTR(SB1->B1_YLINHA,1,3)
wOldNome  := _cTrab->NOMEPROD
wOldProd  := _cTrab->PRODUTO
aClasse	  := {0,0,0,0,0,0,0}
aCores	  := {0,0,0,0,0,0,0}
aLinha	  := {0,0,0,0,0,0,0}
aClasseA  := {0,0,0,0,0,0,0}
aClasseC  := {0,0,0,0,0,0,0}
aClasseD  := {0,0,0,0,0,0,0}
aTotGer	  := {0,0,0,0,0,0,0}
aTotGerG  := {0,0,0,0,0,0,0}
aFormato  := {0,0,0,0,0,0,0}
wPrimVez  := .T.

//Processa arquivo de trabalho

While ! EOF()
	
	//Incrementa regua
	IncProc()
	
	If Empty(_cTrab->VENDEDOR)
		DbSkip()
		Loop
	EndIf
	
	// IMPRIME O NOME DA LINHA SE E A PRIMEIRA VEZ QUE PASSA POR AQUI
	If wPrimVez
		
		DbSelectArea("SA3")
		DbSeek(xFilial("SA3")+wOldVend,.T.)
		wNomeVend := SA3->A3_NOME
		
		//oSecRep:SetHeaderSection(.T.)
		oSecRep:Init()
		oSecRep:Cell("A3_COD"):SetValue(Alltrim(SA3->A3_COD))
		oSecRep:Cell("A3_NOME"):SetValue(Alltrim(wNomeVend))
		oSecRep:PrintLine()
		
		dbSelectArea("_cTrab")
		
		wPrimVez   := .F.
		
	EndIf
	
	//Quebra de Vendedor 
	//# é a mesma coisa de diferente. Pode ser usado != ou <> também
	If _cTrab->VENDEDOR #wOldVend
		//classe aqui!
		fClasse(oReport)
		
		wOldVend := _cTrab->VENDEDOR
		DbSelectArea("SA3")
		DbSeek(xFilial("SA3")+wOldVend,.T.)
		wNomeVend := SA3->A3_NOME
		 
		oSecCla:Finish()
		oSecFor:Finish()	
		oSecRep:Finish()
		
		//oSecRep:SetHeaderSection(.T.)
		oSecRep:Init()
		oSecRep:Cell("A3_COD"):SetValue(Alltrim(SA3->A3_COD))
		oSecRep:Cell("A3_NOME"):SetValue(Alltrim(wNomeVend))
		oSecRep:PrintLine()
		
		dbSelectArea("_cTrab")
	EndIf
	
	fAcumula()
	
	fGravaRes()
	
	dbSelectArea("_cTrab")
	dbSkip()
	
EndDo	

fClasse(oReport)
fTotFor(oReport)
fTotGer(oReport)

Return 

Static Function fClasse(oReport)

	Local oSecTot := oReport:Section(4)
	
	fClasDet(oReport)
		
	oSecTot:Init()
	oSecTot:Cell("CLASSE"):SetValue("TOTAL")	
	oSecTot:Cell("CODCLAS"):SetValue('CLASSE "A"')
	oSecTot:Cell("PRCUNIT"):SetValue(aClasseA[1])
	oSecTot:Cell("QTDPED"):SetValue(aClasseA[2])
	oSecTot:Cell("VLRPED"):SetValue(aClasseA[3])
	oSecTot:Cell("UNIFAT"):SetValue(aClasseA[4])
	oSecTot:Cell("QTDFAT"):SetValue(aClasseA[5])
	oSecTot:Cell("VLRFAT"):SetValue(aClasseA[6])
	oSecTot:Cell("DESCON"):SetValue(aClasseA[7])
	
	oSecTot:PrintLine()
	
	oSecTot:Init()
	oSecTot:Cell("CLASSE"):SetValue("TOTAL")	
	oSecTot:Cell("CODCLAS"):SetValue('CLASSE "C"')
	oSecTot:Cell("PRCUNIT"):SetValue(aClasseC[1])
	oSecTot:Cell("QTDPED"):SetValue(aClasseC[2])
	oSecTot:Cell("VLRPED"):SetValue(aClasseC[3])
	oSecTot:Cell("UNIFAT"):SetValue(aClasseC[4])
	oSecTot:Cell("QTDFAT"):SetValue(aClasseC[5])
	oSecTot:Cell("VLRFAT"):SetValue(aClasseC[6])
	oSecTot:Cell("DESCON"):SetValue(aClasseC[7])
	
	oSecTot:PrintLine()
		
	oSecTot:Init()
	oSecTot:Cell("CLASSE"):SetValue("TOTAL")	
	oSecTot:Cell("CODCLAS"):SetValue('CLASSE "D"')
	oSecTot:Cell("PRCUNIT"):SetValue(aClasseD[1])
	oSecTot:Cell("QTDPED"):SetValue(aClasseD[2])
	oSecTot:Cell("VLRPED"):SetValue(aClasseD[3])
	oSecTot:Cell("UNIFAT"):SetValue(aClasseD[4])
	oSecTot:Cell("QTDFAT"):SetValue(aClasseD[5])
	oSecTot:Cell("VLRFAT"):SetValue(aClasseD[6])
	oSecTot:Cell("DESCON"):SetValue(aClasseD[7])
	
	oSecTot:PrintLine()
		
	oSecTot:Init()
	oSecTot:Cell("CLASSE"):SetValue("TOTAL")	
	oSecTot:Cell("CODCLAS"):SetValue('GERAL VENDEDOR')
	oSecTot:Cell("PRCUNIT"):SetValue(aTotGer[1])
	oSecTot:Cell("QTDPED"):SetValue(aTotGer[2])
	oSecTot:Cell("VLRPED"):SetValue(aTotGer[3])
	oSecTot:Cell("UNIFAT"):SetValue(aTotGer[4])
	oSecTot:Cell("QTDFAT"):SetValue(aTotGer[5])
	oSecTot:Cell("VLRFAT"):SetValue(aTotGer[6])
	oSecTot:Cell("DESCON"):SetValue(aTotGer[7])
	
	oSecTot:PrintLine()
	oSecTot:Finish()
	
	oReport:SkipLine(2)
	oReport:FatLine()
	
	aClasse	 := {0,0,0,0,0,0,0}
	aCores	 := {0,0,0,0,0,0,0}
	aLinha	 := {0,0,0,0,0,0,0}
	aClasseA := {0,0,0,0,0,0,0}
	aClasseC := {0,0,0,0,0,0,0}
	aClasseD := {0,0,0,0,0,0,0}
	aTotGer	 := {0,0,0,0,0,0,0}
	
RETURN( NIL )

Static Function fClasDet(oReport)

	Local oSecCla := oReport:Section(1) //Classe
	Local oSecFor := oReport:Section(2) //Formato

	DBSELECTAREA("_cTrb")
	DBSEEK(wOldVend,.T.)
	
	OLDFORMATO := ""
	OLDCLASSE  := RIGHT(RTRIM(_cTrb->PRODUTO),1)
	OLDPRODUTO := _cTrb->PRODUTO
	nTCQTDV    := 0
	nTCVLRV    := 0
	nTCQTDF    := 0
	nTCVLRF    := 0
	nTCDESC    := 0
	
	//MONTA REGUA
	IncProc( _cTrab->( LastRec() ) )
	
	oReport:SkipLine(1)
	linha := oReport:Row()
	oReport:PrintText('R E S U M O',linha,10)
	oReport:SkipLine(1)
			
	
	While !EOF() .AND. wOldVend == _cTrb->VENDEDOR
		
		IncProc()
		
		IF RIGHT(RTRIM(_cTrb->PRODUTO),1) <> OLDCLASSE .OR. (( OLDFORMATO #LEFT(_cTrb->PRODUTO,7) ) .AND. OLDFORMATO <> "")
			oSecCla:Init()
			oSecCla:Cell("CLASSE"):SetValue("CLASSE " + RIGHT(RTRIM(OLDPRODUTO),1))	
			oSecCla:Cell("CODCLAS"):SetValue("")
			oSecCla:Cell("PRCUNIT"):SetValue(nTCVLRV / nTCQTDV)
			oSecCla:Cell("QTDPED"):SetValue(nTCQTDV)
			oSecCla:Cell("VLRPED"):SetValue(nTCVLRV)
			oSecCla:Cell("UNIFAT"):SetValue(nTCVLRF / nTCQTDF)
			oSecCla:Cell("QTDFAT"):SetValue(nTCQTDF)
			oSecCla:Cell("VLRFAT"):SetValue(nTCVLRF)
			oSecCla:Cell("DESCON"):SetValue(nTCDESC)
			
			oSecCla:PrintLine()
			
			nTCQTDV  := 0
			nTCVLRV  := 0
			nTCQTDF  := 0
			nTCVLRF  := 0
			nTCDESC  := 0
		ENDIF
		
		IF ( OLDFORMATO #LEFT(_cTrb->PRODUTO,7) )		
			oReport:SkipLine(1) 
			oReport:FatLine()

			oSecFor:Init()
			oSecFor:Cell("PRODUTO"):SetValue(LEFT(_cTrb->PRODUTO,7))
			oSecFor:PrintLine()
		ENDIF
		
		OLDFORMATO := LEFT(_cTrb->PRODUTO,7)
		OLDCLASSE  := RIGHT(RTRIM(_cTrb->PRODUTO),1)
		OLDPRODUTO := _cTrb->PRODUTO
		
		nTCQTDV  := nTCQTDV + _cTrb->QTDEVEND
		nTCVLRV  := nTCVLRV + _cTrb->VLRVEND
		nTCQTDF  := nTCQTDF + _cTrb->QTDEFAT
		nTCVLRF  := nTCVLRF + _cTrb->VLRFAT
		nTCDESC  := nTCDESC + _cTrb->DESCONTO
		
		DBSELECTAREA("_cTrb")
		DBSKIP()
		
	EndDo
	
	oSecCla:Init()
	oSecCla:Cell("CLASSE"):SetValue("CLASSE " + RIGHT(RTRIM(OLDPRODUTO),1))	
	oSecCla:Cell("CODCLAS"):SetValue("")
	oSecCla:Cell("PRCUNIT"):SetValue(nTCVLRV / nTCQTDV)
	oSecCla:Cell("QTDPED"):SetValue(nTCQTDV)
	oSecCla:Cell("VLRPED"):SetValue(nTCVLRV)
	oSecCla:Cell("UNIFAT"):SetValue(nTCVLRF / nTCQTDF)
	oSecCla:Cell("QTDFAT"):SetValue(nTCQTDF)
	oSecCla:Cell("VLRFAT"):SetValue(nTCVLRF)
	oSecCla:Cell("DESCON"):SetValue(nTCDESC)
	
	oSecCla:PrintLine()
Return ()

Static Function fTotFor(oReport)

	Local oSecTot := oReport:Section(4) //Classe
            
	cPrdAnt := " " 
	
	DbSelectArea("_cTrb2")
			
	oSecTot:Init()
			
	While !Eof()
		
		IF _cTrb2->PRODUTO <> cPrdAnt
			DbSelectArea("_cTrb3")
			DbSeek(_cTrb2->PRODUTO)
			
			oReport:SkipLine(1)
			
			oSecTot:Cell("CLASSE"):SetValue("FORMATO")	
			oSecTot:Cell("CODCLAS"):SetValue(_cTrb3->PRODUTO)
			oSecTot:Cell("PRCUNIT"):SetValue(_cTrb3->PRUNIT)
			oSecTot:Cell("QTDPED"):SetValue(_cTrb3->QTDEVEND)
			oSecTot:Cell("VLRPED"):SetValue(_cTrb3->VLRVEND)
			oSecTot:Cell("UNIFAT"):SetValue(_cTrb3->PRUNIFAT)
			oSecTot:Cell("QTDFAT"):SetValue(_cTrb3->QTDEFAT)
			oSecTot:Cell("VLRFAT"):SetValue(_cTrb3->VLRFAT)
			oSecTot:Cell("DESCON"):SetValue(_cTrb3->DESCONTO)
			
			oSecTot:PrintLine()
		ENDIF
		
		DbSelectArea("ZZ8")
		DbSetOrder(1)
		DbSeek(xFilial("ZZ8")+_cTrb2->CLASSE)
		
		oSecTot:Cell("CLASSE"):SetValue("CLASSE")	
		oSecTot:Cell("CODCLAS"):SetValue(ZZ8->ZZ8_DESC)
		oSecTot:Cell("PRCUNIT"):SetValue(_cTrb2->PRUNIT)
		oSecTot:Cell("QTDPED"):SetValue(_cTrb2->QTDEVEND)
		oSecTot:Cell("VLRPED"):SetValue(_cTrb2->VLRVEND)
		oSecTot:Cell("UNIFAT"):SetValue(_cTrb2->PRUNIFAT)
		oSecTot:Cell("QTDFAT"):SetValue(_cTrb2->QTDEFAT)
		oSecTot:Cell("VLRFAT"):SetValue(_cTrb2->VLRFAT)
		oSecTot:Cell("DESCON"):SetValue(_cTrb2->DESCONTO)
		
		oSecTot:PrintLine()
		
	    	
		cPrdAnt := _cTrb2->PRODUTO
		
		DbSelectArea("_cTrb2")
		DbSkip()
	END 
	
	//oSecTot:Finish()
	
	oReport:SkipLine(1)
	oReport:FatLine()
	
	oSecTot:Cell("CLASSE"):SetValue("TOTAL")	
	oSecTot:Cell("CODCLAS"):SetValue("FORMATOS")
	oSecTot:Cell("PRCUNIT"):SetValue(aFormato[1])
	oSecTot:Cell("QTDPED"):SetValue(aFormato[2])
	oSecTot:Cell("VLRPED"):SetValue(aFormato[3])
	oSecTot:Cell("UNIFAT"):SetValue(aFormato[4])
	oSecTot:Cell("QTDFAT"):SetValue(aFormato[5])
	oSecTot:Cell("VLRFAT"):SetValue(aFormato[6])
	oSecTot:Cell("DESCON"):SetValue(aFormato[7])
	
	oSecTot:PrintLine()
	//oSecTot:Finish()

RETURN ( NIL )

Static FUNCTION fTotGer(oReport)

	Local oSecTot := oReport:Section(4)
    
	// CORRIGE TOTAL DO PRECO UNITARIO E TOTAL UNIT. FATUR.
	aTotGerG[1] := aTotGerG[3] / aTotGerG[2]
	aTotGerG[4] := aTotGerG[6] / aTotGerG[5]
			
	oSecTot:Init()
	
	oSecTot:Cell("CLASSE"):SetValue("TOTAL")	
	oSecTot:Cell("CODCLAS"):SetValue("GERAL")
	oSecTot:Cell("PRCUNIT"):SetValue(aTotGerG[1])
	oSecTot:Cell("QTDPED"):SetValue(aTotGerG[2])
	oSecTot:Cell("VLRPED"):SetValue(aTotGerG[3])
	oSecTot:Cell("UNIFAT"):SetValue(aTotGerG[4])
	oSecTot:Cell("QTDFAT"):SetValue(aTotGerG[5])
	oSecTot:Cell("VLRFAT"):SetValue(aTotGerG[6])
	oSecTot:Cell("DESCON"):SetValue(aTotGerG[7])
	
	oSecTot:PrintLine()
	oSecTot:Finish()

RETURN ( NIL )

