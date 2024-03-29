#INCLUDE "RWMAKE.CH"
#INCLUDE "BUTTOM.CH"

User Function MT160OK

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
	//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
	//� identificando as variaveis publicas do sistema utilizadas no codigo �
	//� Incluido pelo assistente de conversao do AP5 IDE                    �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

	Local f
	Local p

	/*
	複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
	굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
	굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
	굇쿑un뇙o    쿍IA127    � Autor � WLADIMIR I. N. SANTANA� Data � 11/07/01 낢�
	굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
	굇쿏escri뇙o 쿣alida a gravacao da analise de cotacoes                    낢�
	굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
	굇� Uso      쿞IGACOM                                                     낢�
	굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
	굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
	賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
	*/
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Inicializa variaveis.													 �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	aFornes    := {}
	aExclui    := {}
	lRetorno   := .t.
	dDtEmissao := DDATABASE
	nErro      := 0

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Descobre a quantidade de produtos envolvidos no processo de ...    .�
	//� analise de cotacoes. E gera uma lista do fornecedores ganhadores.   �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	nTotProds := len(PARAMIXB)
	for p:=1 to nTotProds

		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//� Descobre a quantidade de Fornecedores para o produto atual.         �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		nTotForns := len(PARAMIXB[p])
		for f:=1 to nTotForns

			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
			//� Verifica se o fornecedor atual foi selecionado para gerar pedido.   �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
			if PARAMIXB[p][f][1] == "XX"

				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
				//� Captura o codigo e a Loja do fornecedor atual.                      �
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
				cCodFor  := PARAMIXB[p][f][2]
				cLojaFor := PARAMIXB[p][f][3]
				cNomFor  := PARAMIXB[p][f][4]

				//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
				//� Verifica se o fornecedor atual ja nao consta na lista de ...        �
				//� selecionados para geracao de Pedido de Compra.                      �
				//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
				if ascan(aFornes,{|x| x[1] == cCodFor+" - "+cLojaFor}) = 0

					//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
					//� Inclui o fornecedor atual na relacao de fornecedore para pedido.    �
					//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
					AADD(aFornes,{cCodFor+" - "+cLojaFor,cNomFor,"OK"})
				endif
			endif
		next
	next

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Verifica se ha fornecedores ganhadores e analisa o conceito de ...  �
	//� cada um deles.                                                      �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	/*
	if len(aFornes) > 0

	SA2->(DBSetOrder(1))
	ZZ1->(DBSetOrder(1))

	f := 1
	do while f <= len(aFornes)
	cCodFor  := substr(aFornes[f,1],01,6)
	cLojaFor := substr(aFornes[f,1],10,2)

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Posiciona o ponteiro de registros no cadastro do fornecedor atual.  �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	SA2->(DBSeek(xFilial("SA2")+cCodFor))

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Verifica se o fornecedor atual e do tipo "FQ".                      �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	if trim(SA2->A2_YGRUPO) == "FQ"

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Localiza o historico de conceitos do fornecedor atual.              �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	cMesPesq := strzero(iif(month(dDtEmissao)=1,12,month(dDtEmissao)-1),2) // Mes inicial a ser pesquisado (mes anterior ao mes de emissao).
	cAnoPesq := strzero(iif(month(dDtEmissao)=1,year(dDtEmissao)-1,year(dDtEmissao)),4) // Ano inicial a ser pesquisado (ano do mes a ser pesquisado).
	aConcEnc := {0,0,0}  // Relacao de conceitos encontrados
	nConcEnc := 0         // Conceitos encontrados

	do while .T.
	// Posiciona-se no registro correspondente ao ano de pesquisa.
	if ZZ1->(DBSeek(xFilial("ZZ1")+cCodFor+cLojaFor+cAnoPesq))

	// procura por conceitos gravados mes a mes, ate o primeiro mes do ano atual.
	p := ZZ1->(fieldpos("ZZ1_CONC"+cMesPesq))
	do while ZZ1->(fieldname(p)) <> "ZZ1_ANO"
	if alltrim(ZZ1->(fieldget(p))) <> "."
	if !empty(alltrim(ZZ1->(fieldget(p))))
	nConcEnc++
	aConcEnc[nConcEnc] := val(ZZ1->(fieldget(p)))

	// se achou todos os tres conceitos necessarios entao sai da pesquisa.
	if nConcEnc = 3
	exit
	endif
	endif
	endif
	p--
	enddo

	// Verifica se a quantidade de conceitos encontrados e igual a 3. Se nao volta ...
	// um ano e procura novamente por novos conceitos.
	if nConcEnc < 3
	cMesPesq := "12"
	cAnoPesq := strzero(val(cAnoPesq)-1,4)
	else
	exit
	endif
	else
	exit
	endif
	enddo

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Verifica se o fornecedor possui tres conceitos.                     �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	if nConcEnc == 3
	nMediaConc := (aConcEnc[1]+aConcEnc[2]+aConcEnc[3])/3

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Analisa a media dos tres ultimos conceitos e a data da 2a. ...      �
	//� chance do fornecedor atual.                                        .�
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	if nMediaConc < 6
	if empty(SA2->A2_YCHANCE)
	aFornes[f,3] := "CONCEITO INSUFICIENTE"
	nErro++
	else
	if SA2->A2_YCHANCE < dDtEmissao
	aFornes[f,3] := "DATA DE REAVALIACAO VENCIDA"
	nErro++
	endif
	endif
	else
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Exclui o fornecedor da relacao de fornecedores problematicos.       �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	aDel(aFornes,f)
	asize(aFornes,len(aFornes)-1)
	f--
	endif
	else
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Exclui o fornecedor da relacao de fornecedores problematicos, ...   �
	//� caso a quantidade de conceitos encontrados seja menor do que 3.     �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	aDel(aFornes,f)
	asize(aFornes,len(aFornes)-1)
	f--
	endif
	else
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Exclui o fornecedor da relacao de fornecedores problematicos, ...   �
	//� caso o fornecedor nao seja 'FQ'.                                    �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	aDel(aFornes,f)
	asize(aFornes,len(aFornes)-1)
	f--
	endif
	f++
	enddo
	endif

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Verifica se houve erros na avaliacao dos fornecedores.              �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	if nErro > 0

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Ordena os fornecedores por codigo, loja e nome.                     �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	asort(aFornes,,,{|x,y| x[1] < y[1]})

	cMsg := ""
	cMsg += "ATENCAO!!"+chr(13)
	cMsg += ""+chr(13)
	if len(aFornes) > 1
	cMsg += "ALGUNS DOS FORNECEDORES GANHADORES DA(S) COTACAO(OES) POSSUEM PENDENCIAS DE   "+chr(13)
	cMsg += "QUALIDADE."+chr(13)
	cMsg += "FAVOR VERIFICAR A SITUACAO DESTES FORNECEDORES CONFORME O QUADRO A SEGUIR.   "
	else
	cMsg += "O FORNECEDOR GANHADOR DA(S) COTACAO(OES) POSSUI PENDENCIA DE QUALIDADE.  "+chr(13)
	cMsg += "FAVOR VERIFICAR A SITUACAO DESTE FORNECEDOR CONFORME O QUADRO A SEGUIR. "
	endif
	alert(cMsg)

	@ 100,1 TO 500,700 DIALOG oDlg1 TITLE "Relacao de Fornecedores"
	if len(aFornes) > 1
	@ 7,5  SAY "Verifique abaixo a relacao de problemas encontrados com os fornecedores:"
	else
	@ 7,5  SAY "Verifique abaixo o problemas encontrado com o fornecedor:"
	endif
	SX3->(DbSetOrder(2))
	SX3->(DbSeek("A2_COD"))
	aHeader := {}
	AADD(aHeader,{"FORNECEDOR" ,SX3->X3_CAMPO,SX3->X3_PICTURE,40,00,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO})
	AADD(aHeader,{"ERRO"       ,SX3->X3_CAMPO,SX3->X3_PICTURE,35,00,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO})
	aCols := {}

	for f:=1 to len(aFornes)
	AADD(aCols,{aFornes[f,1]+"     "+aFornes[f,2],padr(aFornes[f,3],100)})
	next
	IW_MultiLine(15,5,196,310,.F.,.F.,,1)
	@ 15,315 BmpButton Type 1 ACTION Close(oDlg1)
	//@ 35,315 BmpButton Type 6 ACTION Imprimir()
	ACTIVATE DIALOG oDlg1 CENTERED

	lRetorno := .f.
	endif
	*/

Return(lRetorno)