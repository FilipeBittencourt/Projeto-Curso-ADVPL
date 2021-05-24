#include 'totvs.ch'

/*/{Protheus.doc} PTVSTAMP
Função responsável por padronizar o timestamp entre Protheus e Vinilico
@type function
@version 1.0
@author Pontin - Facile Sistemas
@since 21/12/2020
@param cTipo, character, Tipo de chamada
@param cTimeStamp, character, TimeStamp
@return character, Stamp formatado
/*/
User Function PTVSTAMP( cTipo, cTabela )

  Local cStamp    := ""
  Local cData     := ""
  Local xHora     := ""
  Local cUltStamp := ""
  Local cParam    := "ZZ_VNUP" + cTabela
  Local nHrBack   := 4

  Default cTipo   := "GET"

  //|Cria os parametros |
  If !ExisteSX6(cParam)
		CriarSX6(cParam, "C", "Ultima sincronização da tabela com Portal Vinilico", "")
	EndIf

  If cTipo == "PUT" //|Atualiza o timestamp |

    PutMV( cParam, FwTimeStamp() )
  
  ElseIf cTipo == "GET" //|Pega o timestamp |
  
    cUltStamp   := GetMV(cParam)

    If Empty(cUltStamp)
      cUltStamp := "19700101100000"
    EndIf
    
    //|Trata data |
    cData  := SubStr(cUltStamp, 1, 4) + "-" + SubStr(cUltStamp, 5, 2) + "-" + SubStr(cUltStamp, 7, 2)

    //|Trata a hora |
    xHora  := Val( SubStr(cUltStamp, 9, 2) ) - nHrBack

    If xHora < 0
      xHora   := 0
    EndIf

    xHora  := StrZero( xHora, 2 ) + ":00:00"

    //|Finaliza a padronização do Stamp |
    cStamp  := cData + " " + xHora
  
  EndIf

  cStamp  := Lower(cStamp)

Return cStamp


/*/{Protheus.doc} PTVEMAIL
Tratamento do campo email
@type function
@version 1.0
@author Pontin - Facile Sistemas
@since 21/12/2020
@param cEmail, character, email cadastrado
@return character, email a ser enviado para o portal
/*/
User Function PTVEMAIL(cEmail)

  Local cDefault := ""
  Local nPos     := 0

  Do Case 

    Case Empty( cEmail )
      cEmail  := cDefault
    
    Case At( ";", cEmail ) > 0
      nPos   := At( ";", cEmail )
      cEmail := SubStr(cEmail, 1, nPos - 1)
    
    Case At( ",", cEmail ) > 0
      nPos   := At( ",", cEmail )
      cEmail := SubStr(cEmail, 1, nPos - 1)

    Case At( "/", cEmail ) > 0
      nPos   := At( "/", cEmail )
      cEmail := SubStr(cEmail, 1, nPos - 1)

  EndCase

  If !IsEmail( cEmail )

    cEmail  := cDefault

  EndIf

Return cEmail


/*/{Protheus.doc} PTVLINHA
Busca amarração linha protheus x linha Portal Vinilico
@type function
@version 1.0
@author Pontin - Facile Sistemas
@since 22/12/2020
@param cLinProd, character, Código da linha no protheus
@return character, Código da linha no portal
/*/
User Function PTVLINHA( cLinProd )

  Local cLinha    := ""
  Local nPos      := 0
  Local aLinhas   := {}

  aAdd( aLinhas, { "757C", "CITTA" } )
  aAdd( aLinhas, { "754C", "CITTA" } )
  aAdd( aLinhas, { "754H", "CITTA" } )
  aAdd( aLinhas, { "754F", "CITTA" } )
  aAdd( aLinhas, { "754I", "CITTA" } )
  aAdd( aLinhas, { "754P", "CITTA" } )
  aAdd( aLinhas, { "754G", "CITTA" } )
  aAdd( aLinhas, { "754L", "CITTA" } )
  aAdd( aLinhas, { "754N", "CITTA" } )
  aAdd( aLinhas, { "754E", "CITTA" } )
  aAdd( aLinhas, { "754M", "CITTA" } )
  aAdd( aLinhas, { "754R", "CITTA" } )
  aAdd( aLinhas, { "754T", "CITTA" } )

  aAdd( aLinhas, { "751L", "MASSIMA" } )
  aAdd( aLinhas, { "751P", "MASSIMA" } )
  aAdd( aLinhas, { "751S", "MASSIMA" } )
  aAdd( aLinhas, { "751I", "MASSIMA" } )
  aAdd( aLinhas, { "751T", "MASSIMA" } )
  aAdd( aLinhas, { "751V", "MASSIMA" } )

  aAdd( aLinhas, { "752A", "NOBILE" } )
  aAdd( aLinhas, { "752C", "NOBILE" } )
  aAdd( aLinhas, { "752L", "NOBILE" } )
  aAdd( aLinhas, { "752N", "NOBILE" } )
  aAdd( aLinhas, { "752O", "NOBILE" } )
  aAdd( aLinhas, { "752P", "NOBILE" } )
  aAdd( aLinhas, { "752V", "NOBILE" } )
  aAdd( aLinhas, { "756N", "NOBILE" } )

  aAdd( aLinhas, { "750A", "NUOVA" } )
  aAdd( aLinhas, { "750L", "NUOVA" } )
  aAdd( aLinhas, { "750M", "NUOVA" } )
  aAdd( aLinhas, { "750O", "NUOVA" } )
  aAdd( aLinhas, { "750R", "NUOVA" } )
  aAdd( aLinhas, { "750T", "NUOVA" } )

  aAdd( aLinhas, { "753A", "VITA" } )
  aAdd( aLinhas, { "753C", "VITA" } )
  aAdd( aLinhas, { "753D", "VITA" } )
  aAdd( aLinhas, { "753N", "VITA" } )
  aAdd( aLinhas, { "753M", "VITA" } )
  aAdd( aLinhas, { "753T", "VITA" } )
  aAdd( aLinhas, { "753V", "VITA" } )
  aAdd( aLinhas, { "755V", "VITA" } )

  // SELECT 'aAdd( aLinhas, { "' + ZZ7_COD + '", "' + REPLACE(RTRIM(ZZ7_DESC), 'LVT ', '') + '" } )'
  // FROM ZZ7010
  // WHERE ZZ7_COD IN ( '757C', '757C', '754C', '754C', '754H', '754H', '754F', '754F', '754I', '754I', '754P', '754P',
  //                   '754G', '754G', '754L', '754L', '754N', '754N', '754E', '754E', '754M', '754M', '754R', '754R',
  //                   '754T', '754T', '751L', '751L', '751P', '751P', '751S', '751S', '751I', '751I', '751T', '751T',
  //                   '751V', '751V', '752A', '752A', '752C', '752C', '752L', '752L', '752N', '752N', '752O', '752O',
  //                   '752P', '752P', '752V', '752V', '750A', '750A', '750L', '750L', '750M', '750M', '750O', '750O',
  //                   '750R', '750R', '750T', '750T', '753A', '753A', '753C', '753C', '753D', '753D', '753N', '753N',
  //                   '753M', '753M', '753T', '753T', '753V', '753V', '756N', '756N', '755V', '755V'
  //                 )
  // ORDER BY ZZ7_DESC

  //|Busca A LINHA |
  If ( nPos := aScan( aLinhas, { |x| x[1] == cLinProd } ) ) > 0
    cLinha	:= aLinhas[nPos,2]
  EndIf

Return cLinha
