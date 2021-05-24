#include 'totvs.ch'


User Function PTVTESTE()

  Local aCabSC5 := {}
  Local aItemSC6 := {}
  Local aItensSC6 := {}

  RpcSetType(3)
  RpcSetEnv( "07", "01",,, "FAT" )
  
  aAdd(aCabSC5, {"C5_NUM"   		  , ""		   				                 , Nil})
  aAdd(aCabSC5, {"C5_TIPO"   		  , "N"				   		                 , Nil})
  
  aAdd(aCabSC5, {"C5_YLINHA"	    , "6"					                   , Nil})
  aAdd(aCabSC5, {"C5_YSUBTP"	    , "IM"					                   , Nil})

  aAdd(aCabSC5, {"C5_CLIENTE"   	, "028868"		             , Nil})
  aAdd(aCabSC5, {"C5_LOJACLI"   	, "01"	             , Nil})
  aAdd(aCabSC5, {"C5_CLIENT"   	  , "028868"	             , Nil})
  aAdd(aCabSC5, {"C5_LOJAENT"		  , "01"	             , Nil})
  aAdd(aCabSC5, {"C5_CONDPAG"		  , "912"  	             , Nil})
  
  aAdd(aCabSC5, {"C5_TRANSP"		  , ""						                   , Nil})

  aAdd(aCabSC5, {"C5_YCONF"		    , "S"						                   , Nil})
  aAdd(aCabSC5, {"C5_VEND1"		    , "999999"					               , Nil})
  aAdd(aCabSC5, {"C5_COMIS1"		  , 0							                   , Nil})
  aAdd(aCabSC5, {"C5_COMIS2"		  , 0							                   , Nil})
  aAdd(aCabSC5, {"C5_COMIS3"		  , 0							                   , Nil})
  aAdd(aCabSC5, {"C5_COMIS4"		  , 0							                   , Nil})
  aAdd(aCabSC5, {"C5_COMIS5"		  , 0							                   , Nil})
  
  aAdd(aCabSC5, {"C5_EMISSAO"		  , dDataBase					               , Nil})
  aAdd(aCabSC5, {"C5_TPFRETE"		  , "F" , Nil})

  aAdd(aCabSC5, {"C5_ORIGEM"		  , ""						                   , Nil})
  aAdd(aCabSC5, {"C5_MENNOTA"	    , ""	             , Nil})
  // aAdd(aCabSC5, {"C5_YIDVINI"	    , ""	                   , Nil})

  aAdd(aItemSC6, {"C6_NUM"		  , ""								  	    , Nil})
  aAdd(aItemSC6, {"C6_ITEM"		  , "01"									    , Nil})
  aAdd(aItemSC6, {"C6_PRODUTO"	, "VC0753M1       "		    , Nil})
  aAdd(aItemSC6, {"C6_QTDVEN"		, 5.5		        , Nil})
  aAdd(aItemSC6, {"C6_PRCVEN"		, 50.99	    , Nil})
  aAdd(aItemSC6, {"C6_VALOR"		, 280.45	    , Nil})
  aAdd(aItemSC6, {"C6_PRUNIT"		, 51.29		, Nil})
  // aAdd(aItemSC6, {"C6_TES"		  , "508"				   					  , Nil})
  // aAdd(aItemSC6, {"C6_LOCAL"		, "01"									    , Nil})

  aItemSC6 := FWVetByDic(aItemSC6, "SC6", .F., 1)

  aAdd( aItensSC6, aClone(aItemSC6) )

  Private lMsErroAuto    := .F.
	Private lMsHelpAuto    := .T.
	Private lAutoErrNoFile := .T.

  cNumPed := GetSxENum("SC5","C5_NUM")
  RollBackSX8()

  aCabSC5[1][2] := cNumPed

  aEval( aItensSC6,{ |x|  x[1][2] := cNumPed } )

  dbSelectArea("SC5")
  cMay := "SC5"+ Alltrim(xFilial("SC5"))
  SC5->(dbSetOrder(1))

  While ( dbSeek( xFilial("SC5") + cNumPed ) .Or. !MayIUseCode(cMay + cNumPed) )

    cNumPed := Soma1(cNumPed, Len(cNumPed))

    aCabSC5[1][2] := cNumPed

    aEval( aItensSC6,{ |x|  x[1][2] := cNumPed } )

  EndDo

  cMsgRet          := "Numero pedido utilizado: " + cNumPed + CRLF


  //|Variavel utilizada na regra de negocio da Bianco |
  CREPATU := ""

  SetFunName("RPC")

  MsExecAuto( { |x,y,z| Mata410(x,y,z) }, aCabSC5, aItensSC6, 3 )

  //|Ocorreu erro no execauto |
  If lMsErroAuto

    RollBackSX8()

    VarInfo("aCabSC5", aCabSC5)

    VarInfo("aItensSC6", aItensSC6)

    cLogTxt := GetErrorLog()

    cMsgRet += "### ERRO ao incluir pedido de venda: " + CRLF + cLogTxt

    cNumPed   := ""

  Else

    ConfirmSX8()

    cMsgRet += "Pedido incluido com sucesso: " + SC5->C5_NUM + " - Empresa/Filial: " + cEmpAnt + "/" + cFilAnt
    lOk     := .T.

  EndIf


Return


Static Function GetErrorLog()

	Local cRet   := ""
	Local nCount := 0

	aError := GetAutoGrLog()

	For nCount := 1 To Len(aError)

		cRet += aError[nCount] + CRLF

	Next

Return(cRet)



User Function PTVTEST2()

  RpcSetType(3)
  RpcSetEnv( "07", "01",,, "FAT" )

  CREPATU := ""

  CRET := U_FCOMRT01("F24911", .T., .F., AllTrim(CFILANT) <> "01" )

Return
