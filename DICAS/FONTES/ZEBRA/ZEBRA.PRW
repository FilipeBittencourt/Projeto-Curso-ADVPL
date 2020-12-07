#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "TBICONN.CH" // BIBLIOTECA
#INCLUDE "protheus.ch"
#Include 'TopConn.ch'

/*
------------------------------------------------------------------------------------------------------------
Função   	: BRA0725
Tipo		: Etiquetas de Inventário Imprimir na Etiqueta ZEBRA
Descrição	: 
Retorno 	: Nil
OBs.: 
    Criar as perguntas - BRA0725 
       
        Quantidade ?  100
        Ano ? 2019

    Parametros: 
      
        MV_Y27055A (Codigo da Etiqueta Empresa BRASA)         
        MV_Y27055B (Codigo da Etiqueta Empresa BRAMG) 
        MV_Y27055C (Codigo da Etiqueta Empresa BRASUL) 
        
------------------------------------------------------------------------------------------------------------
*/
#Define STR_PULA	Chr(13)+Chr(10)

User Function BRA0725()

   
 	    
    Local cGrpEmp   :=  FWGrpCompany()    
    Local cBarCode  := ""
    Local cCodEtiq  := ""
    Local nQtd      := 0
    Local nCodEtA      := 0    
    Local dData     := ""

     //RPCSetEnv("99", "01", NIL, NIL, "COM", NIL, {"SB1", "SB5"})    

    Pergunte("BRA0725", .T.)    

    nQtd     := mv_par01
    dData    := cValToChar(mv_par02)
    
    If cGrpEmp == "01"
        cCodEtiq  := SuperGetMv("MV_Y27055A",.T.,"") // BRASA 
    ElseIf cGrpEmp == "02"
        cCodEtiq  := SuperGetMv("MV_Y27055B",.T.,"") // BRASUL
    Else
        cCodEtiq  := SuperGetMv("MV_Y27055C",.T.,"") // BRAMG
    EndIf


    If nQtd <= 0
        Alert("A quantidade deve ser maior que zero. ")
        Return .F.
    EndIf   

           
    If Len(dData) != 4  
        Alert("Preencha a data corretamente: AAAA ")
        Return .F.
    EndIf

    nCodEtA := cCodEtiq
    For nI := 1 To nQtd                   
        nCodEtA++
        cCodEtiq  := PADL(cValToChar(nCodEtA),5,"0")     
        cBarCode  := FWGrpCompany()+"I"+SUBSTR(dData, 3,4)+cCodEtiq //GrupoEmpresa+I+Ano+CodigoSequencialEtiqueta = 1I1900001 

        FWMsgRun(, {||  PZebra(cBarCode, dData, cCodEtiq) }, "Aguarde!", "Imprimindo "+cValToChar(nI)+"/"+cValToChar(nQtd)+"")      

    Next nI   
    
    PUTMV("MV_Y27055A", nCodEtA)

    //RPCClearEnv()    
	 

Return Nil

Static Function PZebra(cBarCode, dData, cCodEtiq)    

    Local cPorta := "LPT1" // Mapeamento feito através de NET USE
    Local cModelo := "ZEBRA"
    Local etiq := ""


    etiq += "CT~~CD,~CC^~CT~"
    etiq += "^XA~TA000~JSN^LT0^MNW^MTT^PON^PMN^LH0,0^JMA^PR4,4~SD15^JUS^LRN^CI0^XZ"
    etiq += "^XA"
    etiq += "^MMT"
    etiq += "^PW1181"
    etiq += "^LL1654"
    etiq += "^LS0"
    etiq += "^FO160,160^GFA,20736,20736,00108,:Z64:"
    etiq += "eJztXEFr41gSflJauHEgSLAix4ScBjXkD/RFDcndAQufTO5z2sMMPlq7p2b3TwifjAZ8bmIYMv8gDZPjQB8HH0wGHPri4K2vqt6T7O5dZmCeBxZXJpKsJ/dT6dNX9VVJ"
    etiq += "GWP+ry3WZfwXn8fBfq8Fsgz+4tM42O+2JI3TIo5jsw+WvTbmvf9Z2KKC/uvne5krzIzJJnuZKigK/N7sZbJ6akwXC/9WFH1gdrWPuTJ26dz3NJS3iFpFkfaSIomZYl4t"
    etiq += "rOtpWHqeRI3c6kd982ofeGV1XWF97n8qYlbRo+wV3AT+GVarX5XxzrCI/MrN1ZXpEWieLbyoJ6WgVfmdKU6GxbDopcWwR0Tr+Z0McNVll34pJJZ+pwJcRQ6OmbTwDFhY"
    etiq += "E7+IY1lFm5XfudJH8gkce8Sm37m6wAugTSWP+TTAxX71AV3uda5sUk+mhhbfGHNR+5xJ6FUghRVxQoHRawarGSrByzPBmF59LPuv8sgvwUL4dR5qrM8qn3MxUjdp8Vj"
    etiq += "0oh6EokdjelXwq6Qw3/VKMKZXj3MYpS+/BAvryYT8ooUJERE9ThWIX4TaME6HJBJ9ZrDMpq+a2dUt/U0lfiF9FSzrveJl/crIr2xqfOpf9QtJDJsm9YlXzX4ZjYmlx5"
    etiq += "kkHBb5NWElOSz3NxcRi1IXYKvMxWRS+ZtJwuGwSG7SR+IW5zB/+asr6auEhGLh4dFSSV+UwHoiFD3OBb8yCvMmI9eIZKW/qYReJDduEBMf/fY4BK+QIgfHRK8EK1Ru9"
    etiq += "K9zhi7P/c0FdTih9FWRi5Paq5536YtS15CR63+FX/+Vcn+Mi3VTfWUMV/lHT/f3m0tffd7s/c1jkyNjbzKEw4yW/iayeN1wh4O3Eo+TCV6ZVMvT0uNMLbmRG42G/Mv2"
    etiq += "Z08m6esCKSz03PDlYrlImGNpkcQJtwKC4S+wvuHWIrKaEIk+YYMPN3ZDD2kMF6sX6+FtBta2WkaLnuw1l8xztqlWMa6KzjS/uV22FGgbym4Z3ukgi9wQNa+f0frdsD"
    etiq += "3npjMej0ej77Uqow980Gg0WtmNv3doQcc4+552j7/D8KmsrIWuqpTPFECobA6Xyxl+St4i0/ObzZb8peVyOdWNWRXOdox2z37F8Mlyi69ysaPHYmgSEyR8Wzq/Ng/mV"
    etiq += "DZe+OCAtnJd856UNp70EGcv+BIPn+n3dv2aOviAkuA1r8yRbNyVPEpbpa4/YH2MY47n23aH3Tr84Qu8+oKSMSoRnV8r09GtnA/WDazX2NH5ml9r+MXDt7Jyfmn6OtfP
    etiq += "9Al+LRdsn0xIy7peLCq5CMsF/MJOBqS7WCyrbnMLLvC7MCc0znjJUVt49ZRZRQq6DWOLEl3uM+ch7itAGAtML3LitONsx68X3k2j8Y5fUi3zJpjVFbwUJbrcFoyphaf"
    etiq += "U9R12vMWOXbw+YPePGH7zFbx6r4wyKxW8LErrbb9wvvcKE/s1BoC7fq1lNx+/2sKLQkEmN1nGlaXch8tZXTOtTkCzWgl2OVvyNaDhWS07ZrPyhEmF48R+pd2LmQx/id"
    etiq += "dDEATGVmDgFwHzWNy28YIbAcOjuPGO8VfxCvTGDXb8ajQhV8yh+HXMhBK87t6//0H5IpRr4YUd5Zv5nd6GdBx/3xLy7XwrHl6Lhr/Wivna+ZXjrNd0yZ+vrwfCF3bji"
    etiq += "f36zDca0zC/3bxogB/gchBbN4rreAcv5C9afUPqEBqR5CLabQvAkRE9ssWU+cQnSPwhyuES0Ibh/fWCcrpFJayVfjReGqnptvEaUs01HMZQhyk04pADWWySMVPlOQa"
    etiq += "f4BetgEBMw8/kF2j4stn0yK9YLAX94vgUww98HZ6+wMugDUVbFWt6wYsv9wf+FeQQJe+OGYHj+Q8MyPG8JrzeOhaFln5TwVWWzvTG404UYdZP+eMZ+yF4rdyF72zW8"
    etiq += "vEWJ54DN6zHLjp0LK2exKMdv8Av4FWhQV9mnGQpkDGfLml5Oat4C8twNrUD1QwEOplNaH1psxsdMCtluP21Nl5EKyopA5GJ1q8XvtxrueR64ckNGbjd/MYenG0eN5"
    etiq += "tg7LJUx9Lqo3xN2LiFF1XLhotlYzOZJB7QQyKhpdXUDlSMzJv5PwjYucPryNKqnP/QfM3ZtVTLJo9EduTsl0PJ+YUTHGxWHQXytzE8uN1ck08NixSvMTBcsV/323i"
    etiq += "heYjpkbgmkzJE/hLK1JS1as5clKUM06XLGelyUTGTsgUxzHzLnON/TNIWns7w1+TLW3j1U370JWClQ/WL2SKXPLV0eThVID/CU1rTZ1qu9Ln0KUeTdPOScOZKvoYX"
    etiq += "9w2lCpuabKqBjIMiX/JQcKDlkRKvZLzAtzuF1BhLy6MWLcv2XCw3UslcfZH2ffbrKqKonkd8anp/EQ4dPvPx5ifgFW3WHb5VnyXrqV8dS8tIZUqDF5QrP/rKyq6kM"
    etiq += "GFWiBxFC/gl2Wo5063LWXnJ2rHGZ8pvFxcXGS4Ssy6krJXNWDPPtvwCRDcp+oZSheEDGEKhGzmK8PqY0NXnbEXLFGdu8SJgTjlbvUD8s18vsgz4G7v3YVeqZXn0JVp"
    etiq += "xKjqCcxVFuOn7fwkiwOFIExvjpXyzqtDidUzfYx4e7eAVSfXFj760ldgXHcG5lS7559GIgjnjsBIIAibQPTlA2nAdWZVhw+iAKMlbX+BF+YuSVsVPUqAVuV7JoAqRw"
    etiq += "6AEF7XQBp24kPMWJ63KnDDfQpGS2O/YJwkw3OnaMV6UtFBKiba/SZG52HqxCsXnmM/6CXj1gMMN4UXyj7TGOm0ECUfLBFCeAVca2ep/hFItIxergJ2+tuUXQXNkgVM"
    etiq += "cjPKKklYFmhFkR1YV2jAqUN658NjGawC8ojzqiWjovxJhsWnJ+Z9xKLlhIuEV8HoiVO9vESIdXswqoClMEzJu+ZVZXUD0glpkJs2k6oISnC05GoJVqMB4QR8+GdaGV"
    etiq += "bic2QpNshvRELzUxc59iPI2+hjcqBpiQBQDi5cRVklKogVyb8Aa6qmp0CyrXlSInW6XX0bSFj/6MqrySouXVFIwVkWWWtii1FXpqoUXR8HQQSV02/Yr4kdfefB9y6/"
    etiq += "Pnz+DYLZgyRWHALyK2K+VrJ46jeDXKLjWCNr5wi/KV/WEn3tl3OsA1yhfXZxnJPK6i2UN8gCwBWplJCaQrLv4hGx1yStb64iYRO7jUNjd4VfCaWuINzcSi1ccgVrgl"
    etiq += "tPqKxaJN0mqcZAItDrlPAW85GqAWU9MsjTFd3fLZW5FhPbRl+BVab465tqKtLqUX0dQ9u+lhr6zsfAtymXHIsaLK4B/C8m2yi+uuiJ+9JUb9auvgYyW92c46QGjQRA"
    etiq += "MBiMh3Vr8WkEBnjZRj1UGpb3RaIAQf7ZdVqJ/iGfLtJIXOTL2i7MUctcJ84TbFV3UZPVSh0+gFSsowJOlYxHrwUuGDzw8ccJRLJCGEq0C23vqNX4BryAQOW+he2Le"
    etiq += "EBZnJEfGfIj9t1SEiD2Y2128MklfLBK7yq8jW11VQpG54GAr52Ouyz68mZfNIUa/4LhJmzvlMgRHnuLRV18kPVdjHVtd3d+qbhIcXJBcwTdQbcyQtv2yrRHyf6es5L"
    etiq += "dEu0SpScUPl4lhk1J1Hi2rjLdQiMlzTU7cIX2kayGtb0phC/tvLTjDSaeDeJhttzdMMCx6eDvq8Sb9RTuBPY7STKgH69fa5TQOkmstvQSvF2SpWPW76+I8xePd+7Ar"
    etiq += "3AJqpX12aXUeamFXfjXtC8HrTuRjuYVX6WAlXHfKZeAFyCIRHYqX1XmI46LfVw0O8EkTmwncIbAICFpYmXw7eHWRvko8/xKRyFUmU4bUXnm5tIVYiC5HjR8aAMdmM8"
    etiq += "JpWZNSdFEPpLpc8FFLV7u1LAW36FZENAzSQsuvjXQz3jV4Ob9erPAQ+fgTHRKQCV73gfPrGYIYIy2/IAvLrhZedatcPmZZIXhNwTlpYdyx8DiSICntjTZeb+cM+pyF"
    etiq += "4w5eEXqGubxww0VYn/26uroeb2wdNWaAnrWFgaTFbq5Uedg4z+FG1H0xZryeBX9rIWQhiUMIxQopbIq+32JykUEWCkWw7EqLI+Sdn5DDkLLqBWvJBUsSGiu18tLeCK"
    etiq += "TlsmzwQumfsKantS2XFZrE+sWVR8y9i018q3ghk21s/HtiPdjTFgdKADvSqsEofVHRVWqjQ/GyVLLlMsjC53us2jDkVmLI5ZeVkBAZ2uKgw91I4xeeLOOtDaGWNH5d"
    etiq += "6AsavG7l/IR0D9r6heRo/MKYlsxo9Vq/7hu/zlF9gWQ1chhLRdsRhAT8xLz51ZKFchlvQhWWrAAvRUt+Ej0Yaja7pLX2E51fQSDp651oebonHxq/UC5Ln2KlrQCElH"
    etiq += "e3ohHZrzYqCDenGvXPtI247ReFQ7zXqzGcX2h74/S87StNjaqKI25AldgnMrCF1zFzT9h27Ebamj5ndRgVFrDc+fWs5TLwsrUUkhrCnnRrOg0qUla7nAX/1a+GX3is"
    etiq += "XIYV+vR8I2ZGyi8RhdIvrGtSgRL1wKEMvY0azMPe2h2Moss2E6ENm8JMLY6hOD6meAmRElkyjGMb036O1a8Ni0GupYg/qJXjYCOy3aHyYGKiZaJ+YftRR9ov8GTuXQ"
    etiq += "Dkrm+MLZel/BK8PlgcwrntbagWbLGo3ewgiv5TBn5s4cWKI3faEH2KAR5j8XOV0YiudjAY9dOBPMqKBqN8MMhxDPr4g++CAR+NXad0zGAgbnQGo+vBiIYGW2+E4MUo"
    etiq += "pldd7wjwP90gDbUxj3CN58sJG8bsMpbPvM2b2IdlLDsS/ZrsluNaI86IVa9t7eX7fWyAFDm//M5F4fCc2/S15/c3UIH1k+YZ8RC7XFcibn1oWhVf+1PM+H9uOSOtYen"
    etiq += "VPEn2ZGk/svQqvL8/X+lbHJTA/L7eS371onfOL8/vz8PqPfHLmFeOXp5fn4fxU+aJ/3hINEiUXsOd9y282L7oBdsXvWBaC3t9+1DNZa99/IXlHuGK9ggX4cWdwz3AZ"
    etiq += "YJ0KPzax/8ioLs3uBxg+4DLvt61l6mIYI/0s7f/o8P7cl8zvbq62stfL+/V8DfMeEJsfw52sIMd7GAHO9jBDnawgx3sL7L/AHxFr1c=:5655"
    etiq += "^FO54,31^GB1077,1584,6^FS"
    etiq += "^FT304,558^A0N,92,91^FB574,1,0,C^FH\^FDInvent\A0rio "+dData+"^FS"
    etiq += "^FT83,798^A0N,62,62^FB1013,1,0,C^FH\^FDFardo localizado sem etiqueta.^FS"
    etiq += "^FT83,876^A0N,62,62^FB1013,1,0,C^FH\^FDSubstituir esta etiqueta no pr\A2ximo ano.^FS"
    etiq += "^FT497,1459^A0N,62,62^FB184,1,0,C^FH\^FD"+cCodEtiq+"^FS"
    etiq += "^BY6,3,279^FT170,1381^BCN,,N,N"
    etiq += "^FD>:"+cBarCode+"^FS"
    etiq += "^PQ1,0,1,Y^XZ"

   // MSCBPRINTER(cModelo, cPorta,,10,.F.,,,,,,.F.,)
    MSCBPRINTER(cModelo,cPorta,NIL,,.F.,NIL,NIL,NIL,,1024,.T.)

    MSCBBEGIN(1,6)
    //|Envia o código ZPL para impressora |
    MSCBWrite(etiq)
    //|Finaliza o arquivo de impressao |
    MSCBEND()
    //|Fecha conexao com a aimpressora |
    MSCBClosePrinter()

    //ShellExecute("Open","C:\facile\ZEBRA_TESTE.bat","","",5)
  //  ShellExecute("Open", "C:\facile\ZEBRA_TESTE.bat", " ", etiq, 1)
    /*If !Empty(::cEtiqZPL) .And. !Empty(_cPrinter)

        If CB5SetImp(_cPrinter)

            MSCBBEGIN(1,6)
            //|Envia o código ZPL para impressora |
            MSCBWrite(etiq)
            //|Finaliza o arquivo de impressao |
            MSCBEND()
            //|Fecha conexao com a aimpressora |
            MSCBClosePrinter()

        EndIf

    EndIf*/

Return .F.