#include "rwmake.ch"
#include "protheus.ch"
#INCLUDE "TOPCONN.CH"

User Function BIA459()

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ BIA459     ³ Autor ³ Biancogres           ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Importacao das metas da INDG                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Private _cARQ    := ""
Private _nQTDREG := 0
Private _nTamLin := 130                  // Tamanho da linha no arquivo texto   681
Private _cBuffer := Space(_nTamLin + 2)  // Guarda a linha lida
Private _nBytes  := 0                    // Guarda numero da linha
Private _nhdl    := Fopen(_cARQ,0)       // Abre o arquivo so leitura
Private _cDIR    := ""                   // Diretorio dos arquivos TXT recebimento
Private _cIMPORT := ""                   // Nome do arquivo TXT de recebimento
Private cEmpresa := ""
Private cSegment := ""
Private cRepres  := ""
Private cRepAnt  := ""
Private cPacote  := ""
Private cFormato := ""
Private cPreco   := ""
Private cVolume  := ""
Private cReceita := ""
Private cPosit   := 0
Private cMesAno  := ""
Private nCont    := 0
Private cVlrPrv  := 0
Private cVlrAju  := 0
Private cVlrRea  := 0
Private nVlrPrv  := 0
Private nVlrAju  := 0
Private nVlrRea  := 0
Private cConta1  := 0
Private cConta2  := 0
Private cConta3  := 0
Private cConta4  := 0
Private cConta5  := 0
Private cCC      := 0
Private cCV      := 0
Private nDoc     := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_cDIR    := "\P10\INDG\" //diretorio dos arquivos TXT recebimento

cHInicio := Time()
fPerg := "BIA459"
//ValidPerg()
If !Pergunte(fPerg,.T.)
	Return
EndIf

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

Static Function fPRINCIPAL()
local _ni

IF MV_PAR01 == 3
	cQuery    := "SELECT MAX(CV1_ORCMTO) AS CV1_ORCMTO FROM "+RetSqlName("CV1")+" CV1 "
	If chkfile("DOC")
		dbSelectArea("DOC")
		dbCloseArea()
	EndIf
	TcQuery cQuery New Alias "DOC"
	
	IF VAL(DOC->CV1_ORCMTO) > 0
		nDoc := VAL(DOC->CV1_ORCMTO)
	ELSE
		nDoc := 1
	ENDIF
ELSE
	nDoc := MV_PAR04
	//nDoc := 
ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da matriz com nome arquivos cabecalho pedido                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DO CASE
	CASE MV_PAR01 == 2
		
		IF !EMPTY(MV_PAR02)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Deleta registros para reprocessar arquivo.                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cQuery  := ""
			cQuery  += "UPDATE "+RetSQLName("ZZH")+" "
			cQuery  += "SET D_E_L_E_T_ = '*' "
			cQuery  += "WHERE "
			cQuery  += " ZZH_FILIAL = '"+xFilial("ZZH")+"' AND "
			cQuery  += " ZZH_DATA = '"+dtos(MV_PAR02)+"' AND "
			cQuery  += " D_E_L_E_T_ = '' "
			TCSQLExec(cQuery)
		ENDIF
		
		_aTRANS:={}
		_aTRANS:=DIRECTORY(_cDIR+"REC????.csv")
		
		FOR _nI := 1 TO LEN(_aTRANS)
			
			_cTRANS := SUBSTR(ALLTRIM(_aTRANS[_nI,1]), 4, 8)
			
			_cIMPORT := "REC"+_cTRANS  //tamanho 12 posicoes
			
			MsAguarde({|| fTRABREC()},"Arquivos de Trabalho","Aguarde") // Atualizar arquivos trabalho _aP1
			
			//Ferase(ALLTRIM(_cDIR)+ALLTRIM(_cIMPORT))
		NEXT
		
	CASE MV_PAR01 == 1
		_aTRANS:={}
		//_aTRANS:=DIRECTORY(_cDIR+"GMR-??.csv")            
		_aTRANS:=DIRECTORY(_cDIR+ALLTRIM(MV_PAR03)+".CSV")		
		
		FOR _nI := 1 TO LEN(_aTRANS)
			
			_cTRANS := SUBSTR(ALLTRIM(_aTRANS[_nI,1]), 7, 5)
			//_cTRANS := SUBSTR(ALLTRIM(_aTRANS[_nI,1]), 8, 4)			
			
			//_cIMPORT := "GMR-II"+_cTRANS  //tamanho 12 posicoes
			_cIMPORT := ALLTRIM(MV_PAR03)+_cTRANS  //tamanho 12 posicoes
			
			//Importação das metas INDG
			//MsAguarde({|| fMETA1()},"Arquivos de Trabalho","Aguarde") // Atualizar arquivos trabalho _aP1
			
			//Importação das metas PRIMVS
			MsAguarde({|| fMETA2()},"Arquivos de Trabalho","Aguarde") // Atualizar arquivos trabalho _aP1
			
			//Ferase(ALLTRIM(_cDIR)+ALLTRIM(_cIMPORT))
		NEXT
		
	CASE MV_PAR01 == 3
		_aTRANS:={}
		_aTRANS:=DIRECTORY(_cDIR+ALLTRIM(MV_PAR03)+".CSV")
		
		FOR _nI := 1 TO LEN(_aTRANS)
			
			_cTRANS := SUBSTR(ALLTRIM(_aTRANS[_nI,1]), 7, 5)
			
			_cIMPORT := ALLTRIM(MV_PAR03)+_cTRANS  //tamanho 12 posicoes
			
			//Importação das metas GMCD PRIMVS
			MsAguarde({|| fMETA3()},"Arquivos de Trabalho","Aguarde") // Atualizar arquivos trabalho _aP1
			
			//Ferase(ALLTRIM(_cDIR)+ALLTRIM(_cIMPORT))
		NEXT
ENDCASE

RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fMETA1        ³ MICROSIGA Vitoria     ³ Data ³ 10/05/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Processa leitura e gravacao dos arquivos de trabalho       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function fMETA1()

_cARQ    := _cDIR + _cIMPORT
_nQTDREG := 0
_nTamLin := 130                  // Tamanho da linha no arquivo texto   681
_cBuffer := Space(_nTamLin + 2)  // Guarda a linha lida
_nBytes  := 0                    // Guarda numero da linha
_nhdl    := Fopen(_cARQ,0)       // Abre o arquivo so leitura

If _nhdl == -1
	MsgAlert("Erro abertura arquivo "+_cARQ)
	Return
Endif

_nTamLin := 800000
lOk      := .T.
_nBytes  := fRead(_nhdl,@_cBuffer,_nTamLin + 2) // Le primeira linha
nValor  := 0
cCodigo := SPACE(6)

While lOk
	
	nPos     := AT('**',_cBuffer)
	nLinAtu  := ALLTRIM(SUBSTR(_cBuffer,1,nPos+4))
	_cBuffer := ALLTRIM(SUBSTR(_cBuffer,nPos+4,_nBytes - nPos+4))
	
	IF nPos = 0
		lOk := .F.
	ENDIF
	
	IF "0"+SUBSTR(nLinAtu,1,1) == cEmpAnt
		//Define posicoes variaveis
		nPos1    := AT(';',nLinAtu)
		cEmpresa := STRZERO(VAL(ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1))),2)
		nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		
		nPos1    := AT(';',nLinAtu)
		cFormato := ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1))
		nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		
		nPos1    := AT(';',nLinAtu)
		cPacote  := ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1))
		nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		
		nPos1    := AT(';',nLinAtu)
		cSegment := STRZERO(VAL(ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1))),6)
		nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		
		nPos1    := AT(';',nLinAtu)
		cRepres  := STRZERO(VAL(ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1))),6)
		nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		
		nPos1    := AT(';',nLinAtu)
		cNome    := ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1))
		nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		
		nPos1    := AT(';',nLinAtu)
		cMesAno  := ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1))
		nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		
		nPos1    := AT(';',nLinAtu)
		cPreco   := ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1))
		nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		
		nPos1    := AT(';',nLinAtu)
		cReceita := ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1))
		nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		
		nPos1    := AT(';',nLinAtu)
		cVolume  := ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1))
		nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		
		//nPos1    := AT(';',nLinAtu)
		//cPosit   := VAL(SUBSTR(ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1)),1,2))
		//nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		cPosit := 0
		
		IF AT('/', cMesAno) > 0
			nBarra  := AT('/', cMesAno)
			nMES := VAL(Substr(cMesAno,1,nBarra-1))
			nAno := VAL(Substr(cMesAno,nBarra+1,4))
		ENDIF
		
		dDataMov := STOD(STRZERO(nAno,4)+STRZERO(nMes,2)+"01")
		
		nPreco := 0
		nPonto := 0
		nVirg  := 0
		nIni   := 1
		IF AT('.', cPreco) > 0
			nPonto := AT('.', cPreco)
			nPreco := (VAL(Substr(cPreco,1,nPonto-1))*1000)
			nIni   := nPonto + 1
		ENDIF
		IF AT(',', cPreco) > 0
			nVirg  := AT(',', cPreco)
			nPreco := nPreco + VAL(Substr(cPreco,nIni,nVirg-nIni)) + (VAL(RTRIM(Substr(cPreco,nVirg+1,2)))/100)
		ENDIF
		
		nVolume := 0
		nPonto  := 0
		nVirg   := 0
		nIni    := 1
		
		IF AT('.', cVolume) > 0
			nPonto  := AT('.', cVolume)
			nVolume := (VAL(Substr(cVolume,1,nPonto-1))*1000)
			nIni    := nPonto + 1
		ENDIF
		IF AT(',', cVolume) > 0
			nVirg   := AT(',', cVolume)
			nVolume := nVolume + VAL(Substr(cVolume,nIni,nVirg-nIni)) + (VAL(RTRIM(Substr(cVolume,nVirg+1,2)))/100)
		ENDIF
		
		nReceita := 0
		nPonto   := 0
		nVirg    := 0
		nIni     := 1
		
		IF AT('.', cReceita) > 0
			nPonto   := AT('.', cReceita)
			nReceita := (VAL(Substr(cReceita,1,nPonto-1))*1000)
			nIni := nPonto + 1
		ENDIF
		IF AT(',', cReceita) > 0
			nVirg    := AT(',', cReceita)
			nReceita := nReceita + VAL(Substr(cReceita,nIni,nVirg-nIni)) + (VAL(RTRIM(Substr(cReceita,nVirg+1,2)))/100)
		ENDIF
		
		DbselectArea("SCT")
		nCont := nCont + 1
		IF (cRepres <> cRepAnt) .OR. nCont > 999
			nDoc  := fGetDoc()
			nCont := 1
		ENDIF
		RecLock("SCT",.T.)
		SCT->CT_FILIAL  := xFilial("SCT")
		SCT->CT_DESCRI  := 'META DE VENDAS REPRESENTANTE '+cRepres
		SCT->CT_DOC     := STRZERO(nDoc,6)
		SCT->CT_VEND    := cRepres
		SCT->CT_GRUPO   := 'PA'
		SCT->CT_VALOR   := nReceita
		SCT->CT_QUANT   := nVolume
		SCT->CT_DATA    := dDataMov
		SCT->CT_MOEDA   := 1
		SCT->CT_SEQUEN  := STRZERO(nCont,3)
		SCT->CT_YPRCUN  := nPreco
		SCT->CT_YPOSCLI := cPosit
		SCT->CT_YPACOTE := cPacote
		
		DO CASE
			CASE cSegment == '000110'
				SCT->CT_CATEGO  := 'R'
			CASE cSegment == '000099'
				SCT->CT_CATEGO  := 'E'
			CASE cSegment == '000105'
				SCT->CT_CATEGO  := 'H'
		ENDCASE
		
		IF ALLTRIM(cFormato) <> 'FORMATOS ESPECIAIS'
			SCT->CT_PRODUTO := cFormato
		ELSE
			SCT->CT_PRODUTO := 'ZZ'
		ENDIF
		MsUnLock()
		cRepAnt := cRepres
	ENDIF
END

If .Not. fClose(_nhdl)
	MsgAlert("Erro fechamento do arquivo "+_cIMPORT)
	Return
EndIf

DbCommitall()

RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fMETA2        ³ MICROSIGA Vitoria     ³ Data ³ 10/05/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Processa leitura e gravacao dos arquivos de trabalho       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function fMETA2()

_cARQ    := _cDIR + _cIMPORT
_nQTDREG := 0
_nTamLin := 130                  // Tamanho da linha no arquivo texto   681
_cBuffer := Space(_nTamLin + 2)  // Guarda a linha lida
_nBytes  := 0                    // Guarda numero da linha
_nhdl    := Fopen(_cARQ,0)       // Abre o arquivo so leitura

If _nhdl == -1
	MsgAlert("Erro abertura arquivo "+_cARQ)
	Return
Endif

_nTamLin := 1000000
lOk      := .T.
_nBytes  := fRead(_nhdl,@_cBuffer,_nTamLin + 2) // Le primeira linha
nValor  := 0
cCodigo := SPACE(6)

While lOk
	
	//nPos     := AT('**;;;;;',_cBuffer)
	//nLinAtu  := ALLTRIM(SUBSTR(_cBuffer,1,nPos+9))
	//_cBuffer := ALLTRIM(SUBSTR(_cBuffer,nPos+9,_nBytes - nPos+9))
	
	nPos     := AT('**',_cBuffer)
	nLinAtu  := ALLTRIM(SUBSTR(_cBuffer,1,nPos+4))
	//ALERT(NLINATU)
	//ALERT(SUBSTRING(_CBUFFER,1,100))
	_cBuffer := ALLTRIM(SUBSTR(_cBuffer,nPos+4,_nBytes - nPos+4))
	
	IF nPos = 0
		lOk := .F.
	ENDIF
  
	//ALERT(SUBSTR(ALLTRIM(nLinAtu),1,2))
	//ALERT(NLINATU)
	
  //Verificar se o depto comercial informou empresa apenas com um dígito = 101 ou 501 ou 599 ou 1399
  //Verificar se existem ponto e virgula apos os **
  
  //Para importar a Mundialli dentro da tabela SCT050
  //IF (SUBSTR(ALLTRIM(nLinAtu),1,2) == '13')
  
  //Esta linha sempre deve ser ajustada
  //IF (SUBSTR(ALLTRIM(nLinAtu),1,2) == cEmpAnt) .OR. (SUBSTR(ALLTRIM(nLinAtu),1,1) == SUBSTR(ALLTRIM(cEmpAnt),2,1))
  IF (SUBSTR(ALLTRIM(nLinAtu),2,2) == cEmpAnt) .OR. (SUBSTR(ALLTRIM(nLinAtu),2,1) == SUBSTR(ALLTRIM(cEmpAnt),3,1))
		nPos1    := AT(';',nLinAtu)
		cEmpresa := STRZERO(VAL(ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1))),4)
		nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		
		nPos1    := AT(';',nLinAtu)
		cMesAno  := ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1))
		nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		
		nPos1    := AT(';',nLinAtu)
		cRepres  := STRZERO(VAL(ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1))),6)
		nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		
		nPos1    := AT(';',nLinAtu)
		cSegment := ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1))
		nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		
		nPos1    := AT(';',nLinAtu)
		cPacote  := ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1))
		nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		
		nPos1    := AT(';',nLinAtu)
		cCliente := STRZERO(VAL(ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1))),6)
		nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		
		nPos1    := AT(';',nLinAtu)
		cTpCli   := ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1))
		nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		
		nPos1    := AT(';',nLinAtu)
		cFormato := ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1))
		nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		
		nPos1    := AT(';',nLinAtu)
		cTpFor   := ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1))
		nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		
		nPos1    := AT(';',nLinAtu)
		cVolume  := ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1))
		nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		
		nPos1    := AT(';',nLinAtu)
		cPreco   := ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1))
		nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		
		nPos1    := AT(';',nLinAtu)
		cReceita := ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1))
		nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		
		//IF cRepres == '000222' .AND. cFormato == 'A8'
		//   LOKKK := .T.
		//ENDIF
		
		cPosit := 0
		
		IF AT('/', cMesAno) > 0
			nBarra  := AT('/', cMesAno)
			nAno    := VAL(Substr(cMesAno,nBarra+1,4))
			
			//Inserido para quando a data for informada XX/XXXX MES/ANO
			nBarra  := AT('/', cMesAno)
			nMES    := VAL(Substr(cMesAno,nBarra-2,2))
		ENDIF
		      
		DO CASE
			CASE UPPER(ALLTRIM(SUBSTR(cMesAno,1,3))) == 'JAN'
				nMES := 1
			CASE UPPER(ALLTRIM(SUBSTR(cMesAno,1,3))) == 'FEV'
				nMES := 2
			CASE UPPER(ALLTRIM(SUBSTR(cMesAno,1,3))) == 'MAR'
				nMES := 3
			CASE UPPER(ALLTRIM(SUBSTR(cMesAno,1,3))) == 'ABR'
				nMES := 4
			CASE UPPER(ALLTRIM(SUBSTR(cMesAno,1,3))) == 'MAI'
				nMES := 5
			CASE UPPER(ALLTRIM(SUBSTR(cMesAno,1,3))) == 'JUN'
				nMES := 6
			CASE UPPER(ALLTRIM(SUBSTR(cMesAno,1,3))) == 'JUL'
				nMES := 7
			CASE UPPER(ALLTRIM(SUBSTR(cMesAno,1,3))) == 'AGO'
				nMES := 8
			CASE UPPER(ALLTRIM(SUBSTR(cMesAno,1,3))) == 'SET'
				nMES := 9
			CASE UPPER(ALLTRIM(SUBSTR(cMesAno,1,3))) == 'OUT'
				nMES := 10
			CASE UPPER(ALLTRIM(SUBSTR(cMesAno,1,3))) == 'NOV'
				nMES := 11
			CASE UPPER(ALLTRIM(SUBSTR(cMesAno,1,3))) == 'DEZ'
				nMES := 12
		ENDCASE

		dDataMov := STOD(STRZERO(nAno,4)+STRZERO(nMes,2)+"01")
		
		/*
		IF AT('/', cMesAno) > 0
		nBarra  := AT('/', cMesAno)
		nMES := VAL(Substr(cMesAno,1,nBarra-1))
		nAno := VAL(Substr(cMesAno,nBarra+1,4))
		ENDIF
		*/
		
		dDataMov := STOD(STRZERO(nAno,4)+STRZERO(nMes,2)+"01")
		
		nPreco := 0
		nPonto := 0
		nVirg  := 0
		nIni   := 1
		IF AT('.', cPreco) > 0
			nPonto := AT('.', cPreco)
			nPreco := (VAL(Substr(cPreco,1,nPonto-1))*1000)
			nIni   := nPonto + 1
		ENDIF
		IF AT(',', cPreco) > 0
			nVirg  := AT(',', cPreco)
			nPreco := nPreco + VAL(Substr(cPreco,nIni,nVirg-nIni)) + (VAL(RTRIM(Substr(cPreco,nVirg+1,2)))/100)
		ENDIF
		IF AT('.', cPreco) == 0 .AND. AT(',', cPreco) == 0
			nPreco := VAL(ALLTRIM(cPreco))
		ENDIF
		
		nVolume := 0
		nPonto  := 0
		nVirg   := 0
		nIni    := 1
		
		IF AT('.', cVolume) > 0
			nPonto  := AT('.', cVolume)
			nVolume := (VAL(Substr(cVolume,1,nPonto-1))*1000)
			nIni    := nPonto + 1
		ENDIF
		IF AT(',', cVolume) > 0
			nVirg   := AT(',', cVolume)
			nVolume := nVolume + VAL(Substr(cVolume,nIni,nVirg-nIni)) + (VAL(RTRIM(Substr(cVolume,nVirg+1,2)))/100)
		ENDIF
		IF AT('.', cVolume) == 0 .AND. AT(',', cVolume) == 0
			nVolume := VAL(ALLTRIM(cVolume))
		ENDIF
		
		nReceita := 0
		nPonto   := 0
		nVirg    := 0
		nIni     := 1

		IF AT(',', cReceita) > 0
			nVirg    := AT(',', cReceita)
			nReceita := VAL(RTRIM(Substr(cReceita,nVirg+1,2)))/100
		ENDIF		
		
		aLista := strtokarr (ALLTRIM(cReceita), '.')
			
		DO CASE
		   CASE Len(aLista) == 1
		        nReceita := nReceita + VAL(RTRIM(Substr(cReceita,nIni,nVirg-1)))
		   CASE Len(aLista) == 2
		        nReceita := nReceita + (VAL(aLista[1])*1000) + VAL(aLista[2])
		   CASE Len(aLista) == 3
		        nReceita := nReceita + (VAL(aLista[1])*1000000) + (VAL(aLista[2])*1000) + VAL(aLista[3])
		   CASE Len(aLista) == 4
		        nReceita := nReceita + (VAL(aLista[1])*1000000000) + (VAL(aLista[2])*1000000) + (VAL(aLista[3])*1000) + VAL(aLista[4])
		   OTHERWISE
		        MsgAlert('Favor alterar o programa para converter numeros maiores do que 1.000.000.000,00')
		ENDCASE      
		
		DbselectArea("SCT")
		nCont := nCont + 1
		IF (cRepres <> cRepAnt) .OR. nCont > 999
			nDoc  := fGetDoc()
			nCont := 1
		ENDIF
		RecLock("SCT",.T.)
		SCT->CT_FILIAL  := xFilial("SCT")
		SCT->CT_DESCRI  := 'META DE VENDAS REPRESENTANTE '+cRepres
		SCT->CT_DOC     := nDoc
		SCT->CT_YEMP    := cEmpresa
		SCT->CT_VEND    := cRepres
		SCT->CT_YCLIENT := cCliente
		
		IF ALLTRIM(cTpCli) <> '999999'
			SCT->CT_YTPCLI  := cTpCli
		ELSE
			SCT->CT_YTPCLI  := "C"
		ENDIF
		
		SCT->CT_GRUPO   := 'PA'
		SCT->CT_VALOR   := nReceita
		SCT->CT_QUANT   := nVolume
		SCT->CT_DATA    := dDataMov
		SCT->CT_MOEDA   := 1
		SCT->CT_SEQUEN  := STRZERO(nCont,3)
		SCT->CT_YPRCUN  := nPreco
		SCT->CT_YPOSCLI := cPosit
		SCT->CT_YPACOTE := cPacote
		SCT->CT_CATEGO  := cSegment
		SCT->CT_YFORMAT := cFormato
		SCT->CT_YTPSEG	:= cSegment
		SCT->CT_YCAT	:= fClcCat(SCT->CT_YTPCLI,cCliente)
		SCT->CT_PRODUTO	:= fClcPrd(SCT->CT_YFORMAT)
		//SCT->CT_YTIPO   := cTpFor
		SCT->CT_YEST	:= Posicione("SA3",1,xFilial("SA3")+cRepres,"A3_EST")
		
		MsUnLock()
		cRepAnt := cRepres
	ENDIF
END

If .Not. fClose(_nhdl)
	MsgAlert("Erro fechamento do arquivo "+_cIMPORT)
	Return
EndIf

DbCommitall()

RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fTRABREC          ³ MICROSIGA Vitoria     ³ Data ³ 10/05/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Processa leitura e gravacao dos arquivos de trabalho       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function fTRABREC()

_cARQ    := _cDIR + _cIMPORT
_nQTDREG := 0
_nTamLin := 130                  // Tamanho da linha no arquivo texto   681
_cBuffer := Space(_nTamLin + 2)  // Guarda a linha lida
_nBytes  := 0                    // Guarda numero da linha
_nhdl    := Fopen(_cARQ,0)       // Abre o arquivo so leitura

If _nhdl == -1
	MsgAlert("Erro abertura arquivo "+_cARQ)
	Return
Endif

_nTamLin := 800000
lOk      := .T.
_nBytes  := fRead(_nhdl,@_cBuffer,_nTamLin + 2) // Le primeira linha
nValor  := 0
cCodigo := SPACE(6)

While lOk
	
	nPos     := AT('**',_cBuffer)
	nLinAtu  := SUBSTR(_cBuffer,1,nPos+4)
	_cBuffer := SUBSTR(_cBuffer,nPos+4,_nBytes - nPos+4)
	
	IF nPos = 0
		lOk := .F.
	ENDIF
	
	IF "0"+SUBSTR(nLinAtu,1,1) == cEmpAnt
		//Define posicoes variaveis
		nPos1    := AT(';',nLinAtu)
		cEmpresa := STRZERO(VAL(ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1))),2)
		nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		
		nPos1    := AT(';',nLinAtu)
		cPacote  := ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1))
		nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		
		nPos1    := AT(';',nLinAtu)
		cFormato := ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1))
		nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		
		nPos1    := AT(';',nLinAtu)
		cRepres  := STRZERO(VAL(ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1))),6)
		nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		
		nPos1    := AT(';',nLinAtu)
		cSeg     := STRZERO(VAL(ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1))),6)
		nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		
		nPos1    := AT(';',nLinAtu)
		cNome    := ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1))
		nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		
		nPos1    := AT(';',nLinAtu)
		cNomeR   := ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1))
		nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		
		nPos1    := AT(';',nLinAtu)
		cVolume  := ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1))
		nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		
		nPos1    := AT(';',nLinAtu)
		cReceita := ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1))
		nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		
		nPos1    := AT(';',nLinAtu)
		cMesAno  := ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1))
		nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		
		nPos1    := AT(';',nLinAtu)
		cPreco   := ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1))
		nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		
		IF AT('/', cMesAno) > 0
			nBarra  := AT('/', cMesAno)
			cMes := Substr(cMesAno,1,nBarra-1)
			DO CASE
				CASE UPPER(cMes) == 'JAN'
					nMes = 1
				CASE UPPER(cMes) == 'FEV'
					nMes = 2
				CASE UPPER(cMes) == 'MAR'
					nMes = 3
				CASE UPPER(cMes) == 'ABR'
					nMes = 4
				CASE UPPER(cMes) == 'MAI'
					nMes = 5
				CASE UPPER(cMes) == 'JUN'
					nMes = 6
				CASE UPPER(cMes) == 'JUL'
					nMes = 7
				CASE UPPER(cMes) == 'AGO'
					nMes = 8
				CASE UPPER(cMes) == 'SET'
					nMes = 9
				CASE UPPER(cMes) == 'OUT'
					nMes = 10
				CASE UPPER(cMes) == 'NOV'
					nMes = 11
				CASE UPPER(cMes) == 'DEZ'
					nMes = 12
			ENDCASE
			nAno := VAL("20"+Substr(cMesAno,nBarra+1,2))
		ENDIF
		
		dDataMov := STOD(STRZERO(nAno,4)+STRZERO(nMes,2)+"01")
		
		nPreco := 0
		nPonto := 0
		nVirg  := 0
		nIni   := 1
		IF AT('.', cPreco) > 0
			nPonto := AT('.', cPreco)
			nPreco := (VAL(Substr(cPreco,1,nPonto-1))*1000)
			nIni := nPonto + 1
		ENDIF
		IF AT(',', cPreco) > 0
			nVirg  := AT(',', cPreco)
			nPreco := nPreco + VAL(Substr(cPreco,nIni,nVirg-nIni)) + (VAL(RTRIM(Substr(cPreco,nVirg+1,2)))/100)
		ENDIF
		
		nVolume := 0
		nPonto  := 0
		nVirg   := 0
		nIni   := 1
		IF AT('.', cVolume) > 0
			nPonto  := AT('.', cVolume)
			nVolume := (VAL(Substr(cVolume,1,nPonto-1))*1000)
			nIni := nPonto + 1
		ENDIF
		IF AT(',', cVolume) > 0
			nVirg   := AT(',', cVolume)
			nVolume := nVolume + VAL(Substr(cVolume,nIni,nVirg-nIni)) + (VAL(RTRIM(Substr(cVolume,nVirg+1,2)))/100)
		ENDIF
		
		nReceita := 0
		nPonto   := 0
		nVirg    := 0
		nIni     := 1
		IF AT('.', cReceita) > 0
			nPonto   := AT('.', cReceita)
			nReceita := (VAL(Substr(cReceita,1,nPonto-1))*1000)
			nIni := nPonto + 1
		ENDIF
		IF AT(',', cReceita) > 0
			nVirg    := AT(',', cReceita)
			nReceita := nReceita + VAL(Substr(cReceita,nIni,nVirg-nIni)) + (VAL(RTRIM(Substr(cReceita,nVirg+1,2)))/100)
		ENDIF
		
		DbselectArea("ZZH")
		RecLock("ZZH",.T.)
		ZZH->ZZH_FILIAL  := xFilial("ZZH")
		ZZH->ZZH_FORMATO := cFormato
		ZZH->ZZH_VEND    := cRepres
		ZZH->ZZH_VALOR   := nReceita
		ZZH->ZZH_QUANT   := nVolume
		ZZH->ZZH_PRUNIT  := nPreco
		ZZH->ZZH_DATA    := dDataMov
		ZZH->ZZH_PACOTE  := '1' //ERA 6 ATE 17/07/14 E FOI ALTERADO PARA 1
		IF ALLTRIM(cSeg) == '000110'
			ZZH->ZZH_SEG := 'R'
		ELSE
			ZZH->ZZH_SEG := 'E'
		ENDIF
		MsUnLock()
	ENDIF
END

If .Not. fClose(_nhdl)
	MsgAlert("Erro fechamento do arquivo "+_cIMPORT)
	Return
EndIf

DbCommitall()

RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fMETA3            ³ MICROSIGA Vitoria     ³ Data ³ 10/05/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Processa leitura e gravacao dos arquivos de trabalho       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fMETA3()

_cARQ    := _cDIR + _cIMPORT
_nQTDREG := 0
_nTamLin := 130                  // Tamanho da linha no arquivo texto   681
_cBuffer := Space(_nTamLin + 2)  // Guarda a linha lida
_nBytes  := 0                    // Guarda numero da linha
_nhdl    := Fopen(_cARQ,0)       // Abre o arquivo so leitura

If _nhdl == -1
	MsgAlert("Erro abertura arquivo "+_cARQ)
	Return
Endif

_nTamLin  := 1000000
lOk       := .T.
_nBytes   := fRead(_nhdl,@_cBuffer,_nTamLin + 2) // Le primeira linha
nValor    := 0
cCodigo   := SPACE(6)
cCtaAnoA  := SPACE(1)
cChaveAnt := SPACE(1)
cCodigoA  := SPACE(1)

While lOk
	
	//nPos     := AT('**;;;;;',_cBuffer)
	//nLinAtu  := ALLTRIM(SUBSTR(_cBuffer,1,nPos+9))
	//_cBuffer := ALLTRIM(SUBSTR(_cBuffer,nPos+9,_nBytes - nPos+9))
	
	nPos     := AT('**',_cBuffer)
	nLinAtu  := ALLTRIM(SUBSTR(_cBuffer,1,nPos+4))
	_cBuffer := ALLTRIM(SUBSTR(_cBuffer,nPos+4,_nBytes - nPos+4))

	nLinAtu1  := ALLTRIM(SUBSTR(_cBuffer,1,nPos+3))
	_cBuffer1 := ALLTRIM(SUBSTR(_cBuffer,nPos+3,_nBytes - nPos+3))
	
	IF LEN(_cBuffer) <= 0
		lOk := .F.
		Exit
	ENDIF
	
	IF SUBSTR(ALLTRIM(nLinAtu),1,2) == '20'
		//Define posicoes variaveis
		nPos1    := AT(';',nLinAtu)
		cAno     := STRZERO(VAL(ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1))),4)
		nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		
		nPos1    := AT(';',nLinAtu)
		cMesAno  := ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1))
		nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		
		nPos1    := AT(';',nLinAtu)
		cConta1  := ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1))
		nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		
		nPos1    := AT(';',nLinAtu)
		cConta2  := ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1))
		nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		
		nPos1    := AT(';',nLinAtu)
		cConta3  := ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1))
		nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		
		nPos1    := AT(';',nLinAtu)
		cConta4  := ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1))
		nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		
		nPos1    := AT(';',nLinAtu)
		cCOnta5  := ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1))
		nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		
		nPos1    := AT(';',nLinAtu)
		cCV      := ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1))
		nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		
		nPos1    := AT(';',nLinAtu)
		cVlrPrv  := ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1))
		nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		
		nPos1    := AT(';',nLinAtu)
		cVlrAju  := ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1))
		nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		
		nPos1    := AT(';',nLinAtu)
		cVlrRea  := ALLTRIM(SUBSTR(nLinAtu,1,nPos1-1))
		nLinAtu  := SUBSTR(nLinAtu,nPos1+1,Len(nLinAtu) - nPos1)
		
		IF AT('/', cMesAno) > 0
			nBarra  := AT('/', cMesAno)
			nAno := VAL(Substr(cMesAno,nBarra+1,4))
		ENDIF
		
		DO CASE
			CASE UPPER(ALLTRIM(SUBSTR(cMesAno,1,3))) == 'JAN'
				nMES := 1
			CASE UPPER(ALLTRIM(SUBSTR(cMesAno,1,3))) == 'FEV'
				nMES := 2
			CASE UPPER(ALLTRIM(SUBSTR(cMesAno,1,3))) == 'MAR'
				nMES := 3
			CASE UPPER(ALLTRIM(SUBSTR(cMesAno,1,3))) == 'ABR'
				nMES := 4
			CASE UPPER(ALLTRIM(SUBSTR(cMesAno,1,3))) == 'MAI'
				nMES := 5
			CASE UPPER(ALLTRIM(SUBSTR(cMesAno,1,3))) == 'JUN'
				nMES := 6
			CASE UPPER(ALLTRIM(SUBSTR(cMesAno,1,3))) == 'JUL'
				nMES := 7
			CASE UPPER(ALLTRIM(SUBSTR(cMesAno,1,3))) == 'AGO'
				nMES := 8
			CASE UPPER(ALLTRIM(SUBSTR(cMesAno,1,3))) == 'SET'
				nMES := 9
			CASE UPPER(ALLTRIM(SUBSTR(cMesAno,1,3))) == 'OUT'
				nMES := 10
			CASE UPPER(ALLTRIM(SUBSTR(cMesAno,1,3))) == 'NOV'
				nMES := 11
			CASE UPPER(ALLTRIM(SUBSTR(cMesAno,1,3))) == 'DEZ'
				nMES := 12
		ENDCASE
		dDtIni := STOD(STRZERO(nAno,4)+STRZERO(nMes,2)+"01")
		dDtFim := STOD(STRZERO(nAno,4)+STRZERO(nMes,2)+"01")
		
		//IF ALLTRIM(cConta5) == '31101001' .AND. ALLTRIM(cCV) == '4000'
		//	Lokk := .T.
		//ENDIF
		
		IF ALLTRIM(cCV) == '1000_DAF'
			cCV := '1000'
		ENDIF
		
		IF ALLTRIM(cCV) == '1000_IMP'
			cCV := '1100'
		ENDIF                        
		
		nVlrPrv := 0
		nPonto  := 0
		nVirg   := 0
		nIni    := 1
		
		IF AT(',', cVlrPrv) > 0
			nPonto  := AT(',', cVlrPrv)
		    nVlrPrv := VAL(Substr(cVlrPrv,1,nPonto-1))+(VAL(Substr(cVlrPrv,nPonto+1,1))/10)+(VAL(Substr(cVlrPrv,nPonto+2,1))/100)
			nIni    := nPonto + 1			
		ELSE 
			nVlrPrv := VAL(cVlrPrv)
		ENDIF
		
		nVlrAju	:= 0
		nPonto  := 0
		nVirg   := 0
		nIni    := 1
		
		IF AT(',', cVlrAju) > 0
			nPonto  := AT(',', cVlrAju)
			nVlrAju := VAL(Substr(cVlrAju,1,nPonto-1))+(VAL(Substr(cVlrAju,nPonto+1,1))/10)+(VAL(Substr(cVlrAju,nPonto+2,1))/100)
			nIni    := nPonto + 1  
		ELSE
			nVlrAju := VAL(cVlrAju)			
		ENDIF
		
		nVlrRea  := 0
		nPonto   := 0
		nVirg    := 0
		nIni     := 1
		
		IF AT(',', cVlrRea) > 0
			nPonto  := AT(',', cVlrRea)
			nVlrRea := VAL(Substr(cVlrRea,1,nPonto-1))+(VAL(Substr(cVlrRea,nPonto+1,1))/10)+(VAL(Substr(cVlrRea,nPonto+2,1))/100)
			nIni    := nPonto + 1 
		ELSE
			nVlrRea := VAL(cVlrRea)			
		ENDIF
		
		DO CASE
			CASE SUBSTR(cCV,1,1) $ '1/4'
				cCC := '1000'
			CASE SUBSTR(cCV,1,1) $ '2'
				cCC := '2000'
			CASE SUBSTR(cCV,1,1) $ '3/8'
				cCC := '3000'
			OTHERWISE
				cCC := ''
		ENDCASE
		
		cChave  := ALLTRIM(cConta5)+ALLTRIM(cCV)+ALLTRIM(cCC)
		cCtaAno := ALLTRIM(cConta5)+cAno
		cCodigo := ALLTRIM(cConta5)+cAno+STRZERO(nMes,2)+ALLTRIM(cCV)+ALLTRIM(cCC)
		
		IF (cCtaAno <> cCtaAnoA) .OR. nCont > 999
			nDoc  := nDoc  + 1
			nCont := 1
		ENDIF
		
		IF cChave <> cChaveAnt
			nCont := nCont + 1
		ENDIF
		
		IF nVlrPrv <> 0 .OR. nVlrAju <> 0 .OR. nVlrRea <> 0
			DbselectArea("CV1")
			IF cCodigo <> cCodigoA
				RecLock("CV1",.T.)
				CV1->CV1_FILIAL := xFilial("CV1")
				CV1->CV1_ORCMTO := STRZERO(nDoc,6)
				CV1->CV1_DESCRI := 'ORCAMENTO EXERCICIO '+ALLTRIM(cAno)
				CV1->CV1_STATUS := '1'
				CV1->CV1_CALEND := SUBSTR(cAno,2,3)
				CV1->CV1_MOEDA  := '01'
				CV1->CV1_REVISA := '001'
				CV1->CV1_SEQUEN := STRZERO(nCont,3)
				CV1->CV1_CT1INI := cConta5
				CV1->CV1_CT1FIM := cConta5
				CV1->CV1_CTTINI := cCC
				CV1->CV1_CTTFIM := cCC
				CV1->CV1_CTHINI := cCV
				CV1->CV1_CTHFIM := cCV
				CV1->CV1_PERIOD := STRZERO(nMes,2)
				CV1->CV1_DTINI  := dDTini
				CV1->CV1_DTFIM  := dDTfim
				CV1->CV1_VALOR  := nVlrPrv					 //Previsto
				CV1->CV1_YORCAJ := nVlrAju					 //Ajustado
				CV1->CV1_YORCRE := nVlrRea 	  			 //Realizado
				CV1->CV1_APROVA := 'Importação'
				MsUnLock()
			ELSE
				ALERT(ALLTRIM(cConta5)+'-'+cAno+'-'+STRZERO(nMes,2)+'-'+ALLTRIM(cCV)+'-'+ALLTRIM(cCC),"STOP")
			ENDIF
		ENDIF
		cCtaAnoA  := ALLTRIM(cConta5)+cAno
		cChaveAnt := ALLTRIM(cConta5)+ALLTRIM(cCV)+ALLTRIM(cCC)
		cCodigoA  := ALLTRIM(cConta5)+cAno+STRZERO(nMes,2)+ALLTRIM(cCV)+ALLTRIM(cCC)
	ENDIF
END

If .Not. fClose(_nhdl)
	MsgAlert("Erro fechamento do arquivo "+_cIMPORT)
	Return
EndIf

DbCommitall()

RETURN

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
cPerg := PADR(fPerg,6)
aRegs:={}

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
aAdd(aRegs,{cPerg,"01","Importar arquivo?             ","","","mv_ch1","N",01,0,0,"C","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Data da importação?           ","","","mv_ch2","D",08,0,0,"C","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
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

Static Function fClcCat(_cTpcli,_cCli)

	Local _cRet	:=	""
	Local _cAlias	:=	GetNextAlias()

	If Alltrim(_cCli) <> "999999"
	
		If _cTpCli	==	"C"
			
			BeginSql Alias _cAlias
				Select MAX(A1_YCAT) CATEG
					FROM %TABLE:SA1% SA1
					WHERE A1_COD = %Exp:_cCli%
						AND A1_MSBLQL <> '1'
						AND SA1.%NotDel%
		
			EndSql
		
			_cRet	:=	(_cALias)->CATEG
			(_cAlias)->(DbCloseArea())
		ElseIf _cTpCli == "G"

			BeginSql Alias _cAlias
				Select MAX(A1_YCAT) CATEG
					FROM %TABLE:SA1% SA1
					WHERE A1_GRPVEN = %Exp:_cCli%
						AND A1_MSBLQL <> '1'
						AND SA1.%NotDel%
		
			EndSql
		
			_cRet	:=	(_cALias)->CATEG
			(_cAlias)->(DbCloseArea())
		EndIf
	EndIf


Return _cRet


Static Function fClcPrd(_cFormat)

	Local _cProd	:=	""
	Local _cAlias	:=	GetNextAlias()
	
	BeginSql Alias _cAlias

		SELECT TOP 1 ISNULL(B1_COD,'') B1_COD
		FROM %TABLE:SB1% SB1
		WHERE  SB1.B1_YFORMAT	= %Exp:_cFormat%
			AND SB1.B1_TIPO		= 'PA'
			AND SB1.B1_YCLASSE	= '1'
			AND SB1.B1_YFORMAT	<> '' 
			AND SB1.B1_YBASE	<> '' 
			AND SB1.B1_YACABAM	<> '' 
			AND SB1.B1_YLINHA	<> '' 
			AND SB1.B1_YLINSEQ	<> '' 
			AND SB1.%NotDel%
			
	EndSql
	_cProd	:=	(_cAlias)->B1_COD
	(_cAlias)->(DbCloseArea())

Return _cProd


Static Function fGetDoc()

	Local _cAliasDoc	:=	GetNextAlias()
	Local _cFDoc	:=	""
	
	BeginSql Alias _cAliasDoc
	
		SELECT MAX(CT_DOC) MAXDOC FROM %TABLE:SCT% WHERE CT_FILIAL = %XFILIAL:SCT% AND %NotDel%
		
	
	EndSql
	
	_cfDoc	:=	Soma1((_cAliasDoc)->MAXDOC)
	
Return _cfDoc