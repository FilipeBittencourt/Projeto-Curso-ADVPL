#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOTVSMAIL.CH"
#INCLUDE "DIRECTRY.CH"
#INCLUDE "fwcommand.ch"

User Function FAXMLSCH()

	/*���������������������������������������������������������������������������
	�����������������������������������������������������������������������������
	�������������������������������������������������������������������������Ŀ��
	���Programa  | FAXMLSCH � Autor � Henry de A. Woelffel  � Data �09/01/2012���
	�������������������������������������������������������������������������Ĵ��
	���Locacao   �                  �Contato � henry@facilesistemas.com.br    ���
	�������������������������������������������������������������������������Ĵ��
	���Descricao � Job para validacao de arquivos XML.                        ���
	�������������������������������������������������������������������������Ĵ��
	���Uso       � BIANCOGRES                                                 ���
	�����������������������������������������������������������������������������
	�����������������������������������������������������������������������������
	���������������������������������������������������������������������������*/

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
		If !EMPTY(_cRelErr) .and. 1 == 2 // Suspenso em 04/04/12 por Marcos Alberto at� segunda ordem.
			MAILWFC(1)
		EndIf

		ConOut("HORA: "+TIME()+" - Finalizando Processo FAXMLSCH " + aEmps[x,1]) // Implantado por Marcos Alberto em 20/03/12

		//Finaliza o ambiente criado
		RESET ENVIRONMENT
	NEXT i

RETURN

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  | GETEMPS  � Autor � Henry de A. Woelffel  � Data �09/01/2012���
�������������������������������������������������������������������������Ĵ��
���Locacao   �                  �Contato � henry@facilesistemas.com.br    ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Funcao para ler todas empresas no SIGAMAT.EMP              ���
�������������������������������������������������������������������������Ĵ��
���Uso       � BIANCOGRES                                                 ���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

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

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  | MAILWFC  � Autor � Henry de A. Woelffel  � Data �14/12/2011���
�������������������������������������������������������������������������Ĵ��
���Locacao   �                  �Contato � henry@facilesistemas.com.br    ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Programa para enviar e-mail do workflow executado.         ���
�������������������������������������������������������������������������Ĵ��
���Uso       �                                                            ���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function MAILWFC(_nSubj)

	Local 	cDest       := GetNewPar("MV_YMAILXM","wanisay.william@biancogres.com.br")
	Local 	cSubject    := "[FALHA NO ARQUIVO XML] Empresa/Filial: " + cEmpAnt+cFilAnt + " - " + DTOC(DDATABASE) + "   "+ TIME() + " Hs"
	Local 	cBody		:= "Os arquivos abaixo encontram-se com falha em sua estrutura." + chr(13) + chr(10) + _cRelErr

	U_BIAEnvMail(,cDest,cSubject,cBody)

RETURN()
