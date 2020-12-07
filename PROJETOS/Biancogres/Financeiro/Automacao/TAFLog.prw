#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAFLog
@author Tiago Rossini Coradini
@since 23/10/2018
@project Automação Financeira
@version 1.0
@description Classe para inclusao de log de procedimentos
@type class
/*/

/*
Identificadores de processos

Identificadores de operacoes: Propriedade - cOperac
P=Pagar
R=Receber
T=Tesouraria

Identificadores de metodos: Propriedade - cMetodo
Retorno a Pagar: Classe - TAFRetornoPagar
I_RET=Inicio Retorno
F_RET=Fim Retorno
I_RET_TIT=Inicio Retorno Titulo
F_RET_TIT=Fim Retorno Titulo
N_RET_TIT=Retorno sem titulos

Identificadores de metodos: Propriedade - cMetodo
Retorno a Pagar: Classe - TAFDDA
I_RET_TIT_DDA=Inicio Retorno DDA
F_RET_TIT_DDA=Fim Retorno DDA
S_RET_TIT_DDA=Titulo Adicionado ao DDA
FOR_RET_TIT_DDA=Titulo Adicionado ao DDA sem fornecedor
N_RET_TIT_DDA=Titulo NAO adicionado ao DDA

Identificadores de metodos: Propriedade - cMetodo	
Remessa a Receber: Classe - TAFRemessaReceber
I_REM_LOT=Inicio Remessa Lote
F_REM_LOT=Fim Remessa Lote
I_REM_TIT=Inicio Remessa Titulo
F_REM_TIT=Fim Remessa Titulo

Identificadores de metodos: Propriedade - cMetodo	
Remessa a Receber: Classe - TAFApiRemessaReceber
I_RET_LOT=Inicio retorno Lote
F_RET_LOT=Fim retorno Lote
R_RET_OK=Retorno ok
R_RET_ER=Retorno com erro

Identificadores de Movimento Remessa a Receber: Classe - TAFMovimentoRemessaReceber
I_SEL_TIT=Inicio Selecao Titulos
F_SEL_TIT=Fim Selecao Titulos
S_SEL_TIT_NORULE=Titulo sem regra
S_SEL_TIT=Titulo Selecionado
N_SEL_TIT=Nao Possui Titulos a Selecionar - Dia sem movimento

Identificadores de Regras de Comunicacao Bancaria a Receber: Classe - TAFRegraComunicacaoBancariaReceber
I_RCB=Inicio Regra Comunicacao Bancaria
S_RCB=Titulo com Regra Valida 
F_RCB=Fim Regra Comunicacao Bancaria
VG_RCB=Grupo de Regra Valido
NVG_RCB=Grupo de Regra Nao Valido
VR_RCB=Regra Valida
NVR_RCB=Regra Nao Valida

Identificadores de Bordero a Receber: Classe - TAFBorderoReceber
I_BOR=Inicio Bordero
S_BOR=Titulo adicionado ao Bordero
F_BOR=Fim Bordero

Identificadores de Bordero a Receber: Classe - TAFDescontoPagar
R_DESC_ER=Erro ExecAuto
R_DESC_OK=Efetuado Desconto tarifa

Identificadores de Bordero a Receber: Classe - TAFCnabPagar
R_CNAB_ER=Erro ExecAuto
R_CNAB_OK=CNAB criado

Identificador de Envio de Workflow: Propriedade - cEnvWF	
S=Sim
N=Nao

Data cRetOri => Origem do retorno
Data cRetMen => Mensagem do retorno

*/

Class TAFLog From LongClassName

	Data cEmp
	Data cFil
	Data cIDProc
	Data cOperac
	Data cMetodo
	Data cTabela
	Data nIDTab
	Data cStatus
	Data dDtIni
	Data cHrIni
	Data dDtFin
	Data cHrFin
	Data cStAPI
	Data cURL
	Data cJsonE
	Data cJsonR
	Data nRecNo
	Data cUser
	Data cEnvWF
	Data cRetOri
	Data cRetMen

	Method New() Constructor
	Method SetProperty()
	Method Insert(lAviso)
	Method Update()
	Method Save(lNew, lAviso)
	Method SetConsoleLog()

EndClass


Method New() Class TAFLog

	::SetProperty()

Return()


Method SetProperty() Class TAFLog

	::cEmp := cEmpAnt
	::cFil := cFilAnt
	::cIDProc := ""
	::cOperac := ""
	::cMetodo := ""
	::cTabela := ""
	::nIDTab := 0
	::cStatus := "0"
	::dDtIni := dDataBase
	::cHrIni := Time()
	::dDtFin := dDataBase
	::cHrFin := Time()
	::cStAPI := "0"
	::cURL := ""
	::cJsonE := ""
	::cJsonR := ""
	::cUser := __cUserId
	::cEnvWF := "N"
	::cRetOri := ""
	::cRetMen := ""

Return()


Method Insert(lAviso) Class TAFLog

	Default lAviso := .F.

	::Save(.T., lAviso)

Return()


Method Update(lAviso) Class TAFLog

	Default lAviso := .F.

	If ::nRecNo > 0

		DbSelectArea("ZK2")
		ZK2->(DbGoTo(::nRecNo))

		::Save(.F., lAviso)

	EndIf

Return()


Method Save(lNew, lAviso) Class TAFLog

	Default lNew := .T.

	RecLock("ZK2", lNew)

	ZK2->ZK2_FILIAL	:= xFilial("ZK2")
	ZK2->ZK2_EMP := ::cEmp
	ZK2->ZK2_FIL := ::cFil
	ZK2->ZK2_IDPROC := ::cIDProc
	ZK2->ZK2_OPERAC := ::cOperac
	ZK2->ZK2_METODO := ::cMetodo
	ZK2->ZK2_TABELA := ::cTabela
	ZK2->ZK2_IDTAB := ::nIDTab
	ZK2->ZK2_STATUS := ::cStatus
	ZK2->ZK2_DTINI := ::dDtIni
	ZK2->ZK2_HRINI := ::cHrIni
	ZK2->ZK2_DTFIN := ::dDtFin
	ZK2->ZK2_HRFIN := ::cHrFin
	ZK2->ZK2_STAPI := ::cStAPI
	ZK2->ZK2_URL := ::cURL
	ZK2->ZK2_JSONE := ::cJsonE
	ZK2->ZK2_JSONR := ::cJsonR
	ZK2->ZK2_USER := ::cUser
	ZK2->ZK2_ENVWF := ::cEnvWF
	ZK2->ZK2_RETORI := ::cRetOri
	ZK2->ZK2_RETMEN := ::cRetMen

	ZK2->(MsUnLock())

	If lAviso

		RecLock("ZK2", .F.)
		ZK2->ZK2_IDTAB := ZK2->(RecNo())
		ZK2->(MsUnLock())

	EndIf

	::SetConsoleLog()

	::nRecNo := ZK2->(RecNo())

	::SetProperty()

Return()


Method SetConsoleLog() Class TAFLog
	Local cLog := ""

	cLog := Replicate("-", 120) + Chr(13)
	cLog += "[" + Dtoc(Date()) + Space(1) + Time() + "] -- Automacao Financeira -- Log de Processos" + Chr(13)
	cLog += "[Thread: " + AllTrim(cValToChar(ThreadId())) + "]" + Chr(13)
	cLog += "[Empresa: " + cEmpAnt + "]" + Chr(13)
	cLog += "[Filial: " + cFilAnt + "]" + Chr(13)
	cLog += "[Processo: " + ::cIDProc + "]" + Chr(13)
	cLog += "[Operacao: " + AllTrim(::cOperac) + "]" + Chr(13)
	cLog += "[Metodo: " + AllTrim(::cMetodo) + "]" + Chr(13)
	cLog += "[Tabela: " + AllTrim(::cTabela) + "]" + Chr(13)
	cLog += "[ID Tabela: " + cValToChar(::nIDTab) + "]" + Chr(13)
	cLog += "[Envia WF: " + cValToChar(::cEnvWF) + "]" + Chr(13)
	cLog += Replicate("-", 120)

	//ConOut(Chr(13) + cLog) Ticket: 27368 - Retirado pois devido ao grande numero de conouts nao esta sendo possivel analiser problemas no arquivo console.log (Para isso leia a ZK2)

Return()
