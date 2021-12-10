#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BIA125
@author Tiago Rossini Coradini
@since 07/03/2017
@version 1.0
@description Valida ambiente de uso do sistema
@type function
/*/

User Function BIA125()
Public CREPATU := Space(1)	//Codigo do representante ativo no sistema
Public CLINHAATU := Space(1)	//Codigo da Linha ativa no sistema
Public cContador := 0				//Variavel para controle na abertura de programas Posicao de Clientes / Consulta Estoque / MT500APO
Public cContAux	:= 0				//Variavel para controle do envio de e-mail MT500APO 
Private cEOL := CHR(13)+CHR(10)
Private cEnvironment
Private cDataBase
Private nDepart := ""

//SetPrvt("CMSG,CENVIRONMENT,CDATABASE,_DADUSER")

cEnvironment := Upper(AllTrim(getenvserver()))
cEnvironment := iif(cEnvironment="PRODUCAO","DADOSADV",cEnvironment)
cDataBase    := AllTrim(U_DBNAME())


If !"FACILE" $ Alltrim(cUserName) 
	
	If Upper(GetSrvProfString( 'theme','')) <> "SUNSET"

		// Verifica se o Environment e o Nome do Banco de Dados sao o mesmo, se forem diferentes informa ao usuario
		If !cEnvironment $ "REQUISICAO_REPRESENTANTE_BALREQ_REMOTO_FECHAMENTO_MARCOS-PROD_MARCOS-DES_LUANA-PROD_LUANA-DES_COLABORACAO_SCHEDULE_COMP-MARCOS_COMP-LUANA_COMP-RODRIGO_COMP-WANISAY_COMP-RANISSES_COMP-GABRIEL_COMP-FERNANDO_COMP-TIAGO_DESENVOLVIMENTO_DSNV-MARCOS"
			If cEnvironment <> cDataBase
				cMsg := ""
				cMsg += "ATENCAO!!"+CHR(13)
				cMsg += ""+CHR(13)
				cMsg += ""+CHR(13)
				cMsg += "O Environment e o Banco de Dados usados sao diferentes."+CHR(13)
				cMsg += "Todos os trabalhos executados nesta secao do Siga serao"+CHR(13)
				cMsg += "processados no Banco de Dados indicado abaixo.         "+CHR(13)
				cMsg += ""+CHR(13)
				cMsg += "environment:"+CHR(13)
				cMsg += cEnvironment+CHR(13)
				cMsg += ""+CHR(13)
				cMsg += "banco:"+CHR(13)
				cMsg += cDataBase+CHR(13)
				alert(cMsg)
			EndIf
	
		EndIf

	EndIf
	
EndIf


// Cria a variavel com o codigo do representante
aArea := GetArea()
DbSelectArea("SA3")
nOrdem := INDEXORD()
psworder(2)                         // Pesquisa por Nome
If  pswseek(cUserName,.t.)          // Nome do usuario, Pesquisa usuarios
	_daduser  	:= pswret(1)     	// Numero do registro
	nDepart		:= _daduser[1,12]
EndIf

//Verifica se o Cadastro do Vendedor esta correto.
If SUBSTRING(Alltrim(cUserName),1,1) $ ("0_1_2_3_4_5_6_7_8_9") .AND. "REPRESENTANTE" <> Alltrim(Upper(nDepart))
	Alert("Representante nao cadastrado como Vendedor, FAVOR ENTRAR EM CONTATO COM A FABRICA")
	Final("O sistema será fechado agora!")
	cRepAtu := "888555"
EndIf

If Alltrim(Upper(nDepart))=="REPRESENTANTE"
	
	DbSelectArea("SA3")
	DbSetOrder(1)
	If DbSeek(xFilial("SA3")+cUserName)
		cRepAtu := SA3->A3_COD
	Else
		Alert("Representante nao cadastrado como Vendedor, FAVOR ENTRAR EM CONTATO COM A FABRICA.")
		Final("O sistema será fechado agora!")
		cRepAtu := "888555"
	EndIf
EndIf
//Define o Almoxarifado do Representante
If cempant $ "01_05_14"
	If Alltrim(Upper(nDepart))=="REPRESENTANTE"
		If (SA3->A3_COMIS > 0 .and. SA3->A3_YCOMISI == 0) .Or. SA3->A3_YCOMVIN > 0
			cLinhaAtu := "02"
		ElseIf SA3->A3_COMIS == 0 .and. SA3->A3_YCOMISI > 0
			cLinhaAtu := "04"
		Else
			cLinhaAtu := "02_04"
		EndIf
	EndIf
EndIf

// Carrega teclas de atalho
// Para usuarios internos na Biancogres
If Alltrim(cRepAtu) == "" 
	
	If CMODULO = "FIN"
		SetKey(VK_F4, {|| U_ExecKey("U_BIAF120()") })		      	// Atalho para Conposicao de Saldo
		SetKey(VK_F8, {|| U_ExecKey("U_Leitor()") })					// Atalho para Leitora de Codigo Barras
		SetKey(VK_F9, {|| U_ExecKey("U_BIAF110()") })		      	// Atalho para Conposicao de Saldo
	ELSE
	  SetKey(VK_F12,{|| U_ExecKey("U_ALT_CONT()") })					    // Atalho para ALTERACAO DO CONTATO NO CALCENTER		
	EndIf
	
	SetKey(VK_F5, {|| U_ExecKey("U_RESUM_RECONCILIA()") })          	// Atalho para Consulta Posicao do Cliente
	SetKey(VK_F6, {|| U_ExecKey("U_ConsEst()") })						// Atalho para Consulta Estoque
	SetKey(VK_F7, {|| U_ExecKey("U_BVERIPESO()") })
	SetKey(VK_F10,{|| U_ExecKey("U_ATALHOS()") })						// Atalho de Consulta Posição Cliente, Saldo Pedido Compras e Linha Digitavel
	SetKey(K_CTRL_F10,{|| U_ExecKey("U_ATALHOS()") })						// Atalho de Consulta Posição Cliente, Saldo Pedido Compras e Linha Digitavel	
	SetKey(VK_F11,{|| U_ExecKey("U_INC_OBS()") })

// Para acesso do Representante
Else
	SetKey(VK_F6, {|| U_ExecKey("U_ConsRep()") })	                    // Atalho para Consulta Estoque
	SetKey(VK_F10,{|| U_ExecKey("U_POS_CLI()") })						// Atalho de Consulta Posição Cliente, Saldo Pedido Compras e Linha Digitavel
	SetKey(K_CTRL_F10,{|| U_ExecKey("U_POS_CLI()") })						// Atalho de Consulta Posição Cliente, Saldo Pedido Compras e Linha Digitavel	
EndIf

//If CMODULO == "COM" .And. U_VALOPER("008",.F.)  
If CMODULO == "COM" .And. U_VALOPER("008",.F.) 
	SetKey(K_CTRL_F9, {|| U_ExecKey("U_PRE_FOLLUP()") })			    // Atalho para Conposicao de Saldo
	SetKey(K_CTRL_F8, {||U_ExecKey("U_BConsultUSR()") })			    // Atalho para Consulta de Cadastro de Usuários
EndIf

//Usuários com acesso a rotina de Troca-Quente
If U_VALOPER("009",.F.)
	SetKey(K_CTRL_F7, {|| U_ExecKey("U_AtualForm()") })			    // Atalho para Troca a quente
	SetKey(VK_F2	, {|| U_ExecKey("U_ConsRep()") })	                // Atalho para Consulta Estoque
EndIf

DbSelectArea("SA3")
DbSetOrder(nOrdem)
RestArea(aArea)
RETURN


// Execução de teclas de atalho
User Function ExecKey(cFunction)
		
	// Somente executa funcao associada a tecla, se não existir processos em execução
	// Tipos de processos em execução: Barras de processamento e Impressão de relatorios (SetPrint, TReport e Crystall) 
	
	// Tiago Rossini Coradini - 12-05-2017 - Bloco comentado
	// If !InProcess()
		&(cFunction)
	// EndIf

Return()


// Verifica se existe algum processo em execução
Static Function InProcess()
Local lRet := .T.

	lRet := FWIsInCallStack("Processa") .Or. FWIsInCallStack("FwMsSpool") .Or. FWIsInCallStack("Preview") .Or. FWIsInCallStack("SetPrint") .Or.;
					FWIsInCallStack("StarPrint") .Or. FWIsInCallStack("RptStatus") .Or. FWIsInCallStack("MpReport") .Or. FWIsInCallStack("PrintDialog") .Or.;
					FWIsInCallStack("CallCrys")

Return(lRet)
