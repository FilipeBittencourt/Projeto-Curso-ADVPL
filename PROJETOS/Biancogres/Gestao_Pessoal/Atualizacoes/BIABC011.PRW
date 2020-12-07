//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} BIABC011
@author Barbara Luan Gomes Coelho
@since 12/05/20
@version 1.1
@description Função que testa a Criação e Leitura de um arquivo XML
@type function
/*/
 
User Function BIABC011()
    Local aArea      := GetArea()
    Private cDirect  := GetTempPath()
    Private cPasta   := ""
    Private cArquivoSIG := ""
    Private cArquivoRET := ""
     
    //Criação do arquivo XML
    fCriaXML()
     
    //Leitura do arquivo XML
    //fLeXML()
     
    RestArea(aArea)
Return
 
/*---------------------------------------------------------------------*
 | Func:  fCriaXML                                                     |                                             |
 | Desc:  Função que cria o arquivo XML                                |
 *---------------------------------------------------------------------*/
         
Static Function fCriaXML()
    Local nHdlSIG  := 0
    Local nHdlRET  := 0
    Local aArea := GetArea()
    Local cQry  := ""       
   
    cQry := " WITH TMP AS (
	cQry += " 	SELECT DISTINCT ID_ENT,  FANTASIA, MAX(DTULTALT) OVER (PARTITION BY ID_ENT)DTULTALT
	cQry += " 	FROM SPED001A  
	cQry += " 	WHERE D_E_L_E_T_ = '') 
    cQry += " SELECT Trim( UTL_RAW.CAST_TO_VARCHAR2( DBMS_LOB.SUBSTR( XMLRET,4000 ) ) ) As XMLTESTE,
    cQry += " 		 SUBSTRING(ISNULL(LTRIM(RTRIM(CONVERT(VARBINARY(max), XMLRET))), ''),1,4000) XMLRET1,
    cQry += " 		 SUBSTRING(ISNULL(LTRIM(RTRIM(CONVERT(VARBINARY(max), XMLRET))), ''),4001,4000) XMLRET2,
    cQry += " 		 SUBSTRING(ISNULL(LTRIM(RTRIM(CONVERT(VARBINARY(max), XMLRET))), ''),8001,4000) XMLRET3,
    cQry += " 		 SUBSTRING(ISNULL(LTRIM(RTRIM(CONVERT(VARBINARY(max), XMLRET))), ''),12001,4000) XMLRET4,
    cQry += " 		 SUBSTRING(ISNULL(LTRIM(RTRIM(CONVERT(VARBINARY(max), XMLRET))), ''),16001,4000) XMLRET5,
    cQry += " 		 SUBSTRING(ISNULL(LTRIM(RTRIM(CONVERT(VARBINARY(max), XMLRET))), ''),20001,4000) XMLRET6,
    cQry += " 		 SUBSTRING(ISNULL(LTRIM(RTRIM(CONVERT(VARBINARY(max), XMLRET))), ''),24001,4000) XMLRET7,
    cQry += " 		 SUBSTRING(ISNULL(LTRIM(RTRIM(CONVERT(VARBINARY(max), XMLRET))), ''),28001,4000) XMLRET8,
    cQry += " 		 SUBSTRING(ISNULL(LTRIM(RTRIM(CONVERT(VARBINARY(max), XMLRET))), ''),32001,4000) XMLRET9,
    cQry += " 		 SUBSTRING(ISNULL(LTRIM(RTRIM(CONVERT(VARBINARY(max), XMLRET))), ''),36001,4000) XMLRET10,      
    cQry += " 		 SUBSTRING(ISNULL(LTRIM(RTRIM(CONVERT(VARBINARY(max), XMLSIG))), ''),1,4000) XMLSIG1,   
    cQry += " 		 SUBSTRING(ISNULL(LTRIM(RTRIM(CONVERT(VARBINARY(max), XMLSIG))), ''),4001,4000) XMLSIG2,  
    cQry += " 		 SUBSTRING(ISNULL(LTRIM(RTRIM(CONVERT(VARBINARY(max), XMLSIG))), ''),8001,4000) XMLSIG3, 
    cQry += " 		 SUBSTRING(ISNULL(LTRIM(RTRIM(CONVERT(VARBINARY(max), XMLSIG))), ''),12001,4000) XMLSIG4,  
    cQry += " 		 SUBSTRING(ISNULL(LTRIM(RTRIM(CONVERT(VARBINARY(max), XMLSIG))), ''),16001,4000) XMLSIG5,  
    cQry += "        RTRIM(LTRIM(CODEVENTO))EVENTO, RTRIM(LTRIM(CHAVE))CHAVE,
    cQry += "        ID_ENT, REPLACE(FANTASIA,'.','')FANTASIA
    cQry += " FROM SPED400 WITH(NOLOCK)
    cQry += " INNER JOIN TMP WITH(NOLOCK) ON ENTIDADE = ID_ENT
    cQry += " WHERE XMLRET IS NOT NULL
    cQry += " AND XMLSIG IS NOT NULL
    cQry += " AND D_E_L_E_T_ = ''       
    cQry += " AND STATUS <> 5
    //cQry += " AND CODEVENTO IN ('S-2190', 'S-2200', 'S-2205', 'S-2206', 'S-2230', 'S-2250', 'S-2298', 'S-2299', 'S-2300', 'S-2306',  'S-2399', 'S-3000')
    cQry += " AND FANTASIA LIKE 'BIANCOGRES%'
    cQry += " AND ISNULL(CONVERT(VARCHAR(8000), CONVERT(VARBINARY(8000), XMLRET)), '')<> ''
    cQry += " AND ISNULL(CONVERT(VARCHAR(8000), CONVERT(VARBINARY(8000), XMLSIG)), '')<> ''
    TCQuery cQry New Alias "SPED" 
                 
       
    //Monta o XML
    While !SPED->(EoF()) 
        cArquivoSIG := cDirect + 'XML\' + TRIM(SPED->FANTASIA)+ '\' + TRIM(SPED->EVENTO) + '\' + TRIM(SPED->EVENTO) + TRIM(SPED->CHAVE) + "SIG.XML"
        cArquivoRET := cDirect + 'XML\' + TRIM(SPED->FANTASIA)+ '\' + TRIM(SPED->EVENTO) + '\' + TRIM(SPED->EVENTO) + TRIM(SPED->CHAVE) + "RET.XML"    
          
        //Gerando os arquivos e pegando o handle (ponteiro)
		FErase(cArquivoSIG)
		FErase(cArquivoRET)
			
		nHdlSIG := FCreate(cArquivoSIG)
		nHdlRET := FCreate(cArquivoRET)
			
		//Se houve erro na criação
	    If nHdlSIG == -1 
	        CONOUT("Não foi possível gerar o arquivo:"+cArquivoSIG)
	    endif
	    If nHdlRET == -1
	        CONOUT("Não foi possível gerar o arquivo:"+cArquivoRET) 
	    endif

	    fWrite(nHdlSIG, SPED->XMLSIG1+SPED->XMLSIG2+SPED->XMLSIG3+SPED->XMLSIG4+SPED->XMLSIG5)
	    fWrite(nHdlRET, SPED->XMLRET1+SPED->XMLRET2+SPED->XMLRET3+SPED->XMLRET4+SPED->XMLRET5+SPED->XMLRET6+SPED->XMLRET7+SPED->XMLRET8+SPED->XMLRET9+SPED->XMLRET10)

			            
       	//Finalizando o Handle
       	fClose(nHdlSIG)
       	fClose(nHdlRET)

        SPED->(DbSkip())
    EndDo
    //RestArea(aArea)
    SPED->(DbCloseArea())        
         
    //Abrindo o arquivo
    ShellExecute("OPEN", cArquivoSIG, "", cDirect, 0 )
    ShellExecute("OPEN", cArquivoRET, "", cDirect, 0 )

    RestArea(aArea)
Return
 
/*---------------------------------------------------------------------*
 | Func:  fLeXML                                                       |
 | Autor: Daniel Atilio                                                |
 | Data:  17/08/2016                                                   |
 | Desc:  Função que faz a leitura do arquivo XML                      |
 *---------------------------------------------------------------------*/
         
Static Function fLeXML()
    Local oLido    := Nil
    Local oProds   := Nil
    Local nAtual   := 0
    Local cReplace := "_"
    Local cErros   := ""
    Local cAvisos  := ""
    Local cMsg     := ""
     
    //Se o arquivo existir
    If File(cDirect+cArquivo)
        //Lendo o arquivo com XMLParser (lê a string), caso queira ler o arquivo direto, utilize o XMLParserFile (o arquivo deve estar dentro da system)
        oLido := XmlParser(MemoRead(cDirect+cArquivo), cReplace, @cErros, @cAvisos)
         
        //Se tiver erros, mostra ao usuário
        If !Empty(cErros)
            Aviso('Atenção', "Erros: "+cErros, {'Ok'}, 03)
        EndIf
         
        //Se tiver avisos, mostra ao usuário
        If !Empty(cAvisos)
            Aviso('Atenção', "Avisos: "+cAvisos, {'Ok'}, 03)
        EndIf
         
        //Montando a Mensagem, data e hora
        cMsg := "Data: "+oLido:_Dados:_Data:Text + Chr(13)+Chr(10)
        cMsg := "Hora: "+oLido:_Dados:_Hora:Text + Chr(13)+Chr(10)
         
        //Percorrendo os produtos
        oProds := oLido:_Dados:_Produtos:_Produto
        For nAtual := 1 To Len(oProds)
            cMsg += "ID: "+oProds[nAtual]:_ID:Text+", "
            cMsg += "Código: "+oProds[nAtual]:_Codigo:Text+", "
            cMsg += "Descrição: "+oProds[nAtual]:_Descricao:Text
            cMsg += Chr(13)+Chr(10)
        Next
         
        //Mostrando a mensagem do xml lido
        Aviso('Atenção', cMsg, {'Ok'}, 03)
    EndIf
Return

User Function fIndentaXML(cTextoOrig)
    Local aArea      := GetArea()
    Local cTextoNovo := ""
    Local aLinhas    := {}
    Local cEspaco    := ""
    Local nAbriu     := 0
    Local nAtual     := 0
    Local aLinNov    := {}
     
    //Se tiver conteúdo texto, e tiver o trecho de XML
    If ! Empty(cTextoOrig) .And. '<?xml version=' $ cTextoOrig
         
        //Substitui a fecha chaves para um enter
        cTextoNovo := StrTran(cTextoOrig, "</",                "fIndentaXML_QUEBR")
        cTextoNovo := StrTran(cTextoNovo, "<",                 CRLF + "<")
        cTextoNovo := StrTran(cTextoNovo, ">",                 ">" + CRLF)
        cTextoNovo := StrTran(cTextoNovo, "fIndentaXML_QUEBR",  CRLF + "</")
         
        //Pega todas as linhas
        aLinhas := StrTokArr(cTextoNovo, CRLF)
         
        //Percorre as linhas adicionando espaços em branco
        For nAtual := 1 To Len(aLinhas)
            //Somente se tiver conteúdo
            If ! Empty(aLinhas[nAtual])
             
                //Se for abertura de tag, e não for fechamento na mesma linha, aumenta a tabulação 
                If "<" $ aLinhas[nAtual] .And. ! "<?" $ aLinhas[nAtual] .And. ! "</" $ aLinhas[nAtual] .And. ! "/>" $ aLinhas[nAtual]
                    nAbriu += 1
                EndIf
                 
                //Definindo a quantidade de espaços em branco, conforme número de tags abertas
                cEspaco := ""
                If nAbriu > 0
                    cEspaco := Replicate(' ', 2 * (nAbriu + Iif(! "<" $ aLinhas[nAtual], 1, 0)) )
                EndIf
                 
                //Monta agora o texto com a tabulação
                aAdd(aLinNov, cEspaco + aLinhas[nAtual])
                 
                //Se for fechamento de tag, diminui a tabulação
                If "</" $ aLinhas[nAtual] .And. At('<', SubStr(aLinhas[nAtual], 2, Len(aLinhas[nAtual]))) == 0
                    nAbriu -= 1
                EndIf
            EndIf
        Next
         
        //Monta agora o texto novo
        cTextoNovo := ""
        For nAtual := 1 TO Len(aLinNov)
            cTextoNovo += aLinNov[nAtual] + CRLF
        Next
    EndIf
     
    RestArea(aArea)
Return cTextoNovo