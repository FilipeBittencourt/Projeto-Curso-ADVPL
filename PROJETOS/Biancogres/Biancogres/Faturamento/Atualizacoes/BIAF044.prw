#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF044
@author Tiago Rossini Coradini
@since 16/08/2016
@version 1.0
@description Geração de arquivo com dados de motoristas para importação do sistema CCURE
@type function
/*/

User Function BIAF044()

	If cEmpAnt $ "01/05/12" .And. (Inclui .Or. Altera) 

		fImport()

	EndIf

Return()

//**************************************************************************************
//*                                                                                    *
//**************************************************************************************
Static Function fImport()

	Local lRet := .T.
	Local cDir := "\P10\CCURE\"
	Local cArquivo := "MOT" +"-"+ StrTran(dToC(Date()), "/") +"-"+ StrTran(Time(), ":")
	Local nHandle := 0
	Local cCRLF := Chr(13) + Chr(10)
	Local aCab := {}
	Local aLinhas := {}
	Local cPla := ""
	Local cCarr := ""
	Local cDesc := ""
	Local cDNIT := ""	
	Local nX	
	Local nY

	aAdd(aCab, "CODEMPR")
	aAdd(aCab, "EMPR")
	aAdd(aCab, "CRACHA")
	aAdd(aCab, "MATRIC")
	aAdd(aCab, "NOME")
	aAdd(aCab, "CPF")
	aAdd(aCab, "DTNASC")
	aAdd(aCab, "CLVL")
	aAdd(aCab, "DCLVL")
	aAdd(aCab, "TELEFONE")
	aAdd(aCab, "ENDERECO")
	aAdd(aCab, "COMPLEMENTO")
	aAdd(aCab, "BAIRRO")
	aAdd(aCab, "MUNICIPIO")
	aAdd(aCab, "ESTADO")
	aAdd(aCab, "CNH")
	aAdd(aCab, "DTVCNH")
	aAdd(aCab, "PLACA")
	aAdd(aCab, "CARRETA")
	aAdd(aCab, "MODELO")
	aAdd(aCab, "DNIT")
	aAdd(aCab, "BLOQUEIO_ACESSO")
	aAdd(aCab, "MOTIVO_BLOQUEIO")
	aAdd(aCab, "TIPO")	

	DbSelectArea("DA3")
	DbSetOrder(2)
	If DA3->(DbSeek(xFilial("DA3") + M->DA4_COD))

		cPla  := AllTrim(DA3->DA3_PLACA)
		cCarr := AllTrim(DA3->DA3_YCARRE)
		cDesc := AllTrim(DA3->DA3_DESC)
		cDNIT := AllTrim(DA3->DA3_YDNIT)		

	EndIf

	ggCracha := IIF(cEmpAnt == "01", "00", cEmpAnt) + "0000000" + M->DA4_COD

	aAdd(aLinhas, {cEmpAnt                                                       ,;
	fGetEmp()                                                                    ,;
	ggCracha                                                                     ,;
	"T" + M->DA4_COD                                                             ,;
	AllTrim(M->DA4_NOME)                                                         ,;
	AllTrim(M->DA4_CGC)                                                          ,;
	""                                                                           ,;
	"1000"                                                                       ,;
	"ADM - FINANCEIRO GERAL"                                                     ,;
	StrTran(AllTrim(M->DA4_TEL), "-")                                            ,;
	StrTran(AllTrim(M->DA4_END), ",")                                            ,;
	""                                                                           ,;
	AllTrim(M->DA4_BAIRRO)                                                       ,;
	AllTrim(M->DA4_MUN)                                                          ,;
	M->DA4_EST                                                                   ,;
	AllTrim(M->DA4_NUMCNH)                                                       ,;
	DToC(M->DA4_DTVCNH)                                                          ,;
	cPla                                                                         ,;
	cCarr                                                                        ,;
	cDesc                                                                        ,; 
	cDNIT                                                                        ,;
	If (M->DA4_BLQMOT == "1", "True", "False")                                   ,;
	""                                                                           ,;
	"Transportador"                                                              })

	// Verifica se o diretoria ja existe
	If !ExistDir(cDir)

		// Cria diretorio
		lRet := MakeDir(cDir) == 0

	EndIf

	If lRet

		nHandle := MsFCreate(cDir + cArquivo + ".CSV", 0)

		If nHandle > 0

			For nX := 1 To Len(aCab)
				fWrite(nHandle, aCab[nX] + If (nX < Len(aCab), ",", ""))
			Next

			fWrite(nHandle, cCRLF)

			For nX := 1 To Len(aLinhas)

				For nY := 1 To Len(aCab)
					fWrite(nHandle, Transform(aLinhas[nX, nY], "@!" ) + If (nY < Len(aCab), ",", ""))
				Next nY

				fWrite(nHandle, cCRLF)

			Next nX

			fClose(nHandle)			

		EndIf

	EndIf

Return()

//**************************************************************************************
//*                                                                                    *
//**************************************************************************************
Static Function fGetEmp()

	Local cRet := ""

	If cEmpAnt == "01"

		cRet := "BIANCOGRES"

	ElseIf cEmpAnt == "05"

		cRet := "INCESA"

	ElseIf cEmpAnt == "12"

		cRet := "ST GESTAO"

	EndIf

Return(cRet)
