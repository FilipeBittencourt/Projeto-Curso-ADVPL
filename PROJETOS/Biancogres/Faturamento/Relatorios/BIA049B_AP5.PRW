#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01
#include "relato.ch"

User Function Bia049b()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("CTAMANHO,CTITULO,CDESC1,CDESC2,CDESC3,ARETURN")
SetPrvt("ALINHA,CNOMEPROG,CCBTXT,NCBCONT,CALIAS,M_PAG")
SetPrvt("AORD,CCABEC1,CCABEC2,ACAMPOS,CARQTEMP,CCHAVE")
SetPrvt("CTIPO,CTRANSP,CPRODUTO,DCHEGADA,CCTRC,CNUMSEQ")
SetPrvt("DDTDIGIT,NPRCTF,CDOC,CFOR,DVENCTO,NTOTNF")
SetPrvt("NUMIDADE,NTICKET,CFORNEC,NPRCUMP,NPRCTMP,NPRCUFRET")
SetPrvt("NPESONF,CPREFIXO,CPEDIDO,CITEMPC,NUMID_F,NTOTUMID_T")
SetPrvt("NTOTGUMID,NTOTDIF_F,NTOTDIF_T,NTOTGDIF,NTOTMP_F,NTOTMP_T")
SetPrvt("NTOTGMP,NTFF,NTFT,NTGF,NTOTNF_F,NTOTNF_T")
SetPrvt("NTOTGNF,NTOTFTICKET,NTOTTTICKET,NTOTGTICKET,NTOTPTMP_F,NTOTPTMP_T")
SetPrvt("NTOTGPTMP,NTOTPTF_F,NTOTPTF_T,NTOTGTF,NPRZMF,NPRZMT")
SetPrvt("NPRZMG,LOK,NDIF,NMP,NFRT,NL")
SetPrvt("NUMIDAD,_CDOC,_CPREFIXO,_CDESCRICAO,_CCHEGADA,_CVENCTO")
SetPrvt("_CCTRC,_CUMIDADE,_CPESONF,_CTICKET,NPRZ,_CDIF")
SetPrvt("_CPRCUMP,_CPRCUFRET,_CPRCTMP,_CPRCTF,_CMP,_CFRT")
SetPrvt("_CPRZ,_CPEDIDO,_CITEMPC,CLINHA,_CTOTUMDMED,_CTOTNF_F")
SetPrvt("_CTOTFTICKET,_NTOTDIF_F,_NTOTPTMP_F,_NTOTPTF_F,_NTOTMP_F,_NTFF")
SetPrvt("_TOTPRZMED,_CTOTUMID_T,_CTOTNF_T,_CTOTTTICKET,_CTOTDIF_T,_CTOTPTMP_T")
SetPrvt("_CTOTPTF_T,_CTOTMP_T,_CTFT,_CPRZMT,_CTOTGUMID,_CTOTGNF")
SetPrvt("_CTOTGTICKET,_CTOTGDIF,_CTOTGPTMP,_CTOTGTF,_CTOTGMP,_CTGF")

/*/
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇙o	 � BIA049b	  � Autor � WLADIMIR ILLIUSHENKO  � Data � 20/11/00 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇙o � RELATORIO DE CONTROLE DE CHEGADA DE MATERIA-PRIMA			낢�
굇�			 � Utilizado pelo Custo.										낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso		 � SIGACOM														낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/

cTamanho 	:= "M"
cTitulo		:= "Planilha de Controle Materia-Prima (resumido)                           "
cDesc1		:= "Emite o controle de chegada de materia-prima (resumido).                "
cDesc2		:= "                                                                        "
cDesc3		:= "                                                                        "
aReturn		:= { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
aLinha		:= { }
cNomeProg	:= "BIA049B"

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Variaveis utilizadas para Impressao do Cabecalho e Rodape	 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
cCbTxt	:= SPACE(10)
nCbCont	:= 0
cAlias	:= "SD1"
m_pag 	:= 1
aOrd	:= {" Por Transportadora+Fornecedor+Produto"}
cCabec1	:= "NOTA   PRF MATERIA-PRIMA         CHEGADA    CTRC      PESO DA       TICKET    DIFERENCA     UMID"
cCabec2	:= "FISCAL                                               NF (TON)        (TON)        (TON)    MEDIA"
//XXXXXX-XXX XXXXXXXXXXXXXXXXX  XX/XX/XXXX  XXXXXX	XXX.XXX,XXX  XXX.XXX,XXX  XXX.XXX,XXX

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Envia controle para a funcao SETPRINT.									 �
//� Verifica Posicao do Formulario na Impressora.							 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
cNomeProg := SetPrint(cAlias,cNomeProg,SubStr(cNomeProg,1,6),@cTitulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,cTamanho)
if LastKey() == 27 .Or. nLastKey == 27
	Return
endif

SetDefault(aReturn,cAlias)
if LastKey() == 27 .Or. nLastKey == 27
	Return
endif

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Solicita os parametros para a emissao do relatorio					   �
//쳐컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
//� mv_par01 � De  Transportadora										   �
//� mv_par02 � Da  Data Chegada											   �
//� mv_par03 � Ate Data Chegada											   �
//읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Pergunte(SubStr(cNomeProg,1,6),.F.)
if LastKey() == 27 .Or. nLastKey == 27
	Return
endif

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Rotinas a serem executadas.									 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Processa({|| fCriaTemp() })// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> 	Processa({|| Execute(fCriaTemp) })
Processa({|| fAcumula()  })// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> 	Processa({|| Execute(fAcumula)  })
Processa({|| fImprime()  })// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> 	Processa({|| Execute(fImprime)  })
Processa({|| fApagaTemp()})// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> 	Processa({|| Execute(fApagaTemp)})

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Libera impressao.														 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
if aReturn[5] == 1
	set printer to
	OurSpool(cNomeProg)
endif
Return


/*/
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴엽�
굇쿑uncao	 � fCriaTemp� Autor � WLADIMIR ILLIUSHENKO					  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿏escricao � Cria, abre e indexa uma tabela temporaria.				  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so		 � SIGACOM													  낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fCriaTemp
Static FUNCTION fCriaTemp()
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Definicao do arquivo de trabalho para totalizar por conta contabil	   �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
aCampos := {}
AAdd(aCampos,{"TRANSP" ,  "C", 06, 0})
AAdd(aCampos,{"FORNEC" ,  "C", 06, 0})
AAdd(aCampos,{"PRODUTO",  "C", 15, 0})
AAdd(aCampos,{"CHEGADA",  "D", 08, 0})
AAdd(aCampos,{"DOC"    ,  "C", 09, 0})
AAdd(aCampos,{"PREFIXO",  "C", 03, 0})
AAdd(aCampos,{"CTRC"   ,  "C", 06, 0})
AAdd(aCampos,{"UMIDADE",  "N", 06, 2})
AAdd(aCampos,{"VENCTO" ,  "D", 08, 0})
AAdd(aCampos,{"PRCTMP" ,  "N", 14, 2})
AAdd(aCampos,{"PRCTF"  ,  "N", 14, 2})
AAdd(aCampos,{"PESONF" ,  "N", 09, 3})
AAdd(aCampos,{"TICKET" ,  "N", 09, 3})
AAdd(aCampos,{"PRCUMP"  , "N", 08, 2})
AAdd(aCampos,{"PEDIDO" ,  "C", 06, 0})
AAdd(aCampos,{"ITEMPC"  , "C", 02, 0})
AAdd(aCampos,{"PRCUFRET", "N", 08, 2})

cArqTemp := CriaTrab(aCampos, .T.)
DbUseArea(.T.,,cArqTemp,"TMP")
DbCreateInd(cArqTemp+".001","TRANSP+FORNEC+PRODUTO",{||TRANSP+FORNEC+PRODUTO})
OrdListClear()
OrdListAdd(cArqTemp+".001")
Return


/*/
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴엽�
굇쿑uncao	 � fAcumula   � Autor � WLADIMIR ILLIUSHENKO 				  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿏escricao � Pesquisa a Base de Dados do Siga em busca de falha de ...  낢�
굇�			 � integridade e inconcistencia e tenta reparalos. 			  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so		 � SIGACOM													  낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Static FUNCTION fAcumula()
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Seleciona a tabela SD1.												   �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
DbSelectArea("SD1")
DbSetOrder(6)
DbGoTop()
ProcRegua(SD1->(LastRec()))
DbSeek(xFilial("SD1")+dtos(MV_PAR02),.T.)

do while !SD1->(EOF()) .AND. (SD1->D1_DTDIGIT <= MV_PAR03)
	
	IncProc("Processando ...")
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Verifica se o fornecedor e igual ao informado no parametro.	   �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	if SD1->D1_FORNECE <> MV_PAR01
		SD1->(DbSkip())
		Loop
	endif
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Verifica se o tipo do item e igual a "C".                      �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	if SD1->D1_TIPO <> "C"
		SD1->(DbSkip())
		Loop
	endif
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//�																   �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	if SD1->D1_NFORI $ "DIVERS,COMPL ,AMOSTR"
		SD1->(DbSkip())
		Loop
	endif
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//�																   �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	cChave := xFilial("SB1")+SD1->D1_COD
	DbSelectArea("SB1")
	if !DbSeek(cChave,.F.)
		SD1->(DbSkip())
		Loop
	else
		cTipo := SB1->B1_TIPO
	endif
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//�																   �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	if SubStr(SB1->B1_COD,1,3) <> "101"
		SD1->(DbSkip())
		Loop
	endif
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//�																   �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	if cTipo <> "MP"
		SD1->(DbSkip())
		Loop
	endif
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Monta Registro do Conhecimento de Frete da Mat.Prima 		   �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	cTransp	 := SD1->D1_FORNECE
	cProduto := SD1->D1_COD
	dChegada := SD1->D1_DTDIGIT
	cCtrc 	 := SD1->D1_DOC
	cNumSeq	 := SD1->D1_NUMSEQ
	dDtDigit := SD1->D1_DTDIGIT
	nPrcTF	 := SD1->D1_TOTAL - SD1->D1_VALDESC
	cDoc	 := SD1->D1_NFORI
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Procura Registro da NF-Mat.Prima do Conhecimento de Frete	   �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	DbSelectArea("SD1")
	DbSetOrder(1)
	DbSeek(xFilial("SD1")+SD1->D1_NFORI+SD1->D1_SERIORI, .F.)
	do while (SD1->D1_DOC == cDoc) .AND. !SD1->(EOF())
        if SD1->D1_DTDIGIT < mv_par02 .OR. SD1->D1_DTDIGIT > mv_par03
           dbSkip()
           Loop
    	endif
		if SD1->D1_COD <> cProduto
			SD1->(DbSkip())
			Loop
		endiF
		cDoc := "999999999"
	enddo
	
	cDoc := SD1->D1_DOC
	cFor := SD1->D1_FORNECE
	cSer := SD1->D1_SERIE
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Procura Registro do Titulo a Pagar para verificar vencto	   �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	DbSelectArea("SE2")
	DbSetOrder(1)
	DbSeek(xFilial("SE2")+SD1->D1_SERIE+SD1->D1_DOC,.T.)
	dVencto := SE2->E2_VENCREA
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Procura Valor Total da NF-Entrada							   �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	DbSelectArea("SF1")
	DbSetOrder(1)
	DbSeek(xFilial("SF1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE,.T.)
	nTotNF := SF1->F1_VALMERC
	
	DbSelectArea("SD1")
	do while (SD1->D1_DOC == cDoc) .AND. (SD1->D1_FORNECE == cFor) .AND. (SD1->D1_SERIE == cSer) .AND. !SD1->(EOF())
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//� Monta Registro da NF-Entrada da Mat.Prima				       �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		nUmidade   := SD1->D1_YUMID
		nTicket	   := SD1->D1_YTICKET
		cFornec	   := SD1->D1_FORNECE
		nPrcuMp	   := SD1->D1_VUNIT
		nPrcTMp	   := SD1->D1_TOTAL
		nPrcTF	   := ((nPrcTF / nTotNF) * SD1->D1_TOTAL)
		nPrcUFret  := (nPrcTF / SD1->D1_QUANT)
		nPesoNf	   := SD1->D1_QUANT
		cDoc	   := SD1->D1_DOC
		cPrefixo   := SD1->D1_SERIE
		cPedido	   := SD1->D1_PEDIDO
		cItemPc	   := SD1->D1_ITEMPC
	
		
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//� Grava Registro do Arquivo de Trabalho 						   �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		DbSelectArea("TMP")
		RecLock("TMP",.T.)
		TMP->TRANSP   := cTransp
		TMP->FORNEC   := cFornec
		TMP->PRODUTO  := cProduto
		TMP->CHEGADA  := dChegada
		TMP->CTRC	  := cCtrc
		TMP->DOC 	  := cDoc
		TMP->UMIDADE  := nUmidade
		TMP->PESONF   := nPesoNf
		TMP->TICKET   := nTicket
		TMP->PRCUMP   := nPrcUMp
		TMP->PRCUFRET := nPrcUFret
		TMP->PREFIXO  := cPrefixo
		TMP->PRCTMP   := nPrcTMp
		TMP->PRCTF	  := nPrcTF
		TMP->VENCTO   := dVencto
		TMP->PEDIDO   := cPedido
		TMP->ITEMPC   := cItemPc
		MsUnLock()
		DbSelectArea("SD1")
		DbSkip()
	enddo
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Volta ao Registro do Conhecimento de Frete Original			   �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	DbSelectArea("SD1")
	DbSetOrder(6)
	DbSeek(xFilial("SD1")+DTOS(dDtDigit)+cNumSeq,.T.)
	DbSkip()
enddo
Return

/*/
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컫컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴엽�
굇쿑uncao	 � fImprime  � Autor � WLADIMIR ILLIUSHENKO					  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컨컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿏escricao � Imprime os dados da tabela temporaria. 					  낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fImprime
Static FUNCTION fImprime()
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Inicializacao das variaveis de trabalho. 						         �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
nUmid_F		:= 0
nTotUmid_T	:= 0
nTotGUmid	:= 0
nTotDif_F	:= 0
nTotDif_T	:= 0
nTotGDif 	:= 0
nTotMp_F 	:= 0
nTotMp_T 	:= 0
nTotGMp		:= 0
nTFF			:= 0
nTFT			:= 0
nTGF			:= 0
nTotNf_F 	:= 0
nTotNf_T 	:= 0
nTotGNf		:= 0
nTotFTicket := 0
nTotTTicket := 0
nTotGTicket := 0
nTotPTMP_F	:= 0
nTotPTMP_T	:= 0
nTotGPTMP	:= 0
nTotPTF_F	:= 0
nTotPTF_T	:= 0
nTotGTF		:= 0
nPrzMF		:= 0
nPrzMT		:= 0
nPrzMG		:= 0
cTransp		:= SPACE(6)
cFornec		:= SPACE(6)
lOk			:= .T.
nDif			:= 0
nMp			:= 0
nFrt			:= 0
nL 			:= 80
nTotQtdCam  := 0
//(26/01/15 - Thiago) -> [OS 0341-15]
cNFAux		:= ''
nQtdNF		:= 0

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Seleciona a tabela temporaria.										   �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
DbSelectArea("TMP")
DbGoTop()
ProcRegua(TMP->(LastRec()) * 3)

If !TMP->(EOF())
	cNFAux := TMP->DOC
	nQtdNF := 1
EndIf

do while !TMP->(EOF())
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Movimenta o cursor da regua 							  �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	IncProc("Imprimindo ...")
	
	cTransp := TMP->TRANSP
	cFornec := TMP->FORNEC
	cDoc 	:= TMP->DOC
	nUmidad := TMP->UMIDADE
	
	do while !TMP->(EOF()) .AND. (TMP->TRANSP == cTransp)
		do while !TMP->(EOF()) .AND. (TMP->FORNEC == cFornec)
		
			If cNFAux != TMP->DOC
				nQtdNF++
				cNFAux := TMP->DOC 
			EndIf
			
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//� Impressao do cabecalho.						                       �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			if nL >= 60
				nL := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,15) + 2
				
				DbSelectArea("SA2")
				DbSetOrder(1)
				DbSeek(xFilial("SA2")+cTransp)
				@ nL,000 PSay "TRANSPORTADORA: "+SA2->A2_COD+" - "+SA2->A2_NOME
				nL := nL + 2
				
				DbSeek(xFilial("SA2")+cFornec)
				@ nL,007 PSay "FORNECEDOR: "+SA2->A2_COD+" - "+SA2->A2_NOME
				nL := nL + 2
				
				DbSelectArea("TMP")
			endif
			
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//� Imprime linha de detalhe 										   �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			_cDoc	  := TMP->DOC
			_cPrefixo := TMP->PREFIXO
			_cDescricao := space(17)
			
			if lOk
				DbSelectArea("SB1")
				DbSetOrder(1)
				DbSeek(xFilial("SB1")+TMP->PRODUTO)
				_cDescricao := Subst(SB1->B1_DESC,1,17)
			endif
			
			_cChegada := transform(TMP->CHEGADA,"@D")
			_cVencto  := transform(TMP->VENCTO,"@D")
			_cCtrc	  := TMP->CTRC
			_cUmidade := Transform(nUmidade,"@E 999.99")
			_cPesoNF  := transform(TMP->PESONF,"@E 999,999.999")
			_cTicket  := transform(TMP->TICKET,"@E 999,999.999")
			
			if cDoc #TMP->DOC
				_cUmidade := Transform(TMP->UMIDADE,"@E 999.99")
				cDoc 	  := TMP->DOC
				nUmidad   := TMP->UMIDADE
			endif
			
			nDif 		:= (TMP->TICKET - TMP->PESONF )
			nMp			:= (nDif * TMP->PRCUMP)
			nFrt 		:= (nDif * TMP->PRCUFRET)
			nPrz 		:= (TMP->VENCTO - TMP->CHEGADA)
			_cDif		:= transform(nDif,"@E 999,999.999")
			_cPrcUmp	:= transform(TMP->PRCUMP,"@E 999.99")
			_cPrcUFret := transform(TMP->PRCUFRET,"@E 9,999.99")
			_cPrcTmp	:= transform(TMP->PRCTMP,"@E 999,999.99")
			_cPrcTF 	:= transform(TMP->PRCTF,"@E 999,999.99")
			_cMp 		:= transform(nMp,"@E 999,999.99")
			_cFrt		:= transform(nFrt,"@E 999,999.99")
			_cPrz		:= transform(nPrz,"@E 9,999")
			_cPedido	:= TMP->PEDIDO
			_cItemPc	:= TMP->ITEMPC
			
			cLinha := ""
			cLinha := cLinha + _cDoc	   + space(02)
			cLinha := cLinha + _cPrefixo   + space(00)
			cLinha := cLinha + _cDescricao + space(04)
			cLinha := cLinha + _cChegada   + space(03)
			*cLinha := cLinha + _cVencto   + space(02)
			cLinha := cLinha + _cCtrc 	   + space(02)
			cLinha := cLinha + _cUmidade   + space(02)
			cLinha := cLinha + _cPesoNF	   + space(02)
			cLinha := cLinha + _cTicket	   + space(02)
			cLinha := cLinha + _cDif	   + space(02)
			*cLinha := cLinha + _cPrcUmp   + space(02)
			*cLinha := cLinha + _cPrcUFret + space(02)
			*cLinha := cLinha + _cPrcTmp   + space(02)
			*cLinha := cLinha + _cPrcTF	   + space(02)
			*cLinha := cLinha + _cMp	   + space(02)
			*cLinha := cLinha + _cFrt	   + space(02)
			*cLinha := cLinha + _cPrz	   + space(02)
			*cLinha := cLinha + _cPedido   + space(02)
			*cLinha := cLinha + _cItemPc
			
			@ nL,000 PSay cLinha
			nL := nL + 1
			
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//� Acumula totais													   �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			nUmid_F 	 := nUmid_F 	 + (TMP->UMIDADE * TMP->TICKET)
			nTotNf_F	 := nTotNf_F	 + TMP->PESONF
			nTotNf_T	 := nTotNf_T	 + TMP->PESONF
			nTotGNf 	 := nTotGNf 	 + TMP->PESONF
			nTotFTicket  := nTotFTicket + TMP->TICKET
			nTotTTicket  := nTotTTicket + TMP->TICKET
			nTotGTicket  := nTotGTicket + TMP->TICKET
			nTotDif_F	 := nTotDif_F	 + nDif
			nTotDif_T	 := nTotDif_T	 + nDif
			nTotGDif	 := nTotGDif	 + nDif
			nTotMp_F	 := nTotMp_F	 + nMp
			nTotMp_T	 := nTotMp_T	 + nMp
			nTotGMp 	 := nTotGMP 	 + nMp
			nTotPTMP_F   := nTotPTMP_F  + TMP->PRCTMP
			nTotPTMP_T   := nTotPTMP_T  + TMP->PRCTMP
			nTotGPTMP	 := nTotGPTMP	 + TMP->PRCTMP
			nTotPTF_F	 := nTotPTF_F	 + TMP->PRCTF
			nTotPTF_T	 := nTotPTF_T	 + TMP->PRCTF
			nTotGTF 	 := nTotGTF 	 + TMP->PRCTF
			nPrzMF		 := nPrzMF		 + (TMP->PESONF * nPrz)
			nTFF 		 := nTFF 		 + nFrt
			nTFT 		 := nTFT 		 + nFrt
			nTGF 		 := nTGF 		 + nFrt
			nDif 		 := 0
			nMp			 := 0
			nFrt 		 := 0
			
			TMP->(DbSkip())
		enddo
		
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//� Impressao do cabecalho.											   �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		if nL >= 60
			nL := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,15) + 2
			
			DbSelectArea("SA2")
			DbSetOrder(1)
			DbSeek(xFilial("SA2")+cTransp)
			@ nL,000 PSay "TRANSPORTADORA: "+SA2->A2_COD+" - "+SA2->A2_NOME
			nL := nL + 2
			
			DbSeek(xFilial("SA2")+cFornec)
			@ nL,007 PSay "FORNECEDOR: "+SA2->A2_COD+" - "+SA2->A2_NOME
			nL := nL + 2
		endif
		
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//� Totaliza a quebra do fornecedor									   �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		cFornec 	  := TMP->FORNEC
		nL			  := nL + 1
		_cTotUmdMed  := transform((nUmid_F / nTotFTicket),"@E 999.99")
		_cTotNF_F	  := transform(nTotNF_F,"@E 999,999.999")
		_cTotFTicket := transform(nTotFTicket,"@E 999,999.999")
		_nTotDif_F   := transform(nTotDif_F,"@E 999,999.999")
		_nTotPTMP_F  := transform(nTotPTMP_F,"@E 999,999.99")
		_nTotPTF_F   := transform(nTotPTF_F,"@E 999,999.99")
		_nTotMp_F	  := transform(nTotMp_F,"@E 999,999.99")
		_nTFF		  := transform(nTFF,"@E 999,999.99")
		_TotPrzMed   := transform((nPrzMF / nTotNf_F),"@E 9,999")
		
		cLinha := "TOTAL FORNECEDOR: "  + space(24)
		*cLinha := cLinha + _cTotUmdMed	+ space(02)
		cLinha := cLinha + _cTotNF_F 	+ space(02)
		cLinha := cLinha + _cTotFTicket + space(02)
		cLinha := cLinha + _nTotDif_F	+ space(02)
		*cLinha := cLinha + _nTotPTMP_F	+ space(02)
		*cLinha := cLinha + _nTotPTF_F	+ space(02)
		*cLinha := cLinha + _nTotMp_F 	+ space(02)
		*cLinha := cLinha + _nTFF			+ space(02)
		*cLinha := cLinha + _TotPrzMed	+ space(02)
		
		@ nL,008 PSay cLinha
		nL := nL + iif(TMP->(EOF()),2,60) // forca uma nova pagina a cada novo fornecedor.
		
		nTotUmid_T  := nTotUmid_T + (nUmid_F / nTotFTicket)
		nTotGUmid	 := nTotGUmid	+ (nUmid_F / nTotFTicket)
		nPrzMT		 := nPrzMT		+ (nPrzMF  / nTotNf_F)
		nPrzMG		 := nPrzMG		+ (nPrzMF  / nTotNf_F)
		nTotDif_F	 := 0
		nTotMp_F	 := 0
		nTFF 		 := 0
		nTotNf_F	 := 0
		nTotFTicket := 0
		nUmid_F 	 := 0
		nTotPTMP_F  := 0
		nTotPTF_F	 := 0
		nPrzMF		 := 0
		
		if !TMP->(EOF())
			DbSelectArea("SA2")
			DbSeek(xFilial("SA2")+cFornec)
			@ nL,007 PSay "FORNECEDOR: "+SA2->A2_COD+" - "+SA2->A2_NOME
			nL := nL + 2
		endif
		
		lOk := .T.
	enddo
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Impressao do cabecalho.											   �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	if nL >= 60
		nL := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,15) + 2
		
		DbSelectArea("SA2")
		DbSetOrder(1)
		DbSeek(xFilial("SA2")+cTransp)
		@ nL,000 PSay "TRANSPORTADORA: "+SA2->A2_COD+" - "+SA2->A2_NOME
		nL := nL + 2
		
		DbSeek(xFilial("SA2")+cFornec)
		@ nL,007 PSay "FORNECEDOR: "+SA2->A2_COD+" - "+SA2->A2_NOME
		nL := nL + 2
	endif
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Totaliza a quebra da transportadora								   �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	cTransp 	  := TMP->TRANSP
	_cTotUmid_T  := transform(nTotUmid_T,"@E 999.99")
	_cTotNf_T	  := transform(nTotNf_T,"@E 999,999.999")
	_cTotTTicket := transform(nTotTTicket,"@E 999,999.999")
	_cTotDif_T   := transform(nTotDif_T,"@E 999,999.999")
	_cTotPTMP_T  := transform(nTotPTMP_T,"@E 999,999.99")
	_cTotPTF_T   := transform(nTotPTF_T,"@E 999,999.99")
	_cTotMp_T	  := transform(nTotMp_T,"@E 999,999.99")
	_cTFT		  := transform(nTFT,"@E 999,999.99")
	_cPrzMT 	  := transform(nPrzMT,"@E 9,999")
	
	cLinha := "TOTAL TRANSPORTADORA: " + space(20)
	*cLinha := cLinha + _cTotUmid_T		+ space(02)
	cLinha := cLinha + _cTotNf_T 		+ space(02)
	cLinha := cLinha + _cTotTTicket 	+ space(02)
	cLinha := cLinha + _cTotDif_T		+ space(02)
	*cLinha := cLinha + _cTotPTMP_T		+ space(02)
	*cLinha := cLinha + _cTotPTF_T		+ space(02)
	*cLinha := cLinha + _cTotMp_T 		+ space(02)
	*cLinha := cLinha + _cTFT				+ space(02)
	*cLinha := cLinha + _cPrzMT
	
	@ nL,008 PSay cLinha
	nL := nL + 2
	
	nTotUmid_T  := 0
	nTotDif_T	 := 0
	nTotMp_T	 := 0
	nTFT 		 := 0
	nTotNf_T	 := 0
	nTotTTicket := 0
	nPrzMT		 := 0
enddo

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Impressao do cabecalho.											   �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
if nL >= 60
	nL := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,15) + 2
endif

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Imprime o Total Geral											   �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
_cTotGUmid	 := transform(nTotGUmid,"@E 999.99")
_cTotGNf 	 := transform(nTotGNf,"@E 999,999.999")
_cTotGTicket := transform(nTotGTicket,"@E 999,999.999")
_cTotGDif	 := transform(nTotGDif,"@E 999,999.999")
_cTotGPTMP	 := transform(nTotGPTMP,"@E 999,999.99")
_cTotGTF 	 := transform(nTotGTF,"@E 999,999.99")
_cTotGMp 	 := transform(nTotGMp,"@E 999,999.99")
_cTGF 		 := transform(nTGF,"@E 999,999.99")

cLinha := "TOTAL GERAL: "       + space(29)
*cLinha := cLinha + _cTotGUmid   + space(02)
cLinha := cLinha + _cTotGNf	  + space(02)
cLinha := cLinha + _cTotGTicket + space(02)
cLinha := cLinha + _cTotGDif	  + space(02)
*cLinha := cLinha + _cTotGPTMP   + space(02)
*cLinha := cLinha + _cTotGTF	  + space(02)
*cLinha := cLinha + _cTotGMp	  + space(02)
*cLinha := cLinha + _cTGF		  + space(02)

@ nL,008 PSay cLinha
nL := nL + 2

cLinha := "QUANTIDADE DE CAMIN�ES: "+ space(29) + cValToChar(nQtdNF)
@ nL,008 PSay cLinha
nL := nL + 1

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Impress꼘 do rodape 												   �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
roda(nCbCont,cCbTxt,cTamanho)
return

/*/
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴엽�
굇쿑uncao	 � fApagaTemp � Autor � WLADIMIR ILLIUSHENKO 				  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿏escricao � Apaga a tabela temporaria. 								  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so		 � SIGACOM													  낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fApagaTemp
Static FUNCTION fApagaTemp()
DbSelectArea("TMP")
DbCloseArea("TMP")
FErase(cArqTemp+".*")
RETURN
