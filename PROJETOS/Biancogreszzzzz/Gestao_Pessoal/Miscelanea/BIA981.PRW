#include "rwmake.ch"
#Include "Protheus.ch"
#include "topconn.ch"

User Function BIA981()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Ranisses A. Corona
Autor(Rev):= Marcos Alberto Soprani
Programa  := BIA250
Empresa   := Biancogres Cerâmica S/A
Data      := 18/01/07
Data(Rev) := 07/07/11
Uso       := Gestão de Pessoal
Aplicação := Importa o Cadastro de Funcionario para Manut. Banestik
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

@ 96,42 TO 323,505 DIALOG oDlg5 TITLE "Importa Funcionarios Banestik"
@ 8,10 TO 84,222
@ 16,12 SAY "Este programa tem por finalidade: "
@ 24,12 SAY "Importar os funcionarios para manutencao e geracao do Banestik"
@ 91,137 BMPBUTTON TYPE 5 ACTION Pergunte("BIA981",.T.)
@ 91,166 BMPBUTTON TYPE 1 ACTION OkProc()
@ 91,195 BMPBUTTON TYPE 2 ACTION Close(oDlg5)

ACTIVATE DIALOG oDlg5 CENTERED

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ OkProc     ¦ Autor ¦                     ¦ Data ¦          ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Aplicação ¦ Confirmação de Processamento                               ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function OkProc()

Processa( {|| RunProc() } )
Close(oDlg5)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ RunProc    ¦ Autor ¦                     ¦ Data ¦          ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Aplicação ¦ Executa o Processamento                                    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function RunProc()

Private Enter	:= CHR(13)+CHR(10)
PRIVATE cAdmissa := ""
PRIVATE cOBSERVACAO := ""
dbSelectArea("SRA")
dbSetOrder(1)
dbGoTop()

wQtdReg := reccount()
wProduto := SRA->RA_NOME

ProcRegua(wQtdReg)

cSql := ""
cSql += " SELECT MAX(ZS_SEQ) AS ZS_SEQ "
cSql += " FROM 	" + RetSqlName("SZS") + " SZS "
cSql += " WHERE D_E_L_E_T_ = '' "
If chkfile("RZ")
	DbSelectArea("RZ")
	DbCloseArea("RZ")
EndIf
TCQUERY cSql ALIAS "RZ" NEW

//Apura Valor do Banestik/ComproCard
cSql := ""
cSql += " SELECT ZS_VALOR, ZS_VALCOMP					"
cSql += " FROM 	" + RetSqlName("SZS") + " SZS	"
cSql += " WHERE D_E_L_E_T_	= '' AND	 				"
cSql += "				ZS_MAT			= '' AND				 	"
cSql += "				ZS_MESANO		= '"+MV_PAR01+"'	"
If chkfile("R001")
	DbSelectArea("R001")
	DbCloseArea("R001")
EndIf
TCQUERY cSql ALIAS "R001" NEW

nValBan	:= R001->ZS_VALOR
nValCom := R001->ZS_VALCOMP


a := Soma1(RZ->ZS_SEQ)

cSql := ""
cSql += "SELECT * FROM " + RetSqlName("SRA") + " "
cSql += "WHERE	(RA_SITFOLH <> 'D' OR SUBSTRING(RA_DEMISSA,1,6) >= '"+MV_PAR01+"')  AND "
cSql += "		RA_PERFGTS <> '2' AND "
cSql += "		RA_MAT  < '100000' AND "
cSql += "		RA_CLVL <> '4000' AND "
cSql += "		SUBSTRING(RA_ADMISSA,1,6) <= '"+MV_PAR01+"' AND "
cSql += "		D_E_L_E_T_ = '' "
cSql += "ORDER BY RA_NOME "
If chkfile("_SRA")
	DbSelectArea("_SRA")
	DbCloseArea("_SRA")
EndIf
TCQUERY cSql ALIAS "_SRA" NEW


While !_SRA->(Eof())
	if _SRA->RA_MAT = '000179'
		a := "s"
	end if
	IncProc("Importando Funcionario... "+_SRA->RA_NOME)
	cAdmissa := ""
	DbSelectArea("SZS")
	//If _SRA->RA_SITFOLH <> "D" .AND. _SRA->RA_PERFGTS <> 2
	
	//Nao gera para Estagiarios e Autonomos
	//If _SRA->RA_MAT <= '100000'
	RecLock("SZS",.T.)
	SZS->ZS_FILIAL	:= _SRA->RA_FILIAL
	SZS->ZS_SEQ		:= a
	SZS->ZS_MAT		:= _SRA->RA_MAT
	SZS->ZS_NOME	:= _SRA->RA_NOME
	
	//Verificar se o Funcionario esta com Afastamento
	cSql := ""
	cSql += " SELECT COUNT(*) AS QUANT "
	cSql += " FROM 	" + RetSqlName("SR8") + " SR8 "
	cSql += " WHERE SR8.R8_MAT 						=  '"+_SRA->RA_MAT+"' AND "
	cSql += "       SUBSTRING(SR8.R8_DATAINI,1,6)	>= '"+MV_PAR01+"'	AND "
	cSql += "       SUBSTRING(SR8.R8_DATAFIM,1,6)	<= '"+MV_PAR01+"'	AND "
	cSql += "       SR8.R8_TIPO						<> 'F' 				AND "
	cSql += "       SR8.R8_TIPOAFA                  <> '001' 			AND "
	cSql += "		SR8.D_E_L_E_T_ 					=  '' "
	If chkfile("R8")
		DbSelectArea("R8")
		DbCloseArea("R8")
	EndIf
	TCQUERY cSql ALIAS "R8" NEW
	
	//Verificar se o Funcionario esta com Faltas
	cSql := ""
	cSql += " SELECT COUNT(*) AS QUANT "
	cSql += " FROM " + RetSqlName("SPC") + " SPC "
	cSql += " WHERE SPC.PC_MAT 					= '"+_SRA->RA_MAT+"' AND "
	cSql += "       SPC.PC_ABONO 				= '015' 			AND "
	cSql += "       SUBSTRING(SPC.PC_DATA,1,6) 	= '"+MV_PAR01+"'	AND "
	cSql += "       D_E_L_E_T_ = '' "
	If chkfile("PC")
		DbSelectArea("PC")
		DbCloseArea("PC")
	EndIf
	TCQUERY cSql ALIAS "PC" NEW
	IF ALLTRIM(_SRA->RA_MAT) = "000699"
		A := "SS"
	END IF
	
	// VERIFICANDO ADMISSAO E DEMISSAO
	cSql := "SELECT SUBSTRING(RA_ADMISSA,7,2) AS ADMISSAO, '0' AS DEMISSAO FROM " + RetSqlName("SRA") + " " + Enter
	cSql += "WHERE RA_MAT = '"+_SRA->RA_MAT+"' AND " + Enter
	cSql += "SUBSTRING(RA_ADMISSA,1,6) >= '"+MV_PAR01+"' AND " + Enter
	cSql += "SUBSTRING(RA_ADMISSA,1,6) <= '"+MV_PAR01+"' AND " + Enter
	cSql += "D_E_L_E_T_ = '' " + Enter
	//cSql += " " + Enter
	cSql += "UNION " + Enter
	//cSql += " " + Enter
	//cSql += "-- DEMISSAO " + Enter
	cSql += "SELECT '0'  AS ADMISSAO, SUBSTRING(RA_DEMISSA,7,2) AS DEMISSAO  FROM " + RetSqlName("SRA") + " " + Enter
	cSql += "WHERE RA_MAT = '"+_SRA->RA_MAT+"' AND " + Enter
	cSql += "SUBSTRING(RA_DEMISSA,1,6) >= '"+MV_PAR01+"' AND " + Enter
	cSql += "SUBSTRING(RA_DEMISSA,1,6) <= '"+MV_PAR01+"' AND " + Enter
	cSql += "D_E_L_E_T_ = '' " + Enter
	If chkfile("ADMISSAO")
		DbSelectArea("ADMISSAO")
		DbCloseArea("ADMISSAO")
	EndIf
	TCQUERY cSql ALIAS "ADMISSAO" NEW
	
	// VERIFICANDO TROCA DE TURNO
	cSql := "SELECT SUBSTRING(PF_DATA,7,2) AS DIA, PF_TURNODE, PF_TURNOPA  " + Enter
	cSql += "FROM " + RetSqlName("SPF") + " " + Enter
	cSql += "WHERE	PF_MAT = '"+_SRA->RA_MAT+"' AND " + Enter
	cSql += "		SUBSTRING(PF_DATA,1,6) = '"+MV_PAR01+"' AND  " + Enter
	cSql += "		PF_TURNODE <> PF_TURNOPA AND D_E_L_E_T_ = ''			 " + Enter
	If chkfile("TROCATURNO")
		DbSelectArea("TROCATURNO")
		DbCloseArea("TROCATURNO")
	EndIf
	TCQUERY cSql ALIAS "TROCATURNO" NEW
	
	
	//Nvalo_Ticket 	:= Iif(_SRA->RA_TNOTRAB=="003",220,IF(_SRA->RA_TNOTRAB=="047",220,IF(_SRA->RA_TNOTRAB=="046",220,Iif(_SRA->RA_TNOTRAB=="006",160,100))))
	//Nvalo_Dia 		:= (Iif(_SRA->RA_TNOTRAB=="003",220,IF(_SRA->RA_TNOTRAB=="047",220,IF(_SRA->RA_TNOTRAB=="046",220,Iif(_SRA->RA_TNOTRAB=="006",160,100)))) )  / 30
	Nvalo_Ticket 	:= Iif(_SRA->RA_TNOTRAB=="003",nValBan,IF(_SRA->RA_TNOTRAB=="047",nValBan,IF(_SRA->RA_TNOTRAB=="046",nValBan,Iif(_SRA->RA_TNOTRAB=="006",nValBan,nValBan))))
	Nvalo_Dia 		:= (Iif(_SRA->RA_TNOTRAB=="003",nValBan,IF(_SRA->RA_TNOTRAB=="047",nValBan,IF(_SRA->RA_TNOTRAB=="046",nValBan,Iif(_SRA->RA_TNOTRAB=="006",nValBan,nValBan)))) )  / 30
	//Iif(_SRA->RA_TNOTRAB=="003",220,Iif(_SRA->RA_TNOTRAB=="006",160,100))
	nProporcional := "Nao"
	COBS := ""
	// TURNO DE TRABALHO
	IF !TROCATURNO->(EOF())
		COBS := "Transf. do turno " + TROCATURNO->PF_TURNODE + " para o turno " + TROCATURNO->PF_TURNOPA + " no dia " + TROCATURNO->DIA
		IF !ADMISSAO->(EOF())
			nProporcional := "Sim"
			//*******************************************************************************
			//**************** TROCA DE TURNO  COM ADMISSAO *********************************
			//*******************************************************************************
			IF VAL(ADMISSAO->ADMISSAO) <> 0
				nProporcional 	:= "Sim"
				//PROPORCIONAL AO PRIMEIRO TURNO
				NDIAS 					:= VAL(TROCATURNO->DIA) - (VAL(ADMISSAO->ADMISSAO))
				Nvalo_Dia 			:= (Iif(TROCATURNO->PF_TURNODE=="003",nValBan,IF(TROCATURNO->PF_TURNODE=="047",nValBan,IF(TROCATURNO->PF_TURNODE=="046",nValBan,Iif(TROCATURNO->PF_TURNODE=="006",nValBan,nValBan))))  )  / 30
				SZS->ZS_VALOR 	:=  NDIAS * Nvalo_Dia
				SZS->ZS_VALCOMP	:= IIF(_SRA->RA_TNOTRAB $ "047_045", ( NDIAS * (nValCom/30)) ,0 )
				
				//PROPORCIONAL AO SEGUNDO TURNO
				NDIAS 					:= 30 - (VAL(TROCATURNO->DIA) - 1)
				Nvalo_Dia 			:= (Iif(TROCATURNO->PF_TURNOPA=="003",nValBan,IF(TROCATURNO->PF_TURNOPA=="047",nValBan,IF(TROCATURNO->PF_TURNOPA=="046",nValBan,Iif(TROCATURNO->PF_TURNOPA=="006",nValBan,nValBan)))) )  / 30
				SZS->ZS_VALOR		+= NDIAS * Nvalo_Dia
				SZS->ZS_VALCOMP	+= IIF(_SRA->RA_TNOTRAB $ "047_045", ( NDIAS * (nValCom/30)) ,0 )
				cAdmissa 				:= "ADMISSÃO NO DIA " + ADMISSAO->ADMISSAO  + "  "
				//*******************************************************************************
				//**************** TROCA DE TURNO COM DEMISSAO *********************************
				//*******************************************************************************
			else
				nProporcional 	:= "Sim"
				//PROPORCIONAL AO PRIMEIRO TURNO
				NDIAS 					:= VAL(TROCATURNO->DIA) - 1
				Nvalo_Dia 			:= (Iif(TROCATURNO->PF_TURNODE=="003",nValBan,IF(TROCATURNO->PF_TURNODE=="047",nValBan,IF(TROCATURNO->PF_TURNODE=="046",nValBan,Iif(TROCATURNO->PF_TURNODE=="006",nValBan,nValBan)))) )  / 30
				SZS->ZS_VALOR 	:= NDIAS * Nvalo_Dia
				SZS->ZS_VALCOMP	:= IIF(_SRA->RA_TNOTRAB $ "047_045", ( NDIAS * (nValCom/30)) ,0 )
				
				//PROPORCIONAL AO SEGUNDO TURNO
				NDIAS 					:= VAL(ADMISSAO->DEMISSAO) - (VAL(TROCATURNO->DIA) - 1)
				Nvalo_Dia 			:= (Iif(TROCATURNO->PF_TURNOPA=="003",nValBan,IF(TROCATURNO->PF_TURNOPA=="047",nValBan,IF(TROCATURNO->PF_TURNOPA=="046",nValBan,Iif(TROCATURNO->PF_TURNOPA=="006",nValBan,nValBan)))) )  / 30
				SZS->ZS_VALOR		+= NDIAS * Nvalo_Dia
				SZS->ZS_VALCOMP	+= IIF(_SRA->RA_TNOTRAB $ "047_045", ( NDIAS * (nValCom/30)) ,0 )
				cAdmissa 				:= "DEMISSAO NO DIA " + ADMISSAO->DEMISSAO  + "  "
				
			end if
		ELSE
			//*******************************************************************************
			//*********************** TROCA DE TURNO ****************************************
			//*******************************************************************************
			nProporcional := "Sim"
			//PROPORCIONAL AO PRIMEIRO TURNO
			NDIAS := VAL(TROCATURNO->DIA) - 1
			Nvalo_Dia 		:= (Iif(TROCATURNO->PF_TURNODE=="003",nValBan,IF(TROCATURNO->PF_TURNODE=="047",nValBan,IF(TROCATURNO->PF_TURNODE=="046",nValBan,Iif(TROCATURNO->PF_TURNODE=="006",nValBan,nValBan)))) )  / 30
			SZS->ZS_VALOR 	:= NDIAS * Nvalo_Dia
			SZS->ZS_VALCOMP := IIF(_SRA->RA_TNOTRAB $ "047_045", ( NDIAS * (nValCom/30)) ,0 )
			
			//PROPORCIONAL AO SEGUNDO TURNO
			NDIAS := 30 - (VAL(TROCATURNO->DIA) - 1)
			Nvalo_Dia 		:= (Iif(TROCATURNO->PF_TURNOPA=="003",nValBan,IF(TROCATURNO->PF_TURNOPA=="047",nValBan,IF(TROCATURNO->PF_TURNOPA=="046",nValBan,Iif(TROCATURNO->PF_TURNOPA=="006",nValBan,nValBan)))) )  / 30
			SZS->ZS_VALOR 	+= NDIAS * Nvalo_Dia
			SZS->ZS_VALCOMP += IIF(_SRA->RA_TNOTRAB $ "047_045", ( NDIAS * (nValCom/30)) ,0 )
		END IF
		
	ELSE
		// ADMINSSAO E DEMISSAO
		IF !ADMISSAO->(EOF())
			nProporcional := "Sim"
			IF VAL(ADMISSAO->ADMISSAO) <> 0 	// vale proporcional a data de admissao
				SZS->ZS_VALOR := (30 - (VAL(ADMISSAO->ADMISSAO)-1)  ) * Nvalo_Dia
				cAdmissa := "ADMISSÃO NO DIA " + ADMISSAO->ADMISSAO  + "  "
			else  							// vale proporcional a data de demissao
				SZS->ZS_VALOR := VAL(ADMISSAO->DEMISSAO) * Nvalo_Dia
				cAdmissa := "DEMISSÃO NO DIA " + ADMISSAO->DEMISSAO  + "  "
			end if
		End If
		
	END IF
	
	
	
	//ATESTADOS
	If R8->QUANT == 0 .AND. PC->QUANT == 0 .AND. nProporcional == "Nao"
		// BUSCANDO O TURNO QUE ESTAVA NO PERIODO. POIS A CLAUDI PODE EXECUTAR A IMPORTACAO EM OUTRO PERIODO
		cSql := "SELECT SUBSTRING(PF_DATA,7,2) AS DIA, PF_TURNODE, PF_TURNOPA  " + Enter
		cSql += "FROM 	" + RetSqlName("SPF") + " " + Enter // ALTERADO POR MADALENO
		cSql += "WHERE	PF_MAT = '"+_SRA->RA_MAT+"' AND " + Enter
		cSql += "		SUBSTRING(PF_DATA,1,6) = '"+MV_PAR01+"' AND  " + Enter
		cSql += "		PF_TURNODE = PF_TURNOPA AND D_E_L_E_T_ = ''			 " + Enter
		If chkfile("ATROCATURNO")
			DbSelectArea("ATROCATURNO")
			DbCloseArea("ATROCATURNO")
		EndIf
		TCQUERY cSql ALIAS "ATROCATURNO" NEW
		//SZS->ZS_VALOR	:= Iif(ATROCATURNO->PF_TURNODE=="003",220,IF(ATROCATURNO->PF_TURNODE=="046",220,Iif(ATROCATURNO->PF_TURNODE=="006",160,100)))
		SZS->ZS_VALOR	:= Iif(_SRA->RA_TNOTRAB=="003",nValBan,IF(_SRA->RA_TNOTRAB=="047",nValBan,IF(_SRA->RA_TNOTRAB=="046",nValBan,Iif(_SRA->RA_TNOTRAB=="006",nValBan,nValBan))))
		SZS->ZS_VALCOMP := IIF(_SRA->RA_TNOTRAB $ "047_045", nValCom ,0 )
	ELSEIF R8->QUANT <> 0
		SZS->ZS_VALOR	:= Iif(_SRA->RA_TNOTRAB=="003",nValBan,IF(_SRA->RA_TNOTRAB=="047",nValBan,IF(_SRA->RA_TNOTRAB=="046",nValBan,Iif(_SRA->RA_TNOTRAB=="006",nValBan,nValBan))))
		SZS->ZS_VALCOMP := IIF(_SRA->RA_TNOTRAB $ "047_045", nValCom ,0 )
	ElseIF nProporcional == "Sim"
		SZS->ZS_VALOR	:= SZS->ZS_VALOR //- 100
		SZS->ZS_VALCOMP := IIF(_SRA->RA_TNOTRAB $ "047_045", nValCom ,0 )
	ELSE
		// BUSCANDO O TURNO QUE ESTAVA NO PERIODO. POIS A CLAUDI PODE EXECUTAR A IMPORTACAO EM OUTRO PERIODO
		cSql := "SELECT SUBSTRING(PF_DATA,7,2) AS DIA, PF_TURNODE, PF_TURNOPA  " + Enter
		cSql += "FROM 	" + RetSqlName("SPF") + " " + Enter // ALTERADO POR MADALENO
		cSql += "WHERE	PF_MAT = '"+_SRA->RA_MAT+"' AND " + Enter
		cSql += "		SUBSTRING(PF_DATA,1,6) = '"+MV_PAR01+"' AND  " + Enter
		cSql += "		PF_TURNODE = PF_TURNOPA AND D_E_L_E_T_ = ''			 " + Enter
		If chkfile("ATROCATURNO")
			DbSelectArea("ATROCATURNO")
			DbCloseArea("ATROCATURNO")
		EndIf
		TCQUERY cSql ALIAS "ATROCATURNO" NEW
		SZS->ZS_VALOR	:= Iif(ATROCATURNO->PF_TURNODE=="003",nValBan,IF(ATROCATURNO->PF_TURNODE=="047",nValBan,IF(ATROCATURNO->PF_TURNODE=="046",nValBan,Iif(ATROCATURNO->PF_TURNODE=="006",nValBan,nValBan))))
		SZS->ZS_VALOR	:= Iif(ATROCATURNO->PF_TURNODE=="003",nValBan,IF(ATROCATURNO->PF_TURNODE=="047",nValBan,IF(ATROCATURNO->PF_TURNODE=="046",nValBan,Iif(ATROCATURNO->PF_TURNODE=="006",nValBan,nValBan))))
		SZS->ZS_VALCOMP := IIF(_SRA->RA_TNOTRAB $ "047_045", nValCom ,0 )
		//SZS->ZS_VALOR	:= Nvalo_Ticket //- 100
	EndIf
	
	
	
	SZS->ZS_TIPO	:= "1"
	SZS->ZS_DTPAG	:= MV_PAR02
	SZS->ZS_MESANO	:= MV_PAR01
	
	
	cOBSERVACAO	:= cAdmissa + Iif(R8->QUANT > 0,"ATESTADO MÉDICO",Iif(PC->QUANT > 0,"FALTA","")) + COBS
	
	// BUSCANDO SE O FUNCIONARIO ESTA AFASTADO OU SO DE ATESTADO.
	//IF cOBSERVACAO = "ATESTADO MÉDICO" // "AFASTAMENTO"
	cSql := "SELECT COUNT(*) AS QUANT  " + Enter
	cSql += "FROM 		" + RetSqlName("SR8") + " SR8  " + Enter
	cSql += "WHERE	SR8.R8_MAT 					=  '"+_SRA->RA_MAT+"' AND  " + Enter
	cSql += "		SUBSTRING(SR8.R8_DATAFIM,1,6) 	= ''	AND  " + Enter
	cSql += "		SR8.R8_TIPO						<> 'F' 				AND  " + Enter
	cSql += "		SR8.R8_TIPOAFA                  <> '001' 			AND  " + Enter
	cSql += "		SR8.D_E_L_E_T_ 					=  '' 				 " + Enter
	If chkfile("AMOT_AFAS")
		DbSelectArea("AMOT_AFAS")
		DbCloseArea("AMOT_AFAS")
	EndIf
	TCQUERY cSql ALIAS "AMOT_AFAS" NEW
	IF AMOT_AFAS->QUANT > 0
		cOBSERVACAO := "AFASTAMENTO"
	END IF
	//END IF
	
	SZS->ZS_OBS := cOBSERVACAO
	
	
	MsUnLock()
	//EndIf
	//EndIf
	
	dbSelectArea("SRA")
	dbSetOrder(1)
	_SRA->(dbSkip())
	
End
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim do programa                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

MsgBox("Importacao Realizada com Sucesso!")

Return
