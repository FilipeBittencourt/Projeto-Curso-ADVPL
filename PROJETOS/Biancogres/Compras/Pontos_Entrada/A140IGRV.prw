#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TOTVS.CH"
#Include "PROTHEUS.CH"
#INCLUDE "XMLXFUN.CH"

/*/{Protheus.doc} A140IGRV
@author Marcos Alberto Soprani
@since 14/01/2015
@version 1.0
@description Funcao para leitura de XMLs de NFe no diretorio de download e geracao da pre-nota de entrada.Em que ponto: Após a gravação dos registros importados na tabela SDS e SDT, permite manipular os dados importados para a tabela SDS e SDT.
@history 04/05/2017, Ranisses A. Corona, Correção do caminho para leitura do XML após migração para o Totvs Colaboração 2.0. Também necessarios para o Projeto Filiais LM.
@history 10/05/2017, Ranisses A. Corona, Ajustes na gravacao dos campos DT_LOTE e DT_DTVALID, necessários para o Projeto Filiais LM.
@history 21/06/2017, Ranisses A. Corona, Retirada a gravacao dos campos DT_LOTE e DT_DTVALID, para correcao do error.log no schedule. Estes campos serao gravados direto no SD1 via MT100CLA
@type function
/*/

User Function A140IGRV()

Local spAreaAt    := GetArea()
Private spDoc     := ParamIxb[1]
Private spSerie   := ParamIxb[2]
Private spFornec  := ParamIxb[3]
Private spLoja    := ParamIxb[4]
Private spOldPath := "\NeoGrid\bin\LIDOS\"
Private spFileXML := SDS->DS_ARQUIVO
Private _spXML

If U_BTC140A( spOldPath + spFileXML )
	
	// Atualizar dados na tabela SDT a partir do arquivo XML
	U_BTC140B()
	
EndIf

RestArea(spAreaAt)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BTC140A   ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 14/01/15 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Valida Arquivo XML                                         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BTC140A(_spFile)

Local  spError   := ""
Local  spWarning := ""
Local  spRetOk  := .T.

_spXML := XmlParserFile(_spFile, "_", @spError, @spWarning )
If ValType(_spXML) != "O"
	spRetOk  := .F.
Else
	SAVE _spXML XMLSTRING pMGetXML
Endif

Return( spRetOk )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BTC140B   ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 14/01/15 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Retorna Vetor MULTIDIMENSIONAL com os dados completos da NF¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BTC140B()

Local spCont
Local spBaseST	:= 0
Local spUnid	:= ""
Local spCFOP	:= ""
Local aAreaSDT	:= SDT->(GetArea())

If Type("_spXML:_NfeProc:_Nfe:_InfNfe") <> "U"
	
	If ValType(_spXML:_NfeProc:_Nfe:_InfNfe:_DET) == "O"
		XmlNode2Arr(_spXML:_NfeProc:_Nfe:_InfNfe:_DET, "_DET")
	EndIf
	spItens := Len(_spXML:_NfeProc:_Nfe:_InfNfe:_DET)
	
	For spCont := 1 to spItens
			
		spItXml		:= StrZero(Val(_spXML:_NFEPROC:_NFE:_INFNFE:_DET[spCont]:_NITEM:TEXT), TamSx3("DT_ITEM")[1])
		spUnid		:= Substr(Alltrim(_spXML:_NFEPROC:_NFE:_INFNFE:_DET[spCont]:_PROD:_UCOM:TEXT),1,2)
		spCFOP		:= _spXML:_NFEPROC:_NFE:_INFNFE:_DET[spCont]:_PROD:_CFOP:TEXT							
		//Procura tag referente a Base do ICMS ST
		If XmlChildEx(_spXML:_NFEPROC:_NFE:_INFNFE:_DET[spCont],"_IMPOSTO") <> nil
			If XmlChildEx(_spXML:_NFEPROC:_NFE:_INFNFE:_DET[spCont]:_IMPOSTO,"_ICMS") <> nil
				If XmlChildEx(_spXML:_NFEPROC:_NFE:_INFNFE:_DET[spCont]:_IMPOSTO:_ICMS,"_ICMS10") <> nil
					spBaseST	:= Val(_spXML:_NFEPROC:_NFE:_INFNFE:_DET[spCont]:_IMPOSTO:_ICMS:_ICMS10:_VBCST:TEXT) 
				EndIf				
			EndIf
		EndIf
		
    	//Grava informações adicionais na tabela SDT
    	SDT->(DbSetOrder(4))
    	If SDT->(DbSeek(xFilial("SDT")+spFornec+spLoja+spDoc+spSerie+spItXml))   		   			 		
 			RecLock("SDT",.F.)				
			SDT->DT_YUNID	:= spUnid 
   			SDT->DT_YCFOP	:= spCFOP    			
   			SDT->DT_YXMLBST	:= spBaseST
   			SDT->(MsUnlock())    	
    	EndIf 

	Next spCont
	
EndIf

RestArea(aAreaSDT)

Return
