//Bibliotecas
#Include "Totvs.ch"
#Include "RESTFul.ch"
#Include "TopConn.ch"



WSRESTFUL zWSTarefas DESCRIPTION 'Consulta de tarefas'
    //Atributos
    WSDATA id         AS STRING
 
    //Métodos
    WSMETHOD GET    ID     DESCRIPTION 'Retorna o registro pesquisado' WSSYNTAX '/zWSTarefas/get_id?{id}'                       PATH 'get_id'        PRODUCES APPLICATION_JSON
END WSRESTFUL


WSMETHOD GET ID WSRECEIVE id WSSERVICE zWSTarefas
    Local lRet       := .T.
    Local jResponse  := JsonObject():New()
    Local cAliasWS   := 'ZZG'

    //Se o id estiver vazio
    If Empty(::id)
    
        //SetRestFault(500, 'Falha ao consultar o registro') //caso queira usar esse comando, você não poderá usar outros retornos, como os abaixo
        Self:setStatus(500) 
        jResponse['errorId']  := 'ID001'
        jResponse['error']    := 'ID vazio'
        jResponse['solution'] := 'Informe o ID'
    Else
        DbSelectArea(cAliasWS)
        (cAliasWS)->(DbSetOrder(1))

        //Se não encontrar o registro
        If ! (cAliasWS)->(MsSeek(FWxFilial(cAliasWS) + ::id))
            //SetRestFault(500, 'Falha ao consultar ID') //caso queira usar esse comando, você não poderá usar outros retornos, como os abaixo
            Self:setStatus(500) 
            jResponse['errorId']  := 'ID002'
            jResponse['error']    := 'ID não encontrado'
            jResponse['solution'] := 'Código ID não encontrado na tabela ' + cAliasWS
        Else
            //Define o retorno
            jResponse['codigo'] := (cAliasWS)->ZZG_CODIGO 
            jResponse['titulo'] := (cAliasWS)->ZZG_TITULO 
            jResponse['descri'] := (cAliasWS)->ZZG_DESCRI 
            jResponse['situac'] := (cAliasWS)->ZZG_SITUAC 
            jResponse['dtconc'] := (cAliasWS)->ZZG_DTCONC 
            jResponse['dtinc '] := (cAliasWS)->ZZG_DTINC  
        EndIf
    EndIf

    //Define o retorno
    Self:SetContentType('application/json')
    Self:SetResponse(EncodeUTF8(jResponse:toJSON()))
Return lRet
