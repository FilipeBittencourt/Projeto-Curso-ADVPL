#Include 'Protheus.ch'
#Include "RPTDEF.CH"
#Include "FWPrintSetup.ch"
#Include "rwmake.ch"
#include "topconn.ch"
#include "tbiconn.ch"

/*/{Protheus.doc} TFZImprimeLaser
@description Classe para impressão de arquivo ns Laser
@author Pontin
@since 14.01.19
@version 1.0
/*/
Class TFZImprimeLaser From LongClassName

	Data cPrinter		//|Impressora selecionada |
	Data cNumNF			//|Numero da nota fiscal a ser impressa |
	Data cSerieNF		//|Serie da nota fiscal a ser impressa |
	Data cNomePDF		//|Nome do arquivo PDF |
	Data cPath			//|Caminho onde vai salvar o PDF |
	Data lImpresso		//|Indica que foi impresso com sucesso |
	Data cArqImp		//|Caminho absoluto e nome do arquivo a ser impresso |

	Method New() Constructor
	Method LimpVar()

	Method ImpDanfe()
	Method ImpArquivo()

EndClass


//-------------------------------------------------------------------
/*/{Protheus.doc} New
description método construtor da classe
@author  Pontin
@since   14.01.19
@version 1.0
/*/
//-------------------------------------------------------------------
Method New() Class TFZImprimeLaser

	::LimpVar()

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} LimpVar
description Limpa as variaveis da rotina
@author  Pontin
@since   14.01.19
@version 1.0
/*/
//-------------------------------------------------------------------
Method LimpVar() Class TFZImprimeLaser

	::cPrinter		:= ""
	::cNumNF		:= ""
	::cSerieNF		:= ""
	::cPath			:= "\DANFES\"
	::lImpresso		:= .F.
	::cArqImp		:= ""

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} ImpDanfe
description Imprime a DANFE em PDF
@author  Pontin
@since   15.01.19
@version 1.0
/*/
//-------------------------------------------------------------------
Method ImpDanfe() Class TFZImprimeLaser

	Local cIdEnt 			:= u_IdEntTSS()
	Local cDirDanfe			:= ::cPath
	Local cFilePrint 		:= ::cNomePDF
	Local lAdjustToLegacy 	:= .F. //|Inibe legado de resolução com a TMSPrinter |
	Local cRaiz				:= GetSrvProfString("ROOTPATH","")
	Local oDanfe
	Local nI				:= 0
	Local cNewFile			:= ''
	Local aDados			:= {}

	//|Verifica e cria o diretório para salvar a Danfe |
	If !ExistDir(cDirDanfe)
		FWMakeDir( cDirDanfe, .F. )
	EndIf

	//|Exclui o arquivo, caso já exista |
	If File(cDirDanfe + cFilePrint)
		fErase(cDirDanfe + cFilePrint)
	EndIf

	nOrientation 	:= 1
	nLocal       	:= 2

	oDanfe := FWMSPrinter():New(cFilePrint,IMP_PDF, lAdjustToLegacy, cDirDanfe, .T., , ,"PDF", .T., , ,.F. , 1)
	oDanfe:lInJob 	:= .T.
	oDanfe:lServer 	:= .T.
	oDanfe:nDevice 	:= IMP_PDF
	oDanfe:SetViewPDF(.F.)

    oDanfe:cPathPDF:= cDirDanfe

	nFlags := PD_ISTOTVSPRINTER + PD_DISABLEORIENTATION + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN

	oSetup := Nil

	/*
	oSetup := FWPrintSetup():New(nFlags, "DANFE")

	oSetup:SetPropert(PD_PRINTTYPE   , 2) //Spool
	oSetup:SetPropert(PD_ORIENTATION , nOrientation)
	oSetup:SetPropert(PD_DESTINATION , nLocal)
	oSetup:SetPropert(PD_MARGIN      , {60,60,60,60})
	oSetup:SetPropert(PD_PAPERSIZE   , 2)

	*/

	//|Atualiza perguntas padrões da impressão de danfe |
	SFP005(::cNumNF, ::cSerieNF)

	MV_PAR01 := ::cNumNF
	MV_PAR02 := ::cNumNF
	MV_PAR03 := ::cSerieNF

	dbSelectArea("SF2")
	SF2->(dbSetOrder(1))
	SF2->(dbSeek(xFilial("SF2") + ::cNumNF + ::cSerieNF))

	U_PrtNfeSef(cIdEnt,'','',oDanfe,oSetup,cFilePrint)

	oSetup := Nil

	::lImpresso := .F.
	//cFilePrint += '.pdf'
	If !File(cDirDanfe + cFilePrint)
		cNewFile := Substr(cFilePrint, 1, Len(cFilePrint)-9)
		aDados	:= Directory("\DANFES\" + cNewFile + "*.*")

		For nI := 1 To Len(aDados)
			cNewFile := Substr(aDados[nI,1], 1, Len(aDados[nI,1])-9)
			If cNewFile $ aDados[nI,1]
				cFilePrint := aDados[nI,1]
			EndIf
		Next nI
	EndIF

	If File(cDirDanfe + cFilePrint)
		::lImpresso	:= .T.
		::cArqImp	:= cRaiz + cDirDanfe + cFilePrint
		//|Envia o arquivo para impressora |
		::ImpArquivo()
	EndIf

Return ::lImpresso


//-------------------------------------------------------------------
/*/{Protheus.doc} ImpArquivo
description Envia o arquivo para impressora
@author  Pontin
@since   05.02.19
@version 1.0
/*/
//-------------------------------------------------------------------
Method ImpArquivo() Class TFZImprimeLaser

	Local oServer		:= Nil
	Local cNameFile		:= ""
	Local nI			:= 0

	If !Empty(::cPrinter) .And. !Empty(::cArqImp)

		ConOut( 'EXECUTANDO: print /d:"' + ::cPrinter +'" ' + ::cArqImp )

		WaitRunSrv( 'print /d:"' + ::cPrinter +'" ' + ::cArqImp , .F. , "c:\WINDOWS\system32\" )

		::lImpresso	:= .T.

	Else
		::lImpresso	:= .F.
	EndIf

Return .T.



/*
------------------------------------------------------------------------------------------------------------
Função		: SFP005
Tipo		: Função de Usuário
Descrição	: Seta os valores da DANFE a serem impressos no grupo de perguntas
Parâmetros	:
Retorno		:
------------------------------------------------------------------------------------------------------------
Atualizações:
- 25/06/2014 - Pontin - Construção inicial do fonte
------------------------------------------------------------------------------------------------------------
*/
Static Function SFP005(cDoc, cSerie)

	Local cOperac	:= 2	//|NF Saída |

	//|Alterando registro de pergunta |
	DbSelectArea("SX1")
	DbSetOrder(1)
	If DbSeek(PadR("NFSIGW",Len(SX1->X1_GRUPO))+"01")

		While AllTrim(SX1->X1_GRUPO) == "NFSIGW"
			RecLock("SX1", .F.)
			If AllTrim(SX1->X1_PERGUNT) = 'Da Serie ?'
				SX1->X1_CNT01 := cSerie
			ElseIf AllTrim(SX1->X1_PERGUNT) = 'Da Nota Fiscal ?'
				SX1->X1_CNT01 := cDoc
			ElseIf AllTrim(SX1->X1_PERGUNT) = 'Ate a Nota Fiscal ?'
				SX1->X1_CNT01 := cDoc
			ElseIf AllTrim(SX1->X1_PERGUNT) = 'Tipo de Operacao ?'
				SX1->X1_PRESEL := cOperac
			EndIf

			SX1->(MsUnLock())
			SX1->(dbSkip())

		EndDo

	EndIf

Return