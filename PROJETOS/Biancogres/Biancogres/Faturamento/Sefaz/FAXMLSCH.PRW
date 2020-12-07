#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOTVSMAIL.CH"
#INCLUDE "DIRECTRY.CH"
#INCLUDE "fwcommand.ch"

User Function FAXMLSCH()

	/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa  | FAXMLSCH ³ Autor ³ Henry de A. Woelffel  ³ Data ³09/01/2012³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Locacao   ³                  ³Contato ³ henry@facilesistemas.com.br    ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Job para validacao de arquivos XML.                        ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Uso       ³ BIANCOGRES                                                 ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

	LOCAL 	aEmps 		:= GETEMPS()
	Local _ni, x
	Private oXML			:= NIL
	Private _cRelErr	:= ""

	FOR x := 1 to len(aEmps)

		//Inicializa o ambiente
		RPCSetType(3)
		RPCSetEnv(aEmps[x,1],aEmps[x,2],"","","","",{}) //inicializa o ambiente de acordo com dados do SIGAMAT

		ConOut("HORA: "+TIME()+" - Iniciando Processo FAXMLSCH " + aEmps[x,1]) // Implantado por Marcos Alberto em 20/03/12

		_cRelErr	:= ""

		//Diretorio para onde os arquivos serao movidos no caso de falha de estrutura
		_cPathErro := "\P10\XML_NFE\"+cEmpAnt+cFilAnt+"\PENDENTES\"

		//Relacao de arquivos encontrados no diretorio de entrada
		_cPathEntr := "\P10\XML_NFE\"+cEmpAnt+cFilAnt+"\RECEBIDOS\"
		_aArquivos := directory(_cPathEntr+"\*.*")

		for _ni := 1 to len(_aArquivos)

			//arquivo atual para leitura
			_cFile  := _cPathEntr + _aArquivos[_ni][1]

			//Nome para novo arquivo e pasta de destino para backup
			_cFile1 := _cPathErro + _aArquivos[_ni][1]

			//Funcao que Valida a estrutura do XML
			IF !U_FAVALXML(_cFile,@oXML,.T.)

				//Verifica se existe o diretorio, se nao existe o mesmo sera criado.
				IF !ExistDir(_cPathErro)
					MakeDir(_cPathErro)
				ENDIF

				//Variavel que acumula os arquivos com falha
				_cRelErr += chr(13) + chr(10) + " Arquivo: "+ _cFile1

				//Move arquivo para pasta determinada invalidos
				FRename(_cFile, _cFile1)
			ENDIF

		next

		//Envia e-mail com os erros
		If !EMPTY(_cRelErr) .and. 1 == 2 // Suspenso em 04/04/12 por Marcos Alberto até segunda ordem.
			MAILWFC(1)
		EndIf

		ConOut("HORA: "+TIME()+" - Finalizando Processo FAXMLSCH " + aEmps[x,1]) // Implantado por Marcos Alberto em 20/03/12

		//Finaliza o ambiente criado
		RESET ENVIRONMENT
	NEXT i

RETURN

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  | GETEMPS  ³ Autor ³ Henry de A. Woelffel  ³ Data ³09/01/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Locacao   ³                  ³Contato ³ henry@facilesistemas.com.br    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para ler todas empresas no SIGAMAT.EMP              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ BIANCOGRES                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

STATIC FUNCTION GETEMPS

	local aEmp := {}
	Local _aSm0	:=	{}
	Local _nI
	Local _cEmp


	_aSm0	:=	FWLoadSM0()

	For _nI	:=	1 to Len(_aSM0)

		_cEmp	:=	Iif(!Empty(_aSM0[_nI,SM0_EMPRESA]),_aSM0[_nI,SM0_EMPRESA],_aSM0[_nI,SM0_GRPEMP])

		aadd(aEmp ,{_cEmp, _aSM0[_nI,SM0_FILIAL]})

	Next


RETURN aEmp

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  | MAILWFC  ³ Autor ³ Henry de A. Woelffel  ³ Data ³14/12/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Locacao   ³                  ³Contato ³ henry@facilesistemas.com.br    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Programa para enviar e-mail do workflow executado.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MAILWFC(_nSubj)

	Local 	cDest       := GetNewPar("MV_YMAILXM","wanisay.william@biancogres.com.br")
	Local 	cSubject    := "[FALHA NO ARQUIVO XML] Empresa/Filial: " + cEmpAnt+cFilAnt + " - " + DTOC(DDATABASE) + "   "+ TIME() + " Hs"
	Local 	cBody		:= "Os arquivos abaixo encontram-se com falha em sua estrutura." + chr(13) + chr(10) + _cRelErr

	U_BIAEnvMail(,cDest,cSubject,cBody)

RETURN()
