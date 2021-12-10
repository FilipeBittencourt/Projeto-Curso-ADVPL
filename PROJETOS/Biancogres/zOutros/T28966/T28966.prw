#include "protheus.ch"
#Include "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

//U_T28966
User Function T28966()

  Local  cMsg := ""

  If Select("SX6") == 0
    RPCSetEnv("07", "01", NIL, NIL, "COM", NIL, {"SB1","SF1", "SF2"})
  EndIf

  //dbSelectArea( "ZNC" )

  TEST1()
  //TEST2() //RM


RETURN


Static Function TEST1()

  Local _aCab	   :=	{}
  Local _aItens	 :=	{}
  Local _aAux	   :=	{}
  Local _aDados	 :=	{}
  Local _aPreReq :=	{}
  Local cMsg := ""

  Local _nI      := 1
  Local _cSql    := ""
  Local cQry := GetNextAlias()

  _cSql += " SELECT  *  "  + CRLF
  _cSql += " ,  ISNULL(EMPRESA,'01') "  + CRLF
  _cSql += " , DADOS_ENTRADA DADOS  "  + CRLF
  _cSql += " , PROCESSO_BIZAGI PROCBIZ   "  + CRLF
  _cSql += " , DATA_INTEGRACAO_BIZAGI DTBIZ "  + CRLF
  _cSql += " FROM BZINTEGRACAO  "  + CRLF
  _cSql += " WHERE PROCESSO_NOME = 'PRQ' "  + CRLF
  _cSql += " AND PROCESSO_BIZAGI IN ( 'PRQ-138762', 'PRQ-138723', 'PRQ-138447', 'PRQ-138446', 'PRQ-138785', 'PRQ-138070', 'PRQ-138783', 'PRQ-138784', 'PRQ-138782', 'PRQ-138799', 'PRQ-138771', 'PRQ-138798', 'PRQ-138811', 'PRQ-138804', 'PRQ-138791', 'PRQ-138596', 'PRQ-138793', 'PRQ-138765', 'PRQ-138810', 'PRQ-138795', 'PRQ-138824', 'PRQ-138821', 'PRQ-138818', 'PRQ-138200', 'PRQ-138830', 'PRQ-138834', 'PRQ-138684', 'PRQ-138829', 'PRQ-138838')"   + CRLF
  _cSql += "    AND STATUS = 'IB' "  + CRLF
  _cSql += "    AND DADOS_ENTRADA IS NOT NULL "  + CRLF
  _cSql += "    AND ISNULL(EMPRESA,'01') = '"+cEmpAnt+"'"  + CRLF
  _cSql += "	WHERE DATA_INTEGRACAO_BIZAGI >= '2019-12-27 00:00:00'
  /*_cSql += "  AND NOT EXISTS (SELECT 1  "  + CRLF
  _cSql	+= "  FROM " + RETSQLNAME("SZI") + " (NOLOCK) " +  CRLF
  _cSql += " 	WHERE ZI_YBIZAGI = BZNUMPROC "  + CRLF
  _cSql += "  AND D_E_L_E_T_ = '' ) "  + CRLF*/

  TcQuery _cSql New Alias (cQry)

  While (cQry)->(!EOF())

    _aCab	   :=	{}
    _aItens   :=	{}
    _aDados	 :=	StrtoKArr(Alltrim((cQry)->DADOS),";")

    DO CASE
    CASE Alltrim(_aDados[5]) $ "DU_DN_RE" //TIPO
      aAdd(_aCab,_aDados[5])
    OTHERWISE
      aAdd(_aCab,"RE")
    ENDCASE

    aAdd(_aCab,_aDados[6]) //Classe de Valor
    aAdd(_aCab,_aDados[2]) //Matrícula

    If Len(_aDados) >= 11
      aAdd(_aCab,Iif(Alltrim(_aDados[10]) == 'null','',_aDados[10]))
      aAdd(_aCab,Iif(Alltrim(_aDados[11]) == 'null','',_aDados[11]))
    Else
      aAdd(_aCab,"")
      aAdd(_aCab,"")
    EndIf
    If Len(_aDados) >= 12
      aAdd(_aCab,Iif(Alltrim(_aDados[12]) == 'null','',_aDados[12]))
    Else
      aAdd(_aCab,"")
    EndIf

    /*
    _aDados[9] - Itens
    1 - Código Produto
    2 - Quantidade
    3 - Local
    4 - Conta
    5 - Tag
    6 - Aplicação
    7 - Melhoria
    8 - Driver
    9 - Justificativa Driver
    10 - Parada
    */
    _aAux	:=	StrToKArr(REPLACE(REPLACE(_aDados[9],"[",""),"]",""),"&")

    For _nI	:=	1 to Len(_aAux)
      aAdd(_aItens,StrToKarr(_aAux[_nI],"|"))
    Next

    //aAdd(_aCab, _aItens)
    cMsg  +=   InsertPRQ(cQry, _aCab, _aItens) + CRLF
    (cQry)->(DBSkip())

  EndDo

Return _aPreReq

Static Function InsertPRQ(cQry, _aCab, _aItens)

  Local _cSql := ""

  Local nI := 1
  Local nK := 1
  Local aItens := {}

  For nK := 1 To Len(_aItens)

    _cSql += " INSERT INTO  [BZINTEGRACAO_PRE_REQUISICAO] ( "
    _cSql += "  [CODIGO_PRODUTO] "  + CRLF
    _cSql += " ,[QUANTIDADE] "  + CRLF
    _cSql += " ,[LOCAL] "  + CRLF
    _cSql += " ,[CONTA] "  + CRLF
    _cSql += " ,[TAG] "  + CRLF
    _cSql += " ,[APLICACAO] "  + CRLF
    _cSql += " ,[MELHORIA] "  + CRLF
    _cSql += " ,[DRIVER] "  + CRLF
    _cSql += " ,[JUSTIFICATIVA_DRIVER] "  + CRLF
    _cSql += " ,[PARADA] "  + CRLF
    _cSql += " ,[TIPO]" + CRLF
    _cSql += " ,[CLASSE_VALOR]" + CRLF
    _cSql += " ,[MATRICULA]" + CRLF
    _cSql += " ,[CLIENTE_AI]" + CRLF
    _cSql += " ,[SUBITEM_PROJ]" + CRLF
    _cSql += " ,[ITEM_CONTA]" + CRLF
    _cSql += " ,[MATRICULA_ORIGEM]" + CRLF

    //----ANTIGOS-------
    _cSql += " ,[EMPRESA] "  + CRLF
    _cSql += " ,[FILIAL] "  + CRLF
    _cSql += " ,[BZDTINTEGRACAO] "  + CRLF
    _cSql += " ,[STATUS] "  + CRLF
    _cSql += " ,[BZNUMPROC] "  + CRLF
    _cSql += " ,[BZGUID] "  + CRLF
    _cSql += " ,[DTINTEGRA] "  + CRLF
    _cSql += " ,[HRINTEGRA] "  + CRLF

    //_cSql += " ,[RECNO_RETORNO] "  + CRLF

    _cSql += ")VALUES( "  + CRLF

    _cSql += " '"+_aItens[nK,1]+"'"+ CRLF
    _cSql += ",'"+_aItens[nK,2]+"'"+ CRLF
    _cSql += ",'"+_aItens[nK,3]+"'"+ CRLF
    _cSql += ",'"+_aItens[nK,4]+"'"+ CRLF
    _cSql += ",'"+_aItens[nK,5]+"'"+ CRLF
    _cSql += ",'"+_aItens[nK,6]+"'"+ CRLF
    _cSql += ",'"+_aItens[nK,7]+"'"+ CRLF
    _cSql += ",'"+_aItens[nK,8]+"'"+ CRLF
    _cSql += ",'"+_aItens[nK,9]+"'"+ CRLF
    _cSql += ",'"+_aItens[nK,10]+"'"+ CRLF
    _cSql += ",'"+AllTrim(_aCab[1])+"'"+ CRLF
    _cSql += ",'"+AllTrim(_aCab[2])+"'"+ CRLF
    _cSql += ",'"+AllTrim(_aCab[3])+"'"+ CRLF
    _cSql += ",'"+AllTrim(_aCab[4])+"'"+ CRLF
    _cSql += ",'"+AllTrim(_aCab[5])+"'"+ CRLF
    _cSql += ",'"+AllTrim(_aCab[6])+"'"+ CRLF
    _cSql += ",'"+_aItens[nK,11]+"'"+ CRLF

    //----ANTIGOS-------

    _cSql += " ,'"+AllTrim((cQry)->EMPRESA)+"' "  + CRLF
    _cSql += " ,'"+AllTrim((cQry)->FILIAL)+"' "  + CRLF
    _cSql += " ,'"+AllTrim((cQry)->DTBIZ)+"'"  + CRLF
    _cSql += " ,'P' "  + CRLF
    _cSql += " ,'"+AllTrim((cQry)->PROCESSO_BIZAGI)+"' "  + CRLF
    _cSql += " ,NEWID() "  + CRLF
    _cSql += " ,'"+DTOS(dDataBase)+"' "  + CRLF
    _cSql += " ,'"+Time()+"' "  + CRLF

    _cSql += ");" + CRLF

  Next nK

  //TcSQLExec(_cSql)

Return _cSql