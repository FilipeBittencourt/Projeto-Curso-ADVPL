#INCLUDE "rwmake.ch"

#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#include "topconn.ch"


/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     :=
Autor(REV):= Marcos Alberto Soprani
Programa  := FARMA1
Empresa   := Biancogres Cerâmica S/A
Data      := 04/11/05
Data(REV) := 28/04/15
Uso       := Gestão de Pessoal
Aplicação := Importar verba de Farmácia
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

User Function FARMA1()

	Private fdPeriod := Space(6)
	Private cString := "RGB"
	Private cProcesso	:=	""
	Private cFilRCJ		:= ""
	Private Enter := CHR(13)+CHR(10)

	dbSelectArea("RGB")
	dbSetOrder(1)

	If ValidPerg()
		fProcessa()
	EndIf

Return

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ OKLETXT  º Autor ³ AP6 IDE            º Data ³  04/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao chamada pelo botao OK na tela inicial de processamenº±±
±±º          ³ to. Executa a leitura do arquivo texto.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function fProcessa()

	Private nHdl    := fOpen(MV_PAR06,68)
	Private cEOL    := "CHR(13)+CHR(10)"

	If Empty(cEOL)
		cEOL := CHR(13)+CHR(10)
	Else
		cEOL := Trim(cEOL)
		cEOL := &cEOL
	Endif

	If nHdl == -1
		MsgAlert("O arquivo de nome "+MV_PAR06+" nao pode ser aberto! Verifique os parametros.","Atencao!")
		Return
	Endif

	Do Case

		Case MV_PAR05 == '411'
		Processa({|| RunFarm() },"Processando...")
		IncProc()

		Case MV_PAR05 == '446'
		Processa({|| RunTel() },"Processando...")
		IncProc()

		OtherWise
		MsgAlert("Não Existe Layout Configurado para a Verba Selecionada","Atencao!")	

	End

Return

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ RUNCONT  º Autor ³ AP5 IDE            º Data ³  04/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela PROCESSA.  A funcao PROCESSA  º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function RunFarm()

	Local nTamFile, nTamLin, cBuffer, nBtLidos, cSitua := ""
	
	Private oExcel      := nil 
	

	nTamFile := fSeek(nHdl,0,2)
	fSeek(nHdl,0,0)
	nTamLin  := 23+Len(cEOL)
	cBuffer  := Space(nTamLin)

	nBtLidos := fRead(nHdl,@cBuffer,nTamLin)

	ProcRegua(nTamFile)
	
	oExcel := FWMSEXCEL():New()
	
	nxPlan := "Planilha 01"
	nxTabl := "Colaboradores Demitidos/Transferidos"
	
	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "Matrícula"	,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Nome"			,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Situação"		,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Valor"		,3,2, .T.)

	While nBtLidos >= nTamLin

		IncProc()

		DbSelectArea("SRA")
		DbSetOrder(1)
		DbSeek(xFilial("SRA")+Substr(cBuffer,01,06),.T.)

		IF SRA->RA_SITFOLH <> 'D'

			dbSelectArea("RGB")
			DbSetOrder(7)
			DbSeek( xFilial("RGB")+ SRA->RA_MAT + MV_PAR05 + SRA->RA_CC,.T.)

			IF RGB->RGB_FILIAL = xFilial(cString) .AND. RGB->RGB_CC = SRA->RA_CC .AND. RGB->RGB_MAT = SRA->RA_MAT .AND. RGB->RGB_PD = MV_PAR05

				RecLock(cString,.F.)
				RGB->RGB_VALOR 	:= Val (alltrim(SubStr(cBuffer,07,17)))
				MSUnLock()

			ELSE

				RecLock(cString,.T.)
				RGB->RGB_FILIAL := XFILIAL("RGB")
				RGB->RGB_PROCES := MV_PAR01
				RGB->RGB_PERIOD := MV_PAR03
				RGB->RGB_SEMANA := "01"
				RGB->RGB_ROTEIR := MV_PAR02
				RGB->RGB_MAT 	:= Substr(cBuffer,01,06)
				RGB->RGB_PD    	:= MV_PAR05
				RGB->RGB_TIPO1 	:= "V"
				RGB->RGB_TIPO2 	:= "I"
				RGB->RGB_VALOR 	:= Val (alltrim(SubStr(cBuffer,07,17)))
				RGB->RGB_DTREF 	:= DDATABASE
				RGB->RGB_CC		:= SRA->RA_CC
				RGB->RGB_ITEM	:= "GPE000000"
				RGB->RGB_CLVL	:= SRA->RA_CLVL
				RGB->RGB_CODFUN	:= SRA->RA_CODFUNC
				RGB->RGB_DEPTO	:= SRA->RA_DEPTO
				MSUnLock()

			END IF

		ELSE

			GU004 := "SELECT * " + Enter
			GU004 += "  FROM SRE010" + Enter
			GU004 += "WHERE RE_EMPD = " + cEmpAnt + Enter
			GU004 += "AND RE_FILIALD =" + xFilial(cString) + Enter
			GU004 += "AND RE_MATD = " + SRA->RA_MAT + Enter
			GU004 += "AND RE_DATA = '" + dtos(SRA->RA_DEMISSA) +"' " + Enter
			GU004 += "AND D_E_L_E_T_ = ''" + Enter
			
			
			GUcIndex := CriaTrab(Nil,.f.)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,GU004),'GU04',.F.,.T.)
			dbSelectArea("GU04")
			dbGoTop()

			
			Count To nTotReg 
			
			if nTotReg > 0
				cSitua := 'Transferido(a)'
			ELSE
				cSitua := 'Demitido(a)'
			END IF
			
			oExcel:AddRow(nxPlan, nxTabl, { SRA->RA_MAT,;
											SRA->RA_NOME,;
			 								cSitua,;
			 								Replace(alltrim(SubStr(cBuffer,07,17)),'.',',')})
			
			
		GU04->(dbCloseArea())

		END IF
		
		nBtLidos := fRead(nHdl,@cBuffer,nTamLin) // Leitura da proxima linha do arquivo texto			

		SRA->(dbSkip())

	EndDo

	Ferase(GUcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(GUcIndex+OrdBagExt())          //indice gerado
	
	xArqTemp := "lista_demitidos_"+cEmpAnt
	
	If File("C:\TEMP\"+xArqTemp+".xml")
		If fErase("C:\TEMP\"+xArqTemp+".xml") == -1
			Aviso('Arquivo em uso', 'Favor fechar o arquivo: ' + 'C:\TEMP\'+xArqTemp+'.xml' + ' antes de prosseguir!!!',{'Ok'})
		EndIf
	EndIf
	
	oExcel:Activate()
	oExcel:GetXMLFile("C:\TEMP\"+xArqTemp+".xml")
	
	cCrLf := Chr(13) + Chr(10)
	If ! ApOleClient( 'MsExcel' )
		MsgAlert( "MsExcel nao instalado!"+cCrLf+cCrLf+"Você poderá recuperar este arquivo em: "+"C:\TEMP\"+xArqTemp+".xml" )
	Else
		oExcel:= MsExcel():New()
		oExcel:WorkBooks:Open( "C:\TEMP\"+xArqTemp+".xml" ) // Abre uma planilha
		oExcel:SetVisible(.T.)
	EndIf

	msgbox("Importacao Realizada com sucesso","Importar Verba 411")

Return

Static Function RunTel()

	Local nTamFile, nTamLin, cBuffer, nBtLidos

	Local _cCpf, _cMatr, _cCCus, msProcess, msRoteiro

	nTamFile := fSeek(nHdl,0,2)
	fSeek(nHdl,0,0)
	nTamLin  := 25+Len(cEOL)
	cBuffer  := Space(nTamLin)

	nBtLidos := fRead(nHdl,@cBuffer,nTamLin)

	ProcRegua(nTamFile)

	While nBtLidos >= nTamLin

		IncProc()
		_cCpf	:=	Alltrim(Substr(cBuffer,01,14))
		DbSelectArea("SRA")
		SRA->(DbSetOrder(5))
		If SRA->(DbSeek(xFilial("SRA")+_cCpf,.T.))
			_cMatr	:=	""
			_cCCus	:=	""
			msProcess := "" 
			msRoteiro := ""
			While SRA->(!Eof()) .and. xFilial("SRA") == SRA->RA_FILIAL .and. Alltrim(_cCpf) == SRA->RA_CIC
				If Empty(SRA->RA_DEMISSA)
					_cMatr := SRA->RA_MAT
					_cCCus := SRA->RA_CC
					msProcess := SRA->RA_PROCES
					msRoteiro := IIF (SRA->RA_PROCES == "00003", "AUT", "FOL")
					Exit
				EndIf
				SRA->(dbSkip())
			End

			If msProcess == MV_PAR01 .and. msRoteiro == MV_PAR02

				If !Empty(_cMatr) .and. !Empty(_cCCus)

					dbSelectArea("RGB")
					RGB->(DbSetOrder(7))
					If RGB->(DbSeek( xFilial("RGB")+ SRA->RA_MAT + MV_PAR05 + SRA->RA_CC,.T.))

						RecLock(cString,.F.)
						RGB->RGB_VALOR 	+= Val(Alltrim(Substr(cBuffer,15,11)))/100
						MSUnLock()

					ELSE

						RecLock(cString,.T.)
						RGB->RGB_FILIAL := XFILIAL("RGB")
						RGB->RGB_PROCES := msProcess
						RGB->RGB_PERIOD := MV_PAR03
						RGB->RGB_SEMANA := "01"
						RGB->RGB_ROTEIR := msRoteiro
						RGB->RGB_MAT 	:= _cMatr
						RGB->RGB_PD    	:= MV_PAR05
						RGB->RGB_TIPO1 	:= "V"
						RGB->RGB_TIPO2 	:= "I"
						RGB->RGB_VALOR 	:= Val(Alltrim(Substr(cBuffer,15,11)))/100
						RGB->RGB_DTREF 	:= Ultimodia(dDataBase)
						RGB->RGB_CC		:= SRA->RA_CC
						RGB->RGB_ITEM	:= "GPE000000"
						RGB->RGB_CLVL	:= SRA->RA_CLVL
						RGB->RGB_CODFUN	:= SRA->RA_CODFUNC
						RGB->RGB_DEPTO	:= SRA->RA_DEPTO
						MSUnLock()

					EndIf

				EndIf

			EndIf

		EndIf

		nBtLidos := fRead(nHdl,@cBuffer,nTamLin) // Leitura da proxima linha do arquivo texto

	End

	fClose(nHdl)

	msgbox("Importacao Realizada com sucesso","Importar Verba 411")

Return

Static Function ValidPerg()

	local cLoad	    := "FARMA" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local _nPeso	:=	0
	Local aPergs	:=	{}

	MV_PAR01 :=	SPACE(TAMSX3("RCJ_CODIGO")[1])
	MV_PAR02 := SPACE(TAMSX3("RY_CALCULO")[1])
	MV_PAR03 := SPACE(6)
	MV_PAR04 := space(2)
	MV_PAR05 := SPACE(TAMSX3("RV_COD")[1])
	MV_PAR06 := Space(100)

	aAdd( aPergs ,{1,"Processo " 	  				,MV_PAR01 ,""  ,"Gpem020VldPrc() .And. Gpm020SetVar()",'RCJ'  ,'.T.',50,.T.})
	aAdd( aPergs ,{1,"Roteiro de Cálculo " 	  		,MV_PAR02 ,""  ,"U_FARMAPR1()",'GPM020'  ,'.T.',50,.T.})
	aAdd( aPergs ,{1,"Período " 	  				,MV_PAR03 ,""  ,"",''  ,'.F.',50,.F.})
	aAdd( aPergs ,{1,"Nro. Pagamento " 	  			,MV_PAR04 ,""  ,"",''  ,'.F.',50,.F.})
	aAdd( aPergs ,{1,"Verba " 	  					,MV_PAR05 ,""  ,"",'SRV'  ,'.T.',50,.T.})
	aAdd( aPergs ,{6,"Arquivo "  					,MV_PAR06 ,"","","", 110 ,.T.,"Arquivos .TXT |*.TXT",,GETF_LOCALHARD+GETF_NETWORKDRIVE} )

	If ParamBox(aPergs ,"Relatório de Farmácia",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)
		MV_PAR03 := ParamLoad(cFileName,,3,MV_PAR03)
		MV_PAR04 := ParamLoad(cFileName,,4,MV_PAR04)
		MV_PAR05 := ParamLoad(cFileName,,5,MV_PAR05)
		MV_PAR06 := ParamLoad(cFileName,,6,MV_PAR06)

	EndIf

Return lRet

User Function FARMAPR1()

	Local _aPer	:=	{}
	Local _lRet	:=	fGetPerAtual( _aPer,, MV_PAR01, MV_PAR02 )

	If _lRet
		MV_PAR03	:=	_aPer[1,1]
		MV_PAR04	:=	_aPer[1,2]	
	EndIf

Return _lRet
