#include "rwmake.ch"
#include "topconn.ch"

User Function BIA430()

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ BIA430     ³ Autor ³ Biancogres           ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ (Importacao)                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
wanisay	*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private nFlag
Private _aItRpt1	:=	{}
Private _aItRpt2	:=	{}


_cDIR    := "\P10\ARQUIVOS\" //diretorio dos arquivos TXT recebimento

MsgBox("Versao_01","STOP")

_cPED    := SPACE(6)
_dDATA      := DDATABASE
_DATALOG    := DTOS(DDATABASE)
_cHORA      := TIME()
_nDESCPER   := 0.00
_nFATOR     := 0.00
_nXFATOR    := 0.00
_nFATSE4    := 0.00
cNfAnt      := ''
nValAnt     := 0
nValPGAnt   := 0
nValorNF    := 0
nValorPG    := 0

_nFATORSZ8  := 0.00
_dNRODIAS   := 0
lPasSD1     := .F.
lPasSF1     := .F.
cMENS       := SPACE(1)
dDataMov    := CTOD("  /  /  ")

Processa({|| fPRINCIPAL()})

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fPRINCIPAL³ Autor ³ MICROSIGA Vitoria     ³ Data ³ 10/05/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cria arquivos de trabalho e processa dados                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//*****************************************************************************
Static Function fPRINCIPAL()
local _ni
//*****************************************************************************
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao do arquivo de trabalho cabecalho                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_aP1A := {}
AADD(  _aP1A , {"CODIGO"   , "C" ,  9  ,  0}  )
AADD(  _aP1A , {"CLVL"     , "C" ,  9  ,  0}  )
AADD(  _aP1A , {"DESC"     , "C" ,  40 ,  0}  )
AADD(  _aP1A , {"FORNECE"  , "C" ,  40 ,  0}  )
AADD(  _aP1A , {"PRODUTO"  , "C" ,  40 ,  0}  )
AADD(  _aP1A , {"NF"       , "C" ,  09 ,  0}  )
AADD(  _aP1A , {"DTMOV"    , "D" ,  08 ,  0}  )
AADD(  _aP1A , {"VALOR"    , "N" ,  14 ,  2}  )
AADD(  _aP1A , {"VLPAGO"   , "N" ,  14 ,  2}  )

_aP1A := CriaTrab(_aP1A,.T.)
DbUseArea(.T.,,_aP1A,"_aP1A")

  DBCreateIndex(_aP1A + "1", "CLVL+CODIGO+DTOS(DTMOV)+NF"         , {|| CLVL+CODIGO+DTOS(DTMOV)+NF         })
  DBCreateIndex(_aP1A + "2", "CLVL+DTOS(DTMOV)+CODIGO"         , {|| CLVL+DTOS(DTMOV)+CODIGO         })
  DBCreateIndex(_aP1A + "3", "CLVL+CODIGO+DTOS(DTMOV)"         , {|| CLVL+CODIGO+DTOS(DTMOV)         })
  _aP1A->( DBClearIndex() ) //Força o fechamento dos indices abertos
 
  dbSetIndex(_aP1A + "1") //acrescenta a ordem de indice para a área aberta
  dbSetIndex(_aP1A + "2") //acrescenta a ordem de indice para a área aberta
  dbSetIndex(_aP1A + "3") //acrescenta a ordem de indice para a área aberta

  _aP1A->(DbSetOrder(1))

dbGotop()

_aP1B := {}
AADD(  _aP1B , {"CODIGO"   , "C" ,  9  ,  0}  )
AADD(  _aP1B , {"CLVL"     , "C" ,  9  ,  0}  )
AADD(  _aP1B , {"DESC"     , "C" ,  40 ,  0}  )
AADD(  _aP1B , {"FORNECE"  , "C" ,  40 ,  0}  )
AADD(  _aP1B , {"PRODUTO"  , "C" ,  40 ,  0}  )
AADD(  _aP1B , {"NF"       , "C" ,  09 ,  0}  )
AADD(  _aP1B , {"DTMOV"    , "D" ,  08 ,  0}  )
AADD(  _aP1B , {"VALOR"    , "N" ,  14 ,  2}  )
AADD(  _aP1B , {"VLPAGO"   , "N" ,  14 ,  2}  )

_aP1B := CriaTrab(_aP1B,.T.)
DbUseArea(.T.,,_aP1B,"_aP1B")

  DBCreateIndex(_aP1B + "1", "CLVL+CODIGO+DTOS(DTMOV)+NF"         , {|| CLVL+CODIGO+DTOS(DTMOV)+NF         })
  DBCreateIndex(_aP1B + "2", "CLVL+DTOS(DTMOV)+CODIGO"         , {|| CLVL+DTOS(DTMOV)+CODIGO         })
  DBCreateIndex(_aP1B + "3", "CLVL+CODIGO+DTOS(DTMOV)"         , {|| CLVL+CODIGO+DTOS(DTMOV)         })
  _aP1B->( DBClearIndex() ) //Força o fechamento dos indices abertos
 
  dbSetIndex(_aP1B + "1") //acrescenta a ordem de indice para a área aberta
  dbSetIndex(_aP1B + "2") //acrescenta a ordem de indice para a área aberta
  dbSetIndex(_aP1B + "3") //acrescenta a ordem de indice para a área aberta

  _aP1B->(DbSetOrder(1))


dbGotop()

_aP1C := {}
AADD(  _aP1C , {"CODIGO"   , "C" ,  9  ,  0}  )
AADD(  _aP1C , {"CLVL"     , "C" ,  9  ,  0}  )
AADD(  _aP1C , {"DESC"     , "C" ,  40 ,  0}  )
AADD(  _aP1C , {"FORNECE"  , "C" ,  40 ,  0}  )
AADD(  _aP1C , {"PRODUTO"  , "C" ,  40 ,  0}  )
AADD(  _aP1C , {"NF"       , "C" ,  09 ,  0}  )
AADD(  _aP1C , {"DTMOV"    , "D" ,  08 ,  0}  )
AADD(  _aP1C , {"VALOR"    , "N" ,  14 ,  2}  )
AADD(  _aP1C , {"VLPAGO"   , "N" ,  14 ,  2}  )

_aP1C := CriaTrab(_aP1C,.T.)
DbUseArea(.T.,,_aP1C,"_aP1C")

  DBCreateIndex(_aP1C + "1", "CLVL+CODIGO+DTOS(DTMOV)+NF"         , {|| CLVL+CODIGO+DTOS(DTMOV)+NF         })
  DBCreateIndex(_aP1C + "2", "CLVL+DTOS(DTMOV)+CODIGO"         , {|| CLVL+DTOS(DTMOV)+CODIGO         })
  DBCreateIndex(_aP1C + "3", "CLVL+CODIGO+DTOS(DTMOV)"         , {|| CLVL+CODIGO+DTOS(DTMOV)         })
  _aP1A->( DBClearIndex() ) //Força o fechamento dos indices abertos
 
  dbSetIndex(_aP1C + "1") //acrescenta a ordem de indice para a área aberta
  dbSetIndex(_aP1C + "2") //acrescenta a ordem de indice para a área aberta
  dbSetIndex(_aP1C + "3") //acrescenta a ordem de indice para a área aberta

  _aP1C->(DbSetOrder(1))

dbGotop()

_aP2A := {}
AADD(  _aP2A , {"CODIGO"   , "C" ,  2  ,  0}  )
AADD(  _aP2A , {"CLVL"     , "C" ,  9  ,  0}  )
AADD(  _aP2A , {"DESC"     , "C" ,  40 ,  0}  )
AADD(  _aP2A , {"VALOR"    , "N" ,  14 ,  2}  )
AADD(  _aP2A , {"VLPAGO"   , "N" ,  14 ,  2}  )

_aP2A := CriaTrab(_aP2A,.T.)
DbUseArea(.T.,,_aP2A,"_aP2A")
cChave  :="CLVL+CODIGO"
IndRegua("_aP2A",_aP2A,cChave,,,"Selecionando Registros...")
dbGotop()

_aP2B := {}
AADD(  _aP2B , {"CODIGO"   , "C" ,  2  ,  0}  )
AADD(  _aP2B , {"CLVL"     , "C" ,  9  ,  0}  )
AADD(  _aP2B , {"DESC"     , "C" ,  40 ,  0}  )
AADD(  _aP2B , {"VALOR"    , "N" ,  14 ,  2}  )
AADD(  _aP2B , {"VLPAGO"   , "N" ,  14 ,  2}  )

_aP2B := CriaTrab(_aP2B,.T.)
DbUseArea(.T.,,_aP2B,"_aP2B")
cChave  :="CLVL+CODIGO"
IndRegua("_aP2B",_aP2B,cChave,,,"Selecionando Registros...")
dbGotop()

_aP2C := {}
AADD(  _aP2C , {"CODIGO"   , "C" ,  2  ,  0}  )
AADD(  _aP2C , {"CLVL"     , "C" ,  9  ,  0}  )
AADD(  _aP2C , {"DESC"     , "C" ,  40 ,  0}  )
AADD(  _aP2C , {"VALOR"    , "N" ,  14 ,  2}  )
AADD(  _aP2C , {"VLPAGO"   , "N" ,  14 ,  2}  )

_aP2C := CriaTrab(_aP2C,.T.)
DbUseArea(.T.,,_aP2C,"_aP2C")
cChave  :="CLVL+CODIGO"
IndRegua("_aP2C",_aP2C,cChave,,,"Selecionando Registros...")
dbGotop()

_aP3A := {}
AADD(  _aP3A , {"CLVL"     , "C" ,  9  ,  0}  )
AADD(  _aP3A , {"TIPO"     , "C" ,  2  ,  0}  )
AADD(  _aP3A , {"VALOR"    , "N" ,  14 ,  2}  )
AADD(  _aP3A , {"VLPAGO"   , "N" ,  14 ,  2}  )

If chkfile("_aP3A")
	dbSelectArea("_aP3A")
	dbCloseArea()
EndIf
_aP3A := CriaTrab(_aP3A,.T.)
DbUseArea(.T.,,_aP3A,"_aP3A")
cChave  :="CLVL+TIPO"
IndRegua("_aP3A",_aP3A,cChave,,,"Selecionando Registros...")
dbGotop()

_aP4A := {}
AADD(  _aP4A , {"CLVL"     , "C" ,  9  ,  0}  )
AADD(  _aP4A , {"TIPO"     , "C" ,  2  ,  0}  )
AADD(  _aP4A , {"VLR01"    , "N" ,  14 ,  2}  )
AADD(  _aP4A , {"VLR02"    , "N" ,  14 ,  2}  )
AADD(  _aP4A , {"VLR03"    , "N" ,  14 ,  2}  )
AADD(  _aP4A , {"VLR04"    , "N" ,  14 ,  2}  )
AADD(  _aP4A , {"VLR05"    , "N" ,  14 ,  2}  )
AADD(  _aP4A , {"VLR06"    , "N" ,  14 ,  2}  )
AADD(  _aP4A , {"VLR07"    , "N" ,  14 ,  2}  )
AADD(  _aP4A , {"VLR08"    , "N" ,  14 ,  2}  )
AADD(  _aP4A , {"VLR09"    , "N" ,  14 ,  2}  )
AADD(  _aP4A , {"VLR10"    , "N" ,  14 ,  2}  )
AADD(  _aP4A , {"VLR11"    , "N" ,  14 ,  2}  )
AADD(  _aP4A , {"VLR12"    , "N" ,  14 ,  2}  )
AADD(  _aP4A , {"VLRAC"    , "N" ,  14 ,  2}  )
AADD(  _aP4A , {"TOTAL"    , "N" ,  14 ,  2}  )

_aP4A := CriaTrab(_aP4A,.T.)
DbUseArea(.T.,,_aP4A,"_aP4A")
cChave  :="CLVL+TIPO"
IndRegua("_aP4A",_aP4A,cChave,,,"Selecionando Registros...")
dbGotop()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da matriz com nome arquivos cabecalho pedido                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cHInicio := Time()
fPerg := "BIA430"
ValidPerg()
If !Pergunte(fPerg,.T.)
	Return
EndIf

// _dDATA1 := DTOC(DDATABASE)
// wkdat := substr(_DDATA1,1,2) + substr(_DDATA1,4,2) + substr(_DDATA1,7,2)
_aTRANS:={}
_aTRANS:=DIRECTORY(_cDIR+"plan????.csv")

FOR _nI := 1 TO LEN(_aTRANS)
	
	_cTRANS := SUBSTR(ALLTRIM(_aTRANS[_nI,1]), 5, 4)
	
	_cIMPORT := "plan"+_cTRANS+".csv"  //tamanho 12 posicoes
	
	MsAguarde({|| fTRABGRAVA()},"Arquivos de Trabalho","Aguarde-A") // Atualizar arquivos trabalho _aP1
	
	//Ferase(ALLTRIM(_cDIR)+ALLTRIM(_cIMPORT))
NEXT

MsAguarde({|| Contabil()},"Importando dados da contabilidade","Atualizando")

//Origem das informacoes - Planilha
nFlag := 1
IF  UPPER(ALLTRIM(cUserName)) == 'JECIMAR'           .OR. ;
	UPPER(ALLTRIM(cUserName)) == 'RENATO'            .OR. ;
	UPPER(ALLTRIM(cUserName)) == 'ENELCIO'           .OR. ;
	UPPER(ALLTRIM(cUserName)) == 'MARCELO GUIZZARDI' .OR. ;
	UPPER(ALLTRIM(cUserName)) == 'MARCELLO'          .OR. ;
	UPPER(ALLTRIM(cUserName)) == 'ADMINISTRADOR'     .OR. ;
	UPPER(ALLTRIM(cUserName)) == 'WANISAY'
	//UPPER(ALLTRIM(cUserName)) == 'ALOISIO'         .OR. ;
		IF MV_PAR03 <> 2
		Processa({|| RptDet_1()})
	ENDIF
ENDIF

//Origem das informacoes - Microsiga
nFlag := 2
IF MV_PAR03 <> 1
	Processa({|| RptDet_2()})
ENDIF

//Origem das informacoes - Planilha + Microsiga
nFlag := 3
IF  UPPER(ALLTRIM(cUserName)) == 'JECIMAR'     	    .OR.;
	UPPER(ALLTRIM(cUserName)) == 'RENATO'           .OR.;
	UPPER(ALLTRIM(cUserName)) == 'ENELCIO'          .OR.;
	UPPER(ALLTRIM(cUserName)) == 'MARCELO GUIZZARDI'.OR.;
	UPPER(ALLTRIM(cUserName)) == 'MARCELLO'         .OR.;
	UPPER(ALLTRIM(cUserName)) == 'ADMINISTRADOR'    .OR.;
	UPPER(ALLTRIM(cUserName)) == 'WANISAY'
	//UPPER(ALLTRIM(cUserName)) == 'ALOISIO'        .OR.;
		IF MV_PAR03 == 3
		Processa({|| RptDet_3()})
	ENDIF
ENDIF

//Origem das informacoes - Planilha + Microsiga
Processa({|| RptDet_4()})

//Resumo dos Investimentos - Acumulado
Processa({|| RptDet_5()})

If MV_PAR09 == 1
	fImpExcel()
EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ exclusao dos arquivos temporarios usados pela rotina                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_aP1A->(DbCloseArea()); aeval(directory(_aP1A+"*.*"),{ |aFile| FErase(aFile[1])})
_aP1B->(DbCloseArea()); aeval(directory(_aP1B+"*.*"),{ |aFile| FErase(aFile[1])})
_aP1C->(DbCloseArea()); aeval(directory(_aP1C+"*.*"),{ |aFile| FErase(aFile[1])})
_aP2A->(DbCloseArea()); aeval(directory(_aP2A+".*"),{ |aFile| FErase(aFile[1])})
_aP2B->(DbCloseArea()); aeval(directory(_aP2B+".*"),{ |aFile| FErase(aFile[1])})
_aP2C->(DbCloseArea()); aeval(directory(_aP2C+".*"),{ |aFile| FErase(aFile[1])})
_aP3A->(DbCloseArea()); aeval(directory(_aP3A+".*"),{ |aFile| FErase(aFile[1])})
_aP4A->(DbCloseArea()); aeval(directory(_aP4A+".*"),{ |aFile| FErase(aFile[1])})
RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fTRABGRAVA        ³ MICROSIGA Vitoria     ³ Data ³ 10/05/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Processa leitura e gravacao dos arquivos de trabalho       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

ßßßßßßßßßßßßßßßßßßß
*/
Static Function fTRABGRAVA()

_cARQ    := _cDIR + _cIMPORT
_nQTDREG := 0
_nTamLin := 130                  // Tamanho da linha no arquivo texto   681
_cBuffer := Space(_nTamLin + 2)  // Guarda a linha lida
_nBytes  := 0                    // Guarda numero da linha
_nhdl    := Fopen(_cARQ,0)       // Abre o arquivo so leitura

If _nhdl == -1
	MsgAlert("Erro abertura arquivo "+_cARQ,)
	Return
Endif

_nTamLin := 50000
lOk      := .T.
_nBytes  := fRead(_nhdl,@_cBuffer,_nTamLin + 2) // Le primeira linha

DBSELECTAREA("_aP1A")
DBSETORDER(1)
nValor  := 0
cCodigo := SPACE(6)

//While _nBytes == _nTamLin + 2
While lOk
	
	nPos     := AT('**',_cBuffer)
	nLinAtu  := SUBSTR(_cBuffer,1,nPos+4)
	_cBuffer := SUBSTR(_cBuffer,nPos+4,_nBytes - nPos+4)
	
	IF LEN(_cBuffer) < 131
		lOk := .F.
	ENDIF
	
	//Define posicoes variaveis
	IF SUBSTR(nLinAtu,1,1) <> ';' .AND. SUBSTR(nLinAtu,1,1) <> 'C'
		nPos1    := AT(';',nLinAtu)
		cCodigo  := ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1))
		nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		
		nPos1    := AT(';',nLinAtu)
		cDescri  := ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1))
		nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		
		nPos1    := AT(';',nLinAtu)
		cBranco1 := ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1))
		nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		
		nPos1    := AT(';',nLinAtu)
		cFornece := ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1))
		nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		
		nPos1    := AT(';',nLinAtu)
		cProd    := ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1))
		nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		
		nPos1    := AT(';',nLinAtu)
		cData    := ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1))
		nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		
		nPos1    := AT(';',nLinAtu)
		cValor   := ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1))
		nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		
		nPos1    := AT(';',nLinAtu)
		cBranco2 := ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1))
		nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		
		nPos1    := AT(';',nLinAtu)
		cFim     := ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1))
		nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		
		dDataMov := CTOD("  /  /  ")
		DO CASE
			CASE Substr(cData,1,3) == 'jan'
				dDataMov := CTOD("01/01/"+Substr(cData,5,2))
			CASE Substr(cData,1,3) == 'fev'
				dDataMov := CTOD("01/02/"+Substr(cData,5,2))
			CASE Substr(cData,1,3) == 'mar'
				dDataMov := CTOD("01/03/"+Substr(cData,5,2))
			CASE Substr(cData,1,3) == 'abr'
				dDataMov := CTOD("01/04/"+Substr(cData,5,2))
			CASE Substr(cData,1,3) == 'mai'
				dDataMov := CTOD("01/05/"+Substr(cData,5,2))
			CASE Substr(cData,1,3) == 'jun'
				dDataMov := CTOD("01/06/"+Substr(cData,5,2))
			CASE Substr(cData,1,3) == 'jul'
				dDataMov := CTOD("01/07/"+Substr(cData,5,2))
			CASE Substr(cData,1,3) == 'ago'
				dDataMov := CTOD("01/08/"+Substr(cData,5,2))
			CASE Substr(cData,1,3) == 'set'
				dDataMov := CTOD("01/09/"+Substr(cData,5,2))
			CASE Substr(cData,1,3) == 'out'
				dDataMov := CTOD("01/10/"+Substr(cData,5,2))
			CASE Substr(cData,1,3) == 'nov'
				dDataMov := CTOD("01/11/"+Substr(cData,5,2))
			CASE Substr(cData,1,3) == 'dez'
				dDataMov := CTOD("01/12/"+Substr(cData,5,2))
		ENDCASE
		
		IF DTOS(dDataMov) < '20080501'
			//Classe de Valor 8009
			DO CASE
				CASE cCodigo == '11'   .AND. _cTRANS == '8009'
					cCodigo := '0802'
				CASE cCodigo == '12'   .AND. _cTRANS == '8009'
					cCodigo := '0301'
				CASE cCodigo == '211'  .AND. _cTRANS == '8009'
					cCodigo := '0502'
				CASE cCodigo == '212'  .AND. _cTRANS == '8009'
					cCodigo := '0502'
				CASE cCodigo == '213'  .AND. _cTRANS == '8009'
					cCodigo := '0502'
				CASE cCodigo == '214'  .AND. _cTRANS == '8009'
					cCodigo := '0502'
				CASE cCodigo == '215'  .AND. _cTRANS == '8009'
					cCodigo := '0502'
				CASE cCodigo == '216'  .AND. _cTRANS == '8009'
					cCodigo := '0805'
				CASE cCodigo == '217'  .AND. _cTRANS == '8009'
					cCodigo := '0401'
				CASE cCodigo == '218'  .AND. _cTRANS == '8009'
					cCodigo := '0913'
				CASE cCodigo == '219'  .AND. _cTRANS == '8009'
					cCodigo := '0903'
				CASE cCodigo == '2110' .AND. _cTRANS == '8009'
					cCodigo := '0502'
				CASE cCodigo == '221'  .AND. _cTRANS == '8009'
					cCodigo := '0505'
				CASE cCodigo == '222'  .AND. _cTRANS == '8009'
					cCodigo := '0505'
				CASE cCodigo == '223'  .AND. _cTRANS == '8009'
					cCodigo := '0505'
				CASE cCodigo == '227'  .AND. _cTRANS == '8009'
					cCodigo := '0505'
				CASE cCodigo == '228'  .AND. _cTRANS == '8009'
					cCodigo := '0806'
				CASE cCodigo == '229'  .AND. _cTRANS == '8009'
					cCodigo := '0505'
				CASE cCodigo == '2210' .AND. _cTRANS == '8009'
					cCodigo := '0505'
				CASE cCodigo == '2211' .AND. _cTRANS == '8009'
					cCodigo := '0505'
				CASE cCodigo == '2212' .AND. _cTRANS == '8009'
					cCodigo := '0505'
				CASE cCodigo == '2213' .AND. _cTRANS == '8009'
					cCodigo := '0505'
				CASE cCodigo == '2215' .AND. _cTRANS == '8009'
					cCodigo := '0505'
				CASE cCodigo == '2217' .AND. _cTRANS == '8009'
					cCodigo := '0401'
				CASE cCodigo == '2218' .AND. _cTRANS == '8009'
					cCodigo := '0913'
				CASE cCodigo == '2219' .AND. _cTRANS == '8009'
					cCodigo := '0903'
				CASE cCodigo == '2220' .AND. _cTRANS == '8009'
					cCodigo := '0505'
				CASE cCodigo == '2221' .AND. _cTRANS == '8009'
					cCodigo := '0505'
				CASE cCodigo == '2222' .AND. _cTRANS == '8009'
					cCodigo := '0505'
				CASE cCodigo == '2223' .AND. _cTRANS == '8009'
					cCodigo := '0505'
				CASE cCodigo == '231'  .AND. _cTRANS == '8009'
					cCodigo := '0603'
				CASE cCodigo == '232'  .AND. _cTRANS == '8009'
					cCodigo := '0402'
				CASE cCodigo == '233'  .AND. _cTRANS == '8009'
					cCodigo := '0503'
				CASE cCodigo == '234'  .AND. _cTRANS == '8009'
					cCodigo := '0806'
				CASE cCodigo == '235'  .AND. _cTRANS == '8009'
					cCodigo := '0503'
				CASE cCodigo == '236'  .AND. _cTRANS == '8009'
					cCodigo := '0603'
				CASE cCodigo == '237'  .AND. _cTRANS == '8009'
					cCodigo := '0603'
				CASE cCodigo == '238'  .AND. _cTRANS == '8009'
					cCodigo := '0604'
				CASE cCodigo == '239'  .AND. _cTRANS == '8009'
					cCodigo := '0907'
				CASE cCodigo == '2313' .AND. _cTRANS == '8009'
					cCodigo := '0401'
				CASE cCodigo == '2314' .AND. _cTRANS == '8009'
					cCodigo := '0202'
				CASE cCodigo == '2315' .AND. _cTRANS == '8009'
					cCodigo := '0403'
				CASE cCodigo == '2316' .AND. _cTRANS == '8009'
					cCodigo := '0503'
				CASE cCodigo == '2318' .AND. _cTRANS == '8009'
					cCodigo := '0903'
				CASE cCodigo == '2319' .AND. _cTRANS == '8009'
					cCodigo := '0503'
				CASE cCodigo == '241'  .AND. _cTRANS == '8009'
					cCodigo := '0506'
				CASE cCodigo == '242'  .AND. _cTRANS == '8009'
					cCodigo := '0506'
				CASE cCodigo == '243'  .AND. _cTRANS == '8009'
					cCodigo := '0506'
				CASE cCodigo == '244'  .AND. _cTRANS == '8009'
					cCodigo := '0704'
				CASE cCodigo == '245'  .AND. _cTRANS == '8009'
					cCodigo := '0401'
				CASE cCodigo == '246'  .AND. _cTRANS == '8009'
					cCodigo := '0913'
				CASE cCodigo == '247'  .AND. _cTRANS == '8009'
					cCodigo := '0903'
				CASE cCodigo == '248'  .AND. _cTRANS == '8009'
					cCodigo := '0606'
				CASE cCodigo == '249'  .AND. _cTRANS == '8009'
					cCodigo := '0913'
				CASE cCodigo == '251'  .AND. _cTRANS == '8009'
					cCodigo := '0607'
				CASE cCodigo == '252'  .AND. _cTRANS == '8009'
					cCodigo := '0402'
				CASE cCodigo == '254'  .AND. _cTRANS == '8009'
					cCodigo := '0401'
				CASE cCodigo == '255'  .AND. _cTRANS == '8009'
					cCodigo := '0202'
				CASE cCodigo == '261'  .AND. _cTRANS == '8009'
					cCodigo := '0607'
				CASE cCodigo == '262'  .AND. _cTRANS == '8009'
					cCodigo := '0507'
				CASE cCodigo == '263'  .AND. _cTRANS == '8009'
					cCodigo := '0707'
				CASE cCodigo == '265'  .AND. _cTRANS == '8009'
					cCodigo := '0401'
				CASE cCodigo == '266'  .AND. _cTRANS == '8009'
					cCodigo := '0202'
				CASE cCodigo == '271'  .AND. _cTRANS == '8009'
					cCodigo := '0608'
				CASE cCodigo == '272'  .AND. _cTRANS == '8009'
					cCodigo := '0402'
				CASE cCodigo == '276'  .AND. _cTRANS == '8009'
					cCodigo := '0401'
				CASE cCodigo == '277'  .AND. _cTRANS == '8009'
					cCodigo := '0202'
				CASE cCodigo == '281'  .AND. _cTRANS == '8009'
					cCodigo := '0511'
				CASE cCodigo == '282'  .AND. _cTRANS == '8009'
					cCodigo := '0511'
				CASE cCodigo == '283'  .AND. _cTRANS == '8009'
					cCodigo := '0511'
				CASE cCodigo == '284'  .AND. _cTRANS == '8009'
					cCodigo := '0511'
				CASE cCodigo == '285'  .AND. _cTRANS == '8009'
					cCodigo := '0511'
				CASE cCodigo == '31'   .AND. _cTRANS == '8009'
					cCodigo := '0805'
				CASE cCodigo == '311'  .AND. _cTRANS == '8009'
					cCodigo := '0806'
				CASE cCodigo == '312'  .AND. _cTRANS == '8009'
					cCodigo := '0805'
				CASE cCodigo == '313'  .AND. _cTRANS == '8009'
					cCodigo := '0805'
				CASE cCodigo == '321'  .AND. _cTRANS == '8009'
					cCodigo := '0805'
				CASE cCodigo == '331'  .AND. _cTRANS == '8009'
					cCodigo := '0805'
				CASE cCodigo == '341'  .AND. _cTRANS == '8009'
					cCodigo := '0805'
				CASE cCodigo == '35'   .AND. _cTRANS == '8009'
					cCodigo := '0807'
				CASE cCodigo == '351'  .AND. _cTRANS == '8009'
					cCodigo := '0804'
				CASE cCodigo == '352'  .AND. _cTRANS == '8009'
					cCodigo := '0803'
				CASE cCodigo == '353'  .AND. _cTRANS == '8009'
					cCodigo := '0807'
				CASE cCodigo == '354'  .AND. _cTRANS == '8009'
					cCodigo := '0807'
				CASE cCodigo == '361'  .AND. _cTRANS == '8009'
					cCodigo := '0806'
				CASE cCodigo == '362'  .AND. _cTRANS == '8009'
					cCodigo := '0805'
				CASE cCodigo == '363'  .AND. _cTRANS == '8009'
					cCodigo := '0805'
				CASE cCodigo == '364'  .AND. _cTRANS == '8009'
					cCodigo := '0805'
				CASE cCodigo == '365'  .AND. _cTRANS == '8009'
					cCodigo := '0806'
				CASE cCodigo == '411'  .AND. _cTRANS == '8009'
					cCodigo := '0714'
				CASE cCodigo == '511'  .AND. _cTRANS == '8009'
					cCodigo := '0902'
				CASE cCodigo == '512'  .AND. _cTRANS == '8009'
					cCodigo := '0901'
				CASE cCodigo == '513'  .AND. _cTRANS == '8009'
					cCodigo := '0901'
				CASE cCodigo == '515'  .AND. _cTRANS == '8009'
					cCodigo := '0901'
				CASE cCodigo == '516'  .AND. _cTRANS == '8009'
					cCodigo := '0901'
				CASE cCodigo == '517'  .AND. _cTRANS == '8009'
					cCodigo := '0902'
				CASE cCodigo == '521'  .AND. _cTRANS == '8009'
					cCodigo := '0905'
				CASE cCodigo == '522'  .AND. _cTRANS == '8009'
					cCodigo := '0705'
				CASE cCodigo == '523'  .AND. _cTRANS == '8009'
					cCodigo := '0905'
				CASE cCodigo == '531'  .AND. _cTRANS == '8009'
					cCodigo := '0908'
				CASE cCodigo == '532'  .AND. _cTRANS == '8009'
					cCodigo := '0908'
				CASE cCodigo == '533'  .AND. _cTRANS == '8009'
					cCodigo := '0908'
				CASE cCodigo == '541'  .AND. _cTRANS == '8009'
					cCodigo := '0906'
				CASE cCodigo == '542'  .AND. _cTRANS == '8009'
					cCodigo := '0906'
				CASE cCodigo == '551'  .AND. _cTRANS == '8009'
					cCodigo := '0907'
				CASE cCodigo == '552'  .AND. _cTRANS == '8009'
					cCodigo := '0907'
				CASE cCodigo == '561'  .AND. _cTRANS == '8009'
					cCodigo := '0904'
				CASE cCodigo == '562'  .AND. _cTRANS == '8009'
					cCodigo := '0904'
				CASE cCodigo == '57'   .AND. _cTRANS == '8009'
					cCodigo := '0909'
				CASE cCodigo == '581'  .AND. _cTRANS == '8009'
					cCodigo := '0908'
				CASE cCodigo == '591'  .AND. _cTRANS == '8009'
					cCodigo := '0714'
				CASE cCodigo == '510'  .AND. _cTRANS == '8009'
					cCodigo := '0915'
				CASE cCodigo == '61'   .AND. _cTRANS == '8009'
					cCodigo := '0913'
				CASE cCodigo == '62'   .AND. _cTRANS == '8009'
					cCodigo := '0401'
				CASE cCodigo == '63'  .AND. _cTRANS == '8009'
					cCodigo := '0201'
				CASE cCodigo == '64'  .AND. _cTRANS == '8009'
					cCodigo := '0204'
				CASE cCodigo == '65'  .AND. _cTRANS == '8009'
					cCodigo := '0101'
				CASE cCodigo == '66'  .AND. _cTRANS == '8009'
					cCodigo := '0102'
				CASE cCodigo == '67'  .AND. _cTRANS == '8009'
					cCodigo := '0106'
				CASE cCodigo == '68'  .AND. _cTRANS == '8009'
					cCodigo := '1002'
				CASE cCodigo == '71'  .AND. _cTRANS == '8009'
					cCodigo := '1001'
				CASE cCodigo == '72'  .AND. _cTRANS == '8009'
					cCodigo := '1002'
				CASE cCodigo == '73'  .AND. _cTRANS == '8009'
					cCodigo := '1001'
				CASE cCodigo == '74'  .AND. _cTRANS == '8009'
					cCodigo := '1005'
				CASE cCodigo == '8'   .AND. _cTRANS == '8009'
					cCodigo := '1005'
				CASE cCodigo == '91'  .AND. _cTRANS == '8009'
					cCodigo := '0607'
				CASE cCodigo == '92'  .AND. _cTRANS == '8009'
					cCodigo := '0502'
				CASE cCodigo == '93'  .AND. _cTRANS == '8009'
					cCodigo := '0502'
				CASE cCodigo == '94'  .AND. _cTRANS == '8009'
					cCodigo := '0502'
				CASE cCodigo == '95'  .AND. _cTRANS == '8009'
					cCodigo := '0806'
				CASE cCodigo == '96'  .AND. _cTRANS == '8009'
					cCodigo := '0511'
				CASE cCodigo == '97'  .AND. _cTRANS == '8009'
					cCodigo := '0502'
				CASE cCodigo == '98'  .AND. _cTRANS == '8009'
					cCodigo := '0101'
				CASE cCodigo == '99'  .AND. _cTRANS == '8009'
					cCodigo := '0607'
				CASE cCodigo == '101'  .AND. _cTRANS == '8009'
					cCodigo := '0912'
				CASE cCodigo == '102'  .AND. _cTRANS == '8009'
					cCodigo := '0914'
				CASE cCodigo == '111'  .AND. _cTRANS == '8009'
					cCodigo := '0912'
				CASE cCodigo == '112'  .AND. _cTRANS == '8009'
					cCodigo := '0914'
				CASE cCodigo == '113'  .AND. _cTRANS == '8009'
					cCodigo := '0914'
			ENDCASE
			
			//Classe de Valor 8011
			DO CASE
				CASE cCodigo == '11'   .AND. _cTRANS == '8011'
					cCodigo := '0301'
				CASE cCodigo == '211'  .AND. _cTRANS == '8011'
					cCodigo := '0502'
				CASE cCodigo == '212'  .AND. _cTRANS == '8011'
					cCodigo := '0913'
				CASE cCodigo == '213'  .AND. _cTRANS == '8011'
					cCodigo := '0913'
				CASE cCodigo == '214'  .AND. _cTRANS == '8011'
					cCodigo := '0806'
				CASE cCodigo == '215'  .AND. _cTRANS == '8011'
					cCodigo := '0502'
				CASE cCodigo == '216'  .AND. _cTRANS == '8011'
					cCodigo := '0502'
				CASE cCodigo == '217'  .AND. _cTRANS == '8011'
					cCodigo := '0502'
				CASE cCodigo == '218'  .AND. _cTRANS == '8011'
					cCodigo := '0502'
				CASE cCodigo == '219'  .AND. _cTRANS == '8011'
					cCodigo := '0502'
				CASE cCodigo == '2110' .AND. _cTRANS == '8011'
					cCodigo := '0502'
				CASE cCodigo == '2111' .AND. _cTRANS == '8011'
					cCodigo := '0708'
				CASE cCodigo == '2112' .AND. _cTRANS == '8011'
					cCodigo := '0701'
				CASE cCodigo == '2113' .AND. _cTRANS == '8011'
					cCodigo := '0401'
				CASE cCodigo == '2114' .AND. _cTRANS == '8011'
					cCodigo := '0403'
				CASE cCodigo == '2115' .AND. _cTRANS == '8011'
					cCodigo := '0701'
				CASE cCodigo == '2116' .AND. _cTRANS == '8011'
					cCodigo := '0913'
				CASE cCodigo == '2117' .AND. _cTRANS == '8011'
					cCodigo := '0913'
				CASE cCodigo == '221'  .AND. _cTRANS == '8011'
					cCodigo := '0511'
				CASE cCodigo == '222'  .AND. _cTRANS == '8011'
					cCodigo := '0511'
				CASE cCodigo == '223'  .AND. _cTRANS == '8011'
					cCodigo := '0511'
				CASE cCodigo == '311'  .AND. _cTRANS == '8011'
					cCodigo := '0806'
				CASE cCodigo == '312'  .AND. _cTRANS == '8011'
					cCodigo := '0805'
				CASE cCodigo == '321'  .AND. _cTRANS == '8011'
					cCodigo := '0805'
				CASE cCodigo == '331'  .AND. _cTRANS == '8011'
					cCodigo := '0708'
				CASE cCodigo == '341'  .AND. _cTRANS == '8011'
					cCodigo := '0714'
				CASE cCodigo == '351'  .AND. _cTRANS == '8011'
					cCodigo := '0802'
				CASE cCodigo == '352'  .AND. _cTRANS == '8011'
					cCodigo := '0803'
				CASE cCodigo == '353'  .AND. _cTRANS == '8011'
					cCodigo := '0805'
				CASE cCodigo == '354'  .AND. _cTRANS == '8011'
					cCodigo := '0805'
				CASE cCodigo == '411'  .AND. _cTRANS == '8011'
					cCodigo := '0902'
				CASE cCodigo == '412'  .AND. _cTRANS == '8011'
					cCodigo := '0702'
				CASE cCodigo == '413'  .AND. _cTRANS == '8011'
					cCodigo := '0702'
				CASE cCodigo == '414'  .AND. _cTRANS == '8011'
					cCodigo := '0901'
				CASE cCodigo == '421'  .AND. _cTRANS == '8011'
					cCodigo := '0905'
				CASE cCodigo == '422'  .AND. _cTRANS == '8011'
					cCodigo := '0705'
				CASE cCodigo == '431'  .AND. _cTRANS == '8011'
					cCodigo := '0908'
				CASE cCodigo == '432'  .AND. _cTRANS == '8011'
					cCodigo := '0908'
				CASE cCodigo == '433'  .AND. _cTRANS == '8011'
					cCodigo := '0908'
				CASE cCodigo == '441'  .AND. _cTRANS == '8011'
					cCodigo := '0906'
				CASE cCodigo == '451'  .AND. _cTRANS == '8011'
					cCodigo := '0911'
				CASE cCodigo == '51'   .AND. _cTRANS == '8011'
					cCodigo := '0201'
				CASE cCodigo == '52'   .AND. _cTRANS == '8011'
					cCodigo := '0101'
				CASE cCodigo == '53'   .AND. _cTRANS == '8011'
					cCodigo := '0103'
				CASE cCodigo == '61'   .AND. _cTRANS == '8011'
					cCodigo := '1003'
				CASE cCodigo == '62'   .AND. _cTRANS == '8011'
					cCodigo := '1002'
				CASE cCodigo == '63'   .AND. _cTRANS == '8011'
					cCodigo := '1001'
				CASE cCodigo == '71'   .AND. _cTRANS == '8011'
					cCodigo := '0901'
				CASE cCodigo == '72'   .AND. _cTRANS == '8011'
					cCodigo := '0908'
				CASE cCodigo == '73'   .AND. _cTRANS == '8011'
					cCodigo := '0805'
				CASE cCodigo == '81'   .AND. _cTRANS == '8011'
					cCodigo := '0901'
				CASE cCodigo == '82'   .AND. _cTRANS == '8011'
					cCodigo := '0908'
				CASE cCodigo == '83'   .AND. _cTRANS == '8011'
					cCodigo := '0805'
			ENDCASE
			
			//Classe de Valor 8016
			DO CASE
				CASE cCodigo == '11' .AND. _cTRANS == '8016'
					cCodigo := '0801'
				CASE cCodigo == '12' .AND. _cTRANS == '8016'
					cCodigo := '0805'
				CASE cCodigo == '13' .AND. _cTRANS == '8016'
					cCodigo := '0802'
				CASE cCodigo == '14' .AND. _cTRANS == '8016'
					cCodigo := '0803'
				CASE cCodigo == '15' .AND. _cTRANS == '8016'
					cCodigo := '0804'
				CASE cCodigo == '16' .AND. _cTRANS == '8016'
					cCodigo := '0805'
				CASE cCodigo == '17' .AND. _cTRANS == '8016'
					cCodigo := '0805'
				CASE cCodigo == '18' .AND. _cTRANS == '8016'
					cCodigo := '0901'
				CASE cCodigo == '19' .AND. _cTRANS == '8016'
					cCodigo := '0805'
				CASE cCodigo == '110' .AND. _cTRANS == '8016'
					cCodigo := '0805'
				CASE cCodigo == '111' .AND. _cTRANS == '8016'
					cCodigo := '0805'
				CASE cCodigo == '41' .AND. _cTRANS == '8016'
					cCodigo := '0805'
				CASE cCodigo == '51' .AND. _cTRANS == '8016'
					cCodigo := '0805'
				CASE cCodigo == '61' .AND. _cTRANS == '8016'
					cCodigo := '0901'
				CASE cCodigo == '71' .AND. _cTRANS == '8016'
					cCodigo := '0101'
				CASE cCodigo == '72' .AND. _cTRANS == '8016'
					cCodigo := '0201'
				CASE cCodigo == '73' .AND. _cTRANS == '8016'
					cCodigo := '0201'
				CASE cCodigo == '74' .AND. _cTRANS == '8016'
					cCodigo := '0203'
				CASE cCodigo == '81' .AND. _cTRANS == '8016'
					cCodigo := '0714'
				CASE cCodigo == '91' .AND. _cTRANS == '8016'
					cCodigo := '0912'
				CASE cCodigo == '92' .AND. _cTRANS == '8016'
					cCodigo := '0911'
			ENDCASE
			
			//Classe de Valor 8017
			DO CASE
				CASE cCodigo == '11' .AND. _cTRANS == '8017'
					cCodigo := '0101'
				CASE cCodigo == '12' .AND. _cTRANS == '8017'
					cCodigo := '0201'
				CASE cCodigo == '13' .AND. _cTRANS == '8017'
					cCodigo := '0106'
				CASE cCodigo == '21' .AND. _cTRANS == '8017'
					cCodigo := '0805'
				CASE cCodigo == '22' .AND. _cTRANS == '8017'
					cCodigo := '0805'
				CASE cCodigo == '23' .AND. _cTRANS == '8017'
					cCodigo := '0807'
				CASE cCodigo == '24' .AND. _cTRANS == '8017'
					cCodigo := '0805'
				CASE cCodigo == '31' .AND. _cTRANS == '8017'
					cCodigo := '0701'
				CASE cCodigo == '32' .AND. _cTRANS == '8017'
					cCodigo := '0912'
				CASE cCodigo == '33' .AND. _cTRANS == '8017'
					cCodigo := '0911'
				CASE cCodigo == '34' .AND. _cTRANS == '8017'
					cCodigo := '0906'
				CASE cCodigo == '35' .AND. _cTRANS == '8017'
					cCodigo := '0910'
				CASE cCodigo == '36' .AND. _cTRANS == '8017'
					cCodigo := '0905'
				CASE cCodigo == '41' .AND. _cTRANS == '8017'
					cCodigo := '0714'
				CASE cCodigo == '42' .AND. _cTRANS == '8017'
					cCodigo := '0712'
				CASE cCodigo == '43' .AND. _cTRANS == '8017'
					cCodigo := '0714'
				CASE cCodigo == '44' .AND. _cTRANS == '8017'
					cCodigo := '0714'
			ENDCASE
			
			//Classe de Valor 8018
			DO CASE
				CASE cCodigo == '111' .AND. _cTRANS == '8018'
					cCodigo := '0505'
				CASE cCodigo == '122' .AND. _cTRANS == '8018'
					cCodigo := '0913'
				CASE cCodigo == '113' .AND. _cTRANS == '8018'
					cCodigo := '0913'
				CASE cCodigo == '114' .AND. _cTRANS == '8018'
					cCodigo := '0505'
				CASE cCodigo == '115' .AND. _cTRANS == '8018'
					cCodigo := '0505'
				CASE cCodigo == '116' .AND. _cTRANS == '8018'
					cCodigo := '0505'
				CASE cCodigo == '117' .AND. _cTRANS == '8018'
					cCodigo := '0505'
				CASE cCodigo == '118' .AND. _cTRANS == '8018'
					cCodigo := '0505'
				CASE cCodigo == '119' .AND. _cTRANS == '8018'
					cCodigo := '0401'
				CASE cCodigo == '1110' .AND. _cTRANS == '8018'
					cCodigo := '0403'
				CASE cCodigo == '1111' .AND. _cTRANS == '8018'
					cCodigo := '0901'
				CASE cCodigo == '211' .AND. _cTRANS == '8018'
					cCodigo := '0806'
				CASE cCodigo == '212' .AND. _cTRANS == '8018'
					cCodigo := '0805'
				CASE cCodigo == '311' .AND. _cTRANS == '8018'
					cCodigo := '0901'
				CASE cCodigo == '312' .AND. _cTRANS == '8018'
					cCodigo := '0701'
				CASE cCodigo == '331' .AND. _cTRANS == '8018'
					cCodigo := '0708'
				CASE cCodigo == '341' .AND. _cTRANS == '8018'
					cCodigo := '0913'
				CASE cCodigo == '41' .AND. _cTRANS == '8018'
					cCodigo := '0201'
				CASE cCodigo == '42' .AND. _cTRANS == '8018'
					cCodigo := '0101'
				CASE cCodigo == '43' .AND. _cTRANS == '8018'
					cCodigo := '0106'
				CASE cCodigo == '51' .AND. _cTRANS == '8018'
					cCodigo := '1003'
				CASE cCodigo == '52' .AND. _cTRANS == '8018'
					cCodigo := '1002'
				CASE cCodigo == '53' .AND. _cTRANS == '8018'
					cCodigo := '1001'
				CASE cCodigo == '61' .AND. _cTRANS == '8018'
					cCodigo := '0901'
				CASE cCodigo == '62' .AND. _cTRANS == '8018'
					cCodigo := '0801'
				CASE cCodigo == '63' .AND. _cTRANS == '8018'
					cCodigo := '0805'
				CASE cCodigo == '605' .AND. _cTRANS == '8018'
					cCodigo := '0605'
			ENDCASE
			
			//Classe de Valor 8019
			DO CASE
				CASE cCodigo == '11' .AND. _cTRANS == '8019'
					cCodigo := '0101'
				CASE cCodigo == '12' .AND. _cTRANS == '8019'
					cCodigo := '0106'
				CASE cCodigo == '13' .AND. _cTRANS == '8019'
					cCodigo := '0203'
				CASE cCodigo == '14' .AND. _cTRANS == '8019'
					cCodigo := '0201'
				CASE cCodigo == '15' .AND. _cTRANS == '8019'
					cCodigo := '0202'
				CASE cCodigo == '16' .AND. _cTRANS == '8019'
					cCodigo := '0204'
				CASE cCodigo == '17' .AND. _cTRANS == '8019'
					cCodigo := '0102'
				CASE cCodigo == '21' .AND. _cTRANS == '8019'
					cCodigo := '1003'
				CASE cCodigo == '22' .AND. _cTRANS == '8019'
					cCodigo := '1002'
				CASE cCodigo == '23' .AND. _cTRANS == '8019'
					cCodigo := '1001'
				CASE cCodigo == '24' .AND. _cTRANS == '8019'
					cCodigo := '1003'
				CASE cCodigo == '25' .AND. _cTRANS == '8019'
					cCodigo := '1005'
				CASE cCodigo == '26' .AND. _cTRANS == '8019'
					cCodigo := '1005'
				CASE cCodigo == '27' .AND. _cTRANS == '8019'
					cCodigo := '0404'
				CASE cCodigo == '31' .AND. _cTRANS == '8019'
					cCodigo := '0713'
				CASE cCodigo == '32' .AND. _cTRANS == '8019'
					cCodigo := '0602'
				CASE cCodigo == '33' .AND. _cTRANS == '8019'
					cCodigo := '0713'
				CASE cCodigo == '34' .AND. _cTRANS == '8019'
					cCodigo := '0913'
				CASE cCodigo == '35' .AND. _cTRANS == '8019'
					cCodigo := '0701'
				CASE cCodigo == '36' .AND. _cTRANS == '8019'
					cCodigo := '0702'
				CASE cCodigo == '37' .AND. _cTRANS == '8019'
					cCodigo := '0702'
				CASE cCodigo == '38' .AND. _cTRANS == '8019'
					cCodigo := '0401'
				CASE cCodigo == '39' .AND. _cTRANS == '8019'
					cCodigo := '0402'
				CASE cCodigo == '310'.AND. _cTRANS == '8019'
					cCodigo := '0403'
				CASE cCodigo == '41' .AND. _cTRANS == '8019'
					cCodigo := '0805'
				CASE cCodigo == '42' .AND. _cTRANS == '8019'
					cCodigo := '0913'
				CASE cCodigo == '43' .AND. _cTRANS == '8019'
					cCodigo := '0913'
				CASE cCodigo == '44' .AND. _cTRANS == '8019'
					cCodigo := '0907'
				CASE cCodigo == '45' .AND. _cTRANS == '8019'
					cCodigo := '0901'
				CASE cCodigo == '46' .AND. _cTRANS == '8019'
					cCodigo := '0902'
				CASE cCodigo == '47' .AND. _cTRANS == '8019'
					cCodigo := '0901'
				CASE cCodigo == '48' .AND. _cTRANS == '8019'
					cCodigo := '0901'
			ENDCASE
			
			//Classe de Valor 8022
			DO CASE
				CASE cCodigo == '11' .AND. _cTRANS == '8022'
					cCodigo := '0101'
				CASE cCodigo == '12' .AND. _cTRANS == '8022'
					cCodigo := '0106'
				CASE cCodigo == '13' .AND. _cTRANS == '8022'
					cCodigo := '0201'
				CASE cCodigo == '14' .AND. _cTRANS == '8022'
					cCodigo := '0202'
				CASE cCodigo == '15' .AND. _cTRANS == '8022'
					cCodigo := '0204'
				CASE cCodigo == '16' .AND. _cTRANS == '8022'
					cCodigo := '0102'
				CASE cCodigo == '21' .AND. _cTRANS == '8022'
					cCodigo := '1003'
				CASE cCodigo == '22' .AND. _cTRANS == '8022'
					cCodigo := '1002'
				CASE cCodigo == '23' .AND. _cTRANS == '8022'
					cCodigo := '1001'
				CASE cCodigo == '24' .AND. _cTRANS == '8022'
					cCodigo := '1003'
				CASE cCodigo == '25' .AND. _cTRANS == '8022'
					cCodigo := '1005'
				CASE cCodigo == '26' .AND. _cTRANS == '8022'
					cCodigo := '0404'
				CASE cCodigo == '31' .AND. _cTRANS == '8022'
					cCodigo := '0602'
				CASE cCodigo == '32' .AND. _cTRANS == '8022'
					cCodigo := '0602'
				CASE cCodigo == '33' .AND. _cTRANS == '8022'
					cCodigo := '0502'
				CASE cCodigo == '34' .AND. _cTRANS == '8022'
					cCodigo := '0502'
				CASE cCodigo == '35' .AND. _cTRANS == '8022'
					cCodigo := '0502'
				CASE cCodigo == '36' .AND. _cTRANS == '8022'
					cCodigo := '0502'
				CASE cCodigo == '37' .AND. _cTRANS == '8022'
					cCodigo := '0702'
				CASE cCodigo == '38' .AND. _cTRANS == '8022'
					cCodigo := '0701'
				CASE cCodigo == '39' .AND. _cTRANS == '8022'
					cCodigo := '0401'
				CASE cCodigo == '310'.AND. _cTRANS == '8022'
					cCodigo := '0402'
				CASE cCodigo == '311'.AND. _cTRANS == '8022'
					cCodigo := '0403'
				CASE cCodigo == '312'.AND. _cTRANS == '8022'
					cCodigo := '0704'
				CASE cCodigo == '41' .AND. _cTRANS == '8022'
					cCodigo := '0801'
				CASE cCodigo == '42' .AND. _cTRANS == '8022'
					cCodigo := '0802'
				CASE cCodigo == '43' .AND. _cTRANS == '8022'
					cCodigo := '0803'
				CASE cCodigo == '44' .AND. _cTRANS == '8022'
					cCodigo := '0804'
				CASE cCodigo == '45' .AND. _cTRANS == '8022'
					cCodigo := '0807'
				CASE cCodigo == '46' .AND. _cTRANS == '8022'
					cCodigo := '0805'
				CASE cCodigo == '47' .AND. _cTRANS == '8022'
					cCodigo := '0806'
				CASE cCodigo == '48' .AND. _cTRANS == '8022'
					cCodigo := '0906'
				CASE cCodigo == '49' .AND. _cTRANS == '8022'
					cCodigo := '0913'
				CASE cCodigo == '410'.AND. _cTRANS == '8022'
					cCodigo := '0913'
				CASE cCodigo == '411'.AND. _cTRANS == '8022'
					cCodigo := '0908'
				CASE cCodigo == '412'.AND. _cTRANS == '8022'
					cCodigo := '0901'
				CASE cCodigo == '413'.AND. _cTRANS == '8022'
					cCodigo := '0902'
				CASE cCodigo == '414'.AND. _cTRANS == '8022'
					cCodigo := '0901'
			ENDCASE
			
			//Classe de Valor 8023
			DO CASE
				CASE cCodigo == '11' .AND. _cTRANS == '8023'
					cCodigo := '0201'
				CASE cCodigo == '12' .AND. _cTRANS == '8023'
					cCodigo := '0204'
				CASE cCodigo == '21' .AND. _cTRANS == '8023'
					cCodigo := '1002'
				CASE cCodigo == '22' .AND. _cTRANS == '8023'
					cCodigo := '1003'
				CASE cCodigo == '23' .AND. _cTRANS == '8023'
					cCodigo := '1005'
				CASE cCodigo == '24' .AND. _cTRANS == '8023'
					cCodigo := '0404'
				CASE cCodigo == '25' .AND. _cTRANS == '8023'
					cCodigo := '0608'
				CASE cCodigo == '31' .AND. _cTRANS == '8023'
					cCodigo := '0608'
				CASE cCodigo == '32' .AND. _cTRANS == '8023'
					cCodigo := '0401'
				CASE cCodigo == '33' .AND. _cTRANS == '8023'
					cCodigo := '0402'
				CASE cCodigo == '34' .AND. _cTRANS == '8023'
					cCodigo := '0403'
				CASE cCodigo == '41' .AND. _cTRANS == '8023'
					cCodigo := '0805'
				CASE cCodigo == '42' .AND. _cTRANS == '8023'
					cCodigo := '0913'
				CASE cCodigo == '43' .AND. _cTRANS == '8023'
					cCodigo := '0905'
				CASE cCodigo == '44' .AND. _cTRANS == '8023'
					cCodigo := '0901'
				CASE cCodigo == '45' .AND. _cTRANS == '8023'
					cCodigo := '0806'
			ENDCASE
			
			//Classe de Valor 8024
			DO CASE
				CASE cCodigo == '11' .AND. _cTRANS == '8024'
					cCodigo := '0101'
				CASE cCodigo == '12' .AND. _cTRANS == '8024'
					cCodigo := '0201'
				CASE cCodigo == '21' .AND. _cTRANS == '8024'
					cCodigo := '0805'
				CASE cCodigo == '22' .AND. _cTRANS == '8024'
					cCodigo := '0805'
			ENDCASE
			
			//Classe de Valor 8025
			DO CASE
				CASE cCodigo == '11' .AND. _cTRANS == '8025'
					cCodigo := '0201'
				CASE cCodigo == '21' .AND. _cTRANS == '8025'
					cCodigo := '0805'
				CASE cCodigo == '22' .AND. _cTRANS == '8025'
					cCodigo := '0901'
			ENDCASE
		ELSE
			IF LEN(ALLTRIM(cCodigo)) <= 3
				cCodigo := '0'+ALLTRIM(cCodigo)
			ELSE
				cCodigo := ALLTRIM(cCodigo)
			ENDIF
		ENDIF
		
		IF MV_PAR04 == 1
			DbSelectArea("CTP")
			DbSetOrder(1)
			IF DbSeek(xFilial("CTP")+DTOS(dDataMov)+"04")
				nFator := CTP->CTP_TAXA
			ELSE
				nFator := 1.00
				IF DTOS(dDataMov) >= '20080101'
					MsgBox("Taxa nao encontrada na data: "+SUBSTR(DTOS(dDataMov),7,2)+"/"+SUBSTR(DTOS(dDataMov),5,2)+"/"+SUBSTR(DTOS(dDataMov),3,2)+" para Classe: "+_cTRANS,"STOP")
				ENDIF
			ENDIF
		ELSE
			nFator := 1.00
		ENDIF
		
		DbSelectArea("CTD")
		DbSetOrder(1)
		DbSeek(xFilial("CTD")+cCodigo)
		
		DbSelectArea("_aP1A")
		RecLock("_aP1A",.T.)
		_aP1A->CODIGO   := cCodigo
		_aP1A->CLVL     := _cTRANS
		_aP1A->DESC     := CTD->CTD_DESC01
		_aP1A->FORNECE  := cFornece
		_aP1A->PRODUTO  := cProd
		_aP1A->DTMOV    := dDataMov
		_aP1A->VALOR    := 0
		_aP1A->VLPAGO   := 0
		
		IF AT('.', cValor) > 0
			nPonto := AT('.', cValor)
			_aP1A->VALOR  := _aP1A->VALOR  + ((VAL(Substr(cValor,1,nPonto-1))*1000)/nFator)
			_aP1A->VLPAGO := _aP1A->VLPAGO + ((VAL(Substr(cValor,1,nPonto-1))*1000)/nFator)
		ELSE
			nPonto := 0
		ENDIF
		IF AT(',', cValor) > 0
			nVirg := AT(',', cValor)
			_aP1A->VALOR  := _aP1A->VALOR  + (VAL(Substr(cValor,nVirg-3,3))/nFator) + (VAL(RTRIM(Substr(cValor,nVirg+1,2)))/100/nFator)
			_aP1A->VLPAGO := _aP1A->VLPAGO + (VAL(Substr(cValor,nVirg-3,3))/nFator) + (VAL(RTRIM(Substr(cValor,nVirg+1,2)))/100/nFator)
		ELSE
			nVirg := 0
			_aP1A->VALOR  := _aP1A->VALOR  + (VAL(cValor)/nFator)
			_aP1A->VLPAGO := _aP1A->VLPAGO + (VAL(cValor)/nFator)
		ENDIF
		MsUnLock()
		nValor := nValor + _aP1A->VALOR
		
		DbSelectArea("_aP1C")
		RecLock("_aP1C",.T.)
		_aP1C->CODIGO   := _aP1A->CODIGO
		_aP1C->CLVL     := _aP1A->CLVL
		_aP1C->DESC     := _aP1A->DESC
		_aP1C->FORNECE  := _aP1A->FORNECE
		_aP1C->PRODUTO  := _aP1A->PRODUTO
		_aP1C->DTMOV    := _aP1A->DTMOV
		_aP1C->VALOR    := _aP1A->VALOR
		_aP1C->VLPAGO   := _aP1A->VLPAGO
		MsUnLock()
		
		DbSelectArea("CTD")
		DbSetOrder(1)
		DbSeek(xFilial("CTD")+SUBSTR(cCodigo,1,2))
		
		IF ALLTRIM(cCodigo) <> '0405'
			DbSelectArea("_aP2A")
			IF !DbSeek(_cTRANS+SPACE(5)+SUBSTR(cCodigo,1,2))
				RecLock("_aP2A",.T.)
				_aP2A->CODIGO   := SUBSTR(cCodigo,1,2)
				_aP2A->CLVL     := _cTRANS
				_aP2A->DESC     := CTD->CTD_DESC01
				_aP2A->VALOR    := _aP1A->VALOR
				_aP2A->VLPAGO   := _aP1A->VALOR
			ELSE
				RecLock("_aP2A",.F.)
				_aP2A->VALOR    := _aP2A->VALOR  + _aP1A->VALOR
				_aP2A->VLPAGO   := _aP2A->VLPAGO + _aP1A->VLPAGO
			ENDIF
			MsUnLock()
		ENDIF
		
		IF ALLTRIM(cCodigo) <> '0405'
			DbSelectArea("_aP2C")
			IF !DbSeek(_cTRANS+SPACE(5)+SUBSTR(cCodigo,1,2))
				RecLock("_aP2C",.T.)
				_aP2C->CODIGO   := SUBSTR(cCodigo,1,2)
				_aP2C->CLVL     := _cTRANS
				_aP2C->DESC     := CTD->CTD_DESC01
				_aP2C->VALOR    := _aP1A->VALOR
				_aP2C->VLPAGO   := _aP1A->VLPAGO
			ELSE
				RecLock("_aP2C",.F.)
				_aP2C->VALOR    := _aP2C->VALOR  + _aP1A->VALOR
				_aP2C->VLPAGO   := _aP2C->VLPAGO + _aP1A->VLPAGO
			ENDIF
			MsUnLock()
		ENDIF
	ENDIF
END

If .Not. fClose(_nhdl)
	MsgAlert("Erro fechamento do arquivo "+_cIMPORT,)
	Return
EndIf

DbCommitall()

RETURN

Static Function Contabil()
A00 := " SELECT CT2_CLVLDB, CT2_CLVLCR, CT2_ITEMD, CT2_ITEMC, CT2_HIST, CT2_VALOR, CT2_DATA, CT2_KEY, CT2_LOTE, CT2_ORIGEM, '01' AS TIPO "
A00 += " FROM CT2010 CT2 "
A00 += " WHERE CT2_FILIAL = '"+xFilial("CT2")+"' "
A00 += " AND CT2_DATA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "
A00 += " AND ((CT2_CLVLDB BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"') OR (CT2_CLVLCR BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"')) " 
A00 += " AND ((CT2_ITEMD  BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"') OR (CT2_ITEMC  BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"')) "
A00 += " AND ((CT2_ITEMC <> ' ' AND CT2_ITEMC < 'I0000') OR (CT2_ITEMD <> ' ' AND CT2_ITEMD < 'I0000')) "
A00 += " AND (CT2_ITEMC NOT IN ('9000','8001') AND CT2_ITEMD NOT IN ('9000','8001')) "
A00 += " AND (CT2_ORIGEM <> 'A35001' ) "
A00 += " AND D_E_L_E_T_ = ' '  "
A00 += " AND (CT2_LOTE <> '000060' AND CT2_LOTE <> '888888') "
A00 += " UNION ALL "
A00 += " SELECT CT2_CLVLDB, CT2_CLVLCR, CT2_ITEMD, CT2_ITEMC, CT2_HIST, CT2_VALOR, CT2_DATA, CT2_KEY, CT2_LOTE, CT2_ORIGEM, '05' AS TIPO "
A00 += " FROM CT2050 CT2 "
A00 += " WHERE CT2_FILIAL = '"+xFilial("CT2")+"' "
A00 += " AND CT2_DATA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "
A00 += " AND ((CT2_CLVLDB BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"') OR (CT2_CLVLCR BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"')) "
A00 += " AND ((CT2_ITEMD  BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"') OR (CT2_ITEMC  BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"')) "
A00 += " AND ((CT2_ITEMC <> ' ' AND CT2_ITEMC < 'I0000') OR (CT2_ITEMD <> ' ' AND CT2_ITEMD < 'I0000')) "
A00 += " AND (CT2_ITEMC NOT IN ('9000','8001') AND CT2_ITEMD NOT IN ('9000','8001')) "
A00 += " AND (CT2_ORIGEM <> 'A35001' ) "
A00 += " AND D_E_L_E_T_ = ' '  "
A00 += " AND (CT2_LOTE <> '000060' AND CT2_LOTE <> '888888') "
A00 += " UNION ALL "
A00 += " SELECT CT2_CLVLDB, CT2_CLVLCR, CT2_ITEMD, CT2_ITEMC, CT2_HIST, CT2_VALOR, CT2_DATA, CT2_KEY, CT2_LOTE, CT2_ORIGEM, '06' AS TIPO "
A00 += " FROM CT2060 CT2 "
A00 += " WHERE CT2_FILIAL = '"+xFilial("CT2")+"' "
A00 += " AND CT2_DATA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "
A00 += " AND ((CT2_CLVLDB BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"') OR (CT2_CLVLCR BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"')) "
A00 += " AND ((CT2_ITEMD  BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"') OR (CT2_ITEMC  BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"')) "
A00 += " AND ((CT2_ITEMC <> ' ' AND CT2_ITEMC < 'I0000') OR (CT2_ITEMD <> ' ' AND CT2_ITEMD < 'I0000')) "
A00 += " AND (CT2_ITEMC NOT IN ('9000','8001') AND CT2_ITEMD NOT IN ('9000','8001')) "
A00 += " AND (CT2_ORIGEM <> 'A35001' ) "
A00 += " AND D_E_L_E_T_ = ' '  "
A00 += " AND (CT2_LOTE <> '000060' AND CT2_LOTE <> '888888') "
A00 += " UNION ALL "
A00 += " SELECT CT2_CLVLDB, CT2_CLVLCR, CT2_ITEMD, CT2_ITEMC, CT2_HIST, CT2_VALOR, CT2_DATA, CT2_KEY, CT2_LOTE, CT2_ORIGEM, '12' AS TIPO "
A00 += " FROM CT2120 CT2 "
A00 += " WHERE CT2_FILIAL = '"+xFilial("CT2")+"' "
A00 += " AND CT2_DATA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "
A00 += " AND ((CT2_CLVLDB BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"') OR (CT2_CLVLCR BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"')) "
A00 += " AND ((CT2_ITEMD  BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"') OR (CT2_ITEMC  BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"')) "
A00 += " AND ((CT2_ITEMC <> ' ' AND CT2_ITEMC < 'I0000') OR (CT2_ITEMD <> ' ' AND CT2_ITEMD < 'I0000')) "
A00 += " AND (CT2_ITEMC NOT IN ('9000','8001') AND CT2_ITEMD NOT IN ('9000','8001')) "
A00 += " AND (CT2_ORIGEM <> 'A35001' ) "
A00 += " AND D_E_L_E_T_ = ' '  "
A00 += " AND (CT2_LOTE <> '000060' AND CT2_LOTE <> '888888') "
A00 += " UNION ALL "
A00 += " SELECT CT2_CLVLDB, CT2_CLVLCR, CT2_ITEMD, CT2_ITEMC, CT2_HIST, CT2_VALOR, CT2_DATA, CT2_KEY, CT2_LOTE, CT2_ORIGEM, '13' AS TIPO "
A00 += " FROM CT2130 CT2 "
A00 += " WHERE CT2_FILIAL = '"+xFilial("CT2")+"' "
A00 += " AND CT2_DATA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "
A00 += " AND ((CT2_CLVLDB BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"') OR (CT2_CLVLCR BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"')) "
A00 += " AND ((CT2_ITEMD  BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"') OR (CT2_ITEMC  BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"')) "
A00 += " AND ((CT2_ITEMC <> ' ' AND CT2_ITEMC < 'I0000') OR (CT2_ITEMD <> ' ' AND CT2_ITEMD < 'I0000')) "
A00 += " AND (CT2_ITEMC NOT IN ('9000','8001') AND CT2_ITEMD NOT IN ('9000','8001')) "
A00 += " AND (CT2_ORIGEM <> 'A35001' ) "
A00 += " AND D_E_L_E_T_ = ' '  "
A00 += " AND (CT2_LOTE <> '000060' AND CT2_LOTE <> '888888') "
A00 += " ORDER BY CT2_CLVLDB, CT2_CLVLCR, CT2_ITEMD, CT2_ITEMC "

If chkfile("A00")
	DbSelectArea("A00")
	DbCloseArea()
EndIf
TcQuery A00 New Alias "A00"

DbSelectArea("A00")
DbGoTop()
ProcRegua(RecCount())

While !Eof()
	cTempo := Alltrim(ElapTime(cHInicio, Time()))
	IncProc("Atualizando....    Tempo: "+cTempo)
	
	nVlPago := A00->CT2_VALOR
	cDesc   := ''
	cNome   := ''
	IF SUBSTR(A00->CT2_KEY,3,1) <> ' '
		
		DO CASE
			//Tratar Requisição e Devolução
			CASE SUBSTR(A00->CT2_ORIGEM,1,6) $ '666001/668001'
				DbSelectArea("SB1")
				DbSetOrder(1)
				IF A00->CT2_DATA >= '20100208'
					DbSeek(xFilial("SB1")+SUBSTR(A00->CT2_KEY,12,15))
				ELSE
					DbSeek(xFilial("SB1")+SUBSTR(A00->CT2_KEY,9,15))
				ENDIF
				cDesc := SB1->B1_DESC
				
				DbSelectArea("SD3")
				DbSetOrder(2)
				IF A00->CT2_DATA >= '20100208'
					DbSeek(xFilial("SD3")+SUBSTR(A00->CT2_KEY,3,9)+SUBSTR(A00->CT2_KEY,12,15))
				ELSE
					DbSeek(xFilial("SD3")+SUBSTR(A00->CT2_KEY,3,6)+SUBSTR(A00->CT2_KEY,9,15))
				ENDIF
				
				DbSelectArea("ZZY")
				DbSetOrder(3)
				DbSeek(xFilial("ZZY")+SD3->D3_YMATRIC)
				cNome := ZZY->ZZY_NOME
				
				//Tratar RA
			CASE SUBSTR(A00->CT2_ORIGEM,1,6) $ '501001'
				A00A := " SELECT SUM(E1_VALOR) AS TOTAL "
				DO CASE
					CASE A00->TIPO == '01'
						A00A += " FROM SE1010 SE1 "
					CASE A00->TIPO == '05'
						A00A += " FROM SE1050 SE1 "
					CASE A00->TIPO == '06'
						A00A += " FROM SE1060 SE1 "
					CASE A00->TIPO == '12'
						A00A += " FROM SE1120 SE1 "
					CASE A00->TIPO == '13'
						A00A += " FROM SE1130 SE1 "
				ENDCASE
				A00A += " WHERE E1_EMISSAO = '"+A00->CT2_DATA+"' "
				IF A00->CT2_DATA >= '20100208'
					A00A += " AND E1_FILIAL+E1_NATUREZ+E1_NOMCLI+E1_PREFIXO+E1_NUM+E1_TIPO = SUBSTRING('"+A00->CT2_KEY+"',1,47) "
				ELSE
					A00A += " AND E1_FILIAL+E1_NATUREZ+E1_NOMCLI+E1_PREFIXO+E1_NUM+E1_TIPO = SUBSTRING('"+A00->CT2_KEY+"',1,44) "
				ENDIF
				A00A += " AND D_E_L_E_T_ = ' ' "
				
				//Tratar Compensação do NCC
			CASE SUBSTR(A00->CT2_ORIGEM,1,6) $ '597001'
				A00A := " SELECT SUM(E5_VALOR) AS TOTAL "
				DO CASE
					CASE A00->TIPO == '01'
						A00A += " FROM SE5010 SE1 "
					CASE A00->TIPO == '05'
						A00A += " FROM SE5050 SE1 "
					CASE A00->TIPO == '06'
						A00A += " FROM SE5060 SE1 "
					CASE A00->TIPO == '12'
						A00A += " FROM SE5120 SE1 "
					CASE A00->TIPO == '13'
						A00A += " FROM SE5130 SE1 "
				ENDCASE
				A00A += " WHERE E5_DATA = '"+A00->CT2_DATA+"' "
				IF A00->CT2_DATA >= '20100208'
					A00A += " AND E5_FILIAL+E5_TIPODOC+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_DATA = SUBSTRING('"+A00->CT2_KEY+"',1,28) "
				ELSE
					A00A += " AND E5_FILIAL+E5_TIPODOC+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_DATA = SUBSTRING('"+A00->CT2_KEY+"',1,25) "
				ENDIF
				A00A += " AND E5_VALOR   = '"+ALLTRIM(STR(A00->CT2_VALOR))+" ' "
				A00A += " AND D_E_L_E_T_ = ' ' "
				
				//Tratar Devolucoes
			CASE SUBSTR(A00->CT2_ORIGEM,1,6) $ '655001'
				A00A := " SELECT SUM(D1_TOTAL+D1_VALIPI+D1_VALFRE-D1_VALDESC+D1_DESPESA) AS TOTAL "
				DO CASE
					CASE A00->TIPO == '01'
						A00A += " FROM SD1010 SD1 "
					CASE A00->TIPO == '05'
						A00A += " FROM SD1050 SD1 "
					CASE A00->TIPO == '06'
						A00A += " FROM SD1060 SD1 "
					CASE A00->TIPO == '12'
						A00A += " FROM SD1120 SD1 "
					CASE A00->TIPO == '13'
						A00A += " FROM SD1130 SD1 "
				ENDCASE
				A00A += " WHERE D1_DTDIGIT = '"+A00->CT2_DATA+"' "
				IF A00->CT2_DATA >= '20100208'
					A00A += " AND D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA = SUBSTRING('"+A00->CT2_KEY+"',1,22) "
				ELSE
					A00A += " AND D1_FILIAL+D1_DOC+D1_SERIE+D1_CLIENTE+D1_LOJA = SUBSTRING('"+A00->CT2_KEY+"',1,19) "
				ENDIF
				IF !Empty(A00->CT2_ITEMD) //.OR. !Empty(A00->CT2_ITEMC)
					A00A += " AND D1_CLVL      = '"+A00->CT2_CLVLDB+"' "
					A00A += " AND D1_ITEMCTA   = '"+A00->CT2_ITEMD+"' "
				ELSE
					A00A += " AND D1_CLVL      = '"+A00->CT2_CLVLCR+"' "
					A00A += " AND D1_ITEMCTA   = '"+A00->CT2_ITEMC+"' "
				ENDIF
				A00A += " AND D_E_L_E_T_ = ' ' "
				
				DbSelectArea("SA2")
				DbSetOrder(1)
				IF A00->CT2_DATA >= '20100208'
					DbSeek(xFilial("SA2")+SUBSTR(A00->CT2_KEY,15,8))
				ELSE
					DbSeek(xFilial("SA2")+SUBSTR(A00->CT2_KEY,12,8))
				ENDIF
				cNome := SA2->A2_NOME
				
				DbSelectArea("SB1")
				DbSetOrder(1)
				IF A00->CT2_DATA >= '20100208'
					DbSeek(xFilial("SB1")+SUBSTR(A00->CT2_KEY,23,15))
				ELSE
					DbSeek(xFilial("SB1")+SUBSTR(A00->CT2_KEY,20,15))
				ENDIF
				cDesc := SB1->B1_DESC
				
				//Tratar Compras
			CASE !Empty(A00->CT2_ITEMD) .OR. !Empty(A00->CT2_ITEMC)
				A00A := " SELECT SUM(D1_TOTAL+D1_VALIPI+D1_VALFRE-D1_VALDESC+D1_DESPESA) AS TOTAL "
				DO CASE
					CASE A00->TIPO == '01'
						A00A += " FROM SD1010 SD1 "
					CASE A00->TIPO == '05'
						A00A += " FROM SD1050 SD1 "
					CASE A00->TIPO == '06'
						A00A += " FROM SD1060 SD1 "
					CASE A00->TIPO == '12'
						A00A += " FROM SD1120 SD1 "
					CASE A00->TIPO == '13'
						A00A += " FROM SD1130 SD1 "
				ENDCASE
				A00A += " WHERE D1_DTDIGIT = '"+A00->CT2_DATA+"' "
				IF A00->CT2_DATA >= '20100208'
					//A00A += " AND D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM = SUBSTRING('"+A00->CT2_KEY+"',1,41) "
					A00A += " AND D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA = SUBSTRING('"+A00->CT2_KEY+"',1,22) "
				ELSE
					//A00A += " AND D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM = SUBSTRING('"+A00->CT2_KEY+"',1,38) "
					A00A += " AND D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA = SUBSTRING('"+A00->CT2_KEY+"',1,19) "
				ENDIF
				IF !Empty(A00->CT2_ITEMD)
					A00A += " AND D1_CLVL      = '"+A00->CT2_CLVLDB+"' "
					A00A += " AND D1_ITEMCTA   = '"+A00->CT2_ITEMD+"' "
				ELSE
					A00A += " AND D1_CLVL      = '"+A00->CT2_CLVLCR+"' "
					A00A += " AND D1_ITEMCTA   = '"+A00->CT2_ITEMC+"' "
				ENDIF
				A00A += " AND D_E_L_E_T_ = ' ' "
				
				DbSelectArea("SA2")
				DbSetOrder(1)
				IF A00->CT2_DATA >= '20100208'
					DbSeek(xFilial("SA2")+SUBSTR(A00->CT2_KEY,15,8))
				ELSE
					DbSeek(xFilial("SA2")+SUBSTR(A00->CT2_KEY,12,8))
				ENDIF
				cNome := SA2->A2_NOME
				
				DbSelectArea("SB1")
				DbSetOrder(1)
				IF A00->CT2_DATA >= '20100208'
					DbSeek(xFilial("SB1")+SUBSTR(A00->CT2_KEY,23,15))
				ELSE
					DbSeek(xFilial("SB1")+SUBSTR(A00->CT2_KEY,20,15))
				ENDIF
				cDesc := SB1->B1_DESC
				
			OTHERWISE
				A00A := " SELECT SUM(D2_TOTAL) AS TOTAL "
				DO CASE
					CASE A00->TIPO == '01'
						A00A += " FROM SD2010 SD2 "
					CASE A00->TIPO == '05'
						A00A += " FROM SD2050 SD2 "
					CASE A00->TIPO == '06'
						A00A += " FROM SD2060 SD2 "
					CASE A00->TIPO == '12'
						A00A += " FROM SD2120 SD2 "
					CASE A00->TIPO == '13'
						A00A += " FROM SD2130 SD2 "
				ENDCASE
				A00A += " WHERE D2_EMISSAO = '"+A00->CT2_DATA+"' "
				IF A00->CT2_DATA >= '20100208'
					A00A += " AND D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA = SUBSTRING('"+A00->CT2_KEY+"',1,22) "
				ELSE
					A00A += " AND D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA = SUBSTRING('"+A00->CT2_KEY+"',1,19) "
				ENDIF
				A00A += " AND D_E_L_E_T_ = ' ' "
		ENDCASE
		
		IF !SUBSTR(A00->CT2_ORIGEM,1,6) $ '666001/668001'
			If chkfile("A00A")
				DbSelectArea("A00A")
				DbCloseArea()
			EndIf
			TcQuery A00A New Alias "A00A"
			
			nVlPago := A00A->TOTAL
		ENDIF
		
	ELSE
		cNome := A00->CT2_HIST
		cDesc := "VER NA CONTABILIDADE"
	ENDIF
	
	IF MV_PAR04 == 1
		DbSelectArea("CTP")
		DbSetOrder(1)
		IF DbSeek(xFilial("CTP")+A00->CT2_DATA+"04")
			nFator := CTP->CTP_TAXA
		ELSE
			nFator := 1.00
			IF DTOS(dDataMov) >= '20080101'
				MsgBox("Taxa nao encontrada na data: "+SUBSTR(A00->CT2_DATA,7,2)+"/"+SUBSTR(A00->CT2_DATA,5,2)+"/"+SUBSTR(A00->CT2_DATA,3,2)+" para Classe: "+A00->CT2_CLVLDB,"STOP")
			ENDIF
		ENDIF
	ELSE
		nFator := 1.00
	ENDIF
	
	IF nVlPago < A00->CT2_VALOR
		nVlPago := A00->CT2_VALOR
		cNome   := '*'+cNome
	ENDIF
	
	IF !Empty(A00->CT2_ITEMD)
		DbSelectArea("CTD")
		DbSetOrder(1)
		DbSeek(xFilial("CTD")+A00->CT2_ITEMD)
		
		DbSelectArea("_aP1B")
		RecLock("_aP1B",.T.)
		_aP1B->CODIGO  := A00->CT2_ITEMD
		_aP1B->CLVL    := A00->CT2_CLVLDB
		_aP1B->DESC    := CTD->CTD_DESC01
		_aP1B->PRODUTO := cDesc
		IF SUBSTR(A00->CT2_ORIGEM,1,6) $ '666001/668001'
			IF A00->CT2_DATA >= '20100208'
				_aP1B->NF := 'R'+SUBSTR(A00->CT2_KEY,3,9)
			ELSE
				_aP1B->NF := 'R'+SUBSTR(A00->CT2_KEY,3,6)
			ENDIF
		ELSE
			IF A00->CT2_DATA >= '20100208'
				_aP1B->NF := SUBSTR(A00->CT2_KEY,3,9)
			ELSE
				_aP1B->NF := SUBSTR(A00->CT2_KEY,3,6)
			ENDIF
		ENDIF
		
		_aP1B->FORNECE := cNome
		_aP1B->DTMOV   := STOD(A00->CT2_DATA)
		_aP1B->VALOR  := (A00->CT2_VALOR/nFator)
		_aP1B->VLPAGO := (nVlPago/nFator)
		MsUnLock()
		
		DbSelectArea("_aP1C")
		RecLock("_aP1C",.T.)
		_aP1C->CODIGO   := _aP1B->CODIGO
		_aP1C->CLVL     := _aP1B->CLVL
		_aP1C->DESC     := _aP1B->DESC
		_aP1C->FORNECE  := _aP1B->FORNECE
		_aP1C->PRODUTO  := _aP1B->PRODUTO
		IF SUBSTR(A00->CT2_ORIGEM,1,6) $ '666001/668001'
			IF A00->CT2_DATA >= '20100208'
				_aP1C->NF := 'R'+SUBSTR(A00->CT2_KEY,3,9)
			ELSE
				_aP1C->NF := 'R'+SUBSTR(A00->CT2_KEY,3,6)
			ENDIF
		ELSE
			IF A00->CT2_DATA >= '20100208'
				_aP1C->NF := SUBSTR(A00->CT2_KEY,3,9)
			ELSE
				_aP1C->NF := SUBSTR(A00->CT2_KEY,3,6)
			ENDIF
		ENDIF
		_aP1C->DTMOV := _aP1B->DTMOV
		_aP1C->VALOR  := _aP1B->VALOR
		_aP1C->VLPAGO := _aP1B->VLPAGO
		MsUnLock()
		
		DbSelectArea("CTD")
		DbSetOrder(1)
		DbSeek(xFilial("CTD")+SUBSTR(A00->CT2_ITEMD,1,2))
		
		DbSelectArea("_aP2B")
		IF !DbSeek(A00->CT2_CLVLDB+SUBSTR(A00->CT2_ITEMD,1,2))
			RecLock("_aP2B",.T.)
			_aP2B->CODIGO   := SUBSTR(A00->CT2_ITEMD,1,2)
			_aP2B->CLVL     := A00->CT2_CLVLDB
			_aP2B->DESC     := CTD->CTD_DESC01
			IF ALLTRIM(A00->CT2_ITEMD) <> '0405'
				_aP2B->VALOR  := (A00->CT2_VALOR/nFator)
				_aP2B->VLPAGO := (nVlPago/nFator)
			ENDIF
		ELSE
			IF ALLTRIM(A00->CT2_ITEMD) <> '0405'
				RecLock("_aP2B",.F.)
				_aP2B->VALOR  := _aP2B->VALOR  + (A00->CT2_VALOR/nFator)
				_aP2B->VLPAGO := _aP2B->VLPAGO + (nVlPago/nFator)
			ENDIF
		ENDIF
		MsUnLock()
		
		DbSelectArea("_aP2C")
		IF !DbSeek(A00->CT2_CLVLDB+SUBSTR(A00->CT2_ITEMD,1,2))
			RecLock("_aP2C",.T.)
			_aP2C->CODIGO   := SUBSTR(A00->CT2_ITEMD,1,2)
			_aP2C->CLVL     := A00->CT2_CLVLDB
			_aP2C->DESC     := CTD->CTD_DESC01
			IF ALLTRIM(A00->CT2_ITEMD) <> '0405'
				_aP2C->VALOR  := (A00->CT2_VALOR/nFator)
				_aP2C->VLPAGO := (nVlPago/nFator)
			ENDIF
		ELSE
			IF ALLTRIM(A00->CT2_ITEMD) <> '0405'
				RecLock("_aP2C",.F.)
				_aP2C->VALOR  := _aP2C->VALOR  + (A00->CT2_VALOR/nFator)
				_aP2C->VLPAGO := _aP2C->VLPAGO + (nVlPago/nFator)
			ENDIF
		ENDIF
		MsUnLock()
	ENDIF
	
	IF !Empty(A00->CT2_ITEMC)
		DbSelectArea("CTD")
		DbSetOrder(1)
		DbSeek(xFilial("CTD")+A00->CT2_ITEMC)
		
		DbSelectArea("_aP1B")
		RecLock("_aP1B",.T.)
		_aP1B->CODIGO  := A00->CT2_ITEMC
		_aP1B->CLVL    := A00->CT2_CLVLCR
		_aP1B->DESC    := CTD->CTD_DESC01
		_aP1B->PRODUTO := cDesc
		IF SUBSTR(A00->CT2_ORIGEM,1,6) $ '666001/668001'
			IF A00->CT2_DATA >= '20100208'
				_aP1B->NF  := 'R'+SUBSTR(A00->CT2_KEY,3,9)
			ELSE
				_aP1B->NF  := 'R'+SUBSTR(A00->CT2_KEY,3,6)
			ENDIF
		ELSE
			IF A00->CT2_DATA >= '20100208'
				_aP1B->NF  := SUBSTR(A00->CT2_KEY,3,9)
			ELSE
				_aP1B->NF  := SUBSTR(A00->CT2_KEY,3,6)
			ENDIF
		ENDIF
		_aP1B->FORNECE := cNome
		_aP1B->DTMOV   := STOD(A00->CT2_DATA)
		_aP1B->VALOR  := (A00->CT2_VALOR * (-1)/nFator)
		_aP1B->VLPAGO := (nVlPago * (-1)/nFator)
		MsUnLock()
		
		DbSelectArea("_aP1C")
		RecLock("_aP1C",.T.)
		_aP1C->CODIGO   := _aP1B->CODIGO
		_aP1C->CLVL     := _aP1B->CLVL
		_aP1C->DESC     := _aP1B->DESC
		_aP1C->FORNECE  := _aP1B->FORNECE
		_aP1C->PRODUTO  := _aP1B->PRODUTO
		IF SUBSTR(A00->CT2_ORIGEM,1,6) $ '666001/668001'
			IF A00->CT2_DATA >= '20100208'
				_aP1C->NF  := 'R'+SUBSTR(A00->CT2_KEY,3,9)
			ELSE
				_aP1C->NF  := 'R'+SUBSTR(A00->CT2_KEY,3,6)
			ENDIF
		ELSE
			IF A00->CT2_DATA >= '20100208'
				_aP1C->NF  := SUBSTR(A00->CT2_KEY,3,9)
			ELSE
				_aP1C->NF  := SUBSTR(A00->CT2_KEY,3,6)
			ENDIF
		ENDIF
		_aP1C->DTMOV  := _aP1B->DTMOV
		_aP1C->VALOR  := _aP1B->VALOR
		_aP1C->VLPAGO := _aP1B->VLPAGO
		MsUnLock()
		
		DbSelectArea("CTD")
		DbSetOrder(1)
		DbSeek(xFilial("CTD")+SUBSTR(A00->CT2_ITEMC,1,2))
		
		DbSelectArea("_aP2B")
		IF !DbSeek(A00->CT2_CLVLCR+SUBSTR(A00->CT2_ITEMC,1,2))
			RecLock("_aP2B",.T.)
			_aP2B->CODIGO   := SUBSTR(A00->CT2_ITEMC,1,2)
			_aP2B->CLVL     := A00->CT2_CLVLCR
			_aP2B->DESC     := CTD->CTD_DESC01
			IF ALLTRIM(A00->CT2_ITEMC) <> '0405'
				_aP2B->VALOR  := (A00->CT2_VALOR * (-1)/nFator)
				_aP2B->VLPAGO := (nVlPago * (-1)/nFator)
			ENDIF
		ELSE
			IF ALLTRIM(A00->CT2_ITEMC) <> '0405'
				RecLock("_aP2B",.F.)
				_aP2B->VALOR  := _aP2B->VALOR  + ((A00->CT2_VALOR * (-1))/nFator)
				_aP2B->VLPAGO := _aP2B->VLPAGO + ((nVlPago * (-1))/nFator)
			ENDIF
		ENDIF
		MsUnLock()
		
		DbSelectArea("_aP2C")
		IF !DbSeek(A00->CT2_CLVLCR+SUBSTR(A00->CT2_ITEMC,1,2))
			RecLock("_aP2C",.T.)
			_aP2C->CODIGO   := SUBSTR(A00->CT2_ITEMC,1,2)
			_aP2C->CLVL     := A00->CT2_CLVLCR
			_aP2C->DESC     := CTD->CTD_DESC01
			IF ALLTRIM(A00->CT2_ITEMC) <> '0405'
				_aP2C->VALOR  := (A00->CT2_VALOR * (-1)/nFator)
				_aP2C->VLPAGO := (nVlPago * (-1)/nFator)
			ENDIF
		ELSE
			IF ALLTRIM(A00->CT2_ITEMC) <> '0405'
				RecLock("_aP2C",.F.)
				_aP2C->VALOR  := _aP2C->VALOR  + ((A00->CT2_VALOR * (-1))/nFator)
				_aP2C->VLPAGO := _aP2C->VLPAGO + ((nVlPago * (-1))/nFator)
			ENDIF
		ENDIF
		MsUnLock()
	ENDIF
	
	DbSelectArea("A00")
	DbSkip()
END

Return

Static Function RptDet_1()
IF cEmpAnt == '01'
	aBitmap  := "LOGOPRI01.BMP"
ELSE
	aBitmap  := "LOGOPRI05.BMP"
ENDIF

fCabec   := "Investimentos"
fCabec2  := " "
wnPag    := 0
nRow1    := 0

CoF10n   := TFont():New("Lucida Console"    ,9,10,.T.,.T.,5,.T.,5,.T.,.F.)
CoF11    := TFont():New("Lucida Console"    ,9,11,.T.,.F.,5,.T.,5,.T.,.F.)
oFont7   := TFont():New("Lucida Console"    ,9,7 ,.T.,.T.,5,.T.,5,.T.,.F.)
oFont14  := TFont():New("Lucida Console"    ,9,14,.T.,.T.,5,.T.,5,.T.,.F.)
oFont8   := TFont():New("Lucida Console"    ,9,8 ,.T.,.T.,5,.T.,5,.T.,.F.)
oFont9   := TFont():New("Lucida Console"    ,9,9 ,.T.,.T.,5,.T.,5,.T.,.F.)
oFont10  := TFont():New("Lucida Console"    ,9,10,.T.,.T.,5,.T.,5,.T.,.F.)
oFont12  := TFont():New("Lucida Console"    ,9,12,.T.,.T.,5,.T.,5,.T.,.F.)
oFont26  := TFont():New("Lucida Console"    ,9,26,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16  := TFont():New("Lucida Console"    ,9,16,.T.,.T.,5,.T.,5,.T.,.F.)

oPrint:= TMSPrinter():New( "...: "+fCabec+" :..." )
oPrint:SetLandscape()
oPrint:SetPaperSize(09)

DbSelectArea("_aP1A")
_aP1A->(DbSetOrder(2))
DbGoTop()
ProcRegua(RecCount())
cCusAnt  := _aP1A->CLVL
nTotCC   := 0
nTotCC2  := 0
nTot0405 := 0
cEsp     := ''
lOK      := .T.
cNfAnt   := ''
nValAnt  := 0
nValPGAnt:= 0
nValorNF := 0
nValorPG := 0

While !Eof()
	cTempo := Alltrim(ElapTime(cHInicio, Time()))
	IncProc("Atualizando....    Tempo: "+cTempo)
	
	cCC := _aP1A->CLVL
	IF lOK
		fImpCabec()
		lOK := .F.
	ENDIF
	
	If nRow1 > 2250 .OR. cCusAnt <> _aP1A->CLVL
		oPrint:Line (nRow1+40, 010, nRow1+40, 3550)
		nRow1 += 050
		
		xf_Item := +;
		Padc(""             	     	                                                             ,09)+"  "+;
		Padc(""             	     	                                                             ,09)+"  "+;
		Padr(""                                                                                      ,35)+"  "+;
		Padr(""                                                                                      ,35)+"  "+;
		Padr(""                                                                                      ,06)+"  "+;
		Padr(""                                                                                      ,30)+"  "+;
		Padl(""                                                                                      ,08)+"  "+;
		Padl(Transform(nTotCC,  "@E 999,999,999.99")                                                 ,14)+"  "+;
		Padl(Transform(nTotCC2,  "@E 999,999,999.99")                                                ,14)
		oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont8)
		nRow1 += 050
		nTotCC  := 0
		nTotCC2 := 0
		
		xf_Item := +;
		Padc("Valor a creditar: "	     	                                                              ,20)+"  "+;
		Padl(Transform(nTot0405,  "@E 999,999,999.99")                                                ,14)
		oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont8)
		nRow1 += 050
		
		fImpRoda()
		fImpCabec()
	EndIf
	
	IF ALLTRIM(_aP1A->CODIGO) == '0405'
		cEsp := "***"
	ELSE
		cEsp := ""
	ENDIF            
	
	IF ALLTRIM(_aP1A->NF) <> ALLTRIM(cNfAnt)
		nValorNF := _aP1A->VALOR
		nValorPG := _aP1A->VLPAGO
	ELSE
		IF nValAnt == _aP1A->VALOR .OR. nValPGAnt <> _aP1A->VLPAGO
			nValorNF := _aP1A->VALOR
			nValorPG := _aP1A->VLPAGO
		ELSE
			nValorNF := 0
			nValorPG := 0
		ENDIF
	ENDIF
	
	xf_Item := +;
	Padc(_aP1A->CLVL           	                                                                  ,09)+"  "+;
	Padc(ALLTRIM(_aP1A->CODIGO)+cEsp                                                              ,09)+"  "+;
	Padr(_aP1A->DESC                                                                              ,35)+"  "+;
	Padr(_aP1A->FORNECE                                                                           ,35)+"  "+;
	Padr(_aP1A->NF                                                                                ,09)+"  "+;
	Padr(_aP1A->PRODUTO                                                                           ,30)+"  "+;
	Padl(_aP1A->DTMOV                                                                             ,08)+"  "+;
	Padl(Transform(nValorNF,  "@E 999,999,999.99")                                                ,14)+"  "+;
	Padl(Transform(nValorPG,      "@E 999,999,999.99")                                            ,14)
	oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont8)
	nRow1 += 050
	
	If nRow1 > 2250
		fImpRoda()
		fImpCabec()
	EndIf
	
	cCusAnt   := _aP1A->CLVL
	cNfAnt    := _aP1A->NF
	nValPGAnt := _aP1A->VLPAGO
	nValAnt   := _aP1A->VALOR
	
	IF ALLTRIM(_aP1A->CODIGO) <> '0405'
		nTotCC  := nTotCC  + nValorNF
		nTotCC2 := nTotCC2 + nValorPG
		
		DbSelectArea("_aP3A")
		IF !DbSeek(_aP1A->CLVL+"1P")
			RecLock("_aP3A",.T.)
			_aP3A->CLVL     := _aP1A->CLVL
			_aP3A->TIPO     := "1P"
			_aP3A->VALOR    := nValorNF
			_aP3A->VLPAGO   := nValorPG
		ELSE
			RecLock("_aP3A",.F.)
			_aP3A->VALOR    := _aP3A->VALOR  + nValorNF
			_aP3A->VLPAGO   := _aP3A->VLPAGO + nValorPG
		ENDIF
		MsUnLock()
		
		DbSelectArea("_aP4A")
		IF !DbSeek(_aP1A->CLVL+"1P")
			RecLock("_aP4A",.T.)
			_aP4A->CLVL     := _aP1A->CLVL
			_aP4A->TIPO     := "1P"
		ELSE
			RecLock("_aP4A",.F.)
		ENDIF
		
		IF ALLTRIM(STR(YEAR(dDatabase))) == ALLTRIM(SUBSTR(DTOS(_aP1A->DTMOV),1,4))
			DO CASE
				CASE SUBSTR(DTOS(_aP1A->DTMOV),5,2) == '01'
					_aP4A->VLR01 := _aP4A->VLR01 + nValorPG
				CASE SUBSTR(DTOS(_aP1A->DTMOV),5,2) == '02'
					_aP4A->VLR02 := _aP4A->VLR02 + nValorPG
				CASE SUBSTR(DTOS(_aP1A->DTMOV),5,2) == '03'
					_aP4A->VLR03 := _aP4A->VLR03 + nValorPG
				CASE SUBSTR(DTOS(_aP1A->DTMOV),5,2) == '04'
					_aP4A->VLR04 := _aP4A->VLR04 + nValorPG
				CASE SUBSTR(DTOS(_aP1A->DTMOV),5,2) == '05'
					_aP4A->VLR05 := _aP4A->VLR05 + nValorPG
				CASE SUBSTR(DTOS(_aP1A->DTMOV),5,2) == '06'
					_aP4A->VLR06 := _aP4A->VLR06 + nValorPG
				CASE SUBSTR(DTOS(_aP1A->DTMOV),5,2) == '07'
					_aP4A->VLR07 := _aP4A->VLR07 + nValorPG
				CASE SUBSTR(DTOS(_aP1A->DTMOV),5,2) == '08'
					_aP4A->VLR08 := _aP4A->VLR08 + nValorPG
				CASE SUBSTR(DTOS(_aP1A->DTMOV),5,2) == '09'
					_aP4A->VLR09 := _aP4A->VLR09 + nValorPG
				CASE SUBSTR(DTOS(_aP1A->DTMOV),5,2) == '10'
					_aP4A->VLR10 := _aP4A->VLR10 + nValorPG
				CASE SUBSTR(DTOS(_aP1A->DTMOV),5,2) == '11'
					_aP4A->VLR11 := _aP4A->VLR11 + nValorPG
				CASE SUBSTR(DTOS(_aP1A->DTMOV),5,2) == '12'
					_aP4A->VLR12 := _aP4A->VLR12 + nValorPG
			ENDCASE
		ELSE
			IF ALLTRIM(STR(YEAR(dDatabase))) > ALLTRIM(SUBSTR(DTOS(_aP1A->DTMOV),1,4))
				_aP4A->VLRAC := _aP4A->VLRAC + nValorPG
			ENDIF
		ENDIF
		_aP4A->TOTAL := _aP4A->TOTAL + nValorPG
		MsUnLock()
	ELSE
		nTot0405 := nTot0405 + (nValorNF - nValorPG)
	ENDIF
	
	DbSelectArea("_aP1A")
	DbSkip()
End

oPrint:Line (nRow1+40, 010, nRow1+40, 3550)
nRow1 += 050

xf_Item := +;
Padc(""             	     	                                                             ,09)+"  "+;
Padc(""             	     	                                                             ,09)+"  "+;
Padr(""                                                                                      ,35)+"  "+;
Padr(""                                                                                      ,35)+"  "+;
Padr(""                                                                                      ,06)+"  "+;
Padr(""                                                                                      ,30)+"  "+;
Padl(""                                                                                      ,08)+"  "+;
Padl(Transform(nTotCC,  "@E 999,999,999.99")                                                 ,14)+"  "+;
Padl(Transform(nTotCC2,  "@E 999,999,999.99")                                                ,14)
oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont8)
nRow1 += 050

xf_Item := +;
Padc("Valor a creditar: "	     	                                                              ,20)+"  "+;
Padl(Transform(nTot0405,  "@E 999,999,999.99")                                                ,14)
oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont8)
nRow1 += 050

If nRow1 > 2250
	fImpRoda()
	fImpCabec()
EndIf

fImpRoda()

oPrint:EndPage()
oPrint:Preview()

IF cEmpAnt == '01'
	aBitmap  := "LOGOPRI01.BMP"
ELSE
	aBitmap  := "LOGOPRI05.BMP"
ENDIF

fCabec   := "Investimentos"
fCabec2  := " "
wnPag    := 0
nRow1    := 0

CoF10n   := TFont():New("Lucida Console"    ,9,10,.T.,.T.,5,.T.,5,.T.,.F.)
CoF11    := TFont():New("Lucida Console"    ,9,11,.T.,.F.,5,.T.,5,.T.,.F.)
oFont7   := TFont():New("Lucida Console"    ,9,7 ,.T.,.T.,5,.T.,5,.T.,.F.)
oFont14  := TFont():New("Lucida Console"    ,9,14,.T.,.T.,5,.T.,5,.T.,.F.)
oFont8   := TFont():New("Lucida Console"    ,9,8 ,.T.,.T.,5,.T.,5,.T.,.F.)
oFont9   := TFont():New("Lucida Console"    ,9,9 ,.T.,.T.,5,.T.,5,.T.,.F.)
oFont10  := TFont():New("Lucida Console"    ,9,10,.T.,.T.,5,.T.,5,.T.,.F.)
oFont12  := TFont():New("Lucida Console"    ,9,12,.T.,.T.,5,.T.,5,.T.,.F.)
oFont26  := TFont():New("Lucida Console"    ,9,26,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16  := TFont():New("Lucida Console"    ,9,16,.T.,.T.,5,.T.,5,.T.,.F.)

oPrint:= TMSPrinter():New( "...: "+fCabec+" :..." )
oPrint:SetLandscape()
DbSelectArea("_aP1A")
_aP1A->(DbSetOrder(3))

DbSelectArea("_aP2A")
DbGoTop()
ProcRegua(RecCount())
cCusAnt  := _aP2A->CLVL
cCC      := _aP2A->CLVL
nTotCC   := 0
nTotCC2  := 0
nTotIT   := 0
nTotIT2  := 0
cEsp    := ''

fImpCabec2()

DbSelectArea("_aP2A")

While !Eof()
	cTempo := Alltrim(ElapTime(cHInicio, Time()))
	IncProc("Atualizando....    Tempo: "+cTempo)
	
	cCC := _aP2A->CLVL
	If nRow1 > 2250 .OR. cCusAnt <> _aP2A->CLVL
		oPrint:Line (nRow1+40, 010, nRow1+40, 3550)
		nRow1 += 050
		
		xf_Item := +;
		Padc(""                 	     	                                                             ,09)+"  "+;
		Padr(""                                                                                      ,80)+"  "+;
		Padl(Transform(nTotCC,  "@E 999,999,999.99")                                                 ,14)+"  "+;
		Padl(Transform(nTotCC2,  "@E 999,999,999.99")                                                ,14)
		oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont8)
		nRow1 += 050
		nTotCC  := 0
		nTotCC2 := 0
		
		fImpRoda()
		fImpCabec2()
	EndIf
	
	oPrint:Line (nRow1+40, 010, nRow1+40, 3550)
	nRow1 += 050
	xf_Item := +;
	Padr(_aP2A->CODIGO      		                                                            ,09)+"  "+;
	Padr(_aP2A->DESC                                                                        ,80)+"  "+;
	Padl(Transform(_aP2A->VALOR,  "@E 999,999,999.99")                                      ,14)+"  "+;
	Padl(Transform(_aP2A->VLPAGO,  "@E 999,999,999.99")                                     ,14)
	oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont8)
	nRow1 += 050
	
	If nRow1 > 2250
		fImpRoda()
		fImpCabec2()
	EndIf
	
	DbSelectArea("_aP1A")
	DbSeek(_aP2A->CLVL+_aP2A->CODIGO,.T.)
	nTotIT   := 0
	nTotIT2  := 0
	cCodItem := _aP1A->CODIGO
	cDesc    := _aP1A->DESC
	
	WHILE _aP1A->CLVL == _aP2A->CLVL .AND. SUBSTR(_aP1A->CODIGO,1,2) == SUBSTR(_aP2A->CODIGO,1,2) .AND. !Eof()
		IF cCodItem <> _aP1A->CODIGO
			IF ALLTRIM(cCodItem) == '0405'
				cEsp := "***"
			ELSE
				cEsp := ""
			ENDIF
			xf_Item := +;
			Padr(ALLTRIM(cCodItem)+cEsp                                                          ,09)+"  "+;
			Padr(SPACE(2)+cDesc                                                                  ,80)+"  "+;
			Padl(Transform(nTotIT,  "@E 999,999,999.99")                                         ,14)+"  "+;
			Padl(Transform(nTotIT2,  "@E 999,999,999.99")                                        ,14)
			oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont8)
			nRow1 += 050
			If nRow1 > 2250
				fImpRoda()
				fImpCabec2()
			EndIf
			nTotIT  := 0
			nTotIT2 := 0
		ENDIF
		
		IF ALLTRIM(_aP1A->CODIGO) <> '0405'
			nTotIT   := nTotIT  + _aP1A->VALOR
			nTotIT2  := nTotIT2 + _aP1A->VLPAGO
			nTotCC   := nTotCC  + _aP1A->VALOR
			nTotCC2  := nTotCC2 + _aP1A->VLPAGO
		ENDIF
		cCodItem := _aP1A->CODIGO
		cDesc    := _aP1A->DESC
		
		DbSelectArea("_aP1A")
		DbSkip()
	END
	
	xf_Item := +;
	Padr(cCodItem          	                                                             ,09)+"  "+;
	Padr(SPACE(2)+cDesc                                                                  ,80)+"  "+;
	Padl(Transform(nTotIT,  "@E 999,999,999.99")                                         ,14)+"  "+;
	Padl(Transform(nTotIT2,  "@E 999,999,999.99")                                        ,14)
	oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont8)
	nRow1 += 050
	nTotIT  := 0
	nTotIT2 := 0
	
	If nRow1 > 2250
		fImpRoda()
		fImpCabec2()
	EndIf
	
	cCusAnt  := _aP2A->CLVL
	
	DbSelectArea("_aP2A")
	DbSkip()
End

oPrint:Line (nRow1+40, 010, nRow1+40, 3550)
nRow1 += 050

xf_Item := +;
Padc(""             	     	                                                             ,09)+"  "+;
Padr(""                                                                                      ,80)+"  "+;
Padl(Transform(nTotCC,  "@E 999,999,999.99")                                                 ,14)+"  "+;
Padl(Transform(nTotCC2,  "@E 999,999,999.99")                                                ,14)
oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont8)
nRow1 += 050

If nRow1 > 2250
	fImpRoda()
	fImpCabec2()
EndIf

fImpRoda()

oPrint:EndPage()
oPrint:Preview()

Return

Static Function RptDet_2()
IF cEmpAnt == '01'
	aBitmap  := "LOGOPRI01.BMP"
ELSE
	aBitmap  := "LOGOPRI05.BMP"
ENDIF

fCabec   := "Investimentos"
fCabec2  := " "
wnPag    := 0
nRow1    := 0

CoF10n   := TFont():New("Lucida Console"    ,9,10,.T.,.T.,5,.T.,5,.T.,.F.)
CoF11    := TFont():New("Lucida Console"    ,9,11,.T.,.F.,5,.T.,5,.T.,.F.)
oFont7   := TFont():New("Lucida Console"    ,9,7 ,.T.,.T.,5,.T.,5,.T.,.F.)
oFont14  := TFont():New("Lucida Console"    ,9,14,.T.,.T.,5,.T.,5,.T.,.F.)
oFont8   := TFont():New("Lucida Console"    ,9,8 ,.T.,.T.,5,.T.,5,.T.,.F.)
oFont9   := TFont():New("Lucida Console"    ,9,9 ,.T.,.T.,5,.T.,5,.T.,.F.)
oFont10  := TFont():New("Lucida Console"    ,9,10,.T.,.T.,5,.T.,5,.T.,.F.)
oFont12  := TFont():New("Lucida Console"    ,9,12,.T.,.T.,5,.T.,5,.T.,.F.)
oFont26  := TFont():New("Lucida Console"    ,9,26,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16  := TFont():New("Lucida Console"    ,9,16,.T.,.T.,5,.T.,5,.T.,.F.)

oPrint:= TMSPrinter():New( "...: "+fCabec+" :..." )
oPrint:SetLandscape()

DbSelectArea("_aP1B")
_aP1B->(DbSetOrder(2))
DbGoTop()
ProcRegua(RecCount())
cCusAnt  := _aP1B->CLVL
nTotCC   := 0
nTotCC2  := 0
nTot0405 := 0
cEsp     := ''
lOK      := .T.
cNfAnt   := ''
nValAnt  := 0
nValPGAnt:= 0
nValorNF := 0
nValorPG := 0

While !Eof()
	cTempo := Alltrim(ElapTime(cHInicio, Time()))
	IncProc("Atualizando....    Tempo: "+cTempo)
	
	cCC := _aP1B->CLVL
	IF lOK
		fImpCabec()
		lOK := .F.
	ENDIF
	
	If nRow1 > 2250 .OR. cCusAnt <> _aP1B->CLVL
		oPrint:Line (nRow1+40, 010, nRow1+40, 3550)
		nRow1 += 050
		
		xf_Item := +;
		Padc(""             	     	                                                                 ,09)+"  "+;
		Padc(""             	     	                                                                 ,09)+"  "+;
		Padr(""                                                                                      ,35)+"  "+;
		Padr(""                                                                                      ,35)+"  "+;
		Padr(""                                                                                      ,06)+"  "+;
		Padr(""                                                                                      ,30)+"  "+;
		Padl(""                                                                                      ,08)+"  "+;
		Padl(Transform(nTotCC,  "@E 999,999,999.99")                                                 ,14)+"  "+;
		Padl(Transform(nTotCC2,  "@E 999,999,999.99")                                                ,14)
		oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont8)
		nRow1 += 050
		nTotCC  := 0
		nTotCC2 := 0
		
		xf_Item := +;
		Padc("Valor a creditar: "	     	                                                              ,20)+"  "+;
		Padl(Transform(nTot0405,  "@E 999,999,999.99")                                                ,14)
		oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont8)
		nRow1 += 050
		
		fImpRoda()
		fImpCabec()
	EndIf
	
	IF ALLTRIM(_aP1B->CODIGO) == '0405'
		cEsp := "***"
	ELSE
		cEsp := ""
	ENDIF

	IF ALLTRIM(_aP1B->NF) <> ALLTRIM(cNfAnt)
		nValorNF := _aP1B->VALOR
		nValorPG := _aP1B->VLPAGO
	ELSE
		IF nValAnt == _aP1B->VALOR .OR. nValPGAnt <> _aP1B->VLPAGO
			nValorNF := _aP1B->VALOR
			nValorPG := _aP1B->VLPAGO
		ELSE
			nValorNF := 0
			nValorPG := 0
		ENDIF
	ENDIF
	
	xf_Item := +;
	Padc(_aP1B->CLVL          	                                                                  ,09)+"  "+;
	Padc(ALLTRIM(_aP1B->CODIGO)+cEsp                                                              ,09)+"  "+;
	Padr(_aP1B->DESC                                                                              ,35)+"  "+;
	Padr(_aP1B->FORNECE                                                                           ,35)+"  "+;
	Padr(_aP1B->NF                                                                                ,09)+"  "+;
	Padr(_aP1B->PRODUTO                                                                           ,30)+"  "+;
	Padl(_aP1B->DTMOV                                                                             ,08)+"  "+;
	Padl(Transform(nValorNF,  "@E 999,999,999.99")                                                ,14)+"  "+;
	Padl(Transform(nValorPG,      "@E 999,999,999.99")                                            ,14)
	oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont8)
	aAdd(_aItRpt1,{_aP1B->CLVL,ALLTRIM(_aP1B->CODIGO)+cEsp,_aP1B->DESC,_aP1B->FORNECE,_aP1B->NF,_aP1B->PRODUTO,_aP1B->DTMOV,nValorNF,nValorPG,Iif(cEsp == "***",0,nValorNF),Iif(cEsp == "***",0,nValorPG)})
	nRow1 += 050
	
	If nRow1 > 2250
		fImpRoda()
		fImpCabec()
	EndIf
	
	cCusAnt   := _aP1B->CLVL
	cNfAnt    := _aP1B->NF
	nValPGAnt := _aP1B->VLPAGO	
	nValAnt   := _aP1B->VALOR
	
	IF ALLTRIM(_aP1B->CODIGO) <> '0405'
		nTotCC  := nTotCC  + nValorNF
		nTotCC2 := nTotCC2 + nValorPG
		
		DbSelectArea("_aP3A")
		IF !DbSeek(_aP1B->CLVL+"2E")
			RecLock("_aP3A",.T.)
			_aP3A->CLVL     := _aP1B->CLVL
			_aP3A->TIPO     := "2E"
			_aP3A->VALOR    := nValorNF
			_aP3A->VLPAGO   := nValorPG
		ELSE
			RecLock("_aP3A",.F.)
			_aP3A->VALOR    := _aP3A->VALOR  + nValorNF
			_aP3A->VLPAGO   := _aP3A->VLPAGO + nValorPG
		ENDIF
		MsUnLock()
		
		DbSelectArea("_aP4A")
		IF !DbSeek(_aP1B->CLVL+"2E")
			RecLock("_aP4A",.T.)
			_aP4A->CLVL     := _aP1B->CLVL
			_aP4A->TIPO     := "2E"
		ELSE
			RecLock("_aP4A",.F.)
		ENDIF
		
		IF ALLTRIM(STR(YEAR(dDatabase))) == ALLTRIM(SUBSTR(DTOS(_aP1B->DTMOV),1,4))
			DO CASE
				CASE SUBSTR(DTOS(_aP1B->DTMOV),5,2) == '01'
					_aP4A->VLR01 := _aP4A->VLR01 + nValorPG
				CASE SUBSTR(DTOS(_aP1B->DTMOV),5,2) == '02'
					_aP4A->VLR02 := _aP4A->VLR02 + nValorPG
				CASE SUBSTR(DTOS(_aP1B->DTMOV),5,2) == '03'
					_aP4A->VLR03 := _aP4A->VLR03 + nValorPG
				CASE SUBSTR(DTOS(_aP1B->DTMOV),5,2) == '04'
					_aP4A->VLR04 := _aP4A->VLR04 + nValorPG
				CASE SUBSTR(DTOS(_aP1B->DTMOV),5,2) == '05'
					_aP4A->VLR05 := _aP4A->VLR05 + nValorPG
				CASE SUBSTR(DTOS(_aP1B->DTMOV),5,2) == '06'
					_aP4A->VLR06 := _aP4A->VLR06 + nValorPG
				CASE SUBSTR(DTOS(_aP1B->DTMOV),5,2) == '07'
					_aP4A->VLR07 := _aP4A->VLR07 + nValorPG
				CASE SUBSTR(DTOS(_aP1B->DTMOV),5,2) == '08'
					_aP4A->VLR08 := _aP4A->VLR08 + nValorPG
				CASE SUBSTR(DTOS(_aP1B->DTMOV),5,2) == '09'
					_aP4A->VLR09 := _aP4A->VLR09 + nValorPG
				CASE SUBSTR(DTOS(_aP1B->DTMOV),5,2) == '10'
					_aP4A->VLR10 := _aP4A->VLR10 + nValorPG
				CASE SUBSTR(DTOS(_aP1B->DTMOV),5,2) == '11'
					_aP4A->VLR11 := _aP4A->VLR11 + nValorPG
				CASE SUBSTR(DTOS(_aP1B->DTMOV),5,2) == '12'
					_aP4A->VLR12 := _aP4A->VLR12 + nValorPG
			ENDCASE
		ELSE
			IF ALLTRIM(STR(YEAR(dDatabase))) > ALLTRIM(SUBSTR(DTOS(_aP1B->DTMOV),1,4))
				_aP4A->VLRAC := _aP4A->VLRAC + nValorPG
			ENDIF
		ENDIF
		_aP4A->TOTAL := _aP4A->TOTAL + nValorPG
		MsUnLock()
	ELSE
		nTot0405 := nTot0405 + (nValorNF - nValorPG)
	ENDIF
	
	DbSelectArea("_aP1B")
	DbSkip()
End

oPrint:Line (nRow1+40, 010, nRow1+40, 3550)
nRow1 += 050

xf_Item := +;
Padc(""             	     	                                                             ,09)+"  "+;
Padc(""             	     	                                                             ,09)+"  "+;
Padr(""                                                                                      ,35)+"  "+;
Padr(""                                                                                      ,35)+"  "+;
Padr(""                                                                                      ,06)+"  "+;
Padr(""                                                                                      ,30)+"  "+;
Padl(""                                                                                      ,08)+"  "+;
Padl(Transform(nTotCC,  "@E 999,999,999.99")                                                 ,14)+"  "+;
Padl(Transform(nTotCC2,  "@E 999,999,999.99")                                                ,14)
oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont8)
nRow1 += 050

xf_Item := +;
Padc("Valor a creditar: "	     	                                                              ,20)+"  "+;
Padl(Transform(nTot0405,  "@E 999,999,999.99")                                                ,14)
oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont8)
nRow1 += 050

If nRow1 > 2250
	fImpRoda()
	fImpCabec()
EndIf

fImpRoda()

oPrint:EndPage()
oPrint:Preview()

IF cEmpAnt == '01'
	aBitmap  := "LOGOPRI01.BMP"
ELSE
	aBitmap  := "LOGOPRI05.BMP"
ENDIF

fCabec   := "Investimentos"
fCabec2  := " "
wnPag    := 0
nRow1    := 0

CoF10n   := TFont():New("Lucida Console"    ,9,10,.T.,.T.,5,.T.,5,.T.,.F.)
CoF11    := TFont():New("Lucida Console"    ,9,11,.T.,.F.,5,.T.,5,.T.,.F.)
oFont7   := TFont():New("Lucida Console"    ,9,7 ,.T.,.T.,5,.T.,5,.T.,.F.)
oFont14  := TFont():New("Lucida Console"    ,9,14,.T.,.T.,5,.T.,5,.T.,.F.)
oFont8   := TFont():New("Lucida Console"    ,9,8 ,.T.,.T.,5,.T.,5,.T.,.F.)
oFont9   := TFont():New("Lucida Console"    ,9,9 ,.T.,.T.,5,.T.,5,.T.,.F.)
oFont10  := TFont():New("Lucida Console"    ,9,10,.T.,.T.,5,.T.,5,.T.,.F.)
oFont12  := TFont():New("Lucida Console"    ,9,12,.T.,.T.,5,.T.,5,.T.,.F.)
oFont26  := TFont():New("Lucida Console"    ,9,26,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16  := TFont():New("Lucida Console"    ,9,16,.T.,.T.,5,.T.,5,.T.,.F.)

oPrint:= TMSPrinter():New( "...: "+fCabec+" :..." )
oPrint:SetLandscape()

DbSelectArea("_aP1B")
_aP1B->(DbSetOrder(3))


DbSelectArea("_aP2B")
DbGoTop()
ProcRegua(RecCount())
cCusAnt  := _aP2B->CLVL
cCC      := _aP2B->CLVL
nTotCC   := 0
nTotCC2  := 0
nTotIT   := 0
nTotIT2  := 0
cEsp    := ''

fImpCabec2()

DbSelectArea("_aP2B")

While !Eof()
	cTempo := Alltrim(ElapTime(cHInicio, Time()))
	IncProc("Atualizando....    Tempo: "+cTempo)
	
	cCC := _aP2B->CLVL
	If nRow1 > 2250 .OR. cCusAnt <> _aP2B->CLVL
		oPrint:Line (nRow1+40, 010, nRow1+40, 3550)
		nRow1 += 050
		
		xf_Item := +;
		Padc(""             	     	                                                             ,09)+"  "+;
		Padr(""                                                                                      ,80)+"  "+;
		Padl(Transform(nTotCC,  "@E 999,999,999.99")                                                 ,14)+"  "+;
		Padl(Transform(nTotCC2,  "@E 999,999,999.99")                                                ,14)
		oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont8)
		nRow1 += 050
		nTotCC  := 0
		nTotCC2 := 0
		
		fImpRoda()
		fImpCabec2()
	EndIf
	
	oPrint:Line (nRow1+40, 010, nRow1+40, 3550)
	nRow1 += 050
	xf_Item := +;
	Padr(_aP2B->CODIGO   		                                                          ,09)+"  "+;
	Padr(_aP2B->DESC                                                                  ,80)+"  "+;
	Padl(Transform(_aP2B->VALOR,  "@E 999,999,999.99")                                ,14)+"  "+;
	Padl(Transform(_aP2B->VLPAGO,  "@E 999,999,999.99")                               ,14)
	oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont8)
	aAdd(_aItRpt2,{_aP2B->CODIGO,_aP2B->DESC,_aP2B->VALOR,_aP2B->VLPAGO,_aP2B->VALOR,_aP2B->VLPAGO})
	nRow1 += 050
	
	If nRow1 > 2250
		fImpRoda()
		fImpCabec2()
	EndIf
	
	DbSelectArea("_aP1B")
	DbSeek(_aP2B->CLVL+_aP2B->CODIGO,.T.)
	nTotIT   := 0
	nTotIT2  := 0
	cCodItem := _aP1B->CODIGO
	cDesc    := _aP1B->DESC
	
	WHILE _aP1B->CLVL == _aP2B->CLVL .AND. SUBSTR(_aP1B->CODIGO,1,2) == SUBSTR(_aP2B->CODIGO,1,2) .AND. !Eof()
		
		IF cCodItem <> _aP1B->CODIGO
			IF ALLTRIM(cCodItem) == '0405'
				cEsp := "***"
			ELSE
				cEsp := ""
			ENDIF
			xf_Item := +;
			Padr(ALLTRIM(cCodItem)+cEsp                                                          ,09)+"  "+;
			Padr(SPACE(2)+cDesc                                                                  ,80)+"  "+;
			Padl(Transform(nTotIT,  "@E 999,999,999.99")                                         ,14)+"  "+;
			Padl(Transform(nTotIT2,  "@E 999,999,999.99")                                        ,14)
			aAdd(_aItRpt2,{ALLTRIM(cCodItem)+cEsp,SPACE(2)+cDesc,nTotIT,nTotIT2,Iif(cDesc == "***",0,nTotIT),Iif(cDesc == "***",0,nTotIT2)})
			oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont8)
			nRow1 += 050
			If nRow1 > 2250
				fImpRoda()
				fImpCabec2()
			EndIf
			nTotIT  := 0
			nTotIT2 := 0
		ENDIF
		
		IF ALLTRIM(_aP1B->CODIGO) <> '0405'
			nTotIT   := nTotIT  + _aP1B->VALOR
			nTotIT2  := nTotIT2 + _aP1B->VLPAGO
			nTotCC   := nTotCC  + _aP1B->VALOR
			nTotCC2  := nTotCC2 + _aP1B->VLPAGO
		ENDIF
		
		cCodItem := _aP1B->CODIGO
		cDesc    := _aP1B->DESC
		
		DbSelectArea("_aP1B")
		DbSkip()
	END
	
	xf_Item := +;
	Padr(ALLTRIM(cCodItem)+cEsp                                                          ,09)+"  "+;
	Padr(SPACE(2)+cDesc                                                                  ,80)+"  "+;
	Padl(Transform(nTotIT,  "@E 999,999,999.99")                                         ,14)+"  "+;
	Padl(Transform(nTotIT2,  "@E 999,999,999.99")                                        ,14)
	aAdd(_aItRpt2,{ALLTRIM(cCodItem)+cEsp,SPACE(2)+cDesc,nTotIT,nTotIT2,Iif(cDesc == "***",0,nTotIT),Iif(cDesc == "***",0,nTotIT2)})
	oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont8)
	nRow1 += 050
	nTotIT  := 0
	nTotIT2 := 0
	
	If nRow1 > 2250
		fImpRoda()
		fImpCabec2()
	EndIf
	
	cCusAnt  := _aP2B->CLVL
	
	DbSelectArea("_aP2B")
	DbSkip()
End

oPrint:Line (nRow1+40, 010, nRow1+40, 3550)
nRow1 += 050

xf_Item := +;
Padc(""             	     	                                                             ,09)+"  "+;
Padr(""                                                                                      ,80)+"  "+;
Padl(Transform(nTotCC,  "@E 999,999,999.99")                                                 ,14)+"  "+;
Padl(Transform(nTotCC2,  "@E 999,999,999.99")                                                ,14)
oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont8)
nRow1 += 050

If nRow1 > 2250
	fImpRoda()
	fImpCabec2()
EndIf

fImpRoda()

oPrint:EndPage()
oPrint:Preview()

Return

Static Function RptDet_3()
IF cEmpAnt == '01'
	aBitmap  := "LOGOPRI01.BMP"
ELSE
	aBitmap  := "LOGOPRI05.BMP"
ENDIF

fCabec   := "Investimentos"
fCabec2  := " "
wnPag    := 0
nRow1    := 0

CoF10n   := TFont():New("Lucida Console"    ,9,10,.T.,.T.,5,.T.,5,.T.,.F.)
CoF11    := TFont():New("Lucida Console"    ,9,11,.T.,.F.,5,.T.,5,.T.,.F.)
oFont7   := TFont():New("Lucida Console"    ,9,7 ,.T.,.T.,5,.T.,5,.T.,.F.)
oFont14  := TFont():New("Lucida Console"    ,9,14,.T.,.T.,5,.T.,5,.T.,.F.)
oFont8   := TFont():New("Lucida Console"    ,9,8 ,.T.,.T.,5,.T.,5,.T.,.F.)
oFont9   := TFont():New("Lucida Console"    ,9,9 ,.T.,.T.,5,.T.,5,.T.,.F.)
oFont10  := TFont():New("Lucida Console"    ,9,10,.T.,.T.,5,.T.,5,.T.,.F.)
oFont12  := TFont():New("Lucida Console"    ,9,12,.T.,.T.,5,.T.,5,.T.,.F.)
oFont26  := TFont():New("Lucida Console"    ,9,26,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16  := TFont():New("Lucida Console"    ,9,16,.T.,.T.,5,.T.,5,.T.,.F.)

oPrint:= TMSPrinter():New( "...: "+fCabec+" :..." )
oPrint:SetLandscape()

DbSelectArea("_aP1C")
_aP1C->(DbSetOrder(2))
DbGoTop()
ProcRegua(RecCount())
cCusAnt  := _aP1C->CLVL
nTotCC   := 0
nTotCC2  := 0
nTot0405 := 0
cEsp     := ''
lOK      := .T.
cNfAnt   := ''
nValAnt  := 0
nValPGAnt:= 0
nValorNF := 0
nValorPG := 0

While !Eof()
	cTempo := Alltrim(ElapTime(cHInicio, Time()))
	IncProc("Atualizando....    Tempo: "+cTempo)
	
	cCC := _aP1C->CLVL
	IF lOK
		fImpCabec()
		lOK := .F.
	ENDIF
	
	If nRow1 > 2250 .OR. cCusAnt <> _aP1C->CLVL
		oPrint:Line (nRow1+40, 010, nRow1+40, 3550)
		nRow1 += 050
		
		xf_Item := +;
		Padc(""             	     	                                                                 ,09)+"  "+;
		Padc(""             	     	                                                                 ,09)+"  "+;
		Padr(""                                                                                      ,35)+"  "+;
		Padr(""                                                                                      ,35)+"  "+;
		Padr(""                                                                                      ,06)+"  "+;
		Padr(""                                                                                      ,30)+"  "+;
		Padl(""                                                                                      ,08)+"  "+;
		Padl(Transform(nTotCC,  "@E 999,999,999.99")                                                 ,14)+"  "+;
		Padl(Transform(nTotCC2,  "@E 999,999,999.99")                                                ,14)
		oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont8)
		nRow1 += 050
		nTotCC  := 0
		nTotCC2 := 0
		
		xf_Item := +;
		Padc("Valor a creditar: "	     	                                                              ,20)+"  "+;
		Padl(Transform(nTot0405,  "@E 999,999,999.99")                                                ,14)
		oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont8)
		nRow1 += 050
		
		fImpRoda()
		fImpCabec()
	EndIf
	
	IF ALLTRIM(_aP1C->CODIGO) == '0405'
		cEsp := "***"
	ELSE
		cEsp := ""
	ENDIF
	
	IF ALLTRIM(_aP1C->NF) <> ALLTRIM(cNfAnt)
		nValorNF := _aP1C->VALOR
		nValorPG := _aP1C->VLPAGO
	ELSE
		IF nValAnt == _aP1C->VALOR .OR. nValPGAnt <> _aP1C->VLPAGO
			nValorNF := _aP1C->VALOR
			nValorPG := _aP1C->VLPAGO
		ELSE
			nValorNF := 0
			nValorPG := 0
		ENDIF
	ENDIF
	
	xf_Item := +;
	Padc(_aP1C->CLVL              	                                                              ,09)+"  "+;
	Padc(ALLTRIM(_aP1C->CODIGO)+cEsp                                                              ,09)+"  "+;
	Padr(_aP1C->DESC                                                                              ,35)+"  "+;
	Padr(_aP1C->FORNECE                                                                           ,35)+"  "+;
	Padr(_aP1C->NF                                                                                ,09)+"  "+;
	Padr(_aP1C->PRODUTO                                                                           ,30)+"  "+;
	Padl(_aP1C->DTMOV                                                                             ,08)+"  "+;
	Padl(Transform(nValorPG,  "@E 999,999,999.99")                                                ,14)+"  "+;
	Padl(Transform(nValorNF,      "@E 999,999,999.99")                                            ,14)
	oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont8)
	nRow1 += 050
	
	If nRow1 > 2250
		fImpRoda()
		fImpCabec()
	EndIf
	
	cCusAnt   := _aP1C->CLVL
	cNfAnt    := _aP1C->NF
	nValPGAnt := _aP1C->VLPAGO
	nValAnt   := _aP1C->VALOR
	
	IF ALLTRIM(_aP1C->CODIGO) <> '0405'
		nTotCC  := nTotCC  + nValorNF
		nTotCC2 := nTotCC2 + nValorPG
	ELSE
		nTot0405 := nTot0405 + (nValorNF - nValorPG)
	ENDIF
	
	DbSelectArea("_aP1C")
	DbSkip()
End

oPrint:Line (nRow1+40, 010, nRow1+40, 3550)
nRow1 += 050

xf_Item := +;
Padc(""             	     	                                                             ,09)+"  "+;
Padc(""             	     	                                                             ,09)+"  "+;
Padr(""                                                                                      ,35)+"  "+;
Padr(""                                                                                      ,35)+"  "+;
Padr(""                                                                                      ,06)+"  "+;
Padr(""                                                                                      ,30)+"  "+;
Padl(""                                                                                      ,08)+"  "+;
Padl(Transform(nTotCC,  "@E 999,999,999.99")                                                 ,14)+"  "+;
Padl(Transform(nTotCC2,  "@E 999,999,999.99")                                                ,14)
oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont8)
nRow1 += 050

xf_Item := +;
Padc("Valor a creditar: "	     	                                                              ,20)+"  "+;
Padl(Transform(nTot0405,  "@E 999,999,999.99")                                                ,14)
oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont8)
nRow1 += 050

If nRow1 > 2250
	fImpRoda()
	fImpCabec()
EndIf

fImpRoda()

oPrint:EndPage()
oPrint:Preview()

IF cEmpAnt == '01'
	aBitmap  := "LOGOPRI01.BMP"
ELSE
	aBitmap  := "LOGOPRI05.BMP"
ENDIF

fCabec   := "Investimentos"
fCabec2  := " "
wnPag    := 0
nRow1    := 0

CoF10n   := TFont():New("Lucida Console"    ,9,10,.T.,.T.,5,.T.,5,.T.,.F.)
CoF11    := TFont():New("Lucida Console"    ,9,11,.T.,.F.,5,.T.,5,.T.,.F.)
oFont7   := TFont():New("Lucida Console"    ,9,7 ,.T.,.T.,5,.T.,5,.T.,.F.)
oFont14  := TFont():New("Lucida Console"    ,9,14,.T.,.T.,5,.T.,5,.T.,.F.)
oFont8   := TFont():New("Lucida Console"    ,9,8 ,.T.,.T.,5,.T.,5,.T.,.F.)
oFont9   := TFont():New("Lucida Console"    ,9,9 ,.T.,.T.,5,.T.,5,.T.,.F.)
oFont10  := TFont():New("Lucida Console"    ,9,10,.T.,.T.,5,.T.,5,.T.,.F.)
oFont12  := TFont():New("Lucida Console"    ,9,12,.T.,.T.,5,.T.,5,.T.,.F.)
oFont26  := TFont():New("Lucida Console"    ,9,26,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16  := TFont():New("Lucida Console"    ,9,16,.T.,.T.,5,.T.,5,.T.,.F.)

oPrint:= TMSPrinter():New( "...: "+fCabec+" :..." )
oPrint:SetLandscape()
DbSelectArea("_aP1C")
_aP1C->(DbSetOrder(3))

DbSelectArea("_aP2C")
DbGoTop()
ProcRegua(RecCount())
cCusAnt  := _aP2C->CLVL
cCC      := _aP2C->CLVL
nTotCC   := 0
nTotCC2  := 0
nTotIT   := 0
nTotIT2  := 0
cEsp    := ''

fImpCabec2()

DbSelectArea("_aP2C")

While !Eof()
	cTempo := Alltrim(ElapTime(cHInicio, Time()))
	IncProc("Atualizando....    Tempo: "+cTempo)
	
	cCC := _aP2C->CLVL
	If nRow1 > 2250 .OR. cCusAnt <> _aP2C->CLVL
		oPrint:Line (nRow1+40, 010, nRow1+40, 3550)
		nRow1 += 050
		
		xf_Item := +;
		Padc(""             	     	                                                             ,09)+"  "+;
		Padr(""                                                                                      ,80)+"  "+;
		Padl(Transform(nTotCC,  "@E 999,999,999.99")                                                 ,14)+"  "+;
		Padl(Transform(nTotCC2,  "@E 999,999,999.99")                                                ,14)
		oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont8)
		nRow1 += 050
		nTotCC  := 0
		nTotCC2 := 0
		
		fImpRoda()
		fImpCabec2()
	EndIf
	
	oPrint:Line (nRow1+40, 010, nRow1+40, 3550)
	nRow1 += 050
	xf_Item := +;
	Padr(_aP2C->CODIGO        		                                                                ,09)+"  "+;
	Padr(_aP2C->DESC                                                                        ,80)+"  "+;
	Padl(Transform(_aP2C->VALOR,  "@E 999,999,999.99")                                      ,14)+"  "+;
	Padl(Transform(_aP2C->VLPAGO,  "@E 999,999,999.99")                                     ,14)
	oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont8)
	nRow1 += 050
	
	If nRow1 > 2250
		fImpRoda()
		fImpCabec2()
	EndIf
	
	DbSelectArea("_aP1C")
	DbSeek(_aP2C->CLVL+_aP2C->CODIGO,.T.)
	nTotIT   := 0
	nTotIT2  := 0
	cCodItem := _aP1C->CODIGO
	cDesc    := _aP1C->DESC
	
	WHILE _aP1C->CLVL == _aP2C->CLVL .AND. SUBSTR(_aP1C->CODIGO,1,2) == SUBSTR(_aP2C->CODIGO,1,2) .AND. !Eof()
		
		IF cCodItem <> _aP1C->CODIGO
			IF ALLTRIM(cCodItem) == '0405'
				cEsp := "***"
			ELSE
				cEsp := ""
			ENDIF
			xf_Item := +;
			Padr(ALLTRIM(cCodItem)+cEsp                                                          ,09)+"  "+;
			Padr(SPACE(2)+cDesc                                                                  ,80)+"  "+;
			Padl(Transform(nTotIT,  "@E 999,999,999.99")                                         ,14)+"  "+;
			Padl(Transform(nTotIT2,  "@E 999,999,999.99")                                        ,14)
			oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont8)
			nRow1 += 050
			If nRow1 > 2250
				fImpRoda()
				fImpCabec2()
			EndIf
			nTotIT  := 0
			nTotIT2 := 0
		ENDIF
		
		IF ALLTRIM(_aP1C->CODIGO) <> '0405'
			nTotIT   := nTotIT  + _aP1C->VALOR
			nTotIT2  := nTotIT2 + _aP1C->VLPAGO
			nTotCC   := nTotCC  + _aP1C->VALOR
			nTotCC2  := nTotCC2 + _aP1C->VLPAGO
		ENDIF
		
		cCodItem := _aP1C->CODIGO
		cDesc    := _aP1C->DESC
		
		DbSelectArea("_aP1C")
		DbSkip()
	END
	
	xf_Item := +;
	Padr(ALLTRIM(cCodItem)+cEsp                                                          ,09)+"  "+;
	Padr(SPACE(2)+cDesc                                                                  ,80)+"  "+;
	Padl(Transform(nTotIT,  "@E 999,999,999.99")                                         ,14)+"  "+;
	Padl(Transform(nTotIT2,  "@E 999,999,999.99")                                        ,14)
	oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont8)
	nRow1 += 050
	nTotIT  := 0
	nTotIT2 := 0
	
	If nRow1 > 2250
		fImpRoda()
		fImpCabec2()
	EndIf
	
	cCusAnt  := _aP2C->CLVL
	
	DbSelectArea("_aP2C")
	DbSkip()
End

oPrint:Line (nRow1+40, 010, nRow1+40, 3550)
nRow1 += 050

xf_Item := +;
Padc(""             	     	                                                             ,09)+"  "+;
Padr(""                                                                                      ,80)+"  "+;
Padl(Transform(nTotCC,  "@E 999,999,999.99")                                                 ,14)+"  "+;
Padl(Transform(nTotCC2,  "@E 999,999,999.99")                                                ,14)
oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont8)
nRow1 += 050

If nRow1 > 2250
	fImpRoda()
	fImpCabec2()
EndIf

fImpRoda()

oPrint:EndPage()
oPrint:Preview()

Return

Static Function RptDet_4()
IF cEmpAnt == '01'
	aBitmap  := "LOGOPRI01.BMP"
ELSE
	aBitmap  := "LOGOPRI05.BMP"
ENDIF

fCabec   := "Resumo dos Investimentos na Classe de Valor "
fCabec2  := ""
wnPag    := 0
nRow1    := 0

CoF10n   := TFont():New("Lucida Console"    ,9,10,.T.,.T.,5,.T.,5,.T.,.F.)
CoF11    := TFont():New("Lucida Console"    ,9,11,.T.,.F.,5,.T.,5,.T.,.F.)
oFont7   := TFont():New("Lucida Console"    ,9,7 ,.T.,.T.,5,.T.,5,.T.,.F.)
oFont14  := TFont():New("Lucida Console"    ,9,14,.T.,.T.,5,.T.,5,.T.,.F.)
oFont8   := TFont():New("Lucida Console"    ,9,8 ,.T.,.T.,5,.T.,5,.T.,.F.)
oFont9   := TFont():New("Lucida Console"    ,9,9 ,.T.,.T.,5,.T.,5,.T.,.F.)
oFont10  := TFont():New("Lucida Console"    ,9,10,.T.,.T.,5,.T.,5,.T.,.F.)
oFont12  := TFont():New("Lucida Console"    ,9,12,.T.,.T.,5,.T.,5,.T.,.F.)
oFont26  := TFont():New("Lucida Console"    ,9,26,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16  := TFont():New("Lucida Console"    ,9,16,.T.,.T.,5,.T.,5,.T.,.F.)

oPrint:= TMSPrinter():New( "...: "+fCabec+" :..." )
oPrint:SetLandscape()

DbSelectArea("_aP3A")
DbGoTop()
ProcRegua(RecCount())
cCusAnt := _aP3A->CLVL
nTotCC  := 0
nTotCC2 := 0
lOK     := .T.

While !Eof()
	cTempo := Alltrim(ElapTime(cHInicio, Time()))
	IncProc("Atualizando....    Tempo: "+cTempo)
	
	cCC := _aP3A->CLVL
	IF lOK
		fImpCabec3()
		lOK := .F.
	ENDIF
	
	If nRow1 > 2250 .OR. cCusAnt <> _aP3A->CLVL
		oPrint:Line (nRow1+40, 010, nRow1+40, 3550)
		nRow1 += 050
		
		xf_Item := +;
		Padc(""             	     	                                                             ,100)+"  "+;
		Padl(Transform(nTotCC,  "@E 999,999,999.99")                                                 ,30)+"  "+;
		Padl(Transform(nTotCC2,  "@E 999,999,999.99")                                                ,30)
		oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont8)
		nRow1 += 050
		nTotCC  := 0
		nTotCC2 := 0
		
		fImpRoda()
		fImpCabec3()
	EndIf
	
	IF _aP3A->TIPO == '1P'
		xf_Item := +;
		Padr("Planilha (P) - Previsoes de Desembolso"                                                 ,100)+"  "+;
		Padl(Transform(_aP3A->VALOR,  "@E 999,999,999.99")                                            ,30)+"  "+;
		Padl(Transform(_aP3A->VLPAGO,  "@E 999,999,999.99")                                           ,30)
		oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont8)
		nRow1 += 050
	ELSE
		IF cEmpAnt == '01'
			xf_Item := +;
			Padr("Planilha (E) - Entradas de Notas Fiscais "                                              ,100)+"  "+;
			Padl(Transform(_aP3A->VALOR,  "@E 999,999,999.99")                                            ,30)+"  "+;
			Padl(Transform(_aP3A->VLPAGO,  "@E 999,999,999.99")                                           ,30)
			oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont8)
			nRow1 += 050
		ELSE
			xf_Item := +;
			Padr("Planilha (E) - Entradas de Notas Fiscais"                                               ,100)+"  "+;
			Padl(Transform(_aP3A->VALOR,  "@E 999,999,999.99")                                            ,30)+"  "+;
			Padl(Transform(_aP3A->VLPAGO,  "@E 999,999,999.99")                                           ,30)
			oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont8)
			nRow1 += 050
		ENDIF
	ENDIF
	
	If nRow1 > 2250
		fImpRoda()
		fImpCabec3()
	EndIf
	
	cCusAnt := _aP3A->CLVL
	nTotCC  := nTotCC  + _aP3A->VALOR
	nTotCC2 := nTotCC2 + _aP3A->VLPAGO
	
	DbSelectArea("_aP3A")
	DbSkip()
End

oPrint:Line (nRow1+40, 010, nRow1+40, 3550)
nRow1 += 050

xf_Item := +;
Padr(""             	     	                                                             ,100)+"  "+;
Padl(Transform(nTotCC,  "@E 999,999,999.99")                                                 ,30)+"  "+;
Padl(Transform(nTotCC2,  "@E 999,999,999.99")                                                ,30)
oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont8)
nRow1 += 050

If nRow1 > 2250
	fImpRoda()
	fImpCabec3()
EndIf

fImpRoda()

oPrint:EndPage()
oPrint:Preview()
Return

Static Function RptDet_5()
IF cEmpAnt == '01'
	aBitmap  := "LOGOPRI01.BMP"
ELSE
	aBitmap  := "LOGOPRI05.BMP"
ENDIF

fCabec   := "Resumo dos Investimentos - Acumulado "
fCabec2  := " "
wnPag    := 0
nRow1    := 0

CoF10n   := TFont():New("Lucida Console"    ,9,10,.T.,.T.,5,.T.,5,.T.,.F.)
CoF11    := TFont():New("Lucida Console"    ,9,11,.T.,.F.,5,.T.,5,.T.,.F.)
oFont7   := TFont():New("Lucida Console"    ,9,4 ,.T.,.T.,5,.T.,5,.T.,.F.)
oFont14  := TFont():New("Lucida Console"    ,9,14,.T.,.T.,5,.T.,5,.T.,.F.)
oFont8   := TFont():New("Lucida Console"    ,9,5 ,.T.,.T.,5,.T.,5,.T.,.F.)
oFont9   := TFont():New("Lucida Console"    ,9,9 ,.T.,.T.,5,.T.,5,.T.,.F.)
oFont10  := TFont():New("Lucida Console"    ,9,10,.T.,.T.,5,.T.,5,.T.,.F.)
oFont12  := TFont():New("Lucida Console"    ,9,12,.T.,.T.,5,.T.,5,.T.,.F.)
oFont26  := TFont():New("Lucida Console"    ,9,26,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16  := TFont():New("Lucida Console"    ,9,16,.T.,.T.,5,.T.,5,.T.,.F.)

oPrint:= TMSPrinter():New( "...: "+fCabec+" :..." )
oPrint:SetLandscape()

//Adequacao das Classes de Valores antigas sem informacoes na base do Protheus durante o ano atual e o último ano.
DbSelectArea("_aP4A")
IF !DbSeek("8009"+"2E")
	RecLock("_aP4A",.T.)
	_aP4A->CLVL     := "8009"
	_aP4A->TIPO     := "2E"
	MsUnLock()
ENDIF

DbSelectArea("_aP4A")
IF !DbSeek("8011"+"2E")
	RecLock("_aP4A",.T.)
	_aP4A->CLVL     := "8011"
	_aP4A->TIPO     := "2E"
	MsUnLock()
ENDIF

//DbSelectArea("_aP4A")
//IF !DbSeek("8016"+"2E")
//	RecLock("_aP4A",.T.)
//	_aP4A->CLVL     := "8016"
//	_aP4A->TIPO     := "2E"
//	MsUnLock()
//ENDIF

//DbSelectArea("_aP4A")
//IF !DbSeek("8017"+"2E")
//	RecLock("_aP4A",.T.)
//	_aP4A->CLVL     := "8017"
//	_aP4A->TIPO     := "2E"
//	MsUnLock()
//ENDIF

DbSelectArea("_aP4A")
IF !DbSeek("8018"+"2E")
	RecLock("_aP4A",.T.)
	_aP4A->CLVL     := "8018"
	_aP4A->TIPO     := "2E"
	MsUnLock()
ENDIF

//DbSelectArea("_aP4A")
//IF !DbSeek("8019"+"2E")
//	RecLock("_aP4A",.T.)
//	_aP4A->CLVL     := "8019"
//	_aP4A->TIPO     := "2E"
//	MsUnLock()
//ENDIF

//DbSelectArea("_aP4A")
//IF !DbSeek("8022"+"2E")
//	RecLock("_aP4A",.T.)
//	_aP4A->CLVL     := "8022"
//	_aP4A->TIPO     := "2E"
//	MsUnLock()
//ENDIF

DbSelectArea("_aP4A")
IF !DbSeek("8023"+"2E")
	RecLock("_aP4A",.T.)
	_aP4A->CLVL     := "8023"
	_aP4A->TIPO     := "2E"
	MsUnLock()
ENDIF

DbSelectArea("_aP4A")
IF !DbSeek("8024"+"2E")
	RecLock("_aP4A",.T.)
	_aP4A->CLVL     := "8024"
	_aP4A->TIPO     := "2E"
	MsUnLock()
ENDIF

DbSelectArea("_aP4A")
IF !DbSeek("8025"+"2E")
	RecLock("_aP4A",.T.)
	_aP4A->CLVL     := "8025"
	_aP4A->TIPO     := "2E"
	MsUnLock()
ENDIF

//DbSelectArea("_aP4A")
//IF !DbSeek("8026"+"2E")
//	RecLock("_aP4A",.T.)
//	_aP4A->CLVL     := "8026"
//	_aP4A->TIPO     := "2E"
//	MsUnLock()
//ENDIF

//DbSelectArea("_aP4A")
//IF !DbSeek("8027"+"2E")
//	RecLock("_aP4A",.T.)
//	_aP4A->CLVL     := "8027"
//	_aP4A->TIPO     := "2E"
//	MsUnLock()
//ENDIF

//DbSelectArea("_aP4A")
//IF !DbSeek("8028"+"2E")
//	RecLock("_aP4A",.T.)
//	_aP4A->CLVL     := "8028"
//	_aP4A->TIPO     := "2E"
//	MsUnLock()
//ENDIF

DbSelectArea("_aP4A")
DbGoTop()
ProcRegua(RecCount())

lOK      := .T.
cCCant   := _aP4A->CLVL

nVLRAC1  := 0
nVLRAC2  := 0

nVLRAC   := 0
nTOTAL   := 0
nVLR01   := 0
nVLR02   := 0
nVLR03   := 0
nVLR04   := 0
nVLR05   := 0
nVLR06   := 0
nVLR07   := 0
nVLR08   := 0
nVLR09   := 0
nVLR10   := 0
nVLR11   := 0
nVLR12   := 0

nVLRS01   := 0
nVLRS02   := 0
nVLRS03   := 0
nVLRS04   := 0
nVLRS05   := 0
nVLRS06   := 0
nVLRS07   := 0
nVLRS08   := 0
nVLRS09   := 0
nVLRS10   := 0
nVLRS11   := 0
nVLRS12   := 0

nVLRACE1 := 0
nVLRACE2 := 0

nVLRACE  := 0
nTOTALE  := 0
nVLR01E  := 0
nVLR02E  := 0
nVLR03E  := 0
nVLR04E  := 0
nVLR05E  := 0
nVLR06E  := 0
nVLR07E  := 0
nVLR08E  := 0
nVLR09E  := 0
nVLR10E  := 0
nVLR11E  := 0
nVLR12E  := 0

nVLRACP1 := 0
nVLRACP2 := 0

nVLRACP  := 0
nTOTALP  := 0
nVLR01P  := 0
nVLR02P  := 0
nVLR03P  := 0
nVLR04P  := 0
nVLR05P  := 0
nVLR06P  := 0
nVLR07P  := 0
nVLR08P  := 0
nVLR09P  := 0
nVLR10P  := 0
nVLR11P  := 0
nVLR12P  := 0

nVLRACT1 := 0
nVLRACT2 := 0

nVLRACT  := 0
nTOTALT  := 0
nVLR01T  := 0
nVLR02T  := 0
nVLR03T  := 0
nVLR04T  := 0
nVLR05T  := 0
nVLR06T  := 0
nVLR07T  := 0
nVLR08T  := 0
nVLR09T  := 0
nVLR10T  := 0
nVLR11T  := 0
nVLR12T  := 0

While !Eof()
	cTempo := Alltrim(ElapTime(cHInicio, Time()))
	IncProc("Atualizando....    Tempo: "+cTempo)
	
	IF lOK
		fImpCabec4()
	ENDIF
	
	IF _aP4A->CLVL <> cCCant
		DbSelectArea("CTD")
		DbSetOrder(1)
		DbSeek(xFilial("CTD")+cCCant)
		
		xf_Item := +;
		Padc(SPACE(6)                                                                         ,06)+"  "+;
		Padr('Sub-Total'                                                                      ,33)+"  "+;
		Padr(SPACE(5)                                                                         ,05)+"  "+;
		Padl(Transform(nVLRAC1, "@E 99,999,999.99")                                           ,13)+"  "+;
		Padl(Transform(nVLRAC,  "@E 99,999,999.99")                                           ,13)+"  "+;
		Padl(Transform(nVLRS01,  "@E 99,999,999.99")                                          ,12)+"  "+;
		Padl(Transform(nVLRS02,  "@E 99,999,999.99")                                          ,12)+"  "+;
		Padl(Transform(nVLRS03,  "@E 99,999,999.99")                                          ,12)+"  "+;
		Padl(Transform(nVLRS04,  "@E 99,999,999.99")                                          ,12)+"  "+;
		Padl(Transform(nVLRS05,  "@E 99,999,999.99")                                          ,12)+"  "+;
		Padl(Transform(nVLRS06,  "@E 99,999,999.99")                                          ,12)+"  "+;
		Padl(Transform(nVLRS07,  "@E 99,999,999.99")                                          ,12)+"  "+;
		Padl(Transform(nVLRS08,  "@E 99,999,999.99")                                          ,12)+"  "+;
		Padl(Transform(nVLRS09,  "@E 99,999,999.99")                                          ,12)+"  "+;
		Padl(Transform(nVLRS10,  "@E 99,999,999.99")                                          ,12)+"  "+;
		Padl(Transform(nVLRS11,  "@E 99,999,999.99")                                          ,12)+"  "+;
		Padl(Transform(nVLRS12,  "@E 99,999,999.99")                                          ,12)+"  "+;
		Padl(Transform(nTOTAL,  "@E 99,999,999.99")                                           ,13)+"  "+;
		Padl(Transform(nVLRAC2,  "@E 99,999,999.99")                                          ,13)
		
		oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont7)
		oPrint:Line (nRow1+40, 010, nRow1+40, 3550)
		nRow1 += 050
		
		If nRow1 > 2150
			fImpRoda()
			fImpCabec4()
		EndIf
		
		nVLRAC1   := 0
		nVLRAC2   := 0
		
		nVLRAC    := 0
		nTOTAL    := 0
		nVLRS01   := 0
		nVLRS02   := 0
		nVLRS03   := 0
		nVLRS04   := 0
		nVLRS05   := 0
		nVLRS06   := 0
		nVLRS07   := 0
		nVLRS08   := 0
		nVLRS09   := 0
		nVLRS10   := 0
		nVLRS11   := 0
		nVLRS12   := 0
	ENDIF
	
	DbSelectArea("CTH")
	DbSetOrder(1)
	DbSeek(xFilial("CTH")+_aP4A->CLVL)
	IF _aP4A->CLVL == cCCant .OR. lOK
		IF lOK
			cNome  := CTH->CTH_DESC01
			IF CTH->CTH_BLOQ == '1'
				cStatus := "B"
			ELSE
				cStatus := "L"
			ENDIF
			CLVL := ALLTRIM(_aP4A->CLVL)+"-"+cStatus
		ELSE
			cNome   := SPACE(35)
			CLVL  := SPACE(6)
		ENDIF
		lOK     := .F.
	ELSE
		cNome  := CTH->CTH_DESC01
		IF CTH->CTH_BLOQ == '1'
			cStatus := "B"
		ELSE
			cStatus := "L"
		ENDIF
		CLVL := ALLTRIM(_aP4A->CLVL)+"-"+cStatus
	ENDIF
	
	IF _aP4A->TIPO == '1P'
		cDesc := "Planilha (P) - Previsoes de Desembolso"
	ELSE
		IF cEmpAnt == '01'
			cDesc := "Planilha (E) - Entradas de Notas Fiscais"
		ELSE
			cDesc := "Planilha (E) - Entradas de Notas Fiscais"
		ENDIF
	ENDIF
	
	nAc2004   := 0	 				  //Valor acumulado ate ano atual - 2
	nAcAtual  := 0     			      //Valor acumulado do ano atual
	nTotLinha := 0
	
	IF cEmpAnt == '01'
		nAcAnt := _aP4A->VLRAC        //Valor acumulado do ano anterior
	ELSE
		nAcAnt := 0
	ENDIF
	
	nVlr01    := _aP4A->VLR01
	nVlr02    := _aP4A->VLR02
	nVlr03    := _aP4A->VLR03
	nVlr04    := _aP4A->VLR04
	nVlr05    := _aP4A->VLR05
	
	IF cEmpAnt == '01'
		DO CASE
			CASE ALLTRIM(_aP4A->CLVL) == '8009' .AND. _aP4A->TIPO == '2E'
				nAc2004 := 14546180.90
				nAcAnt  := 0
				nVlr01  := 0
				nVlr02  := 0
				nVlr03  := 0
				nVlr04  := 0
				nVlr05  := 0
			CASE ALLTRIM(_aP4A->CLVL) == '8009' .AND. _aP4A->TIPO == '1P'
				nAc2004 := 13327188.68
				nAcAnt  := 0
				nVlr01  := 0
				nVlr02  := 0
				nVlr03  := 0
				nVlr04  := 0
				nVlr05  := 0
			CASE ALLTRIM(_aP4A->CLVL) == '8011' .AND. _aP4A->TIPO == '2E'
				nAc2004 := 1586089.33
				nAcAnt  := 0
				nVlr01  := 0
				nVlr02  := 0
				nVlr03  := 0
				nVlr04  := 0
				nVlr05  := 0
			CASE ALLTRIM(_aP4A->CLVL) == '8011' .AND. _aP4A->TIPO == '1P'
				nAc2004 := 2446503.91
				nAcAnt  := 0
				nVlr01  := 0
				nVlr02  := 0
				nVlr03  := 0
				nVlr04  := 0
				nVlr05  := 0        
			CASE ALLTRIM(_aP4A->CLVL) == '8016' .AND. _aP4A->TIPO == '2E'
				IF ALLTRIM(STR(YEAR(dDatabase))) == '2008'
					nAcAnt  := 232783.46
					nVlr01  := 11018.87
					nVlr02  := 10828.12
					nVlr03  := 17571.62
					nVlr04  :=  9023.47
					nVlr05  := 17205.40                   
				ENDIF
				IF ALLTRIM(STR(YEAR(dDatabase))) == '2009'
					nAc2004 := 232783.46				
					nAcAnt  := 65647.48
					nVlr01  := 58095.67
				ENDIF                     
				IF ALLTRIM(STR(YEAR(dDatabase))) >= '2010'
					nAc2004 := 298430.94
				    nAcAnt  := 58095.67
				ENDIF				    
			CASE ALLTRIM(_aP4A->CLVL) == '8017' .AND. _aP4A->TIPO == '2E'
				IF ALLTRIM(STR(YEAR(dDatabase))) == '2008'
					nAcAnt  := 745750.50
					nVlr01  := 30105.42
					nVlr02  := 52210.01
					nVlr03  := 28474.53
					nVlr04  := 67793.02
					nVlr05  := 53843.46
				ENDIF
				IF ALLTRIM(STR(YEAR(dDatabase))) == '2009'
					nAc2004 := 745750.50
					nAcAnt  := 428383.26
					nVlr01  := 233800.50
				ENDIF                     
				IF ALLTRIM(STR(YEAR(dDatabase))) >= '2010'
					nAc2004 := 1174133.76
				    nAcAnt  := 233800.50
				ENDIF				    
			CASE ALLTRIM(_aP4A->CLVL) == '8018' .AND. _aP4A->TIPO == '1P'
				IF ALLTRIM(STR(YEAR(dDatabase))) == '2008'
					nAcAnt  := 201140.00
					nVlr01  := 0
					nVlr02  := 0
					nVlr03  := 0
					nVlr04  := 0
					nVlr05  := 0
				ENDIF
			CASE ALLTRIM(_aP4A->CLVL) == '8019' .AND. _aP4A->TIPO == '2E'
				IF ALLTRIM(STR(YEAR(dDatabase))) == '2008'
					nAcAnt  := 225349.47
					nVlr01  :=  18344.42
					nVlr02  :=  36245.67
					nVlr03  :=  66715.36
					nVlr04  := 155141.50
					nVlr05  := 714072.84
				ENDIF
				IF ALLTRIM(STR(YEAR(dDatabase))) == '2009'
					nAc2004 := 225349.47
					nAcAnt  := 10964352.79
				ENDIF                     
				IF ALLTRIM(STR(YEAR(dDatabase))) >= '2010'
					nAc2004 := 11189702.26
				    nAcAnt  := 106269.02
				ENDIF				    
			CASE ALLTRIM(_aP4A->CLVL) == '8022' .AND. _aP4A->TIPO == '2E'
				IF ALLTRIM(STR(YEAR(dDatabase))) == '2008'
					nAcAnt  := 1817062.15
					nVlr01  := 549568.68
					nVlr02  := 273833.45
					nVlr03  := 393101.62
					nVlr04  := 52847.19
					nVlr05  := 34456.87
				ENDIF
				IF ALLTRIM(STR(YEAR(dDatabase))) == '2009'
					nAc2004 := 1817062.15
					nAcAnt  := 1403858.80
				ENDIF                     
				IF ALLTRIM(STR(YEAR(dDatabase))) >= '2010'
					nAc2004 := 3220920.95
				    nAcAnt  := 0
				ENDIF				    
			CASE ALLTRIM(_aP4A->CLVL) == '8023' .AND. _aP4A->TIPO == '2E'
				IF ALLTRIM(STR(YEAR(dDatabase))) == '2008'
					nAcAnt  := 566322.71
					nVlr01  := 1318.20
					nVlr02  := 0
					nVlr03  := 0
					nVlr04  := 0
					nVlr05  := 0
				ENDIF
				IF ALLTRIM(STR(YEAR(dDatabase))) == '2009'
					nAc2004 := 566322.71
					nAcAnt  := 1318.20
				ENDIF                     
				IF ALLTRIM(STR(YEAR(dDatabase))) >= '2010'
					nAc2004 := 567640.91
				    nAcAnt  := 0
				ENDIF				    
			CASE ALLTRIM(_aP4A->CLVL) == '8024' .AND. _aP4A->TIPO == '2E'
				IF ALLTRIM(STR(YEAR(dDatabase))) == '2008'
					nVlr01  := 0
					nVlr02  := 0
					nVlr03  := 10172.71
					nVlr04  := 25893.28
					nVlr05  := 0
				ENDIF
				IF ALLTRIM(STR(YEAR(dDatabase))) == '2009'
					nAcAnt  := 36065.99
				ENDIF
				IF ALLTRIM(STR(YEAR(dDatabase))) >= '2010'
					nAc2004 := 36065.99
				ENDIF
			CASE ALLTRIM(_aP4A->CLVL) == '8025' .AND. _aP4A->TIPO == '2E'
				IF ALLTRIM(STR(YEAR(dDatabase))) = '2008'
					nVlr01  := 0
					nVlr02  := 0
					nVlr03  := 10421.58
					nVlr04  := 0
					nVlr05  := 0
				ENDIF
				IF ALLTRIM(STR(YEAR(dDatabase))) == '2009'
					nAc2004 := 10421.58
				ENDIF
				IF ALLTRIM(STR(YEAR(dDatabase))) >= '2010'
					nAc2004 := 10421.58
				ENDIF

			//CASE ALLTRIM(_aP4A->CLVL) == '8026' .AND. _aP4A->TIPO == '2E'
			//	IF ALLTRIM(STR(YEAR(dDatabase))) >= '2009'
			//		nAcAnt  := 25943.76
			//	ENDIF

			
			//CASE ALLTRIM(_aP4A->CLVL) == '8027' .AND. _aP4A->TIPO == '2E'
			//	IF ALLTRIM(STR(YEAR(dDatabase))) >= '2010'
			//		nAcAnt  := 939759.14
			//	ENDIF
				
			//CASE ALLTRIM(_aP4A->CLVL) == '8028' .AND. _aP4A->TIPO == '2E'
			// 	IF ALLTRIM(STR(YEAR(dDatabase))) >= '2008'
			//		nAcAnt  := 8000.00
			//	ENDIF
							
			//CASE ALLTRIM(_aP4A->CLVL) == '8030' .AND. _aP4A->TIPO == '2E'
			//	IF ALLTRIM(STR(YEAR(dDatabase))) >= '2010'
			//		nAcAnt  := 11432374.90
			//	ENDIF
				
			//CASE ALLTRIM(_aP4A->CLVL) == '8051' .AND. _aP4A->TIPO == '2E'
			//	IF ALLTRIM(STR(YEAR(dDatabase))) >= '2011'
			//		nAcAnt  := nAcAnt + 42692036.33
			//	ENDIF
			
		ENDCASE
	ENDIF    
	
	//IF ALLTRIM(_aP4A->CLVL) == '8030'
	//   lllOK := .T.
	//ENDIF
	
	nTotLin := (nVlr01 + nVlr02 + nVlr03 + nVlr04 + nVlr05 + _aP4A->VLR06 + _aP4A->VLR07 + _aP4A->VLR08 + _aP4A->VLR09 + _aP4A->VLR10 + _aP4A->VLR11 + _aP4A->VLR12)
	
	xf_Item := +;
	Padc(CLVL                                                                                   ,06)+"  "+;
	Padl(cNome                                                                                  ,33)+"  "+;
	Padr(SUBSTR(_aP4A->TIPO,2,1)                                                                ,05)+"  "+;
	Padl(Transform(nAc2004,  "@E 99,999,999.99")                                                ,13)+"  "+;
	Padl(Transform(nAcAnt,   "@E 99,999,999.99")                                                ,13)+"  "+;
	Padl(Transform(nVlr01,   "@E 99,999,999.99")                                                ,12)+"  "+;
	Padl(Transform(nVlr02,   "@E 99,999,999.99")                                                ,12)+"  "+;
	Padl(Transform(nVlr03,   "@E 99,999,999.99")                                                ,12)+"  "+;
	Padl(Transform(nVlr04,   "@E 99,999,999.99")                                                ,12)+"  "+;
	Padl(Transform(nVlr05,   "@E 99,999,999.99")                                                ,12)+"  "+;
	Padl(Transform(_aP4A->VLR06,  "@E 99,999,999.99")                                           ,12)+"  "+;
	Padl(Transform(_aP4A->VLR07,  "@E 99,999,999.99")                                           ,12)+"  "+;
	Padl(Transform(_aP4A->VLR08,  "@E 99,999,999.99")                                           ,12)+"  "+;
	Padl(Transform(_aP4A->VLR09,  "@E 99,999,999.99")                                           ,12)+"  "+;
	Padl(Transform(_aP4A->VLR10,  "@E 99,999,999.99")                                           ,12)+"  "+;
	Padl(Transform(_aP4A->VLR11,  "@E 99,999,999.99")                                           ,12)+"  "+;
	Padl(Transform(_aP4A->VLR12,  "@E 99,999,999.99")                                           ,12)+"  "+;
	Padl(Transform(nTotLin,  "@E 99,999,999.99")                                                ,13)+"  "+;
	Padl(Transform(nTotLin+nAc2004+nAcAnt,  "@E 99,999,999.99")                                 ,13)
	
	oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont7)
	nRow1 += 050
	
	If nRow1 > 2150
		fImpRoda()
		fImpCabec4()
	EndIf
	
	nVLRAC1  := nVLRAC1  + nAc2004
	nVLRAC2  := nVLRAC2  + nAc2004 + nAcAnt + nTotLin
	
	nVLRAC    := nVLRAC    + nAcAnt
	nTOTAL    := nTOTAL    + nTotLin
	nVLRS01   := nVLRS01   + nVlr01
	nVLRS02   := nVLRS02   + nVlr02
	nVLRS03   := nVLRS03   + nVlr03
	nVLRS04   := nVLRS04   + nVlr04
	nVLRS05   := nVLRS05   + nVlr05
	nVLRS06   := nVLRS06   + _aP4A->VLR06
	nVLRS07   := nVLRS07   + _aP4A->VLR07
	nVLRS08   := nVLRS08   + _aP4A->VLR08
	nVLRS09   := nVLRS09   + _aP4A->VLR09
	nVLRS10   := nVLRS10   + _aP4A->VLR10
	nVLRS11   := nVLRS11   + _aP4A->VLR11
	nVLRS12   := nVLRS12   + _aP4A->VLR12
	
	IF _aP4A->TIPO == '1P'
		nVLRACP1   := nVLRACP1 + nAc2004
		nVLRACP2   := nVLRACP2 + nAc2004 + nAcAnt + nTotLin
		
		nVLRACP   := nVLRACP   + nAcAnt
		nTOTALP   := nTOTALP   + nTotLin
		nVLR01P   := nVLR01P   + nVlr01
		nVLR02P   := nVLR02P   + nVlr02
		nVLR03P   := nVLR03P   + nVlr03
		nVLR04P   := nVLR04P   + nVlr04
		nVLR05P   := nVLR05P   + nVlr05
		nVLR06P   := nVLR06P   + _aP4A->VLR06
		nVLR07P   := nVLR07P   + _aP4A->VLR07
		nVLR08P   := nVLR08P   + _aP4A->VLR08
		nVLR09P   := nVLR09P   + _aP4A->VLR09
		nVLR10P   := nVLR10P   + _aP4A->VLR10
		nVLR11P   := nVLR11P   + _aP4A->VLR11
		nVLR12P   := nVLR12P   + _aP4A->VLR12
	ELSE
		nVLRACE1  := nVLRACE1  + nAc2004
		nVLRACE2  := nVLRACE2  + nAc2004 + nAcAnt + nTotLin
		
		nVLRACE   := nVLRACE   + nAcAnt
		nTOTALE   := nTOTALE   + nTotLin
		nVLR01E   := nVLR01E   + nVlr01
		nVLR02E   := nVLR02E   + nVlr02
		nVLR03E   := nVLR03E   + nVlr03
		nVLR04E   := nVLR04E   + nVlr04
		nVLR05E   := nVLR05E   + nVlr05
		nVLR06E   := nVLR06E   + _aP4A->VLR06
		nVLR07E   := nVLR07E   + _aP4A->VLR07
		nVLR08E   := nVLR08E   + _aP4A->VLR08
		nVLR09E   := nVLR09E   + _aP4A->VLR09
		nVLR10E   := nVLR10E   + _aP4A->VLR10
		nVLR11E   := nVLR11E   + _aP4A->VLR11
		nVLR12E   := nVLR12E   + _aP4A->VLR12
	ENDIF
	
	nVLRACT1  := nVLRACT1  + nAc2004
	nVLRACT2  := nVLRACT2  + nAc2004 + nAcAnt + nTotLin
	
	nVLRACT   := nVLRACT   + nAcAnt
	nTOTALT   := nTOTALT   + nTotLin
	nVLR01T   := nVLR01T   + nVlr01
	nVLR02T   := nVLR02T   + nVlr02
	nVLR03T   := nVLR03T   + nVlr03
	nVLR04T   := nVLR04T   + nVlr04
	nVLR05T   := nVLR05T   + nVlr05
	nVLR06T   := nVLR06T   + _aP4A->VLR06
	nVLR07T   := nVLR07T   + _aP4A->VLR07
	nVLR08T   := nVLR08T   + _aP4A->VLR08
	nVLR09T   := nVLR09T   + _aP4A->VLR09
	nVLR10T   := nVLR10T   + _aP4A->VLR10
	nVLR11T   := nVLR11T   + _aP4A->VLR11
	nVLR12T   := nVLR12T   + _aP4A->VLR12
	
	cCCant   := _aP4A->CLVL
	
	DbSelectArea("_aP4A")
	DbSkip()
End

DbSelectArea("CTH")
DbSetOrder(1)
DbSeek(xFilial("CTH")+cCCant)

xf_Item := +;
Padc(SPACE(6)                                                                         ,06)+"  "+;
Padr('Sub-Total'                                                                      ,33)+"  "+;
Padr(SPACE(5)                                                                         ,05)+"  "+;
Padl(Transform(nVLRAC1, "@E 99,999,999.99")                                           ,13)+"  "+;
Padl(Transform(nVLRAC,  "@E 99,999,999.99")                                           ,13)+"  "+;
Padl(Transform(nVLRS01,  "@E 99,999,999.99")                                           ,12)+"  "+;
Padl(Transform(nVLRS02,  "@E 99,999,999.99")                                           ,12)+"  "+;
Padl(Transform(nVLRS03,  "@E 99,999,999.99")                                           ,12)+"  "+;
Padl(Transform(nVLRS04,  "@E 99,999,999.99")                                           ,12)+"  "+;
Padl(Transform(nVLRS05,  "@E 99,999,999.99")                                           ,12)+"  "+;
Padl(Transform(nVLRS06,  "@E 99,999,999.99")                                           ,12)+"  "+;
Padl(Transform(nVLRS07,  "@E 99,999,999.99")                                           ,12)+"  "+;
Padl(Transform(nVLRS08,  "@E 99,999,999.99")                                           ,12)+"  "+;
Padl(Transform(nVLRS09,  "@E 99,999,999.99")                                           ,12)+"  "+;
Padl(Transform(nVLRS10,  "@E 99,999,999.99")                                           ,12)+"  "+;
Padl(Transform(nVLRS11,  "@E 99,999,999.99")                                           ,12)+"  "+;
Padl(Transform(nVLRS12,  "@E 99,999,999.99")                                           ,12)+"  "+;
Padl(Transform(nTOTAL,  "@E 99,999,999.99")                                           ,13)+"  "+;
Padl(Transform(nVLRAC2, "@E 99,999,999.99")                                           ,13)

oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont7)
oPrint:Line (nRow1+40, 010, nRow1+40, 3550)
nRow1 += 050

If nRow1 > 2150
	fImpRoda()
	fImpCabec4()
EndIf

xf_Item := +;
Padc(SPACE(6)                                                                         ,06)+"  "+;
Padr(SPACE(35)                                                                        ,33)+"  "+;
Padr('E'                                                                              ,05)+"  "+;
Padl(Transform(nVLRACE1, "@E 99,999,999.99")                                          ,13)+"  "+;
Padl(Transform(nVLRACE,  "@E 99,999,999.99")                                          ,13)+"  "+;
Padl(Transform(nVLR01E,  "@E 99,999,999.99")                                          ,12)+"  "+;
Padl(Transform(nVLR02E,  "@E 99,999,999.99")                                          ,12)+"  "+;
Padl(Transform(nVLR03E,  "@E 99,999,999.99")                                          ,12)+"  "+;
Padl(Transform(nVLR04E,  "@E 99,999,999.99")                                          ,12)+"  "+;
Padl(Transform(nVLR05E,  "@E 99,999,999.99")                                          ,12)+"  "+;
Padl(Transform(nVLR06E,  "@E 99,999,999.99")                                          ,12)+"  "+;
Padl(Transform(nVLR07E,  "@E 99,999,999.99")                                          ,12)+"  "+;
Padl(Transform(nVLR08E,  "@E 99,999,999.99")                                          ,12)+"  "+;
Padl(Transform(nVLR09E,  "@E 99,999,999.99")                                          ,12)+"  "+;
Padl(Transform(nVLR10E,  "@E 99,999,999.99")                                          ,12)+"  "+;
Padl(Transform(nVLR11E,  "@E 99,999,999.99")                                          ,12)+"  "+;
Padl(Transform(nVLR12E,  "@E 99,999,999.99")                                          ,12)+"  "+;
Padl(Transform(nTOTALE,  "@E 99,999,999.99")                                          ,13)+"  "+;
Padl(Transform(nVLRACE2, "@E 99,999,999.99")                                         ,13)

oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont7)
oPrint:Line (nRow1+40, 010, nRow1+40, 3550)
nRow1 += 050

If nRow1 > 2150
	fImpRoda()
	fImpCabec4()
EndIf

xf_Item := +;
Padc(SPACE(6)                                                                         ,06)+"  "+;
Padr(SPACE(35)                                                                        ,33)+"  "+;
Padr('P'                                                                              ,05)+"  "+;
Padl(Transform(nVLRACP1, "@E 99,999,999.99")                                          ,13)+"  "+;
Padl(Transform(nVLRACP,  "@E 99,999,999.99")                                          ,13)+"  "+;
Padl(Transform(nVLR01P,  "@E 99,999,999.99")                                          ,12)+"  "+;
Padl(Transform(nVLR02P,  "@E 99,999,999.99")                                          ,12)+"  "+;
Padl(Transform(nVLR03P,  "@E 99,999,999.99")                                          ,12)+"  "+;
Padl(Transform(nVLR04P,  "@E 99,999,999.99")                                          ,12)+"  "+;
Padl(Transform(nVLR05P,  "@E 99,999,999.99")                                          ,12)+"  "+;
Padl(Transform(nVLR06P,  "@E 99,999,999.99")                                          ,12)+"  "+;
Padl(Transform(nVLR07P,  "@E 99,999,999.99")                                          ,12)+"  "+;
Padl(Transform(nVLR08P,  "@E 99,999,999.99")                                          ,12)+"  "+;
Padl(Transform(nVLR09P,  "@E 99,999,999.99")                                          ,12)+"  "+;
Padl(Transform(nVLR10P,  "@E 99,999,999.99")                                          ,12)+"  "+;
Padl(Transform(nVLR11P,  "@E 99,999,999.99")                                          ,12)+"  "+;
Padl(Transform(nVLR12P,  "@E 99,999,999.99")                                          ,12)+"  "+;
Padl(Transform(nTOTALP,  "@E 99,999,999.99")                                          ,13)+"  "+;
Padl(Transform(nVLRACP2, "@E 99,999,999.99")                                          ,13)

oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont7)
oPrint:Line (nRow1+40, 010, nRow1+40, 3550)
nRow1 += 050

If nRow1 > 2150
	fImpRoda()
	fImpCabec4()
EndIf

xf_Item := +;
Padc(SPACE(6)                                                                         ,06)+"  "+;
Padr(SPACE(35)                                                                        ,33)+"  "+;
Padr('TOTAL'                                                                          ,05)+"  "+;
Padl(Transform(nVLRACT1, "@E 99,999,999.99")                                          ,13)+"  "+;
Padl(Transform(nVLRACT,  "@E 99,999,999.99")                                          ,13)+"  "+;
Padl(Transform(nVLR01T,  "@E 99,999,999.99")                                          ,12)+"  "+;
Padl(Transform(nVLR02T,  "@E 99,999,999.99")                                          ,12)+"  "+;
Padl(Transform(nVLR03T,  "@E 99,999,999.99")                                          ,12)+"  "+;
Padl(Transform(nVLR04T,  "@E 99,999,999.99")                                          ,12)+"  "+;
Padl(Transform(nVLR05T,  "@E 99,999,999.99")                                          ,12)+"  "+;
Padl(Transform(nVLR06T,  "@E 99,999,999.99")                                          ,12)+"  "+;
Padl(Transform(nVLR07T,  "@E 99,999,999.99")                                          ,12)+"  "+;
Padl(Transform(nVLR08T,  "@E 99,999,999.99")                                          ,12)+"  "+;
Padl(Transform(nVLR09T,  "@E 99,999,999.99")                                          ,12)+"  "+;
Padl(Transform(nVLR10T,  "@E 99,999,999.99")                                          ,12)+"  "+;
Padl(Transform(nVLR11T,  "@E 99,999,999.99")                                          ,12)+"  "+;
Padl(Transform(nVLR12T,  "@E 99,999,999.99")                                          ,12)+"  "+;
Padl(Transform(nTOTALT,  "@E 99,999,999.99")                                          ,13)+"  "+;
Padl(Transform(nVLRACT2, "@E 999,999,999.99")                                         ,14)

oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont7)
oPrint:Line (nRow1+40, 010, nRow1+40, 3550)
nRow1 += 050

xf_Item := +;
Padc('Legenda: E=Equipamento, P=Projeto, L=CC Liberado, B=CC Bloqueado'       ,100)
oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont7)
oPrint:Line (nRow1+40, 010, nRow1+40, 3550)
nRow1 += 050

If nRow1 > 2150
	fImpRoda()
	fImpCabec4()
EndIf

fImpRoda()

oPrint:EndPage()
oPrint:Preview()
Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ fImpCabec¦ Autor ¦ Wanisay William       ¦ Data ¦ 13.02.08 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fImpCabec()

DO CASE
	CASE nFlag == 1
		fCabec   := "Investimentos (P) - "+ALLTRIM(cCC)+" Prev. Desemb."
	CASE nFlag == 2
		fCabec   := "Investimentos (E) - "+ALLTRIM(cCC)+" Prev. Desemb."
	CASE nFlag == 3
		fCabec   := "Investimentos GERAL - "+ALLTRIM(cCC)+" Prev. Desemb."
ENDCASE

DbSelectArea("CTH")
DbSetOrder(1)
DbSeek(xFilial("CTH")+cCC)
fCabec2 := ALLTRIM(CTH->CTH_DESC01)+' - Mes de Referencia '+ALLTRIM(U_MES(MV_PAR02))+'/'+STR(YEAR(MV_PAR02),4)

oPrint:StartPage()
wnPag ++
nRow1 := 050
If File(aBitmap)
	oPrint:SayBitmap( nRow1,0050,aBitmap,0500,0150 )
EndIf
nRow1 += 025
oPrint:Say  (nRow1   , 0050 ,Padc(fCabec,098)                        ,oFont14)
oPrint:Say  (nRow1+20 ,2950 ,"Página:"                               ,oFont7)
oPrint:Say  (nRow1+15 ,3100 ,StrZero(wnPag,4)                        ,oFont8)
nRow1 += 075
oPrint:Say  (nRow1   , 0050 ,Padc(fCabec2,133)                       ,oFont10)
nRow1 += 150

xf_Titu := +;
Padr("CLVL"                       ,09)+"  "+;
Padr("Codigo"                     ,09)+"  "+;
Padr("Descricao"                  ,35)+"  "+;
Padr("Fornecedor"                 ,35)+"  "+;
Padr("NF/REQ"                     ,09)+"  "+;
Padr("Descricao do Material"      ,30)+"  "+;
Padr("Data"                       ,08)+"  "+;
Padl("Valor Liquido"              ,14)+"  "+;
Padl("Valor Pago"                 ,14)

oPrint:Say  (nRow1 ,0010 ,xf_Titu   ,oFont8)
oPrint:Line (nRow1+40, 010, nRow1+40, 3550)

nRow1 += 075

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ fImpCabec¦ Autor ¦ Wanisay William       ¦ Data ¦ 13.02.08 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fImpCabec2()

DO CASE
	CASE nFlag == 1
		fCabec   := "Investimentos - "+ALLTRIM(cCC)+" Planilha (P) - Previsões de Desembolso."
	CASE nFlag == 2
		fCabec   := "Investimentos - "+ALLTRIM(cCC)+" Planilha (E) - Previsões de Desembolso."
	CASE nFlag == 3
		fCabec   := "Investimentos - "+ALLTRIM(cCC)+" Planilha GERAL - Previsões de Desembolso."
ENDCASE

DbSelectArea("CTH")
DbSetOrder(1)
DbSeek(xFilial("CTH")+cCC)
fCabec2 := ALLTRIM(CTH->CTH_DESC01)+' - Mes de Referencia '+ALLTRIM(U_MES(MV_PAR02))+'/'+STR(YEAR(MV_PAR02),4)

oPrint:StartPage()
wnPag ++
nRow1 := 050
If File(aBitmap)
	oPrint:SayBitmap( nRow1,0050,aBitmap,0500,0150 )
EndIf
nRow1 += 025
oPrint:Say  (nRow1   , 0050 ,Padc(fCabec,098)                        ,oFont14)
oPrint:Say  (nRow1+20 ,2950 ,"Página:"                               ,oFont7)
oPrint:Say  (nRow1+15 ,3100 ,StrZero(wnPag,4)                        ,oFont8)
nRow1 += 075
oPrint:Say  (nRow1   , 0050 ,Padc(fCabec2,133)                       ,oFont10)
nRow1 += 150

xf_Titu := +;
Padr("Codigo"                     ,09)+"  "+;
Padr("Tipos de Gastos"            ,80)+"  "+;
Padl("Total Liquido"              ,14)+"  "+;
Padl("Total Pago"                 ,14)

oPrint:Say  (nRow1 ,0010 ,xf_Titu   ,oFont8)
oPrint:Line (nRow1+40, 010, nRow1+40, 3550)

nRow1 += 075

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ fImpCabec¦ Autor ¦ Wanisay William       ¦ Data ¦ 13.02.08 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fImpCabec3()

fCabec   := "Resumo dos Investimentos na Classe de Valor "+ALLTRIM(cCC)

DbSelectArea("CTH")
DbSetOrder(1)
DbSeek(xFilial("CTH")+cCC)
fCabec2 := ALLTRIM(CTH->CTH_DESC01)+' - Mes de Referencia '+ALLTRIM(U_MES(MV_PAR02))+'/'+STR(YEAR(MV_PAR02),4)

oPrint:StartPage()
wnPag ++
nRow1 := 050
If File(aBitmap)
	oPrint:SayBitmap( nRow1,0050,aBitmap,0500,0150 )
EndIf
nRow1 += 025
oPrint:Say  (nRow1   , 0050 ,Padc(fCabec,098)                        ,oFont14)
oPrint:Say  (nRow1+20 ,2950 ,"Página:"                               ,oFont7)
oPrint:Say  (nRow1+15 ,3100 ,StrZero(wnPag,4)                        ,oFont8)
nRow1 += 075
oPrint:Say  (nRow1   , 0050 ,Padc(fCabec2,133)                       ,oFont10)
nRow1 += 150

IF MV_PAR04 == 1
	xf_Titu := +;
	Padc(""                                   ,100)+"  "+;
	Padl("Total Liquido - Valores em UV"      ,30)+"  "+;
	Padl("Total Pago - Valores em UV"         ,30)
ELSE
	xf_Titu := +;
	Padc(""                                   ,100)+"  "+;
	Padl("Total Liquido - Valores em R$"      ,30)+"  "+;
	Padl("Total Pago - Valores em R$"         ,30)
ENDIF

oPrint:Say  (nRow1 ,0010 ,xf_Titu   ,oFont8)
oPrint:Line (nRow1+40, 010, nRow1+40, 3550)

nRow1 += 075

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ fImpCabec4¦ Autor ¦ Wanisay William      ¦ Data ¦ 13.02.08 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fImpCabec4()

fCabec   := "Resumo dos Investimentos - Acumulado - "+ALLTRIM(STR(YEAR(dDatabase)))
fCabec2  := "Período: de "+DTOC(MV_PAR01)+" até "+DTOC(MV_PAR02)

oPrint:StartPage()
wnPag ++
nRow1 := 050
If File(aBitmap)
	oPrint:SayBitmap( nRow1,0050,aBitmap,0500,0150 )
EndIf
nRow1 += 025
oPrint:Say  (nRow1   , 0050 ,Padc(fCabec,098)                        ,oFont14)
oPrint:Say  (nRow1+20 ,2950 ,"Página:"                               ,oFont7)
oPrint:Say  (nRow1+15 ,3100 ,StrZero(wnPag,4)                        ,oFont8)
nRow1 += 075
oPrint:Say  (nRow1   , 0050 ,Padc(fCabec2,133)                       ,oFont10)
nRow1 += 150

cAno     := ALLTRIM(STR(YEAR(dDatabase)))
cAnoAnt1 := ALLTRIM(STR(YEAR(dDatabase)-2))
cAnoAnt2 := ALLTRIM(STR(YEAR(dDatabase)-1))

xf_Titu := +;
Padr("CC"                         ,05)+"  "+;
Padr("Descricao"                  ,33)+"  "+;
Padr("Tipo"                       ,05)+"  "+;
Padl("Ac-2004/"+cAnoAnt1          ,13)+"  "+;
Padl("Ac-"+cAnoAnt2               ,13)+"  "+;
Padl("JAN"                        ,12)+"  "+;
Padl("FEV"                        ,12)+"  "+;
Padl("MAR"                        ,12)+"  "+;
Padl("ABR"                        ,12)+"  "+;
Padl("MAI"                        ,12)+"  "+;
Padl("JUN"                        ,12)+"  "+;
Padl("JUL"                        ,12)+"  "+;
Padl("AGO"                        ,12)+"  "+;
Padl("SET"                        ,12)+"  "+;
Padl("OUT"                        ,12)+"  "+;
Padl("NOV"                        ,12)+"  "+;
Padl("DEZ"                        ,12)+"  "+;
Padl("Ac-"+cAno                   ,13)+"  "+;
Padl("Ac-2004/"+cAno              ,13)

oPrint:Say  (nRow1 ,0010 ,xf_Titu   ,oFont7)
oPrint:Line (nRow1+40, 010, nRow1+40, 3550)

nRow1 += 075

Return

/*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ fImpRoda ¦ Autor ¦ Wanisay William       ¦ Data ¦ 13.02.08 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fImpRoda()

oPrint:Line (2300, 010, 2300, 3550)
oPrint:Say  (2300+30 , 010,"Prog.: BIA430"                                        ,oFont7)
oPrint:Say  (2300+30 ,2500,"Impresso em:  "+dtoc(dDataBase)+"  "+TIME()           ,oFont7)
oPrint:EndPage()
nRow1 := 4000

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ ValidPerg¦ Autor ¦ Wanisay William       ¦ Data ¦ 28.04.08 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function ValidPerg()
local j,i
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(fPerg,10)
aRegs:={}

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
/*
aAdd(aRegs,{cPerg,"01","Da Data                ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Ate Data               ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Tipo                   ?","","","mv_ch3","C",01,0,0,"C","","mv_par03","Planilha","Planilha","Planilha","","","Contabil","Contabil","Contabil","","","Ambos","Ambos","Ambos","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","Utiliza Fator          ?","","","mv_ch4","C",01,0,0,"C","","mv_par04","Sim","Sim","Sim","","","Nao","Nao","Nao","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"05","CC Inicial             ?","","","mv_ch5","C",10,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"06","CC Final               ?","","","mv_ch6","C",10,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","",""})
*/
//Gabriel - Facile - Número Da Pergunta diferente pois foram inseridas novas no SX1
aAdd(aRegs,{cPerg,"09","Gerar Excel            ?","","","mv_ch9","N",01,0,0,"C","","mv_par09","Sim","Sim","Sim","","","Nao","Nao","Nao","","","","","","","","","","","","","","","","",""})

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

Static Function fImpExcel()

	Local nTotReg	:=	0
	local nRegAtu   := 0
*	Local _cBaia	:=	""

	local cCab1Fon	:= 'Calibri' 
	local cCab1TamF	:= 8   
	local cCab1CorF := '#FFFFFF'
	local cCab1Fun	:= '#4F81BD'

	local cFonte1	 := 'Arial'
	local nTamFont1	 := 12   
	local cCorFont1  := '#FFFFFF'
	local cCorFun1	 := '#4F81BD'

	local cFonte2	 := 'Arial'
	local nTamFont2	 := 8   
	local cCorFont2  := '#000000'
	local cCorFun2	 := '#B8CCE4'
*	Local nConsumo	 :=	0
	Local _nI

	local cEmpresa  := CapitalAce(SM0->M0_NOMECOM)

	local cArqXML   := "BIA430_"+ALLTrim( DTOS(DATE())+"_"+StrTran( time(),':',''))


	If Empty(_aItRpt1) .And. Empty(_aItRpt2)
		Return
	EndIf

	oExcel := ARSexcel():New()

	If !Empty(_aItRpt1)

	
		nTotReg	:=	Len(_aItRpt1) 
	
		ProcRegua(nTotReg + 2)
	
		nRegAtu++
		IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(99,2)) + "%")	
	
		oExcel:AddPlanilha("Analitico",{20,23,30,120,160,33,190,43,51,44},6)
	
		oExcel:AddLinha(20)
		oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,10) 
		oExcel:AddLinha(15)
		oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2,10) 
		oExcel:AddLinha(15)
		oExcel:AddLinha(20)
		oExcel:AddCelula("Investimentos - Analítico ",0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,10)  
	
		oExcel:AddLinha(20)
		oExcel:AddLinha(12) 
		oExcel:AddCelula()
		oExcel:AddCelula("CLVL"						,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula("Codigo"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula("Descricao"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula("Fornecedor"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula("NF/REQ"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula("Descricao do Material"	,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula("Data"						,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula("Valor Liquido"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula("Valor Pago"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)		
		oExcel:AddCelula("Valor Liquido Real"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula("Valor Pago Real"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)

		For _nI	:=	1 to Len(_aItRpt1)
	
			nRegAtu++
	
			if MOD(nRegAtu,2) > 0 
				cCorFun2 := '#DCE6F1'
			else
				cCorFun2 := '#B8CCE4'
			endif
	
			oExcel:AddLinha(14) 
			oExcel:AddCelula()
	
			oExcel:AddCelula(_aItRpt1[_nI,1]	,0		,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula(_aItRpt1[_nI,2]	,0		,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula(_aItRpt1[_nI,3]	,0		,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula(_aItRpt1[_nI,4]	,0		,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula(_aItRpt1[_nI,5]	,0		,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula(_aItRpt1[_nI,6]	,0		,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula(_aItRpt1[_nI,7]	,0		,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula(_aItRpt1[_nI,8]	,0		,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula(_aItRpt1[_nI,9]	,0		,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
	
			oExcel:AddCelula(_aItRpt1[_nI,10]	,0		,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula(_aItRpt1[_nI,11]	,0		,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
	
			IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(99,2)) + "%")

		Next

	EndIf

	If !Empty(_aItRpt2)

	
		nTotReg	:=	Len(_aItRpt2) 
	
		ProcRegua(nTotReg + 2)
	
		nRegAtu++
		IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(99,2)) + "%")	
	
		oExcel:AddPlanilha("Sintetico",{20,30,120,50,50,50,50},6)
	
		oExcel:AddLinha(20)
		oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,5) 
		oExcel:AddLinha(15)
		oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2,5) 
		oExcel:AddLinha(15)
		oExcel:AddLinha(20)
		oExcel:AddCelula("Investimentos - Sintético ",0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,5)  
	
		oExcel:AddLinha(20)
		oExcel:AddLinha(12) 
		oExcel:AddCelula()
		oExcel:AddCelula("Codigo"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula("Tipos de Gastos"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula("Total Liquido"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula("Total Pago"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)		
		oExcel:AddCelula("Total Liquido Real"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula("Total Pago Real"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
		For _nI	:=	1 to Len(_aItRpt2)
	
			nRegAtu++
	
			if MOD(nRegAtu,2) > 0 
				cCorFun2 := '#DCE6F1'
			else
				cCorFun2 := '#B8CCE4'
			endif
	
			oExcel:AddLinha(14) 
			oExcel:AddCelula()
	
			oExcel:AddCelula(_aItRpt2[_nI,1]	,0		,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula(_aItRpt2[_nI,2]	,0		,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula(_aItRpt2[_nI,3]	,0		,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula(_aItRpt2[_nI,4]	,0		,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)

			oExcel:AddCelula(_aItRpt2[_nI,5]	,0		,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula(_aItRpt2[_nI,6]	,0		,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
	
			IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(99,2)) + "%")
	
			
	
		Next

	EndIf


	
	oExcel:SaveXml(Alltrim(GetTempPath()),cArqXML,.T.) 

	nRegAtu++
	IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(100,3)) + "%")

	

Return
